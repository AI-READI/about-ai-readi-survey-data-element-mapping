-- Databricks notebook source
-- Unit inference, Part E: review the outputs of a full A-D run.
--
-- Read-only: every cell is a SELECT. Run after A, B, C and D, top to bottom,
-- and paste back every cell's result. Each cell repeats a check or review
-- query from A-D (named in its comment, which also says what to expect);
-- the queries stay in A-D too, so a change there has to be copied here.
-- Cells E1 and E2 are the only queries that aren't in A-D.
--
-- Checks (should be empty): 4b, 7b, 10b, 14a, 14d, 17e, E2.


-- COMMAND ----------

-- 4b (Part A, cell A2). Check: explicit concept rules whose UCUM code
--     didn't resolve to a concept.
--     Expect: no rows.
SELECT r.*
FROM hive_metastore.ehr_union_clean_metrics.unit_concept_rules r
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
WHERE r.rule = 'explicit' AND ru.concept_id IS NULL;

-- COMMAND ----------

-- 5a (Part A, cell A3). Review: Part A concept-level decisions by method.
--     Expect: n_records totals 205,838; suspect_concept 88. no_concept rows
--     are the concept-0 groups that 8b decides.
SELECT unit_inference_method, COUNT(*) AS n_groups, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_inference_range_decisions
GROUP BY 1
ORDER BY n_records DESC;

-- COMMAND ----------

-- 7b (Part A, cell A6). Check: source-name rule codes that don't resolve
--     to a UCUM concept.
--     Expect: no rows.
SELECT r.*
FROM hive_metastore.ehr_union_clean_metrics.unit_source_name_rules r
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
WHERE r.unit_code IS NOT NULL AND ru.concept_id IS NULL;

-- COMMAND ----------

-- 8b (Part A, cell A7). Review: no-concept decisions, every group.
--     Expect: almost all source_name or unitless; Part A's needs_review and
--     no_concept together come to 6 records (5a plus this).
SELECT * FROM hive_metastore.ehr_union_clean_metrics.unit_inference_source_name_decisions
ORDER BY unit_inference_method, n DESC;

-- COMMAND ----------

-- 10b (Part B, cell B1). Check: unit-string map codes that don't resolve
--      to a UCUM concept.
--      Expect: no rows.
SELECT m.*
FROM hive_metastore.ehr_union_clean_metrics.unit_string_map m
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = m.unit_code
  AND ru.invalid_reason IS NULL
WHERE m.rule = 'unit' AND ru.concept_id IS NULL;

-- COMMAND ----------

-- 11b (Part B, cell B2). Review: unit-string decisions by method.
--      Expect: 223 strings, 55,429 records; unmapped_string 58 strings
--      (5,988 records), not_a_unit 18 (275).
SELECT unit_inference_method, COUNT(*) AS n_strings, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_string_decisions
GROUP BY 1 ORDER BY n_records DESC;

-- COMMAND ----------

-- 14a (Part C, cell C1). Check: explicit name rules without a valid UCUM
--      code, and non-explicit rules with one.
--      Expect: no rows.
SELECT r.*
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_rules r
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
WHERE (r.rule = 'explicit') <> (ru.concept_id IS NOT NULL);

-- COMMAND ----------

-- 14d (Part C). Check: value bands with bad codes, gaps, overlaps, open ends.
--      Expect: no rows.
WITH v AS (
  SELECT v.*, ru.concept_id AS ucum_concept_id,
         lag(v.value_max) OVER (PARTITION BY v.test_pattern ORDER BY v.value_min NULLS FIRST) AS prev_max,
         ROW_NUMBER() OVER (PARTITION BY v.test_pattern ORDER BY v.value_min NULLS FIRST) AS rn,
         COUNT(*) OVER (PARTITION BY v.test_pattern) AS n_bands
  FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_value_rules v
  LEFT JOIN omop_vocab.concept ru
    ON  ru.vocabulary_id = 'UCUM'
    AND ru.concept_code = v.unit_code
    AND ru.invalid_reason IS NULL
)
SELECT * FROM (
  SELECT CASE WHEN v.unit_code IS NOT NULL AND v.ucum_concept_id IS NULL THEN 'not a UCUM code'
              WHEN (v.method = 'value_split') <> (v.unit_code IS NOT NULL)
                OR v.method NOT IN ('value_split', 'unitless', 'reciprocal', 'needs_review', 'suspect_concept')
                                                                         THEN 'method and unit_code disagree'
              WHEN v.rn = 1 AND v.value_min IS NOT NULL                  THEN 'first band has a lower bound'
              WHEN v.rn = v.n_bands AND v.value_max IS NOT NULL          THEN 'last band has an upper bound'
              WHEN v.rn > 1 AND NOT (v.value_min <=> v.prev_max)         THEN 'gap or overlap with previous band'
              WHEN v.value_min >= v.value_max                            THEN 'empty band'
         END AS problem,
         v.*
  FROM v
) WHERE problem IS NOT NULL;

