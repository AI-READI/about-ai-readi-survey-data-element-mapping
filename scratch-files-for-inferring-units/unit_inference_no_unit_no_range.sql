%sql
-- Unit inference, Part D: numeric records with no unit string, no unit
-- concept and no reference range (~1.07M records, mostly flowsheet:
-- ETCO2, pain scores, tidal volume, MAP).
--
-- A group is (data_partner_id, test_id); test_id as in Part C (the
-- measurement concept, or 'src:<source value>' for concept 0).
-- Each group gets the first of:
--   1. unit_no_range_rules  name pattern on the test name (unitless,
--                           explicit, suspect_concept)
--   2. unit_concept_rules   Part A's hand rules by concept (pH, INR, ...)
--   3. partner_unit / dataset_unit / unitless
--                           copied from records of the same test that have a
--                           unit (or are unitless): same partner first, then
--                           any partner, most records first. A candidate only
--                           counts if the group's median is within a factor of
--                           2 of the candidate's median.
--   4. source_name          concept 0 only: Part A's unit_source_name_rules
--   5. needs_review
-- Method names are Part A's; range_high IS NULL tells Part D records apart.
--
-- Records in scope are picked by their RAW columns (no unit string, no unit
-- concept, no range_high), never by inferred_unit_concept_id, so rerunning
-- after D4 sees the same records and doesn't use its own output as evidence.
--
-- After D4, re-run Part C from cell 14 (unit_conversion.sql) so the new
-- units get converted.
--
-- Each %sql block is one cell. Blocks that end in a SELECT show its result.


-- ===== D0. Sizing =====

-- 17. Records in scope, and the records that can serve as evidence for them
CREATE OR REPLACE VIEW hive_metastore.ehr_union_clean_metrics.unit_no_range_records AS
SELECT h.*,
       CASE WHEN COALESCE(h.measurement_concept_id, 0) = 0
            THEN concat('src:', h.measurement_source_value)
            ELSE CAST(h.measurement_concept_id AS STRING)
       END AS test_id
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized h
WHERE h.value_as_number IS NOT NULL
  AND h.unit_source_value IS NULL
  AND COALESCE(h.unit_concept_id, 0) = 0
  AND h.range_high IS NULL;

-- 17a. Evidence: every other numeric record with a unit or marked unitless.
--      unit_concept_id NULL here means unitless.
CREATE OR REPLACE VIEW hive_metastore.ehr_union_clean_metrics.unit_no_range_evidence AS
SELECT data_partner_id, test_id, effective_unit_concept_id AS unit_concept_id, value_as_number
FROM hive_metastore.ehr_union_clean_metrics.measurement_unit_keyed
WHERE (effective_unit_concept_id IS NOT NULL OR unit_inference_method = 'unitless')
  AND NOT (unit_source_value IS NULL
           AND COALESCE(unit_concept_id, 0) = 0
           AND range_high IS NULL);

-- 17b. Review: overall shape
SELECT CASE WHEN COALESCE(r.measurement_concept_id, 0) = 0 THEN 'concept 0' ELSE 'has concept' END AS concept,
       mt.concept_name AS measurement_type,
       r.range_low IS NOT NULL AS has_range_low,
       COUNT(*) AS n,
       COUNT(DISTINCT r.test_id) AS n_tests,
       COUNT(DISTINCT r.data_partner_id) AS n_partners
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_records r
LEFT JOIN omop_vocab.concept mt ON mt.concept_id = r.measurement_type_concept_id
GROUP BY 1, 2, 3
ORDER BY n DESC;


