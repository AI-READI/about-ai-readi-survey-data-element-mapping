<details>
<summary><strong>Target variables</strong></summary>

```sql
%sql
WITH lab_grouped AS (
    SELECT
        m.data_partner_id,
        m.measurement_concept_id,
        c.concept_name AS measurement_concept_name,
        m.unit_concept_id,
        m.unit_source_value,
        m.value_as_number,
        CASE
            WHEN LOWER(c.concept_name) LIKE '%creatinine, urine, random%' THEN 'Creatinine, Urine, Random'
            WHEN LOWER(c.concept_name) LIKE '%albumin, urine%'
                 AND LOWER(c.concept_name) NOT LIKE '%creatinine%' THEN 'Albumin, Urine'
            WHEN LOWER(c.concept_name) LIKE '%albumin/creatinine ratio%'
              OR LOWER(c.concept_name) LIKE '%uacr%' THEN 'Albumin/Creatinine Ratio (uACR)'
            WHEN LOWER(c.concept_name) LIKE '%glucose%' THEN 'Glucose'
            WHEN LOWER(c.concept_name) LIKE '%sodium%' THEN 'Sodium'
            WHEN LOWER(c.concept_name) LIKE '%potassium%' THEN 'Potassium'
            WHEN LOWER(c.concept_name) LIKE '%chloride%' THEN 'Chloride'
            WHEN LOWER(c.concept_name) LIKE '%anion gap%' THEN 'Anion Gap'
            WHEN LOWER(c.concept_name) LIKE '%blood urea nitrogen%'
              OR LOWER(c.concept_name) LIKE '%bun%' THEN 'Blood Urea Nitrogen'
            WHEN LOWER(c.concept_name) LIKE '%creatinine%'
                 AND LOWER(c.concept_name) NOT LIKE '%albumin/creatinine%'
                 AND LOWER(c.concept_name) NOT LIKE '%creatinine, urine, random%' THEN 'Creatinine'
            WHEN LOWER(c.concept_name) LIKE '%ast/sgot%'
              OR LOWER(c.concept_name) LIKE '%sgot%' THEN 'AST/SGOT'
            WHEN LOWER(c.concept_name) LIKE '%alkaline phosphatase%' THEN 'Alkaline Phosphatase'
            WHEN LOWER(c.concept_name) LIKE '%alt/sgpt%'
              OR LOWER(c.concept_name) LIKE '%sgpt%' THEN 'ALT/SGPT'
            WHEN LOWER(c.concept_name) LIKE '%bilirubin, total%' THEN 'Bilirubin, total'
            WHEN LOWER(c.concept_name) LIKE '%calcium%' THEN 'Calcium'
            WHEN LOWER(c.concept_name) LIKE '%protein, total%' THEN 'Protein, total'
            WHEN LOWER(c.concept_name) LIKE '%serum albumin%' THEN 'Albumin, Serum'
            WHEN LOWER(c.concept_name) LIKE '%globulin%' THEN 'Globulin'
            WHEN LOWER(c.concept_name) LIKE '%egfr%'
              OR LOWER(c.concept_name) LIKE '%estimated glomerular filtration rate%' THEN 'eGFR'
            WHEN LOWER(c.concept_name) LIKE '%a/g ratio%'
              OR LOWER(c.concept_name) LIKE '%albumin/globulin%' THEN 'A/G Ratio'
            WHEN LOWER(c.concept_name) LIKE '%cholesterol%'
              AND LOWER(c.concept_name) NOT LIKE '%hdl%'
              AND LOWER(c.concept_name) NOT LIKE '%ldl%'
              AND LOWER(c.concept_name) NOT LIKE '%vldl%'
              AND LOWER(c.concept_name) NOT LIKE '%non hdl%' THEN 'Cholesterol'
            WHEN LOWER(c.concept_name) LIKE '%triglyceride%' THEN 'Triglyceride'
            WHEN LOWER(c.concept_name) LIKE '%hdl cholesterol%' THEN 'HDL Cholesterol'
            WHEN LOWER(c.concept_name) LIKE '%ldl cholesterol%' THEN 'LDL Cholesterol'
            WHEN LOWER(c.concept_name) LIKE '%vldl%' THEN 'VLDL'
            WHEN LOWER(c.concept_name) LIKE '%non hdl cholesterol%' THEN 'Non-HDL Cholesterol'
            WHEN LOWER(c.concept_name) LIKE '%c-peptide%' THEN 'C-Peptide'
            WHEN LOWER(c.concept_name) LIKE '%vitamin d%' THEN 'Vitamin D'
            WHEN LOWER(c.concept_name) LIKE '%hemoglobin a1c%'
              OR LOWER(c.concept_name) LIKE '%hba1c%' THEN 'Hemoglobin A1C'
            ELSE NULL
        END AS lab_category
    FROM ehr_union_clean.measurement m
    LEFT JOIN omop_vocab.concept c
        ON m.measurement_concept_id = c.concept_id
    WHERE m.data_partner_id IN (2084, 3058, 8469)
)
SELECT
    data_partner_id,
    lab_category,
    measurement_concept_id,
    measurement_concept_name,
    unit_concept_id,
    unit_source_value,
    COUNT(*) AS record_count,
    AVG(value_as_number) AS avg_value_as_number
FROM lab_grouped
WHERE lab_category IS NOT NULL
  AND value_as_number IS NOT NULL
GROUP BY
    data_partner_id,
    lab_category,
    measurement_concept_id,
    measurement_concept_name,
    unit_concept_id,
    unit_source_value
ORDER BY
    data_partner_id,
    lab_category,
    measurement_concept_name,
    unit_concept_id,
    unit_source_value;
```



|data_partner_id|lab_category|measurement_concept_id|measurement_concept_name|unit_concept_id|unit_source_value|record_count|avg_value_as_number|
|---|---|---|---|---|---|---|---|
|2084|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|null|null|11|67.72727272727273|
|2084|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|8645|U/L|12284|90.30096059915337|
|2084|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|8923|IU/L|1512|76.0271164021164|
|2084|Alkaline Phosphatase|3021952|Alkaline phosphatase isoenzymes [Enzymatic activity/volume] in Serum or Plasma by Heat stability|8645|U/L|20|0|
|2084|Alkaline Phosphatase|3001467|Alkaline phosphatase.bone [Enzymatic activity/volume] in Serum or Plasma|8645|U/L|26|105.26923076923077|
|2084|Alkaline Phosphatase|3018910|Alkaline phosphatase.bone [Mass/volume] in Serum or Plasma|8748|ug/L|2|45.4|
|2084|Alkaline Phosphatase|3002069|Alkaline phosphatase.bone/Alkaline phosphatase.total in Serum or Plasma|8554|%|2|29|
|2084|Alkaline Phosphatase|3020990|Alkaline phosphatase.intestinal/Alkaline phosphatase.total in Serum or Plasma|8554|%|2|15|
|2084|Alkaline Phosphatase|3035400|Alkaline phosphatase.liver [Enzymatic activity/volume] in Serum or Plasma|8645|U/L|26|158.46153846153845|
|2084|Alkaline Phosphatase|3036955|Alkaline phosphatase.liver/Alkaline phosphatase.total in Serum or Plasma|8554|%|2|56|
|2084|Alkaline Phosphatase|3045684|Alkaline phosphatase.other fractions [Enzymatic activity/volume] in Serum or Plasma|8645|U/L|6|0|
|2084|Alkaline Phosphatase|3037466|Alkaline phosphatase.placental/Alkaline phosphatase.total in Serum or Plasma|8554|%|1|0|
|2084|Anion Gap|3045716|Anion gap in Serum or Plasma by calculation|8753|mmol/L|15436|11.731944804353459|
|2084|Blood Urea Nitrogen|3038136|Choriogonadotropin.beta subunit [Units/volume] in Serum or Plasma|9550|mIU/mL|2|5|
|2084|Blood Urea Nitrogen|3046071|Choriogonadotropin.intact+Beta subunit [Units/volume] in Serum or Plasma|9550|mIU/mL|97|1210.1958762886597|
|2084|Calcium|3007687|Calcium [Mass/time] in 24 hour Urine|null|null|1|174|
|2084|Calcium|3007687|Calcium [Mass/time] in 24 hour Urine|8909|mg/24 h|3|138|
|2084|Calcium|3007687|Calcium [Mass/time] in 24 hour Urine|8909|mg/24 hr|18|209.94444444444446|
|2084|Calcium|3017730|Calcium [Mass/volume] in 24 hour Urine|8840|mg/dL|35|14.128571428571425|
|2084|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|null|null|11|9.281818181818183|
|2084|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|8840|MG/DL|5|9.600000000000001|
|2084|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|8840|mg/dL|17719|9.370314351825783|
|2084|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|8840|mg/dl|4|9.3|
|2084|Calcium|3006661|Calcium [Mass/volume] in Urine|8840|mg/dL|1|35.6|
|2084|Calcium|3031809|Calcium hydrogen phosphate dihydrate [Saturation Fraction] in 24 hour Urine|null|null|10|0.366|
|2084|Calcium|3029800|Calcium oxalate dihydrate/Total in Stone by Infrared spectroscopy|8554|%|1|10|
|2084|Calcium|3032612|Calcium oxalate index in 24 hour Urine|null|null|10|3.9379999999999997|
|2084|Calcium|3034896|Calcium oxalate monohydrate/Total in Stone|8554|%|2|92.5|
|2084|Calcium|3023690|Calcium phosphate/Total in Stone|8554|%|1|5|
|2084|Calcium|3027694|Calcium.ionized [Mass/volume] in Serum or Plasma|8840|mg/dL|7|5.514285714285714|
|2084|Calcium|3024250|Calcium.ionized [Mass/volume] in Serum or Plasma by Ion-selective membrane electrode (ISE)|8840|mg/dL|16|5.075|
|2084|Calcium|40762533|Calcium.ionized [Mass/volume] in Venous blood|8753|mmol/L|20|1.1015000000000001|
|2084|Calcium|3044331|Calcium.ionized [Moles/volume] in Arterial blood|8753|mmol/L|125|1.1446400000000005|
|2084|Calcium|3050068|Calcium.ionized [Moles/volume] in Blood by Ion-selective membrane electrode (ISE)|8753|mMol/L|379|0.8930606860158308|
|2084|Calcium|3050068|Calcium.ionized [Moles/volume] in Blood by Ion-selective membrane electrode (ISE)|8753|mmol/L|278|1.173021582733813|
|2084|Calcium|3023232|Voltage-gated calcium channel Ab [Moles/volume] in Serum|8729|pmol/L|1|1|
|2084|Chloride|3006567|Chloride [Moles/time] in 24 hour Urine|null|mmol/24 hr|9|170.11111111111111|
|2084|Chloride|3002752|Chloride [Moles/volume] in 24 hour Urine|8753|mmol/L|2|68.5|
|2084|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|null|null|11|102.45454545454545|
|2084|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|8753|MMOL/L|5|104|
|2084|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|8753|mmol/L|17574|102.32348924547627|
|2084|Chloride|3007733|Chloride [Moles/volume] in Urine|8753|mmol/L|54|75.75925925925925|
|2084|Cholesterol|3015232|Cholesterol [Mass/volume] in Body fluid|8840|mg/dL|10|69.3|
|2084|Cholesterol|3027114|Cholesterol [Mass/volume] in Serum or Plasma|null|null|11|166.72727272727272|
|2084|Cholesterol|3027114|Cholesterol [Mass/volume] in Serum or Plasma|8840|MG/DL|7|195|
|2084|Cholesterol|3027114|Cholesterol [Mass/volume] in Serum or Plasma|8840|mg/dL|6604|176.19245911568746|
|2084|Cholesterol|3027114|Cholesterol [Mass/volume] in Serum or Plasma|8840|mg/dl|1|182|
|2084|Creatinine|3043562|5-Hydroxyindoleacetate/Creatinine [Mass Ratio] in 24 hour Urine|9014|mg/gCR|2|5|
|2084|Creatinine|3006508|Arsenic/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|6|38.483333333333334|
|2084|Creatinine|3023978|Arsenic/Creatinine [Mass Ratio] in Urine|9014|ug/g CRT|1|16.6|
|2084|Creatinine|3027481|Cadmium/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|1|0.6|
|2084|Creatinine|3035982|Calcium/Creatinine [Mass Ratio] in 24 hour Urine|9017|mg/g creat|10|175.2|
|2084|Creatinine|3036325|Citrate/Creatinine [Mass Ratio] in Urine|8723|mg/g|1|182|
|2084|Creatinine|3010391|Collagen crosslinked N-telopeptide/Creatinine [Molar ratio] in Urine|null|null|1|19|
|2084|Creatinine|3003415|Copper/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|6|24.86666666666667|
|2084|Creatinine|3010913|Copper/Creatinine [Mass Ratio] in Urine|null|ug/g creat|2|8|
|2084|Creatinine|3010913|Copper/Creatinine [Mass Ratio] in Urine|9014|ug/g CRT|2|14.5|
|2084|Creatinine|3016589|Cortisol Free/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|13|56.73846153846154|
|2084|Creatinine|3004239|Creatinine [Mass/time] in 24 hour Urine|null|mg/d|28|1190.357142857143|
|2084|Creatinine|3004239|Creatinine [Mass/time] in 24 hour Urine|8807|g/24 h|3|1.1566666666666665|
|2084|Creatinine|3004239|Creatinine [Mass/time] in 24 hour Urine|8909|mg/24 hr|22|1299.409090909091|
|2084|Creatinine|3001349|Creatinine [Mass/volume] in 24 hour Urine|8840|mg/dL|94|66.58510638297872|
|2084|Creatinine|3016662|Creatinine [Mass/volume] in Body fluid|8840|mg/dL|2|1.2|
|2084|Creatinine|3016723|Creatinine [Mass/volume] in Serum or Plasma|null|null|66|1.108666666666667|
|2084|Creatinine|3016723|Creatinine [Mass/volume] in Serum or Plasma|8840|MG/DL|5|0.74|
|2084|Creatinine|3016723|Creatinine [Mass/volume] in Serum or Plasma|8840|mg/dL|17880|1.1000609619686825|
|2084|Creatinine|3017250|Creatinine [Mass/volume] in Urine|null|null|5|54.436|
|2084|Creatinine|3017250|Creatinine [Mass/volume] in Urine|8636|g/L|2|0.63|
|2084|Creatinine|3017250|Creatinine [Mass/volume] in Urine|8748|ug/L|2|2.5|
|2084|Creatinine|3017250|Creatinine [Mass/volume] in Urine|8840|mg/dL|2699|105.94668395702107|
|2084|Creatinine|3005770|Creatinine renal clearance in 24 hour Urine and Serum or Plasma|8795|mL/min|8|95.125|
|2084|Creatinine|3036094|Creatinine/Body weight [Mass/kg/time] in 24 hour Urine|null|mg/24 hr/kg|9|16.255555555555556|
|2084|Creatinine|40759796|Cystine/Creatinine [Ratio] in 24 hour Urine|null|umol/g CRT|1|49|
|2084|Creatinine|3015397|DOPamine/Creatinine [Mass Ratio] in Urine|9014|ug/g CRT|3|169.66666666666666|
|2084|Creatinine|3008612|EPINEPHrine/Creatinine [Mass Ratio] in Urine|9014|ug/g CRT|3|15|
|2084|Creatinine|1619026|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine and Cystatin C-based formula (CKD-EPI 2021)/1.73 sq M|9117|mL/min/1.73|19|82.84210526315789|
|2084|Creatinine|1619025|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI 2021)/1.73 sq M|9117|mL/min/1.73.m2|4864|62.60032894736842|
|2084|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|null|null|2|88.5|
|2084|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|null|mL/min/1.72m*2|3|98|
|2084|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|null|mL/min/1.73 m2|3848|56.20660083160083|
|2084|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|8795|mL/min|1572|56.63740458015267|
|2084|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|9117|mL/min/1.73|50|88.28|
|2084|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|9117|mL/min/1.73m2|4|84.5|
|2084|Creatinine|36306178|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among black population|null|null|2|88|
|2084|Creatinine|36306178|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among black population|9117|ML/MIN/1.73|2|117.5|
|2084|Creatinine|36306178|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among black population|9117|mL/min/1.73|481|89.71517671517671|
|2084|Creatinine|36306178|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among black population|9117|mL/min/1.73m2|72|95.52777777777777|
|2084|Creatinine|36303797|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among non black population|null|null|6|64.83333333333333|
|2084|Creatinine|36303797|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among non black population|9117|ML/MIN/1.73|2|102|
|2084|Creatinine|36303797|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among non black population|9117|mL/min/1.73|481|77.68399168399168|
|2084|Creatinine|36303797|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among non black population|9117|mL/min/1.73m2|72|82.38888888888889|
|2084|Creatinine|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|null|null|6|58.333333333333336|
|2084|Creatinine|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|9117|ML/MIN/1.73|3|88|
|2084|Creatinine|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|9117|mL/min/1.73|85|81.84705882352941|
|2084|Creatinine|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|9117|mL/min/1.73m2|122|78.77868852459017|
|2084|Creatinine|3053283|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among black population|null|null|8|68.5|
|2084|Creatinine|3053283|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among black population|9117|mL/min/1.73|3|84.66666666666667|
|2084|Creatinine|3053283|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among black population|9117|mL/min/1.73m2|116|91.12931034482759|
|2084|Creatinine|3049187|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among non black population|null|null|9|61.333333333333336|
|2084|Creatinine|3049187|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among non black population|8795|mL/min|7650|55.93751633986928|
|2084|Creatinine|3049187|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among non black population|9117|mL/min/1.73|3|73.33333333333333|
|2084|Creatinine|3015290|Mercury/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|1|1.8|
|2084|Creatinine|3036105|Metanephrine/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|4|81.5|
|2084|Creatinine|3019797|Norepinephrine/Creatinine [Mass Ratio] in Urine|9014|ug/g CRT|3|54|
|2084|Creatinine|3044199|Normetanephrine/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|4|364|
|2084|Creatinine|40765543|PhenX - urinary creatinine assay for kidney function protocol 141601|8636|G/L|1|0.2|
|2084|Creatinine|40765543|PhenX - urinary creatinine assay for kidney function protocol 141601|8636|g/L|2|0.2|
|2084|Creatinine|3001582|Protein/Creatinine [Mass Ratio] in Urine|null|null|2|358.8585|
|2084|Creatinine|3001582|Protein/Creatinine [Mass Ratio] in Urine|9017|mg/g creat|28|928.9285714285714|
|2084|Creatinine|3001582|Protein/Creatinine [Mass Ratio] in Urine|9074|mg/mg creat|8|0.828625|
|2084|Creatinine|3045462|Protein/Creatinine [Ratio] in Urine|null|null|182|0.8526923076923075|
|2084|Creatinine|3017395|Specimen creatinine acceptable [Presence] in Urine|8840|mg/dL|4|156.025|
|2084|Creatinine|3018311|Urea nitrogen/Creatinine [Mass Ratio] in Serum or Plasma|null|null|1621|18.043800123380628|
|2084|Creatinine|3018311|Urea nitrogen/Creatinine [Mass Ratio] in Serum or Plasma|8596|(calc)|98|20.346938775510203|
|2084|Creatinine|3022610|Zinc/Creatinine [Mass Ratio] in 24 hour Urine|9014|ug/g CRT|8|674.425|
|2084|Globulin|3020509|Albumin/Globulin [Mass Ratio] in Serum or Plasma|null|null|957|1.8296969696969676|
|2084|Globulin|3020509|Albumin/Globulin [Mass Ratio] in Serum or Plasma|null|**Please|4|1.775|
|2084|Globulin|3020509|Albumin/Globulin [Mass Ratio] in Serum or Plasma|8596|(calc)|489|1.691206543967281|
|2084|Globulin|3046948|Albumin/Globulin [Mass Ratio] in Serum or Plasma by Electrophoresis|null|null|296|1.257432432432433|
|2084|Globulin|3046948|Albumin/Globulin [Mass Ratio] in Serum or Plasma by Electrophoresis|null|Corrected|1|1.14|
|2084|Globulin|3015322|Alpha 1 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|31|0.24935483870967745|
|2084|Globulin|3015322|Alpha 1 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|297|0.23026936026936026|
|2084|Globulin|3005166|Alpha 1 globulin [Mass/volume] in Urine|8840|mg/dL|12|2.3583333333333334|
|2084|Globulin|3023607|Alpha 1 globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|8554|%|2|0.5|
|2084|Globulin|3005229|Alpha 2 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|31|0.8248387096774193|
|2084|Globulin|3005229|Alpha 2 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|297|0.7217845117845118|
|2084|Globulin|3037039|Alpha 2 globulin [Mass/volume] in Urine by Electrophoresis|8840|mg/dL|12|5.766666666666667|
|2084|Globulin|3020422|Alpha 2 globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|8554|%|2|2.5|
|2084|Globulin|3043723|Beta 1 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|2|0.45|
|2084|Globulin|3043747|Beta 2 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|2|0.35|
|2084|Globulin|3016520|Beta globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|29|1.0920689655172415|
|2084|Globulin|3016520|Beta globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|297|1.0585185185185184|
|2084|Globulin|3028075|Beta globulin [Mass/volume] in Urine by Electrophoresis|8840|mg/dL|12|6.683333333333334|
|2084|Globulin|3004404|Beta globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|8554|%|2|6.5|
|2084|Globulin|3013201|Beta-2-Microglobulin [Mass/volume] in Serum or Plasma|8751|mg/L|70|2.118571428571428|
|2084|Globulin|46236048|Gamma globulin [Mass/volume] by Electrophoresis in Urine collected for unspecified duration|8840|mg/dL|3|10.933333333333332|
|2084|Globulin|3023465|Gamma globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|31|1.1206451612903225|
|2084|Globulin|3023465|Gamma globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|297|1.1571717171717169|
|2084|Globulin|3001571|Gamma globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|8554|%|2|8.5|
|2084|Globulin|3021886|Globulin [Mass/volume] in Serum|null|null|1|2.3|
|2084|Globulin|3027970|Globulin [Mass/volume] in Serum by calculation|null|null|1|1.9|
|2084|Globulin|3027970|Globulin [Mass/volume] in Serum by calculation|8713|G/DL|5|2.36|
|2084|Globulin|3027970|Globulin [Mass/volume] in Serum by calculation|8713|g/dL|1488|2.4860887096774205|
|2084|Globulin|3027970|Globulin [Mass/volume] in Serum by calculation|8713|g/dL (calc)|489|2.6208588957055223|
|2084|Globulin|3004248|Sex hormone binding globulin [Moles/volume] in Serum or Plasma|null|null|1|42.5|
|2084|Globulin|3004248|Sex hormone binding globulin [Moles/volume] in Serum or Plasma|8736|nmol/L|421|34.02684085510688|
|2084|Globulin|3025547|Thyroglobulin Ab [Units/volume] in Serum or Plasma|8985|IU/mL|22|3.4499999999999997|
|2084|Globulin|3025547|Thyroglobulin Ab [Units/volume] in Serum or Plasma|8985|[IU]/mL|50|8.709999999999987|
|2084|Globulin|3036535|Thyroglobulin [Mass/volume] in Serum or Plasma|8842|ng/mL|42|2.140476190476189|
|2084|Globulin|3007498|Thyroid stimulating immunoglobulins [Units/volume] in Serum|8688|% baseline|1|285|
|2084|Globulin|3007498|Thyroid stimulating immunoglobulins [Units/volume] in Serum|8923|IU/L|7|0.09999999999999999|
|2084|Globulin|3007498|Thyroid stimulating immunoglobulins [Units/volume] in Serum|8923|[IU]/L|20|1.4920000000000004|
|2084|Globulin|3020924|Thyroxine binding globulin [Mass/volume] in Serum or Plasma|8859|ug/mL|1|16|
|2084|Glucose|3037110|Fasting glucose [Mass/volume] in Serum or Plasma|null|null|2|167|
|2084|Glucose|3037110|Fasting glucose [Mass/volume] in Serum or Plasma|8840|mg/dL|20|85.95|
|2084|Glucose|3007034|Glucose [Mass/volume] in 24 hour Urine|8840|mg/dL|1|2|
|2084|Glucose|3031266|Glucose [Mass/volume] in Arterial blood|8840|mg/dL|351|161.85754985754986|
|2084|Glucose|3000483|Glucose [Mass/volume] in Blood|8840|mg/dL|314|118.65605095541402|
|2084|Glucose|3000483|Glucose [Mass/volume] in Blood|8840|mg/dl|76|139.18421052631578|
|2084|Glucose|3019210|Glucose [Mass/volume] in Body fluid|8840|mg/dL|15|142.33333333333334|
|2084|Glucose|3034962|Glucose [Mass/volume] in Capillary blood by Glucometer|8840|mg/dL|10433|153.03680628774083|
|2084|Glucose|3022548|Glucose [Mass/volume] in Cerebral spinal fluid|8840|mg/dL|43|71.65116279069767|
|2084|Glucose|3004501|Glucose [Mass/volume] in Serum or Plasma|null|null|10|125.4|
|2084|Glucose|3004501|Glucose [Mass/volume] in Serum or Plasma|8840|MG/DL|5|94.2|
|2084|Glucose|3004501|Glucose [Mass/volume] in Serum or Plasma|8840|mg/dL|17641|123.99144039453546|
|2084|Glucose|3016699|Glucose [Mass/volume] in Serum or Plasma --1 hour post 50 g glucose PO|null|null|1|146|
|2084|Glucose|3016699|Glucose [Mass/volume] in Serum or Plasma --1 hour post 50 g glucose PO|8840|mg/dL|2|87.5|
|2084|Glucose|3007332|Glucose [Mass/volume] in Serum or Plasma --1 hour post 75 g glucose PO|null|null|2|276|
|2084|Glucose|3007332|Glucose [Mass/volume] in Serum or Plasma --1 hour post 75 g glucose PO|8840|mg/dL|18|161.44444444444446|
|2084|Glucose|3025673|Glucose [Mass/volume] in Serum or Plasma --2 hours post 75 g glucose PO|null|null|2|261|
|2084|Glucose|3025673|Glucose [Mass/volume] in Serum or Plasma --2 hours post 75 g glucose PO|8840|mg/dL|20|124.2|
|2084|Glucose|3027457|Glucose [Mass/volume] in Serum or Plasma --3 hours post 100 g glucose PO|null|null|1|197|
|2084|Glucose|3013604|Glucose [Mass/volume] in Serum or Plasma --30 minutes post 75 g glucose PO|8840|mg/dL|4|158|
|2084|Glucose|3020399|Glucose [Mass/volume] in Urine|8840|mg/dL|1|1500|
|2084|Glucose|3039896|Glucose [Mass/volume] in Urine by Automated test strip|8840|MG/DL|1|1000|
|2084|Glucose|3033408|Glucose [Mass/volume] in Venous blood|8840|mg/dL|60|206.45|
|2084|Glucose|3001501|Glucose [Moles/volume] in Capillary blood by Glucometer|8840|MG/DL|9|117.77777777777777|
|2084|Glucose|3009261|Glucose [Presence] in Urine by Test strip|null|null|2|1000.1|
|2084|Glucose|3005131|Glucose mean value [Mass/volume] in Blood Estimated from glycated hemoglobin|null|null|19|131.1578947368421|
|2084|Glucose|3005131|Glucose mean value [Mass/volume] in Blood Estimated from glycated hemoglobin|8840|mg/dL|1007|136.0834160873883|
|2084|Glucose|3005131|Glucose mean value [Mass/volume] in Blood Estimated from glycated hemoglobin|9028|mg/dL (calc)|10|152.7|
|2084|Glucose|3031932|Glucose-6-Phosphate dehydrogenase [Enzymatic activity/mass] in Red Blood Cells by Glock and McLean|9651|U/g Hgb|2|8.05|
|2084|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|null|null|42|6.790476190476189|
|2084|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|null|%Hb|10|6.889999999999999|
|2084|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|null|Dr|1|7|
|2084|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8554|%|8496|6.333992467043311|
|2084|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8644|s/co ratio|5|0.1|
|2084|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8737|% of total Hgb|280|6.741071428571427|
|2084|Hemoglobin A1C|3005673|Hemoglobin A1c/Hemoglobin.total in Blood by HPLC|8554|%|24|6.266666666666666|
|2084|Potassium|3016330|Potassium [Moles/time] in 24 hour Urine|null|mmol/24 hr|9|65.77777777777777|
|2084|Potassium|3010796|Potassium [Moles/volume] in 24 hour Urine|8753|mmol/L|3|43|
|2084|Potassium|3043409|Potassium [Moles/volume] in Arterial blood|8753|mmol/L|343|4.132653061224486|
|2084|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|null|null|66|4.495454545454545|
|2084|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|8753|MMOL/L|5|4.26|
|2084|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|8753|mmol/L|17699|4.288084072546483|
|2084|Potassium|3016038|Potassium [Moles/volume] in Urine|8753|mmol/L|60|35.3|
|2084|Potassium|3041354|Potassium [Moles/volume] in Venous blood|8753|mmol/L|62|4.138709677419355|
|2084|Sodium|3002079|Sodium [Moles/time] in 24 hour Urine|null|mmol/24 hr|9|153.55555555555554|
|2084|Sodium|3014485|Sodium [Moles/volume] in 24 hour Urine|8753|mmol/L|8|88.625|
|2084|Sodium|3043706|Sodium [Moles/volume] in Arterial blood|8753|mmol/L|343|136.06413994169097|
|2084|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|null|null|11|139.8181818181818|
|2084|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|8753|MMOL/L|5|141.8|
|2084|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|8753|mmol/L|17690|138.99536461277557|
|2084|Sodium|3003181|Sodium [Moles/volume] in Urine|null|null|1|54|
|2084|Sodium|3003181|Sodium [Moles/volume] in Urine|8753|mmol/L|90|73.42222222222222|
|2084|Sodium|3041473|Sodium [Moles/volume] in Venous blood|8753|mmol/L|61|135.1639344262295|
|2084|Sodium|3046391|Sodium urate [Saturation Fraction] in 24 hour Urine|null|null|1|1.76|
|2084|Sodium|3045687|Sodium/Creatinine [Molar ratio] in Urine|null|mmol/g creat|1|17|
|2084|Triglyceride|3000637|Triglyceride [Mass/volume] in Body fluid|8840|mg/dL|7|110.28571428571429|
|2084|Triglyceride|3022192|Triglyceride [Mass/volume] in Serum or Plasma|null|null|11|84.27272727272727|
|2084|Triglyceride|3022192|Triglyceride [Mass/volume] in Serum or Plasma|8840|MG/DL|7|112.28571428571429|
|2084|Triglyceride|3022192|Triglyceride [Mass/volume] in Serum or Plasma|8840|mg/dL|6680|157.61332335329342|
|2084|Triglyceride|3022192|Triglyceride [Mass/volume] in Serum or Plasma|8840|mg/dl|1|193|
|2084|Triglyceride|3047111|Triglyceride/Cholesterol in HDL [Mass Ratio] in Serum or Plasma|null|calc|1|1.8|
|2084|VLDL|3007352|Cholesterol in VLDL [Mass/volume] in Serum or Plasma|null|null|4|12.75|
|2084|VLDL|3007352|Cholesterol in VLDL [Mass/volume] in Serum or Plasma|8840|MG/DL|2|18.5|
|2084|VLDL|3007352|Cholesterol in VLDL [Mass/volume] in Serum or Plasma|8840|mg/dL|3|10.666666666666666|
|2084|VLDL|3009596|Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation|null|null|9|25.444444444444443|
|2084|VLDL|3009596|Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation|8840|MG/DL|5|23.2|
|2084|VLDL|3009596|Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation|8840|mg/dL|1142|22.225919439579684|
|2084|Vitamin D|40765038|1,25-Dihydroxyvitamin D [Mass/volume] in Serum or Plasma|8845|pg/mL|27|50.45185185185187|
|2084|Vitamin D|40765039|1,25-Dihydroxyvitamin D2 [Mass/volume] in Serum or Plasma|8845|pg/mL|3|9.666666666666666|
|2084|Vitamin D|40765040|25-Hydroxyvitamin D3+25-Hydroxyvitamin D2 [Mass/volume] in Serum or Plasma|8842|NG/ML|11|27.3|
|2084|Vitamin D|40765040|25-Hydroxyvitamin D3+25-Hydroxyvitamin D2 [Mass/volume] in Serum or Plasma|8842|ng/mL|867|39.053863898500545|
|2084|Vitamin D|3049536|25-hydroxyvitamin D2 [Mass/volume] in Serum or Plasma|8842|ng/mL|400|5.6375|
|2084|Vitamin D|3020149|25-hydroxyvitamin D3 [Mass/volume] in Serum or Plasma|8842|ng/mL|460|33.827608695652174|
|2084|Vitamin D|3037334|Vitamin D+Metabolites [Mass/volume] in Serum or Plasma|null|null|2|39.55|
|2084|Vitamin D|3037334|Vitamin D+Metabolites [Mass/volume] in Serum or Plasma|8842|ng/mL|1215|42.61316872427984|
|3058|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|null|null|7|70.14285714285714|
|3058|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|8645|U/L|9706|71.38450443024934|
|3058|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|8923|IU/L|1|71|
|3058|Alkaline Phosphatase|3018910|Alkaline phosphatase.bone [Mass/volume] in Serum or Plasma|null|ug/L|7|26.328571428571426|
|3058|Alkaline Phosphatase|3018910|Alkaline phosphatase.bone [Mass/volume] in Serum or Plasma|8748|mcg/L|8|18.375|
|3058|Anion Gap|3039000|Anion gap in Blood by calculation|8753|mmol/L|2|17|
|3058|Anion Gap|3045716|Anion gap in Serum or Plasma by calculation|null|null|12864|8.197761194029852|
|3058|Anion Gap|3045716|Anion gap in Serum or Plasma by calculation|8753|mmol/L|3|7|
|3058|Anion Gap|3045716|Anion gap in Serum or Plasma by calculation|8753|mmol/l|1|10|
|3058|Anion Gap|3045716|Anion gap in Serum or Plasma by calculation|9557|meq/L|34|16.735294117647058|
|3058|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|null|null|9|8.844444444444445|
|3058|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|8840|mg/dL|13003|9.380258401907225|
|3058|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|8840|mg/dl|2|9.149999999999999|
|3058|Calcium|3013784|Calcium.ionized [Moles/volume] in Serum or Plasma by Ion-selective membrane electrode (ISE)|8753|mmol/L|40|1.1862500000000002|
|3058|Chloride|3018572|Chloride [Moles/volume] in Blood|9557|meq/L|39|102.51282051282051|
|3058|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|8753|mmol/L|120|103.875|
|3058|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|9557|mEq/L|754|102.95888594164457|
|3058|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|9557|meq/L|12089|102.81470758540823|
|3058|Cholesterol|3027114|Cholesterol [Mass/volume] in Serum or Plasma|8840|mg/dL|6549|180.21377309512903|
|3058|Creatinine|3051825|Creatinine [Mass/volume] in Blood|8840|mg/dL|209|1.1492822966507172|
|3058|Creatinine|3016723|Creatinine [Mass/volume] in Serum or Plasma|8840|mg/dL|12957|1.0501057343520896|
|3058|Creatinine|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|720870|mL/min/1.73|12|100|
|3058|Creatinine|3045462|Protein/Creatinine [Ratio] in Urine|null|null|360|1.1855555555555575|
|3058|Creatinine|3018311|Urea nitrogen/Creatinine [Mass Ratio] in Serum or Plasma|null|null|9|16.333333333333332|
|3058|Globulin|3020509|Albumin/Globulin [Mass Ratio] in Serum or Plasma|null|null|5|1.8|
|3058|Globulin|3016520|Beta globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|238|0.7798319327731085|
|3058|Globulin|3013201|Beta-2-Microglobulin [Mass/volume] in Serum or Plasma|8859|ug/mL|7|3.1714285714285713|
|3058|Globulin|3023465|Gamma globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|g/dL|238|0.8953781512605048|
|3058|Globulin|3027970|Globulin [Mass/volume] in Serum by calculation|8713|g/dL|5|2.56|
|3058|Globulin|3013770|Testosterone [Mass/volume] adjusted for sex hormone binding globulin in Serum or Plasma|8842|ng/mL|130|3.2476923076923088|
|3058|Glucose|3037110|Fasting glucose [Mass/volume] in Serum or Plasma|8840|mg/dL|145|116.84827586206896|
|3058|Glucose|3000483|Glucose [Mass/volume] in Blood|null|null|4|163.5|
|3058|Glucose|3000483|Glucose [Mass/volume] in Blood|8840|mg/dL|1198|140.40818030050085|
|3058|Glucose|3034962|Glucose [Mass/volume] in Capillary blood by Glucometer|8840|mg/dL|417|145.673860911271|
|3058|Glucose|3004501|Glucose [Mass/volume] in Serum or Plasma|8840|mg/dL|12946|122.06627529738915|
|3058|Glucose|3005131|Glucose mean value [Mass/volume] in Blood Estimated from glycated hemoglobin|8840|mg/dL|453|134.92273730684326|
|3058|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|null|null|346|6.587283236994219|
|3058|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8554|%|8047|6.5063253386355155|
|3058|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8713|g/dL|1|5.8|
|3058|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8737|%Hb|2|6.25|
|3058|Potassium|3005456|Potassium [Moles/volume] in Blood|9557|mEq/L|9|4.144444444444444|
|3058|Potassium|3005456|Potassium [Moles/volume] in Blood|9557|meq/L|153|4.070588235294116|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|null|null|10|4.040000000000001|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|8753|mmol/L|5|4.64|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|8753|mmol/l|1|4.5|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|9557|MEQ/L|1|4.1|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|9557|mEq/L|775|4.143483870967741|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|9557|meq/L|12108|4.174966963990753|
|3058|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|9557|meq/l|1|4.2|
|3058|Potassium|46235078|Potassium [Moles/volume] in Serum, Plasma or Blood|9557|mEq/L|3|4.266666666666667|
|3058|Sodium|3000285|Sodium [Moles/volume] in Blood|9557|mEq/L|7|138.57142857142858|
|3058|Sodium|3000285|Sodium [Moles/volume] in Blood|9557|meq/L|148|138.91216216216216|
|3058|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|8753|mmol/L|2|136|
|3058|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|8753|mmol/l|1|140|
|3058|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|9557|mEq/L|764|137.2238219895288|
|3058|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|9557|meq/L|12107|138.5479474684067|
|3058|Triglyceride|3022192|Triglyceride [Mass/volume] in Serum or Plasma|8840|mg/dL|6529|156.08577117475878|
|3058|VLDL|3009596|Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation|8840|mg/dL|6476|128.29107473749227|
|3058|Vitamin D|3020149|25-hydroxyvitamin D3 [Mass/volume] in Serum or Plasma|8842|ng/mL|1467|34.90961145194277|
|8469|Alkaline Phosphatase|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|8645|Units/L|12296|82.45616460637606|
|8469|Anion Gap|3039000|Anion gap in Blood by calculation|8753|mMol/L|224|11.617410714285715|
|8469|Anion Gap|3039000|Anion gap in Blood by calculation|9557|mEq/L|104|12.115384615384615|
|8469|Anion Gap|3021391|Anion gap in Serum or Plasma by Calculated.3Ions|8753|mMol/L|22276|9.020290896031604|
|8469|Anion Gap|3021391|Anion gap in Serum or Plasma by Calculated.3Ions|9557|mEq/L|470|8.993617021276595|
|8469|Blood Urea Nitrogen|3038136|Choriogonadotropin.beta subunit [Units/volume] in Serum or Plasma|9550|mInt-unit(s)/mL|27|7617.665555555556|
|8469|Blood Urea Nitrogen|3008615|Choriogonadotropin.beta subunit [Units/volume] in Serum or Plasma by Immunoassay (EIA) 3rd IS|9550|mInt-unit(s)/mL|139|487.63021582733774|
|8469|Blood Urea Nitrogen|3046071|Choriogonadotropin.intact+Beta subunit [Units/volume] in Serum or Plasma|9550|mInt-unit(s)/mL|8|46608|
|8469|Calcium|3007687|Calcium [Mass/time] in 24 hour Urine|8909|mg/24H|18|156.5|
|8469|Calcium|3047107|Calcium [Mass/volume] corrected for albumin in Serum or Plasma|8840|mg/dL|11292|9.31172688629118|
|8469|Calcium|3006906|Calcium [Mass/volume] in Serum or Plasma|8840|mg/dL|22922|9.258738329988606|
|8469|Calcium|3006661|Calcium [Mass/volume] in Urine|null|null|3|16.633333333333333|
|8469|Calcium|3006661|Calcium [Mass/volume] in Urine|8840|mg/dL|13|11.39230769230769|
|8469|Calcium|3044331|Calcium.ionized [Moles/volume] in Arterial blood|8753|mMol/L|323|1.1454798761609908|
|8469|Calcium|3021119|Calcium.ionized [Moles/volume] in Blood|8554|%|191|49.182146596858644|
|8469|Calcium|3021119|Calcium.ionized [Moles/volume] in Blood|8753|mMol/L|583|1.1549056603773589|
|8469|Calcium|3050068|Calcium.ionized [Moles/volume] in Blood by Ion-selective membrane electrode (ISE)|8753|mMol/L|2256|1.106414007092201|
|8469|Chloride|3006567|Chloride [Moles/time] in 24 hour Urine|8910|mmol/day|1|352|
|8469|Chloride|3031248|Chloride [Moles/volume] in Arterial blood|8753|mMol/L|363|102.69146005509641|
|8469|Chloride|3018572|Chloride [Moles/volume] in Blood|8753|mMol/L|328|102.41463414634147|
|8469|Chloride|3014576|Chloride [Moles/volume] in Serum or Plasma|8753|mMol/L|22747|102.18235371697367|
|8469|Chloride|3007733|Chloride [Moles/volume] in Urine|8753|mMol/L|6|67.83333333333333|
|8469|Chloride|3035285|Chloride [Moles/volume] in Venous blood|8753|mMol/L|31|101.64516129032258|
|8469|Cholesterol|3027114|Cholesterol [Mass/volume] in Serum or Plasma|8840|mg/dL|6843|169.48063714744995|
|8469|Creatinine|3004239|Creatinine [Mass/time] in 24 hour Urine|8909|mg/24H|62|1469.5483870967741|
|8469|Creatinine|3051825|Creatinine [Mass/volume] in Blood|8840|mg/dL|662|1.0454682779456184|
|8469|Creatinine|3016662|Creatinine [Mass/volume] in Body fluid|8840|mg/dL|11|1.7818181818181815|
|8469|Creatinine|3016723|Creatinine [Mass/volume] in Serum or Plasma|8840|mg/dL|22757|1.283707870105908|
|8469|Creatinine|3017250|Creatinine [Mass/volume] in Urine|null|null|11|92.63636363636364|
|8469|Creatinine|3017250|Creatinine [Mass/volume] in Urine|8840|mg/dL|2558|114.725488663018|
|8469|Creatinine|3043954|Creatinine in dialysis fluid/Creatinine in serum or plasma|8840|mg/dL|321|1.0620872274143303|
|8469|Creatinine|3005770|Creatinine renal clearance in 24 hour Urine and Serum or Plasma|8795|mL/min|5|102.2|
|8469|Creatinine|3005770|Creatinine renal clearance in 24 hour Urine and Serum or Plasma|720870|mL/min/1.73 m2|14|69.14285714285714|
|8469|Creatinine|3008392|Creatinine/Protein [Mass Ratio] in Urine|null|null|94|763.4755319148936|
|8469|Creatinine|1619025|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI 2021)/1.73 sq M|0|mL/min/1.73m²|4892|72.11292722812743|
|8469|Creatinine|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|0|mL/min/1.73m²|6913|71.78287140170713|
|8469|Creatinine|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|720870|mL/min/1.73 m2|11909|76.22503232849105|
|8469|Creatinine|3001582|Protein/Creatinine [Mass Ratio] in Urine|null|null|675|506.0035555555556|
|8469|Globulin|3015322|Alpha 1 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|412|0.3249271844660192|
|8469|Globulin|3005229|Alpha 2 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|412|0.7576699029126216|
|8469|Globulin|3016520|Beta globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|412|0.7890533980582518|
|8469|Globulin|3013201|Beta-2-Microglobulin [Mass/volume] in Serum or Plasma|8751|mg/L|22|4.170454545454546|
|8469|Globulin|3023465|Gamma globulin [Mass/volume] in Serum or Plasma by Electrophoresis|8713|gm/dL|412|1.1520631067961171|
|8469|Globulin|3004248|Sex hormone binding globulin [Moles/volume] in Serum or Plasma|8736|nMol/L|112|37.36160714285715|
|8469|Globulin|3004248|Sex hormone binding globulin [Moles/volume] in Serum or Plasma|8843|nMol/mL|7|31.114285714285717|
|8469|Globulin|3025547|Thyroglobulin Ab [Units/volume] in Serum or Plasma|null|null|41|1.2536585365853656|
|8469|Globulin|3025547|Thyroglobulin Ab [Units/volume] in Serum or Plasma|8763|unit(s)/mL|8|0.39999999999999997|
|8469|Globulin|40759656|Thyroglobulin Ab [Units/volume] in Serum or Plasma by Immunoassay|8510|unit(s)|10|0.04|
|8469|Globulin|3036535|Thyroglobulin [Mass/volume] in Serum or Plasma|8842|ng/mL|49|0.9175510204081634|
|8469|Glucose|3037110|Fasting glucose [Mass/volume] in Serum or Plasma|8840|mg/dL|3|91|
|8469|Glucose|3018251|Fasting glucose [Moles/volume] in Serum or Plasma|8840|mg/dL|321|137.82242990654206|
|8469|Glucose|3031266|Glucose [Mass/volume] in Arterial blood|8840|mg/dL|1794|160.70178372352285|
|8469|Glucose|3000483|Glucose [Mass/volume] in Blood|8840|mg/dL|848|149.63443396226415|
|8469|Glucose|3019210|Glucose [Mass/volume] in Body fluid|8840|mg/dL|2|176.5|
|8469|Glucose|3034962|Glucose [Mass/volume] in Capillary blood by Glucometer|8840|mg/dL|16866|172.22435669394048|
|8469|Glucose|3022548|Glucose [Mass/volume] in Cerebral spinal fluid|8840|mg/dL|21|70.85714285714286|
|8469|Glucose|3004501|Glucose [Mass/volume] in Serum or Plasma|8840|mg/dL|22641|131.22220749966874|
|8469|Glucose|3010300|Glucose [Mass/volume] in Serum or Plasma --1 hour post dose glucose|8840|mg/dL|14|125.64285714285714|
|8469|Glucose|3026300|Glucose [Mass/volume] in Serum or Plasma --2 hours post dose glucose|8840|mg/dL|4|107.5|
|8469|Glucose|3027198|Glucose [Mass/volume] in Serum or Plasma --3 hours post dose glucose|8840|mg/dL|3|90.33333333333333|
|8469|Glucose|3028247|Glucose [Mass/volume] in Serum or Plasma --30 minutes post dose glucose|8840|mg/dL|1|142|
|8469|Glucose|3011161|Glucose [Mass/volume] in Serum or Plasma --4 hours post dose glucose|8840|mg/dL|1|73|
|8469|Glucose|3033408|Glucose [Mass/volume] in Venous blood|8840|mg/dL|64|168.71875|
|8469|Glucose|3005131|Glucose mean value [Mass/volume] in Blood Estimated from glycated hemoglobin|8840|mg/dL|8208|141.08534478557596|
|8469|Hemoglobin A1C|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|8554|%|8743|6.546156925540433|
|8469|Potassium|3016330|Potassium [Moles/time] in 24 hour Urine|8910|mmol/day|9|55.622222222222234|
|8469|Potassium|3043409|Potassium [Moles/volume] in Arterial blood|8753|mMol/L|1782|4.123232323232323|
|8469|Potassium|3005456|Potassium [Moles/volume] in Blood|8753|mMol/L|2650|4.104226415094341|
|8469|Potassium|3023103|Potassium [Moles/volume] in Serum or Plasma|8753|mMol/L|21201|4.210480637705775|
|8469|Potassium|3016038|Potassium [Moles/volume] in Urine|null|null|1|46.9|
|8469|Potassium|3016038|Potassium [Moles/volume] in Urine|8753|mMol/L|11|35.39090909090908|
|8469|Potassium|3041354|Potassium [Moles/volume] in Venous blood|8753|mMol/L|98|4.331632653061225|
|8469|Sodium|3002079|Sodium [Moles/time] in 24 hour Urine|8910|mmol/day|16|178.0625|
|8469|Sodium|3043706|Sodium [Moles/volume] in Arterial blood|8753|mMol/L|1798|138.1674082313682|
|8469|Sodium|3000285|Sodium [Moles/volume] in Blood|8753|mMol/L|2971|137.38000673174017|
|8469|Sodium|3019550|Sodium [Moles/volume] in Serum or Plasma|8753|mMol/L|20647|138.0200513391776|
|8469|Sodium|3003181|Sodium [Moles/volume] in Urine|null|null|4|93.5|
|8469|Sodium|3003181|Sodium [Moles/volume] in Urine|8753|mMol/L|104|46.81730769230769|
|8469|Sodium|3041473|Sodium [Moles/volume] in Venous blood|8753|mMol/L|66|137.8939393939394|
|8469|Triglyceride|3000637|Triglyceride [Mass/volume] in Body fluid|8840|mg/dL|3|27.666666666666668|
|8469|Triglyceride|3022192|Triglyceride [Mass/volume] in Serum or Plasma|8840|mg/dL|6925|143.1407942238267|
|8469|Vitamin D|3020149|25-hydroxyvitamin D3 [Mass/volume] in Serum or Plasma|8842|ng/mL|4050|38.124617283950606|