-- COMMAND ----------

-- 15a (Part C). Review: Part C decisions by method, per (partner, test),
--      before 16 splits value_split groups into bands.
--      Expect: explicit 510,927; needs_review 661; value_split 7,047;
--      total 1,066,417. E1 has the per-record counts after the split.
SELECT unit_inference_method, COUNT(*) AS n_groups, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions
GROUP BY 1
ORDER BY n_records DESC;

-- COMMAND ----------

-- 15c (Part C). Review: needs_review, one row per test across partners.
--      Expect: log viral loads, Treadmill MPH (28), Creatinine/Protein [Mass
--      Ratio] in Urine (94), Physical findings of Skin (69),
--      Aldosterone/Renin ratio (33), plus one-offs. Band-level needs_review
--      (15d) isn't here.
SELECT test_name, test_id, SUM(n) AS n, COUNT(*) AS n_partners,
       min(p05) AS min_p05, percentile_approx(med, 0.5) AS med_of_medians, max(p95) AS max_p95,
       round(sum(frac_integer * n) / SUM(n), 2) AS frac_integer,
       max(evidence_units) AS evidence_units
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions
WHERE unit_inference_method = 'needs_review'
GROUP BY test_name, test_id
ORDER BY n DESC;

-- COMMAND ----------

-- 15d (Part C). Review: value_split records by band, as 16 assigns them.
--      Expect: seven rows, no NULL band. HDL/total reciprocal 6,482 records;
--      RV/TLC under 8 suspect_concept 225.
SELECT r.data_partner_id, d.test_name, v.value_min, v.value_max, v.unit_code, v.method,
       COUNT(*) AS n, min(r.value_as_number) AS min_value,
       percentile_approx(r.value_as_number, 0.5) AS median, max(r.value_as_number) AS max_value
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_records r
JOIN hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions d
  ON  d.data_partner_id = r.data_partner_id
  AND d.test_id = r.test_id
  AND d.unit_inference_method = 'value_split'
LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_no_range_value_rules v
  ON  d.test_name RLIKE v.test_pattern
  AND (v.value_min IS NULL OR r.value_as_number >= v.value_min)
  AND (v.value_max IS NULL OR r.value_as_number <  v.value_max)
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY 1, 2, 3 NULLS FIRST;

-- COMMAND ----------

