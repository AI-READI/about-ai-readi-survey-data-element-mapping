-- Databricks notebook source
-- ===== B1. Unit-string hand map. Last result: check, should be empty =====
-- PART B: records that HAVE a unit string but no unit concept.
-- Per string: hand map first, then reuse the concept the same string
-- already has elsewhere (exact, then case-insensitive), otherwise
-- unmapped_string. Only numeric records are touched.

-- 10. Hand map of unit strings. rule = 'unit' | 'unitless' | 'not_a_unit'.
--     unit_code is the UCUM code as OMOP spells it (checked in 10b).
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_string_map AS
SELECT * FROM VALUES
  -- eGFR spellings
  ('mL/min/1.73m²',      'unit', 'mL/min/(173.10*-2.m2)', 'eGFR'),
  ('mL/min/1.73 m2',     'unit', 'mL/min/(173.10*-2.m2)', 'eGFR'),
  ('mL/min/{1.73_m2}',   'unit', 'mL/min/(173.10*-2.m2)', 'eGFR'),
  ('mL/min/1.73_m2',     'unit', 'mL/min/(173.10*-2.m2)', 'eGFR'),
  ('mL/min/1.73m2',      'unit', 'mL/min/(173.10*-2.m2)', 'eGFR'),
  ('ml/min/1.73m2',      'unit', 'mL/min/(173.10*-2.m2)', 'eGFR'),
  ('mL/min/1.72m*2',     'unit', 'mL/min/(173.10*-2.m2)', 'eGFR, typo'),
  ('mL/min/1.73,2',      'unit', 'mL/min/(173.10*-2.m2)', 'eGFR, typo'),
  ('m/m/1.73',           'unit', 'mL/min/(173.10*-2.m2)', 'eGFR, abbreviated'),
  -- rates and times
  ('BPM',                'unit', '/min', 'beats per minute'),
  ('bpm',                'unit', '/min', 'beats per minute'),
  ('PBPM',               'unit', '/min', 'pulse beats per minute'),
  ('ms',                 'unit', 'ms', NULL),
  ('msec',               'unit', 'ms', NULL),
  ('min',                'unit', 'min', NULL),
  ('minutes',            'unit', 'min', NULL),
  ('Minutes',            'unit', 'min', NULL),
  ('hr',                 'unit', 'h', NULL),
  ('d',                  'unit', 'd', NULL),
  ('days',               'unit', 'd', NULL),
  ('weeks',              'unit', 'wk', NULL),
  ('mo',                 'unit', 'mo', NULL),
  ('yr',                 'unit', 'a', NULL),
  ('years',              'unit', 'a', NULL),
  ('a',                  'unit', 'a', 'UCUM year'),
  -- flows and volumes
  ('mL/hr',              'unit', 'mL/h', NULL),
  ('mL/min',             'unit', 'mL/min', NULL),
  ('L/min',              'unit', 'L/min', NULL),
  ('L/sec',              'unit', 'L/s', NULL),
  ('liter/min/m2',       'unit', 'L/min/m2', 'cardiac index'),
  ('ml/min/mmHg',        'unit', 'mL/min/mm[Hg]', 'DLCO'),
  ('L',                  'unit', 'L', NULL),
  ('mL/beat',            'unit', 'mL/{hb}', 'stroke volume'),
  ('mL/24 hr',           'unit', 'mL/(24.h)', NULL),
  ('liters/day',         'unit', 'L/(24.h)', NULL),
  -- lengths, masses, speeds
  ('cm',                 'unit', 'cm', NULL),
  ('mm',                 'unit', 'mm', NULL),
  ('ft',                 'unit', '[ft_i]', NULL),
  ('cm/sec',             'unit', 'cm/s', NULL),
  ('g',                  'unit', 'g', NULL),
  ('[lb_av]',            'unit', '[lb_us]', 'pound'),
  ('lbs',                'unit', '[lb_us]', 'pound'),
  -- temperature, pressure, electrical, radiation
  ('\'C',                'unit', 'Cel', 'degrees Celsius'),
  ('mm Hg',              'unit', 'mm[Hg]', NULL),
  ('cmH2O',              'unit', 'cm[H2O]', NULL),
  ('kPa',                'unit', 'kPa', NULL),
  ('V',                  'unit', 'V', NULL),
  ('mV',                 'unit', 'mV', NULL),
  ('mA',                 'unit', 'mA', NULL),
  ('Ohm',                'unit', 'Ohm', NULL),
  ('Ohms',               'unit', 'Ohm', NULL),
  ('cGray',              'unit', 'cGy', NULL),
  ('Gray',               'unit', 'Gy', NULL),
  ('Gy (RBE)',           'unit', 'Gy', 'RBE-weighted dose'),
  ('mCi',                'unit', 'mCi', NULL),
  ('ppm',                'unit', '[ppm]', NULL),
  -- concentrations
  ('nmol/L',             'unit', 'nmol/L', NULL),
  ('ug/L',               'unit', 'ug/L', NULL),
  ('ATP ng/mL',          'unit', 'ng/mL', NULL),
  ('ng/mL RBC',          'unit', 'ng/mL', NULL),
  ('mg/dL:',             'unit', 'mg/dL', 'trailing colon'),
  ('mWq/L',              'unit', '10*-3.eq/L', 'typo for mEq/L'),
  ('mosm/kg',            'unit', 'mosm/kg', NULL),
  ('mOsm/kg',            'unit', 'mosm/kg', NULL),
  ('mOsmol/kg',          'unit', 'mosm/kg', NULL),
  ('mOsm/K',             'unit', 'mosm/kg', NULL),
  ('mcg/g',              'unit', 'ug/g', NULL),
  ('mcg/mg',             'unit', 'ug/mg', NULL),
  ('mg/kg',              'unit', 'mg/kg', NULL),
  ('mg/mg',              'unit', 'mg/mg', NULL),
  ('umol/mol',           'unit', 'umol/mol', NULL),
  ('nmol/mmol',          'unit', 'nmol/mmol', NULL),
  ('nmol',               'unit', 'nmol', NULL),
  ('ng/mL/hr',           'unit', 'ng/mL/h', 'renin activity'),
  ('ug{FEU}/mL',         'unit', 'ug{FEU}/mL', 'D-dimer'),
  ('mcg/mL FEU',         'unit', 'ug{FEU}/mL', 'D-dimer'),
  -- per creatinine
  ('mg/g{creat}',        'unit', 'mg/g{creat}', NULL),
  ('mg/g Creat',         'unit', 'mg/g{creat}', NULL),
  ('mg/g creat',         'unit', 'mg/g{creat}', NULL),
  ('ug/g creat',         'unit', 'ug/g{creat}', NULL),
  ('nmol{BCE}/mmol{creat}', 'unit', 'nmol{BColl}eq/mmol{creat}', NULL),
  ('nM BCE/mM Creat',    'unit', 'nmol{BColl}eq/mmol{creat}', NULL),
  -- per 24 hours
  ('mg/d',               'unit', 'mg/(24.h)', NULL),
  ('mg/24 hr',           'unit', 'mg/(24.h)', NULL),
  ('mg/24hr',            'unit', 'mg/(24.h)', NULL),
  ('ug/(24.h)',          'unit', 'ug/(24.h)', NULL),
  ('ug/24 hr',           'unit', 'ug/(24.h)', NULL),
  ('mcg/24 h',           'unit', 'ug/(24.h)', NULL),
  ('mmol/24 hr',         'unit', 'mmol/(24.h)', NULL),
  ('mmol/(24.h)',        'unit', 'mmol/(24.h)', NULL),
  ('meq/24 hr',          'unit', '10*-3.eq/(24.h)', NULL),
  ('meq/(24.h)',         'unit', '10*-3.eq/(24.h)', NULL),
  ('meq/day',            'unit', '10*-3.eq/(24.h)', NULL),
  ('g/24 hr',            'unit', 'g/(24.h)', NULL),
  ('g/24hr',             'unit', 'g/(24.h)', NULL),
  -- counts
  ('10*9/L',             'unit', '10*9/L', NULL),
  ('bil/L',              'unit', '10*9/L', NULL),
  ('X 10E3/mm3',         'unit', '10*3/uL', NULL),
  ('M/mcl',              'unit', '10*6/uL', NULL),
  ('Leu/uL',             'unit', '/uL', 'urine leukocytes'),
  ('cell/uL',            'unit', '/uL', NULL),
  ('{cells}',            'unit', '{cells}', NULL),
  ('10*6/mL',            'unit', '10*6/mL', NULL),
  ('million/mL',         'unit', '10*6/mL', NULL),
  ('mil sperm/mL',       'unit', '10*6/mL', NULL),
  ('Copies/mL',          'unit', '{copies}/mL', NULL),
  ('cp/mL',              'unit', '{copies}/mL', NULL),
  -- percentages
  ('%PCV',               'unit', '%', 'hematocrit'),
  ('VOL%',               'unit', '%', NULL),
  ('% of CD19',          'unit', '%', NULL),
  ('% Lymphs',           'unit', '%', NULL),
  ('% fat',              'unit', '%', NULL),
  ('% donor',            'unit', '%', NULL),
  ('% normal',           'unit', '%', NULL),
  ('% Inhibition',       'unit', '%', NULL),
  ('%Hb',                'unit', '%', NULL),
  -- international and arbitrary units
  ('k[IU]/L',            'unit', '10*3.[iU]/L', NULL),
  ('mIU/mL',             'unit', '10*-3.[iU]/mL', NULL),
  ('uU/mL',              'unit', '10*-6.[iU]/mL', 'insulin'),
  ('IU gamma IF/mL',     'unit', '[iU]/mL', 'QuantiFERON'),
  ('[IU]',               'unit', '[iU]', NULL),
  ('IU',                 'unit', '[iU]', NULL),
  ('UI/L',               'unit', '[iU]/L', NULL),
  ('UI/mL',              'unit', '[iU]/mL', NULL),
  ('U',                  'unit', '[U]', NULL),
  ('U/g{Hb}',            'unit', '[U]/g{HGB}', NULL),
  ('U/g Hgb',            'unit', '[U]/g{HGB}', NULL),
  ('AU/mL',              'unit', '[arb\'U]/mL', NULL),
  ('GPL U/mL',           'unit', '[GPL\'U]/mL', NULL),
  ('MPL U/mL',           'unit', '[MPL\'U]/mL', NULL),
  ('APL U/mL',           'unit', '[APL\'U]/mL', NULL),
  ('E.U./dL',            'unit', '[EU]/dL', 'urobilinogen'),
  ('EU/dL (mg/dL)',      'unit', '[EU]/dL', 'urobilinogen'),
  ('{Ehrlich\'U}',       'unit', '[EU]/dL', 'urobilinogen'),
  ('EHRLICH UNITS',      'unit', '[EU]/dL', 'urobilinogen'),
  -- unitless
  ('{ratio}',            'unitless', NULL, NULL),
  ('A/G Ratio',          'unitless', NULL, NULL),
  ('Index',              'unitless', NULL, NULL),
  ('{index_val}',        'unitless', NULL, NULL),
  ('TSI Index',          'unitless', NULL, NULL),
  ('ISR',                'unitless', NULL, 'index of serum reactivity'),
  ('S/CO',               'unitless', NULL, 'signal to cutoff'),
  ('OD',                 'unitless', NULL, 'optical density'),
  ('ACTIVITY COEFF',     'unitless', NULL, NULL),
  -- not a unit
  ('Urine',              'not_a_unit', NULL, NULL),
  ('Possible',           'not_a_unit', NULL, NULL),
  ('**Please',           'not_a_unit', NULL, NULL),
  ('*Not Applicable',    'not_a_unit', NULL, NULL),
  ('No',                 'not_a_unit', NULL, NULL),
  ('Normal',             'not_a_unit', NULL, NULL),
  ('Performed',          'not_a_unit', NULL, NULL),
  ('Corrected',          'not_a_unit', NULL, NULL),
  ('calc',               'not_a_unit', NULL, NULL),
  ('Dose',               'not_a_unit', NULL, NULL),
  ('PharmD',             'not_a_unit', NULL, NULL),
  ('PHARMD',             'not_a_unit', NULL, NULL),
  ('MD',                 'not_a_unit', NULL, NULL),
  ('Dr',                 'not_a_unit', NULL, NULL),
  ('TAC',                'not_a_unit', NULL, NULL),
  ('Bands',              'not_a_unit', NULL, NULL),
  ('bands',              'not_a_unit', NULL, NULL),
  ('30.0-100.0',         'not_a_unit', NULL, 'a reference range in the unit field')
