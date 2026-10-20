-- Databricks notebook source
-- Unit inference for measurement_unit_harmonized
--
-- Import with File > Import; each COMMAND block becomes a cell. A cell with
-- several statements runs them in order; Databricks shows the result of the
-- LAST statement, which is the one to look at.
--
-- Run order: A, B, C, D (files A_ to D_).
-- PART A: numeric records with NO unit but a reference range.
-- PART B: records with a unit STRING but no unit concept.
-- PART C: numeric records with no unit and no reference range.
-- PART D: conversion to a canonical unit per test.
--
-- unit_inference_method values written:
--   Part A: dataset_unit, partner_unit, range_match, explicit, source_name,
--           unitless, suspect_concept, needs_review, no_concept
--   Part B: mapped_string, reused_mapping, unitless, not_a_unit, unmapped_string
--
-- canonical_unit_concept_id and harmonized_value_as_number are filled in
-- Part D; only unitless records get harmonized_value_as_number here. Every
-- apply (A, B, C) clears canonical_unit_concept_id on the records it writes,
-- so a rerun of any part needs a rerun of Part D after it.
--
-- Things learned the hard way:
--   * OMOP UCUM codes write international units as [iU] (lowercase i), and
--     prefixes as powers of ten: 10*-6.[iU]/mL = uIU/mL, 10*-3.eq/L = mEq/L.
--   * In Spark SQL an apostrophe inside a string is written \' (backslash);
--     '' silently joins two strings instead.


-- COMMAND ----------

-- ===== A1. Add the method column (run once; an error means it already exists) =====

-- 1. Add the method column (run once; errors harmlessly if it already exists)
ALTER TABLE hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
  ADD COLUMNS (unit_inference_method STRING);

-- COMMAND ----------

-- ===== A2. Rules, working views and decisions. Last result: check, should be empty =====

-- 2. Hand rules by concept.
--    unitless        : no unit expected (pH, specific gravity, INR, ratios, indexes, scores)
--    suspect_concept : values don't fit the concept; looks like a concept-mapping error
--    explicit        : unit decided by hand, given as a UCUM code and looked up in cell 4
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_concept_rules AS
SELECT * FROM VALUES
  -- pH
  (3022621,  'unitless', CAST(NULL AS STRING), 'pH of Urine by Test strip'),
  (3029305,  'unitless', NULL, 'pH of Urine by Automated test strip'),
  (3015736,  'unitless', NULL, 'pH of Urine'),
  (3015501,  'unitless', NULL, 'pH of 24 hour Urine'),
  (3019977,  'unitless', NULL, 'pH of Arterial blood'),
  (3029473,  'unitless', NULL, 'pH of Arterial blood, temp adjusted'),
  (3012544,  'unitless', NULL, 'pH of Venous blood'),
  (3038999,  'unitless', NULL, 'pH of Venous blood, temp adjusted'),
  (3030091,  'unitless', NULL, 'pH of Blood, temp adjusted'),
  (3032186,  'unitless', NULL, 'pH of Venous cord blood, temp adjusted'),
  (3030109,  'unitless', NULL, 'pH of Arterial cord blood, temp adjusted'),
  (3018672,  'unitless', NULL, 'pH of Body fluid'),
  -- specific gravity (3058 labels some as g/mL; SG is dimensionless)
  (3029991,  'unitless', NULL, 'Specific gravity of Urine by Refractometry automated'),
  (3033543,  'unitless', NULL, 'Specific gravity of Urine'),
  (3000330,  'unitless', NULL, 'Specific gravity of Urine by Test strip'),
  (3039919,  'unitless', NULL, 'Specific gravity of Urine by Automated test strip'),
  (3019150,  'unitless', NULL, 'Specific gravity of Urine by Refractometry'),
  -- INR
  (3022217,  'unitless', NULL, 'INR in Platelet poor plasma'),
  (3051593,  'unitless', NULL, 'INR in Capillary blood'),
  (3032080,  'unitless', NULL, 'INR in Blood'),
  -- ratios
  (3018311,  'unitless', NULL, 'BUN/Creatinine ratio'),
  (3020509,  'unitless', NULL, 'Albumin/Globulin ratio'),
  (3053209,  'unitless', NULL, 'Kappa/Lambda free light chain ratio'),
  (40757349, 'unitless', NULL, 'CD4/CD8 ratio'),
  (3021492,  'unitless', NULL, 'IgG/Albumin ratio'),
  -- indexes and scores
  (3032612,  'unitless', NULL, 'Calcium oxalate index, 24h urine'),
  (3031809,  'unitless', NULL, 'Calcium hydrogen phosphate saturation fraction'),
  (3000551,  'unitless', NULL, 'T4 free index'),
  (21492175, 'unitless', NULL, 'AlloMap score'),
  -- suspect concept mappings
  (3037816,  'suspect_concept', NULL, 'CD4+CD8+ cells/cells: range 0.8-4.2 and values look like a CD4/CD8 ratio'),
  (3046867,  'suspect_concept', NULL, 'Alpha 1 antitrypsin phenotype [Interpretation]: holds the same value and range as an IgA result'),
  (3023884,  'suspect_concept', NULL, 'HDL/Total cholesterol ratio: values 2.6-9.2 are Total/HDL (HDL/Total cannot exceed 1)'),
  (3016991,  'suspect_concept', NULL, 'Thyroxine (T4) total: ranges 0.82-1.77 and values ~1 are free T4 in ng/dL'),
  -- explicit units
  (3045462,  'explicit', 'mg/mg{creat}', 'Protein/Creatinine [Ratio]: range_high 0.2 implies mg/mg'),
  (3034485,  'explicit', 'mg/g{creat}',  'Albumin/Creatinine: median 22.8, 95th pct 1660 fit mg/g; in mg/mmol the 95th would be implausible'),
  (3034426,  'explicit', 's',            'Prothrombin time: range 9.2-12.1 is seconds'),
  (3000034,  'explicit', 'mg/L',         'Microalbumin [Mass/volume] in Urine: range 5-20 fits mg/L'),
  (3043722,  'explicit', '/[LPF]',       'Hyaline casts [#/area]: per low power field')
