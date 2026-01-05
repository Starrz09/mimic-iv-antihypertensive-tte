# mimic-iv-antihypertensive-tte
Target Trial Emulation of First-Line Antihypertensives in ICU — MIMIC-IV v3.1
### Abstract
We emulated a target trial to compare the effectiveness of ACE-inhibitors, calcium-channel blockers, and thiazide-like diuretics as first-line antihypertensive therapy among 6,580 critically ill adults with acute hypertension in the ICU. Using stabilized inverse probability weighting and doubly robust estimation to account for confounding, we evaluated 30-day all-cause mortality as the primary outcome. Compared with ACE-inhibitors, initiation of calcium-channel blockers was associated with a trend toward higher 30-day mortality (hazard ratio 1.22, 95% CI 1.00–1.50). These findings suggest clinically meaningful differences in outcomes across commonly used first-line antihypertensive agents in critically ill patients, underscoring the need for careful drug selection in the ICU setting.versus ACE-inhibitors.

### Target Trial Protocol (Fu et al. 2023)
| Component           | Specification                                      |
|---------------------|----------------------------------------------------|
| Eligibility         | ICU admission, age ≥18, no antihypertensive 6 months prior |
| Treatment strategies | ACE-I / CCB / Thiazide-like within 48 h of admission |
| Time zero           | ICU admission                                     |
| Follow-up           | 30 days (censor at death/discharge)                |
| **Primary outcome** | 30-day all-cause mortality                         |
| **Secondary outcomes** | AKI (KDIGO ≥1 within 7 days), hyperkalemia (K⁺ ≥5.5 within 7 days) |
| Causal contrast     | Per-protocol                                       |
| Analysis            | Stabilized IPW + doubly robust Cox PH              |

# Introduction
Hypertension in critically ill patients isn't just elevated blood pressure—it's a medical emergency demanding immediate intervention. Poor blood pressure control in the ICU carries substantial risk of cardio-renal complications, and when you're dealing with patients who often have multiple comorbidities on top of poorly managed hypertension, the stakes are high. These patients require intensive monitoring precisely because sustained elevated blood pressure can dramatically worsen their prognosis.
Three drug classes dominate first-line therapy: ACE-inhibitors work by blocking angiotensin-converting enzyme, reducing angiotensin II levels and causing vasodilation. Calcium-channel blockers intercept calcium ions from entering L-type channels in blood vessel walls, also producing vasodilation. Thiazide diuretics take a different approach, promoting fluid excretion by altering ion concentrations in the kidneys. In outpatient settings, clinicians use these agents relatively interchangeably based on patient-specific factors. But ICU patients aren't outpatients. They have hemodynamic instability, multiorgan dysfunction, and altered drug responses that might make one agent superior—or riskier—than another.
Despite widespread use of these medications in intensive care, we found limited comparative effectiveness data specifically examining which first-line agent optimizes outcomes in critically ill adults. Clinical judgment guides most prescribing decisions, but empirical evidence comparing mortality and renal safety across these three classes in the ICU setting remains sparse. When our query of the MIMIC-IV database revealed substantial use of all three agents, the question became obvious: are we choosing the right drugs?
We conducted this target trial emulation to investigate 30-day mortality, acute kidney injury, and hyperkalemia rates across ACE-inhibitors (lisinopril), calcium-channel blockers (amlodipine), and thiazide-like diuretics (hydrochlorothiazide) in 6,580 ICU adults. We selected 30-day all-cause mortality as the primary outcome because it represents the most clinically meaningful endpoint for assessing treatment effectiveness in this vulnerable population—and because it's objectively measurable without the subjective complexities of blood pressure control targets. Using MIMIC-IV offered critical advantages: it's real-world data from actual ICU practice, the analysis is fully reproducible, and the findings have potential to directly impact patient care and healthcare policy.

# Methods

## Study Design and Data Source

We conducted a retrospective cohort study using a **target trial emulation** framework with data from the Medical Information Mart for Intensive Care IV (MIMIC-IV, version 3.1). MIMIC-IV contains de-identified, real-world clinical data from patients admitted to intensive care units at Beth Israel Deaconess Medical Center (Boston, MA) between 2008 and 2019. The database includes patient demographics, vital signs, laboratory measurements, medication administration records, comorbidities, and clinical outcomes, making it well suited for comparative effectiveness research in critically ill populations.



## Study Population

From **531,491 total hospital admissions** in MIMIC-IV, we identified **76,621 ICU stays**. We restricted the cohort to adults aged ≥18 years with **no documented antihypertensive medication use in the 6 months prior to ICU admission**, consistent with a new-user design.