</details>

<details>
<summary><strong>Target output table</strong></summary>

```python
# Create a measurement table in ehr_union_clean_metrics that mirrors ehr_union_clean.measurement
# with additional columns for unit harmonization

spark.sql("""
CREATE TABLE IF NOT EXISTS hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized
AS
SELECT
    m.*,
    -- Additional columns for unit harmonization (initialized as NULL)
    CAST(NULL AS STRING)  AS inferred_unit_source_value,
    CAST(NULL AS BIGINT)  AS inferred_unit_concept_id,
    CAST(NULL AS STRING)  AS canonical_unit_value,
    CAST(NULL AS BIGINT)  AS canonical_unit_concept_id,
    CAST(NULL AS DOUBLE)  AS harmonized_value_as_number
FROM hive_metastore.ehr_union_clean.measurement m
""")

print("✅ Table ehr_union_clean_metrics.measurement_unit_harmonized created successfully.")

# Verify row counts match
src_count = spark.table("hive_metastore.ehr_union_clean.measurement").count()
dst_count = spark.table("hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized").count()
print(f"   Source rows (ehr_union_clean.measurement):                          {src_count:,}")
print(f"   Destination rows (ehr_union_clean_metrics.measurement_unit_harmonized): {dst_count:,}")
print(f"   Counts match: {src_count == dst_count}")

# Show the schema of the new table
print("\n📋 Schema of new table:")
spark.table("hive_metastore.ehr_union_clean_metrics.measurement_unit_harmonized").printSchema()
```

</details>

<details>
<summary><strong>Verify output</strong></summary>

```
✅ Table ehr_union_clean_metrics.measurement_unit_harmonized created successfully.
   Source rows (ehr_union_clean.measurement):                          7,835,317
   Destination rows (ehr_union_clean_metrics.measurement_unit_harmonized): 7,835,317
   Counts match: True

📋 Schema of new table:
root
 |-- measurement_id: long (nullable = true)
 |-- person_id: long (nullable = true)
 |-- provider_id: long (nullable = true)
 |-- visit_occurrence_id: long (nullable = true)
 |-- measurement_concept_id: integer (nullable = true)
 |-- measurement_date: date (nullable = true)
 |-- measurement_datetime: timestamp (nullable = true)
 |-- measurement_time: string (nullable = true)
 |-- measurement_type_concept_id: integer (nullable = true)
 |-- operator_concept_id: integer (nullable = true)
 |-- value_as_number: double (nullable = true)
 |-- value_as_concept_id: integer (nullable = true)
 |-- unit_concept_id: integer (nullable = true)
 |-- range_low: float (nullable = true)
 |-- range_high: float (nullable = true)
 |-- visit_detail_id: long (nullable = true)
 |-- measurement_source_value: string (nullable = true)
 |-- measurement_source_concept_id: integer (nullable = true)
 |-- unit_source_value: string (nullable = true)
 |-- data_partner_id: integer (nullable = true)
 |-- inferred_unit_source_value: string (nullable = true)
 |-- inferred_unit_concept_id: long (nullable = true)
 |-- canonical_unit_value: string (nullable = true)
 |-- canonical_unit_concept_id: long (nullable = true)
 |-- harmonized_value_as_number: double (nullable = true)
```

</details>

<details>
<summary><strong>Null and distinct value counts from all cols</strong></summary>

|column_name                  |null_count|distinct_count|
|-----------------------------|----------|--------------|
|measurement_id               |0         |7835317       |
|person_id                    |0         |3734          |
|provider_id                  |2325732   |9652          |
|visit_occurrence_id          |741007    |191300        |
|measurement_concept_id       |0         |2618          |
|measurement_date             |0         |4594          |
|measurement_datetime         |3048155   |4438          |
|measurement_time             |3406717   |33456         |
|measurement_type_concept_id  |0         |17            |
|operator_concept_id          |2662281   |22            |
|value_as_number              |782761    |39460         |
|value_as_concept_id          |6006951   |155           |
|unit_concept_id              |2052455   |139           |
|range_low                    |5470415   |445           |
|range_high                   |5478702   |747           |
|visit_detail_id              |5539112   |40479         |
|measurement_source_value     |680559    |7107          |
|measurement_source_concept_id|4485944   |1087          |
|unit_source_value            |2185978   |488           |
|data_partner_id              |0         |3             |
|inferred_unit_source_value   |7835317   |0             |
|inferred_unit_concept_id     |7835317   |0             |
|canonical_unit_value         |7835317   |0             |
|canonical_unit_concept_id    |7835317   |0             |
|harmonized_value_as_number   |7835317   |0             |

</details>

<details>
<summary><strong>Sizing query</strong></summary>

```sql
%sql
WITH g AS (
  SELECT
    m.measurement_concept_id,
    c.concept_name,
    COUNT(*) AS n_numeric,
    SUM(CASE WHEN COALESCE(m.unit_concept_id, 0) = 0 THEN 1 ELSE 0 END) AS n_no_unit_concept,
    SUM(CASE WHEN COALESCE(m.unit_concept_id, 0) = 0
              AND m.unit_source_value IS NULL THEN 1 ELSE 0 END) AS n_no_unit_at_all,
    COUNT(DISTINCT m.unit_concept_id) AS n_unit_concepts,
    COUNT(DISTINCT m.data_partner_id) AS n_partners,
    SUM(CASE WHEN m.range_high IS NOT NULL THEN 1 ELSE 0 END) AS n_with_ref_range
  FROM ehr_union_clean.measurement m
  LEFT JOIN omop_vocab.concept c ON c.concept_id = m.measurement_concept_id
  WHERE m.value_as_number IS NOT NULL
  GROUP BY 1, 2
)
SELECT *,
  SUM(n_numeric) OVER (ORDER BY n_numeric DESC ROWS UNBOUNDED PRECEDING)
    / SUM(n_numeric) OVER () AS cum_share_rows,
  SUM(n_no_unit_concept) OVER (ORDER BY n_no_unit_concept DESC ROWS UNBOUNDED PRECEDING)
    / SUM(n_no_unit_concept) OVER () AS cum_share_no_unit
FROM g
ORDER BY n_numeric DESC;
```