-- 17e (Part D). Check: bad or duplicate unit codes, duplicate bridges.
--      Expect: no rows.
WITH codes AS (
  SELECT 'unit_factors' AS src, unit_code FROM hive_metastore.ehr_union_clean_metrics.unit_factors
  UNION ALL
  SELECT 'canonical_unit_rules', unit_code FROM hive_metastore.ehr_union_clean_metrics.canonical_unit_rules
  UNION ALL
  SELECT 'unit_relabel_rules', treat_as_code FROM hive_metastore.ehr_union_clean_metrics.unit_relabel_rules
  WHERE treat_as_code IS NOT NULL
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
SELECT 'duplicate bridge', concat_ws(' ', analyte, from_base, to_base)
FROM hive_metastore.ehr_union_clean_metrics.unit_analyte_bridges
GROUP BY analyte, from_base, to_base HAVING COUNT(*) > 1;

-- COMMAND ----------

-- 18d (Part D). Review: tests each canonical-unit rule hits.
--      Expect: n_rules_for_test 1 on every row, each test under the rule
--      meant for it (Body weight kg, Body height cm, Body temperature Cel,
--      HbA1c %, 24 h urine protein mg/(24.h)).
SELECT r.test_pattern, r.unit_code, t.test_name, SUM(t.n) AS n,
       COUNT(*) OVER (PARTITION BY t.test_id) AS n_rules_for_test
FROM hive_metastore.ehr_union_clean_metrics.canonical_unit_rules r
LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_test_units t
  ON t.test_name RLIKE r.test_pattern
GROUP BY r.test_pattern, r.unit_code, t.test_id, t.test_name
ORDER BY r.test_pattern, n DESC;

-- COMMAND ----------

-- 19a (Part D). Review: conversion decisions by method.
--      Expect: identity and same_base hold nearly all records;
--      no_conversion 3,185 plus blocked 4 = 20a's "has unit, no conversion".
SELECT conversion_method, COUNT(*) AS n_groups, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_conversion_decisions
GROUP BY 1 ORDER BY n_records DESC;

-- COMMAND ----------

-- 19d (Part D). Review: (partner, test, unit) with no conversion to the
--      canonical unit.
--      Expect: log viral loads, Lp(a), arbitrary antibody units, and tests
--      holding two different quantities. Nothing a factor would fix.
SELECT test_name, data_partner_id, unit_code, n, median_raw, canonical_unit_code, canonical_median, analyte
FROM hive_metastore.ehr_union_clean_metrics.unit_conversion_medians
WHERE conversion_method = 'no_conversion'
ORDER BY n DESC;

-- COMMAND ----------

-- 19e (Part D). Review: converted medians against canonical-unit medians.
--      Expect: ratios near 1 apart from small groups. Body weight, partner
--      2084, [lb_us] relabeled as [oz_av], median_converted about 80.7 (kg).
SELECT test_name, data_partner_id, unit_code, relabeled_as, canonical_unit_code, conversion_method, n,
       median_raw, median_converted, canonical_median, ratio
FROM hive_metastore.ehr_union_clean_metrics.unit_conversion_medians
WHERE conversion_method <> 'no_conversion' AND canonical_median IS NOT NULL
ORDER BY greatest(abs(ratio), abs(try_divide(1, ratio))) DESC NULLS FIRST;

-- COMMAND ----------

-- 20a (Part D). Review: numeric records by harmonization status.
--      Expect: in canonical unit 6,529,079; unitless 509,251; has unit, no
--      conversion 3,189; no unit 11,037 (E1's no-unit methods).
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

-- COMMAND ----------

-- E1 (new, not in A-D). Review: numeric records by part and method, read
--    from the target table after every apply. Parts are told apart by raw
--    columns, as each part picks its records.
--    Expect:
--      has unit concept: method NULL only
--      A: total 205,838; the unit methods (dataset_unit, partner_unit,
--         range_match, explicit, source_name) 172,788; unitless 32,956;
--         suspect_concept 88; needs_review plus no_concept 6
--      B: total 55,429; mapped_string 49,073; unmapped_string 5,988;
--         not_a_unit 275; unitless 77; reused_mapping 16
--      C: total 1,066,417; explicit 510,927; unitless plus reciprocal
--         476,218 (reciprocal 6,482); partner_unit plus dataset_unit 73,887;
--         source_name 365; not_a_quantity 3,794; suspect_concept 225;
--         needs_review 661; value_split 340
SELECT CASE WHEN COALESCE(unit_concept_id, 0) <> 0 THEN 'has unit concept'
            WHEN unit_source_value IS NOT NULL      THEN 'B'
            WHEN range_high IS NOT NULL             THEN 'A'
            ELSE 'C'
       END AS part,
       unit_inference_method,
       COUNT(*) AS n
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
WHERE value_as_number IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, n DESC;

-- COMMAND ----------

-- E2 (new, not in A-D). Check: records with a canonical unit but no
--    harmonized value. Part D sets the two together, and every apply clears
--    the canonical unit, so this catches stale values from an earlier run.
--    Expect: no rows.
SELECT unit_inference_method, COUNT(*) AS n
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
WHERE canonical_unit_concept_id IS NOT NULL
  AND harmonized_value_as_number IS NULL
GROUP BY 1;

-- COMMAND ----------

-- 20b (Part D). Review: stored body weights by test, partner and unit.
--      Expect: kg_pct medians all near 80-90. Partner 2084 [lb_us]: raw
--      median about 2,847, kg median about 80.7 (was 1,291 before the
--      partner relabel).
SELECT COALESCE(mc.concept_name, k.measurement_source_value) AS test_name,
       k.data_partner_id, u.concept_code AS unit, k.unit_source_value,
       k.unit_inference_method, COUNT(*) AS n,
       percentile_approx(k.value_as_number, array(0.05, 0.5, 0.95)) AS raw_pct,
       percentile_approx(k.harmonized_value_as_number, array(0.05, 0.5, 0.95)) AS kg_pct
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_keyed k
LEFT JOIN omop_vocab.concept mc ON mc.concept_id = NULLIF(k.measurement_concept_id, 0)
LEFT JOIN omop_vocab.concept u  ON u.concept_id = k.effective_unit_concept_id
WHERE COALESCE(mc.concept_name, k.measurement_source_value) RLIKE '(?i)^body weight'
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, n DESC;

-- COMMAND ----------

-- 20c (Part D). Review: people with "Body weight" records in both kg and
--      [lb_us]; ratio = median converted lb record / median kg record.
--      Expect: ratio_pct median near 1 for partner 8469, and for 2084 too
--      if it has people with both (its lb records are now ounces).
WITH w AS (
  SELECT k.person_id, k.data_partner_id, u.concept_code AS unit,
         percentile_approx(k.harmonized_value_as_number, 0.5) AS kg
  FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_keyed k
  JOIN omop_vocab.concept mc ON mc.concept_id = k.measurement_concept_id
  JOIN omop_vocab.concept u  ON u.concept_id = k.effective_unit_concept_id
  WHERE mc.concept_name = 'Body weight'
    AND u.concept_code IN ('kg', '[lb_us]')
  GROUP BY 1, 2, 3
)
SELECT lb.data_partner_id AS lb_partner, kg.data_partner_id AS kg_partner,
       COUNT(*) AS n_people,
       percentile_approx(lb.kg / kg.kg, array(0.05, 0.25, 0.5, 0.75, 0.95)) AS ratio_pct
FROM w lb
JOIN w kg ON kg.person_id = lb.person_id AND kg.unit = 'kg'
WHERE lb.unit = '[lb_us]'
GROUP BY 1, 2;
