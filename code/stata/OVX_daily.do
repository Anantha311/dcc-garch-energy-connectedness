log using "tvgc_results_ovx_daily.log", replace text
clear all
set scheme sj
set more off

// check for Mata mm_quantile from moremata
capt mata: mm_quantile()
if _rc > 0 & _rc != 3001 {
	di in r _n "you must ssc install moremata" _n
	error 999
}

// these routines are not needed by tvgc, but their output is used in the paper
capt which adfmaxur
if _rc > 0 {
	di in r _n "you must ssc install adfmaxur" _n
	error 999
}

capt which ersur
if _rc > 0 {
	di in r _n "you must ssc install ersur" _n
	error 999
}

import delimited "C:\Users\Anantha\OneDrive\Desktop\Anantha\BITS GOA\Academics\3 - 1\FRAM\Project\Data\Daily\TCI_OVX_daily", clear
rename *, lower
gen actual_date = date(date, "DMY")  
format actual_date %td
bcal create tradecal, from(actual_date) replace generate(bdate)
format bdate %tbtradecal
tsset bdate



gen trend = _n

* Data transformations
foreach var of varlist tci ovx {
	gen d`var' = d.`var'
}


* Unit root tests
* Leybourne (1995, OBES)
foreach var of varlist tci ovx {
	adfmaxur `var' /* if tin(1992m1,) */
	adfmaxur d`var' /* if tin(1992m1,) */
}

* Elliott, Rothenberg & Stock (1996, Econometrica)
foreach var of varlist tci ovx {
	ersur `var' /* if tin(1992m1,) */
	ersur d`var' /* if tin(1992m1,) */
}


* Determining the order of VAR

varsoc tci ovx /* if tin(1992m1,) */ , exog(trend) maxlag(12)


* ----------------------------------------------------------------------------------------
* ----------------------------------------------------------------------------------------


local yvar tci
local xvar ovx
display "TVGC results: `yvar' caused by `xvar'"
tvgc `yvar' `xvar', trend win(504) sizec(252) p(2) d(1) seed(123) boot(499) prefix(fig_`xvar'y1_d1_) graph pdf notitle
log close


