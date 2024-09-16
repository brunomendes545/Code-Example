*****BRUNO MENDES****



*THE POINT OF THIS DOCUMENT IS TO SHOW SOME SIMPLE EXAMPLE ON DATA ANALYSIS TOPICS
*AND VISUALIZATIONS.

*HERE I ALSO APPLY SOME RELATIVELY ADVACED MICROECONOMETRIC METHODS*

*THIS IS A REPLICATION EXERCISE OF "Did Unilateral Divorce Laws Raise Divorce Rates? A Reconciliation and New 
*Results", (2006), by Justin Wolfers




*************************************************
*                     INDEX              		*
*************************************************
*A: Intrdoduction and considerations  			*
*B: Getting the Data     						*
*C: Looking at the data							*
*D1: Table 1: Replicating Friedberg				*
*D2:  Table 2: Authors favourite specification	*
*D3: Figure 3 replication						*
*E1: Addition number 1 : Oaxaca-Blinder			*
*E2: Addition number 1.2 : Oaxaca-Blinder		*
*E3: Addition number 2.1 : Gelbach decomposition*
*************************************************

*********************************************
*A: Intrdoduction and considerations       	*
*********************************************
/*
I start with the replication. Some parts done here, regarding replication, are not included in the report.

In the United States, coastal areas often exhibit distinct demographic characteristics, including higher levels of urbanization, greater population density, and more diverse socioeconomic conditions compared to their inland counterparts. One intriguing approach to understanding these differences is to examine the divorce rates by dividing the country into coastal and non-coastal regions. These differences could arguably influence marital stability in various ways, from economic opportunities and lifestyle choices to social norms and community support systems. By employing the Oaxaca-Blinder decomposition method to this coastal versus non-coastal  dichotomy, we aim to decompose the mean differences and understand what is being explained or not by some covariates that we have in the dataset. We also apply a Gelbach Decomposition.

Besides this we try something weith more and less conservative states.

*/
*********************************
*B: Getting the Data        	*
*********************************
capture cd "C:\Users\Bruno Mendes\OneDrive - ucp.pt\CLSBE\trim_4\Microeconometrics\Project\Data\DataAppendix"

*
pause off
clear
set mem 50m 
set matsize 400 
use "Divorce-Wolfers-AER.dta" 



*********************************
*C: Looking at the data         *
*********************************
/*
Relevant varibles for our work:
- st: Two letter state code. 
Note that data are coded to the state in which the divorce was granted.
- year: Year of observation
- div_rate: Annual divorces per 1000 people, 1956-1998
Source: Friedberg 1998 for 1968-88, and hand-entered data from annual editions of Vital Statistics for 1956-67 and 1989-98. These data reflect a count of administrative data, that is, new divorces granted, and reported to the NCHS.
- stpop: State population
Source: www.census.gov.
- lfdivlaw: Friedberg's divorce law reform date; 1900=pre-sample; 2000=yet to reform;
Source: Columns 1 and 4 of Table 1 in Friedberg 1998.
- years_unilateral: Years since lfdivlaw, partitioned into two-year intervals; -99=No change in sample
(year in the sample corresponds to before the reform year).
Top-coded to 15 years+, i.e., data further than 15 years from the reform date are considered
always to be 15 years.
- time: Year-1968 (matches Friedberg's trends)
- timesq: (Years since 1968)^2
- reform: Was this state a reform state? (Friedberg's coding)
- neighper: Percent of neighbouring states with unilateral divorce laws
-evdiv50: Ever-divorced rate 
Source: 1950 census (25-50 native born) 
-married_annual: Percentage of married among adults; linear interpolation from Census Source: extrap for AK, HI in 1950

*/

summarize

tab

*I have 2193 observations between 1956 to 1998. 
*From the data appendix I have individuals with age between 25 and 50
*Main topics written in the article summary

*Summary statistics output. Here I am only considering the period between 1956 and 1988 because that's the period I focus on our additions. Also this is the the period that the author focus is preferred model (table 2 replication). The variables used here are the ones used in the additions
 set more off
