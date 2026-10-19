# Unit inference: status and handoff

AI-READI EHR data on Databricks. Goal: every numeric measurement record gets a
unit (or is marked unitless), a canonical unit, and a harmonized value.

## Tables

- Source: `ehr_union_clean.measurement` (never modified)
- Target: `hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized`
  (full copy of measurement, 7,835,317 rows) plus these columns:
  - `unit_inference_method`: how the unit was decided (values below)
  - `inferred_unit_concept_id`, `inferred_unit_source_value`: the unit we assigned
    (UCUM concept id and code)
  - `canonical_unit_concept_id`: NOT FILLED YET
  - `harmonized_value_as_number`: filled only for unitless records (= value_as_number)
- Original `unit_concept_id` / `unit_source_value` are left untouched. A record's
  effective unit is `COALESCE(NULLIF(unit_concept_id, 0), inferred_unit_concept_id)`.

Decision and rule tables (all in `hive_metastore.ehr_union_clean_metrics`):
`unit_concept_rules`, `unit_inference_range_decisions`, `unit_source_name_rules`,
`unit_inference_source_name_decisions`, `unit_string_map`, `unit_string_decisions`.

## Notebooks (SQL files)

- `unit_inference_range_groups.sql`: Part A
- `unit_inference_with_source_value_but_no_unit_concept.sql`: Part B

## Done

**Part A.** Numeric records with no unit string and no unit concept, but with a
reference range: 205,838 records.

| Method | Meaning |
|---|---|
| dataset_unit / partner_unit / range_match | unit copied from other records of the same test (any partner / same partner / same partner and same reference range) |
| explicit | unit set by hand per concept (unit_concept_rules) |
| source_name | concept 0; unit decided from measurement_source_value |
| unitless | pH, specific gravity, INR, ratios, indexes, scores |
| suspect_concept | values don't fit the concept (likely concept-mapping error); 88 records |
| needs_review / no_concept | undetermined; 6 records |

Result: 172,788 got a unit, 32,956 unitless, 94 flagged.

**Part B.** Numeric records with a unit string but no unit concept: about 55,000
records, 223 strings.

| Method | Meaning |
|---|---|
| mapped_string | hand map (unit_string_map) |
| reused_mapping | same string already maps to a concept elsewhere in the table |
| unitless | {ratio}, Index, S/CO, ISR, z-scores, etc. |
| not_a_unit | junk in the unit field ("Possible", "**Please", "PharmD", "Urine") |
| unmapped_string | left on purpose (~45 strings: log viral loads, FLU, CU, per-ejaculate counts) |

About 900 records remain without a unit (not_a_unit plus unmapped_string).

## Not done

1. **Conversion step (next).** Fill `canonical_unit_concept_id` and
   `harmonized_value_as_number` for every record with a unit, original or
   inferred. Needs a canonical unit per measurement concept and a conversion
   table (slope + intercept, since HbA1c % <-> mmol/mol and temperature are
   affine). Equivalent codes must be treated as the same unit:
   - mmol/L = 10*-3.eq/L (mEq/L) for monovalent ions
   - /min = {counts}/min
   - % = %{of'HGB}
   - [iU]/L = [U]/L
   Existing strings that will matter: lb, ounces, kg (weight); inch(es),
   [in_us], cm (height); DegF, DegC, [degF] (temperature).
2. **No unit string, no reference range:** 1,066,511 numeric records. Mostly
   flowsheet data (ETCO2, pain scores, tidal volume, MAP). Probably many
   unitless scores and single-unit vitals. Needs its own sizing pass.
3. **Flagged items to look at:** suspect_concept records (CD4+CD8+ cells/cells
   that look like CD4/CD8 ratios, "HDL/total" that is total/HDL, "total T4"
   that is free T4, an "A1AT phenotype" holding an IgA value), and Beta-2
   glycoprotein IgM (4 records).
4. **Write-up for the boss**, after the conversion step.

## Gotchas learned

- OMOP UCUM codes write international units as `[iU]` (lowercase i) and
  prefixes as powers of ten: `10*-6.[iU]/mL` = uIU/mL, `10*-3.eq/L` = mEq/L,
  `mL/min/(173.10*-2.m2)` = eGFR units, `[lb_us]` = pound.
- Every hand-written unit code needs a check query against `omop_vocab.concept`
  (vocabulary_id = 'UCUM', invalid_reason IS NULL); several guesses failed.
- In Spark SQL an apostrophe inside a string is `\'`. `''` silently joins two
  strings (`'[APL''U]'` became `[APLU]`).
- Concept-level rules (e.g. "unitless") apply to every group with that concept.

## Working conventions

- Claude can't reach Databricks; Siggie runs each query and pastes results back.
- SQL comes as paste-ready cells: each starts with `%sql`, no
  `-- COMMAND ----------` lines. Every query whose result needs looking at gets
  its own cell; table-building statements can share a cell.
- Pattern for each step: build rules, run a check (should return no rows),
  build decisions, review, then apply with a rerunnable MERGE.