AS t(measurement_concept_id, rule, unit_code, note);

-- 3a. Numeric source records
CREATE OR REPLACE TEMP VIEW src AS
SELECT data_partner_id, measurement_concept_id, range_low, range_high,
       unit_concept_id, unit_source_value, value_as_number
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
WHERE value_as_number IS NOT NULL;

-- 3b. Unlabeled groups: no unit at all, but a reference range
CREATE OR REPLACE TEMP VIEW unl AS
SELECT data_partner_id, measurement_concept_id, range_low, range_high,
       COUNT(*) AS n,
       percentile_approx(value_as_number, 0.5) AS med
FROM src
WHERE range_high IS NOT NULL
  AND unit_source_value IS NULL
  AND COALESCE(unit_concept_id, 0) = 0
GROUP BY 1, 2, 3, 4;

-- 3c. Labeled records for the same concepts. Only records with a real
--     unit_concept_id count as evidence; junk strings like 'Possible' or
--     '**Please' with no concept are ignored.
CREATE OR REPLACE TEMP VIEW lab AS
SELECT s.*
FROM src s
WHERE COALESCE(s.unit_concept_id, 0) <> 0
  AND s.measurement_concept_id IN (
        SELECT measurement_concept_id FROM unl WHERE measurement_concept_id <> 0);

-- 3d. Candidate units at three levels of evidence:
--     1 = same partner, same concept, same reference range
--     2 = same partner, same concept
--     3 = same concept, any partner
CREATE OR REPLACE TEMP VIEW cand AS
SELECT 1 AS lvl, data_partner_id, measurement_concept_id, range_low, range_high,
       unit_concept_id, COUNT(*) AS n_lab,
       percentile_approx(value_as_number, 0.5) AS med_lab
FROM lab
GROUP BY data_partner_id, measurement_concept_id, range_low, range_high, unit_concept_id
UNION ALL
SELECT 2, data_partner_id, measurement_concept_id, NULL, NULL,
       unit_concept_id, COUNT(*), percentile_approx(value_as_number, 0.5)
FROM lab
GROUP BY data_partner_id, measurement_concept_id, unit_concept_id
UNION ALL
SELECT 3, NULL, measurement_concept_id, NULL, NULL,
       unit_concept_id, COUNT(*), percentile_approx(value_as_number, 0.5)
FROM lab
GROUP BY measurement_concept_id, unit_concept_id;