%sql
-- 17c. Review: one row per test, biggest first. cum_pct shows how many tests
--      cover most of the records. frac_integer near 1 with a small range
--      suggests a score; n_text_value counts value_source_value with letters
--      or % in it (a unit hiding in the value?); n_evidence is how many
--      records of the same test have a unit to copy.
WITH t AS (
  SELECT r.test_id,
         COALESCE(mc.concept_name, max(r.measurement_source_value)) AS test_name,
         COUNT(*) AS n,
         COUNT(DISTINCT r.data_partner_id) AS n_partners,
         percentile_approx(r.value_as_number, array(0.05, 0.5, 0.95)) AS pct,
         min(r.value_as_number) AS min_value,
         max(r.value_as_number) AS max_value,
         avg(CASE WHEN r.value_as_number = floor(r.value_as_number) THEN 1D ELSE 0D END) AS frac_integer,
         COUNT_IF(r.value_source_value RLIKE '[A-Za-z%]') AS n_text_value,
         slice(collect_set(r.value_source_value), 1, 5) AS sample_values
  FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_records r
  LEFT JOIN omop_vocab.concept mc ON mc.concept_id = NULLIF(r.measurement_concept_id, 0)
  GROUP BY r.test_id, mc.concept_name
),
ev AS (
  SELECT test_id, COUNT(*) AS n_evidence
  FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_evidence
  WHERE test_id IN (SELECT test_id FROM t)
  GROUP BY 1
)
SELECT t.test_name, t.test_id, t.n,
       round(100 * SUM(t.n) OVER (ORDER BY t.n DESC ROWS UNBOUNDED PRECEDING)
                 / SUM(t.n) OVER (), 1) AS cum_pct,
       t.n_partners, t.min_value, t.pct[0] AS p05, t.pct[1] AS median, t.pct[2] AS p95,
       t.max_value, round(t.frac_integer, 2) AS frac_integer, t.n_text_value,
       COALESCE(ev.n_evidence, 0) AS n_evidence, t.sample_values
FROM t
LEFT JOIN ev ON ev.test_id = t.test_id
ORDER BY t.n DESC;


%sql
-- ===== D1. Hand rules by test name. Last result: check, should be empty =====

-- 18. Rules on the test name (concept name, or source value for concept 0).
--     Java regexes; lowest priority wins. (?i) covers the whole pattern, so
--     anchor short tokens or use (?-i:...). Starter rows only: add from the
--     17c and 19c reviews.
--     rule = 'unitless' | 'explicit' (unit_code required) | 'suspect_concept'
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_no_range_rules AS
SELECT * FROM VALUES
  (1, '(?i)score|glasgow coma|braden|apgar|richmond agitation', 'unitless', CAST(NULL AS STRING), 'scores'),
  (2, '(?i)^pain|pain (level|intensity|rating|severity)',       'unitless', NULL, 'pain scales')
AS t(priority, test_pattern, rule, unit_code, note);

-- 18a. Check: explicit rules without a valid UCUM code, and the reverse
SELECT r.*
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_rules r
LEFT JOIN omop_vocab.concept ru
  ON  ru.vocabulary_id = 'UCUM'
  AND ru.concept_code = r.unit_code
  AND ru.invalid_reason IS NULL
WHERE (r.rule = 'explicit') <> (ru.concept_id IS NOT NULL);


%sql
-- 18b. Review: tests each name rule hits, with the rule that wins.
--      Look for tests a pattern catches by accident.
WITH t AS (
  SELECT r.test_id, COALESCE(mc.concept_name, max(r.measurement_source_value)) AS test_name,
         COUNT(*) AS n, percentile_approx(r.value_as_number, 0.5) AS median
  FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_records r
  LEFT JOIN omop_vocab.concept mc ON mc.concept_id = NULLIF(r.measurement_concept_id, 0)
  GROUP BY r.test_id, mc.concept_name
)
SELECT ru.priority, ru.test_pattern, ru.rule, ru.unit_code, t.test_name, t.n, t.median,
       ru.priority = min(ru.priority) OVER (PARTITION BY t.test_id) AS wins
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_rules ru
LEFT JOIN t ON t.test_name RLIKE ru.test_pattern
ORDER BY ru.priority, t.n DESC;


%sql
-- ===== D2. Decisions =====

