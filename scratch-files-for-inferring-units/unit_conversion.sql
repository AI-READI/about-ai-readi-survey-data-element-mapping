%sql
-- Unit inference, Part C: conversion to a canonical unit per test.
-- Fills canonical_unit_concept_id and harmonized_value_as_number for every
-- numeric record with an effective unit
--   COALESCE(NULLIF(unit_concept_id, 0), inferred_unit_concept_id).
-- Unitless records (harmonized = value already) and suspect_concept records
-- are not touched.
--
-- A "test" is the measurement concept; for concept 0 it is the
-- measurement_source_value (test_id 'src:<source value>').
--
-- How conversion works:
--   unit_factors   every unit -> a base unit, base = slope * x + intercept.
--                  Units with the same base convert directly. Equivalent
--                  codes (/min = {counts}/min, % = %{of'HGB}, [iU]/L = [U]/L)
--                  are just units with the same factor.
--   unit_analytes  name patterns that give a test an analyte, with molar mass
--                  and/or charge. These bridge bases for that analyte only:
--                  g/L <-> mol/L by molar mass, eq/L <-> mol/L by charge
--                  (so mEq/L = mmol/L for monovalent ions, 0.5 for Ca, Mg).
--                  HbA1c % <-> mmol/mol is an affine bridge.
--   canonical unit the most common unit for the test (counting equivalent
--                  codes together), unless canonical_unit_rules says otherwise.
-- Conversion: canonical = slope * value_as_number + intercept, per
-- (test, unit), in unit_conversion_decisions.
-- Methods written: identity, same_base, analyte_bridge, no_conversion.
-- canonical_unit_concept_id is set only where harmonized_value_as_number is,
-- so a non-null harmonized value is always in canonical_unit_concept_id.
--
-- Each %sql block is one cell. Blocks that end in a SELECT show its result;
-- the others build tables and show nothing.


-- ===== C1. Hand-written rule tables =====

-- 13. Unit factors. base is just a label; units convert only within a base
--     (or across bases through an analyte bridge, 14b).
--     unit_code is the UCUM code as OMOP spells it (checked in 13c).
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_factors AS
SELECT unit_code, base, CAST(slope AS DOUBLE) AS slope,
       CAST(intercept AS DOUBLE) AS intercept, note
FROM VALUES
  -- mass (body weight)
  ('kg',               'g',       1000,          0, NULL),
  ('g',                'g',       1,             0, NULL),
  ('[lb_us]',          'g',       453.59237,     0, 'pound'),
  ('[oz_av]',          'g',       28.349523125,  0, 'ounce'),
  -- length (body height)
  ('m',                'm',       1,             0, NULL),
  ('cm',               'm',       0.01,          0, NULL),
  ('mm',               'm',       0.001,         0, NULL),
  ('[in_i]',           'm',       0.0254,        0, 'inch'),
  ('[in_us]',          'm',       0.0254,        0, 'US survey inch, treated as international'),
  ('[ft_i]',           'm',       0.3048,        0, 'foot'),
  -- temperature
  ('Cel',              'Cel',     1,             0, NULL),
  ('[degF]',           'Cel',     5 / 9,         -160 / 9, 'C = (F - 32) * 5/9'),
  ('K',                'Cel',     1,             -273.15, NULL),
  -- pressure
  ('kPa',              'kPa',     1,             0, NULL),
  ('mm[Hg]',           'kPa',     0.133322387415, 0, NULL),
  ('cm[H2O]',          'kPa',     0.0980665,     0, NULL),
  -- time
  ('s',                's',       1,             0, NULL),
  ('ms',               's',       0.001,         0, NULL),
  ('min',              's',       60,            0, NULL),
  ('h',                's',       3600,          0, NULL),
  ('d',                's',       86400,         0, NULL),
  ('wk',               's',       604800,        0, NULL),
  ('mo',               's',       2629800,       0, 'mean month'),
  ('a',                's',       31557600,      0, 'mean year'),
  -- rates
  ('/min',             '/min',    1,             0, NULL),
  ('{counts}/min',     '/min',    1,             0, 'same as /min'),
  -- volumes and flows
  ('L',                'L',       1,             0, NULL),
  ('dL',               'L',       0.1,           0, NULL),
  ('mL',               'L',       0.001,         0, NULL),
  ('uL',               'L',       1e-6,          0, NULL),
  ('L/min',            'L/min',   1,             0, NULL),
  ('mL/min',           'L/min',   0.001,         0, NULL),
  ('mL/h',             'L/min',   1 / 60000,     0, NULL),
  ('L/h',              'L/min',   1 / 60,        0, NULL),
  ('L/s',              'L/min',   60,            0, NULL),
  ('mL/s',             'L/min',   0.06,          0, NULL),
  -- mass concentration
  ('g/L',              'g/L',     1,             0, NULL),
  ('g/dL',             'g/L',     10,            0, NULL),
  ('mg/mL',            'g/L',     1,             0, NULL),
  ('mg/dL',            'g/L',     0.01,          0, NULL),
  ('mg/L',             'g/L',     0.001,         0, NULL),
  ('ug/mL',            'g/L',     0.001,         0, NULL),
  ('ug/dL',            'g/L',     1e-5,          0, NULL),
  ('ug/L',             'g/L',     1e-6,          0, NULL),
  ('ng/mL',            'g/L',     1e-6,          0, NULL),
  ('ng/dL',            'g/L',     1e-8,          0, NULL),
  ('ng/L',             'g/L',     1e-9,          0, NULL),
  ('pg/mL',            'g/L',     1e-9,          0, NULL),
  -- molar and equivalent concentration
  ('mol/L',            'mol/L',   1,             0, NULL),
  ('mmol/L',           'mol/L',   1e-3,          0, NULL),
  ('umol/L',           'mol/L',   1e-6,          0, NULL),
  ('nmol/L',           'mol/L',   1e-9,          0, NULL),
  ('pmol/L',           'mol/L',   1e-12,         0, NULL),
  ('nmol/mL',          'mol/L',   1e-6,          0, NULL),
  ('10*-3.eq/L',       'eq/L',    1e-3,          0, 'mEq/L'),
  -- per 24 hours
  ('g/(24.h)',         'g/d',     1,             0, NULL),
  ('mg/(24.h)',        'g/d',     1e-3,          0, NULL),
  ('ug/(24.h)',        'g/d',     1e-6,          0, NULL),
  ('mmol/(24.h)',      'mol/d',   1e-3,          0, NULL),
  ('10*-3.eq/(24.h)',  'eq/d',    1e-3,          0, 'mEq/24 h'),
  ('L/(24.h)',         'L/d',     1,             0, NULL),
  ('mL/(24.h)',        'L/d',     1e-3,          0, NULL),
  -- counts per volume
  ('/L',               '/L',      1,             0, NULL),
  ('10*6/L',           '/L',      1e6,           0, NULL),
  ('10*9/L',           '/L',      1e9,           0, NULL),
  ('10*12/L',          '/L',      1e12,          0, NULL),
  ('/uL',              '/L',      1e6,           0, NULL),
  ('/mm3',             '/L',      1e6,           0, NULL),
  ('10*3/uL',          '/L',      1e9,           0, NULL),
  ('10*6/uL',          '/L',      1e12,          0, NULL),
  -- percent (mmol/mol gets its own base so it never meets % without a bridge)
  ('%',                '%',       1,             0, NULL),
  ('%{of\'HGB}',       '%',       1,             0, 'same as %'),
  ('mmol/mol',         'mol/mol', 1e-3,          0, NULL),
  -- enzyme and international units ([iU]/L = [U]/L)
  ('[iU]/L',           'U/L',     1,             0, NULL),
  ('[U]/L',            'U/L',     1,             0, 'same as [iU]/L'),
  ('U/L',              'U/L',     1,             0, 'same as [iU]/L'),
  ('10*3.[iU]/L',      'U/L',     1000,          0, NULL),
  ('[iU]/mL',          'U/L',     1000,          0, NULL),
  ('10*-3.[iU]/mL',    'U/L',     1,             0, 'mIU/mL'),
  ('10*-6.[iU]/mL',    'U/L',     0.001,         0, 'uIU/mL')
AS t(unit_code, base, slope, intercept, note);

-- 13a. Analytes. A test gets the first analyte (lowest priority) whose
--      pattern matches its concept name (or source value, for concept 0).
--      molar_mass bridges g/L <-> mol/L and g/d <-> mol/d;
--      charge bridges eq/L <-> mol/L and eq/d <-> mol/d;
--      both together bridge eq/L <-> g/L and eq/d <-> g/d.
--      A loose pattern is harmless unless the test carries units in two
--      bridged bases; 14b lists every assignment.
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_analytes AS
SELECT analyte, priority, pattern, CAST(molar_mass AS DOUBLE) AS molar_mass,
       CAST(charge AS INT) AS charge, note
FROM VALUES
  ('hba1c',          1,  '(?i)a1c',                     NULL,   NULL, 'affine bridge in 13b'),
  ('urea_nitrogen',  2,  '(?i)urea nitrogen|BUN',       28.014, NULL, 'as N2: mg/dL x 0.357 = mmol/L urea'),
  ('creatinine',     3,  '(?i)creatinine',              113.12, NULL, NULL),
  ('glucose',        4,  '(?i)glucose',                 180.16, NULL, NULL),
  ('triglyceride',   5,  '(?i)triglyceride',            885.7,  NULL, 'mg/dL x 0.01129 = mmol/L'),
  ('cholesterol',    6,  '(?i)cholesterol',             386.65, NULL, 'total, HDL, LDL'),
  ('vitamin_d_25oh', 7,  '(?i)25-hydroxyvitamin d|calcidiol|calcifediol', 400.64, NULL, NULL),
  ('calcium',        8,  '(?i)calcium',                 40.078, 2,    NULL),
  ('magnesium',      9,  '(?i)magnesium',               24.305, 2,    NULL),
  ('phosphorus',     10, '(?i)phosph',                  30.974, NULL, 'reported as P'),
  ('uric_acid',      11, '(?i)urate|uric acid',         168.11, NULL, NULL),
  ('bilirubin',      12, '(?i)bilirubin',               584.66, NULL, NULL),
  ('iron',           13, '(?i)iron',                    55.845, NULL, NULL),
  ('sodium',         14, '(?i)sodium',                  22.990, 1,    NULL),
  ('potassium',      15, '(?i)potassium',               39.098, 1,    NULL),
  ('chloride',       16, '(?i)chloride',                35.453, 1,    NULL),
  ('bicarbonate',    17, '(?i)bicarbonate|carbon dioxide', 61.017, 1, 'total CO2 reported as HCO3'),
  ('lithium',        18, '(?i)lithium',                 6.94,   1,    NULL),
  ('anion_gap',      19, '(?i)anion gap',               NULL,   1,    NULL)
AS t(analyte, priority, pattern, molar_mass, charge, note);

-- 13b. Bridges between bases, per analyte, both directions.
--      to_base = slope * from_base + intercept.
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_analyte_bridges AS
WITH one_way AS (
  SELECT * FROM (
    SELECT a.analyte, p.from_base, p.to_base,
           CASE p.via WHEN 'mass'   THEN 1 / a.molar_mass
                      WHEN 'charge' THEN 1 / a.charge
                      ELSE a.molar_mass / a.charge
           END AS slope,
           0D AS intercept
    FROM hive_metastore.ehr_union_clean_metrics.unit_analytes a
    CROSS JOIN VALUES
      ('mass',      'g/L',  'mol/L'),
      ('mass',      'g/d',  'mol/d'),
      ('charge',    'eq/L', 'mol/L'),
      ('charge',    'eq/d', 'mol/d'),
      ('charge_mass', 'eq/L', 'g/L'),
      ('charge_mass', 'eq/d', 'g/d')
    AS p(via, from_base, to_base)
  ) WHERE slope IS NOT NULL
  UNION ALL
  -- IFCC mmol/mol = 10.929 * (NGSP % - 2.15)
  SELECT 'hba1c', '%', 'mol/mol', 0.010929D, -0.010929D * 2.15D
)
SELECT * FROM one_way
UNION ALL
SELECT analyte, to_base, from_base, 1 / slope, -intercept / slope FROM one_way;

-- 13c. Canonical-unit overrides. test_id is the measurement concept id as a
--      string, or 'src:<measurement_source_value>' for concept 0.
--      Everything not listed gets its most common unit.
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.canonical_unit_rules AS
SELECT * FROM VALUES
  ('3025315', 'kg',  'Body weight'),
  ('3036277', 'cm',  'Body height'),
  ('3020891', 'Cel', 'Body temperature'),
  ('3004410', '%',   'Hemoglobin A1c')
AS t(test_id, unit_code, note);


%sql
-- 13d. CHECK (should return no rows): bad or duplicate codes, duplicate bridges.
--      Paste any rows this returns; I'll correct them.
WITH codes AS (
  SELECT 'unit_factors' AS src, unit_code FROM hive_metastore.ehr_union_clean_metrics.unit_factors
  UNION ALL
  SELECT 'canonical_unit_rules', unit_code FROM hive_metastore.ehr_union_clean_metrics.canonical_unit_rules
)
SELECT concat(c.src, ': not a UCUM code') AS problem, c.unit_code AS item
FROM codes c
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = c.unit_code
  AND ru.invalid_reason IS NULL
WHERE ru.concept_id IS NULL
UNION ALL
SELECT 'unit_factors: duplicate code', unit_code
FROM hive_metastore.ehr_union_clean_metrics.unit_factors
GROUP BY unit_code HAVING COUNT(*) > 1
UNION ALL
SELECT 'canonical_unit_rules: duplicate test_id', test_id
FROM hive_metastore.ehr_union_clean_metrics.canonical_unit_rules
GROUP BY test_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'duplicate bridge', concat_ws(' ', analyte, from_base, to_base)
FROM hive_metastore.ehr_union_clean_metrics.unit_analyte_bridges
GROUP BY analyte, from_base, to_base HAVING COUNT(*) > 1;


%sql
-- 13e. Review: canonical-unit overrides. concept_name should match note.
SELECT r.test_id, r.note, mc.concept_name, r.unit_code
FROM hive_metastore.ehr_union_clean_metrics.canonical_unit_rules r
LEFT JOIN omop_vocab.concept mc ON mc.concept_id = try_cast(r.test_id AS INT);


%sql
-- ===== C2. Tests and their units =====

-- 14. Keyed view: numeric records in scope, with test_id and effective unit.
--     The MERGE in 16 uses the same keys.
CREATE OR REPLACE VIEW hive_metastore.ehr_union_clean_metrics.measurement_unit_keyed AS
SELECT *,
       CASE WHEN COALESCE(measurement_concept_id, 0) = 0
            THEN concat('src:', measurement_source_value)
            ELSE CAST(measurement_concept_id AS STRING)
       END AS test_id,
       COALESCE(NULLIF(unit_concept_id, 0), inferred_unit_concept_id) AS effective_unit_concept_id
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
WHERE value_as_number IS NOT NULL
  AND COALESCE(unit_inference_method, '') <> 'suspect_concept';

-- 14a. One row per (test, effective unit)
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_test_units AS
SELECT k.test_id,
       COALESCE(mc.concept_name, substr(k.test_id, 5)) AS test_name,
       k.unit_concept_id, u.concept_code AS unit_code, k.n
FROM (
  SELECT test_id, max(measurement_concept_id) AS measurement_concept_id,
         effective_unit_concept_id AS unit_concept_id, COUNT(*) AS n
  FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_keyed
  WHERE effective_unit_concept_id IS NOT NULL
  GROUP BY test_id, effective_unit_concept_id
) k
LEFT JOIN omop_vocab.concept mc ON mc.concept_id = NULLIF(k.measurement_concept_id, 0)
LEFT JOIN omop_vocab.concept u  ON u.concept_id = k.unit_concept_id;

-- 14b. Analyte per test
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_test_analytes AS
SELECT t.test_id, min_by(a.analyte, a.priority) AS analyte
FROM (SELECT DISTINCT test_id, test_name
      FROM hive_metastore.ehr_union_clean_metrics.unit_test_units) t
JOIN hive_metastore.ehr_union_clean_metrics.unit_analytes a
  ON t.test_name RLIKE a.pattern
GROUP BY t.test_id;


%sql
-- 14c. Review: analyte assignments, with each test's units.
--      Look for tests that got the wrong analyte.
SELECT a.analyte, t.test_name, SUM(t.n) AS n,
       array_join(collect_list(concat(t.unit_code, ' (', CAST(t.n AS STRING), ')')), ', ') AS units
FROM hive_metastore.ehr_union_clean_metrics.unit_test_analytes a
JOIN hive_metastore.ehr_union_clean_metrics.unit_test_units t ON t.test_id = a.test_id
GROUP BY a.analyte, t.test_id, t.test_name
ORDER BY a.analyte, n DESC;


%sql
-- ===== C3. Conversion decisions =====

-- 15. Decisions: one row per (test, effective unit)
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions AS
WITH cls AS (
  -- equivalent codes (same base, slope, intercept) count as one unit
  SELECT tu.test_id, tu.unit_concept_id, tu.n,
         CASE WHEN f.base IS NULL THEN concat('concept:', CAST(tu.unit_concept_id AS STRING))
              ELSE concat_ws(':', f.base, CAST(f.slope AS STRING), CAST(f.intercept AS STRING))
         END AS class_key
  FROM hive_metastore.ehr_union_clean_metrics.unit_test_units tu
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_factors f ON f.unit_code = tu.unit_code
),
cls_n AS (
  SELECT test_id, class_key, SUM(n) AS n, max_by(unit_concept_id, n) AS top_unit_concept_id
  FROM cls GROUP BY 1, 2
),
most_common AS (
  SELECT test_id, max_by(top_unit_concept_id, n) AS unit_concept_id
  FROM cls_n GROUP BY 1
),
canonical AS (
  SELECT m.test_id,
         COALESCE(ru.concept_id, m.unit_concept_id) AS canonical_unit_concept_id,
         CASE WHEN ru.concept_id IS NOT NULL THEN 'rule' ELSE 'most_common' END AS canonical_source
  FROM most_common m
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.canonical_unit_rules r ON r.test_id = m.test_id
  LEFT JOIN omop_vocab.concept ru
    ON  ru.vocabulary_id = 'UCUM'
    AND ru.concept_code = r.unit_code
    AND ru.invalid_reason IS NULL
),
pairs AS (
  SELECT tu.*, a.analyte,
         c.canonical_unit_concept_id, kc.concept_code AS canonical_unit_code, c.canonical_source,
         fu.base AS u_base, fu.slope AS u_slope, fu.intercept AS u_intercept,
         fk.base AS k_base, fk.slope AS k_slope, fk.intercept AS k_intercept,
         CASE WHEN fu.base = fk.base THEN 1D ELSE b.slope END     AS b_slope,
         CASE WHEN fu.base = fk.base THEN 0D ELSE b.intercept END AS b_intercept
  FROM hive_metastore.ehr_union_clean_metrics.unit_test_units tu
  JOIN canonical c ON c.test_id = tu.test_id
  LEFT JOIN omop_vocab.concept kc ON kc.concept_id = c.canonical_unit_concept_id
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_test_analytes a ON a.test_id = tu.test_id
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_factors fu ON fu.unit_code = tu.unit_code
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_factors fk ON fk.unit_code = kc.concept_code
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_analyte_bridges b
    ON  b.analyte = a.analyte
    AND b.from_base = fu.base
    AND b.to_base = fk.base
)
-- unit -> base -> (bridge) -> canonical:
--   canonical = (b_slope * (u_slope * x + u_intercept) + b_intercept - k_intercept) / k_slope
SELECT test_id, test_name, unit_concept_id, unit_code, n, analyte,
       canonical_unit_concept_id, canonical_unit_code, canonical_source,
       CASE WHEN unit_concept_id = canonical_unit_concept_id THEN 'identity'
            WHEN u_base = k_base                              THEN 'same_base'
            WHEN b_slope IS NOT NULL                          THEN 'analyte_bridge'
            ELSE 'no_conversion'
       END AS conversion_method,
       CASE WHEN unit_concept_id = canonical_unit_concept_id THEN 1D
            ELSE b_slope * u_slope / k_slope
       END AS conversion_slope,
       CASE WHEN unit_concept_id = canonical_unit_concept_id THEN 0D
            ELSE (b_slope * u_intercept + b_intercept - k_intercept) / k_slope
       END AS conversion_intercept
FROM pairs;


%sql
-- 15a. Review: summary
SELECT conversion_method, COUNT(*) AS n_pairs, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions
GROUP BY 1 ORDER BY n_records DESC;


%sql
-- 15b. Review: canonical unit for every test that has more than one unit.
--      Look for canonical units you'd not choose; add them to 13c.
SELECT test_name, canonical_unit_code, canonical_source, SUM(n) AS n,
       array_join(collect_list(concat(unit_code, ' ', CAST(n AS STRING), ' ', conversion_method)), '; ') AS units
FROM hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions
GROUP BY test_id, test_name, canonical_unit_code, canonical_source
HAVING COUNT(*) > 1
ORDER BY n DESC;


%sql
-- 15c. Review: (test, unit) pairs with no conversion to the canonical unit
SELECT test_name, unit_code, n, canonical_unit_code, analyte
FROM hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions
WHERE conversion_method = 'no_conversion'
ORDER BY n DESC;


%sql
-- 15d. Review: do converted values look like canonical-unit values?
--      Median converted value per unit vs median of records already in the
--      canonical unit. ratio far from 1 = wrong factor, wrong analyte, or
--      the source unit label is wrong. Most extreme first.
WITH v AS (
  SELECT d.test_id, d.test_name, d.unit_code, d.canonical_unit_code, d.conversion_method,
         k.value_as_number AS x,
         d.conversion_slope * k.value_as_number + d.conversion_intercept AS y
  FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_keyed k
  JOIN hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions d
    ON  d.test_id = k.test_id
    AND d.unit_concept_id = k.effective_unit_concept_id
  WHERE d.conversion_slope IS NOT NULL
),
per_unit AS (
  SELECT test_id, test_name, unit_code, canonical_unit_code, conversion_method,
         COUNT(*) AS n, percentile_approx(x, 0.5) AS median_raw,
         percentile_approx(y, 0.5) AS median_converted
  FROM v GROUP BY 1, 2, 3, 4, 5
),
canon AS (
  SELECT test_id, median_converted AS canonical_median
  FROM per_unit WHERE conversion_method = 'identity'
)
SELECT p.test_name, p.unit_code, p.canonical_unit_code, p.conversion_method, p.n,
       p.median_raw, p.median_converted, c.canonical_median,
       p.median_converted / NULLIF(c.canonical_median, 0) AS ratio
FROM per_unit p
JOIN canon c ON c.test_id = p.test_id
WHERE p.conversion_method <> 'identity'
ORDER BY greatest(abs(p.median_converted / NULLIF(c.canonical_median, 0)),
                  abs(c.canonical_median / NULLIF(p.median_converted, 0))) DESC NULLS FIRST;


%sql
-- ===== C4. Apply conversion decisions =====

-- 16. Apply. Rerunnable. Keys are the same as in the view (14).
MERGE INTO hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized t
USING hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions d
ON  d.test_id = CASE WHEN COALESCE(t.measurement_concept_id, 0) = 0
                     THEN concat('src:', t.measurement_source_value)
                     ELSE CAST(t.measurement_concept_id AS STRING)
                END
AND d.unit_concept_id = COALESCE(NULLIF(t.unit_concept_id, 0), t.inferred_unit_concept_id)
AND t.value_as_number IS NOT NULL
AND COALESCE(t.unit_inference_method, '') <> 'suspect_concept'
WHEN MATCHED THEN UPDATE SET
  t.canonical_unit_concept_id  = CASE WHEN d.conversion_slope IS NOT NULL
                                      THEN d.canonical_unit_concept_id END,
  t.harmonized_value_as_number = d.conversion_slope * t.value_as_number + d.conversion_intercept;


%sql
-- 16a. Review: numeric records by harmonization status
SELECT CASE WHEN canonical_unit_concept_id IS NOT NULL  THEN 'in canonical unit'
            WHEN harmonized_value_as_number IS NOT NULL THEN 'unitless'
            WHEN COALESCE(NULLIF(unit_concept_id, 0), inferred_unit_concept_id) IS NOT NULL
                                                        THEN 'has unit, no conversion'
            ELSE 'no unit'
       END AS status,
       COUNT(*) AS n
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
WHERE value_as_number IS NOT NULL
GROUP BY 1 ORDER BY n DESC;