outreg2 using sumstat.doc if year>1955 & year<1989, replace sum(detail) keep (year st div_rate stpop married unilateral evdiv50 married_annual years_unilateral neighper ) eqkeep (N mean sd skewness p50 p75 p99) 

*************************************
*D1: Table 1: Replicating Friedberg *
*************************************
*Even though we are not reporting this table, because this results are not the most important in the paper, I will leave this here.


xi: reg div_rate unilateral divx* i.st i.year if year>1967 & year<1989 [w=stpop] 
//xi will be useful to create dummy varibles for state and year fixed effets
//w=stpop indicates that the analysis should consider each observation proportional to the value of stpop
//The regression created dummies with the name _Iyear or _Ist, let´s test it´s significance
outreg2 using divorceregfrid.doc, replace ctitle (Basic Specification) keep(unilateral) nocon adj dec(4) addtext(State FE, 216.5, Year FE, 89.3, State*time, No, State*times^2, No) title (Table 1: Friedberg's Results)
testparm _Iy*
testparm _Is*
//This concludes the replication of column one of table 1


xi i.st i.st*time i.year
reg div_rate unilateral divx* _I* if year>1967 & year<1989 [w=stpop]
outreg2 using divorceregfrid.doc, append ctitle(State-Specific Linear Trends) keep(unilateral) nocon adj dec(4) addtext(State FE, 191.6, Year FE, 95.3, State*time, 24.4, State*times^2, No)
testparm _Iy*
testparm _Ist_*
testparm _IstX*
//This concludes the replication of column tow of table 1

xi i.st i.st*time i.st*timesq i.year
reg div_rate unilateral divx* _I* if year>1967 & year<1989 [w=stpop]
outreg2 using divorceregfrid.doc, append ctitle(State-Specific Quadratic Trends) keep(unilateral) nocon adj dec(4) addtext(State FE, 129.1, Year FE, 9.0, State*time, 9.3, State*times^2, 6.6)
testparm _Iy*
testparm _Ist_*
testparm _IstXtime_*
testparm _IstXtimea*
//This concludes the replication of column 3 of table 1




***********************************************
*D2:  Table 2: Authors favourite specification*
***********************************************

*Make sure the packadge is installed, if not, run the following command:
*ssc install outreg2

//Table 2 shows authors preferred set of estimates, running equation (2) on an unbalanced panel of  divorce rates from 1956-88: 

*The first column of Table 2 reports results from a specification including only state and year fixed  effects as controls
xi i.years_unilateral i.st i.year
reg div_rate _I* if year>1955 & year<1989 [w=stpop] 
outreg2 using divorcereg.doc, replace ctitle (Basic Specification) keep(_Iyears_uni_*) nocon adj dec(4) addtext(State FE, 220.29, Year FE, 145.04, State*time, No, State*times^2, No) title (Table 1: Dynamic Effects of Adopting Unilateral Divorce Laws - (Replication of table 2))
testparm _Iyear_*
testparm _Ist_*


*the second adds state-specific time trends, and the third also includes quadratic statate specific time trends
xi i.years_unilateral i.st*time i.year
reg div_rate _I* if year>1955 & year<1989 [w=stpop] 
outreg2 using divorcereg.doc, append ctitle(State-Specific Linear Trends) keep(_Iyears_uni_*) nocon adj dec(4) addtext(State FE, 468.16, Year FE, 53.86, State*time, 49.43, State*times^2, No)
testparm _Iyear_*
testparm _Ist_*
testparm _IstXtime_*

xi i.years_unilateral i.st*time i.st*timesq i.year
reg div_rate _I*  if year>1955 & year<1989 [w=stpop] 
outreg2 using divorcereg.doc, append ctitle(State-Specific Quadratic Trends) keep(_Iyears_uni_*) nocon adj dec(4) addtext(State FE, 522.54, Year FE, 70.61, State*time, 55.55, State*times^2, 16.18)
testparm _Iyear_*
testparm _Ist_*
testparm _IstXtime_*
testparm _IstXtimea*

*The outreg2 gives a better output

***************************
*D3: Figure 3 replication *
***************************

*We beleive this graph is very helpful to undstand better the authors result. This code is based on the authors original code with some minor changes.

* Create the regressions and the Confidence intervals for the several specifications
xi i.st i.year i.years_unilateral
reg div_rate _I* if year>1955 & year<1989 [w=stpop]
gen effect1=0
for num 2/9: replace effect1=_b[_Iyears_uni_X] if _Iyears_uni_X==1
for any lower1 upper1: gen X=.
for X in num 2/9: replace upper1=_b[_Iyears_uni_X]+1.96*_se[_Iyears_uni_X] if _Iyears_uni_X==1
for X in num 2/9: replace lower1=_b[_Iyears_uni_X]-1.96*_se[_Iyears_uni_X] if _Iyears_uni_X==1

xi i.years_unilateral i.st*time i.year
reg div_rate time _I* if year>1955 & year<1989 [w=stpop]
testparm _Iy*
testparm _Ist_*
testparm _IstX*
gen effect2=0
for num 2/9: replace effect2=_b[_Iyears_uni_X] if _Iyears_uni_X==1
for any lower2 upper2: gen X=0 if years_unilateral<0
for X in num 2/9: replace upper2=_b[_Iyears_uni_X]+1.96*_se[_Iyears_uni_X] if _Iyears_uni_X==1
for X in num 2/9: replace lower2=_b[_Iyears_uni_X]-1.96*_se[_Iyears_uni_X] if _Iyears_uni_X==1

xi i.years_unilateral i.st*time i.st*timesq i.year
reg div_rate time timesq _I*  if year>1955 & year<1989 [w=stpop]
gen effect3=0
for num 2/9: replace effect3=_b[_Iyears_uni_X] if _Iyears_uni_X==1
for any lower3 upper3: gen X=.
for X in num 2/9: replace upper3=_b[_Iyears_uni_X]+1.96*_se[_Iyears_uni_X] if _Iyears_uni_X==1
for X in num 2/9: replace lower3=_b[_Iyears_uni_X]-1.96*_se[_Iyears_uni_X] if _Iyears_uni_X==1

replace years_unilateral=-3 if years_unilateral==-99 & uniform()>0.5
replace years_unilateral=-1 if years_unilateral==-99 
#delimit ;
twoway 
	(rarea lower2 upper2 years_unilateral, sort blcolor(ltbluishgray) bfcolor(ltbluishgray)) 
	(connected effect2 years_unilateral, sort msymbol(diamond) msize(large) clcolor(black) clwidth(medthick)) 
	(connected effect1 years_unilateral, sort msymbol(triangle) msize(medlarge) clcolor(dkgreen) clwidth(medthick)) 
	(connected effect3 years_unilateral, sort msymbol(square) msize(medlarge) mcolor(navy) clcolor(navy) clwidth(medthick))
	, 
	ytitle("Annual divorces per thousand people") 
	ylabel(-0.6(0.2)0.6, angle(horizontal) format(%9.1f)) 
	yline(0, lwidth(medium) lcolor(black)) 
	xtitle(Years since (until) adoption of Unilateral Divorce Laws) 
	xlabel(-3 "(3-4)" -1 "(1-2)" 1 "1-2" 3 "3-4" 5 "5-6" 7 "7-8" 9 "9-10" 11 "11-12" 13 "13-14" 15 ">=15") 
	legend(order(2 "State Trends" 1 "95% confidence interval - State Trends" 3 "No state trends" 4 "Quadratic state trends")position(bottom))
;
#delimit cr
replace years_unilateral=-99 if years_unilateral<0
pause
drop lower* upper* effect*

*Export the graph. Change the export directory to get it.
capture graph export "C:\Users\Bruno Mendes\OneDrive - ucp.pt\CLSBE\trim_4\Microeconometrics\Project\Graph.jpg", as(jpg) name("Graph") quality(100)

****************************************
*E1: Addition number 1 : Oaxaca-Blinder*
****************************************
*I beleive it would be interesting to dive into decomposing the divorce rates in the USA. In almost any topic, arguably, we can separate the country in tow different counties, the coastline and not coastal states. For example, one could expect that in coastal states, the divorce rate would be lower. Let's dive into this.

* Create the dummy variable
keep if year > 1955 & year < 1989
gen coastline = 0

* List of coastal states
local coastal_states "AK AL CA CT DE FL GA HI LA ME MD MA MS NH NJ NY NC OR PA RI SC TX VA WA"
* Set coastline to 1 for coastal states
foreach st in `coastal_states' {
    replace coastline = 1 if st == "`st'"
}