-- 19. One row per (partner, test)
CREATE OR REPLACE TABLE hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions AS
WITH g AS (
  SELECT r.data_partner_id, r.test_id,
         max(r.measurement_concept_id) AS measurement_concept_id,
         COALESCE(mc.concept_name, max(r.measurement_source_value)) AS test_name,
         max(r.measurement_source_value) AS measurement_source_value,
         COUNT(*) AS n,
         percentile_approx(r.value_as_number, array(0.05, 0.5, 0.95)) AS pct,
         avg(CASE WHEN r.value_as_number = floor(r.value_as_number) THEN 1D ELSE 0D END) AS frac_integer
  FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_records r
  LEFT JOIN omop_vocab.concept mc ON mc.concept_id = NULLIF(r.measurement_concept_id, 0)
  GROUP BY r.data_partner_id, r.test_id, mc.concept_name
),
ev AS (
  SELECT * FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_evidence
  WHERE test_id IN (SELECT test_id FROM g)
),
-- candidates: 2 = same partner and test, 3 = same test, any partner
cand AS (
  SELECT 2 AS lvl, data_partner_id, test_id, unit_concept_id,
         COUNT(*) AS n_ev, percentile_approx(value_as_number, 0.5) AS med_ev
  FROM ev GROUP BY data_partner_id, test_id, unit_concept_id
  UNION ALL
  SELECT 3, NULL, test_id, unit_concept_id,
         COUNT(*), percentile_approx(value_as_number, 0.5)
  FROM ev GROUP BY test_id, unit_concept_id
),
-- every unit the test carries elsewhere, for the review
ev_units AS (
  SELECT c.test_id,
         array_join(transform(
           array_sort(collect_list(named_struct(
             'k', -c.n_ev,
             's', concat(COALESCE(u.concept_code, 'unitless'), ' n=', CAST(c.n_ev AS STRING),
                         ' med=', CAST(round(c.med_ev, 3) AS STRING))))),
           x -> x.s), '; ') AS evidence_units
  FROM cand c
  LEFT JOIN omop_vocab.concept u ON u.concept_id = c.unit_concept_id
  WHERE c.lvl = 3
  GROUP BY c.test_id
),
-- best candidate whose median fits; same-sign ratio so negatives work too
pick AS (
  SELECT * FROM (
    SELECT g.data_partner_id, g.test_id, c.lvl, c.unit_concept_id, c.n_ev, c.med_ev,
           ROW_NUMBER() OVER (PARTITION BY g.data_partner_id, g.test_id
                              ORDER BY c.lvl, c.n_ev DESC) AS rk
    FROM g
    JOIN cand c
      ON  c.test_id = g.test_id
      AND (c.lvl = 3 OR c.data_partner_id = g.data_partner_id)
    WHERE (g.pct[1] = 0 AND c.med_ev = 0)
       OR (c.med_ev <> 0 AND g.pct[1] / c.med_ev BETWEEN 0.5 AND 2)
  ) WHERE rk = 1
),
name_rule AS (
  SELECT * FROM (
    SELECT t.test_id, r.rule, r.unit_code, r.note,
           ROW_NUMBER() OVER (PARTITION BY t.test_id ORDER BY r.priority) AS rk
    FROM (SELECT DISTINCT test_id, test_name FROM g) t
    JOIN hive_metastore.ehr_union_clean_metrics.unit_no_range_rules r
      ON t.test_name RLIKE r.test_pattern
  ) WHERE rk = 1
),
src_rule AS (
  SELECT * FROM (
    SELECT t.test_id, r.rule, r.unit_code, r.pattern,
           ROW_NUMBER() OVER (PARTITION BY t.test_id ORDER BY r.priority) AS rk
    FROM (SELECT DISTINCT test_id, measurement_source_value FROM g
          WHERE measurement_concept_id = 0) t
    JOIN hive_metastore.ehr_union_clean_metrics.unit_source_name_rules r
      ON lower(t.measurement_source_value) LIKE r.pattern
  ) WHERE rk = 1
),
-- hand rule per group: name rule first, then Part A's concept rule
hand AS (
  SELECT g.data_partner_id, g.test_id,
         CASE WHEN nr.rule IS NOT NULL THEN nr.rule      ELSE cr.rule      END AS rule,
         CASE WHEN nr.rule IS NOT NULL THEN nr.unit_code ELSE cr.unit_code END AS unit_code,
         CASE WHEN nr.rule IS NOT NULL THEN nr.note      ELSE cr.note      END AS note
  FROM g
  LEFT JOIN name_rule nr ON nr.test_id = g.test_id
  LEFT JOIN hive_metastore.ehr_union_clean_metrics.unit_concept_rules cr
    ON cr.measurement_concept_id = NULLIF(g.measurement_concept_id, 0)
)
SELECT g.data_partner_id, g.test_id, g.measurement_concept_id, g.test_name,
       g.n, g.pct[0] AS p05, g.pct[1] AS med, g.pct[2] AS p95,
       round(g.frac_integer, 2) AS frac_integer,
       CASE
         WHEN h.rule IS NOT NULL                              THEN h.rule
         WHEN p.lvl IS NOT NULL AND p.unit_concept_id IS NULL THEN 'unitless'
         WHEN p.lvl = 2                                       THEN 'partner_unit'
         WHEN p.lvl = 3                                       THEN 'dataset_unit'
         WHEN s.rule IS NOT NULL                              THEN s.rule
         ELSE 'needs_review'
       END AS unit_inference_method,
       CASE
         WHEN h.rule = 'explicit'  THEN hu.concept_id
         WHEN h.rule IS NOT NULL   THEN NULL
         WHEN p.lvl IS NOT NULL    THEN p.unit_concept_id
         ELSE su.concept_id
       END AS inferred_unit_concept_id,
       p.n_ev  AS evidence_n,
       p.med_ev AS evidence_median,
       e.evidence_units,
       COALESCE(h.note, s.pattern) AS note