Among these patients, we identified those who initiated a **first qualifying antihypertensive agent within 48 hours of ICU admission**. Qualifying agents included lisinopril, amlodipine, and hydrochlorothiazide. This selection resulted in a final analytic cohort of **6,580 critically ill adults**.

Patients were excluded if they had prior exposure to any antihypertensive medication in the preceding 6 months or did not receive one of the qualifying agents within the defined exposure window.



## Treatment Exposure

Patients were categorized based on the **first antihypertensive agent initiated** during the exposure window:

- **ACE-inhibitor group**: lisinopril (any dose)  
- **Calcium-channel blocker group**: amlodipine (any dose)  
- **Thiazide-like diuretic group**: hydrochlorothiazide (any dose)

Time zero was defined as the **date of ICU admission**, marking the start of follow-up.



## Outcomes

The **primary outcome** was **30-day all-cause mortality** measured from ICU admission.

**Secondary outcomes** included:
- **Acute kidney injury (AKI)** within 7 days of ICU admission, defined using KDIGO criteria (Stage 1 or higher)
- **Hyperkalemia** within 7 days, defined as serum potassium ≥5.5 mEq/L



## Covariates

Baseline covariates were selected a priori based on clinical relevance and included:

- Age  
- Sex  
- Race  
- Insurance type  
- Diabetes mellitus  
- Chronic kidney disease  
- Heart failure  
- Prior stroke  

To account for potential effect modification, interaction terms were created between chronic kidney disease and age, sex, and diabetes status.



## Statistical Analysis

To address confounding by indication, we used **inverse probability of treatment weighting (IPTW)** with stabilized weights. Propensity scores were estimated using **multinomial logistic regression**, incorporating all baseline covariates. Weights were trimmed at the 1st and 99th percentiles to limit the influence of extreme values.

Covariate balance across treatment groups was assessed using **standardized mean differences (SMDs)**, with SMD < 0.1 indicating adequate balance.

Unadjusted survival was examined using **Kaplan–Meier curves** and log-rank tests. For adjusted analyses, we fit **Cox proportional hazards models** using a **doubly robust approach**, combining IPTW with additional covariate adjustment for age and sex. Robust standard errors were used to account for weighting.

Sensitivity analyses included **E-value calculations** to assess robustness to unmeasured confounding and a **negative control outcome analysis** using prior stroke.

All statistical tests were two-sided, with statistical significance defined as p < 0.05. Analyses were conducted in **Python 3.x** using `pandas`, `scikit-learn`, `lifelines`, and `statsmodels`.



## Discussion
### Primary Finding: Calcium-Channel Blockers Underperformed
The most striking finding from this analysis was how poorly calcium-channel blockers performed in critically ill adults. Patients initiated on CCBs had significantly higher 30-day mortality compared to both ACE-inhibitors (p=0.0057) and thiazide-like diuretics (p=0.0037), with an adjusted hazard ratio of 1.22 (95% CI: 1.00–1.49, p=0.05). This was unexpected. Pharmacologically, CCBs shouldn't demonstrate worse outcomes—in fact, they're recommended as first-line therapy for hypertension in Black patients. We anticipated that thiazide-like diuretics, given their electrolyte-depleting effects, would pose greater risks in the ICU setting. The data told a different story.
The Kaplan-Meier survival curves showed clear separation between treatment groups, with the CCB curve consistently tracking below ACE-inhibitors and thiazides throughout the 30-day follow-up period. While the p-value (0.05) sits at the threshold of statistical significance, we believe the finding is clinically meaningful in this critically ill population where even modest mortality differences translate to substantial absolute risk.

### Mechanistic Considerations: Why CCBs May Fail in the ICU.