* Verify the changes
list st coastline if coastline == 1
list st coastline if coastline == 0

*Create an interaction term. See the written project for the motivation
gen unilateral_neighper = unilateral*neighper

* Run regression models with state and year fixed effects
xi: reg div_rate i.year
* Save the residuals
predict residuals, resid
*See the report for the motivation.

* Perform Oaxaca decomposition on the residuals
oaxaca resid unilateral stpop neighper unilateral_neighper  married_annual evdiv50 , by(coastline) weight(0) 




******************************************
*E2: Addition number 1.2 : Oaxaca-Blinder*
******************************************
*I were also interested on comparing the dirvoce rate between conservative and less conservative states. Arguably, we could expect more conservative states to have lower divorce rates. Let's look closer:
* Create the dummy variable for more conservative states (This is not a scientific division, just an intuitive one...for further reaserch we should read what the literature say's about this types of divisions)
local more_conservative_states "AL AK AZ AR GA ID IN KS KY LA MS MO MT NE NC ND OK SC SD TN TX UT VA WV WY"
local less_conservative_states "CA CO CT DE FL HI IL IA ME MD MA MI MN NV NH NJ NM NY OH OR PA RI VT WA WI"

* Create the dummy variable
gen conservative = 0

* Set conservative to 1 for more conservative states
foreach st in `more_conservative_states' {
    replace conservative = 1 if st == "`st'"
}

