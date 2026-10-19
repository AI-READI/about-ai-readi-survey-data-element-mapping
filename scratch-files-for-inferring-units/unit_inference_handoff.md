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
  - `canonical_unit_concept_id`: the test's canonical unit; set only where
    `harmonized_value_as_number` is in it (NULL for unitless records)
  - `harmonized_value_as_number`: value in the canonical unit, or
    value_as_number for unitless records
- Original `unit_concept_id` / `unit_source_value` are left untouched. A record's
  effective unit is `COALESCE(NULLIF(unit_concept_id, 0), inferred_unit_concept_id)`.

Decision and rule tables (all in `hive_metastore.ehr_union_clean_metrics`):
`unit_concept_rules`, `unit_inference_range_decisions`, `unit_source_name_rules`,
`unit_inference_source_name_decisions`, `unit_string_map`, `unit_string_decisions`,
and for Part C `unit_factors`, `unit_analytes`, `unit_analyte_bridges`,
`canonical_unit_rules`, `unit_relabel_rules`, `unit_test_units`,
`unit_test_analytes`, `unit_conversion_decisions`, `unit_conversion_medians`,
plus the view `measurement_unit_keyed`; for Part D `unit_no_range_rules`,
`unit_no_range_decisions`, and the views `unit_no_range_records`,
`unit_no_range_evidence`.

## Notebooks (SQL files)

- [unit_inference_range_groups.sql](unit_inference_range_groups.sql): Part A
- [unit_inference_with_source_value_but_no_unit_concept.sql](unit_inference_with_source_value_but_no_unit_concept.sql): Part B
- [unit_conversion.sql](unit_conversion.sql): Part C (conversion to canonical units)
- [unit_inference_no_unit_no_range.sql](unit_inference_no_unit_no_range.sql): Part D
  (no unit string, no reference range), written, not yet run

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

**Part C.** Conversion to a canonical unit per test. A test is the measurement
concept, or the measurement_source_value for concept 0.

- Every unit maps to a base (`unit_factors`: base = slope * x + intercept).
  Units with the same base convert directly. Equivalent codes are units with
  the same factor (/min = {counts}/min, % = %{of'HGB}, [iU] = [U],
  10\*3/mm3 = 10\*3/uL, and so on).
- Analytes found by name pattern (`unit_analytes`) bridge mass, molar and
  equivalent units using molar mass and charge. So mEq/L = mmol/L only for
  monovalent ions, and HbA1c % <-> mmol/mol uses the IFCC formula.
- `unit_relabel_rules` convert a unit as if it were another one. They cover
  mis-coded units (S/H used for seconds/hours, [foz_us] on weights, `deg` on
  temperature, `m2` on BMI, `mL/min` on eGFR) and a few labels the values
  contradict (CEA "mg/dL"). A rule with no target blocks conversion.
- The canonical unit is the most common one (equivalent codes counted
  together), unless a name-pattern rule in `canonical_unit_rules` sets it
  (body weight kg, height cm, temperature Cel, HbA1c %, 24 h urine protein
  mg/(24.h)).
- The 15e review compares the median converted value with the median of
  records already in the canonical unit. That's how the relabels were found.

| Method | Meaning |
|---|---|
| identity | already in the canonical unit (possibly after a relabel) |
| same_base | converted by unit factors |
| analyte_bridge | converted through molar mass or charge |
| no_conversion | different quantity under one test, or no fixed factor (log viral loads, Lp(a), arbitrary antibody units) |
| blocked | relabel rule says don't convert |

Numeric records after Part C: 5,949,036 in canonical unit, 33,039 unitless,
3,187 with a unit but no conversion, 1,067,294 with no unit.

## Not done

1. **No unit string, no reference range:** 1,066,511 numeric records. Mostly
   flowsheet data (ETCO2, pain scores, tidal volume, MAP). Probably many
   unitless scores and single-unit vitals. Part D notebook is written but not
   run: sizing (17b, 17c), name rules (`unit_no_range_rules`, two starter
   rows for scores and pain scales), decisions per (partner, test) copying
   units from labeled records of the same test with Part A's factor-2 median
   check, then a MERGE. Next: run 17-17c, write name rules from 17c, run 19,
   review 19a-19c, apply 20, re-run Part C from cell 14.
2. **Flagged items to look at:**
   - suspect_concept records: CD4+CD8+ cells/cells that look like CD4/CD8
     ratios, "HDL/total" that is total/HDL, "total T4" that is free T4, an
     "A1AT phenotype" holding an IgA value
   - Beta-2 glycoprotein IgM (4 records)
   - INR concept: about 1,440 records in seconds with median 12, so PT values
     stored under INR
   - Reticulocytes [#/volume] by automated count: 312 records in 10\*6/mm3
     with median 4.25, so RBC counts, not reticulocytes (about 0.06)
   - Expiratory minute volume: `L` and `l` rows, 869 each with the same
     median, look like duplicates
   - Body weight: [lb_us] records have median 118 kg, against 90 kg for
     records in kg ("Body weight Measured" matches)
   - Tidal volume setting: mL and mL/kg (labeled kg) under one concept
3. **Write-up for the boss.**

## Gotchas learned

- OMOP UCUM codes write international units as `[iU]` (lowercase i) and
  prefixes as powers of ten: `10*-6.[iU]/mL` = uIU/mL, `10*-3.eq/L` = mEq/L,
  `mL/min/(173.10*-2.m2)` = eGFR units, `[lb_us]` = pound.
- Every hand-written unit code needs a check query against `omop_vocab.concept`
  (vocabulary_id = 'UCUM', invalid_reason IS NULL); several guesses failed.
- In Spark SQL an apostrophe inside a string is `\'`. `''` silently joins two
  strings (`'[APL''U]'` became `[APLU]`).
- Concept-level rules (e.g. "unitless") apply to every group with that concept.
- Some unit codes in the data aren't valid UCUM (`[degC]`, `mL/min/1.73.m2`).
  Map them with a relabel rule, not a factor row, so the code check stays clean.
- Name patterns are Java regexes with `(?i)` applying to the whole pattern:
  `(?i)BUN` matched "sub**un**it" and `urate` matched "unsat**urate**d". Anchor
  them or use `(?-i:...)`.

## Working conventions

- Claude can't reach Databricks; Siggie runs each query and pastes results back.
- SQL comes as paste-ready cells: each starts with `%sql`, no
  `-- COMMAND ----------` lines. Every query whose result needs looking at gets
  its own cell; table-building statements can share a cell.
- Pattern for each step: build rules, run a check (should return no rows),
  build decisions, review, then apply with a rerunnable MERGE.