-- 3e. Pick the best candidate per unlabeled group: strongest evidence level
--     first, then most records. An exact reference-range match (level 1) is
--     trusted as is. Weaker candidates only count if the unlabeled group's
--     median is within a factor of 2 of the candidate's median; that check is
--     what keeps body temperature from being called Celsius when values are ~98.
--     (Applying it at level 1 too rejected small groups of abnormal results,
--     e.g. a BUN of 44 against a typical 17.)
CREATE OR REPLACE TEMP VIEW pick AS
SELECT u.data_partner_id, u.measurement_concept_id, u.range_low, u.range_high,
       c.lvl, c.unit_concept_id, c.n_lab, c.med_lab,
       ROW_NUMBER() OVER (
         PARTITION BY u.data_partner_id, u.measurement_concept_id, u.range_low, u.range_high
         ORDER BY c.lvl, c.n_lab DESC, c.unit_concept_id) AS rk
FROM unl u
JOIN cand c
  ON  c.measurement_concept_id = u.measurement_concept_id
  AND (c.lvl = 3 OR c.data_partner_id = u.data_partner_id)
  AND (c.lvl > 1 OR (c.range_high = u.range_high AND c.range_low <=> u.range_low))
WHERE c.lvl = 1
   OR (u.med = 0 AND c.med_lab = 0)
   OR (c.med_lab > 0 AND u.med / c.med_lab BETWEEN 0.5 AND 2);

-- 4. Decisions table: one row per unlabeled group
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_inference_range_decisions AS
SELECT
  u.data_partner_id, u.measurement_concept_id, cn.concept_name,
  u.range_low, u.range_high, u.n, u.med,
  CASE
    WHEN r.rule = 'unitless'           THEN 'unitless'
    WHEN r.rule = 'suspect_concept'    THEN 'suspect_concept'
    WHEN u.measurement_concept_id = 0  THEN 'no_concept'
    WHEN r.rule = 'explicit'           THEN 'explicit'
    WHEN p.lvl = 1                     THEN 'range_match'
    WHEN p.lvl = 2                     THEN 'partner_unit'
    WHEN p.lvl = 3                     THEN 'dataset_unit'
    ELSE 'needs_review'
  END AS unit_inference_method,
  CASE
    WHEN r.rule = 'explicit' THEN ru.concept_id
    WHEN r.rule IS NULL AND u.measurement_concept_id <> 0 THEN p.unit_concept_id
  END AS inferred_unit_concept_id,
  p.n_lab  AS evidence_n,
  p.med_lab AS evidence_median,
  r.note
FROM unl u
LEFT JOIN pick p
  ON  p.rk = 1
  AND p.data_partner_id = u.data_partner_id
  AND p.measurement_concept_id = u.measurement_concept_id
  AND p.range_high = u.range_high
  AND p.range_low <=> u.range_low
LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_concept_rules r
  ON r.measurement_concept_id = u.measurement_concept_id
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
LEFT JOIN omop_vocab.concept cn
  ON cn.concept_id = u.measurement_concept_id;

-- 4b. Check: explicit rules whose UCUM code didn't resolve to a concept.
--     Should return no rows; fix the code in cell 2 if it does.
SELECT r.*
FROM hive_metastore.ehr_union_clean_metrics.unit_concept_rules r
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
WHERE r.rule = 'explicit' AND ru.concept_id IS NULL;

-- COMMAND ----------

-- ===== A3. Review: summary by method =====

-- 5a. Review: how many groups and records each method covers
SELECT unit_inference_method, COUNT(*) AS n_groups, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_inference_range_decisions
GROUP BY 1
ORDER BY n_records DESC;

-- COMMAND ----------

-- ===== A4. Review: every group =====

-- 5b. Review: every group, with the chosen unit spelled out
SELECT d.unit_inference_method, d.data_partner_id, d.measurement_concept_id, d.concept_name,
       d.range_low, d.range_high, d.n, d.med,
       uc.concept_code AS inferred_unit, d.evidence_n, d.evidence_median, d.note
FROM hive_metastore.ehr_union_clean_metrics.unit_inference_range_decisions d
LEFT JOIN omop_vocab.concept uc ON uc.concept_id = d.inferred_unit_concept_id
ORDER BY d.n DESC;

-- COMMAND ----------

-- ===== A5. Apply Part A decisions =====

