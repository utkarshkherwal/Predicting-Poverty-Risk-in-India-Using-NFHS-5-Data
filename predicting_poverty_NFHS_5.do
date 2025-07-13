*******************************************************
* Stata Script: Predicting Household Poverty (NFHS-5)
* Data file: IAHR74FL.DTA
* Author: utkarshkherwal
* Date: 2025-07-13
*******************************************************

*-----------------------------Import and Explore Data-----------------------------*
clear
set more off

use "D:\GITHUB\New folder\Predicting Poverty Risk in India Using NFHS-5 Data\data\hh_master.dta", clear

egen max_edu = rowmax(hv109_01 hv109_02 hv109_03 hv109_04 hv109_05 hv109_06 hv109_07 hv109_08 hv109_09 hv109_10 hv109_11 hv109_12 hv109_13 hv109_14 hv109_15 hv109_16 hv109_17 hv109_18 hv109_19 hv109_20 hv109_21 hv109_22 hv109_23 hv109_24 hv109_25 hv109_26 hv109_27 hv109_28 hv109_29 hv109_30 hv109_31 hv109_32 hv109_33 hv109_34 hv109_35)



label define edulabel ///
    0 "no education" ///
    1 "incomplete primary" ///
    2 "complete primary" ///
    3 "incomplete secondary" ///
    4 "complete secondary" ///
    5 "higher" ///
    8 "don't know"
	
label values max_edu edulabel

* Quick overview of variables
describe hv270a hv206 hv205 hv221 hv208 hv212 hv213 max_edu hv024 hv025

summarize hv270a hv206 hv205 hv221 hv208 hv212 hv213 max_edu hv024 hv025



*-----------------------------Create Binary Target Variable: is_poor-----------------------------*
gen is_poor = .
replace is_poor = 1 if inlist(hv270a,1,2)
replace is_poor = 0 if inlist(hv270a,3,4,5)

label define poor_lbl 0 "Not poor" 1 "Poor"
label values is_poor poor_lbl

tab is_poor

*-----------------------------Recode Features-----------------------------*

* Electricity: binary (1 = yes, else 0)
gen electricity = hv206 == 1
label variable electricity "Household has electricity"

* Toilet facility: binary (1 = has toilet, else 0)
gen has_toilet = !inlist(hv205,0,.)
label variable has_toilet "Has toilet facility"

* Cooking fuel: binary (1 = clean fuel, else 0)
* Example clean fuels: LPG, natural gas, electricity, biogas (codes may differ by survey, adjust as needed)
gen clean_fuel = inlist(hv221,1,2,3,4,5) // example codes
label variable clean_fuel "Uses clean cooking fuel"

* TV ownership: binary
gen owns_tv = hv208 == 1
label variable owns_tv "Owns TV"

* Bicycle ownership: binary
gen owns_bicycle = hv212 == 1
label variable owns_bicycle "Owns bicycle"

* Motorcycle ownership: binary
gen owns_motorcycle = hv213 == 1
label variable owns_motorcycle "Owns motorcycle"

* Education level of head: treat as categorical
label variable max_edu "Education level of head"

* State: categorical
label variable hv024 "State"

* Urban/rural: binary
gen urban = hv025 == 1
label variable urban "Urban residence"

*-----------------------------Run Logit and Probit Models-----------------------------*

* Logit regression
logit is_poor electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle i.max_edu i.urban i.hv024

* Cluster standard errors by state
logit is_poor electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle i.max_edu i.urban, cluster(hv024)

* Probit regression
probit is_poor electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle i.max_edu i.urban i.hv024

* Cluster SEs by state
probit is_poor electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle i.max_edu i.urban, cluster(hv024)

*-----------------------------Marginal Effects-----------------------------*

* Logit marginal effects
margins, dydx(*) atmeans

* Probit marginal effects
margins, dydx(*) atmeans

*-----------------------------predicted probabilities----------------------------*

* Logit predicted probabilities
predict p_logit, pr
summarize p_logit

* Probit predicted probabilities
predict p_probit, pr
summarize p_probit

*-----------------------------model diagnostics-----------------------------*

* Hosmer-Lemeshow test for logit
estat gof, group(10)

****************************************************************************
*----------------------VISUALIZATIONS---------------------------------------
****************************************************************************


* Bar chart: predicted poverty by state
graph bar (mean) p_logit, over(hv024, label(angle(90) labsize(vsmall))) ///
    title("Avg. Predicted Poverty Probability by State (Logit)") ///
    ytitle("Predicted Probability")


* Bar chart: proportion poor by education level of head
graph bar (mean) is_poor, over(max_edu, label(angle(90) labsize(vsmall))) ///
    title("Poverty Rate by Head's Education Level") ///
    ytitle("Proportion Poor") ///
    blabel(bar, format(%9.2f))
	
label define urban 0 "Poor" 1 "Not Poor"
label values urban urban 

* Bar chart: proportion poor by urban/rural
graph bar (mean) is_poor, over(urban) ///
    title("Poverty Rate by Urban/Rural Residence") ///
    ytitle("Proportion Poor") ///
    blabel(bar, format(%9.2f)) ///
    legend(label(1 "Rural") label(2 "Urban"))
	
	
	

*--------------------------------------------correlation matrix--------------------------------------------*

*Create correlation matrix
corr electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle urban
matrix C = r(C)
matrix rownames C = electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle urban
matrix colnames C = electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle urban
heatplot C, ///
    title("Correlation Heatmap of Key Features") ///
    color(Reds)
heatplot C, ///
    title("Correlation Heatmap of Key Features") ///
    color(Reds) ///
    showvalues

*--------------------------------------------Visualization: Odds Ratios (Logit Model)--------------------------------------------*

* Bar chart of odds ratios for key binary features
esttab, eform label
estimates store logitmod
esttab logitmod using oddsratios.txt, eform replace
* Alternatively in Stata:
logit is_poor electricity has_toilet clean_fuel owns_tv owns_bicycle owns_motorcycle i.max_edu i.urban
esttab, eform
* For a simple odds ratio plot:
coefplot, eform vertical ///
    title("Feature Importance (Odds Ratios from Logit Model)") ///
    ytitle("Odds Ratio")
	
*--------------------------------------------Boxplot: Distribution of predicted poverty by state------------------------------*

graph box p_logit, over(hv024) ///
    title("Distribution of Predicted Poverty Probabilities by State") ///
    ytitle("Predicted Probability (Logit Model)") ///
    xsize(12)
	
*--------------------------------------------Model Performance Visualization------------------------------*
* ROC curve for logit
lroc

* Distribution of predicted probabilities by poverty status
twoway (kdensity p_logit if is_poor==1, lcolor(red) lpattern(solid)) ///
       (kdensity p_logit if is_poor==0, lcolor(blue) lpattern(dash)), ///
       legend(order(1 "Poor" 2 "Not Poor")) ///
       title("Predicted Probability of Poverty (Logit Model)") ///
       xtitle("Predicted probability") ytitle("Density")
****************************************************************************
*-----------------------------End of Analysis-----------------------------*
****************************************************************************