AS t(unit_source_value, rule, unit_code, note);

-- 10b. Check: hand-map codes that don't resolve to a UCUM concept.
--      Paste any rows this returns; I'll correct the codes.
SELECT m.*
FROM hive_metastore.ehr_union_clean_metrics.unit_string_map m
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = m.unit_code
  AND ru.invalid_reason IS NULL
WHERE m.rule = 'unit' AND ru.concept_id IS NULL;

-- COMMAND ----------

-- ===== B2. Unit-string decisions. Last result: summary =====

-- 11. Decisions: one row per unit string that lacks a unit concept
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_string_decisions AS
WITH need AS (
  SELECT unit_source_value, measurement_concept_id, COUNT(*) AS n
  FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
  WHERE value_as_number IS NOT NULL
    AND unit_source_value IS NOT NULL
    AND COALESCE(unit_concept_id, 0) = 0
  GROUP BY 1, 2
),
s AS (
  SELECT unit_source_value, SUM(n) AS n,
         max_by(measurement_concept_id, n) AS top_concept_id
  FROM need GROUP BY 1
),
have AS (
  SELECT unit_source_value, unit_concept_id, COUNT(*) AS n
  FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
  WHERE unit_source_value IS NOT NULL AND COALESCE(unit_concept_id, 0) <> 0
  GROUP BY 1, 2
),
reuse_exact AS (
  SELECT unit_source_value, max_by(unit_concept_id, n) AS unit_concept_id
  FROM have GROUP BY 1
),
reuse_ci AS (
  SELECT lower(trim(unit_source_value)) AS k, max_by(unit_concept_id, n) AS unit_concept_id
  FROM have GROUP BY 1
)
SELECT s.unit_source_value, s.n,
       tc.concept_name AS top_measurement_concept,
       CASE
         WHEN m.rule = 'unit'       THEN 'mapped_string'
         WHEN m.rule IS NOT NULL    THEN m.rule
         WHEN COALESCE(re.unit_concept_id, rc.unit_concept_id) IS NOT NULL THEN 'reused_mapping'
         ELSE 'unmapped_string'
       END AS unit_inference_method,
       CASE
         WHEN m.rule = 'unit'    THEN mu.concept_id
         WHEN m.rule IS NOT NULL THEN NULL
         ELSE COALESCE(re.unit_concept_id, rc.unit_concept_id)
       END AS inferred_unit_concept_id,
       m.note