-- 6. Apply to the target table. Rerunnable: it rewrites the same rows.
--    Groups marked needs_review / no_concept / suspect_concept get the
--    method recorded but no unit, so they stay visible.
MERGE INTO hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized t
USING (
  SELECT d.*, uc.concept_code AS unit_code
  FROM hive_metastore.ehr_union_clean_metrics.unit_inference_range_decisions d
  LEFT JOIN omop_vocab.concept uc ON uc.concept_id = d.inferred_unit_concept_id
) d
ON  t.data_partner_id = d.data_partner_id
AND t.measurement_concept_id = d.measurement_concept_id
AND t.range_high = d.range_high
AND t.range_low <=> d.range_low
AND t.value_as_number IS NOT NULL
AND t.unit_source_value IS NULL
AND COALESCE(t.unit_concept_id, 0) = 0
WHEN MATCHED THEN UPDATE SET
  t.unit_inference_method      = d.unit_inference_method,
  t.inferred_unit_concept_id   = d.inferred_unit_concept_id,
  t.inferred_unit_source_value = d.unit_code,
  t.canonical_unit_concept_id  = NULL,
  t.harmonized_value_as_number = CASE WHEN d.unit_inference_method = 'unitless'
                                      THEN t.value_as_number END;

-- COMMAND ----------

-- ===== A6. No-concept records: rules. Last result: check, should be empty =====

-- 7. Records with no concept (measurement_concept_id = 0): decide the unit
--    from the source test name. Patterns are matched against
--    lower(measurement_source_value); the lowest priority number wins, so
--    ratios come before their components ("albumin/globulin" before "albumin").
--    Run this AFTER cell 6: it overwrites the 'no_concept' rows cell 6 wrote.
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_source_name_rules AS
SELECT * FROM VALUES
  -- unitless
  ( 1, '%albumin/globulin%',     'unitless', CAST(NULL AS STRING)),
  ( 3, '%bun/creatinine%',       'unitless', NULL),
  ( 4, '%igg/albumin%',          'unitless', NULL),
  ( 5, '%immunoglobulin g index%','unitless', NULL),
  ( 6, '%kappa/lambda%',         'unitless', NULL),
  ( 7, '%cd4/cd8%',              'unitless', NULL),
  ( 8, '%specific gravity%',     'unitless', NULL),
  ( 9, 'ph,%',                   'unitless', NULL),
  (10, '%inr%',                  'unitless', NULL),
  (11, '%aspergillus gm%',       'unitless', NULL),
  (12, '%teratozoospermia index%','unitless', NULL),
  (13, '%jcv index%',            'unitless', NULL),
  (14, '%nash%',                 'unitless', NULL),
  -- units
  ( 2, '%albumin/creatinine%',   'source_name', 'mg/g{creat}'),
  (15, '%non-hdl%',              'source_name', 'mg/dL'),
  (16, '%cholesterol%',          'source_name', 'mg/dL'),
  (17, '%triglyceride%',         'source_name', 'mg/dL'),
  (18, '%glucose%',              'source_name', 'mg/dL'),
  (19, '%calcium%',              'source_name', 'mg/dL'),
  (20, '%creatinine%',           'source_name', 'mg/dL'),
  (21, '%magnesium%',            'source_name', 'mg/dL'),
  (22, '%phosphate%',            'source_name', 'mg/dL'),
  (23, '%direct bilirubin%',     'source_name', 'mg/dL'),
  (24, '%apolipoprotein b%',     'source_name', 'mg/dL'),
  (25, '%protein (total)%',      'source_name', 'g/dL'),
  (26, 'albumin,%',              'source_name', 'g/dL'),
  (27, '%globulin%',             'source_name', 'g/dL'),
  (28, '%hemoglobin%',           'source_name', 'g/dL'),
  (29, '%hematocrit%',           'source_name', '%'),
  (30, '%rdw%',                  'source_name', '%'),
  (31, '%sodium%',               'source_name', 'mmol/L'),
  (32, '%potassium%',            'source_name', 'mmol/L'),
  (33, '%chloride%',             'source_name', 'mmol/L'),
  (34, '%platelet count%',       'source_name', '10*3/uL'),
  (35, '%lymphocyte count%',     'source_name', '10*3/uL'),
  (36, '%neutrophils%',          'source_name', '10*3/uL'),
  (37, '%monocytes%',            'source_name', '10*3/uL'),
  (38, '%basophils%',            'source_name', '10*3/uL'),
  (39, '%eosinophil count%',     'source_name', '10*3/uL'),
  (40, '%immature granulocytes%','source_name', '10*3/uL'),
  (41, '%alt (gpt)%',            'source_name', '[U]/L'),
  (42, '%ast (got)%',            'source_name', '[U]/L'),
  (43, '%alkaline phosphatase%', 'source_name', '[U]/L'),
  (44, '%thyroid stimulating%',  'source_name', '10*-6.[iU]/mL'),
  (45, '%insulin%',              'source_name', '10*-6.[iU]/mL'),
  (46, '%sedimentation%',        'source_name', 'mm/h'),
  (47, '%cortisol%',             'source_name', 'ug/dL'),
  (48, '%prolactin%',            'source_name', 'ng/mL'),
  (49, '%hydroxy%',              'source_name', 'ng/mL'),
  (50, '%free t4%',              'source_name', 'ng/dL'),
  (51, '%parathyroid%',          'source_name', 'pg/mL'),
  (52, '%ferritin%',             'source_name', 'ng/mL'),
  (53, '%free testosterone%',    'source_name', 'pg/mL'),
  (54, '%testosterone%',         'source_name', 'ng/dL'),
  (55, '%urobilinogen%',         'source_name', '[EU]/dL'),
  (56, '%osmolality%',           'source_name', 'mosm/kg')