* Verify the changes
count if conservative == 1
count if conservative == 0

oaxaca resid unilateral stpop neighper unilateral_neighper  married_annual evdiv50 , by(conservative) weight(0) 

*We won't follow with this reaserch part on the written article because it would make the work to extensive for the pages we are recommended...


*************************************************
*E3: Addition number 2.1 : Gelbach decomposition*
*************************************************
*Base model
reg div_rate coastline 

gen beta1_base=_b[coastline] 
*Full model
*Try adding this unilateral.neighper

*xi: reg div_rate coastline unilateral stpop neighper unilateral_neighper  married_annual evdiv50 
reghdfe div_rate coastline unilateral stpop neighper unilateral_neighper  married_annual evdiv50, a(beta8=year) 
*Lets store the betas

gen beta1_full=_b[coastline] 
gen beta2=_b[unilateral]*unilateral
gen beta3=_b[stpop]*stpop
gen beta4=_b[neighper]*neighper
gen beta5=_b[unilateral_neighper]*unilateral_neighper // Problem HERE?
gen beta6=_b[married_annual]*married_annual
gen beta7=_b[evdiv50]*evdiv50

*Diff between the beta base and beta full
disp beta1_base-beta1_full
*The diff is 0.14365673

*Now let's do the auxiliary regressions of the decomposition
* unilateral on coastline
reg beta2 coastline if div_rate!=.
gen coef2=_b[coastline]

* stpop on coastline
reg beta3 coastline if div_rate!=.
gen coef3=_b[coastline]

*neighper on coastline
reg beta4 coastline if div_rate!=.
gen coef4=_b[coastline]

*unilateral_neighper on coastline
reg beta5 coastline if div_rate!=.
gen coef5=_b[coastline]

*married_annual on coastline
reg beta6 coastline if div_rate!=.
gen coef6=_b[coastline]

*evdiv50 on coastline
reg beta7 coastline if div_rate!=.
gen coef7=_b[coastline]

*year fixed effects
reg beta8 coastline if div_rate!=.
gen coef8=_b[coastline]

display coef2+coef3+coef4+coef5+coef6+coef7+coef8
*.14365669
*The decomposition was sucessful!














