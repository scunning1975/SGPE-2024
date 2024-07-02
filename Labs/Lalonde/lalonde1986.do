* lalonde1986.do Original Lalonde adult male sample
clear all
capture log close
use https://github.com/scunning1975/mixtape/raw/master/lalonde_original.dta, 

/* 
data_id: identifies the sample as belonging to LaLonde's original sample
treat : indicates which group was treated
age : age of the participant
education : years of schooling
black : African-American
hispanic : Hispanic
married : Marital status
nodegree : High school completion
re75 : real earnings in 1975 (before enrolling)
re78 : real earnings in 1978 (after enrolling)
*/

* Relabel variables
label var treat "NSW Participation"
label var age "Age"
label var education "Education"
label var black "Black"
label var hispanic "Hispanic"
label var married "Married"
label var nodegree "No High School Degree"
label var re75 "Real Earnings in 1975"

* Compare means for treatment and controls
bysort treat: summarize age-re75

* Estimation of ATE
reg re78 treat, robust
reg re78 age-nodegree treat, robust
reg re78 age-nodegree re75 treat, robust


* Merge in the CPS
drop if treat==0

append using https://github.com/scunning1975/mixtape/raw/master/cps_controls.dta

* Relabel variables
label var treat "NSW Participation"
label var age "Age"
label var education "Education"
label var black "Black"
label var hispanic "Hispanic"
label var married "Married"
label var nodegree "No High School Degree"
label var re75 "Real Earnings in 1975"

* Estimation of ATT
reg re78 treat, robust
reg re78 age-nodegree treat, robust
reg re78 age-nodegree re75 treat, robust




capture log close
exit

* Tables

* Relabel variables
label var treat "NSW Participation"
label var age "Age"
label var education "Education"
label var black "Black"
label var hispanic "Hispanic"
label var married "Married"
label var nodegree "No High School Degree"
label var re75 "Real Earnings in 1975"

* Create summary statistics
eststo clear
eststo: estpost summarize treat age education black hispanic married nodegree re75 if treat==1
eststo: estpost summarize treat age education black hispanic married nodegree re75 if treat==0

* Output to LaTeX
#delimit ;
esttab using summary_stats2.tex, 
    cells("mean(fmt(%9.2f))") 
    noobs
    nogaps
    label
    collabels("NSW Experimental Participants" "CPS Controls")
    title(Summary Statistics for the Adult Male Sample of the NSW and CPS Controls)
    nonumbers
    replace
    style(tex)
    prehead("\begin{table}[htbp]\centering\small\caption{@title}\begin{tabular}{l*{2}{c}}")
    posthead("\hline\hline")
    prefoot("\hline")
    postfoot("\hline\hline\end{tabular}\end{table}");
#delimit cr


* Run the regressions and store the estimates
reg re78 treat, robust
				cap n estimates store nsw1
				cap n estadd ysumm

reg re78 age-nodegree treat, robust
				cap n estimates store nsw2
				cap n estadd ysumm

reg re78 age-nodegree re75 treat, robust
				cap n estimates store nsw3
				cap n estadd ysumm

#delimit ;
	cap n estout * using ./results2.tex,
		style(tex) label notype
		cells((b(star fmt(%9.3f))) (se(fmt(%9.3f)par))) 		
		stats(N ymean,
			labels("N" "Mean of dependent variable")
			fmt(%9.0fc %9.2fc 2))
			drop(_cons) 
			replace noabbrev starlevels(* 0.10 ** 0.05 *** 0.01) 
			title(Effect of NSW on Earnings using the CPS Controls)   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none) substitute(_ \_)
			prehead("\begin{table}[htbp]\centering" "\small" "\caption{@title}" "\begin{center}" "\begin{threeparttable}" "\begin{tabular}{l*{@E}{c}}"
	"\toprule"
	"\multicolumn{1}{l}{\textbf{Dependent variable: 1978 Real Earnings}}&"
	"\multicolumn{1}{c}{\textbf{(1)}}&"
	"\multicolumn{1}{c}{\textbf{(2)}}&"
	"\multicolumn{1}{c}{\textbf{(3)}}\\")
		posthead("\midrule")
		prefoot("\midrule")  
		postfoot("\bottomrule" "\end{tabular}" "\begin{tablenotes}" "\tiny" "\item Data is from NLS with CPS controls.  Heteroskedastic standard errors shown in parenthesis.  * p$<$0.10, ** p$<$0.05, *** p$<$0.01" "\end{tablenotes}" "\end{threeparttable}" "\end{center}" "\end{table}");
#delimit cr
	cap n estimates clear

	
	
	