AS t(priority, pattern, rule, unit_code);

-- 7b. Check: unit codes that don't resolve to a UCUM concept.
--     Should return no rows; fix the code in cell 7 if it does.
SELECT r.*
FROM hive_metastore.ehr_union_clean_metrics.unit_source_name_rules r
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
WHERE r.unit_code IS NOT NULL AND ru.concept_id IS NULL;

-- COMMAND ----------

-- ===== A7. No-concept records: decisions. Last result: review =====

-- 8. Decisions for the no-concept groups, keyed by partner + source name + range
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_inference_source_name_decisions AS
WITH g AS (
  SELECT data_partner_id, measurement_source_value, range_low, range_high,
         COUNT(*) AS n,
         percentile_approx(value_as_number, 0.5) AS med
  FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
  WHERE measurement_concept_id = 0
    AND measurement_source_value IS NOT NULL
    AND value_as_number IS NOT NULL
    AND range_high IS NOT NULL
    AND unit_source_value IS NULL
    AND COALESCE(unit_concept_id, 0) = 0
  GROUP BY 1, 2, 3, 4
),
m AS (
  SELECT g.*, r.rule, r.unit_code, r.pattern,
         ROW_NUMBER() OVER (
           PARTITION BY g.data_partner_id, g.measurement_source_value, g.range_low, g.range_high
           ORDER BY r.priority) AS rk
  FROM g
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_source_name_rules r
    ON lower(g.measurement_source_value) LIKE r.pattern
)
SELECT m.data_partner_id, m.measurement_source_value, m.range_low, m.range_high, m.n, m.med,
       COALESCE(m.rule, 'no_concept') AS unit_inference_method,
       ru.concept_id AS inferred_unit_concept_id,
       ru.concept_code AS inferred_unit,
       m.pattern AS matched_pattern
FROM m
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = m.unit_code
  AND ru.invalid_reason IS NULL
WHERE m.rk = 1;

-- 8b. Review
SELECT * FROM hive_metastore.ehr_union_clean_metrics.unit_inference_source_name_decisions
ORDER BY unit_inference_method, n DESC;

-- COMMAND ----------

-- ===== A8. Apply no-concept decisions (after A5) =====

-- 9. Apply the no-concept decisions. Rerunnable.
MERGE INTO hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized t
USING hive_metastore.ehr_union_clean_metrics.unit_inference_source_name_decisions d
ON  t.data_partner_id = d.data_partner_id
AND t.measurement_concept_id = 0
AND t.measurement_source_value = d.measurement_source_value
AND t.range_high = d.range_high
AND t.range_low <=> d.range_low
AND t.value_as_number IS NOT NULL
AND t.unit_source_value IS NULL
AND COALESCE(t.unit_concept_id, 0) = 0
WHEN MATCHED THEN UPDATE SET
  t.unit_inference_method      = d.unit_inference_method,
  t.inferred_unit_concept_id   = d.inferred_unit_concept_id,
  t.inferred_unit_source_value = d.inferred_unit,
  t.canonical_unit_concept_id  = NULL,
  t.harmonized_value_as_number = CASE WHEN d.unit_inference_method = 'unitless'
                                      THEN t.value_as_number END;