|measurement_concept_id|concept_name|n_numeric|n_no_unit_concept|n_no_unit_at_all|n_unit_concepts|n_partners|n_with_ref_range|cum_share_rows|cum_share_no_unit|
|---|---|---|---|---|---|---|---|---|---|
|3027018|Heart rate|582300|73288|73288|2|3|73284|0.08256581018286137|0.4221893161324532|
|40762499|Oxygen saturation in Arterial blood by Pulse oximetry|535556|405|164|2|3|118886|0.1585036687408083|0.9882411778706379|
|3004249|Systolic blood pressure|360215|2276|2276|1|3|71127|0.20957947728454762|0.9657087077949271|
|3012888|Diastolic blood pressure|357131|529|529|1|3|71126|0.26021799756003355|0.986184212508398|
|3020891|Body temperature|295934|40395|40395|4|3|40351|0.3021792382790013|0.7934282555186325|
|3024171|Respiratory rate|262193|44211|44211|2|3|44208|0.3393562560864458|0.6998110996291286|
|3038553|Body mass index (BMI) [Ratio]|224221|57310|57310|2|3|0|0.3711491266428795|0.5131198387568127|
|3025315|Body weight|205860|5|5|3|3|37294|0.40033854392648566|0.9997484341153468|
|3036277|Body height|190103|0|0|2|3|23942|0.427293735774661|1|
|3013762|Body weight Measured|164481|0|0|3|2|37294|0.450615918540739|1|
|4353938|End tidal carbon dioxide concentration|160833|160833|160833|0|1|0|0.47342084203230717|0.12113801175580936|
|4353936|Inspired oxygen concentration|152422|158|158|1|1|0|0.4950331482656784|0.9964848563362969|
|43055141|Pain severity - 0-10 verbal numeric rating [Score] - Reported|127120|127120|127120|0|2|0|0.5130578190375235|0.21688368617833761|
|44782827|Expiratory tidal volume|118643|118643|118643|0|1|0|0.5298805142419287|0.306244558193064|
|0|No matching concept|86094|49344|16666|38|1|23952|0.542088003271438|0.632148161761383|
|3027598|Mean blood pressure|81018|332|332|1|1|0|0.5535757532446393|0.9917194151620415|
|4137083|Pain intensity rating scale|80650|80650|80650|0|1|0|0.5650113235541837|0.3669894342328446|
|4141655|Morse falls risk assessment|63417|63417|63417|0|1|0|0.5740033826034135|0.4699544469919047|
|3016502|Oxygen saturation in Arterial blood|62093|0|0|1|3|62042|0.5828077082975307|1|
|40762636|Body mass index (BMI) [Percentile]|60075|0|0|2|1|0|0.5913258965969217|1|
|3005424|Body surface area|59863|19|19|1|1|0|0.5998140248726844|0.9991052087695567|
|3032445|Ideal body weight|55191|0|0|2|1|0|0.60763969828811|1|
|4108290|Invasive mean arterial pressure|54637|54637|54637|0|1|0|0.615386818622922|0.554271950253223|
|4022240|Pain score|54051|54051|54051|0|1|0|0.6230508485150632|0.5949826916645828|
|3013682|Urea nitrogen [Mass/volume] in Serum or Plasma|53807|365|365|1|3|51586|0.630680281021519|0.9888166160020004|
|3006906|Calcium [Mass/volume] in Serum or Plasma|53675|20|20|1|3|51787|0.6382909969094893|0.9990479662329289|
|3016723|Creatinine [Mass/volume] in Serum or Plasma|53665|66|66|1|3|51707|0.6459002948718167|0.9980334175903303|
|3014576|Chloride [Moles/volume] in Serum or Plasma|53300|11|11|2|3|51434|0.6534578385481803|0.9993951874090522|
|3004501|Glucose [Mass/volume] in Serum or Plasma|53243|10|10|1|3|51370|0.6610073000483796|0.9994027193217663|
|3023103|Potassium [Moles/volume] in Serum or Plasma|51872|76|76|2|3|49922|0.6683623639429449|0.997931736768689|
|3019550|Sodium [Moles/volume] in Serum or Plasma|51227|11|11|2|3|49347|0.6756259716335468|0.999378617201081|
|4108289|Non-invasive mean arterial pressure|45624|45624|45624|0|1|0|0.6820951155864625|0.6665117603285119|
|3000905|Leukocytes [#/volume] in Blood by Automated count|44311|360|359|3|3|42448|0.6883780859024728|0.9899012114328409|
|3023599|MCV [Entitic mean volume] in Red Blood Cells by Automated count|43719|324|324|2|3|41890|0.6945771150204266|0.9924560362254874|
|3012030|MCH [Entitic mass] by Automated count|43704|329|329|2|3|41888|0.7007740172499162|0.9919672150903378|
|3020416|Erythrocytes [#/volume] in Blood by Automated count|43527|136|134|3|3|41885|0.7069458221955274|0.9970324263906171|
|3009744|MCHC [Entitic Mass/volume] in Red Blood Cells by Automated count|43470|92|92|3|3|41892|0.7131095449649744|0.9977539836286345|
|3019897|Erythrocyte [DistWidth] in Red Blood Cells by Automated count|43415|35|35|1|3|41878|0.7192654691433857|0.9986404897550923|
|36684829|Richmond Agitation-Sedation Scale|43058|43058|43058|0|1|0|0.7253707733763475|0.7322420093938016|
|1616927|LACE index score LACE index|42981|0|0|1|1|0|0.7314651595818594|1|
|4313591|Respiratory rate|40841|40841|40841|0|1|0|0.7372561096998025|0.763003094109743|
|3000963|Hemoglobin [Mass/volume] in Blood|40600|32|32|1|3|39001|0.7430128878097529|0.9987414173854622|
|3024929|Platelets [#/volume] in Blood by Automated count|39109|24|23|2|3|37570|0.7485582532063553|0.9989041067000882|
|3023314|Hematocrit [Volume Fraction] of Blood by Automated count|38917|13|13|1|3|37348|0.7540763944306149|0.9993093236041106|
|3015632|Carbon dioxide, total [Moles/volume] in Serum or Plasma|37878|21|21|2|3|37857|0.7594472131805831|0.9990020215653724|
|3020630|Protein [Mass/volume] in Serum or Plasma|36234|17|17|1|3|34836|0.7645849249548674|0.9991865534268697|
|3013721|Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma|35877|17|17|2|3|34483|0.7696720167837022|0.9991993576784838|
|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|35817|18|18|2|3|34446|0.77475060105868|0.9991473874807559|
|3024128|Bilirubin.total [Mass/volume] in Serum or Plasma|35743|16|16|1|3|23963|0.7798186926839007|0.9992114087388264|
|3013650|Neutrophils [#/volume] in Blood by Automated count|34523|8|7|4|3|28839|0.7847137973806944|0.9995985490523347|
|3008342|Neutrophils/Leukocytes in Blood by Automated count|33547|9|9|1|3|14793|0.7894705125347463|0.9994765320663652|
|3043111|Platelet [Entitic mean volume] in Blood by Automated count|32611|27|27|1|2|15119|0.794094509848628|0.9988461109721891|
|3045716|Anion gap in Serum or Plasma by calculation|28338|12864|12864|2|2|26457|0.798112627535322|0.8440125813069977|
|3034962|Glucose [Mass/volume] in Capillary blood by Glucometer|27716|0|0|1|3|25984|0.802042550247031|1|
|3024561|Albumin [Mass/volume] in Serum or Plasma|26282|7|7|2|3|26273|0.8057691424215561|0.9996271703206486|
|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|25973|399|388|4|3|16400|0.8094519206937173|0.9885417011879333|
|3037511|Lymphocytes/Leukocytes in Blood by Automated count|25200|6|6|1|3|15260|0.8130250933136866|0.9997055022128759|
|3011948|Monocytes/Leukocytes in Blood by Automated count|24692|6|6|1|3|14756|0.8165262353109993|0.9996874256223619|
|3005629|Inhaled oxygen flow rate|24154|0|0|1|1|0|0.819951092908727|1|
|3006923|Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma|24059|5|5|2|3|24050|0.8233624802128476|0.9997296043335613|
|3013869|Basophils/Leukocytes in Blood by Automated count|23918|0|0|1|3|13977|0.8267538747654042|1|
|3014315|Urine output|23505|0|0|1|1|0|0.8300867089889112|1|
|3010457|Eosinophils/Leukocytes in Blood by Automated count|23338|6|6|2|3|13474|0.8333958638541829|0.9997009830652475|
|3021391|Anion gap in Serum or Plasma by Calculated.3Ions|22746|0|0|2|1|22746|0.8366210775213979|1|
|3012042|Body surface area Derived from formula|22290|22290|22290|0|1|0|0.8397816337792993|0.8102168889585173|
|21490853|Invasive Systolic blood pressure|21405|0|0|1|2|0|0.8428167036178089|1|
|21490851|Invasive Diastolic blood pressure|21390|0|0|1|2|0|0.8458496465678542|1|
|3022192|Triglyceride [Mass/volume] in Serum or Plasma|20153|11|11|1|3|19225|0.8487071921158796|0.9993869023050665|
|3007070|Cholesterol in HDL [Mass/volume] in Serum or Plasma|20075|102|102|1|3|122|0.8515536778438909|0.9975378177337378|
|3027114|Cholesterol [Mass/volume] in Serum or Plasma|20015|11|11|1|3|14662|0.8543916560180451|0.9993537618891242|
|3003215|Lymphocytes [#/volume] in Blood by Manual count|19757|3|3|3|2|17849|0.8571930517106139|0.999828272390117|
|3046900|Leukocytes [#/volume] corrected for nucleated erythrocytes in Blood by Automated count|19641|0|0|2|2|19641|0.8599779994657256|1|
|46236952|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M|19038|6919|6|3|2|0|0.8626774463045739|0.9032412833174159|
|1616852|SOFA Total Score|17418|17418|17418|0|1|0|0.8651471891892811|0.8233359745240585|
|4141684|Delivered oxygen flow rate|15688|0|0|1|1|0|0.8673716309377764|1|
|3016293|Bicarbonate [Moles/volume] in Serum or Plasma|15438|8|8|1|1|13580|0.8695606245452003|0.9996106001126774|
|3035519|Braden scale total score|14588|14588|14588|0|1|0|0.8716290944729825|0.8343235287914895|
|3001420|Magnesium [Mass/volume] in Serum or Plasma|13921|3|3|1|3|13451|0.873602988760387|0.9998327915377454|
|3028288|Cholesterol in LDL [Mass/volume] in Serum or Plasma by calculation|12875|82|82|2|2|7592|0.8754285680255499|0.9978157453128907|
|3026611|Left eye Pupil diameter Manual|12833|0|0|1|1|0|0.8772481920030128|1|
|4237865|Size of pupil|12829|0|0|1|1|0|0.8790672488102186|1|
|3025524|Oxygen/Gas total Inhaled gas by Gas dilution.rebreath|12758|0|0|1|1|0|0.8808762383453602|1|
|3010321|Right eye Pupil diameter Manual|12732|0|0|1|1|0|0.8826815412738304|1|
|40763912|Albumin [Mass/volume] in Serum or Plasma by Bromocresol green (BCG) dye binding method|12125|11|11|1|1|10750|0.8844007761157798|0.9993703320970954|
|3012677|Fluid intake oral Measured|11951|0|0|1|1|0|0.8860953390515439|1|
|3027388|Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma by No addition of P-5'-P|11795|0|0|1|1|10405|0.8877677823472795|1|
|3047107|Calcium [Mass/volume] corrected for albumin in Serum or Plasma|11292|0|0|1|1|11292|0.88936890398318|1|
|3011904|Phosphate [Mass/volume] in Serum or Plasma|10939|4|4|1|3|10510|0.8909199728438881|0.9997627447495037|
|4323687|Central venous pressure|10412|10412|10412|0|1|0|0.8923963170232182|0.8518548088249915|
|3035357|Carbon dioxide [Partial pressure] in Exhaled gas --at end expiration|9976|0|0|1|1|0|0.8938108396445203|1|
|3004327|Lymphocytes [#/volume] in Blood by Automated count|9953|8|7|4|3|9946|0.895222101036844|0.999550344810964|
|3013429|Basophils [#/volume] in Blood by Automated count|9945|1|0|3|2|7292|0.8966322280886533|0.9999224212990441|
|3028615|Eosinophils [#/volume] in Blood by Automated count|9944|8|7|3|2|9937|0.8980422133478982|0.9996045745825061|
|3033575|Monocytes [#/volume] in Blood by Automated count|9942|8|7|4|3|9935|0.8994519150220147|0.9996166256428487|
|3007194|Glasgow coma score total|9855|9855|9855|0|1|0|0.9008492807430384|0.8592775088048059|
|40482818|Adelaide coma scale|9846|9846|9846|0|1|0|0.9022453703309835|0.8666934300631777|
|1619025|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI 2021)/1.73 sq M|9756|4892|0|2|2|0|0.9036286985881431|0.9209473037258866|
|3005131|Glucose mean value [Mass/volume] in Blood Estimated from glycated hemoglobin|9697|19|19|2|3|46|0.9050036610840099|0.9990908981353996|
|3022217|INR in Platelet poor plasma by Coagulation assay|9495|8054|8054|3|3|2711|0.906349981481891|0.8925354225854948|
|3032652|Glasgow coma scale|9410|9410|9410|0|1|0|0.9076842495118081|0.8737809599272116|
|3038058|Lymphocytes/Leukocytes in Blood by Manual count|8841|9|9|1|1|29|0.9089378375726475|0.9995443192807927|
|3034107|Monocytes [#/volume] in Blood by Manual count|8838|4|4|2|1|7487|0.9101910002557938|0.999804923460703|
|3022407|Monocytes/Leukocytes in Blood by Manual count|8835|8|8|1|1|29|0.9114437375612473|0.9995925235221634|
|4232753|Elderly mobility scale|8768|8768|8768|0|1|0|0.9126869747648938|0.8803849409949958|
|3015956|Eosinophils/Leukocytes in Blood by Manual count|8739|8|8|1|1|7|0.913926099984176|0.9995864979919921|
|3009932|Eosinophils [#/volume] in Blood by Manual count|8629|4|4|2|2|5897|0.9151496280213869|0.9997898596352747|
|3034426|Prothrombin time (PT)|8381|3|3|2|3|8377|0.9163379915026552|0.9998440894068167|
|3009797|Basophils/Leukocytes in Blood by Manual count|8185|8|8|1|1|16|0.9174985636413238|0.9995744469316494|
|3029991|Specific gravity of Urine by Refractometry automated|8078|8078|8058|0|2|7566|0.918643963975614|0.8864692200855022|
|3019170|Thyrotropin [Units/volume] in Serum or Plasma by Detection limit <= 0.005 mIU/L|8063|8|8|1|3|7630|0.9197872374214399|0.9995623958713067|
|3027651|Basophils [#/volume] in Blood by Manual count|7890|4|4|2|1|7|0.9209059807536445|0.9997747958098463|
|3025809|Q-T interval|7735|2863|2863|1|1|0|0.9220027462383851|0.9424305783605135|
|3049187|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among non black population|7662|9|9|2|1|0|0.9230891608659328|0.9995239831164645|
|3009596|Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation|7632|9|9|1|2|7620|0.9241713217165521|0.9994697533449224|
|3009542|Hematocrit [Volume Fraction] of Blood by calculation|7442|2|2|1|3|7417|0.9252265419799574|0.9998681915275021|
|3022621|pH of Urine by Test strip|7295|7295|7295|0|2|6738|0.9262609187364127|0.8980299529104817|
|3028437|Cholesterol in LDL [Mass/volume] in Serum or Plasma|6861|0|0|1|3|13|0.9272337575199686|1|
|42869590|Oxygen/Gas total [Pure volume fraction] Inhaled gas|6515|4|4|2|2|0|0.9281575360762822|0.9998109489908743|
|3023884|Cholesterol in HDL/Cholesterol.total [Mass Ratio] in Serum or Plasma|6489|6488|6488|1|1|7|0.9290776280259242|0.9081279882863693|
|3007238|Nucleated erythrocytes [#/volume] in Blood by Automated count|6370|0|0|5|3|5426|0.9299808466604165|1|
|21491175|Number of stools|6322|6322|6322|0|1|0|0.9308772592518231|0.9128896635042676|
|3044491|Cholesterol non HDL [Mass/volume] in Serum or Plasma|6229|5|5|2|1|993|0.9317604851347512|0.9997220724208471|
|3027597|Bilirubin.direct [Mass/volume] in Serum or Plasma|6006|0|0|1|2|3724|0.9326120912758438|1|
|3020149|25-hydroxyvitamin D3 [Mass/volume] in Serum or Plasma|5977|0|0|1|3|4105|0.9334595854325722|1|
|3018677|aPTT in Platelet poor plasma by Coagulation assay|5883|1|1|2|3|5606|0.934293751088258|0.9999608340538864|
|21491174|Number of voids|5806|5806|5806|0|1|0|0.9351169987164937|0.9172626920261147|
|42869452|Immature granulocytes/Leukocytes in Blood by Automated count|5758|2|2|1|1|0|0.9359334403016438|0.9998696979100449|
|3041084|Immature granulocytes [#/volume] in Blood by Automated count|5668|0|0|2|1|1104|0.9367371205560083|1|
|3026280|Airway pressure Ventilator --at peak inspiratory flow setting|5665|0|0|1|1|0|0.93754037543268|1|
|40761514|Nucleated erythrocytes/Leukocytes [Ratio] in Blood by Automated count|5663|0|0|2|3|169|0.9383433467242231|1|
|3038234|Drainage amount of Wound|5562|0|0|1|1|0|0.9391319969667735|1|
|3000593|Cobalamin (Vitamin B12) [Mass/volume] in Serum or Plasma|5508|4|4|1|3|5373|0.9399129904108524|0.9997657575145893|
|40764999|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M|5491|3853|2|3|2|0|0.9406915733813386|0.930116654264117|
|3022022|QRS duration|5381|2863|2863|1|1|0|0.9414545591697535|0.9618380578511152|
|3007794|P-R Interval|5335|2863|2863|1|1|0|0.9422110225002113|0.9575252846309815|
|3017250|Creatinine [Mass/volume] in Urine|5277|16|16|3|2|2136|0.9429592618619406|0.999223459799169|
|3010494|Fluid intake enteral tube Measured|5263|0|0|1|1|0|0.9437055161277699|1|
|3016222|Fluid intake enteral tube 1 hour|5188|0|0|1|1|0|0.9444411359512778|1|
|3013603|Prostate specific Ag [Mass/volume] in Serum or Plasma|5168|3|3|1|3|4891|0.9451739199235001|0.9998260128163027|
|21490675|Central venous pressure (CVP)|4763|0|0|1|1|0|0.9458492779071871|1|
|3007461|Platelets [#/volume] in Blood|4527|1|1|2|2|4526|0.946491172845703|0.9999442638459152|
|3016226|PEEP Respiratory system|4489|0|0|1|1|0|0.9471276796667761|1|
|42527086|Mean airway pressure|4343|4343|4343|0|1|0|0.9477434847734637|0.9242184134176505|
|40760528|Thyrotropin receptor Ab [Units/volume] in Serum by Immunoassay|4295|0|0|1|1|4295|0.9483524838370656|1|
|3005606|Pulmonary artery Systolic blood pressure|4287|0|0|1|2|0|0.9489603485601532|1|
|3017188|Pulmonary artery Diastolic blood pressure|4285|0|0|1|2|0|0.9495679296981123|1|
|21490754|Inspired minute Volume|4167|0|0|1|1|0|0.9501587793134858|1|
|21490854|Tidal volume Ventilator --on ventilator|4144|0|0|1|1|0|0.9507463676998807|1|
|3007469|Breath rate setting Ventilator|3996|0|0|1|1|0|0.9513129707867616|1|
|3008598|Thyroxine (T4) free [Mass/volume] in Serum or Plasma|3982|6|6|1|3|3853|0.9518775887777424|0.9996964639176189|
|3029305|pH of Urine by Automated test strip|3978|3978|3978|0|3|3977|0.9524416395984662|0.9272146082953474|
|40758903|Hemoglobin [Mass/volume] in Blood by Oximetry|3820|0|0|1|2|3798|0.9529832871940329|1|
|21491756|Right eye Intraocular pressure|3745|3745|3745|0|1|0|0.9535143003472784|0.9329373555755737|
|21491757|Left eye Intraocular pressure|3701|3701|3701|0|1|0|0.9540390746276952|0.935724916471088|
|3015242|Ferritin [Mass/volume] in Serum or Plasma by Immunoassay|3612|0|0|1|2|3612|0.9545512293698909|1|
|3007359|Bilirubin.indirect [Mass/volume] in Serum or Plasma|3609|0|0|2|2|176|0.9550629587343936|1|
|4090194|Fluid output from drain|3590|0|0|1|1|0|0.9555719940401749|1|
|3027801|Oxygen [Partial pressure] in Arterial blood|3415|37|0|1|3|3388|0.9560562156472064|0.9985034089436944|
|3002400|Iron [Mass/volume] in Serum or Plasma|3265|4|4|1|2|3180|0.9565191683695954|0.9997988979305317|
|3012410|Tidal volume setting Ventilator|3254|0|0|2|1|0|0.9569805613737771|1|
|3019977|pH of Arterial blood|3177|3177|3177|0|3|3170|0.957431036350509|0.9381178051403798|
|3021044|Iron binding capacity [Mass/volume] in Serum or Plasma|3130|4|4|1|2|3054|0.9578748470767194|0.9998079362257887|
|3027946|Carbon dioxide [Partial pressure] in Arterial blood|3129|37|0|1|3|3122|0.9583185160103656|0.9985312770207369|
|3008152|Bicarbonate [Moles/volume] in Arterial blood|3129|0|0|2|3|3053|0.9587621849440118|1|
|3000185|Iron saturation [Mass Fraction] in Serum or Plasma|3126|4|4|2|2|2073|0.9592054284999652|0.999795885165446|
|3000285|Sodium [Moles/volume] in Blood|3126|0|0|2|2|3106|0.9596486720559184|1|
|3024882|Oxygen/Total gas setting [Volume Fraction] Ventilator|3117|0|0|1|1|0|0.9600906394787933|1|
|3003841|Heart rate Peripheral artery by palpation|3033|0|0|1|1|0|0.9605206963262681|1|
|3001376|Heart rate by Pulse oximetry|3033|0|0|1|1|0|0.960950753173743|1|
|4183393|Peripheral pulse|3030|0|0|1|1|0|0.9613803846435249|1|
|3003396|Base excess in Arterial blood by calculation|2914|0|0|2|3|707|0.96179356817585|1|
|3050068|Calcium.ionized [Moles/volume] in Blood by Ion-selective membrane electrode (ISE)|2913|0|0|1|2|2586|0.9622066099156107|1|
|3004699|PP interval|2863|2863|2863|0|1|0|0.9626125620271573|0.9402741917504467|
|3020019|EKG impression|2863|2863|2863|0|1|0|0.9630185141387038|0.9445869649705804|
|46235173|Q-T interval corrected based on Fridericia formula|2863|2863|2863|0|1|0|0.9634244662502502|0.9467433515806472|
|46235174|Q-T interval corrected based on Bazett formula|2863|2863|2863|0|1|0|0.9638304183617967|0.948899738190714|
|3013078|R-R interval by EKG|2863|2863|2863|0|1|0|0.9642363704733433|0.9510561248007809|
|3006277|QRS axis|2863|2863|2863|0|1|0|0.9646423225848898|0.9532125114108477|
|3027358|T wave axis|2863|2863|2863|0|1|0|0.9650482746964363|0.9553688980209146|
|3026258|Q-T interval corrected|2863|2863|2863|0|1|0|0.9654542268079828|0.9596816712410483|
|3006698|P wave axis|2863|2863|2863|0|1|0|0.9658601789195294|0.963994444461182|
|3005456|Potassium [Moles/volume] in Blood|2812|0|0|2|2|2790|0.9662588996102973|1|
|40769783|Troponin T.cardiac [Mass/volume] in Serum or Plasma by High sensitivity method|2772|0|0|1|2|2243|0.9666519485984939|1|
|3037121|Protein [Mass/volume] in Urine|2762|6|6|1|3|1219|0.9670435796610477|0.9996919447699905|
|3014007|Fractional oxyhemoglobin in Arterial blood|2665|194|194|1|3|485|0.9674214568448659|0.9955795204280536|
|3020460|C reactive protein [Mass/volume] in Serum or Plasma|2639|2|2|2|3|1304|0.9677956474220126|0.9999179021514155|
|3012516|Albumin [Mass/volume] in Urine|2466|1|1|2|2|2432|0.9681453078855382|0.9999322127855724|
|3043415|Inspiratory breath [Time] --on ventilator|2455|0|0|1|1|0|0.9684934086308566|1|
|3000483|Glucose [Mass/volume] in Blood|2440|4|4|1|3|2025|0.9688393824877108|0.9998019106956173|
|3024928|Oxygen saturation in Venous blood|2388|0|0|1|2|0|0.9691779831312222|1|
|1989190|Transmembrane pressure Renal replacement therapy circuit|2357|0|0|1|1|0|0.9695121882052408|1|
|3037556|Urate [Mass/volume] in Serum or Plasma|2297|4|4|1|3|2201|0.9698378857254023|0.999777808574932|
|3022250|Lactate dehydrogenase [Enzymatic activity/volume] in Serum or Plasma by Lactate to pyruvate reaction|2237|0|0|2|3|2115|0.9701550756917067|1|
|3006239|Hemoglobin [Mass/volume] in Arterial blood by Oximetry|2194|0|0|1|2|2171|0.9704661685777468|1|
|3031266|Glucose [Mass/volume] in Arterial blood|2145|0|0|1|2|2118|0.970770313628137|1|
|3043706|Sodium [Moles/volume] in Arterial blood|2141|0|0|1|2|2115|0.9710738915082702|1|
|3043409|Potassium [Moles/volume] in Arterial blood|2125|0|0|1|2|2099|0.9713752007073747|1|
|40762365|Oxygen content in Arterial blood by calculation|2122|0|0|1|1|0|0.9716760845287864|1|
|3007220|Creatine kinase [Enzymatic activity/volume] in Serum or Plasma|2057|0|0|1|3|1984|0.9719677518335197|1|
|3004789|Transferrin [Mass/volume] in Serum or Plasma|2052|1849|1849|1|2|757|0.9722587101754314|0.9671013584557772|
|3028074|Pulmonary artery Mean blood pressure|2007|0|0|1|1|0|0.9725432878519504|1|
|3027970|Globulin [Mass/volume] in Serum by calculation|1988|1|1|1|2|1988|0.972825171469748|0.9999879489396574|
|3039919|Specific gravity of Urine by Automated test strip|1979|147|147|1|1|1978|0.973105778954467|0.9968252987909774|
|4144329|Expiratory minute volume|1965|0|0|3|1|0|0.9733844013432861|1|
|3004905|Lipase [Enzymatic activity/volume] in Serum or Plasma|1952|0|0|1|3|1879|0.9736611804287694|1|
|3000034|Microalbumin [Mass/volume] in Urine|1820|2|2|3|1|1|0.9739192428957671|0.9998727106751305|
|3021447|Carbon dioxide [Partial pressure] in Venous blood|1814|3|0|1|3|1675|0.9741764546073792|0.9998666851449592|
|3029943|Horowitz index in Arterial blood|1789|128|128|1|1|0|0.9744301215048842|0.9971288348733585|
|3013707|Erythrocyte sedimentation rate [Velocity] in Red Blood Cells by Westergren method|1763|0|0|1|3|1728|0.9746801017957177|1|
|44805435|Optic cup disc ratio of right eye|1730|1730|1730|0|1|0|0.97492540293193|0.9684043793553285|
|3018311|Urea nitrogen/Creatinine [Mass Ratio] in Serum or Plasma|1728|1630|1630|1|2|1722|0.9751704204830135|0.9709072339502473|
|44805434|Optic cup disc ratio of left eye|1693|1693|1693|0|1|0|0.9754104752943472|0.9696795321778375|
|4159411|American Society of Anesthesiologists physical status classification|1617|1617|1617|0|1|0|0.9756397538707953|0.9721251442361285|
|3016948|Activated clotting time (ACT) of Blood by Coagulation assay|1585|0|0|2|2|508|0.9758644950851861|1|
|3001122|Ferritin [Mass/volume] in Serum or Plasma|1553|1|1|1|2|1467|0.9760846989375199|0.9999352255506582|
|3020138|Lactate [Mass/volume] in Serum or Plasma|1501|0|0|2|2|1501|0.976297529576511|1|
|3010156|C reactive protein [Mass/volume] in Serum or Plasma by High sensitivity method|1466|9|9|2|3|1313|0.976505397475752|0.9995307618379072|
|3036987|Folate [Mass/volume] in Serum or Plasma|1463|0|0|1|2|13|0.9767128399973003|1|
|3020509|Albumin/Globulin [Mass Ratio] in Serum or Plasma|1455|966|962|1|2|1447|0.9769191481783343|0.9790582698895219|
|46236053|Tacrolimus [Mass/volume] in Blood --trough|1449|8|5|1|1|0|0.9771246056039824|0.9995684214014781|
|3034485|Albumin/Creatinine [Mass Ratio] in Urine|1434|1009|1009|2|2|461|0.9773279361411664|0.9783306871213331|
|21490712|Left ventricular Cardiac index|1424|1424|0|1|1|0|0.9775298487527075|0.9731976886066263|
|3005555|Left ventricular Cardiac output|1424|0|0|1|1|0|0.9777317613642487|1|
|3000333|Central venous pressure (CVP) Mean|1375|0|0|1|1|0|0.9779267261401399|1|
|1989402|Ultrafiltrate volume removed 1 hour|1373|1373|0|1|1|0|0.9781214073309025|0.9742318202222818|
|3011960|Natriuretic peptide B [Mass/volume] in Serum or Plasma|1342|1|1|1|3|1253|0.9783116929521722|0.9999766510705861|
|4092647|Fluid intake|1338|177|177|1|1|0|0.9785014114031849|0.9959877500971617|
|3008047|Systemic vascular Resistance index|1286|5|0|2|1|0|0.9786837566408547|0.9997258383772042|
|3035146|Systemic vascular Resistance|1286|0|0|1|1|0|0.9788661018785246|1|
|3014111|Lactate [Moles/volume] in Serum or Plasma|1252|0|0|2|3|1180|0.9790436261690088|1|
|1988590|Ultrafiltrate volume removed|1232|0|0|1|1|0|0.9792183146082073|1|
|3037334|Vitamin D+Metabolites [Mass/volume] in Serum or Plasma|1217|2|2|1|1|1215|0.9793908761589415|0.9998892808831017|
|3026910|Gamma glutamyl transferase [Enzymatic activity/volume] in Serum or Plasma|1197|103|103|2|3|1066|0.9795606018583901|0.9974609922240533|
|3005168|Iron binding capacity.unsaturated [Mass/volume] in Serum or Plasma|1185|0|0|1|1|1113|0.9797286260470672|1|
|3014037|CD3+CD4+ (T4 helper) cells/cells in Blood|1176|2|2|1|2|1070|0.9798953741026658|0.9999194085339583|
|3000067|Parathyrin.intact [Mass/volume] in Serum or Plasma|1176|0|0|1|2|1112|0.9800621221582643|1|
|3028167|CD3+CD4+ (T4 helper) cells [#/volume] in Blood|1170|1|1|3|2|1065|0.9802280194584772|0.9999246808728584|
|3008893|Testosterone [Mass/volume] in Serum or Plasma|1162|3|3|3|3|1069|0.9803927824181757|0.9998395702591881|
|4101694|Peak inspiratory pressure|1141|1141|1141|0|1|0|0.9805545677340244|0.9750912114629686|
|3024354|Oxygen [Partial pressure] in Venous blood|1132|3|0|1|3|1035|0.9807150769167944|0.9998305319639311|
|3047181|Lactate [Moles/volume] in Blood|1132|0|0|1|1|1132|0.9808755860995645|1|
|21491633|Left cornea Central corneal thickness Pachymetry|1098|1098|1098|0|1|0|0.9810312743351488|0.9759182154789845|
|21491632|Right cornea Central corneal thickness Pachymetry|1098|1098|1098|0|1|0|0.9811869625707332|0.9767452194950003|
|1989533|Dialysate flow rate Renal replacement therapy circuit|1096|1096|0|1|1|0|0.9813423672211891|0.9775707171284733|
|1988610|Blood flow rate Renal replacement therapy circuit|1090|0|0|1|1|0|0.9814969211162591|1|
|1989079|Access pressure Renal replacement therapy circuit|1071|0|0|1|1|0|0.9816487809526078|1|
|1989498|Filter pressure Renal replacement therapy circuit|1065|0|0|1|1|0|0.9817997900335708|1|
|1988101|Effluent pressure Renal replacement therapy circuit|1060|0|0|1|1|0|0.9819500901517124|1|
|3002032|Base excess in Venous blood by calculation|1051|0|0|2|3|517|0.9820991141367754|1|
|1988071|Return pressure Renal replacement therapy circuit|1045|0|0|1|1|0|0.9822472873664527|1|
|3006805|Breaths maximum setting Ventilator alarm|1041|0|0|1|1|0|0.9823948934258728|1|
|3025509|Minimum volume setting Ventilator alarm|1040|0|0|1|1|0|0.9825423576927287|1|
|3033543|Specific gravity of Urine|986|909|909|1|3|981|0.9826821651611132|0.9811581671542324|
|40758412|Fetal Heart rate|983|49|49|1|1|0|0.9828215472518049|0.998244311146327|
|1988373|Pressure drop Renal replacement therapy circuit|979|0|0|1|1|0|0.9829603621722394|1|
|3021471|Maximum tidal volume setting Ventilator alarm|978|0|0|1|1|0|0.9830990353001097|1|
|3028286|Albumin [Mass/volume] in Serum or Plasma by Electrophoresis|978|0|0|1|3|951|0.9832377084279799|1|
|3023465|Gamma globulin [Mass/volume] in Serum or Plasma by Electrophoresis|978|0|0|1|3|951|0.98337638155585|1|
|3006802|Pressure maximum setting Ventilator alarm|977|0|0|1|1|0|0.9835149128911561|1|
|3016520|Beta globulin [Mass/volume] in Serum or Plasma by Electrophoresis|976|0|0|1|3|949|0.9836533024338977|1|
|3001941|Minimum tidal volume setting Ventilator alarm|967|0|0|1|1|0|0.9837904158435609|1|
|4092500|Fluid intake volume|965|0|0|1|1|0|0.9839272456680954|1|
|3012544|pH of Venous blood|960|960|960|0|2|864|0.9840633665298085|0.9797813335100822|
|44782824|Mean inspiratory airway pressure|919|919|919|0|1|0|0.9841936738963859|0.9804735162885144|
|40762903|Apnea interval Ventilator alarm|912|0|0|1|1|0|0.9843229887150134|1|
|3039001|Fluid output wound drain Estimated|898|0|0|1|1|0|0.9844503184377409|1|
|4092499|Fluid output from wound drain|894|0|0|1|1|0|0.9845770809902112|1|
|4353950|Train of four count|887|887|887|0|1|0|0.9847028509947315|0.9818262478119794|
|3019230|Fractional oxyhemoglobin in Venous blood|885|245|245|1|2|373|0.9848283374141233|0.9939405762214503|
|40765040|25-Hydroxyvitamin D3+25-Hydroxyvitamin D2 [Mass/volume] in Serum or Plasma|878|0|0|1|1|636|0.9849528312855651|1|
|3051825|Creatinine [Mass/volume] in Blood|871|0|0|1|2|866|0.9850763326090569|1|
|3029473|pH of Arterial blood adjusted to patient's actual temperature|857|857|857|0|1|791|0.9851978488366487|0.9824717327315837|
|3022803|Oxygen [Partial pressure] adjusted to patient's actual temperature in Arterial blood|857|0|0|1|1|791|0.9853193650642406|1|
|3045156|Carbon dioxide [Partial pressure] adjusted to patient's actual temperature in Arterial blood|857|0|0|1|1|791|0.9854408812918324|1|
|42528622|Erythrocyte sedimentation rate [Velocity] in Red Blood Cells by Photometric method|851|0|0|1|1|851|0.9855615467640385|1|
|3021654|Right glasses lens prescription Sphere far|835|0|0|1|1|0|0.985679943555216|1|
|3002184|Left glasses lens prescription Sphere far|817|0|0|1|1|0|0.9857957880802365|1|
|3027172|Left ventricular Ejection fraction|816|0|0|1|1|0|0.9859114908126926|1|
|3005719|IgG [Mass/volume] in Serum or Plasma|814|1|1|1|2|779|0.9860269099600202|0.9999533021411722|
|3026250|Tacrolimus [Mass/volume] in Blood|811|0|0|2|2|0|0.9861419037296549|1|
|3010747|HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by NAA with probe detection|794|1|1|2|2|447|0.9862544870256967|0.9999947276611001|
|3006217|Methemoglobin/Hemoglobin.total in Arterial blood|779|0|0|1|3|774|0.9863649434332744|1|
|3021119|Calcium.ionized [Moles/volume] in Blood|774|0|0|2|1|548|0.9864746908780306|1|
|3023421|Hepatitis B virus surface Ab [Units/volume] in Serum|765|441|441|1|2|0|0.9865831621897082|0.9872816121908526|
|3007164|IgA [Mass/volume] in Serum or Plasma|761|1|1|1|2|724|0.9866910663311288|0.9999721319229575|
|3005229|Alpha 2 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|740|0|0|1|2|713|0.9867959928286992|1|
|3015322|Alpha 1 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|740|0|0|1|2|713|0.9869009193262698|1|
|3013752|Hematocrit [Volume Fraction] of Blood by Impedance|724|0|0|1|1|672|0.9870035771428117|1|
|3028653|Carboxyhemoglobin/Hemoglobin.total in Arterial blood|720|0|0|1|3|562|0.9871056677890966|1|
|40483766|Addiction Research Foundation Clinical Institute Withdrawal Assessment for Alcohol|718|718|718|0|1|0|0.9872074748502528|0.9830125240644612|
|3001582|Protein/Creatinine [Mass Ratio] in Urine|713|677|677|2|2|36|0.9873085729485878|0.9835224345552104|
|3016407|Fibrinogen [Mass/volume] in Platelet poor plasma by Coagulation assay|706|0|0|1|3|698|0.9874086784989726|1|
|3001024|Left glasses lens prescription Cylinder far|705|0|0|1|1|0|0.9875086422567931|1|
|3000799|Right glasses lens prescription Axis far|703|0|0|1|1|0|0.9876083224294852|1|
|3021247|Left glasses lens prescription Axis far|703|0|0|1|1|0|0.9877080026021772|1|
|3005325|Right glasses lens prescription Cylinder far|701|0|0|1|1|0|0.9878073991897406|1|
|3017501|Neutrophils [#/volume] in Blood by Manual count|687|0|0|1|1|496|0.987904810681404|1|
|3012501|Base excess in Blood by calculation|682|0|0|1|1|0|0.9880015132102461|1|
|3001405|CD3+CD8+ (T8 suppressor) cells [#/volume] in Blood|679|1|1|3|2|574|0.9880977903613952|0.9999758978793146|
|3007449|CD3+CD8+ (T8 suppressor) cells/cells in Blood|678|0|0|1|2|574|0.9881939257199801|1|
|3001802|Microalbumin/Creatinine [Mass Ratio] in Urine|664|0|0|1|1|52|0.988288075982665|1|
|3027484|Hemoglobin [Mass/volume] in Blood by calculation|654|0|0|1|1|632|0.9883808083197071|1|
|3030091|pH of Blood adjusted to patient's actual temperature|645|645|645|0|1|626|0.9884722645236705|0.9840082429252743|
|3033203|Carbon dioxide [Partial pressure] adjusted to patient's actual temperature in Blood|645|0|0|1|1|626|0.9885637207276341|1|
|3014094|Carbon dioxide, total [Moles/volume] in Blood|644|344|344|2|2|310|0.9886550351390333|0.9906988409892715|
|3006576|Bicarbonate [Moles/volume] in Blood|644|0|0|1|1|625|0.9887463495504325|1|
|3011367|Oxygen saturation Calculated from oxygen partial pressure in Blood|642|0|0|1|1|492|0.9888373803767031|1|
|3027273|Bicarbonate [Moles/volume] in Venous blood|624|0|0|2|3|568|0.9889258589368166|1|
|3028026|IgM [Mass/volume] in Serum or Plasma|622|0|0|1|2|588|0.9890140539118016|1|
|3002317|Cells Counted Total [#] in Blood|610|610|610|0|1|0|0.9891005473760152|0.9844676896008387|
|3015736|pH of Urine|608|608|608|0|3|608|0.9891867572551002|0.9849256298938602|
|40757349|CD3+CD4+ (T4 helper) cells/CD3+CD8+ (T8 suppressor cells) cells [# Ratio] in Blood|600|600|600|0|1|496|0.9892718327936708|0.9853775446567105|
|21490586|Blood temperature|569|338|0|1|2|0|0.9893525127627487|0.9914693556599311|
|3006792|LMW Heparin [Units/volume] in Platelet poor plasma by Chromogenic method|569|0|0|2|2|0|0.9894331927318266|1|
|36303797|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among non black population|561|6|6|1|1|0|0.9895127383603902|0.9997145405081329|
|3018229|Myelocytes/Leukocytes in Blood by Manual count|559|0|0|1|2|2|0.9895920004038252|1|
|3017594|Tidal volume.spontaneous --on ventilator|559|0|0|1|1|0|0.9896712624472602|1|
|36306178|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (CKD-EPI)/1.73 sq M among black population|557|2|2|1|1|0|0.9897502409055667|0.9998877745005589|
|3005785|Creatine kinase.MB [Mass/volume] in Serum or Plasma|557|0|0|1|3|516|0.9898292193638731|1|
|1175625|Breath rate spontaneous|546|0|0|1|1|0|0.9899066381039725|1|
|40763791|Oxygen content in Venous blood by calculation|544|0|0|1|2|0|0.9899837732589433|1|
|3045462|Protein/Creatinine [Ratio] in Urine|542|542|542|0|2|360|0.9900606248287854|0.9857857743258185|
|3004248|Sex hormone binding globulin [Moles/volume] in Serum or Plasma|541|1|1|2|2|501|0.9901373346060633|0.9999314595943011|
|3037072|Urobilinogen [Mass/volume] in Urine by Test strip|525|0|0|1|1|525|0.9902117757023128|1|
|40763528|Reticulocytes [#/volume] in Blood by Automated count|524|0|0|3|2|200|0.9902860750059979|1|
|3025285|Estradiol (E2) [Mass/volume] in Serum or Plasma|523|1|1|1|3|30|0.9903602325171186|0.9999412510808294|
|3000330|Specific gravity of Urine by Test strip|517|517|517|0|1|472|0.9904335392728537|0.9865736123957207|
|36304439|Pressure.plateau Respiratory system airway|515|0|0|1|1|0|0.9905065624434602|1|
|21490583|Compliance.static Lung|509|200|200|1|1|0|0.990578734858681|0.9954334013213988|
|3034703|Diastolic blood pressure--sitting|506|49|49|1|1|0|0.990650481896209|0.9982812175186264|
|4221102|Cardiac output|504|0|0|1|1|0|0.9907219453486084|1|
|3038999|pH of Venous blood adjusted to patient's actual temperature|499|499|499|0|1|459|0.9907926998381863|0.9869494548401577|
|3004529|Oxygen [Partial pressure] adjusted to patient's actual temperature in Venous blood|498|0|0|1|1|458|0.9908633125352|1|
|3007628|Bicarbonate [Moles/volume] standard in Venous blood|498|0|0|1|1|451|0.9909339252322137|1|
|3009682|Cortisol [Mass/volume] in Serum or Plasma|485|0|0|1|2|174|0.9910026946258916|1|
|3026925|Triiodothyronine (T3) Free [Mass/volume] in Serum or Plasma|478|0|0|1|3|474|0.9910704714716196|1|
|3009306|Alpha-1-Fetoprotein [Mass/volume] in Serum or Plasma|457|0|0|1|2|453|0.9911352706734977|1|
|3018586|Systolic blood pressure--sitting|457|0|0|1|1|0|0.9912000698753757|1|
|3023725|Urinary bladder Volume by derived by EMP (US)|456|0|0|1|1|0|0.9912647272846894|1|
|3021614|Rheumatoid factor [Units/volume] in Serum or Plasma|455|0|0|1|3|412|0.9913292429014389|1|
|3029187|Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma|452|0|0|1|1|410|0.9913933331404955|1|
|3016750|Collection duration of Urine|449|0|0|2|3|282|0.9914569980018592|1|
|3044331|Calcium.ionized [Moles/volume] in Arterial blood|448|0|0|1|2|438|0.9915205210706587|1|
|3017766|Complement C4 [Mass/volume] in Serum or Plasma|443|1|1|1|3|292|0.9915833351766367|0.9999969872349144|
|21493446|Residual volume/Total capacity --pre bronchodilation|438|438|438|0|1|0|0.9916454403197933|0.9876115099677333|
|3000348|Leukocyte esterase [Presence] in Urine by Test strip|431|431|3|0|1|0|0.9917065529149999|0.987936135405714|
|3000666|Metamyelocytes/Leukocytes in Blood by Manual count|428|0|0|1|2|2|0.9917672401325136|1|
|3010742|Negative inspiratory pressure setting Ventilator|425|0|0|1|1|0|0.9918275019723346|1|
|4208254|Cardiac index|424|235|235|1|1|0|0.9918876220195912|0.9941175761702333|
|3003785|Carcinoembryonic Ag [Mass/volume] in Serum or Plasma|422|0|0|2|3|215|0.9919474584817193|1|
|3015183|Erythrocyte sedimentation rate [Velocity] in Red Blood Cells|420|0|0|1|2|286|0.9920070113587187|1|
|3016771|Amylase [Enzymatic activity/volume] in Serum or Plasma|418|0|0|1|3|379|0.9920662806505897|1|
|3029859|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Cystatin C-based formula/1.73 sq M|417|0|0|2|1|0|0.9921254081498962|1|
|3039426|Oxygen saturation Calculated from oxygen partial pressure in Arterial blood|406|0|0|1|1|399|0.9921829759309958|1|
|3017925|Prealbumin [Mass/volume] in Serum or Plasma by Immunoassay|402|0|0|1|2|402|0.9922399765418382|1|
|3049536|25-hydroxyvitamin D2 [Mass/volume] in Serum or Plasma|400|0|0|1|1|0|0.992296693567552|1|
|4090192|Fluid output|397|342|342|1|1|0|0.9923529852155729|0.9912147770101922|
|3011163|Cholesterol.total/Cholesterol in HDL [Mass Ratio] in Serum or Plasma|389|5|1|3|1|100|0.9924081425230796|0.9997371362462755|
|3019812|Kappa light chains [Mass/volume] in Serum or Plasma|384|0|0|1|1|384|0.9924625908677648|1|
|3004640|Lambda light chains [Mass/volume] in Serum or Plasma|384|0|0|1|1|384|0.99251703921245|1|
|3037663|Carbon dioxide, total [Moles/volume] in Arterial blood by calculation|384|0|0|1|1|362|0.9925714875571353|1|
|3007124|Reticulocytes/Erythrocytes in Blood by Automated count|381|0|0|1|2|380|0.9926255105241277|1|
|21490855|PEEP Respiratory system --on ventilator|380|0|0|1|1|0|0.9926793916985558|1|
|3024386|Platelet [Entitic mean volume] in Blood by Rees-Ecker|375|0|0|1|1|375|0.9927325639101625|1|
|3007778|Kappa light chains/Lambda light chains [Mass Ratio] in Serum|374|0|0|1|1|374|0.9927855943292049|1|
|3023520|Reticulocytes [#/volume] in Blood|372|0|0|3|2|60|0.9928383411631188|1|
|3011505|FEV1/FVC|368|360|360|1|1|0|0.9928905208267754|0.9890877648597106|
|40766800|Mycobacterium tuberculosis stimulated gamma interferon release by CD4+ T-cells [Units/volume] corrected for background in Blood|367|0|0|1|1|0|0.9929425586978678|1|
|3018572|Chloride [Moles/volume] in Blood|367|0|0|2|2|365|0.9929945965689603|1|
|36305335|Mycobacterium tuberculosis stimulated gamma interferon release by CD4+ and CD8+ T-cells [Units/volume] corrected for background in Blood|366|0|0|1|1|0|0.9930464926474883|1|
|3051714|Fibrin D-dimer FEU [Mass/volume] in Platelet poor plasma|365|0|0|2|2|365|0.9930982469334522|1|
|3031248|Chloride [Moles/volume] in Arterial blood|363|0|0|1|1|363|0.9931497176342875|1|
|3010340|Triiodothyronine (T3) [Mass/volume] in Serum or Plasma|361|0|0|2|3|350|0.9932009047499942|1|
|42868460|FEF 25-75% Predicted|360|360|360|0|1|0|0.9932519500731366|0.9893589137174207|
|3037879|Forced vital capacity [Volume] Respiratory system --pre bronchodilation|360|360|360|0|1|0|0.993302995396279|0.9896300625751309|
|3011417|Gas flow FEV 25%-75%|360|360|360|0|1|0|0.9933540407194215|0.9901723602905511|
|4194399|Elderly at risk rating scale|355|355|355|0|1|0|0.9934043770797424|0.9904397431919041|
|3013308|Fluid intake Measured|346|0|0|1|1|0|0.9934534373069849|1|
|3043722|Hyaline casts [#/area] in Urine sediment by Automated count|344|122|122|1|2|2|0.9935022139490988|0.9972207242084713|
|3018366|Fluid output total Measured|343|343|343|0|1|0|0.9935508487986483|0.9909571855953676|
|3032971|Troponin I.cardiac [Mass/volume] in Serum or Plasma by Detection limit <= 0.01 ng/mL|343|0|0|1|1|343|0.993599483648198|1|
|3019762|Thyrotropin [Units/volume] in Serum or Plasma by Detection limit <= 0.05 mIU/L|341|0|0|1|1|341|0.9936478349126189|1|
|4231869|Stroke volume|336|0|0|1|1|0|0.9936954772142185|1|
|3006473|Urobilinogen [Units/volume] in Urine by Test strip|330|309|217|1|1|135|0.9937422687604324|0.9926887723283553|
|3039000|Anion gap in Blood by calculation|330|0|0|2|2|328|0.9937890603066463|1|
|40766814|Six minute walk test|325|325|0|1|1|0|0.9938351428900387|0.9922120022535483|
|3008939|Band form neutrophils [#/volume] in Blood by Manual count|323|0|0|1|1|270|0.9938809418883027|1|
|3023323|Follitropin [Units/volume] in Serum or Plasma|322|44|0|2|3|38|0.9939265990940023|0.9983828983402677|
|3004295|Urea nitrogen [Mass/volume] in Blood|322|0|0|1|2|322|0.9939722562997019|1|
|3018251|Fasting glucose [Moles/volume] in Serum or Plasma|321|0|0|1|1|321|0.9940177717128371|1|
|3043954|Creatinine in dialysis fluid/Creatinine in serum or plasma|321|0|0|1|1|321|0.9940632871259725|1|
|3049133|Carbon dioxide, total [Moles/volume] in Venous blood by calculation|310|0|0|1|1|0|0.9941072428209007|1|
|3046948|Albumin/Globulin [Mass Ratio] in Serum or Plasma by Electrophoresis|297|297|296|0|1|0|0.9941493552124931|0.9929124701359661|
|1617299|Diffusion capacity.carbon monoxide/Predicted|288|288|288|0|1|0|0.9941901914710071|0.9931293892221342|
|3008905|Diffusion capacity.carbon monoxide|288|288|288|0|1|0|0.994231027729521|0.9933463083083023|
|3016049|Testosterone Free [Mass/volume] in Serum or Plasma|288|2|2|2|2|279|0.994271863988035|0.9998802425878447|
|3028833|Bilirubin.total [Mass/volume] in Blood|283|223|223|1|1|14|0.9943119912837275|0.9946304994260683|
|4303572|Systemic vascular resistance|281|281|281|0|1|0|0.9943518349942915|0.9935579550555704|
|3016991|Thyroxine (T4) [Mass/volume] in Serum or Plasma|281|3|3|1|3|278|0.9943916787048553|0.9998621659973307|
|3022509|Hyaline casts [#/area] in Urine sediment by Microscopy low power field|278|0|0|1|1|0|0.9944310970377265|1|
|3021337|Troponin I.cardiac [Mass/volume] in Serum or Plasma|274|0|0|1|3|273|0.9944699482003404|1|
|3000620|Complement C3 [Mass/volume] in Serum or Plasma|270|1|1|1|3|144|0.9945082321926972|0.9999713787316862|
|3008364|Apolipoprotein A-I [Mass/volume] in Serum or Plasma|267|1|1|1|1|165|0.9945460908073612|0.9999917148960145|
|3040168|Immature granulocytes [#/volume] in Blood|266|3|3|2|1|155|0.9945838076294609|0.9998237532424884|
|3051593|INR in Capillary blood by Coagulation assay|263|263|263|0|2|142|0.9946210990738676|0.9937560443599531|
|3009201|Thyrotropin [Units/volume] in Serum or Plasma|263|0|0|3|2|226|0.9946583905182745|1|
|3012920|Ethanol [Mass/volume] in Serum or Plasma|263|0|0|1|2|5|0.9946956819626813|1|
|3009214|Lutropin [Units/volume] in Serum or Plasma|261|33|2|2|3|44|0.9947326898219596|0.9987173152647768|
|3964677|Oxygen/Total gas setting ECMO device|251|0|0|1|1|0|0.994768279755595|1|
|3030367|Cyclic citrullinated peptide IgG Ab [Units/volume] in Serum or Plasma|251|0|0|2|2|190|0.9948038696892304|1|
|3027653|Mycophenolate [Mass/volume] in Serum or Plasma|244|0|0|1|1|0|0.9948384670749159|1|
|40760765|Tidal volume.spontaneous minimum setting Ventilator alarm|244|0|0|1|1|0|0.9948730644606012|1|
|3005715|Vancomycin [Mass/volume] in Serum or Plasma|241|0|0|1|2|161|0.9949072364685938|1|
|3004267|Output.colostomy [Volume]|239|0|0|1|1|0|0.9949411248914578|1|
|36304157|Cystatin C and Glomerular filtration rate by Cystatin C-based formula panel - Serum or Plasma|234|0|0|1|1|234|0.9949743043515004|1|
|4081061|Systemic vascular resistance index|232|232|232|0|1|0|0.9950072002264143|0.994292316545202|
|3032080|INR in Blood by Coagulation assay|226|226|214|0|3|12|0.9950392453459427|0.9944625377725422|
|3011087|Output.stool [Volume]|225|0|0|1|1|0|0.9950711486729067|1|
|3020876|Protein [Mass/time] in 24 hour Urine|223|2|0|3|3|135|0.9951027684147421|0.9998907872656445|
|3018920|Vancomycin [Mass/volume] in Serum or Plasma --trough|223|0|0|1|2|208|0.9951343881565775|1|
|3046538|Tissue transglutaminase IgA Ab [Units/volume] in Serum by Immunoassay|222|37|0|2|2|222|0.9951658661058487|0.9985591450977793|
|3001784|Prostate Specific Ag Free/Prostate specific Ag.total in Serum or Plasma|221|0|0|2|3|2|0.9951972022625556|1|
|3014498|Breath rate minimum setting Ventilator alarm|221|0|0|1|1|0|0.9952285384192625|1|
|3022914|Cancer Ag 19-9 [Units/volume] in Serum or Plasma|220|0|0|1|2|201|0.9952597327834051|1|
|1002029|Residual volume/Predicted by Plethysmograph body box|219|219|219|0|1|0|0.9952907853549834|0.9947954483145086|
|36303283|Total lung capacity measured/predicted by Plethysmograph body box|219|219|219|0|1|0|0.9953218379265617|0.9949603972029489|
|21493126|Residual volume --pre bronchodilation|219|219|219|0|1|0|0.99535289049814|0.9951253460913893|
|3007591|Band form neutrophils/Leukocytes in Blood by Manual count|219|0|0|1|2|219|0.9953839430697182|1|
|3005013|Prostate Specific Ag Free [Mass/volume] in Serum or Plasma|219|0|0|1|3|0|0.9954149956412965|1|
|3016267|Urine output by in and out urethral catheter|217|0|0|1|1|0|0.9954457646277463|1|
|3049555|Testosterone [Mass/volume] in Serum or Plasma by Detection limit <= 1.0 ng/dL|216|0|0|1|1|216|0.9954763918216317|1|
|3051014|Leukocytes [#/area] in Urine sediment by Automated count|213|209|48|1|1|4|0.9955065936378243|0.9952827630671154|
|3025684|Heparin unfractionated [Units/volume] in Platelet poor plasma by Chromogenic method|211|0|0|1|1|0|0.9955365118688884|1|
|3047169|Lambda light chains.free [Mass/volume] in Serum or Plasma|210|0|0|1|2|190|0.9955662883073881|1|
|3034860|Kappa light chains.free [Mass/volume] in Serum|210|0|0|1|2|190|0.9955960647458879|1|
|3009413|Insulin [Units/volume] in Serum or Plasma --fasting|210|0|0|2|1|210|0.9956258411843876|1|
|3021748|Pressure minimum setting Ventilator alarm|209|0|0|1|1|0|0.9956554758303231|1|
|3027401|Testosterone Free/Testosterone.total in Serum or Plasma|207|0|0|1|2|105|0.9956848268911299|1|
|3053209|Kappa light chains.free/Lambda light chains.free [Mass Ratio] in Serum|205|187|187|1|2|185|0.9957138943668082|0.9957203671958086|
|3030366|Cystatin C [Mass/volume] in Serum or Plasma|204|0|0|1|1|204|0.9957428200499223|1|
|3003181|Sodium [Moles/volume] in Urine|199|5|5|1|2|3|0.995771036770215|0.9997559660280609|
|4090200|Parenteral fluid input|194|35|35|1|1|0|0.9957985445276861|0.9986668514495919|
|3013731|Hepatitis B virus surface Ab [Units/volume] in Serum or Plasma by Immunoassay|191|37|0|1|2|0|0.9958256269074645|0.9985870131748217|
|3026285|Alpha 1 antitrypsin [Mass/volume] in Serum or Plasma|183|0|0|1|2|182|0.9958515749467285|1|
|3010084|C peptide [Mass/volume] in Serum or Plasma|181|0|0|1|2|175|0.995877239400864|1|
|42527121|Inspired minute Volume during Mechanical ventilation|180|0|0|1|1|0|0.9959027620624352|1|
|3017963|Variant lymphocytes [Presence] in Blood by Automated count|179|0|0|1|1|0|0.9959281429314422|1|
|3037106|Fluid intake total Measured|178|178|178|0|1|0|0.9959533820078847|0.9958544352421209|
|3013247|Albumin in CSF/Albumin in Serum or Plasma|178|0|0|2|2|178|0.9959786210843274|1|
|3022493|Free Hemoglobin [Mass/volume] in Plasma|178|0|0|1|1|178|0.99600386016077|1|
|3046549|Lipoprotein.beta.subparticle.small [Moles/volume] in Serum or Plasma|178|0|0|1|1|0|0.9960290992372127|1|
|3014646|Fractional oxyhemoglobin in Blood|175|0|0|1|1|0|0.9960539129359625|1|
|3012388|pH of Mixed venous blood|173|173|173|0|1|0|0.9960784430495837|0.9961180521871168|
|3012565|Volume of 24 hour Urine|173|10|0|1|1|47|0.996102973163205|0.9994177831471946|
|3038071|Oxygen [Partial pressure] in Mixed venous blood|173|0|0|1|1|0|0.9961275032768262|1|
|3021513|Carbon dioxide [Partial pressure] in Mixed venous blood|173|0|0|1|1|0|0.9961520333904473|1|
|3025817|Bicarbonate [Moles/volume] in Mixed venous blood|173|0|0|1|1|0|0.9961765635040686|1|
|40767502|Oxygen content in Mixed venous blood by calculation|173|0|0|1|1|0|0.9962010936176898|1|
|3010719|Protein in CSF/Protein in serum|172|0|0|1|1|172|0.9962254819387467|1|
|3023001|Base excess in Mixed venous blood by calculation|172|0|0|1|1|0|0.9962498702598037|1|
|3013171|Leukocyte esterase [Units/volume] in Urine|171|171|0|0|1|0|0.9962741167882964|0.9962468478945291|
|3008286|Lipoprotein.beta.subparticle [Entitic length] in Serum or Plasma|171|1|0|1|1|0|0.996298363316789|0.9999480298022723|
|40757565|Lipoprotein.beta.subparticle [Moles/volume] in Serum or Plasma|170|3|3|1|1|0|0.9963224680527173|0.9998599064235164|
|3037110|Fasting glucose [Mass/volume] in Serum or Plasma|170|2|2|1|3|161|0.9963465727886457|0.9998968127958159|
|4354266|Actual blood loss|169|0|0|1|1|0|0.9963705357320097|1|
|21493943|Blood loss [Volume] Measured|169|0|0|1|1|0|0.9963944986753739|1|
|3041952|Clot initiation [Time] in Blood by Thromboelastography|167|15|0|1|2|167|0.9964181780336093|0.999246808728583|
|3032771|Lipoprotein.alpha [Moles/volume] in Serum or Plasma|167|1|1|1|1|0|0.9964418573918449|0.9999487829935436|
|3016426|Methylmalonate [Moles/volume] in Serum or Plasma|167|0|0|2|2|166|0.9964655367500804|1|
|3002173|Hemoglobin [Mass/volume] in Arterial blood|165|0|0|1|2|165|0.9964889325231874|1|
|3018465|Oxygen saturation in Mixed venous blood|164|0|0|1|1|0|0.99651218650373|1|
|3041354|Potassium [Moles/volume] in Venous blood|160|0|0|1|2|154|0.9965348733140155|1|
|3011912|Apolipoprotein B/Apolipoprotein A-I [Mass Ratio] in Serum or Plasma|158|158|158|0|1|0|0.9965572765391725|0.996365852115413|
|3034387|Apolipoprotein B-100 [Mass/volume] in Serum or Plasma|157|0|0|1|1|157|0.9965795379717651|1|
|3035856|Systolic blood pressure--standing|157|0|0|1|1|0|0.9966017994043578|1|
|3048402|Erythrocytes [#/area] in Urine sediment by Automated count|156|154|153|1|1|2|0.9966239190443862|0.9966008477920951|
|3004775|Volume in Urine collected for unspecified duration|155|0|0|3|2|0|0.9966458968918502|1|
|3045440|Sjogrens syndrome-A extractable nuclear Ab [Units/volume] in Serum by Immunoassay|154|0|0|2|2|139|0.99666773294675|1|
|3019962|Diastolic blood pressure--standing|154|0|0|1|1|0|0.9966895690016498|1|
|3009966|Cholesterol in LDL [Mass/volume] in Serum or Plasma by Direct assay|153|0|0|1|1|69|0.9967112632639854|1|
|3013702|Oxygen [Partial pressure] adjusted to patient's actual temperature in Blood|153|0|0|1|1|152|0.996732957526321|1|
|40769408|Clot angle in Blood by Thromboelastography|152|0|0|1|1|152|0.9967545099960922|1|
|3000581|Complement C3c [Mass/volume] in Serum or Plasma|152|0|0|1|1|136|0.9967760624658635|1|
|21490826|Nitrogen dioxide [VFr/PPres] Gas delivery system|151|151|0|1|1|0|0.9967974731430704|0.9967145796740791|
|3041078|Clot formation [Time] in Blood by Thromboelastography|149|0|0|1|1|149|0.9968186002351488|1|
|3016724|Homocysteine [Moles/volume] in Serum or Plasma|145|0|0|1|2|138|0.99683916015697|1|
|3029713|Protein.monoclonal band 1 [Mass/volume] in Serum or Plasma by Electrophoresis|143|0|0|1|1|0|0.9968594364936627|1|
|3009395|Systolic blood pressure--supine|141|0|0|1|1|0|0.9968794292452269|1|
|3040808|Maximum clot firmness [Length] in Blood by Thromboelastography|140|0|0|1|1|140|0.9968992802042267|1|
|1989527|Pacemaker rate|139|139|0|1|1|0|0.9969189893706623|0.9969299923777043|
|3024980|IgG subclass 4 [Mass/volume] in Serum|139|0|0|1|2|139|0.9969386985370977|1|
|3008615|Choriogonadotropin.beta subunit [Units/volume] in Serum or Plasma by Immunoassay (EIA) 3rd IS|139|0|0|1|1|139|0.9969584077035333|1|
|3006135|Nucleated erythrocytes [#/volume] in Blood by Manual count|139|0|0|1|1|0|0.9969781168699688|1|
|3022756|Ceruloplasmin [Mass/volume] in Serum or Plasma|138|0|0|2|2|135|0.99699768424384|1|
|3027238|Thyroperoxidase Ab [Units/volume] in Serum or Plasma|137|0|0|2|2|128|0.9970171098251471|1|
|3043359|Sjogrens syndrome-B extractable nuclear Ab [Units/volume] in Serum by Immunoassay|136|0|0|1|1|136|0.9970363936138897|1|
|3013940|Diastolic blood pressure--supine|136|0|0|1|1|0|0.9970556774026325|1|
|3016604|IgE [Mass/volume] in Serum|134|0|0|2|1|134|0.9970746776062466|1|
|42528496|Gas delivery system Fresh gas.air flow setting [Flow]|133|0|0|1|1|0|0.9970935360172964|1|
|3015586|Segmented neutrophils [#/volume] in Blood|132|0|0|1|1|132|0.997112252635782|1|
|3048530|Fibrin D-dimer DDU [Mass/volume] in Platelet poor plasma|131|0|0|1|1|0|0.9971308274617032|1|
|3013770|Testosterone [Mass/volume] adjusted for sex hormone binding globulin in Serum or Plasma|130|0|0|1|1|130|0.9971492604950603|1|
|3028192|IgG subclass 2 [Mass/volume] in Serum|128|0|0|1|2|128|0.9971674099432887|1|
|40765014|Lipoprotein.alpha [Entitic length] in Serum or Plasma|128|0|0|1|1|0|0.9971855593915171|1|
|40765015|Lipoprotein.pre-beta [Entitic length] in Serum or Plasma|128|0|0|1|1|0|0.9972037088397455|1|
|3027135|IgG subclass 1 [Mass/volume] in Serum|128|0|0|1|2|128|0.9972218582879739|1|
|3046076|Lipoprotein.alpha.subparticle.large [Moles/volume] in Serum or Plasma|128|0|0|2|1|0|0.9972400077362024|1|
|3024139|IgG subclass 3 [Mass/volume] in Serum|128|0|0|1|2|128|0.9972581571844307|1|
|3053283|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine-based formula (MDRD)/1.73 sq M among black population|127|8|8|1|1|0|0.9972761648400948|0.9995804724618207|
|3026782|Osmolality of Urine|127|1|0|2|2|122|0.997294172495759|0.9999465234197293|
|3041473|Sodium [Moles/volume] in Venous blood|127|0|0|1|2|121|0.9973121801514231|1|
|3046528|Lipoprotein.pre-beta.subparticle.large [Moles/volume] in Serum or Plasma|127|0|0|1|1|0|0.9973301878070873|1|
|3046279|Procalcitonin [Mass/volume] in Serum or Plasma|125|0|0|1|3|120|0.9973479118776228|1|
|3021421|Base excess standard in Arterial blood by calculation|125|0|0|1|1|118|0.9973656359481584|1|
|3033408|Glucose [Mass/volume] in Venous blood|124|0|0|1|2|118|0.9973832182261296|1|
|3016311|Creatine kinase.MB/Creatine kinase.total in Serum or Plasma|124|0|0|1|1|0|0.997400800504101|1|
|3032493|dRVVT/dRVVT W excess phospholipid (screen to confirm ratio)|123|9|9|2|1|0|0.9974182409895079|0.9995036469521362|
|3006361|Follitropin [Units/volume] in Serum or Plasma by 2nd IRP|123|1|1|1|2|0|0.9974356814749149|0.9999420042721009|
|3041253|Oxygen saturation Calculated from oxygen partial pressure in Venous blood|122|0|0|1|1|20|0.9974529801677576|1|
|3012336|Haptoglobin [Mass/volume] in Serum or Plasma|122|0|0|1|3|119|0.9974702788606004|1|
|3025547|Thyroglobulin Ab [Units/volume] in Serum or Plasma|121|41|41|2|2|80|0.9974874357608787|0.9984454132157953|
|3037551|Cancer Ag 125 [Units/volume] in Serum or Plasma|120|0|0|1|2|118|0.9975044508685929|1|
|3011958|Ammonia [Moles/volume] in Plasma|116|0|0|1|2|115|0.9975208988060499|1|
|3004239|Creatinine [Mass/time] in 24 hour Urine|115|28|0|2|2|106|0.9975372049509426|0.9988257748078609|
|3035167|Continuous positive airway pressure Respiratory system|113|0|0|1|1|0|0.9975532275107067|1|
|42869527|Mitogen stimulated gamma interferon [Units/volume] in Blood|113|0|0|1|1|0|0.9975692500704709|1|
|3052023|Hepatitis C virus Ab Signal/Cutoff in Serum or Plasma by Immunoassay|112|18|18|1|1|94|0.9975851308376708|0.9991609449236415|
|3027491|Helicobacter pylori IgG Ab [Units/volume] in Serum by Immunoassay|112|0|0|1|1|112|0.9976010116048706|1|
|3024226|Microscopic observation [Identifier] in Specimen by Other stain|111|111|111|0|1|0|0.9976167505795062|0.9973043284395986|
|3013273|Insulin-like growth factor-I [Mass/volume] in Serum or Plasma|111|0|0|1|2|111|0.9976324895541417|1|
|3004119|Hemoglobin [Mass/volume] in Venous blood|110|0|0|1|3|110|0.9976480867362131|1|
|3022533|CD3 cells/cells in Blood|110|0|0|1|2|109|0.9976636839182844|1|
|3003540|Lymphocytes/Leukocytes in Body fluid by Manual count|110|0|0|1|2|0|0.9976792811003556|1|
|3031987|Alpha-1-Fetoprotein L3/Alpha-1-fetoprotein.total in Serum or Plasma|109|0|0|1|1|109|0.9976947364898627|1|
|3010375|cycloSPORINE [Mass/volume] in Blood|109|0|0|1|1|0|0.9977101918793697|1|
|3011412|CD3 cells [#/volume] in Blood|109|0|0|3|2|108|0.9977256472688767|1|
|3037081|Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma by With P-5'-P|106|0|0|2|1|106|0.9977406772806908|1|
|3023230|Hematocrit [Volume Fraction] of Arterial blood by calculation|105|105|0|0|1|105|0.9977555654999407|0.9973834135230973|
|40761479|Ethyl glucuronide [Mass/volume] in Urine by Confirmatory method|105|0|0|1|1|0|0.9977704537191906|1|
|40761526|Ethyl sulfate [Mass/volume] in Urine by Confirmatory method|105|0|0|1|1|0|0.9977853419384405|1|
|3017394|Zinc [Mass/volume] in Serum or Plasma|105|0|0|1|2|105|0.9978002301576904|1|
|3046071|Choriogonadotropin.intact+Beta subunit [Units/volume] in Serum or Plasma|105|0|0|1|2|1|0.9978151183769403|1|
|40763913|Albumin [Mass/volume] in Serum or Plasma by Bromocresol purple (BCP) dye binding method|104|0|0|1|1|104|0.9978298648036258|1|
|3035486|Pain severity Wong-Baker FACES pain rating scale|101|101|101|0|1|0|0.9978441858526186|0.997613890052151|
|3005755|Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma by With P-5'-P|101|0|0|2|1|101|0.9978585069016113|1|
|3013201|Beta-2-Microglobulin [Mass/volume] in Serum or Plasma|99|0|0|2|3|90|0.9978725443654755|1|
|44817130|Procalcitonin [Mass/volume] in Serum or Plasma by Immunoassay|99|0|0|1|1|88|0.9978865818293396|1|
|3006588|Cancer Ag 15-3 [Units/volume] in Serum or Plasma|99|0|0|1|1|84|0.9979006192932037|1|
|3008295|Osmolality of Serum or Plasma|98|2|0|2|2|95|0.9979145149645037|0.9998772298227591|
|3011335|Digoxin [Mass/volume] in Serum or Plasma|95|0|0|1|3|88|0.9979279852581107|1|
|3008392|Creatinine/Protein [Mass Ratio] in Urine|94|94|94|0|1|0|0.9979413137591534|0.9976846900316642|
|3001349|Creatinine [Mass/volume] in 24 hour Urine|94|0|0|1|1|56|0.9979546422601961|1|
|3005322|IgE [Units/volume] in Serum or Plasma|93|0|0|2|1|48|0.9979678289686746|1|
|3011587|Promyelocytes/Leukocytes in Blood by Manual count|93|0|0|1|2|0|0.997981015677153|1|
|40769405|Clot Lysis [Length fraction] in Blood by Thromboelastography --30 minutes post maximum clot amplitude|92|0|0|1|1|92|0.9979940605930673|1|
|3036535|Thyroglobulin [Mass/volume] in Serum or Plasma|91|0|0|1|2|89|0.9980069637164172|1|
|3013861|Lipoprotein a [Mass/volume] in Serum or Plasma|90|0|0|2|1|0|0.9980197250472027|1|
|3029483|DNA double strand Ab [Units/volume] in Serum by Immunoassay|90|0|0|1|1|73|0.9980324863779884|1|
|3019839|Fructosamine [Moles/volume] in Serum or Plasma|89|0|0|1|2|89|0.9980451059162097|1|
|3001490|Nucleated erythrocytes [#/volume] in Blood|86|0|0|1|1|0|0.9980573000767381|1|
|40757337|Cytomegalovirus DNA [Log #/volume] (viral load) in Serum or Plasma by NAA with probe detection|84|0|0|2|1|0|0.998069210652138|1|
|37116693|Stroke volume variation|84|0|0|1|1|0|0.9980811212275379|1|
|3015481|Prolactin [Mass/volume] in Serum or Plasma by Immunoassay|83|0|0|1|1|49|0.9980928900103735|1|
|3038792|Ribonucleoprotein extractable nuclear Ab [Units/volume] in Serum by Immunoassay|82|0|0|1|1|82|0.9981045170006448|1|
|3044620|Acarboxyprothrombin [Mass/volume] in Serum or Plasma|82|0|0|1|1|76|0.9981161439909162|1|
|3048689|Calprotectin [Mass/mass] in Stool|81|0|0|1|1|5|0.9981276291886233|1|
|3024126|Macrophages/Leukocytes in Body fluid|80|0|0|1|2|0|0.998138972593766|1|
|1616808|Oxidants [Mass/volume] in Urine|80|0|0|1|1|80|0.9981503159989088|1|
|3037816|CD4+CD8+ cells/cells in Blood|78|78|78|0|1|78|0.998161375818923|0.9978744942320612|
|3013742|Prealbumin [Mass/volume] in Serum or Plasma|78|0|0|1|1|68|0.9981724356389371|1|
|43055510|Sirolimus [Mass/volume] in Plasma --trough|77|0|0|1|1|0|0.998183353666387|1|
|3023548|Base deficit in Arterial blood|75|0|0|1|1|75|0.9981939881087084|1|
|3016244|Insulin [Units/volume] in Serum or Plasma|73|1|1|2|2|64|0.9982043389659011|0.9999510425673579|
|3046664|Lipoprotein a [Moles/volume] in Serum or Plasma|73|0|0|1|1|0|0.9982146898230939|1|
|3016038|Potassium [Moles/volume] in Urine|72|1|1|1|2|1|0.9982248988877224|0.9999736383055005|
|3009041|Cardiolipin IgG Ab [Units/volume] in Serum by Immunoassay|71|26|0|3|2|45|0.9982349661597866|0.9988860301095742|
|3027144|Progesterone [Mass/volume] in Serum or Plasma|70|0|0|1|2|0|0.9982448916392865|1|
|3013135|Physical findings of Skin|69|69|69|0|1|0|0.9982546753262221|0.9979837069664167|
|3011337|Aldosterone [Mass/volume] in Serum or Plasma|68|0|0|1|2|0|0.9982643172205935|1|
|3024889|Methemoglobin/Hemoglobin.total in Venous blood|68|0|0|1|3|66|0.9982739591149649|1|
|3023500|Segmented neutrophils/Leukocytes in Body fluid by Manual count|67|0|0|1|1|0|0.9982834592167719|1|
|3026893|Collection duration of Specimen|66|0|0|2|1|0|0.9982928175260147|1|
|3003159|Erythrocytes [#/volume] in Body fluid by Automated count|65|0|0|2|2|0|0.9983020340426931|1|
|43533584|Insulin-like growth factor-I [Z-score] in Serum or Plasma|64|64|62|0|1|0|0.9983111087668074|0.9980816218317009|
|3050746|Hematocrit [Volume Fraction] of Blood by Estimated|64|0|0|1|1|64|0.9983201834909216|1|
|3019473|Protein [Mass/volume] in Cerebral spinal fluid|64|0|0|1|2|59|0.9983292582150358|1|
|3035855|Coccidioides immitis IgG Ab [Presence] in Serum by Immunoassay|64|0|0|1|1|0|0.99833833293915|1|
|3003191|Choriogonadotropin [Presence] in Serum or Plasma|64|0|0|1|1|64|0.9983474076632642|1|
|3022548|Glucose [Mass/volume] in Cerebral spinal fluid|64|0|0|1|2|59|0.9983564823873784|1|
|3009394|Coccidioides immitis IgM Ab [Presence] in Serum by Immunoassay|63|0|0|1|1|0|0.9983654153189283|1|
|3000504|BK virus DNA [Units/volume] (viral load) in Serum or Plasma by NAA with probe detection|63|0|0|1|2|18|0.9983743482504782|1|
|3015813|Cardiolipin IgM Ab [Units/volume] in Serum by Immunoassay|61|19|0|3|2|45|0.9983829975968996|0.9991195194037136|
|44786754|Tacrolimus [Mass/volume] in Blood by LC/MS/MS|60|0|0|2|1|0|0.9983915051507567|1|
|3035637|Corticotropin [Mass/volume] in Plasma|60|0|0|1|3|60|0.9984000127046138|1|
|3007733|Chloride [Moles/volume] in Urine|60|0|0|1|2|0|0.9984085202584708|1|
|1989192|Permanent pacemaker Ventricular stimulation setting|59|59|0|1|1|0|0.9984168860197636|0.9981260601167146|
|3042925|Actin smooth muscle IgG Ab [Units/volume] in Serum|59|0|0|1|1|59|0.9984252517810565|1|
|3007808|Renin [Enzymatic activity/volume] in Plasma|58|1|0|1|2|1|0.9984334757497849|0.9999668595840576|
|3016201|Valproate [Mass/volume] in Serum or Plasma|58|0|0|2|3|52|0.9984416997185134|1|
|3002109|Cholesterol in LDL/Cholesterol in HDL [Mass Ratio] in Serum or Plasma|58|0|0|3|1|57|0.998449923687242|1|
|3028717|Thiamine [Mass/volume] in Blood|58|0|0|1|1|57|0.9984581476559704|1|
|40771901|t(9;22)(q34.1;q11)(ABL1,BCR) b2a2+b3a2 fusion transcript/control transcript (International Scale) [# Ratio] in Blood or Tissue by Molecular genetics method|57|28|0|2|1|0|0.9984662298321346|0.9987835960966616|
|3000162|Prolactin [Mass/volume] in Serum or Plasma --baseline|57|0|0|1|1|0|0.9984743120082988|1|
|3004411|Monocytes/Leukocytes in Body fluid by Manual count|56|0|0|1|1|0|0.9984822523918988|1|
|3014102|Estradiol (E2).bioavailable [Mass/volume] in Serum or Plasma|56|0|0|1|1|0|0.9984901927754987|1|
|43055120|Cytomegalovirus DNA [Units/volume] (viral load) in Serum or Plasma by NAA with probe detection|56|0|0|1|2|29|0.9984981331590986|1|
|3024666|Lithium [Moles/volume] in Serum or Plasma|56|0|0|2|3|55|0.9985060735426986|1|
|1988467|Initial screening NRS_2002|55|55|55|0|1|0|0.9985138721337342|0.9981674856366425|
|3045792|Smith extractable nuclear Ab [Units/volume] in Serum by Immunoassay|55|0|0|1|1|55|0.9985216707247698|1|
|3004809|Band form neutrophils/Leukocytes in Blood|55|0|0|1|1|55|0.9985294693158056|1|
|3038207|HIV 1 RNA [#/volume] (viral load) in Specimen by NAA with probe detection|54|2|0|1|2|0|0.9985371261142769|0.9998953064132731|
|3046034|DNA double strand IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|54|0|0|1|1|0|0.9985447829127482|1|
|1002411|Depression score|53|53|53|0|1|0|0.9985522979186553|0.9982074047740276|
|3021642|Sjogrens syndrome-A extractable nuclear Ab [Presence] in Serum by Immune diffusion (ID)|53|1|1|1|1|0|0.9985598129245624|0.9999525489499007|
|3000785|Sjogrens syndrome-B extractable nuclear Ab [Presence] in Serum by Immune diffusion (ID)|53|1|1|1|1|0|0.9985673279304694|0.9999781574531289|
|3010910|Erythrocytes [#/volume] in Body fluid|53|0|0|2|2|0|0.9985748429363765|1|
|3021009|Hemoglobin A2/Hemoglobin.total in Blood by Electrophoresis|52|0|0|1|1|52|0.9985822161497193|1|
|3023895|Varicella zoster virus IgG Ab [Units/volume] in Serum by Immunoassay|49|40|0|2|2|38|0.9985891639853692|0.998475540866652|
|3027126|Copper [Mass/volume] in Serum or Plasma|49|0|0|1|1|49|0.9985961118210193|1|
|3019947|Neutrophils/Leukocytes in Body fluid by Manual count|49|0|0|1|1|0|0.9986030596566692|1|
|3018747|Beta hydroxybutyrate [Mass/volume] in Serum or Plasma|49|0|0|2|1|0|0.9986100074923191|1|
|3966536|Testosterone Free [Mass/volume] in Serum or Plasma by Calculation|47|0|0|1|1|47|0.9986166717428405|1|
|3027180|Monocytes+Macrophages/Leukocytes in Body fluid by Manual count|47|0|0|1|1|0|0.9986233359933618|1|
|3022520|Coagulation factor VIII activated [Units/volume] in Platelet poor plasma by Coagulation assay|47|0|0|1|1|44|0.9986300002438833|1|
|40765016|Lipoprotein insulin resistance score in Serum or Plasma|46|46|46|0|1|0|0.9986365227018403|0.9983158643171116|
|3016228|CD19 cells/cells in Blood|46|22|0|1|1|43|0.9986430451597974|0.998970387531973|
|3021374|Sirolimus [Mass/volume] in Blood|46|0|0|1|2|8|0.9986495676177545|1|
|3019930|Urea nitrogen [Mass/volume] in Body fluid|46|0|0|1|1|0|0.9986560900757115|1|
|3010503|CD19 cells [#/volume] in Blood|46|0|0|1|1|43|0.9986626125336686|1|
|1988660|Permanent pacemaker Atrial stimulation setting|45|45|0|1|1|0|0.9986689931990614|0.9983497579243253|
|40484911|Mixed venous oxygen saturation|45|17|17|1|1|0|0.9986753738644543|0.9991737491752556|
|3011951|Aspergillus fumigatus IgE Ab [Units/volume] in Serum|45|0|0|1|1|0|0.9986817545298471|1|
|3010409|Erythrocytes [#/volume] in Cerebral spinal fluid by Manual count|45|0|0|1|1|0|0.9986881351952398|1|
|3002617|Acetaminophen [Mass/volume] in Serum or Plasma|44|0|0|1|2|43|0.9986943740680684|1|
|3038205|Alternaria alternata IgE Ab [Units/volume] in Serum|44|0|0|1|1|0|0.9987006129408968|1|
|3022174|Leukocytes [#/volume] in Body fluid|44|0|0|1|1|44|0.9987068518137254|1|
|3022338|Retinol [Mass/volume] in Serum or Plasma|43|0|0|2|1|43|0.9987129488939896|1|
|3023430|Cat dander IgE Ab [Units/volume] in Serum|43|0|0|1|1|0|0.9987190459742539|1|
|3027953|Aldolase [Enzymatic activity/volume] in Serum or Plasma|43|0|0|1|2|40|0.9987251430545181|1|
|3014133|Dog dander IgE Ab [Units/volume] in Serum|43|0|0|1|1|0|0.9987312401347823|1|
|3048505|Hepatitis B virus DNA [log units/volume] (viral load) in Serum or Plasma by NAA with probe detection|43|0|0|1|1|0|0.9987373372150465|1|
|3015731|Bermuda grass IgE Ab [Units/volume] in Serum|43|0|0|1|1|0|0.9987434342953108|1|
|3038601|CD4 stimulated ATP immune response [Mass/volume] in Blood|42|42|0|0|1|0|0.9987493895830107|0.9984145323736672|
|3013750|Rubella virus IgG Ab [Presence] in Serum|42|1|1|2|2|11|0.9987553448707107|0.9999337191681154|
|3014480|Olive Pollen IgE Ab [Units/volume] in Serum|42|0|0|1|1|0|0.9987613001584107|1|
|3007757|White Elm IgE Ab [Units/volume] in Serum|42|0|0|1|1|0|0.9987672554461106|1|
|3051447|Retinyl palmitate [Mass/volume] in Serum or Plasma|42|0|0|1|1|42|0.9987732107338105|1|
|3022260|Johnson grass IgE Ab [Units/volume] in Serum|42|0|0|1|1|0|0.9987791660215105|1|
|3002187|Saltwort IgE Ab [Units/volume] in Serum|42|0|0|1|1|0|0.9987851213092105|1|
|3002527|Cottonwood IgE Ab [Units/volume] in Serum|41|0|0|1|1|0|0.9987909348043461|1|
|3003888|Timothy IgE Ab [Units/volume] in Serum|41|0|0|1|1|0|0.9987967482994817|1|
|3019420|Tryptase [Mass/volume] in Serum or Plasma|41|0|0|1|1|1|0.9988025617946175|1|
|3050479|Immature granulocytes/Leukocytes in Blood|41|0|0|1|1|0|0.9988083752897531|1|
|3028461|Complement total hemolytic CH50 [Units/volume] in Serum or Plasma|41|0|0|1|1|27|0.9988141887848888|1|
|3008401|Mugwort IgE Ab [Units/volume] in Serum|41|0|0|1|1|0|0.9988200022800244|1|
|40760954|Leukocytes [#/volume] in Body fluid by Automated count|41|0|0|1|1|0|0.99882581577516|1|
|3011965|Urea nitrogen [Mass/volume] in Urine|40|1|1|1|2|0|0.9988314874777314|0.9999292000204868|
|3007687|Calcium [Mass/time] in 24 hour Urine|40|1|1|1|2|27|0.9988371591803028|0.9999517957586294|
|3035569|Folate [Mass/volume] in Red Blood Cells|40|1|0|1|1|27|0.9988428308828743|0.9999623404364292|
|3015884|Dehydroepiandrosterone sulfate (DHEA-S) [Mass/volume] in Serum or Plasma|40|1|1|2|2|30|0.9988485025854457|0.999963846818972|
|3013784|Calcium.ionized [Moles/volume] in Serum or Plasma by Ion-selective membrane electrode (ISE)|40|0|0|1|1|40|0.998854174288017|1|
|3045331|Galactomannan Ag [Units/volume] in Serum or Plasma by Immunoassay|40|0|0|1|1|40|0.9988598459905884|1|
|40758926|cycloSPORINE [Mass/volume] in Blood by LC/MS/MS|40|0|0|1|1|0|0.9988655176931598|1|
|3000787|Salicylates [Mass/volume] in Serum or Plasma|39|0|0|1|3|39|0.9988710476031668|1|
|3025921|Beta hydroxybutyrate dehydrogenase [Enzymatic activity/volume] in Blood|38|0|0|1|1|38|0.9988764357206097|1|
|3010517|Carboxyhemoglobin/Hemoglobin.total in Venous blood|38|0|0|1|2|30|0.9988818238380525|1|
|3001915|Cockroach IgE Ab [Units/volume] in Serum|38|0|0|1|1|0|0.9988872119554952|1|
|3029870|Urobilinogen [Mass/volume] in Urine by Automated test strip|37|34|0|1|2|0|0.9988924582803738|0.9986924599528201|
|3037701|Pyridoxine [Mass/volume] in Serum or Plasma|37|0|0|3|1|37|0.9988977046052523|1|
|3028136|Grey Alder IgE Ab [Units/volume] in Serum|37|0|0|1|1|0|0.9989029509301308|1|
|3010528|dRVVT actual/normal (normalized LA screen)|36|36|36|0|1|0|0.9989080554624451|0.9986141280605927|
|40759195|Circumference Neck|36|0|0|1|1|0|0.9989131599947594|1|
|1617538|24 hour predicted protein [Mass/time] based on random Urine by calculation|36|0|0|1|1|36|0.9989182645270736|1|
|3031147|Carbon dioxide, total [Moles/volume] in Blood by calculation|36|0|0|1|1|36|0.9989233690593878|1|
|3046171|Beta 2 glycoprotein 1 IgM Ab [Units/volume] in Serum or Plasma by Immunoassay|35|4|4|2|2|16|0.9989283317991378|0.999768770279675|
|3044355|Beta 2 glycoprotein 1 IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|35|4|0|3|2|16|0.9989332945388878|0.99981396175596|
|3023694|Leukocytes [#/volume] in Cerebral spinal fluid by Manual count|35|0|0|1|1|30|0.9989382572786377|1|
|3017730|Calcium [Mass/volume] in 24 hour Urine|35|0|0|1|1|0|0.9989432200183876|1|
|3024865|Alpha tocopherol [Mass/volume] in Serum or Plasma|34|0|0|1|1|33|0.9989480409655733|1|
|3017181|Myelocytes/Leukocytes in Blood|34|0|0|1|1|2|0.998952861912759|1|
|3010074|HIV 1 RNA [Log #/volume] (viral load) in Plasma by Probe with signal amplification|34|0|0|1|1|0|0.9989576828599447|1|
|3024172|Erythropoietin (EPO) [Units/volume] in Serum or Plasma|34|0|0|2|1|34|0.9989625038071304|1|
|3019174|dRVVT (LA screen)|33|6|6|2|2|0|0.9989671829617517|0.9996738681794765|
|3041292|Length of Wound|33|0|0|1|1|0|0.9989718621163731|1|
|3027475|Erythrocytes [#/volume] in Cerebral spinal fluid|33|0|0|2|2|33|0.9989765412709946|1|
|3004559|Base deficit in Venous blood|33|0|0|1|1|33|0.9989812204256159|1|
|3005244|Beta+gamma tocopherol [Mass/volume] in Serum or Plasma|33|0|0|1|1|32|0.9989858995802373|1|
|3023643|Blasts/Leukocytes in Blood by Manual count|33|0|0|1|2|32|0.9989905787348586|1|
|3014791|Apolipoprotein B [Mass/volume] in Serum or Plasma|33|0|0|1|1|0|0.9989952578894801|1|
|3004722|Prolactin [Mass/volume] in Serum or Plasma|32|1|1|1|2|13|0.9989997952515371|0.9999404978895581|
|1616799|POPEth [Mass/volume] in Blood|32|0|0|1|1|0|0.9990043326135942|1|
|1616374|PLPEth [Mass/volume] in Blood|32|0|0|1|1|0|0.9990088699756514|1|
|3030612|Hemoglobin S/Hemoglobin.total in Blood by Electrophoresis|32|0|0|1|1|0|0.9990134073377085|1|
|3040905|Dermatophagoides sp IgE Ab [Units/volume] in Serum|32|0|0|1|1|0|0.9990179446997656|1|
|3041449|Collagen crosslinked C-telopeptide [Mass/volume] in Serum or Plasma|32|0|0|1|1|5|0.9990224820618226|1|
|3035285|Chloride [Moles/volume] in Venous blood|31|0|0|1|1|30|0.9990268776313155|1|
|3000598|Mesothelial cells/Leukocytes in Body fluid by Manual count|31|0|0|1|2|0|0.9990312732008083|1|
|3042480|Width of Wound|31|0|0|1|1|0|0.9990356687703011|1|
|3002179|Metamyelocytes/Leukocytes in Blood|31|0|0|1|1|1|0.999040064339794|1|
|3004944|Lidocaine [Mass/volume] in Serum or Plasma|30|0|0|1|1|30|0.9990443181167225|1|
|21490776|Pulmonary artery wedge pressure|30|0|0|1|1|0|0.999048571893651|1|
|3043730|California Walnut Pollen IgE Ab [Units/volume] in Serum|30|0|0|1|1|0|0.9990528256705796|1|
|3001219|Smith extractable nuclear Ab [Presence] in Serum by Immune diffusion (ID)|29|1|1|1|1|0|0.9990569376549439|0.9999743914967718|
|1988680|Cell-free DNA.donor/Cell-free DNA.total in Plasma cell-free DNA --post cardiac transplant|29|0|0|1|1|0|0.9990610496393081|1|
|3035583|Leukocytes [#/area] in Urine sediment by Microscopy high power field|29|0|0|1|1|25|0.9990651616236723|1|
|3052716|Fibrin D-dimer [Mass/volume] in Platelet poor plasma by Immunoassay.DDU|29|0|0|1|1|0|0.9990692736080365|1|
|3005136|Cladosporium herbarum IgE Ab [Units/volume] in Serum|29|0|0|1|1|0|0.9990733855924008|1|
|3037310|Renin [Mass/volume] in Plasma|29|0|0|1|1|29|0.9990774975767651|1|
|3007302|Hemoglobin [Mass/volume] in Mixed venous blood|29|0|0|1|2|29|0.9990816095611293|1|
|3018447|Hepatitis C virus RNA [Units/volume] (viral load) in Serum or Plasma by NAA with probe detection|29|0|0|1|1|29|0.9990857215454936|1|
|3038136|Choriogonadotropin.beta subunit [Units/volume] in Serum or Plasma|29|0|0|1|2|0|0.9990898335298578|1|
|3039363|dRVVT in Control Platelet poor plasma by Coagulation assay|29|0|0|2|2|0|0.999093945514222|1|
|3000152|Output.ileostomy [Volume]|29|0|0|1|1|0|0.9990980574985864|1|
|3022164|Urea nitrogen [Mass/volume] in Serum or Plasma --pre dialysis|29|0|0|1|1|0|0.9991021694829506|1|
|3013915|Aldosterone [Mass/volume] in Blood|29|0|0|1|1|29|0.9991062814673148|1|
|21491177|Fluid output emesis [#]|28|28|28|0|1|0|0.9991102516591148|0.9987625067410619|
|4311150|Upper eyelid margin reflex distance|28|28|28|0|1|0|0.9991142218509148|0.9988046854522612|
|3007498|Thyroid stimulating immunoglobulins [Units/volume] in Serum|28|0|0|2|1|7|0.9991181920427147|1|
|3018650|Bicarbonate [Moles/volume] in Venous cord blood|28|0|0|2|2|21|0.9991221622345147|1|
|3005029|Protein [Mass/volume] in Body fluid|28|0|0|2|2|0|0.9991261324263147|1|
|3046299|Protein.monoclonal [Mass/volume] in Serum or Plasma by Electrophoresis|28|0|0|1|1|24|0.9991301026181146|1|
|3009131|Hemoglobin A/Hemoglobin.total in Blood by Electrophoresis|28|0|0|1|1|25|0.9991340728099146|1|
|3018994|Lactate dehydrogenase [Enzymatic activity/volume] in Body fluid by Lactate to pyruvate reaction|28|0|0|2|3|0|0.9991380430017146|1|
|3037234|Variant lymphocytes/Leukocytes in Blood by Manual count|28|0|0|1|1|0|0.9991420131935145|1|
|3013101|Penicillium notatum IgE Ab [Units/volume] in Serum|28|0|0|1|1|0|0.9991459833853145|1|
|3049398|Myeloperoxidase Ab [Units/volume] in Serum by Immunoassay|28|0|0|3|2|19|0.9991499535771144|1|
|3011564|Rubella virus IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|28|0|0|2|2|0|0.9991539237689144|1|
|21492175|Heart transplant acute cellular rejection risk [Score] in Mononuclear cells Calculated by AlloMap|27|27|27|0|1|27|0.9991577521681501|0.9988664471365174|
|3964874|Measles virus IgG Ab index [Units/volume] in Serum and CSF|27|0|0|1|1|0|0.9991615805673858|1|
|3023351|European house dust mite IgE Ab [Units/volume] in Serum|27|0|0|1|1|0|0.9991654089666214|1|
|3003752|BK virus DNA [Units/volume] (viral load) in Urine by NAA with probe detection|27|0|0|1|1|25|0.9991692373658572|1|
|3009178|Nicotine [Mass/volume] in Serum or Plasma|27|0|0|1|1|0|0.9991730657650928|1|
|3005770|Creatinine renal clearance in 24 hour Urine and Serum or Plasma|27|0|0|2|2|20|0.9991768941643285|1|
|40765038|1,25-Dihydroxyvitamin D [Mass/volume] in Serum or Plasma|27|0|0|1|1|27|0.9991807225635642|1|
|3051669|Proteinase 3 Ab [Units/volume] in Serum by Immunoassay|27|0|0|3|2|18|0.9991845509627999|1|
|3006028|Cotinine [Mass/volume] in Serum or Plasma|27|0|0|1|1|0|0.9991883793620355|1|
|3036780|American house dust mite IgE Ab [Units/volume] in Serum|27|0|0|1|1|0|0.9991922077612713|1|
|3006734|White Oak IgE Ab [Units/volume] in Serum|27|0|0|1|1|0|0.9991960361605069|1|
|3044870|Hemoglobin C/Hemoglobin.total in Blood by Electrophoresis|27|0|0|1|1|0|0.9991998645597426|1|
|3041543|Other cells/Leukocytes in Blood by Manual count|27|0|0|1|1|0|0.9992036929589783|1|
|3001467|Alkaline phosphatase.bone [Enzymatic activity/volume] in Serum or Plasma|26|0|0|1|1|26|0.9992073795656496|1|
|3017809|Bicarbonate [Moles/volume] in Arterial cord blood|26|0|0|2|2|18|0.999211066172321|1|
|3035400|Alkaline phosphatase.liver [Enzymatic activity/volume] in Serum or Plasma|26|0|0|1|1|26|0.9992147527789925|1|
|3002079|Sodium [Moles/time] in 24 hour Urine|25|9|0|1|2|25|0.9992182975930995|0.9994900895092507|
|3000570|Elastase.pancreatic [Mass/mass] in Stool|25|4|1|1|1|0|0.9992218424072067|0.999786846870189|
|3013928|Ribonucleoprotein extractable nuclear Ab [Presence] in Serum by Immune diffusion (ID)|25|1|1|1|1|0|0.9992253872213138|0.9999284468292153|
|36204016|Streptococcus pneumoniae Danish serotype 2 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.999228932035421|1|
|36204373|Streptococcus pneumoniae Danish serotype 9N IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.999232476849528|1|
|36203990|Streptococcus pneumoniae Danish serotype 17F IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992360216636351|1|
|36204278|Streptococcus pneumoniae Danish serotype 11A IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992395664777423|1|
|36204351|Streptococcus pneumoniae Danish serotype 8 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992431112918494|1|
|36204005|Streptococcus pneumoniae Danish serotype 19F IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992466561059565|1|
|3005665|Streptococcus pneumoniae Danish serotype 6B IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992502009200636|1|
|36204110|Streptococcus pneumoniae Danish serotype 3 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992537457341707|1|
|3038232|Streptococcus pneumoniae Danish serotype 33F IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992572905482778|1|
|3001247|Common Ragweed IgE Ab [Units/volume] in Serum|25|0|0|1|1|0|0.999260835362385|1|
|36204094|Streptococcus pneumoniae Danish serotype 23F IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.999264380176492|1|
|3016459|Mountain Juniper IgE Ab [Units/volume] in Serum|25|0|0|1|1|0|0.9992679249905991|1|
|3000899|Streptococcus pneumoniae Danish serotype 7F IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992714698047063|1|
|3042065|Streptococcus pneumoniae Danish serotype 15B IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992750146188134|1|
|3045405|Hemoglobin F/Hemoglobin.total in Blood by Electrophoresis|25|0|0|1|1|25|0.9992785594329205|1|
|3009713|Pulmonary vascular Resistance index|25|0|0|1|1|0|0.9992821042470276|1|
|36204178|Streptococcus pneumoniae Danish serotype 10A IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9992856490611347|1|
|3009036|Unspecified cells/Leukocytes in Body fluid by Manual count|25|0|0|1|1|0|0.9992891938752418|1|
|36204029|Streptococcus pneumoniae Danish serotype 22F IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.999292738689349|1|
|36204022|Streptococcus pneumoniae Danish serotype 20A IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.999296283503456|1|
|3013652|Pulmonary vascular Resistance|25|0|0|1|1|0|0.9992998283175631|1|
|36204187|Streptococcus pneumoniae Danish serotype 4 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9993033731316703|1|
|3005260|Streptococcus pneumoniae Danish serotype 9V IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9993069179457774|1|
|36203922|Streptococcus pneumoniae Danish serotype 14 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9993104627598846|1|
|3006665|Streptococcus pneumoniae Danish serotype 18C IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9993140075739916|1|
|36203821|Streptococcus pneumoniae Danish serotype 1 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9993175523880987|1|
|36204286|Streptococcus pneumoniae Danish serotype 5 IgG Ab [Mass/volume] in Serum|25|0|0|1|1|0|0.9993210972022059|1|
|3009471|Fatty acids.nonesterified [Moles/volume] in Serum or Plasma|24|0|0|1|1|1|0.9993245002237486|1|
|42869531|Gamma interferon background [Units/volume] in Blood by Immunoassay|24|0|0|1|1|0|0.9993279032452915|1|
|3011705|Protein [Mass/volume] in 24 hour Urine|24|0|0|1|1|0|0.9993313062668343|1|
|3044549|Streptococcus pneumoniae Danish serotype 19A IgG Ab [Mass/volume] in Serum|24|0|0|1|1|0|0.9993347092883772|1|
|3039753|Posaconazole [Mass/volume] in Serum or Plasma|24|0|0|1|1|0|0.99933811230992|1|
|3005673|Hemoglobin A1c/Hemoglobin.total in Blood by HPLC|24|0|0|1|1|24|0.9993415153314628|1|
|36203231|Streptococcus pneumoniae Danish serotype 12F IgG Ab [Mass/volume] in Serum|24|0|0|1|1|0|0.9993449183530057|1|
|3025260|Common pigweed IgE Ab [Units/volume] in Serum|23|0|0|1|1|0|0.9993481795819842|1|
|3012266|Gestational age|23|0|0|1|1|0|0.9993514408109627|1|
|3004221|5 minute Apgar Score|22|22|22|0|1|0|0.999354560247377|0.9989206769080594|
|4313168|Lower eyelid margin reflex distance|22|22|22|0|1|0|0.9993576796837912|0.9989372471160306|
|3034578|Cells Counted Total [#] in Body fluid|22|22|22|0|1|0|0.9993607991202055|0.9989538173240018|
|3025673|Glucose [Mass/volume] in Serum or Plasma --2 hours post 75 g glucose PO|22|2|2|1|1|7|0.9993639185566198|0.9999103702387013|
|3009678|Varicella zoster virus IgG Ab [Presence] in Serum by Immunoassay|22|1|1|1|2|21|0.9993670379930341|0.9999201617252298|
|3046825|Epithelial cells.renal [#/area] in Urine sediment by Microscopy low power field|22|0|0|2|1|0|0.9993701574294482|1|
|3031282|Methemoglobin/Hemoglobin.total in Mixed venous blood|22|0|0|1|2|22|0.9993732768658625|1|
|3022005|Segmented neutrophils/Leukocytes in Body fluid|22|0|0|1|1|0|0.9993763963022768|1|
|3026212|White mulberry IgE Ab [Units/volume] in Serum|22|0|0|1|1|0|0.9993795157386911|1|
|43054946|Parathyrin.intact intraoperative panel - Serum or Plasma|22|0|0|1|1|22|0.9993826351751053|1|
|1259742|Aldosterone/Renin [Ratio] in Serum or Plasma|21|21|0|1|1|0|0.9993856128189553|0.9989862045486727|
|3032186|pH of Venous cord blood adjusted to patient's actual temperature|21|21|21|0|1|21|0.9993885904628053|0.9990178385820723|
|3029246|Carbon dioxide [Partial pressure] adjusted to patient's actual temperature in Venous cord blood|21|0|0|1|1|21|0.9993915681066552|1|
|3022675|Perennial rye grass IgE Ab [Units/volume] in Serum|21|0|0|1|1|0|0.9993945457505052|1|
|3016543|Leukocytes [#/volume] in Cerebral spinal fluid|21|0|0|1|1|21|0.9993975233943552|1|
|40759660|Glutamate decarboxylase 65 Ab [Units/volume] in Serum by Immunoassay|21|0|0|2|1|21|0.9994005010382051|1|
|3048918|Histoplasma capsulatum Ag [Mass/volume] in Urine|21|0|0|1|2|21|0.9994034786820551|1|
|4164986|Katz activities of daily living|20|20|20|0|1|0|0.9994063145333408|0.9990329024075005|
|3017457|Urea nitrogen [Mass/time] in 24 hour Urine|20|11|2|1|2|18|0.9994091503846265|0.9993620469931098|
|3007332|Glucose [Mass/volume] in Serum or Plasma --1 hour post 75 g glucose PO|20|2|2|1|1|7|0.9994119862359122|0.9999163957688727|
|3005235|Kentucky blue grass IgE Ab [Units/volume] in Serum|20|0|0|1|1|0|0.9994148220871979|1|
|3027215|Base excess standard in Venous blood by calculation|20|0|0|1|1|20|0.9994176579384836|1|
|40762533|Calcium.ionized [Mass/volume] in Venous blood|20|0|0|1|1|20|0.9994204937897693|1|
|3014126|English plantain IgE Ab [Units/volume] in Serum|20|0|0|1|1|0|0.999423329641055|1|
|44787087|Thiamine pyrophosphate [Moles/volume] in Blood|20|0|0|1|1|20|0.9994261654923406|1|
|3037117|Mesquite IgE Ab [Units/volume] in Serum|20|0|0|1|1|0|0.9994290013436263|1|
|3021952|Alkaline phosphatase isoenzymes [Enzymatic activity/volume] in Serum or Plasma by Heat stability|20|0|0|1|1|0|0.999431837194912|1|
|3002479|Goosefoot IgE Ab [Units/volume] in Serum|20|0|0|1|1|0|0.9994346730461977|1|
|706177|SARS-CoV-2 (COVID-19) IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|20|0|0|2|2|0|0.9994375088974834|1|
|4167593|Abbreviated Mental Test|19|19|19|0|1|0|0.9994402029562048|0.9990622768670858|
|3030109|pH of Arterial cord blood adjusted to patient's actual temperature|19|19|19|0|1|18|0.9994428970149262|0.9990765875012427|
|3034976|Hematocrit [Volume Fraction] of Venous blood by calculation|19|19|0|0|1|19|0.9994455910736476|0.9991338300378705|
|3030703|Everolimus [Mass/volume] in Blood|19|0|0|1|1|0|0.999448285132369|1|
|3032029|Measles virus IgG Ab [Presence] in Serum by Immunoassay|19|0|0|1|1|19|0.9994509791910904|1|
|3032759|Carbon dioxide [Partial pressure] adjusted to patient's actual temperature in Arterial cord blood|19|0|0|1|1|18|0.9994536732498118|1|
|3022976|Prolactin [Units/volume] in Serum or Plasma by 3rd IS|19|0|0|1|1|0|0.9994563673085333|1|
|1619026|Glomerular filtration rate [Volume Rate/Area] in Serum, Plasma or Blood by Creatinine and Cystatin C-based formula (CKD-EPI 2021)/1.73 sq M|19|0|0|1|1|0|0.9994590613672546|1|
|3042659|BK virus DNA [Log #/volume] (viral load) in Serum or Plasma by NAA with probe detection|19|0|0|1|1|0|0.999461755425976|1|
|46235126|dRVVT with 1:1 PNP (LA mix)|19|0|0|2|2|0|0.9994644494846975|1|
|3052524|SCL-70 extractable nuclear IgG Ab [Units/volume] in Serum by Immunoassay|19|0|0|2|1|11|0.9994671435434189|1|
|3016330|Potassium [Moles/time] in 24 hour Urine|18|9|0|1|2|18|0.999469695809576|0.9994833107878079|
|3032567|Hepatitis B virus DNA [Units/volume] (viral load) in Serum or Plasma by NAA with probe detection|18|0|0|1|2|16|0.9994722480757331|1|
|3009445|Proteinase 3 Ab [Units/volume] in Serum|18|0|0|1|1|18|0.9994748003418902|1|
|36306105|Troponin I.cardiac [Mass/volume] in Serum or Plasma by High sensitivity method|18|0|0|1|1|0|0.9994773526080474|1|
|3006957|Toxoplasma gondii IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|18|0|0|1|2|0|0.9994799048742045|1|
|3014173|Calcitriol [Mass/volume] in Serum or Plasma|18|0|0|1|1|15|0.9994824571403615|1|
|3018910|Alkaline phosphatase.bone [Mass/volume] in Serum or Plasma|17|7|0|1|2|5|0.9994848676139544|0.9996693490318479|
|3006661|Calcium [Mass/volume] in Urine|17|3|3|1|2|0|0.9994872780875472|0.9998350511115597|
|3036603|Volume of Urine|17|1|1|1|1|0|0.9994896885611401|0.9999593276713434|
|3027831|CD3-CD16+CD56+ (Natural killer) cells/cells in Blood|17|0|0|1|1|16|0.9994920990347329|1|
|3006573|Measles virus IgG Ab [Units/volume] in Serum by Immunoassay|17|0|0|1|1|0|0.9994945095083257|1|
|3036663|Lymphocytes/Leukocytes in Cerebral spinal fluid by Manual count|17|0|0|1|2|0|0.9994969199819186|1|
|3012494|Peanut IgE Ab [Units/volume] in Serum|17|0|0|1|1|0|0.9994993304555114|1|
|3035845|Cortisol [Mass/volume] in Saliva (oral fluid)|17|0|0|2|1|0|0.9995017409291043|1|
|3010189|Epithelial cells [#/area] in Urine sediment by Microscopy high power field|17|0|0|1|1|17|0.9995041514026971|1|
|3000876|Codfish IgE Ab [Units/volume] in Serum|17|0|0|1|1|0|0.99950656187629|1|
|3034780|Angiotensin converting enzyme [Enzymatic activity/volume] in Serum or Plasma|17|0|0|1|1|17|0.9995089723498828|1|
|3030595|Trans-3-Hydroxycotinine [Mass/volume] in Serum or Plasma|17|0|0|1|1|0|0.9995113828234756|1|
|3023150|Myeloperoxidase Ab [Units/volume] in Serum|17|0|0|1|1|17|0.9995137932970685|1|
|3019210|Glucose [Mass/volume] in Body fluid|17|0|0|1|2|2|0.9995162037706613|1|
|3020358|CD16+CD56+ cells [#/volume] in Blood|16|16|0|0|1|15|0.9995184724516899|0.9992355108595118|
|3015174|Gliadin IgA Ab [Units/volume] in Serum by Immunoassay|16|5|0|2|1|15|0.9995207411327184|0.9997333702899184|
|3017044|Thyrotropin receptor Ab [Units/volume] in Serum|16|0|0|2|1|4|0.999523009813747|1|
|3024250|Calcium.ionized [Mass/volume] in Serum or Plasma by Ion-selective membrane electrode (ISE)|16|0|0|1|1|16|0.9995252784947755|1|
|3022910|Penicillium sp Ab [Units/volume] in Serum|16|0|0|1|1|0|0.999527547175804|1|
|3027231|Wheat IgE Ab [Units/volume] in Serum|16|0|0|1|1|0|0.9995298158568326|1|
|3021226|Shrimp IgE Ab [Units/volume] in Serum|16|0|0|1|1|0|0.9995320845378611|1|
|3015076|Soybean IgE Ab [Units/volume] in Serum|16|0|0|1|1|0|0.9995343532188897|1|
|40760947|dRVVT W excess phospholipid (LA confirm)|16|0|0|2|1|0|0.9995366218999183|1|
|3017797|Hepatitis B virus surface Ab [Presence] in Serum|16|0|0|1|1|0|0.9995388905809468|1|
|40760212|Cyclic citrullinated peptide IgA+IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|16|0|0|1|1|16|0.9995411592619754|1|
|21491173|Urine output measured by nephrostomy|16|0|0|1|1|0|0.9995434279430039|1|
|40765204|Galactomannan Ag [Units/volume] in Specimen by Immunoassay|16|0|0|1|1|16|0.9995456966240325|1|
|36031787|Tree Allergen Oak Mix (White oak+Red oak+Black Oak) IgE Ab [Units/volume] in Serum|16|0|0|1|1|0|0.9995479653050611|1|
|3030335|Coarse Granular Casts [#/area] in Urine sediment by Automated count|16|0|0|1|1|0|0.9995502339860896|1|
|3004167|Zinc [Mass/volume] in Blood|16|0|0|1|1|16|0.9995525026671181|1|
|3034548|Prostate specific Ag [Mass/volume] in Serum or Plasma by Detection limit <= 0.01 ng/mL|15|1|1|1|1|11|0.9995546295555824|0.9999570680975293|
|3015399|Transferrin receptor.soluble [Mass/volume] in Serum or Plasma|15|0|0|1|1|15|0.9995567564440466|1|
|3034360|1,3 beta glucan [Mass/volume] in Serum|15|0|0|1|1|0|0.999558883332511|1|
|3021871|Sjogrens syndrome-A extractable nuclear IgG Ab [Presence] in Serum|15|0|0|1|1|15|0.9995610102209752|1|
|3019084|Cladosporium sphaerospermum IgE Ab [Units/volume] in Serum|15|0|0|1|1|0|0.9995631371094394|1|
|3047171|Jo-1 extractable nuclear IgG Ab [Units/volume] in Serum|15|0|0|1|1|15|0.9995652639979037|1|
|3017980|Sjogrens syndrome-B extractable nuclear IgG Ab [Units/volume] in Serum by Immunoassay|15|0|0|1|1|0|0.999567390886368|1|
|3041423|Sjogrens syndrome-A extractable nuclear 60kD Ab [Units/volume] in Serum|15|0|0|1|1|15|0.9995695177748323|1|
|3028277|Fluid output emesis|15|0|0|1|1|0|0.9995716446632965|1|
|3018676|Antithrombin [Units/volume] in Platelet poor plasma by Chromogenic method|15|0|0|1|1|13|0.9995737715517609|1|
|36303285|CD38+IgM+ cells/Cells.CD19 in Blood|14|14|0|0|1|14|0.9995757566476607|0.9992573534063829|
|36305243|CD27+IgD+IgM+ cells/Cells.CD19 in Blood|14|14|0|0|1|14|0.9995777417435607|0.9992678980841827|
|36304530|CD38+IgM- cells/Cells.CD19 in Blood|14|14|0|0|1|14|0.9995797268394607|0.9992784427619825|
|36303676|CD27 cells/Cells.CD19 in Blood|14|14|0|0|1|14|0.9995817119353607|0.9992889874397823|
|36303828|CD27+IgD-IgM- cells/Cells.CD19 in Blood|14|14|0|0|1|14|0.9995836970312607|0.9992995321175822|
|3015468|Gliadin IgG Ab [Units/volume] in Serum by Immunoassay|14|3|0|2|1|13|0.9995856821271607|0.99981923409486|
|3014564|Cortisol Free [Mass/time] in 24 hour Urine|14|2|0|1|1|2|0.9995876672230607|0.9998922936481873|
|46236875|Albumin [Mass/volume] by Electrophoresis in Urine collected for unspecified duration|14|2|2|1|1|0|0.9995896523189607|0.9998983191783587|
|3021835|Urate [Mass/time] in 24 hour Urine|14|1|1|2|3|4|0.9995916374148607|0.9999615872451577|
|40764997|Pyridoxal phosphate [Moles/volume] in Serum or Plasma|14|0|0|1|1|14|0.9995936225107607|1|
|3022616|Phenytoin [Mass/volume] in Serum or Plasma|14|0|0|1|3|14|0.9995956076066607|1|
|3034806|Corn IgE Ab [Units/volume] in Serum|14|0|0|1|1|0|0.9995975927025607|1|
|36303647|CD19+CD27+IgD-IgM- cells [#/volume] in Blood|14|0|0|1|1|14|0.9995995777984605|1|
|42869529|Mitogen stimulated gamma interferon [Units/volume] corrected for background in Blood|14|0|0|1|1|0|0.9996015628943605|1|
|1761842|Rubella virus IgG Ab index [Units/volume] in Serum and CSF|14|0|0|1|1|0|0.9996035479902605|1|
|36303696|CD19+CD27+ cells [#/volume] in Blood|14|0|0|1|1|14|0.9996055330861605|1|
|36303232|CD19+CD38+IgM- cells [#/volume] in Blood|14|0|0|1|1|14|0.9996075181820605|1|
|36305810|CD19+CD27+IgD+IgM+ cells [#/volume] in Blood|14|0|0|1|1|14|0.9996095032779605|1|
|3025313|Albumin [Mass/volume] in Body fluid|14|0|0|1|1|0|0.9996114883738605|1|
|3023420|DNA double strand Ab [Units/volume] in Serum|14|0|0|1|1|11|0.9996134734697605|1|
|3025709|Mumps virus IgG Ab [Units/volume] in Serum by Immunoassay|14|0|0|1|1|0|0.9996154585656605|1|
|3045305|Beta 2 glycoprotein 1 IgA Ab [Units/volume] in Serum or Plasma by Immunoassay|14|0|0|1|1|0|0.9996174436615605|1|
|3018071|CD20 cells [#/volume] in Blood|14|0|0|1|1|14|0.9996194287574605|1|
|3964704|Mumps virus IgG Ab index [Units/volume] in Serum and CSF|14|0|0|1|1|0|0.9996214138533605|1|
|3010300|Glucose [Mass/volume] in Serum or Plasma --1 hour post dose glucose|14|0|0|1|1|0|0.9996233989492603|1|
|36305644|CD19+CD38+IgM+ cells [#/volume] in Blood|14|0|0|1|1|14|0.9996253840451603|1|
|3015982|Mucor racemosus IgE Ab [Units/volume] in Serum|14|0|0|1|1|0|0.9996273691410603|1|
|3012133|Amylase [Enzymatic activity/volume] in Body fluid|14|0|0|1|2|0|0.9996293542369603|1|
|3003311|Nucleated erythrocytes/Leukocytes [Ratio] in Blood by Manual count|14|0|0|1|1|0|0.9996313393328603|1|
|3001488|Cow milk IgE Ab [Units/volume] in Serum|13|0|0|1|1|0|0.999633182636196|1|
|3006653|Thiamine [Moles/volume] in Blood|13|0|0|1|1|13|0.9996350259395317|1|
|3016589|Cortisol Free/Creatinine [Mass Ratio] in 24 hour Urine|13|0|0|1|1|0|0.9996368692428674|1|
|3002346|Protein S [Units/volume] in Platelet poor plasma by Coagulation assay|13|0|0|1|1|11|0.9996387125462031|1|
|3014599|Egg white IgE Ab [Units/volume] in Serum|13|0|0|1|1|0|0.9996405558495388|1|
|3047826|Mullerian inhibiting substance [Mass/volume] in Serum or Plasma|13|0|0|1|1|9|0.9996423991528745|1|
|3028079|Lymphocytes/Leukocytes in Body fluid|13|0|0|1|1|0|0.9996442424562102|1|
|3031748|Cortisol Free [Mass/volume] in 24 hour Urine by HPLC|13|0|0|1|1|0|0.9996460857595459|1|
|3001149|Protein C [Units/volume] in Platelet poor plasma by Chromogenic method|13|0|0|1|1|11|0.9996479290628816|1|
|3023261|lamoTRIgine [Mass/volume] in Serum or Plasma|13|0|0|1|2|13|0.9996497723662173|1|
|3035999|Lactate [Moles/volume] in Cerebral spinal fluid|13|0|0|1|2|13|0.999651615669553|1|
|3016662|Creatinine [Mass/volume] in Body fluid|13|0|0|1|2|11|0.9996534589728887|1|
|3031305|aPTT panel - Platelet poor plasma|13|0|0|1|1|13|0.9996553022762243|1|
|3010454|Acetylcholine receptor binding Ab [Moles/volume] in Serum|13|0|0|1|1|12|0.9996571455795601|1|
|4079329|Degree of levator lift|12|12|12|0|1|0|0.9996588470903315|0.9993183618993676|
|3036518|Left ventricular Stroke volume|12|12|0|1|1|0|0.9996605486011029|0.9993274001946246|
|4287954|Exophthalmometry measurement|12|12|12|0|1|0|0.9996622501118744|0.9993364384898816|
|4157231|Alzheimer's Disease Assessment Scale|12|12|12|0|1|0|0.9996639516226458|0.9993454767851386|
|3039183|Clostridium tetani toxoid IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|12|0|0|1|1|0|0.9996656531334172|1|
|44816587|Nucleated cells [#/volume] in Body fluid by Manual count|12|0|0|1|1|0|0.9996673546441885|1|
|3019069|Monocytes/Leukocytes in Blood|12|0|0|1|2|2|0.9996690561549599|1|
|3011781|Mumps virus IgG Ab [Presence] in Serum by Immunoassay|12|0|0|1|1|12|0.9996707576657314|1|
|3000515|Antithrombin actual/normal in Platelet poor plasma by Chromogenic method|12|0|0|1|2|12|0.9996724591765028|1|
|3043986|U1 small nuclear ribonucleoprotein IgG Ab [Units/volume] in Serum|12|0|0|2|1|12|0.9996741606872742|1|
|3037039|Alpha 2 globulin [Mass/volume] in Urine by Electrophoresis|12|0|0|1|1|0|0.9996758621980456|1|
|3020934|Sesame Seed IgE Ab [Units/volume] in Serum|12|0|0|1|1|0|0.9996775637088171|1|
|40765151|PhenX - upper arm circ protocol 021101|12|0|0|1|1|0|0.9996792652195885|1|
|3005166|Alpha 1 globulin [Mass/volume] in Urine|12|0|0|1|1|0|0.9996809667303599|1|
|3006451|Walnut IgE Ab [Units/volume] in Serum|12|0|0|1|1|0|0.9996826682411313|1|
|3020666|levETIRAcetam [Mass/volume] in Serum or Plasma|12|0|0|1|1|12|0.9996843697519027|1|
|3028271|Lactate [Moles/volume] in Capillary blood|12|0|0|1|1|12|0.9996860712626742|1|
|3028075|Beta globulin [Mass/volume] in Urine by Electrophoresis|12|0|0|1|1|0|0.9996877727734456|1|
|3050146|Prolactin [Mass/volume] in Serum or Plasma by 3rd IS|12|0|0|1|1|0|0.999689474284217|1|
|3025886|Oxalate [Mass/time] in 24 hour Urine|11|2|1|1|1|10|0.9996910340024241|0.9998817489703875|
|3001218|Citrate [Mass/time] in 24 hour Urine|11|2|1|1|1|1|0.9996925937206312|0.9999118766212443|
|44786869|Apixaban [Mass/volume] in Platelet poor plasma by Chromogenic method|11|0|0|1|1|0|0.9996941534388384|1|
|3019250|Coagulation factor VIII activity actual/normal in Platelet poor plasma by Coagulation assay|11|0|0|1|2|11|0.9996957131570455|1|
|21492326|RNA polymerase III IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|11|0|0|1|1|11|0.9996972728752526|1|
|3024469|Scallop IgE Ab [Units/volume] in Serum|11|0|0|1|1|0|0.9996988325934597|1|
|3012602|Metanephrines [Moles/volume] in Serum or Plasma|11|0|0|1|1|11|0.9997003923116669|1|
|3012711|Mouse urine proteins IgE Ab [Units/volume] in Serum|11|0|0|1|1|0|0.999701952029874|1|
|3044877|Strongyloides sp IgG Ab [Units/volume] in Serum by Immunoassay|11|0|0|1|1|0|0.9997035117480811|1|
|3002754|Copper [Mass/volume] in Urine collected for unspecified duration|11|0|0|1|1|2|0.9997050714662883|1|
|3018601|Magnesium [Mass/time] in 24 hour Urine|11|0|0|1|2|11|0.9997066311844954|1|
|3003538|Epstein Barr virus nuclear IgG Ab [Units/volume] in Serum by Immunoassay|11|0|0|1|1|6|0.9997081909027025|1|
|3033397|Urate [Saturation Fraction] in 24 hour Urine|10|10|10|0|1|0|0.9997096088283454|0.9994102512344805|
|3031809|Calcium hydrogen phosphate dihydrate [Saturation Fraction] in 24 hour Urine|10|10|10|0|1|9|0.9997110267539882|0.9994253150599088|
|3007175|Sulfate [Moles/time] in 24 hour Urine|10|10|1|0|1|9|0.999712444679631|0.999432846972623|
|3015501|pH of 24 hour Urine|10|10|10|0|1|10|0.9997138626052738|0.9994403788853372|
|3035051|Ammonia [Moles/time] in 24 hour Urine|10|10|0|0|1|9|0.9997152805309167|0.9994479107980514|
|3032612|Calcium oxalate index in 24 hour Urine|10|10|10|0|1|9|0.9997166984565595|0.9994554427107655|
|21490880|Left ventricular Stroke volume index|10|10|0|1|1|0|0.9997181163822024|0.9994629746234797|
|3006567|Chloride [Moles/time] in 24 hour Urine|10|9|0|1|2|10|0.9997195343078452|0.99953754055935|
|3051396|Hemoglobin.other/Hemoglobin.total in Blood|10|2|2|1|1|8|0.9997209522334881|0.9999073574736157|
|3035982|Calcium/Creatinine [Mass Ratio] in 24 hour Urine|10|0|0|1|1|10|0.999722370159131|1|
|3015232|Cholesterol [Mass/volume] in Body fluid|10|0|0|1|1|0|0.9997237880847738|1|
|3000150|Clam IgE Ab [Units/volume] in Serum|10|0|0|1|1|0|0.9997252060104167|1|
|42869447|Nucleated cells [#/volume] in Body fluid by Automated count|10|0|0|1|1|0|0.9997266239360595|1|
|3035124|Erythrocytes [#/area] in Urine sediment by Microscopy high power field|10|0|0|1|1|10|0.9997280418617024|1|
|3021600|Valproate Free [Mass/volume] in Serum or Plasma|10|0|0|2|1|10|0.9997294597873452|1|
|3032560|Acetylcholine receptor blocking Ab/Acetylcholine Ab.total in Serum|10|0|0|1|1|10|0.9997308777129881|1|
|3012636|Phosphate [Mass/time] in 24 hour Urine|10|0|0|1|2|10|0.9997322956386309|1|
|40759656|Thyroglobulin Ab [Units/volume] in Serum or Plasma by Immunoassay|10|0|0|1|1|10|0.9997337135642738|1|
|3019050|Tissue transglutaminase IgA Ab [Units/volume] in Serum|10|0|0|1|1|10|0.9997351314899166|1|
|3000637|Triglyceride [Mass/volume] in Body fluid|10|0|0|1|2|0|0.9997365494155595|1|
|3013498|Variant lymphocytes/Leukocytes in Blood|10|0|0|1|1|0|0.9997379673412022|1|
|3018143|Epstein Barr virus capsid IgG Ab [Units/volume] in Serum by Immunoassay|10|0|0|1|1|5|0.9997393852668451|1|
|3016891|Zinc [Mass/volume] in 24 hour Urine|10|0|0|1|1|10|0.9997408031924879|1|
|3017872|Arsenic [Mass/volume] in 24 hour Urine|10|0|0|1|1|10|0.9997422211181308|1|
|3021440|Promyelocytes/Leukocytes in Blood|10|0|0|1|1|0|0.9997436390437736|1|
|3007844|Epstein Barr virus capsid IgM Ab [Units/volume] in Serum by Immunoassay|10|0|0|1|1|5|0.9997450569694165|1|
|3036094|Creatinine/Body weight [Mass/kg/time] in 24 hour Urine|9|9|0|0|1|9|0.999746333102495|0.9994968682306935|
|1002241|Protein catabolic rate based on 24 hour Urine [Calculated]|9|9|0|0|1|9|0.9997476092355736|0.999510425673579|
|3019077|Protein [Presence] in 24 hour Urine by Test strip|9|9|9|0|1|0|0.9997488853686521|0.9995172043950217|
|3007352|Cholesterol in VLDL [Mass/volume] in Serum or Plasma|9|4|4|1|1|0|0.9997501615017307|0.9997838341051033|
|3005446|Hemoglobin A1/Hemoglobin.total in Blood|9|1|1|1|1|8|0.9997514376348092|0.9999600808626149|
|3001604|Monocytes [#/volume] in Blood|9|0|0|1|2|5|0.9997527137678879|1|
|3037871|Macrophages/Leukocytes in Cerebral spinal fluid by Manual count|9|0|0|1|1|0|0.9997539899009664|1|
|3020287|Protein C actual/normal in Platelet poor plasma by Coagulation assay|9|0|0|1|2|9|0.999755266034045|1|
|3026179|Normetanephrine [Moles/volume] in Serum or Plasma|9|0|0|1|1|9|0.9997565421671235|1|
|3027035|Albumin [Mass/time] in 24 hour Urine|9|0|0|1|1|9|0.999757818300202|1|
|3001501|Glucose [Moles/volume] in Capillary blood by Glucometer|9|0|0|1|1|9|0.9997590944332806|1|
|3007953|Mercury [Mass/volume] in 24 hour Urine|9|0|0|1|1|9|0.9997603705663592|1|
|1617157|Varicella zoster virus IgG Ab index [Units/volume] in Serum and CSF|8|8|0|0|1|0|0.9997615049068734|0.9995563703411354|
|3023851|Copper [Mass/time] in 24 hour Urine|8|2|0|1|1|8|0.9997626392473877|0.9998742170576733|
|3026729|Phosphate [Mass/volume] in Urine|8|0|0|1|2|4|0.999763773587902|1|
|3018738|Hemoglobin F/Hemoglobin.total in Blood|8|0|0|1|1|8|0.9997649079284163|1|
|3025994|Estriol (E3) [Mass/volume] in Serum or Plasma|8|0|0|1|2|0|0.9997660422689306|1|
|3009927|Gastrin [Mass/volume] in Serum or Plasma|8|0|0|1|2|8|0.9997671766094448|1|
|3024731|MCV [Entitic mean volume] in Red Blood Cells|8|0|0|1|1|8|0.9997683109499591|1|
|3039162|Centromere protein B Ab [Units/volume] in Serum|8|0|0|2|1|4|0.9997694452904734|1|
|3035801|Estradiol (E2) [Mass/volume] in Serum or Plasma by High sensitivity method|8|0|0|1|1|1|0.9997705796309877|1|
|3022610|Zinc/Creatinine [Mass Ratio] in 24 hour Urine|8|0|0|1|1|7|0.999771713971502|1|
|3013530|Hemoglobin E/Hemoglobin.total in Blood|8|0|0|1|1|8|0.9997728483120163|1|
|3019434|Lead [Mass/volume] in 24 hour Urine|8|0|0|1|1|8|0.9997739826525305|1|
|46236017|Lead [Mass/volume] in Venous blood|8|0|0|1|2|8|0.9997751169930448|1|
|3037329|Epstein Barr virus DNA [#/volume] (viral load) in Blood by NAA with probe detection|8|0|0|1|1|8|0.9997762513335591|1|
|3024489|Varicella zoster virus IgM Ab [Units/volume] in Serum by Immunoassay|8|0|0|1|1|0|0.9997773856740734|1|
|3005081|Hemoglobin S/Hemoglobin.total in Blood|8|0|0|1|1|8|0.9997785200145877|1|
|3022231|Eosinophils/Leukocytes in Body fluid by Manual count|8|0|0|1|1|0|0.9997796543551019|1|
|3036669|Protein S actual/normal in Platelet poor plasma by Coagulation assay|8|0|0|1|1|8|0.9997807886956162|1|
|3020675|Cadmium [Mass/volume] in 24 hour Urine|8|0|0|1|1|8|0.9997819230361304|1|
|3966129|Maximum heart rate|8|0|0|1|1|0|0.9997830573766447|1|
|3001258|Hemoglobin C/Hemoglobin.total in Blood|8|0|0|1|1|8|0.999784191717159|1|
|3014485|Sodium [Moles/volume] in 24 hour Urine|8|0|0|1|1|0|0.9997853260576732|1|
|3007458|Neutrophils/Leukocytes in Cerebral spinal fluid by Manual count|8|0|0|1|1|0|0.9997864603981875|1|
|3020784|Hemoglobin A2/Hemoglobin.total in Blood|8|0|0|1|1|8|0.9997875947387018|1|
|3000551|Thyroxine (T4) free index in Serum or Plasma by calculation|7|7|7|0|1|7|0.9997885872866518|0.9996218979817487|
|3022670|pH of Venous cord blood|7|7|7|0|1|0|0.9997895798346018|0.9996324426595485|
|1989569|Pacemaker Ventricular sensitivity setting|7|7|0|1|1|0|0.9997905723825518|0.9996377149984484|
|3018672|pH of Body fluid|7|7|2|0|2|2|0.9997915649305018|0.9996429873373484|
|3025466|Phosphatidylserine IgG Ab [Units/volume] in Serum by Immunoassay|7|7|0|0|1|7|0.9997925574784517|0.9996482596762483|
|3006598|pH of Arterial cord blood|7|7|7|0|1|0|0.9997935500264018|0.9996535320151482|
|3026312|Phosphatidylserine IgM Ab [Units/volume] in Serum by Immunoassay|7|7|0|0|1|7|0.9997945425743517|0.9996588043540481|
|3009118|Cardiolipin IgA Ab [Units/volume] in Serum by Immunoassay|7|7|0|0|1|4|0.9997955351223018|0.999664076692948|
|3034868|Hepatitis C virus RNA [log units/volume] (viral load) in Serum or Plasma by NAA with probe detection|7|1|1|1|1|0|0.9997965276702517|0.9999578212888006|
|3000194|Beta 2 glycoprotein 1 IgA Ab [Units/volume] in Serum|7|1|0|1|1|6|0.9997975202182018|0.9999683659666004|
|3042621|Parietal cell IgG Ab [Units/volume] in Serum|7|0|0|1|1|7|0.9997985127661517|1|
|3033526|Urate [Mass/volume] in Urine|7|0|0|1|2|0|0.9997995053141018|1|
|3021717|Triiodothyronine resin uptake (T3RU) in Serum or Plasma|7|0|0|1|1|7|0.9998004978620517|1|
|3022096|Basophils/Leukocytes in Blood|7|0|0|1|1|2|0.9998014904100017|1|
|3020716|Inhaled oxygen concentration|7|0|0|1|1|0|0.9998024829579517|1|
|3023023|von Willebrand factor (vWf) ristocetin cofactor [Units/volume] in Platelet poor plasma|7|0|0|1|1|6|0.9998034755059017|1|
|4092502|Dwell time|7|0|0|1|1|0|0.9998044680538517|1|
|3027514|Triiodothyronine (T3).reverse [Mass/volume] in Serum or Plasma|7|0|0|1|1|3|0.9998054606018016|1|
|3027694|Calcium.ionized [Mass/volume] in Serum or Plasma|7|0|0|1|1|7|0.9998064531497517|1|
|3006504|Eosinophils/Leukocytes in Blood|7|0|0|1|1|2|0.9998074456977016|1|
|3013520|Cancer Ag 27-29 [Units/volume] in Serum or Plasma|7|0|0|1|1|7|0.9998084382456517|1|
|3016921|Smith extractable nuclear Ab [Units/volume] in Serum|7|0|0|1|1|7|0.9998094307936016|1|
|42870326|Spermatozoa Motile [#] in Semen --post ejaculate|6|6|0|0|1|0|0.9998102815489873|0.9996783873271049|
|43055144|Spermatozoa [#] in Semen --post ejaculate|6|6|0|0|1|0|0.999811132304373|0.9996829064747335|
|3009105|Erythrocytes [#/volume] in Urine by Test strip|6|6|6|0|1|0|0.9998119830597587|0.9997100213605045|
|3003741|Lipoprotein.pre-beta [Mass/volume] in Serum or Plasma|6|2|2|1|1|5|0.9998128338151445|0.9999058510910729|
|3053341|Cholesterol in LDL [Mass/volume] in Serum or Plasma by Electrophoresis|6|1|1|1|1|0|0.9998136845705302|0.9999887021309287|
|3045684|Alkaline phosphatase.other fractions [Enzymatic activity/volume] in Serum or Plasma|6|0|0|1|1|0|0.9998145353259159|1|
|3003415|Copper/Creatinine [Mass Ratio] in 24 hour Urine|6|0|0|1|1|5|0.9998153860813016|1|
|3001038|Herpes simplex virus 1 IgG Ab [Units/volume] in Serum by Immunoassay|6|0|0|1|1|2|0.9998162368366873|1|
|3035401|Herpes virus 6 DNA [Presence] in Specimen by NAA with probe detection|6|0|0|2|1|0|0.999817087592073|1|
|3006315|Basophils [#/volume] in Blood|6|0|0|1|2|2|0.9998179383474587|1|
|3036557|Herpes simplex virus 2 IgG Ab [Units/volume] in Serum by Immunoassay|6|0|0|1|1|2|0.9998187891028444|1|
|3036489|Thrombin time|6|0|0|2|2|4|0.9998196398582301|1|
|3016273|Islet cell 512 Ab [Units/volume] in Serum|6|0|0|1|1|0|0.9998204906136158|1|
|3032159|PTT circulating inhibitor [Presence] in Platelet poor plasma|6|0|0|2|1|6|0.9998213413690016|1|
|3050637|Epstein Barr virus DNA [Log #/volume] (viral load) in Specimen by NAA with probe detection|6|0|0|1|1|0|0.9998221921243873|1|
|3015608|Urea nitrogen [Mass/volume] in 24 hour Urine|6|0|0|1|1|0|0.999823042879773|1|
|3006508|Arsenic/Creatinine [Mass Ratio] in 24 hour Urine|6|0|0|1|1|6|0.9998238936351587|1|
|3050218|Voriconazole [Mass/volume] in Serum or Plasma|6|0|0|1|1|6|0.9998247443905444|1|
|3006407|Chromogranin A [Mass/volume] in Serum or Plasma|6|0|0|1|1|6|0.9998255951459301|1|
|3033670|Parathyrin related protein [Moles/volume] in Serum or Plasma|6|0|0|1|1|6|0.9998264459013158|1|
|3002440|Dexamethasone [Mass/volume] in Serum or Plasma|6|0|0|1|1|0|0.9998272966567014|1|
|3018478|Zinc [Mass/time] in 24 hour Urine|6|0|0|1|1|6|0.9998281474120871|1|
|3000453|Epstein Barr virus DNA [#/volume] (viral load) in Specimen by NAA with probe detection|6|0|0|1|1|0|0.999828998167473|1|
|3045132|Smith extractable nuclear IgG Ab [Units/volume] in Serum by Immunoassay|6|0|0|1|1|0|0.9998298489228586|1|
|3022000|Dehydroepiandrosterone (DHEA) [Mass/volume] in Serum or Plasma|6|0|0|2|1|6|0.9998306996782443|1|
|3006999|Ribonucleoprotein extractable nuclear Ab [Units/volume] in Serum|6|0|0|1|1|6|0.99983155043363|1|
|21493261|Report|5|5|5|0|1|0|0.9998322593964515|0.99971830646449|
|4134573|Bispectral index|5|5|5|0|1|0|0.9998329683592728|0.9997409022026326|
|3004206|Cells Counted Total [#] in Cerebral spinal fluid|5|5|2|0|1|0|0.9998336773220943|0.9997446681589897|
|3014078|IgG synthesis rate [Mass/time] in Serum and CSF by calculation|5|5|0|0|1|0|0.9998343862849157|0.9997522000717038|
|3004519|Platelet factor 4 Ag [Mass/volume] in Platelet poor plasma by Immunoassay|5|5|0|0|1|0|0.9998350952477372|0.999759731984418|
|3038609|Microalbumin [Mass/volume] in Body fluid by Detection limit <= 1.0 mg/L|5|2|2|1|1|0|0.9998358042105585|0.9998712042925877|
|4048731|Capillary filling|5|0|0|1|1|0|0.99983651317338|1|
|3036035|von Willebrand factor (vWf) Ag actual/normal in Platelet poor plasma by Immunoassay|5|0|0|1|2|5|0.9998372221362014|1|
|3027450|Sjogrens syndrome-B extractable nuclear Ab [Units/volume] in Serum|5|0|0|1|1|5|0.9998379310990229|1|
|40759668|U1 small nuclear ribonucleoprotein IgG Ab [Units/volume] in Serum by Immunoassay|5|0|0|1|1|0|0.9998386400618442|1|
|40761804|Gliadin peptide IgG Ab [Units/volume] in Serum|5|0|0|1|1|5|0.9998393490246656|1|
|1176170|Maximum amplitude activator F induced [Length] in Blood by Resonance TEG|5|0|0|1|1|5|0.9998400579874871|1|
|3020629|Protein S Free Ag actual/normal in Platelet poor plasma by Immunoassay|5|0|0|1|1|4|0.9998407669503085|1|
|3033504|Pyridoxal phosphate [Mass/volume] in Serum or Plasma|5|0|0|2|1|5|0.9998414759131299|1|
|40761803|Gliadin peptide IgA Ab [Units/volume] in Serum|5|0|0|1|1|5|0.9998421848759513|1|
|3036086|Jo-1 extractable nuclear Ab [Units/volume] in Serum by Immunoassay|5|0|0|1|1|0|0.9998428938387728|1|
|36659685|Maximum amplitude arachidonate induced [Length] in Blood by Resonance TEG|5|0|0|1|1|5|0.9998436028015942|1|
|3007368|IgG [Mass/volume] in Cerebral spinal fluid|5|0|0|1|1|5|0.9998443117644156|1|
|40762000|Nucleated cells [#/volume] in Cerebral spinal fluid by Manual count|5|0|0|1|1|5|0.999845020727237|1|
|3037194|Monocytes/Leukocytes in Cerebral spinal fluid by Manual count|5|0|0|1|1|0|0.9998457296900585|1|
|3015302|Jo-1 extractable nuclear Ab [Units/volume] in Serum|5|0|0|2|1|4|0.9998464386528799|1|
|3033341|Arsenic [Mass/time] in 24 hour Urine|5|0|0|1|1|5|0.9998471476157013|1|
|3024474|Albumin [Mass/volume] in Cerebral spinal fluid|5|0|0|1|1|5|0.9998478565785227|1|
|1175928|Maximum amplitude kaolin induced [Length] in Blood by Resonance TEG --after addition of heparinase|5|0|0|1|1|5|0.9998485655413442|1|
|1175759|Maximum amplitude ADP induced [Length] in Blood by Resonance TEG|5|0|0|1|1|5|0.9998492745041656|1|
|3030465|Serotonin release 100 IU/mL heparin.unfractionated [Units/volume] in Serum|5|0|0|1|1|0|0.9998499834669871|1|
|3039783|Alpha-1-fetoprotein.tumor marker [Mass/volume] in Serum or Plasma|5|0|0|1|1|3|0.9998506924298084|1|
|3037384|Protein C actual/normal in Platelet poor plasma by Chromogenic method|5|0|0|1|1|5|0.9998514013926298|1|
|3007798|IgG/Albumin [Mass Ratio] in Cerebral spinal fluid|5|0|0|1|1|5|0.9998521103554513|1|
|3028193|Bilirubin.total [Mass/volume] in Body fluid|5|0|0|1|3|0|0.9998528193182727|1|
|3020222|IgG clearance/Albumin clearance [Ratio] in Serum and CSF|5|0|0|1|1|5|0.9998535282810941|1|
|3002124|von Willebrand factor (vWf) Ag [Units/volume] in Platelet poor plasma by Immunoassay|5|0|0|1|1|5|0.9998542372439155|1|
|3012986|Erythrocytes [#/volume] in Cerebral spinal fluid by Automated count|5|0|0|1|1|0|0.999854946206737|1|
|3042000|Depth of Wound|5|0|0|1|1|0|0.9998556551695584|1|
|3052796|Metanephrine Free [Mass/volume] in Serum or Plasma|5|0|0|1|1|3|0.9998563641323798|1|
|3045676|Capillary refill [Time]|5|0|0|1|1|0|0.9998570730952012|1|
|3023939|Sjogrens syndrome-A extractable nuclear Ab [Units/volume] in Serum|5|0|0|1|1|5|0.9998577820580227|1|
|3049714|Procollagen type I.N-terminal propeptide [Mass/volume] in Serum|5|0|0|1|1|2|0.9998584910208441|1|
|3029588|Serotonin release 0.1 IU/mL heparin.unfractionated [Units/volume] in Serum|5|0|0|1|1|0|0.9998591999836655|1|
|3003645|Borrelia burgdorferi Ab [Units/volume] in Serum by Immunoassay|5|0|0|1|1|5|0.9998599089464869|1|
|42529198|Borrelia burgdorferi IgG+IgM Ab [Presence] in Serum by Immunoassay|5|0|0|1|1|5|0.9998606179093084|1|
|3041372|Nucleated cells [#/volume] in Cerebral spinal fluid by Automated count|5|0|0|1|1|5|0.9998613268721298|1|
|3017732|Neutrophils [#/volume] in Blood|5|0|0|1|1|5|0.9998620358349511|1|
|3023640|Estrone (E1) [Mass/volume] in Serum or Plasma|5|0|0|1|1|3|0.9998627447977726|1|
|3011742|Histone IgG Ab [Units/volume] in Serum by Immunoassay|5|0|0|1|1|5|0.999863453760594|1|
|3022368|Phosphatidylserine IgA Ab [Units/volume] in Serum by Immunoassay|4|4|0|0|1|4|0.9998640209308511|0.9997717830447607|
|3030396|Oligoclonal bands [#] in Cerebral spinal fluid by Isoelectric focusing|4|4|0|0|1|4|0.9998645881011083|0.9997808213400177|
|3011145|Aldosterone/Renin [Ratio] in Plasma|4|4|4|0|1|0|0.9998651552713654|0.9997928724003603|
|3035258|Number of specimens obtained|4|4|2|0|1|0|0.9998657224416225|0.9998169745210457|
|3010913|Copper/Creatinine [Mass Ratio] in Urine|4|2|0|1|1|4|0.9998662896118797|0.9999013319434443|
|3005148|5-Hydroxyindoleacetate [Mass/time] in 24 hour Urine|4|2|0|1|1|4|0.9998668567821368|0.9999043447085301|
|3017395|Specimen creatinine acceptable [Presence] in Urine|4|0|0|1|1|4|0.999867423952394|1|
|3015142|Tuna IgE Ab [Units/volume] in Serum|4|0|0|1|1|0|0.9998679911226511|1|
|3037043|Lambda light chains.free [Mass/volume] in Urine|4|0|0|2|1|4|0.9998685582929083|1|
|3019198|Lymphocytes [#/volume] in Blood|4|0|0|1|1|0|0.9998691254631654|1|
|3050388|Mycobacterium tuberculosis stimulated gamma interferon release by CD4+ T-cells [Units/volume] in Blood|4|0|0|1|1|0|0.9998696926334225|1|
|3034597|Kappa light chains.free [Mass/volume] in Urine|4|0|0|2|1|4|0.9998702598036797|1|
|3044199|Normetanephrine/Creatinine [Mass Ratio] in 24 hour Urine|4|0|0|1|1|4|0.9998708269739368|1|
|3023028|5-Hydroxyindoleacetate [Mass/volume] in 24 hour Urine|4|0|0|1|1|0|0.999871394144194|1|
|3051741|Pregnancy associated plasma protein A [Mass/volume] in Serum or Plasma|4|0|0|1|1|0|0.9998719613144511|1|
|3027646|Estrogen [Mass/volume] in Serum or Plasma|4|0|0|1|1|1|0.9998725284847082|1|
|3002052|WBC casts [#/area] in Urine sediment by Microscopy low power field|4|0|0|1|1|0|0.9998730956549654|1|
|3016450|Mercury [Mass/volume] in Blood|4|0|0|1|1|4|0.9998736628252225|1|
|3003700|Normetanephrine [Mass/volume] in 24 hour Urine|4|0|0|1|1|0|0.9998742299954797|1|
|3020080|Proinsulin [Moles/volume] in Serum or Plasma|4|0|0|1|1|1|0.9998747971657368|1|
|3002451|Nonhematic cells/Leukocytes in Body fluid|4|0|0|1|1|0|0.9998753643359939|1|
|3045399|Abnormal lymphocytes/Leukocytes in Body fluid by Manual count|4|0|0|1|1|0|0.9998759315062511|1|
|44787062|Parvovirus B19 DNA [log units/volume] (viral load) in Serum or Plasma by NAA with probe detection|4|0|0|1|1|0|0.9998764986765082|1|
|3019965|Metanephrine [Mass/time] in 24 hour Urine|4|0|0|1|1|4|0.9998770658467654|1|
|3016997|Mouse epithelium IgE Ab [Units/volume] in Serum|4|0|0|1|1|0|0.9998776330170225|1|
|3011786|Fungal susceptibility panel|4|0|0|1|1|0|0.9998782001872796|1|
|3010645|SCL-70 extractable nuclear Ab [Units/volume] in Serum|4|0|0|1|1|4|0.9998787673575368|1|
|3026532|HIV 1 RNA [Log #/volume] (viral load) in Serum or Plasma by NAA with probe detection|4|0|0|1|1|0|0.9998793345277939|1|
|3036105|Metanephrine/Creatinine [Mass Ratio] in 24 hour Urine|4|0|0|1|1|4|0.9998799016980511|1|
|3013748|Metanephrine [Mass/volume] in 24 hour Urine|4|0|0|1|1|0|0.9998804688683082|1|
|3027476|Ascorbate [Mass/volume] in Serum or Plasma|4|0|0|1|1|4|0.9998810360385653|1|
|44787063|Parvovirus B19 DNA [Units/volume] (viral load) in Serum or Plasma by NAA with probe detection|4|0|0|1|1|0|0.9998816032088225|1|
|3013604|Glucose [Mass/volume] in Serum or Plasma --30 minutes post 75 g glucose PO|4|0|0|1|1|0|0.9998821703790796|1|
|3016436|Lactate dehydrogenase [Enzymatic activity/volume] in Serum or Plasma|4|0|0|1|1|4|0.9998827375493368|1|
|3038470|Chromatin Ab [Units/volume] in Serum or Plasma|4|0|0|1|1|4|0.9998833047195939|1|
|3028718|17-Hydroxyprogesterone [Mass/volume] in Serum or Plasma|4|0|0|1|1|0|0.999883871889851|1|
|3026300|Glucose [Mass/volume] in Serum or Plasma --2 hours post dose glucose|4|0|0|1|1|3|0.9998844390601082|1|
|3035633|Horse hair+Horse dander IgE Ab [Units/volume] in Serum|4|0|0|1|1|0|0.9998850062303652|1|
|3018595|Inhibin A [Mass/volume] in Serum or Plasma|4|0|0|1|1|0|0.9998855734006225|1|
|3028110|Bile acid [Moles/volume] in Serum or Plasma|4|0|0|1|1|4|0.9998861405708795|1|
|3035015|Normetanephrine [Mass/time] in 24 hour Urine|4|0|0|1|1|4|0.9998867077411366|1|
|3027368|Neutrophils/Leukocytes in Blood by Manual count|4|0|0|1|1|2|0.9998872749113938|1|
|3000138|Arsenic [Mass/volume] in Blood|4|0|0|1|1|4|0.9998878420816509|1|
|3035118|Cow hair+Cow dander IgE Ab [Units/volume] in Serum|4|0|0|1|1|0|0.9998884092519081|1|
|3023560|House dust Greer IgE Ab [Units/volume] in Serum|4|0|0|1|1|0|0.9998889764221652|1|
|3048015|Spermatozoa [#/volume] in Semen --pre washing|3|3|0|0|1|0|0.9998894017998581|0.9998214936686741|
|36660714|CD21lowCD38- cells/Cells.CD19 in Blood|3|3|0|0|1|3|0.9998898271775509|0.999837310685374|
|36659906|CD20 cells/Cells.CD19 in Blood|3|3|0|0|1|3|0.9998902525552438|0.9998418298330024|
|3028923|Bacteria [#/area] in Urine sediment by Automated count|3|3|3|0|1|0|0.9998906779329366|0.999846348980631|
|3046914|Granular casts [#/area] in Urine by Computer assisted method|3|3|3|0|1|0|0.9998911033106295|0.9998486085544452|
|1989128|Pacemaker Atrial sensitivity setting|3|3|0|1|1|0|0.9998915286883223|0.9998508681282594|
|3042721|Spermatozoa Motile [#/volume] in Semen --post washing|3|3|0|0|1|0|0.9998919540660152|0.9998531277020737|
|3029083|Spermatozoa Motile [#/volume] in Semen|3|3|0|0|1|0|0.9998923794437081|0.999855387275888|
|46235125|dRVVT with 1:1 PNP actual/normal (normalized LA mix)|3|3|3|0|1|0|0.999892804821401|0.9998576468497022|
|3047671|Spermatozoa [#/volume] in Semen --post washing|3|3|0|0|1|0|0.9998932301990938|0.999864425571145|
|3004691|Service comment|3|2|2|1|1|1|0.9998936555767867|0.9998938000307303|
|3016699|Glucose [Mass/volume] in Serum or Plasma --1 hour post 50 g glucose PO|3|1|1|1|1|0|0.9998940809544795|0.9999563149062578|
|3013226|Pecan or Hickory Nut IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9998945063321724|1|
|3010771|Insulin Free [Units/volume] in Serum or Plasma|3|0|0|1|1|3|0.9998949317098652|1|
|46235078|Potassium [Moles/volume] in Serum, Plasma or Blood|3|0|0|1|1|1|0.9998953570875581|1|
|3016031|Almond IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9998957824652509|1|
|3007315|Brazil Nut IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9998962078429438|1|
|3043102|Amyloid beta 42 peptide [Mass/volume] in Plasma|3|0|0|1|1|0|0.9998966332206366|1|
|3027165|Pistachio IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9998970585983294|1|
|46236048|Gamma globulin [Mass/volume] by Electrophoresis in Urine collected for unspecified duration|3|0|0|1|1|0|0.9998974839760223|1|
|3015397|DOPamine/Creatinine [Mass Ratio] in Urine|3|0|0|1|1|3|0.9998979093537151|1|
|3008625|EPINEPHrine [Mass/volume] in Plasma|3|0|0|1|1|3|0.999898334731408|1|
|42868556|Amyloid beta 40 peptide [Mass/volume] in Plasma|3|0|0|1|1|0|0.9998987601091008|1|
|3010796|Potassium [Moles/volume] in 24 hour Urine|3|0|0|1|1|0|0.9998991854867937|1|
|3030540|Arsenic organic [Moles/volume] in Urine|3|0|0|1|1|0|0.9998996108644865|1|
|3005757|Coagulation factor V activity actual/normal in Platelet poor plasma by Coagulation assay|3|0|0|1|2|3|0.9999000362421794|1|
|3042222|Estrogen [Mass/volume] in Serum or Plasma by calculation|3|0|0|1|1|1|0.9999004616198723|1|
|40765942|Actin smooth muscle Ab [Presence] in Serum by Immunoassay|3|0|0|1|1|3|0.9999008869975652|1|
|3026156|Glutamate decarboxylase 65 Ab [Moles/volume] in Serum|3|0|0|1|1|0|0.999901312375258|1|
|3027198|Glucose [Mass/volume] in Serum or Plasma --3 hours post dose glucose|3|0|0|1|1|0|0.9999017377529509|1|
|3051433|Spermatozoa Motile/Spermatozoa in Semen --pre washing|3|0|0|1|1|0|0.9999021631306437|1|
|3008612|EPINEPHrine/Creatinine [Mass Ratio] in Urine|3|0|0|1|1|3|0.9999025885083366|1|
|3027306|Macadamia IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999030138860294|1|
|3042549|Arsenic.methylated [Mass/volume] in Urine|3|0|0|1|1|0|0.9999034392637223|1|
|3013490|DOPamine [Mass/volume] in Serum or Plasma|3|0|0|1|1|3|0.9999038646414151|1|
|3044844|Fine Granular Casts [#/area] in Urine sediment by Microscopy low power field|3|0|0|1|1|0|0.999904290019108|1|
|3036312|Salmon IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999047153968008|1|
|3007015|Cashew nut IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999051407744937|1|
|3012984|Norclozapine [Mass/volume] in Serum or Plasma|3|0|0|1|1|0|0.9999055661521865|1|
|3005225|Lactate dehydrogenase [Enzymatic activity/volume] in Serum or Plasma by Pyruvate to lactate reaction|3|0|0|1|1|3|0.9999059915298794|1|
|36304997|Mycobacterium tuberculosis stimulated gamma interferon release by CD4+ and CD8+ T-cells [Units/volume] in Blood|3|0|0|1|1|0|0.9999064169075722|1|
|3007027|Mitochondria M2 IgG Ab [Units/volume] in Serum|3|0|0|1|1|3|0.999906842285265|1|
|3018686|DOPamine [Mass/volume] in Urine|3|0|0|1|1|0|0.9999072676629579|1|
|40765543|PhenX - urinary creatinine assay for kidney function protocol 141601|3|0|0|1|1|0|0.9999076930406507|1|
|3020874|Milk IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999081184183436|1|
|3025776|Phosphate [Mass/volume] in 24 hour Urine|3|0|0|1|1|3|0.9999085437960366|1|
|3013494|Arsenic.inorganic [Mass/volume] in Urine|3|0|0|1|1|0|0.9999089691737294|1|
|3029741|Coarse Granular Casts [#/area] in Urine sediment by Microscopy low power field|3|0|0|1|1|0|0.9999093945514222|1|
|3033240|Hepatitis B virus DNA [Units/volume] (viral load) in Specimen by NAA with probe detection|3|0|0|1|1|3|0.9999098199291151|1|
|3022618|Myelin basic protein [Mass/volume] in Cerebral spinal fluid|3|0|0|1|1|3|0.9999102453068079|1|
|44816701|von Willebrand factor (vWf).activity actual/normal in Control Platelet poor plasma by Immunoassay|3|0|0|1|1|3|0.9999106706845008|1|
|3003245|Complement C1 esterase inhibitor [Mass/volume] in Serum or Plasma|3|0|0|1|1|3|0.9999110960621936|1|
|3003813|EPINEPHrine [Mass/volume] in Urine|3|0|0|1|1|0|0.9999115214398865|1|
|3052566|Lipoprotein.beta.subparticle.medium [Entitic length] in Serum or Plasma|3|0|0|1|1|0|0.9999119468175793|1|
|3041348|Volume of Semen--pre washing|3|0|0|1|1|0|0.9999123721952722|1|
|3043849|Epstein Barr virus DNA [Units/volume] (viral load) in Serum or Plasma by NAA with probe detection|3|0|0|1|2|2|0.999912797572965|1|
|40765039|1,25-Dihydroxyvitamin D2 [Mass/volume] in Serum or Plasma|3|0|0|1|1|0|0.9999132229506579|1|
|3012932|Hazelnut IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999136483283507|1|
|3046870|Tissue transglutaminase IgG Ab [Units/volume] in Serum|3|0|0|1|1|3|0.9999140737060436|1|
|3013751|cloZAPine [Mass/volume] in Serum or Plasma|3|0|0|1|1|3|0.9999144990837364|1|
|3008455|Magnesium [Moles/volume] in Red Blood Cells|3|0|0|2|1|3|0.9999149244614293|1|
|3016851|Normetanephrine [Mass/volume] in Serum or Plasma|3|0|0|1|1|3|0.9999153498391221|1|
|3016999|Rubella virus IgG Ab [Units/volume] in Serum|3|0|0|1|1|0|0.999915775216815|1|
|3022417|Norepinephrine [Mass/volume] in Plasma|3|0|0|1|1|3|0.9999162005945078|1|
|3029892|Epstein Barr virus early diffuse IgG Ab [Units/volume] in Serum|3|0|0|1|1|2|0.9999166259722008|1|
|3021839|Stemphylium botryosum IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999170513498936|1|
|3019994|Crab IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999174767275865|1|
|3018765|Aureobasidium pullulans IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999179021052793|1|
|3039557|Volume of Semen--post washing|3|0|0|1|1|0|0.9999183274829722|1|
|3011547|Coagulation factor VII activity actual/normal in Platelet poor plasma by Coagulation assay|3|0|0|1|1|3|0.999918752860665|1|
|44816763|Rivaroxaban [Mass/volume] in Platelet poor plasma by Chromogenic method|3|0|0|1|1|0|0.9999191782383579|1|
|3018352|Whole Egg IgE Ab [Units/volume] in Serum|3|0|0|1|1|0|0.9999196036160507|1|
|44816559|Phosphatidylethanol [Mass/volume] in Blood|3|0|0|1|1|0|0.9999200289937435|1|
|3049318|Spermatozoa Motile/Spermatozoa in Semen --post washing|3|0|0|1|1|0|0.9999204543714364|1|
|3019797|Norepinephrine/Creatinine [Mass Ratio] in Urine|3|0|0|1|1|3|0.9999208797491292|1|
|3013062|Norepinephrine [Mass/volume] in Urine|3|0|0|1|1|0|0.9999213051268221|1|
|36659842|CD21lowCD38- cells [#/volume] in Blood|3|0|0|1|1|3|0.9999217305045149|1|
|3009066|Myelin associated glycoprotein IgM Ab [Units/volume] in Serum by Immunoassay|2|2|0|0|1|2|0.9999220140896435|0.9998757234402162|
|3035198|Specific gravity of Body fluid by Refractometry|2|2|2|0|1|0|0.9999222976747721|0.9998787362053019|
|3018834|Bilirubin.total [Presence] in Urine by Test strip|2|2|2|0|1|0|0.9999225812599006|0.9998832553529303|
|3009261|Glucose [Presence] in Urine by Test strip|2|2|2|0|1|0|0.9999228648450292|0.9998847617354732|
|3965290|Total score (0 to 7)|2|2|2|0|1|0|0.9999231484301578|0.9998862681180161|
|3002653|Hepatitis C virus genotype [Identifier] in Serum or Plasma by NAA with probe detection|2|2|2|0|1|0|0.9999234320152863|0.9998998255609015|
|3036727|Kappa light chains.free [Mass/time] in 24 hour Urine|2|2|0|0|1|0|0.9999237156004149|0.9999028383259873|
|3035511|Protein [Mass/volume] in Urine collected for unspecified duration|2|2|2|0|1|0|0.9999239991855435|0.9999088638561585|
|3017685|Yellow fever virus Ab [Titer] in Serum|2|2|2|0|1|0|0.9999242827706721|0.9999133830037871|
|4307420|Inferior scleral show measurement|2|2|2|0|1|0|0.9999245663558006|0.9999148893863299|
|3018658|Beta 2 glycoprotein 1 IgG Ab [Units/volume] in Serum|2|1|0|1|1|1|0.9999248499409292|0.9999269404466725|
|3015160|Creatine [Mass/volume] in Serum or Plasma|2|1|1|1|1|0|0.9999251335260578|0.9999329659768439|
|3000606|Spermatozoa [#/volume] in Semen|2|1|1|1|1|0|0.9999254171111863|0.9999435106546437|
|3014300|Beta 2 glycoprotein 1 IgM Ab [Units/volume] in Serum|2|1|0|1|1|1|0.9999257006963149|0.9999646000102435|
|3005353|Prothrombin activity actual/normal in Platelet poor plasma by Coagulation assay|2|1|0|1|1|2|0.9999259842814435|0.999981923409486|
|40759657|Tissue transglutaminase IgG Ab [Units/volume] in Serum by Immunoassay|2|1|0|1|1|2|0.999926267866572|1|
|3037533|von Willebrand factor (vWf) ristocetin cofactor actual/normal in Platelet poor plasma by Platelet aggregation|2|0|0|1|1|2|0.9999265514517006|1|
|3007518|Tomato IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999268350368292|1|
|3014535|oxyMORphone [Mass/volume] in Urine by Confirmatory method|2|0|0|1|1|0|0.9999271186219578|1|
|3007785|fentaNYL [Mass/volume] in Urine|2|0|0|1|1|0|0.9999274022070863|1|
|3023919|Lactate dehydrogenase 2/Lactate dehydrogenase.total in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.9999276857922149|1|
|3005008|Cadmium [Mass/volume] in Blood|2|0|0|1|1|2|0.9999279693773435|1|
|3022251|Phencyclidine [Mass/volume] in Urine by Confirmatory method|2|0|0|1|1|0|0.999928252962472|1|
|3007930|Methemoglobin/Hemoglobin.total in Blood|2|0|0|1|1|2|0.9999285365476006|1|
|3005333|Pork IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999288201327292|1|
|40767665|Peanut recombinant (rAra h) 9 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999291037178577|1|
|3007858|Lactate dehydrogenase 3/Lactate dehydrogenase.total in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.9999293873029863|1|
|3043747|Beta 2 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.9999296708881149|1|
|3002752|Chloride [Moles/volume] in 24 hour Urine|2|0|0|1|1|0|0.9999299544732435|1|
|3007456|Orange IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.999930238058372|1|
|3007542|Rye IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999305216435006|1|
|3028866|Leukocytes [#/volume] in Blood Product unit.platelet pheresis by Automated count|2|0|0|1|1|0|0.9999308052286292|1|
|3038606|aPTT.lupus insensitive in Platelet poor plasma by Coagulation assay|2|0|0|1|1|0|0.9999310888137577|1|
|3023709|Somatotropin [Mass/volume] in Serum or Plasma|2|0|0|1|1|1|0.9999313723988863|1|
|3015737|Metanephrines [Mass/volume] in Serum or Plasma|2|0|0|1|1|0|0.9999316559840149|1|
|42870531|Hazelnut recombinant (rCor a) 1 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999319395691434|1|
|3002435|Spermatozoa Motile [Presence] in Semen by Light microscopy|2|0|0|2|1|0|0.999932223154272|1|
|3021236|Streptolysin O Ab [Units/volume] in Serum or Plasma|2|0|0|1|1|1|0.9999325067394006|1|
|3002386|Liver kidney microsomal 1 Ab [Units/volume] in Serum|2|0|0|1|1|1|0.9999327903245292|1|
|3043562|5-Hydroxyindoleacetate/Creatinine [Mass Ratio] in 24 hour Urine|2|0|0|1|1|2|0.9999330739096577|1|
|3017415|Bell Pepper IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999333574947863|1|
|3036955|Alkaline phosphatase.liver/Alkaline phosphatase.total in Serum or Plasma|2|0|0|1|1|2|0.9999336410799149|1|
|3005190|oxyCODONE [Mass/volume] in Urine by Confirmatory method|2|0|0|1|1|0|0.9999339246650434|1|
|40758310|Human epididymis protein 4 [Moles/volume] in Serum or Plasma|2|0|0|1|1|2|0.999934208250172|1|
|3018335|Norfentanyl [Mass/volume] in Urine|2|0|0|1|1|0|0.9999344918353006|1|
|40761847|Hazelnut recombinant (rCor a) 8 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999347754204291|1|
|3024605|Mycoplasma pneumoniae IgM Ab [Units/volume] in Serum by Immunoassay|2|0|0|2|1|1|0.9999350590055577|1|
|3043723|Beta 1 globulin [Mass/volume] in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.9999353425906863|1|
|3034896|Calcium oxalate monohydrate/Total in Stone|2|0|0|1|1|0|0.9999356261758149|1|
|3022690|Leukocytes other/Leukocytes in Body fluid by Manual count|2|0|0|1|1|0|0.9999359097609434|1|
|3008839|Basophils/Leukocytes in Body fluid by Manual count|2|0|0|1|1|0|0.999936193346072|1|
|3003526|Cytomegalovirus IgM Ab [Units/volume] in Serum or Plasma by Immunoassay|2|0|0|1|1|1|0.9999364769312006|1|
|3020752|Cabbage IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999367605163291|1|
|3010653|Setomelanomma rostrata IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999370441014577|1|
|3005895|Myoglobin [Mass/volume] in Serum or Plasma|2|0|0|1|2|2|0.9999373276865863|1|
|3001537|Head Occipital-frontal circumference by Tape measure|2|0|0|1|1|0|0.9999376112717149|1|
|3016682|Platelets [#/volume] in Plasma by Automated count|2|0|0|1|1|0|0.9999378948568434|1|
|3026237|Erythrocytes [#/volume] in Body fluid by Manual count|2|0|0|1|1|0|0.999938178441972|1|
|3028591|White Bean IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999384620271006|1|
|3003985|Beta hydroxybutyrate [Moles/volume] in Serum or Plasma|2|0|0|1|1|0|0.9999387456122291|1|
|3004090|Tobramycin [Mass/volume] in Serum or Plasma --peak|2|0|0|1|1|0|0.9999390291973577|1|
|3002348|Coagulation factor XII activity actual/normal in Platelet poor plasma by Coagulation assay|2|0|0|1|2|2|0.9999393127824863|1|
|3042668|Hematocrit [Volume Fraction] of Stem cell product by calculation|2|0|0|1|1|0|0.9999395963676148|1|
|3041276|Muscle specific receptor tyrosine kinase Ab [Moles/volume] in Serum|2|0|0|1|1|2|0.9999398799527434|1|
|36031978|Prothrombin time (PT) factor substitution in Platelet poor plasma by Coagulation assay --immediately after 1:1 addition of normal plasma|2|0|0|2|1|2|0.999940163537872|1|
|1989582|Cell-free DNA.donor/Cell-free DNA.total in Plasma cell-free DNA --post kidney transplant|2|0|0|1|1|0|0.9999404471230006|1|
|3001850|Coagulation factor XI activity actual/normal in Platelet poor plasma by Coagulation assay|2|0|0|1|1|2|0.999940730708129|1|
|3020147|Parvovirus B19 IgM Ab [Units/volume] in Serum by Immunoassay|2|0|0|1|1|0|0.9999410142932577|1|
|3004141|Fusarium moniliforme IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999412978783863|1|
|40760574|Normetanephrine Free [Mass/volume] in Serum or Plasma|2|0|0|1|1|0|0.9999415814635148|1|
|3023607|Alpha 1 globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|2|0|0|1|1|0|0.9999418650486434|1|
|3007700|Barley IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.999942148633772|1|
|3004404|Beta globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|2|0|0|1|1|0|0.9999424322189004|1|
|3020422|Alpha 2 globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|2|0|0|1|1|0|0.999942715804029|1|
|3009200|Lead [Mass/volume] in Urine|2|0|0|1|1|2|0.9999429993891576|1|
|3009883|Potato IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999432829742863|1|
|3020457|Parvovirus B19 IgG Ab [Units/volume] in Serum by Immunoassay|2|0|0|1|1|0|0.9999435665594147|1|
|21494261|Hazelnut recombinant (rCor a) 14 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999438501445433|1|
|3034080|Insulin human Ab [Units/volume] in Serum|2|0|0|1|1|2|0.999944133729672|1|
|3046422|BK virus DNA [Log #/volume] (viral load) in Specimen by NAA with probe detection|2|0|0|1|1|0|0.9999444173148004|1|
|46235123|aPTT.lupus sensitive with 1:1 PNP (LA mix)|2|0|0|1|1|0|0.999944700899929|1|
|3006384|Leukocytes other/Leukocytes in Cerebral spinal fluid by Manual count|2|0|0|1|1|0|0.9999449844850576|1|
|3018098|Cadmium [Mass/volume] in Urine|2|0|0|1|1|2|0.9999452680701861|1|
|3020990|Alkaline phosphatase.intestinal/Alkaline phosphatase.total in Serum or Plasma|2|0|0|1|1|2|0.9999455516553147|1|
|3013115|Eosinophils [#/volume] in Blood|2|0|0|1|1|2|0.9999458352404433|1|
|3028639|carBAMazepine [Mass/volume] in Serum or Plasma|2|0|0|1|2|2|0.9999461188255719|1|
|3026086|Segmented neutrophils/Leukocytes in Cerebral spinal fluid by Manual count|2|0|0|1|1|0|0.9999464024107004|1|
|3001571|Gamma globulin/Protein.total by Electrophoresis in Urine collected for unspecified duration|2|0|0|1|1|0|0.999946685995829|1|
|3023006|Beef IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999469695809576|1|
|40768453|Hazelnut native (nCor a) 9 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999472531660861|1|
|3027528|Unidentified cells/Leukocytes in Cerebral spinal fluid by Manual count|2|0|0|1|1|0|0.9999475367512147|1|
|3046858|Cortisol Free [Mass/volume] in 24 hour Urine|2|0|0|1|1|0|0.9999478203363433|1|
|3018001|Oat IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999481039214718|1|
|3023017|Iron/Transferrin [Mass Ratio] in Serum or Plasma|2|0|0|1|1|2|0.9999483875066004|1|
|1175134|Peanut recombinant (rAra h) 6 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.999948671091729|1|
|3044947|aPTT.lupus sensitive in Control Platelet poor plasma by Coagulation assay|2|0|0|1|1|0|0.9999489546768576|1|
|3015802|Gum-Tree IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999492382619861|1|
|40760909|Oxygen content in Blood by calculation|2|0|0|1|1|0|0.9999495218471147|1|
|3021770|Magnesium [Mass/volume] in Red Blood Cells|2|0|0|1|1|2|0.9999498054322433|1|
|3012481|Lactate dehydrogenase 5/Lactate dehydrogenase.total in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.9999500890173718|1|
|3002625|Androstanolone [Mass/volume] in Serum or Plasma|2|0|0|1|1|0|0.9999503726025004|1|
|3003765|Lettuce IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.999950656187629|1|
|3015007|Phoma betae IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999509397727576|1|
|3024072|Mycoplasma pneumoniae IgG Ab [Units/volume] in Serum by Immunoassay|2|0|0|2|1|1|0.9999512233578861|1|
|3035510|Gentamicin [Mass/volume] in Serum or Plasma|2|0|0|1|1|1|0.9999515069430147|1|
|3008955|Epicoccum purpurascens IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999517905281433|1|
|3028506|Copper [Mass/volume] in Urine|2|0|0|1|1|0|0.9999520741132718|1|
|3023235|Rice IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999523576984004|1|
|3004409|Coagulation factor X activity actual/normal in Platelet poor plasma by Coagulation assay|2|0|0|1|1|2|0.999952641283529|1|
|3008977|Amikacin [Mass/volume] in Serum or Plasma --peak|2|0|0|1|1|2|0.9999529248686575|1|
|40761871|Peanut recombinant (rAra h) 3 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999532084537861|1|
|3006898|Lactate dehydrogenase 1/Lactate dehydrogenase.total in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.9999534920389147|1|
|3003406|Grape IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999537756240433|1|
|3006892|Cells Counted Total [#] in Specimen|2|0|0|1|1|0|0.9999540592091718|1|
|3010297|aPTT W excess hexagonal phase phospholipid in Platelet poor plasma by Coagulation assay|2|0|0|2|1|0|0.9999543427943004|1|
|3024830|Lactate dehydrogenase 4/Lactate dehydrogenase.total in Serum or Plasma by Electrophoresis|2|0|0|1|1|2|0.999954626379429|1|
|3023081|Carboxyhemoglobin/Hemoglobin.total in Blood|2|0|0|1|1|0|0.9999549099645575|1|
|3025296|Carrot IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999551935496861|1|
|3002636|Chicken serum proteins IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999554771348147|1|
|44816566|Gardnerella vaginalis DNA [Log #/volume] in Vaginal fluid by NAA with probe detection|2|0|0|1|1|0|0.9999557607199432|1|
|3006109|Coagulation factor IX activity actual/normal in Platelet poor plasma by Coagulation assay|2|0|0|1|1|2|0.9999560443050718|1|
|3031932|Glucose-6-Phosphate dehydrogenase [Enzymatic activity/mass] in Red Blood Cells by Glock and McLean|2|0|0|1|1|1|0.9999563278902004|1|
|3007527|Weight of Stone|2|0|0|1|1|0|0.999956611475329|1|
|3037539|Albumin/Protein.total by Electrophoresis in Urine collected for unspecified duration|2|0|0|1|1|0|0.9999568950604575|1|
|3042027|Normetanephrine Free [Moles/volume] in Serum or Plasma|2|0|0|1|1|2|0.9999571786455861|1|
|40761872|Peanut recombinant (rAra h) 2 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999574622307147|1|
|3033891|Prothrombin time (PT) in Control Platelet poor plasma by Coagulation assay|2|0|0|2|1|0|0.9999577458158432|1|
|3002069|Alkaline phosphatase.bone/Alkaline phosphatase.total in Serum or Plasma|2|0|0|1|1|2|0.9999580294009718|1|
|3013480|cycloSPORINE [Mass/volume] in Blood by Immunoassay|2|0|0|1|1|0|0.9999583129861004|1|
|40766207|Peanut recombinant (rAra h) 8 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999585965712289|1|
|3013766|Candida albicans IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999588801563575|1|
|40761873|Peanut recombinant (rAra h) 1 IgE Ab [Units/volume] in Serum|2|0|0|1|1|0|0.9999591637414861|1|
|3036428|Adenosine deaminase [Enzymatic activity/volume] in Pleural fluid|2|0|0|1|1|2|0.9999594473266147|1|
|3024675|Thyroxine (T4) free [Mass/volume] in Serum or Plasma by Dialysis|2|0|0|1|1|0|0.9999597309117432|1|
|3966171|Olive Pollen IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999598727043075|0.9999209149165013|
|3965523|Bermuda grass IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999600144968718|0.9999216681077726|
|3018884|Sulfate-3-Glucuronyl paragloboside IgM Ab [Presence] in Serum|1|1|1|0|1|0|0.999960156289436|0.9999231744903154|
|3965211|White Elm IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999602980820004|0.9999239276815869|
|3042599|Myelin associated glycoprotein IgM Ab [Titer] in Serum by Immunoassay|1|1|0|0|1|0|0.9999604398745646|0.9999254340641297|
|3045687|Sodium/Creatinine [Molar ratio] in Urine|1|1|0|0|1|1|0.9999605816671289|0.9999261872554012|
|3964737|European house dust mite IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999607234596932|0.999927693637944|
|3039542|Porphyrins [Moles/time] in 24 hour Urine|1|1|1|0|1|0|0.9999608652522575|0.9999299532117583|
|3048168|Spermatozoa Progressive [Presence] in Semen --4 hours post ejaculation|1|1|1|0|1|0|0.9999610070448217|0.9999307064030296|
|3039998|Platelet aggregation arachidonate induced [Units/volume] in Blood|1|1|0|0|1|0|0.9999611488373861|0.9999344723593867|
|3053286|Cholesterol in HDL [Mass/volume] in Serum or Plasma by Electrophoresis|1|1|1|0|1|0|0.9999612906299503|0.9999359787419295|
|3006453|Hepatitis B virus surface Ab [Presence] in Serum by Immunoassay|1|1|1|0|1|0|0.9999614324225146|0.999936731933201|
|3964994|Mouse urine proteins IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999615742150789|0.9999374851244723|
|3013437|Mycoplasma pneumoniae IgA Ab [Presence] in Serum by Immunoassay|1|1|0|0|1|1|0.9999617160076432|0.9999382383157438|
|3964963|Timothy IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999618578002075|0.9999389915070153|
|3966767|Mugwort IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999619995927718|0.9999397446982866|
|3010391|Collagen crosslinked N-telopeptide/Creatinine [Molar ratio] in Urine|1|1|1|0|1|0|0.999962141385336|0.9999427574633724|
|3021492|IgG/Albumin [Mass Ratio] in Serum|1|1|1|0|1|1|0.9999622831779004|0.9999450170371865|
|3023539|Ketones [Mass/volume] in Urine by Test strip|1|1|1|0|1|0|0.9999624249704646|0.999945770228458|
|3019150|Specific gravity of Urine by Refractometry|1|1|1|0|1|1|0.9999625667630289|0.9999472766110008|
|3009531|Nitrite [Mass/volume] in Urine by Test strip|1|1|1|0|1|0|0.9999627085555932|0.9999495361848151|
|3966047|Cottonwood IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999628503481575|0.9999502893760864|
|3966567|Johnson grass IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999629921407217|0.9999540553324435|
|3046391|Sodium urate [Saturation Fraction] in 24 hour Urine|1|1|1|0|1|0|0.9999631339332861|0.999954808523715|
|3047111|Triglyceride/Cholesterol in HDL [Mass Ratio] in Serum or Plasma|1|1|0|0|1|0|0.9999632757258503|0.9999555617149865|
|3037010|Lambda light chains.free [Mass/time] in 24 hour Urine|1|1|0|0|1|0|0.9999634175184146|0.9999585744800721|
|3034891|Synovial lining cells/cells in Synovial fluid|1|1|0|0|1|0|0.9999635593109789|0.9999630936277005|
|3013695|Basement membrane IgG Ab [Units/volume] in Serum by Immunoassay|1|1|1|0|1|0|0.9999637011035432|0.9999653532015148|
|3966550|California Walnut Pollen IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999638428961074|0.9999661063927863|
|3014324|Cystine [Mass/time] in 24 hour Urine|1|1|0|0|1|0|0.9999639846886718|0.9999676127753291|
|3965467|Aspergillus fumigatus IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.999964126481236|0.9999691191578719|
|40759796|Cystine/Creatinine [Ratio] in 24 hour Urine|1|1|0|0|1|1|0.9999642682738004|0.9999698723491434|
|3045696|Lymphocyte proliferation stimulated by phytohemagglutinin [Mass/volume] in Blood|1|1|0|0|1|0|0.9999644100663646|0.9999706255404147|
|3965362|White Oak IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999645518589289|0.999972885114229|
|3965775|Common Ragweed IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999646936514932|0.9999751446880433|
|3013393|Acetylcholine receptor blocking Ab [Units/volume] in Serum|1|1|0|0|1|0|0.9999648354440575|0.9999774042618574|
|3965996|Dog dander IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999649772366217|0.9999789106444004|
|3966225|Common pigweed IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999651190291861|0.9999796638356717|
|1988149|Visual acuity far uncorrected Left eye|1|1|1|0|1|0|0.9999652608217503|0.9999804170269432|
|3965114|Penicillium notatum IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999654026143145|0.9999811702182145|
|3965635|Cladosporium herbarum IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999655444068789|0.9999826766007575|
|3034356|Lactoferrin [Mass/volume] in Stool|1|1|0|0|1|1|0.9999656861994431|0.9999834297920288|
|3964885|Saltwort IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999658279920074|0.9999841829833003|
|3027457|Glucose [Mass/volume] in Serum or Plasma --3 hours post 100 g glucose PO|1|1|1|0|1|0|0.9999659697845718|0.9999849361745716|
|3965417|Grey Alder IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.999966111577136|0.9999856893658431|
|3966553|Mountain Juniper IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999662533697002|0.9999864425571144|
|3046867|Alpha 1 antitrypsin phenotype [Interpretation] in Serum or Plasma|1|1|1|0|1|1|0.9999663951622646|0.9999871957483859|
|3964987|Alternaria alternata IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999665369548288|0.9999894553222002|
|3041907|Viscosity of Serum Qualitative|1|1|1|0|1|0|0.9999666787473931|0.9999902085134715|
|3964879|American house dust mite IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999668205399574|0.999990961704743|
|44816693|Total thyroxine binding capacity in Serum or Plasma|1|1|0|0|1|1|0.9999669623325217|0.9999924680872858|
|3038939|Triple phosphate [Saturation Fraction] in 24 hour Urine|1|1|1|0|1|0|0.999967104125086|0.9999932212785573|
|3965984|White mulberry IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999672459176503|0.9999939744698286|
|3011397|Hemoglobin [Presence] in Urine by Test strip|1|1|1|0|1|0|0.9999673877102145|0.9999954808523714|
|3966205|Cockroach IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999675295027789|0.9999962340436429|
|3013516|pH of Semen|1|1|1|0|1|0|0.9999676712953431|0.9999977404261857|
|3021886|Globulin [Mass/volume] in Serum|1|1|1|0|1|0|0.9999678130879074|0.9999984936174572|
|3965661|Cat dander IgE Ab [Presence] in Serum by Radioallergosorbent test (RAST)|1|1|1|0|1|0|0.9999679548804717|0.9999992468087285|
|3002313|Ginger IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.999968096673036|1|
|3029800|Calcium oxalate dihydrate/Total in Stone by Infrared spectroscopy|1|0|0|1|1|0|0.9999682384656002|1|
|3032682|Adenovirus DNA [#/volume] (viral load) in Specimen by NAA with probe detection|1|0|0|1|1|0|0.9999683802581646|1|
|3005356|Cytomegalovirus IgG Ab [Units/volume] in Serum or Plasma by Immunoassay|1|0|0|1|1|0|0.9999685220507288|1|
|3014051|Protein [Presence] in Urine by Test strip|1|0|0|1|1|0|0.9999686638432931|1|
|3028447|Cobalt [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999688056358574|1|
|3012870|Urate [Mass/volume] in 24 hour Urine|1|0|0|1|1|1|0.9999689474284217|1|
|3014309|Bahia grass IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999690892209859|1|
|46235190|Zinc transporter 8 Ab [Units/volume] in Serum or Plasma by Immunoassay|1|0|0|1|1|0|0.9999692310135503|1|
|3007487|PHENobarbital [Mass/volume] in Urine|1|0|0|1|1|0|0.9999693728061145|1|
|3018669|Avocado IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999695145986789|1|
|3028990|Mitochondria M2 Ab [Units/volume] in Serum|1|0|0|1|1|1|0.9999696563912431|1|
|3021505|Blood loss.total intraoperative [Volume] Estimated|1|0|0|1|1|0|0.9999697981838074|1|
|3010119|Morphine [Mass/volume] in Urine by Confirmatory method|1|0|0|1|1|0|0.9999699399763717|1|
|3008269|Chromium [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.999970081768936|1|
|3002463|Red top grass IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999702235615002|1|
|21494263|English walnut recombinant (rJug r) 1 IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999703653540646|1|
|40767663|Brazil Nut recombinant (rBer e) 1 IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999705071466288|1|
|3007893|Nutmeg IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999706489391931|1|
|3038943|Toxoplasma gondii IgM Ab [Presence] in Serum or Plasma by Immunoassay|1|0|0|1|1|0|0.9999707907317574|1|
|3020960|American Cockroach IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999709325243217|1|
|3020331|Lead [Mass/volume] in Blood|1|0|0|1|1|1|0.9999710743168859|1|
|3031110|HIV 1 RNA [Log #/volume] (viral load) in Cerebral spinal fluid by NAA with probe detection|1|0|0|1|1|0|0.9999712161094503|1|
|44816567|Lactobacillus sp DNA [Log #/volume] in Vaginal fluid by NAA with probe detection|1|0|0|1|1|0|0.9999713579020145|1|
|3011492|Wormwood IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999714996945788|1|
|3006840|Garlic IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999716414871431|1|
|3002431|Phytonadione [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999717832797074|1|
|3027300|Silver Birch IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999719250722716|1|
|3023669|Thiamine [Moles/volume] in Serum or Plasma|1|0|0|1|1|1|0.999972066864836|1|
|3023978|Arsenic/Creatinine [Mass Ratio] in Urine|1|0|0|1|1|1|0.9999722086574002|1|
|3027626|Tilapia IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999723504499646|1|
|3028054|Vasoactive intestinal peptide [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999724922425288|1|
|3016413|Influenza virus B IgG Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999726340350931|1|
|3011461|Vancomycin [Mass/volume] in Serum or Plasma --peak|1|0|0|1|1|1|0.9999727758276574|1|
|3024262|Proinsulin [Moles/volume] in Serum or Plasma --12 hours fasting|1|0|0|1|1|0|0.9999729176202217|1|
|1989508|Interleukin 2 Receptor Soluble [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999730594127859|1|
|3017916|Jo-1 extractable nuclear Ab [Titer] in Serum|1|0|0|1|1|1|0.9999732012053503|1|
|40766151|Gliadin peptide+tissue transglutaminase IgA+IgG Ab [Presence] in Serum by Immunoassay|1|0|0|1|1|1|0.9999733429979145|1|
|40759837|Islet cell 512 Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999734847904788|1|
|3037870|Insulin Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999736265830431|1|
|3021453|Eosinophils/Leukocytes in Body fluid|1|0|0|1|1|0|0.9999737683756074|1|
|3035509|Tobramycin [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999739101681716|1|
|3012151|West Nile virus IgM Ab [Units/volume] in Serum|1|0|0|1|1|0|0.999974051960736|1|
|4089847|Enteral fluid input|1|0|0|1|1|0|0.9999741937533002|1|
|3023436|Glucagon [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999743355458645|1|
|3017177|Insulin Ab [Units/volume] in Serum by Radioimmunoassay (RIA)|1|0|0|1|1|0|0.9999744773384288|1|
|1989352|Interleukin 17 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999746191309931|1|
|1988550|Interleukin 12 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999747609235574|1|
|3002291|Halibut IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999749027161217|1|
|3002911|CD3+CD25+ cells/cells in Blood|1|0|0|1|1|1|0.9999750445086859|1|
|3014512|Acetylcholine receptor modulation Ab/Acetylcholine Ab.total in Serum|1|0|0|1|1|1|0.9999751863012503|1|
|40763883|CD8-CD57+ cells [#/volume] in Blood|1|0|0|1|1|1|0.9999753280938145|1|
|3017295|CD8+CD38+ cells [#/volume] in Blood|1|0|0|1|1|1|0.9999754698863788|1|
|3028471|Vanilla IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999756116789431|1|
|3014178|Parietal cell Ab [Units/volume] in Serum|1|0|0|1|1|1|0.9999757534715074|1|
|3020805|Taenia solium larva IgG Ab [Presence] in Serum by Immunoblot|1|0|0|1|1|0|0.9999758952640716|1|
|3023456|Valproate Free/Valproate.total in Serum or Plasma|1|0|0|1|1|1|0.999976037056636|1|
|3028305|Cortisol [Mass/volume] in Serum or Plasma --1 hour post dose corticotropin|1|0|0|1|1|0|0.9999761788492002|1|
|40760771|Ganglioside GQ1b IgG Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999763206417644|1|
|3048234|Riboflavin [Moles/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999764624343288|1|
|40764183|Norhydrocodone [Mass/volume] in Urine by Confirmatory method|1|0|0|1|1|0|0.999976604226893|1|
|3034124|Dill IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999767460194573|1|
|3014727|Leptin [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999768878120217|1|
|3003101|Alpha 1 antitrypsin [Mass/mass] in Stool|1|0|0|1|1|1|0.9999770296045859|1|
|3038882|Thiopurine methyltransferase [Enzymatic activity/volume] in Blood|1|0|0|1|1|1|0.9999771713971501|1|
|3034552|Adenosine deaminase [Enzymatic activity/volume] in Cerebral spinal fluid|1|0|0|1|1|1|0.9999773131897145|1|
|3013741|HYDROmorphone [Mass/volume] in Urine by Confirmatory method|1|0|0|1|1|0|0.9999774549822787|1|
|40763084|Lactate dehydrogenase [Enzymatic activity/volume] in Cerebral spinal fluid by Lactate to pyruvate reaction|1|0|0|1|1|0|0.9999775967748431|1|
|3049801|Complement C1 esterase inhibitor actual/normal in Serum or Plasma|1|0|0|1|1|0|0.9999777385674073|1|
|3016636|Influenza virus B IgM Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999778803599716|1|
|3017894|Mustard IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.999978022152536|1|
|3006008|Cystine [Mass/volume] in 24 hour Urine|1|0|0|1|1|0|0.9999781639451002|1|
|3026253|Mumps virus IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999783057376644|1|
|3040432|Spermatozoa [#/volume] in Semen --post concentration|1|0|0|1|1|0|0.9999784475302288|1|
|3017840|Spermatozoa Motile/Spermatozoa in Semen|1|0|0|1|1|0|0.999978589322793|1|
|3050010|Liver kidney microsomal 1 IgG Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999787311153573|1|
|3002538|Oyster IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999788729079216|1|
|40761846|Wheat recombinant (rTri a) 19 IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999790147004859|1|
|3035839|Band form neutrophils/Leukocytes in Blood by Automated count|1|0|0|1|1|0|0.9999791564930501|1|
|3025618|West Nile virus IgG Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999792982856145|1|
|3013147|Brome IgG Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999794400781787|1|
|3028398|Blue mussel IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.999979581870743|1|
|3008561|Activated protein C resistance [Time Ratio] in Platelet poor plasma by Coagulation assay|1|0|0|1|1|1|0.9999797236633073|1|
|3040200|Ganglioside GM1 IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999798654558716|1|
|1259491|Phosphorylated tau 181 [Mass/volume] in Plasma by Immunoassay|1|0|0|1|1|1|0.9999800072484358|1|
|3035797|Protein.monoclonal band 2 [Mass/volume] in Serum or Plasma by Electrophoresis|1|0|0|1|1|0|0.9999801490410002|1|
|3009991|Angiotensin converting enzyme [Enzymatic activity/volume] in Cerebral spinal fluid|1|0|0|1|1|1|0.9999802908335644|1|
|3037475|Sheep Sorrel IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999804326261288|1|
|42868560|Interleukin 2 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.999980574418693|1|
|3036325|Citrate/Creatinine [Mass Ratio] in Urine|1|0|0|1|1|0|0.9999807162112573|1|
|3009529|Cryoproteins identified in Serum or Plasma|1|0|0|1|1|0|0.9999808580038216|1|
|40759661|Ganglioside GD1b IgG Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999809997963859|1|
|3020478|Candida sp IgA Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999811415889501|1|
|3017018|EPINEPHrine [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999812833815145|1|
|3013474|6-Monoacetylmorphine (6-MAM) [Mass/volume] in Urine by Confirmatory method|1|0|0|1|1|0|0.9999814251740787|1|
|3005445|Coagulation factor X activated [Units/volume] in Platelet poor plasma by Coagulation assay|1|0|0|1|1|1|0.999981566966643|1|
|3966310|Neurofilament light chain [Mass/volume] in Serum or Plasma by Immunoassay|1|0|0|1|1|1|0.9999817087592073|1|
|3010414|Dengue virus IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999818505517716|1|
|3036031|Lobster IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999819923443358|1|
|36660649|Glutamate decarboxylase 65 IgG+IgM Ab [Moles/volume] in Cerebral spinal fluid by Immunoassay|1|0|0|1|1|0|0.9999821341369002|1|
|40764186|Noroxycodone [Mass/volume] in Urine by Confirmatory method|1|0|0|1|1|0|0.9999822759294644|1|
|3011161|Glucose [Mass/volume] in Serum or Plasma --4 hours post dose glucose|1|0|0|1|1|0|0.9999824177220287|1|
|3015222|Testosterone.free+weakly bound [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.999982559514593|1|
|1988559|Interleukin 8 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|1|0.9999827013071573|1|
|3001534|Cinnamon IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999828430997216|1|
|3019652|Selenium [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999829848922859|1|
|3026286|Lipase [Enzymatic activity/volume] in Body fluid|1|0|0|1|1|1|0.9999831266848501|1|
|3032676|Herpes virus 8 DNA [#/volume] (viral load) in Serum or Plasma by NAA with probe detection|1|0|0|1|1|0|0.9999832684774145|1|
|3045699|Interleukin 2 [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999834102699787|1|
|3011306|Selenium [Mass/volume] in Blood|1|0|0|1|1|1|0.999983552062543|1|
|3014521|Porphyrins [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999836938551073|1|
|42868572|Interleukin 13 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999838356476716|1|
|3007887|Pellitory (Parietaria officinalis) IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999839774402358|1|
|40760548|Muscle specific receptor tyrosine kinase Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999841192328002|1|
|3004959|Base excess in Arterial cord blood by calculation|1|0|0|1|1|1|0.9999842610253644|1|
|3006013|Black Pepper IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999844028179287|1|
|3024507|Metamyelocytes [#/volume] in Blood|1|0|0|1|1|0|0.999984544610493|1|
|3027151|Growth hormone-releasing hormone [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999846864030573|1|
|3016059|Intrinsic factor blocking Ab [Units/volume] in Serum|1|0|0|1|1|1|0.9999848281956215|1|
|3036834|Lenscale IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999849699881859|1|
|3029272|Interleukin 6 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999851117807501|1|
|3001797|Niacin [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999852535733144|1|
|21495016|Sample variant allelic frequency [NFr]|1|0|0|1|1|0|0.9999853953658787|1|
|3007483|Insulin-like growth factor binding protein 1 [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.999985537158443|1|
|3025222|Cobalamin (Vitamin B12).unsaturated Binding Capacity [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999856789510073|1|
|3020924|Thyroxine binding globulin [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999858207435716|1|
|3002762|Somatostatin [Mass/volume] in Plasma|1|0|0|1|1|0|0.9999859625361358|1|
|36303370|Noroxymorphone [Presence] in Urine by Screen method|1|0|0|1|1|0|0.9999861043287002|1|
|3038056|Oxalate [Mass/volume] in 24 hour Urine|1|0|0|1|1|0|0.9999862461212644|1|
|3025271|CD3-CD16+CD56+ (Natural killer) cells [#/volume] in Blood|1|0|0|1|1|1|0.9999863879138287|1|
|3015147|Influenza virus A IgG Ab [Units/volume] in Serum|1|0|0|1|1|0|0.999986529706393|1|
|3005219|Iodine [Mass/volume] in Urine|1|0|0|1|1|1|0.9999866714989573|1|
|3031119|Herpes simplex virus 1+2 IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999868132915215|1|
|3039896|Glucose [Mass/volume] in Urine by Automated test strip|1|0|0|1|1|0|0.9999869550840859|1|
|40762070|Ganglioside GD1b IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999870968766501|1|
|3005031|Microalbumin [Mass/volume] in 24 hour Urine|1|0|0|1|1|1|0.9999872386692144|1|
|3010493|Viscosity of Serum|1|0|0|1|1|0|0.9999873804617787|1|
|3018399|Cortisol Free [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.999987522254343|1|
|3030326|Porphyrins [Moles/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999876640469072|1|
|40766755|Adenovirus DNA [Log #/volume] (viral load) in Specimen by NAA with probe detection|1|0|0|1|1|0|0.9999878058394716|1|
|3019961|Butalbital [Mass/volume] in Urine|1|0|0|1|1|0|0.9999879476320358|1|
|3028327|Soluble liver Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999880894246002|1|
|3046210|Cortisol [Mass/volume] in Serum or Plasma --baseline|1|0|0|1|1|0|0.9999882312171644|1|
|3018966|Blomia tropicalis IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999883730097286|1|
|3014410|PENTobarbital [Mass/volume] in Urine|1|0|0|1|1|0|0.999988514802293|1|
|3008513|Cadmium [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999886565948573|1|
|40766102|Gamma tocopherol [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999887983874215|1|
|44816660|Megasphaera sp DNA [Log #/volume] in Vaginal fluid by NAA with probe detection|1|0|0|1|1|0|0.9999889401799859|1|
|3011003|Haemophilus influenzae B IgG Ab [Mass/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999890819725501|1|
|3009337|Methadone [Mass/volume] in Urine|1|0|0|1|1|0|0.9999892237651143|1|
|3023232|Voltage-gated calcium channel Ab [Moles/volume] in Serum|1|0|0|1|1|1|0.9999893655576787|1|
|3015603|HYDROcodone [Mass/volume] in Urine by Confirmatory method|1|0|0|1|1|0|0.999989507350243|1|
|3023690|Calcium phosphate/Total in Stone|1|0|0|1|1|0|0.9999896491428072|1|
|3037466|Alkaline phosphatase.placental/Alkaline phosphatase.total in Serum or Plasma|1|0|0|1|1|0|0.9999897909353715|1|
|3041934|Coagulation factor XI activated [Units/volume] in Platelet poor plasma by Coagulation assay|1|0|0|1|1|1|0.9999899327279358|1|
|3027481|Cadmium/Creatinine [Mass Ratio] in 24 hour Urine|1|0|0|1|1|1|0.9999900745205|1|
|3018194|Nettle IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999902163130644|1|
|3009917|Gentamicin [Mass/volume] in Serum or Plasma --peak|1|0|0|1|1|1|0.9999903581056286|1|
|3040571|West Nile virus IgG Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999904998981929|1|
|3001417|Mercury [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999906416907572|1|
|3021120|Myelocytes [#/volume] in Blood|1|0|0|1|1|0|0.9999907834833215|1|
|3001894|Volume of Semen|1|0|0|1|1|0|0.9999909252758858|1|
|3011657|Norepinephrine [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999910670684501|1|
|3048446|Mycobacterium tuberculosis tuberculin stimulated gamma interferon/Mitogen stimulated gamma interferon [Units/volume] in Control Blood|1|0|0|1|1|0|0.9999912088610143|1|
|3006147|Osmolality of 24 hour Urine|1|0|0|1|1|1|0.9999913506535787|1|
|3006828|Magnesium [Mass/volume] in 24 hour Urine|1|0|0|1|1|1|0.9999914924461429|1|
|36305170|Lipoprotein associated phospholipase A2 [Enzymatic activity/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999916342387072|1|
|3028668|London Plane IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999917760312715|1|
|3007204|Coagulation factor IX activated [Units/volume] in Platelet poor plasma by Coagulation assay|1|0|0|1|1|1|0.9999919178238358|1|
|3011307|Candida albicans IgG Ab [Units/volume] in Serum|1|0|0|1|1|1|0.9999920596164|1|
|3037831|Wattle IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999922014089644|1|
|3028247|Glucose [Mass/volume] in Serum or Plasma --30 minutes post dose glucose|1|0|0|1|1|0|0.9999923432015286|1|
|3026147|Cortisol [Mass/volume] in Serum or Plasma --30 minutes post dose corticotropin|1|0|0|1|1|0|0.9999924849940929|1|
|3035505|West Nile virus IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|0.9999926267866572|1|
|1988486|Tumor necrosis factor.alpha [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999927685792215|1|
|3021106|5-Hydroxyindoleacetate [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999929103717857|1|
|3007034|Glucose [Mass/volume] in 24 hour Urine|1|0|0|1|1|1|0.9999930521643501|1|
|3005151|Delta aminolevulinate [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999931939569143|1|
|3018050|Australian pine IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999933357494786|1|
|3017575|Referral lab test results|1|0|0|1|1|1|0.9999934775420429|1|
|3022312|CD3+CD25+ cells [#/volume] in Blood|1|0|0|1|1|1|0.9999936193346072|1|
|40768060|Cortisol Free/Cortisol.total in Serum or Plasma|1|0|0|1|1|0|0.9999937611271715|1|
|3036931|Citrate [Mass/volume] in 24 hour Urine|1|0|0|1|1|0|0.9999939029197358|1|
|3035964|CD8+CD38+ cells/cells in Blood|1|0|0|1|1|1|0.9999940447123|1|
|40763882|CD8-CD57+ cells/cells in Blood|1|0|0|1|1|1|0.9999941865048644|1|
|3031501|Kappa light chains.free/Lambda light chains.free [Mass Ratio] in Urine|1|0|0|1|1|1|0.9999943282974286|1|
|3017651|SCL-70 extractable nuclear IgG Ab [Presence] in Serum|1|0|0|1|1|1|0.9999944700899929|1|
|1989513|Interleukin 1 beta [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999946118825572|1|
|3010657|Triiodothyronine (T3) Free [Mass/volume] in Serum or Plasma by Dialysis|1|0|0|1|1|0|0.9999947536751215|1|
|42868566|Interleukin 4 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999948954676857|1|
|3010296|Alpha-1-Fetoprotein [Mass/volume] in Amniotic fluid|1|0|0|1|1|0|0.9999950372602501|1|
|3008090|DOPamine [Mass/time] in 24 hour Urine|1|0|0|1|1|1|0.9999951790528143|1|
|3028772|Osteocalcin [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999953208453786|1|
|3036887|Ammonia [Mass/volume] in Plasma|1|0|0|1|1|1|0.9999954626379429|1|
|3036353|Mesothelial cells/Leukocytes in Body fluid|1|0|0|1|1|0|0.9999956044305072|1|
|36204193|Lipoprotein.alpha 3 [Moles/volume] in Serum|1|0|0|1|1|0|0.9999957462230714|1|
|3046710|Basement membrane IgG Ab [Units/volume] in Serum by Immunofluorescence|1|0|0|1|1|1|0.9999958880156358|1|
|3017497|Pine Nut IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999960298082|1|
|3032756|HIV 1 RNA [Log #/volume] (viral load) in Specimen by NAA with probe detection|1|0|0|1|1|0|0.9999961716007644|1|
|3010989|Calcitonin [Mass/volume] in Serum or Plasma|1|0|0|1|1|0|0.9999963133933286|1|
|3021959|Cocoa IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999964551858929|1|
|3034801|CD8+HLA-DR+ cells/cells in Blood|1|0|0|1|1|1|0.9999965969784572|1|
|40759665|Ganglioside GQ1b IgM Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999967387710215|1|
|3008907|Influenza virus A IgM Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999968805635857|1|
|3015290|Mercury/Creatinine [Mass Ratio] in 24 hour Urine|1|0|0|1|1|0|0.9999970223561501|1|
|3016072|Theophylline [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999971641487143|1|
|3010354|Pecan or Hickory Tree IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999973059412786|1|
|3019406|Latex IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999974477338429|1|
|3021535|Protoporphyrin.zinc [Mass/volume] in Red Blood Cells|1|0|0|1|1|1|0.9999975895264072|1|
|21494262|English walnut recombinant (rJug r) 3 IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999977313189714|1|
|3029051|Interleukin 10 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999978731115358|1|
|3030946|Fine Granular Casts [#/area] in Urine sediment by Automated count|1|0|0|1|1|0|0.9999980149041|1|
|3002234|CD8+HLA-DR+ cells [#/volume] in Blood|1|0|0|1|1|1|0.9999981566966643|1|
|42868567|Interleukin 5 [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999982984892286|1|
|3031029|2-Ethylidene-1,5-Dimethyl-3,3-Diphenylpyrrolidine (EDDP) [Mass/volume] in Urine|1|0|0|1|1|0|0.9999984402817929|1|
|3029797|Carbon dioxide [Partial pressure] in Capillary blood by Transcutaneous CO2 monitor|1|0|0|1|1|0|0.9999985820743571|1|
|3025554|Western Ragweed IgE Ab [Units/volume] in Serum|1|0|0|1|1|0|0.9999987238669215|1|
|3018174|Transcortin [Mass/volume] in Serum|1|0|0|1|1|0|0.9999988656594857|1|
|1988432|Interferon gamma [Mass/volume] in Cerebral spinal fluid|1|0|0|1|1|0|0.9999990074520501|1|
|36031308|Delta aPTT W excess hexagonal phospholipid [Time] in Platelet poor plasma by Coagulation assay|1|0|0|1|1|1|0.9999991492446143|1|
|3021997|Mannose-binding protein [Mass/volume] in Serum|1|0|0|1|1|0|0.9999992910371786|1|
|3023091|Interleukin 6 [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999994328297429|1|
|46235736|Interleukin 2 Receptor Soluble [Mass/volume] in Serum or Plasma|1|0|0|1|1|1|0.9999995746223072|1|
|3039077|Ganglioside GM1 IgG Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|1|0.9999997164148714|1|
|3020399|Glucose [Mass/volume] in Urine|1|0|0|1|1|1|0.9999998582074358|1|
|3012988|Dengue virus IgG Ab [Units/volume] in Serum by Immunoassay|1|0|0|1|1|0|1|1|

</details>

<details>
<summary><strong>unit_source_value query</strong></summary>

```sql
%sql
SELECT unit_source_value,-- unit_concept_id, COUNT(*) AS n
    COUNT(*) AS n_numeric,
    COUNT(DISTINCT measurement_concept_id) AS n_concepts,
    SUM(CASE WHEN COALESCE(m.unit_concept_id, 0) = 0 THEN 1 ELSE 0 END) AS n_no_unit_concept,
    SUM(CASE WHEN COALESCE(m.unit_concept_id, 0) = 0
              AND m.unit_source_value IS NULL THEN 1 ELSE 0 END) AS n_no_unit_at_all,
    COUNT(DISTINCT m.unit_concept_id) AS n_unit_concepts,
    COUNT(DISTINCT m.data_partner_id) AS n_partners,
    SUM(CASE WHEN m.range_high IS NOT NULL THEN 1 ELSE 0 END) AS n_with_ref_range
  FROM ehr_union_clean.measurement m
  WHERE m.value_as_number IS NOT NULL
  GROUP BY 1
  ORDER BY 4 DESC
```
|unit_source_value|n_numeric|n_concepts|n_no_unit_concept|n_no_unit_at_all|n_unit_concepts|n_partners|n_with_ref_range|
|---|---|---|---|---|---|---|---|
|null|1466178|374|1272255|1272255|10|3|205838|
|mL/min/1.73m²|11805|2|11805|0|1|1|0|
|ms|7028|1|7028|0|0|1|0|
|degrees|5185|1|5185|0|0|1|0|
|mL/min/1.73 m2|15838|4|3915|0|1|3|14|
|BPM|3510|1|3510|0|0|1|0|
|mL/hr|2469|2|2469|0|1|1|0|
|cm|68893|8|2374|0|1|2|0|
|L|3057|3|1896|0|1|2|0|
|mL/min/{1.73_m2}|1609|1|1609|0|0|1|0|
|cGray|1500|1|1500|0|0|1|0|
|liter/min/m2|1424|1|1424|0|1|1|0|
|mg/g{creat}|1164|1|1164|0|0|1|1164|
|mL/min/1.73_m2|1091|1|1091|0|0|1|0|
|E.U./dL|706|1|706|0|0|1|706|
|cm/sec|704|1|704|0|0|1|0|
|Gray|656|1|656|0|0|1|0|
|Gy (RBE)|640|1|640|0|0|1|0|
|Leu/uL|599|2|599|0|0|1|0|
|IU gamma IF/mL|511|1|511|0|0|1|0|
|nmol/L|1641|25|470|0|1|2|1040|
|ml/min/mmHg|432|1|432|0|0|1|0|
|L/sec|420|1|420|0|0|1|0|
|mL/min|11106|6|384|0|1|3|37|
|'C|338|1|338|0|0|1|0|
|ft|325|1|325|0|1|1|0|
|Unit%|241|1|241|0|0|1|0|
|L/min|30249|7|189|0|1|2|0|
|k[IU]/L|186|1|186|0|0|1|184|
|Urine|161|1|161|0|0|1|0|
|bpm|167800|8|152|0|2|3|0|
|ppm|151|1|151|0|1|1|0|
|ml/min/mmHg/L|148|1|148|0|0|1|0|
|10*9/L|144|1|144|0|0|1|144|
|PBPM|139|1|139|0|1|1|0|
|%PCV|124|2|124|0|0|1|124|
|ug{FEU}/mL|118|1|118|0|0|1|118|
|V|111|1|111|0|0|1|0|
|mA|104|2|104|0|1|1|0|
|VOL%|102|1|102|0|0|1|48|
|EU/dL (mg/dL)|92|1|92|0|0|1|0|
|mm Hg|1562|7|86|0|1|2|82|
|mosm/kg|78|1|78|0|0|1|77|
|% of CD19|76|7|76|0|0|1|76|
|mIU/mL|821|10|75|0|2|3|36|
|mg/g Creat|71|1|71|0|0|1|71|
|Ohm|68|1|68|0|0|1|0|
|min|57|2|57|0|0|1|41|
|{Log_copies}/mL|52|1|52|0|0|1|0|
|mV|51|3|51|0|1|2|0|
|mCi|50|1|50|0|0|1|0|
|mm|25775|8|50|0|1|2|178|
|*Not Applicable|50|1|50|0|0|1|0|
|{Log}|49|1|49|0|0|1|0|
|FLU|46|4|46|0|0|1|46|
|U|46|2|45|0|1|2|44|
|{cells}|44|1|44|0|0|1|0|
|ATP ng/mL|42|1|42|0|0|1|0|
|mg/d|41|8|41|0|0|1|32|
|ISR|46|2|38|0|2|2|38|
|ug/(24.h)|37|1|37|0|0|1|37|
|mmol/24 hr|36|4|36|0|0|1|36|
|{Ehrlich'U}|33|2|33|0|0|1|0|
|yr|31|1|31|0|0|1|0|
|ml/m|30|1|30|0|0|1|0|
|log10|28|1|28|0|1|1|0|
|[IU]|23|2|23|0|0|1|0|
|GPL U/mL|22|2|22|0|0|2|1|
|% Lymphs|22|1|22|0|0|1|22|
|{Log_IU}/mL|22|1|22|0|0|1|0|
|ng/dL / pg/mL|21|1|21|0|1|1|0|
|weeks|21|1|21|0|0|1|0|
|ug/L|174|31|21|0|1|2|80|
|mil/ejaculate|20|1|20|0|0|1|7|
|Possible|19|1|19|0|0|1|19|
|minutes|18|1|18|0|0|1|0|
|MPL U/mL|17|2|17|0|0|2|3|
|cell/uL|16|1|16|0|0|1|15|
|IU|106|2|16|0|1|2|73|
|mg/kg|15|1|15|0|0|1|15|
|CU|14|3|14|0|1|1|14|
|mil sperm/mL|13|1|13|0|0|1|0|
|million|12|2|12|0|0|1|0|
|deg|1418|3|12|0|1|2|12|
|mL/beat|12|1|12|0|1|1|0|
|million/mL|12|4|12|0|0|1|0|
|d|11|1|11|0|0|1|11|
|g/24 hr|11|2|11|0|0|2|11|
|nmol/mmol|11|1|11|0|0|1|0|
|AU/mL|230|21|11|0|1|3|128|
|nmol{BCE}/mmol{creat}|11|1|11|0|0|1|0|
|{ratio}|10|1|10|0|0|1|10|
|mL/m2/beat|10|1|10|0|1|1|0|
|g|10|1|10|0|0|1|0|
|%Hb|12|1|10|0|1|2|1|
|S/CO|10|2|10|0|0|1|0|
|meq/24 hr|9|1|9|0|0|1|9|
|dB/m|9|1|9|0|0|1|8|
|% donor|9|1|9|0|0|1|0|
|mg/24 hr/kg|9|1|9|0|0|1|9|
|kPa|9|1|9|0|0|1|8|
|[lb_av]|9|1|9|0|0|1|0|
|mL/24 hr|9|1|9|0|0|1|9|
|g/kg/24 hr|9|1|9|0|0|1|9|
|% fat|9|1|9|0|0|1|9|
|No|9|3|9|0|0|1|0|
|years|9|1|9|0|0|1|0|
|a|8|1|8|0|0|1|0|
|MPS|7|1|7|0|0|1|7|
|GPS|7|1|7|0|0|1|7|
|meq/(24.h)|7|1|7|0|0|1|7|
|X 10E3/mm3|7|7|7|0|0|1|7|
|U/g{Hb}|6|1|6|0|0|1|6|
|{index_val}|6|1|6|0|0|1|6|
|cmH2O|6|1|6|0|0|1|0|
|lbs|6|1|6|0|0|1|0|
|Ohms|6|1|6|0|0|1|3|
|mcg/g|9|3|6|0|1|2|0|
|PharmD|5|1|5|0|0|1|0|
|mo|5|1|5|0|0|1|0|
|APL|5|1|5|0|0|1|4|
|OD|5|1|5|0|0|1|0|
|METS|5|1|5|0|0|1|0|
|umol/mol|5|1|5|0|0|1|5|
|MD|5|1|5|0|0|1|0|
|dynes-sec/cm5/m2|5|1|5|0|1|1|0|
|SD|5|2|5|0|0|2|4|
|ug/min|5|1|5|0|0|1|5|
|TSI Index|4|1|4|0|0|1|4|
|Bands|4|1|4|0|0|1|4|
|**Please|4|1|4|0|0|1|4|
|mL/min/1.73m2|393|7|4|0|1|2|0|
|calc|4|2|4|0|0|1|0|
|10*6/mL|4|1|4|0|0|1|2|
|m/m/1.73|4|1|4|0|0|1|0|
|cp/mL|4|1|4|0|0|1|0|
|ug/24 hr|4|2|4|0|0|1|4|
|hr|190|3|4|0|2|3|0|
|bil/L|4|1|4|0|0|1|4|
|APS|4|1|4|0|0|1|4|
|mL/min/1.72m*2|3|1|3|0|0|1|0|
|bands|3|1|3|0|0|1|1|
|ug Elast./g|3|1|3|0|0|1|0|
|TU|3|2|3|0|0|2|3|
|mg/g creat|419|4|3|0|1|2|383|
|mg/mg|3|1|3|0|0|1|3|
|mOsm/kg|29|3|3|0|1|3|29|
|uU/mL|187|5|3|0|1|2|179|
|mOsmol/kg|3|2|3|0|0|1|2|
|Degrees|3|1|3|0|0|1|3|
|mcg/24 h|3|1|3|0|0|1|3|
|ug/g creat|2|1|2|0|0|1|2|
|UI/L|2|1|2|0|0|1|2|
|Minutes|2|2|2|0|0|1|2|
|Normal|2|1|2|0|0|1|0|
|mmol/(24.h)|2|1|2|0|0|1|2|
|PHARMD|2|1|2|0|0|1|0|
|nmol|2|1|2|0|0|1|2|
|APL U/mL|2|1|2|0|0|1|0|
|ug Eq/mL|2|1|2|0|0|1|2|
|Dose|2|1|2|0|0|1|0|
|mg/24 hr|95|10|2|0|1|2|55|
|Index|92|6|2|0|1|3|90|
|mcg/mL FEU|2|1|2|0|0|1|2|
|g/24hr|2|1|2|0|0|1|0|
|Copies/mL|2|1|2|0|0|1|0|
|EHRLICH UNITS|2|1|2|0|0|1|0|
|ml/min/1.73m2|2|1|2|0|0|1|1|
|mg/24hr|2|1|2|0|0|1|0|
|mcg/mg|2|1|2|0|0|1|1|
|UI/mL|2|1|2|0|0|1|2|
|TBI|1|1|1|0|0|1|1|
|ng/mL/hr|35|1|1|0|1|2|0|
|days|1|1|1|0|0|1|1|
|mg/dL:|1|1|1|0|0|1|0|
|mil mot sperm|1|1|1|0|0|1|0|
|SMU|14|3|1|0|1|2|13|
|% normal|1|1|1|0|0|1|1|
|mWq/L|1|1|1|0|0|1|1|
|mL/min/1.73,2|1|1|1|0|0|1|0|
|MPL|12|2|1|0|1|2|10|
|U/mL{RBCs}|1|1|1|0|0|1|1|
|M/mcl|1|1|1|0|0|1|1|
|Corrected|1|1|1|0|0|1|0|
|mOsm/K|1|1|1|0|0|1|1|
|A/G Ratio|1|1|1|0|0|1|0|
|Performed|1|1|1|0|0|1|0|
|nM BCE/mM Creat|1|1|1|0|0|1|0|
|Dr|1|1|1|0|0|1|0|
|ACTIVITY COEFF|1|1|1|0|0|1|1|
|GPI IgG units|1|1|1|0|0|1|1|
|TAC|1|1|1|0|0|1|0|
|ARU|1|1|1|0|0|1|0|
|% Inhibition|1|1|1|0|0|1|0|
|mmol/{specimen}|1|1|1|0|0|1|1|
|30.0-100.0|1|1|1|0|0|1|0|
|Angstrom|1|1|1|0|0|1|0|
|meq/day|1|1|1|0|0|1|0|
|liters/day|1|1|1|0|0|1|0|
|ng/mL RBC|1|1|1|0|0|1|0|
|Buhlmann Titer Unit|1|1|1|0|0|1|0|
|not|1|1|1|0|0|1|0|
|LEU/uL|1|1|1|0|0|1|0|
|GPI IgM units|1|1|1|0|0|1|1|
|copies/mL|752|2|1|0|1|3|447|
|ng/mL ATP|1|1|1|0|0|1|0|
|POSSIBLE|1|1|1|0|0|1|1|
|AI|42|11|1|0|1|2|40|
|[in_i]|1|1|1|0|0|1|0|
|X 10E6/mm3|1|1|1|0|0|1|1|
|BU/mL|1|1|1|0|0|1|1|
|mL/min/173m2|1|1|1|0|0|1|0|
|mmol/g creat|1|1|1|0|0|1|1|
|mil sperm|1|1|1|0|0|1|0|
|mut/Mb|1|1|1|0|0|1|0|
|GPI IgA units|1|1|1|0|0|1|1|
|PRU|1|1|1|0|0|1|0|
|S.D.|1|1|1|0|0|1|0|
|{ARU}|1|1|1|0|0|1|1|
|mg/{specimen}|1|1|1|0|0|1|1|
|Month(s)|1|1|1|0|0|1|0|
|umol/g CRT|1|1|1|0|0|1|1|
|mmol/24 h|1|1|1|0|0|1|1|
|ug/mL(g)|1|1|1|0|0|1|1|
|ug/mL|1468|36|0|0|1|2|356|
|ng/L|2802|3|0|0|1|3|2255|
|mill/mm3|13080|1|0|0|1|1|11564|
|M/uL|5|1|0|0|1|1|5|
|cells|2|1|0|0|1|1|0|
|lb|121183|3|0|0|1|1|0|
|NG/DL|6|2|0|0|1|1|5|
|inch(es)|64372|1|0|0|1|1|0|
|br/min|121379|3|0|0|1|1|0|
|mg/L FEU|2|1|0|0|1|1|2|
|fL|63264|4|0|0|1|3|45789|
|beats per minute|637|1|0|0|1|1|0|
|mg/24 h|3|1|0|0|1|1|0|
|{copies}/mL|105|2|0|0|1|1|0|
|K/mcl|7|2|0|0|1|1|7|
|fl|6|2|0|0|1|1|6|
|mcg/dL|4275|13|0|0|1|3|4213|
|PG|9|1|0|0|1|1|9|
|umol/L|541|8|0|0|1|2|240|
|mIU/L|191|1|0|0|1|1|156|
|g/dl|2|2|0|0|1|1|2|
|[in_us]|35388|1|0|0|1|1|0|
|/min|449616|2|0|0|1|1|0|
|IU/L|3118|11|0|0|1|2|3117|
|SEC|4|2|0|0|2|1|4|
|ng/dl|2|1|0|0|1|1|2|
|MIU/ML|3|2|0|0|1|1|3|
|10^3/cmm|85237|9|0|0|1|1|79824|
|MCG/DL|2|2|0|0|1|1|2|
|U/ML|5|1|0|0|1|1|5|
|nMol/L|112|1|0|0|1|1|107|
|THOU/uL|2699|13|0|0|1|1|2648|
|MG/L|2|2|0|0|1|1|1|
|GPL|15|1|0|0|1|1|10|
|INDEX|20|3|0|0|1|1|5|
|log|10|3|0|0|1|1|0|
|THOU/ul|67|1|0|0|1|1|63|
|g/24 h|3|1|0|0|1|1|3|
|MEQ/L|7|3|0|0|1|1|4|
|inches|23942|1|0|0|1|1|23942|
|#/HPF|4|2|0|0|1|1|4|
|ug/g CRT|55|13|0|0|1|1|39|
|ng/dL|5198|17|0|0|1|3|4955|
|cmH20|13082|9|0|0|1|1|0|
|mOsm/kg H2O|119|2|0|0|1|1|119|
|mL|63923|29|0|0|1|3|38|
|UG/DL|6|3|0|0|1|1|6|
|ug/g|99|2|0|0|1|1|5|
|um3|13079|1|0|0|1|1|11577|
|Thousand/uL|760|2|0|0|1|1|760|
|g/dL (calc)|489|1|0|0|1|1|489|
|MILL/MCL|5|1|0|0|1|1|5|
|Historical_inch(es)|1|1|0|0|1|1|0|
|[degC]|86|1|0|0|1|1|0|
|X10E3/UL|32|8|0|0|1|1|32|
|thous/mcL|3|1|0|0|1|1|3|
|ml|355|2|0|0|1|1|0|
|mmol/day|26|3|0|0|1|1|26|
|[IU]/mL|1783|22|0|0|1|2|367|
|sec|7209|14|0|0|2|2|6046|
|pg/dL|1|1|0|0|1|1|1|
|hours|326|1|0|0|2|1|282|
|UNITS|3|1|0|0|1|1|0|
|pmol/L|21|6|0|0|1|2|17|
|ng/mL|30995|90|0|0|1|3|21057|
|IV|34|22|0|0|1|1|6|
|msec|9862|3|0|0|1|1|0|
|U/g Hgb|2|1|0|0|1|1|1|
|kg/m2|182908|2|0|0|1|2|0|
|ratio|557|10|0|0|1|2|556|
|/HPF|24|2|0|0|1|2|0|
|week(s)|23|1|0|0|1|1|0|
|ratio units|10|2|0|0|1|1|10|
|10^6/cmm|20263|3|0|0|1|1|19639|
|mInt-unit(s)/mL|4605|7|0|0|1|1|4434|
|ug/dL|5917|19|0|0|1|2|5309|
|UIU/ML|5|1|0|0|1|1|5|
|IntUnits/mL|532|14|0|0|1|1|468|
|mm/h|843|1|0|0|1|2|808|
|SGU|13|2|0|0|1|1|12|
|gm/dl|14|2|0|0|1|1|4|
|mEq/L|3750|20|0|0|2|3|3706|
|EU/dl|21|1|0|0|1|1|21|
|copy/mL|22|2|0|0|1|1|0|
|U/L|58404|25|0|0|1|2|55289|
|mmol/l|14|6|0|0|1|1|11|
|meq/L|49320|21|0|0|1|1|49210|
|mcg/dL (calc)|18|1|0|0|1|1|18|
|PG/ML|5|1|0|0|1|1|5|
|IU/ml|2|1|0|0|1|1|0|
|kU/L|1414|135|0|0|1|1|0|
|degree|461|2|0|0|1|1|152|
|mm[Hg]|288473|11|0|0|1|2|384|
|DegF|84084|1|0|0|1|1|0|
|minute(s)|301|2|0|0|1|1|301|
|MM/HR|1|1|0|0|1|1|1|
|ml/min/1.73|1|1|0|0|1|1|0|
|h|172|2|0|0|1|1|0|
|Log (cells/mL)|1|1|0|0|1|1|0|
|Log copies/mL|3|1|0|0|1|1|0|
|THOUS/MCL|25|7|0|0|1|1|25|
|units|23|5|0|0|1|1|23|
|meq/l|4|3|0|0|1|1|3|
|U/mL|926|43|0|0|1|2|527|
|MG/DL|92|21|0|0|1|2|71|
|mg/dL (calc)|598|4|0|0|1|1|18|
|uIU/mL |5|1|0|0|1|1|0|
|log IU/mL|4|1|0|0|1|1|0|
|kg|190316|5|0|0|1|2|0|
|mL/min/1.73|1166|9|0|0|2|2|0|
|breaths/minute|263|1|0|0|1|1|0|
|s/co ratio|97|2|0|0|1|1|97|
|mg/dl|156|10|0|0|1|2|55|
|kIntUnits/L|55|1|0|0|1|1|55|
|DegC|36782|2|0|0|1|1|0|
|seconds|12|1|0|0|1|1|2|
|pg/mL|11391|57|0|0|1|3|10395|
|10^3|157|1|0|0|1|1|0|
|mg/L |9|2|0|0|1|1|6|
|SECONDS|1|1|0|0|1|1|1|
|ng/ml|1|1|0|0|1|1|1|
|pg|30418|3|0|0|1|3|30415|
|mmol/L|92193|37|0|0|1|2|82210|
|% of total Hgb|280|1|0|0|1|1|38|
|Log cells/mL|3|3|0|0|1|1|0|
|uIU/mL|4374|6|0|0|1|2|3949|
|/uL|23|7|0|0|1|1|23|
|mil/uL|514|1|0|0|1|1|514|
|Million/uL|382|1|0|0|1|1|382|
|mcg/min|9|1|0|0|1|1|9|
|Log10 IU/mL|32|2|0|0|1|1|0|
|[IU]/L|59|7|0|0|1|2|12|
|mcmol/L|142|3|0|0|1|1|140|
|cP|1|1|0|0|1|1|0|
|mcIntUnits/mL|458|4|0|0|1|1|458|
|[lb_us]|41320|1|0|0|1|1|0|
|mOsm/Kg|78|3|0|0|1|1|71|
|mg/24H|169|9|0|0|1|1|126|
|mcg/mgCr|664|1|0|0|1|1|52|
|SAU|6|1|0|0|1|1|5|
|mg|2|1|0|0|1|1|0|
|nm|429|4|0|0|1|1|0|
|/100_WBC|237|1|0|0|1|1|169|
|/cmm|1407|8|0|0|1|1|1362|
|mcg/mg creat|47|1|0|0|1|1|0|
|Log10 copies/mL|55|2|0|0|1|1|0|
|mcg/L|95|5|0|0|1|2|28|
|mg/(24.h)|104|1|0|0|1|1|104|
|sec |778|1|0|0|2|1|0|
|mg/g|2|2|0|0|1|1|1|
|nMol/mL|7|1|0|0|1|1|7|
|Ratio|4|1|0|0|1|1|4|
|%|982794|182|0|0|2|3|367304|
|Units/L|40450|11|0|0|1|1|40438|
|/[HPF]|11|1|0|0|1|1|0|
|ML|1|1|0|0|1|1|0|
|[U]/L|13806|2|0|0|1|1|12415|
|% baseline|1|1|0|0|1|1|0|
|u/L|7|1|0|0|1|1|0|
|ng/mL D-DU|160|2|0|0|1|1|0|
|{cells}/uL|88|3|0|0|1|1|47|
|IU/mL|285|20|0|0|1|2|103|
|mm[Hg][|236|1|0|0|1|1|0|
|u[IU]/mL|3766|2|0|0|1|1|3766|
|mcg/mL|932|19|0|0|1|3|577|
|/LPF|529|8|0|0|1|1|0|
|secs|3|1|0|0|1|1|0|
|MPL-Units/mL|31|1|0|0|1|1|31|
|AU/ML|1|1|0|0|1|1|0|
|log cpy/mL|3|2|0|0|1|1|0|
|mm [Hg][|243|1|0|0|1|1|0|
|unit(s)/mL|861|8|0|0|1|1|286|
|gm/dL|86191|21|0|0|1|3|84234|
|mg.dl|1|1|0|0|1|1|1|
|mm3|212|11|0|0|1|1|40|
|ng/mL/h|23|1|0|0|1|2|1|
|second(s)|10788|13|0|0|1|1|7108|
|ounces|74702|2|0|0|1|1|74588|
|[score]|42981|1|0|0|1|1|0|
|MMOL/L|20|4|0|0|1|1|20|
|g/L|4|2|0|0|1|1|2|
|1000/mm3|89077|21|0|0|1|1|63732|
|/100 WBC|236|2|0|0|1|1|0|
|mU/mL|30|1|0|0|1|1|30|
|beats/minute|263|1|0|0|1|1|0|
|g/d|33|3|0|0|1|1|33|
|Units|132|17|0|0|1|1|129|
|x10E3/uL|9398|12|0|0|1|2|9398|
|mm/hr|2190|3|0|0|1|3|2056|
|ng/mL DDU|363|1|0|0|1|1|363|
|FL|14|3|0|0|1|1|14|
|unit(s)|893|11|0|0|1|1|893|
|cells/uL|3151|22|0|0|1|1|2851|
|nmol/min/mL|1|1|0|0|1|1|1|
|/hpf|59|5|0|0|1|1|54|
|uMol/L|21|1|0|0|1|1|20|
|% (calc)|19|2|0|0|1|1|18|
|mill/mcl|3|1|0|0|1|1|3|
|x10E6/uL|1258|1|0|0|1|2|1258|
|X10E6/UL|4|1|0|0|1|1|4|
|EIA Units|127|2|0|0|1|1|0|
|g/mL|1909|2|0|0|1|1|1909|
|[degF]|134509|1|0|0|1|1|0|
|mL/min/1.73.m2|4864|1|0|0|1|1|0|
|pgm|13061|1|0|0|1|1|11566|
|mg/mg creat|8|1|0|0|1|1|8|
|log10copy/mL|1|1|0|0|1|1|0|
|m2|63658|3|0|0|1|1|0|
|mMol/L|134153|39|0|0|1|2|129920|
|g/dL|86092|25|0|0|1|2|81725|
|[diop]|3058|4|0|0|1|1|0|
|cpy/mL|12|5|0|0|1|1|0|
|mg/dL|460967|127|0|0|1|3|367187|
|GPL-Units/mL|30|1|0|0|1|1|30|
|thous/mcl|18|10|0|0|1|1|18|
|mL/day|1|1|0|0|1|1|0|
|mmHg|598399|41|0|0|1|3|153870|
|10*3/uL|56676|14|0|0|1|2|56669|
|10*6/uL|8500|1|0|0|1|2|8500|
|s|2678|5|0|0|1|1|2579|
|m[IU]/mL|421|5|0|0|1|1|129|
|K/uL|39|8|0|0|1|1|39|
|nmol/mL|2|2|0|0|1|1|2|
|CELLS/uL|4|2|0|0|1|1|0|
|G/L|1|1|0|0|1|1|0|
|dynes-sec/cm5|2617|4|0|0|1|1|0|
|pg/ml|4|3|0|0|1|2|3|
|vol %|758|3|0|0|1|1|362|
|VOL_%|2777|4|0|0|1|1|0|
|S/CO RATIO|2|1|0|0|1|1|2|
|(calc)|872|4|0|0|1|1|587|
|mcMol/L|136|2|0|0|1|1|136|
|ug/d|42|11|0|0|1|1|30|
|G/DL|52|7|0|0|1|2|52|
|mg/L|7176|26|0|0|1|3|6926|
|index|36|5|0|0|1|1|4|
|mg/gCR|2|1|0|0|1|1|2|
|x10e6/mL|3|3|0|0|1|1|0|
|LIV|5|1|0|0|1|1|5|
|ML/MIN/1.73|7|3|0|0|1|1|0|
|NG/ML|25|6|0|0|1|1|20|

</details>

<details>
<summary><strong>Sizing query with m.unit_source_value IS NULL AND m.range_high IS NOT NULL</strong></summary>

|measurement_concept_id|concept_name|n_numeric|n_no_unit_concept|n_no_unit_at_all|n_unit_concepts|n_partners|n_with_ref_range|cum_share_rows|cum_share_no_unit|
|---|---|---|---|---|---|---|---|---|---|
|3027018|Heart rate|73284|73284|73284|0|1|73284|0.35602755565056016|0.35602755565056016|
|3024171|Respiratory rate|44208|44208|44208|0|1|44208|0.5707983948542057|0.5707983948542057|
|3020891|Body temperature|40351|40351|40351|0|1|40351|0.7668311973493719|0.7668311973493719|
|3045716|Anion gap in Serum or Plasma by calculation|12833|12833|12833|0|1|12833|0.8291763425606545|0.8291763425606545|
|3029991|Specific gravity of Urine by Refractometry automated|7546|7546|7546|0|2|7546|0.8658362401500209|0.8658362401500209|
|3022621|pH of Urine by Test strip|6738|6738|6738|0|2|6738|0.898570720663823|0.898570720663823|
|3029305|pH of Urine by Automated test strip|3977|3977|3977|0|3|3977|0.9178917401062971|0.9178917401062971|
|3019977|pH of Arterial blood|3170|3170|3170|0|3|3170|0.9332922006626571|0.9332922006626571|
|3022217|INR in Platelet poor plasma by Coagulation assay|1719|1719|1719|0|2|1719|0.941643428327131|0.941643428327131|
|0|No matching concept|1633|1633|1633|0|1|1633|0.9495768516989088|0.9495768516989088|
|3018311|Urea nitrogen/Creatinine [Mass Ratio] in Serum or Plasma|1624|1624|1624|0|2|1624|0.9574665513656371|0.9574665513656371|
|3020509|Albumin/Globulin [Mass Ratio] in Serum or Plasma|954|954|954|0|2|954|0.9621012641008949|0.9621012641008949|
|3033543|Specific gravity of Urine|904|904|904|0|2|904|0.9664930673636549|0.9664930673636549|
|3012544|pH of Venous blood|864|864|864|0|2|864|0.9706905430484167|0.9706905430484167|
|3029473|pH of Arterial blood adjusted to patient's actual temperature|791|791|791|0|1|791|0.9745333709033317|0.9745333709033317|
|3030091|pH of Blood adjusted to patient's actual temperature|626|626|626|0|1|626|0.9775745974990041|0.9775745974990041|
|3015736|pH of Urine|608|608|608|0|3|608|0.9805283766845772|0.9805283766845772|
|3004789|Transferrin [Mass/volume] in Serum or Plasma|559|559|559|0|1|559|0.9832441045871024|0.9832441045871024|
|40757349|CD3+CD4+ (T4 helper) cells/CD3+CD8+ (T8 suppressor cells) cells [# Ratio] in Blood|496|496|496|0|1|496|0.9856537665542805|0.9856537665542805|
|3000330|Specific gravity of Urine by Test strip|472|472|472|0|1|472|0.9879468319746597|0.9879468319746597|
|3038999|pH of Venous blood adjusted to patient's actual temperature|459|459|459|0|1|459|0.9901767409321894|0.9901767409321894|
|3045462|Protein/Creatinine [Ratio] in Urine|360|360|360|0|1|360|0.9919256891341734|0.9919256891341734|
|3004410|Hemoglobin A1c/Hemoglobin.total in Blood|265|265|265|0|1|265|0.9932131093384118|0.9932131093384118|
|3019230|Fractional oxyhemoglobin in Venous blood|220|220|220|0|1|220|0.994281911017402|0.994281911017402|
|3053209|Kappa light chains.free/Lambda light chains.free [Mass Ratio] in Serum|167|167|167|0|1|167|0.9950932286555446|0.9950932286555446|
|3014007|Fractional oxyhemoglobin in Arterial blood|156|156|156|0|1|156|0.9958511062097377|0.9958511062097377|
|3039919|Specific gravity of Urine by Automated test strip|146|146|146|0|1|146|0.9965604018694313|0.9965604018694313|
|3051593|INR in Capillary blood by Coagulation assay|142|142|142|0|1|142|0.9972502647713251|0.9972502647713251|
|3034485|Albumin/Creatinine [Mass Ratio] in Urine|118|118|118|0|2|118|0.9978235311264199|0.9978235311264199|
|3006473|Urobilinogen [Units/volume] in Urine by Test strip|114|114|114|0|1|114|0.9983773647237147|0.9983773647237147|
|3037816|CD4+CD8+ cells/cells in Blood|78|78|78|0|1|78|0.9987563035008113|0.9987563035008113|
|21492175|Heart transplant acute cellular rejection risk [Score] in Mononuclear cells Calculated by AlloMap|27|27|27|0|1|27|0.9988874746159602|0.9988874746159602|
|3032186|pH of Venous cord blood adjusted to patient's actual temperature|21|21|21|0|1|21|0.9989894965944092|0.9989894965944092|
|3030109|pH of Arterial cord blood adjusted to patient's actual temperature|18|18|18|0|1|18|0.9990769440045084|0.9990769440045084|
|3032080|INR in Blood by Coagulation assay|12|12|12|0|2|12|0.9991352422779078|0.9991352422779078|
|3009744|MCHC [Entitic Mass/volume] in Red Blood Cells by Automated count|12|12|12|0|1|12|0.9991935405513074|0.9991935405513074|
|3014094|Carbon dioxide, total [Moles/volume] in Blood|11|11|11|0|1|11|0.9992469806352569|0.9992469806352569|
|3012030|MCH [Entitic mass] by Automated count|11|11|11|0|1|11|0.9993004207192063|0.9993004207192063|
|3013682|Urea nitrogen [Mass/volume] in Serum or Plasma|11|11|11|0|1|11|0.9993538608031559|0.9993538608031559|
|3015501|pH of 24 hour Urine|10|10|10|0|1|10|0.9994024426976554|0.9994024426976554|
|3000905|Leukocytes [#/volume] in Blood by Automated count|10|10|10|0|1|10|0.999451024592155|0.999451024592155|
|3031809|Calcium hydrogen phosphate dihydrate [Saturation Fraction] in 24 hour Urine|9|9|9|0|1|9|0.9994947482972046|0.9994947482972046|
|3032612|Calcium oxalate index in 24 hour Urine|9|9|9|0|1|9|0.9995384720022542|0.9995384720022542|
|3028288|Cholesterol in LDL [Mass/volume] in Serum or Plasma by calculation|8|8|8|0|2|8|0.9995773375178538|0.9995773375178538|
|3020416|Erythrocytes [#/volume] in Blood by Automated count|8|8|8|0|1|8|0.9996162030334534|0.9996162030334534|
|3000551|Thyroxine (T4) free index in Serum or Plasma by calculation|7|7|7|0|1|7|0.9996502103596032|0.9996502103596032|
|3023599|MCV [Entitic mean volume] in Red Blood Cells by Automated count|7|7|7|0|1|7|0.9996842176857529|0.9996842176857529|
|3023884|Cholesterol in HDL/Cholesterol.total [Mass Ratio] in Serum or Plasma|6|6|6|0|1|6|0.9997133668224526|0.9997133668224526|
|3046171|Beta 2 glycoprotein 1 IgM Ab [Units/volume] in Serum or Plasma by Immunoassay|4|4|4|0|1|4|0.9997327995802524|0.9997327995802524|
|3008598|Thyroxine (T4) free [Mass/volume] in Serum or Plasma|4|4|4|0|1|4|0.9997522323380522|0.9997522323380522|
|3010156|C reactive protein [Mass/volume] in Serum or Plasma by High sensitivity method|4|4|4|0|1|4|0.999771665095852|0.999771665095852|
|3024561|Albumin [Mass/volume] in Serum or Plasma|3|3|3|0|1|3|0.999786239664202|0.999786239664202|
|3035995|Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma|3|3|3|0|1|3|0.9998008142325518|0.9998008142325518|
|3015632|Carbon dioxide, total [Moles/volume] in Serum or Plasma|3|3|3|0|1|3|0.9998153888009017|0.9998153888009017|
|3028833|Bilirubin.total [Mass/volume] in Blood|3|3|3|0|1|3|0.9998299633692516|0.9998299633692516|
|3020630|Protein [Mass/volume] in Serum or Plasma|3|3|3|0|1|3|0.9998445379376014|0.9998445379376014|
|3024128|Bilirubin.total [Mass/volume] in Serum or Plasma|3|3|3|0|1|3|0.9998591125059513|0.9998591125059513|
|3016991|Thyroxine (T4) [Mass/volume] in Serum or Plasma|3|3|3|0|1|3|0.9998736870743011|0.9998736870743011|
|3019897|Erythrocyte [DistWidth] in Red Blood Cells by Automated count|2|2|2|0|1|2|0.999883403453201|0.999883403453201|
|3043722|Hyaline casts [#/area] in Urine sediment by Automated count|2|2|2|0|1|2|0.9998931198321009|0.9998931198321009|
|3018672|pH of Body fluid|2|2|2|0|1|2|0.9999028362110008|0.9999028362110008|
|3003741|Lipoprotein.pre-beta [Mass/volume] in Serum or Plasma|2|2|2|0|1|2|0.9999125525899007|0.9999125525899007|
|3009596|Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation|1|1|1|0|1|1|0.9999174107793507|0.9999174107793507|
|3044491|Cholesterol non HDL [Mass/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999222689688007|0.9999222689688007|
|3006923|Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999271271582507|0.9999271271582507|
|3000034|Microalbumin [Mass/volume] in Urine|1|1|1|0|1|1|0.9999319853477007|0.9999319853477007|
|40763912|Albumin [Mass/volume] in Serum or Plasma by Bromocresol green (BCG) dye binding method|1|1|1|0|1|1|0.9999368435371506|0.9999368435371506|
|3006906|Calcium [Mass/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999417017266006|0.9999417017266006|
|3021492|IgG/Albumin [Mass Ratio] in Serum|1|1|1|0|1|1|0.9999465599160505|0.9999465599160505|
|3019150|Specific gravity of Urine by Refractometry|1|1|1|0|1|1|0.9999514181055005|0.9999514181055005|
|3023103|Potassium [Moles/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999562762949504|0.9999562762949504|
|3005719|IgG [Mass/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999611344844004|0.9999611344844004|
|3034426|Prothrombin time (PT)|1|1|1|0|1|1|0.9999659926738503|0.9999659926738503|
|3007070|Cholesterol in HDL [Mass/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999708508633003|0.9999708508633003|
|3007164|IgA [Mass/volume] in Serum or Plasma|1|1|1|0|1|1|0.9999757090527502|0.9999757090527502|
|3000963|Hemoglobin [Mass/volume] in Blood|1|1|1|0|1|1|0.9999805672422002|0.9999805672422002|
|3046867|Alpha 1 antitrypsin phenotype [Interpretation] in Serum or Plasma|1|1|1|0|1|1|0.9999854254316501|0.9999854254316501|
|3027970|Globulin [Mass/volume] in Serum by calculation|1|1|1|0|1|1|0.9999902836211001|0.9999902836211001|
|3024929|Platelets [#/volume] in Blood by Automated count|1|1|1|0|1|1|0.99999514181055|0.99999514181055|
|3013721|Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma|1|1|1|0|1|1|1|1|

</details>
