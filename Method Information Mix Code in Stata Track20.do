* Method Information Index
* Track20, Avenir Health
* January 2021

clear all
set more off
set maxvar 10000

********************************************************************
* Read in data
********************************************************************
use "C:\Users\KristinBietsch\files\DHSLoop\UGIR7HFL.DTA"
********************************************************************

********************************************************************
* Label Values
********************************************************************
numlabel, add
********************************************************************

********************************************************************
* Create dataset to modern method users
********************************************************************
keep if v313==3
********************************************************************

********************************************************************
* Mutate data
********************************************************************
gen told_om = 1 if v3a05==1
replace told_om =0 if v3a05>=0 & v3a05<9 & told_om==.

gen told_side_eff=1 if v3a02==1 
replace told_side_eff=0 if v3a02==0 

gen told_to_do=1 if v3a04==1 & v3a02==1 
replace told_to_do=0 if v3a02>=0 & v3a02<9 & told_to_do==.

gen total_mii = told_om + told_side_eff + told_to_do

gen mii = 1 if total_mii==3
replace mii = 0 if total_mii<3

gen sampleweights=v005/100000


********************************************************************

********************************************************************
* Set survey design
********************************************************************
svyset v021 [pw=sampleweights], strata(v025) singleunit(scaled)
********************************************************************


********************************************************************
* Weighted Results
********************************************************************

* % of Modern Method Users Told of Other Methods
svy: mean  told_om

* % of Modern Method Users Told of Side Effects
svy: mean  told_side_eff

* % of Modern Method Users Told what to do about Side Effects
svy: mean  told_to_do

* % of Modern Method Users with All Three of the Above
svy: mean  mii

* For individual methods, there may be sample size issues- we will only display results if there are more than 25 unweighted observations
* To find the unweighted N
tab v312
* MII by method
svy: mean  mii, over(v312)
********************************************************************