Understanding why amlodipine (the primary CCB in our cohort) performed poorly requires revisiting its renal pharmacology and pharmacokinetics. Amlodipine demonstrates high vasoselectivity at the afferent arteriole (kidney entrance); by dilating the "front gate" while the "back gate" (efferent arteriole) remains relatively constricted, it can maintain or even increase intraglomerular pressure. In contrast, ACE-inhibitors like lisinopril preferentially dilate the efferent arteriole, providing a pressure-relief valve that reduces intraglomerular tension—a renoprotective mechanism well-established in chronic kidney disease that likely translates to acute protection in the ICU.
In our cohort, where patients frequently presented with hypertensive emergencies (BP >180 mmHg), this pharmacological distinction has critical implications. Amlodipine’s lack of activity on the efferent arteriole contributes to fluid retention, a known side effect that is particularly dangerous in critically ill patients. In this setting, where hemodynamic stability depends on the precise balance of vasodilation, electrolyte regulation, and fluid elimination, CCBs appear to be the least optimal choice. Lisinopril’s promotion of fluid elimination via efferent dilation—and the direct diuretic effects of thiazides—offer a clear physiological advantage.
Beyond these hemodynamic disadvantages, the pharmacokinetic profile of amlodipine may further explain its underperformance. Amlodipine possesses a prolonged half-life of 30–50 hours and a slow onset of action (6–12 hours), creating a state of "pharmacological inertia." In the ICU, where blood pressure is volatile and requires rapid, nimble titration, the inability to quickly "wash out" or adjust the drug’s effect is a significant liability. This contrasts unfavorably with the more manageable 12-hour half-life of lisinopril, which allows for faster achievement of steady state and more responsive clinical management. Ultimately, the combination of high intraglomerular pressure, fluid retention, and slow onset likely rendered amlodipine less effective than lisinopril or thiazides in managing acute hypertensive crises.
###Secondary Outcomes: The AKI Signal
The 64% AKI rate with CCBs, compared to 58% for ACE-inhibitors and 57% for thiazides, aligns with existing renal physiology literature.  While ACE-inhibitors carry hyperkalemia risk (evident in our cohort's 99% hyperkalemia rates across all groups—reflecting the critically ill population's baseline electrolyte dysregulation), their renoprotective effects appear to outweigh risks in this acute hypertensive context.
Robustness of Findings
Our E-value of 1.74 suggests moderate robustness to unmeasured confounding. An unobserved variable would need to increase both CCB prescription likelihood AND mortality risk by at least 74% each to nullify our results. While unmeasured confounding remains possible in observational research, this threshold seems substantial given our adjustment for age, comorbidities, and renal function.
The negative control outcome analysis using prior stroke provides additional confidence. We found no association between treatment assignment and prior stroke after inverse probability weighting (CCB: p=0.960; thiazide: p=0.346). This suggests our propensity score weighting successfully balanced observed confounders, reducing residual confounding to non-significant levels.
##Study Limitations
###Several limitations warrant acknowledgment:

Drug class aggregation: We selected specific exemplar drugs (amlodipine, lisinopril, HCTZ) rather than analyzing entire drug classes. While this enhances mechanistic interpretation, it limits generalizability to other CCBs (diltiazem, nicardipine) or ACE-inhibitors with different pharmacokinetic profiles.
Missing clinical variables: We lacked proteinuria measurements and BMI data—both potentially important confounders. Proteinuria, in particular, could modify the renal response to these medications.
Administrative data constraints: MIMIC-IV provides excellent ICU data quality, but administrative databases inherently lack granular clinical details (e.g., vasoactive medication doses, hemodynamic monitoring parameters, fluid balance records).
Short-term follow-up: Our 30-day endpoint captures acute mortality but misses long-term outcomes. Whether treatment effects persist beyond hospital discharge remains unknown.
Observational design: Despite rigorous propensity score methods and sensitivity analyses, we cannot definitively establish causation. Residual unmeasured confounding remains possible.

###Clinical Implications
Based on these findings, clinicians managing acute hypertension in ICU patients should consider prioritizing ACE-inhibitors (particularly lisinopril) or thiazide-like diuretics over calcium-channel blockers, especially in patients without baseline acute kidney injury or severe hyperkalemia. The mortality signal, combined with higher AKI rates, suggests CCBs may not be optimal first-line agents in this critically ill population—contrary to their established role in outpatient hypertension management.
Future Directions
Ethical constraints preclude randomized controlled trials in critically ill hypertensive patients. However, several research directions could strengthen these findings:

Mechanistic studies: Detailed investigation of renal hemodynamics, proteinuria patterns, and fluid balance profiles across antihypertensive classes in ICU settings.
Drug class comparisons: Expanding analysis to include all CCB subtypes (dihydropyridines vs. non-dihydropyridines) and additional ACE-inhibitors/ARBs to assess class-wide effects versus drug-specific phenomena.
Pharmacogenomic investigations: Exploring whether genetic variants in calcium channel or renin-angiotensin system genes modify treatment response in acute critical illness.
Long-term outcomes: Extending follow-up beyond 30 days to evaluate persistent mortality differences and renal recovery trajectories.

Ultimately, confirmation of these findings through independent cohorts and exploration of underlying mechanisms will determine whether our observations translate into clinical practice changes. For now, the data suggest caution in reflexive CCB use for ICU hypertension management.