FROM s
LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_string_map m
  ON m.unit_source_value = s.unit_source_value
LEFT JOIN omop_vocab.concept mu
  ON  mu.vocabulary_id = 'UCUM'
  AND mu.concept_code = m.unit_code
  AND mu.invalid_reason IS NULL
LEFT JOIN reuse_exact re ON re.unit_source_value = s.unit_source_value
LEFT JOIN reuse_ci rc    ON rc.k = lower(trim(s.unit_source_value))
LEFT JOIN omop_vocab.concept tc ON tc.concept_id = s.top_concept_id;

-- 11b. Review: summary
SELECT unit_inference_method, COUNT(*) AS n_strings, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_string_decisions
GROUP BY 1 ORDER BY n_records DESC;

-- COMMAND ----------

-- ===== B3. Review: every string =====

-- 11c. Review: every string, with the unit it got and the test it's mostly on
SELECT d.unit_inference_method, d.unit_source_value, d.n,
       u.concept_code AS inferred_unit, d.top_measurement_concept, d.note
FROM hive_metastore.ehr_union_clean_metrics.unit_string_decisions d
LEFT JOIN omop_vocab.concept u ON u.concept_id = d.inferred_unit_concept_id
ORDER BY d.unit_inference_method, d.n DESC;

-- COMMAND ----------

-- ===== B4. Apply Part B decisions =====

-- 12. Apply. Rerunnable.
MERGE INTO hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized t
USING (
  SELECT d.*, u.concept_code AS unit_code
  FROM hive_metastore.ehr_union_clean_metrics.unit_string_decisions d
  LEFT JOIN omop_vocab.concept u ON u.concept_id = d.inferred_unit_concept_id
) d
ON  t.unit_source_value = d.unit_source_value
AND t.value_as_number IS NOT NULL
AND COALESCE(t.unit_concept_id, 0) = 0
WHEN MATCHED THEN UPDATE SET
  t.unit_inference_method      = d.unit_inference_method,
  t.inferred_unit_concept_id   = d.inferred_unit_concept_id,
  t.inferred_unit_source_value = d.unit_code,
  t.harmonized_value_as_number = CASE WHEN d.unit_inference_method = 'unitless'
                                      THEN t.value_as_number END;