FROM g
LEFT JOIN hand h     ON h.data_partner_id = g.data_partner_id AND h.test_id = g.test_id
LEFT JOIN pick p     ON p.data_partner_id = g.data_partner_id AND p.test_id = g.test_id
LEFT JOIN src_rule s ON s.test_id = g.test_id
LEFT JOIN ev_units e ON e.test_id = g.test_id
LEFT JOIN omop_vocab.concept hu
  ON  hu.vocabulary_id = 'UCUM'
  AND hu.concept_code = h.unit_code
  AND hu.invalid_reason IS NULL
LEFT JOIN omop_vocab.concept su
  ON  su.vocabulary_id = 'UCUM'
  AND su.concept_code = s.unit_code
  AND su.invalid_reason IS NULL;


%sql
-- 19a. Review: summary by method
SELECT unit_inference_method, COUNT(*) AS n_groups, SUM(n) AS n_records
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions
GROUP BY 1
ORDER BY n_records DESC;


%sql
-- 19b. Review: every group with a unit or rule, biggest first. Compare med
--      with evidence_median, and scan evidence_units for a test that carries
--      two units close enough to both pass the factor-2 check (kg vs lb).
SELECT d.unit_inference_method, d.test_name, d.data_partner_id, d.n,
       d.p05, d.med, d.p95, u.concept_code AS inferred_unit,
       d.evidence_n, d.evidence_median, d.evidence_units, d.note
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions d
LEFT JOIN omop_vocab.concept u ON u.concept_id = d.inferred_unit_concept_id
WHERE d.unit_inference_method <> 'needs_review'
ORDER BY d.n DESC;


%sql
-- 19c. Review: needs_review, one row per test across partners. These are
--      what the name rules (18) are for. evidence_units shows units the test
--      has elsewhere whose medians didn't fit.
SELECT test_name, test_id, SUM(n) AS n, COUNT(*) AS n_partners,
       min(p05) AS min_p05, percentile_approx(med, 0.5) AS med_of_medians, max(p95) AS max_p95,
       round(sum(frac_integer * n) / SUM(n), 2) AS frac_integer,
       max(evidence_units) AS evidence_units
FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions
WHERE unit_inference_method = 'needs_review'
GROUP BY test_name, test_id
ORDER BY n DESC;


%sql
-- ===== D3. Apply Part D decisions =====

-- 20. Apply. Rerunnable: it rewrites the same rows. canonical_unit_concept_id
--     is cleared so it never disagrees with harmonized_value_as_number;
--     re-run Part C from cell 14 afterwards to fill both.
MERGE INTO hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized t
USING (
  SELECT d.*, u.concept_code AS unit_code
  FROM hive_metastore.ehr_union_clean_metrics.unit_no_range_decisions d
  LEFT JOIN omop_vocab.concept u ON u.concept_id = d.inferred_unit_concept_id
) d
ON  t.data_partner_id = d.data_partner_id
AND d.test_id = CASE WHEN COALESCE(t.measurement_concept_id, 0) = 0
                     THEN concat('src:', t.measurement_source_value)
                     ELSE CAST(t.measurement_concept_id AS STRING)
                END
AND t.value_as_number IS NOT NULL
AND t.unit_source_value IS NULL
AND COALESCE(t.unit_concept_id, 0) = 0
AND t.range_high IS NULL
WHEN MATCHED THEN UPDATE SET
  t.unit_inference_method      = d.unit_inference_method,
  t.inferred_unit_concept_id   = d.inferred_unit_concept_id,
  t.inferred_unit_source_value = d.unit_code,
  t.canonical_unit_concept_id  = NULL,
  t.harmonized_value_as_number = CASE WHEN d.unit_inference_method = 'unitless'
                                      THEN t.value_as_number END;
