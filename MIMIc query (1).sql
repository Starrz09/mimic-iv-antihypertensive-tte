-- Target Trial Emulation: First-line antihypertensives in ICU
WITH
  eligible_admissions AS (
    SELECT DISTINCT
      a.subject_id,
      a.hadm_id,
      a.admittime AS time_zero,
      p.gender,
      p.anchor_age + (EXTRACT(YEAR FROM a.admittime) - p.anchor_year) AS age,
      a.race,
      a.insurance
    FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
    INNER JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
      ON a.subject_id = p.subject_id
    INNER JOIN `physionet-data.mimiciv_3_1_icu.icustays` i
      ON a.hadm_id = i.hadm_id  
    WHERE
      p.anchor_age + (EXTRACT(YEAR FROM a.admittime) - p.anchor_year) >= 18
      AND i.first_careunit LIKE '%ICU%'
      AND NOT EXISTS(
        SELECT 1
        FROM `physionet-data.mimiciv_3_1_hosp.prescriptions` prior
        WHERE
          prior.subject_id = a.subject_id
          AND prior.starttime >= DATE_SUB(a.admittime, INTERVAL 6 MONTH)
          AND prior.starttime < a.admittime
          AND LOWER(prior.drug)
            IN (
              'lisinopril', 'amlodipine', 'hydrochlorothiazide',
              'chlorthalidone')
      )
  ),
  first_drug AS (
    SELECT
      e.*,
      pr.drug,
      pr.starttime AS drug_start,
      ROW_NUMBER() OVER (PARTITION BY e.subject_id ORDER BY pr.starttime) AS rn,
      CASE
        WHEN LOWER(pr.drug) LIKE '%lisinopril%' THEN 'ACE-Inhibitor'
        WHEN LOWER(pr.drug) LIKE '%amlodipine%' THEN 'Calcium-Channel Blocker'
        ELSE 'Thiazide-like'
        END
        AS treatment
    FROM `eligible_admissions` e
    INNER JOIN `physionet-data.mimiciv_3_1_hosp.prescriptions` pr
      ON e.hadm_id = pr.hadm_id
    WHERE
      LOWER(pr.drug)
        IN (
          'lisinopril', 'lisinopril-hydrochlorothiazide', 'amlodipine',
          'amlodipine-benazepril', 'hydrochlorothiazide',
          'hydrochlorothiazide-lisinopril', 'hydrochlorothiazide-triamterene',
          'chlorthalidone')
      AND pr.starttime <= DATETIME_ADD(e.time_zero, INTERVAL 48 HOUR)
  ),
  assigned AS (SELECT * EXCEPT (rn) FROM `first_drug` WHERE rn = 1),
  outcomes AS (
    SELECT
      a.*,
      COALESCE(p.dod, DATETIME_ADD(a.time_zero, INTERVAL 30 DAY))
        AS censor_date,
      CASE
        WHEN p.dod <= DATETIME_ADD(a.time_zero, INTERVAL 30 DAY) THEN 1
        ELSE 0
        END
        AS death_30d,
      DATETIME_DIFF(
        COALESCE(p.dod, DATETIME_ADD(a.time_zero, INTERVAL 30 DAY)),
        a.time_zero,
        DAY)
        AS time_to_event,
      COALESCE(aki.aki_7d, 0) AS aki_7d,
      COALESCE(hyperk.hyperk_7d, 0) AS hyperk_7d
    FROM `assigned` a
    INNER JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
      ON a.subject_id = p.subject_id
    LEFT JOIN
      (
        SELECT k.subject_id, 1 AS aki_7d
        FROM `physionet-data.mimiciv_3_1_derived.kdigo_stages` k
        INNER JOIN `assigned` b
          ON k.subject_id = b.subject_id  
        WHERE
          k.aki_stage >= 1
          AND k.charttime >= b.time_zero  
          AND k.charttime <= DATETIME_ADD(
            b.time_zero, INTERVAL 7 DAY) 
        GROUP BY k.subject_id
      ) aki
      ON a.subject_id = aki.subject_id
    LEFT JOIN
      (
        
        SELECT l.subject_id, 1 AS hyperk_7d
        FROM `physionet-data.mimiciv_3_1_hosp.labevents` l
        INNER JOIN `assigned` b
          ON l.subject_id = b.subject_id
        WHERE
          l.itemid = 50983
          AND l.valuenum >= 5.5
          AND l.charttime >= b.time_zero
          AND l.charttime <= DATETIME_ADD(b.time_zero, INTERVAL 7 DAY)
        GROUP BY l.subject_id
      ) hyperk
      ON a.subject_id = hyperk.subject_id
  ),
  final AS (
    SELECT
      o.*,
      COALESCE(c.diabetes, 0) AS diabetes,
      COALESCE(c.ckd, 0) AS ckd,
      COALESCE(c.heart_failure, 0) AS heart_failure,
      COALESCE(c.prior_stroke, 0) AS prior_stroke
    FROM `outcomes` o
    LEFT JOIN
      (
        SELECT
          subject_id,
          MAX(CASE WHEN icd_code LIKE 'E1%' THEN 1 ELSE 0 END) AS diabetes,
          MAX(
            CASE
              WHEN
                icd_code LIKE 'N18%'
                OR icd_code LIKE 'I12%'
                OR icd_code LIKE 'I13%'
                THEN 1
              ELSE 0
              END)
            AS ckd,
          MAX(CASE WHEN icd_code LIKE 'I50%' THEN 1 ELSE 0 END)
            AS heart_failure,
          MAX(
            CASE
              WHEN
                icd_code LIKE 'I60%'
                OR icd_code LIKE 'I61%'
                OR icd_code LIKE 'I63%'
                THEN 1
              ELSE 0
              END)
            AS prior_stroke
        FROM `physionet-data.mimiciv_3_1_hosp.diagnoses_icd`
        WHERE icd_version = 10
        GROUP BY subject_id
      ) c
      ON o.subject_id = c.subject_id
  )

SELECT * FROM `final` ORDER BY subject_id;

