* nearest neighbor match with one covariate. 

    clear 
	capture log close
    drop _all 
	set seed 5000
	set obs 30
	
	* Identifiers and treatment status
	gen 	id = _n
	gen 	treat = 0 
	replace treat = 1 in 1/10
	
	* Poor pre-treatment fit on age as confounder
	gen 	age = rnormal(25,2.5) 		if treat==1
	replace age = rnormal(40,10) 		if treat==0
	replace age = round(age)
	
	* Imbalance in confounders for two groups
	twoway (histogram age if treat==1,  color(green)) ///
       (histogram age if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))

	* Generate potential outcomes and treatment effects
	gen y0 = 15000 + 10.25*age + rnormal(0,5)
	gen y1 = y0 + 2500 
	gen delta = y1 - y0

	* Summarize treatment effects into ATE and ATT
	su delta 			 // ATE = 2500
	su delta if treat==1 // ATT = 2500
	local att = r(mean)
	scalar att = `att'
	gen att = `att'

	* Switching equation
	gen earnings = treat*y1 + (1-treat)*y0
	replace earnings = round(earnings)
	
	* SDO Estimation
	regress earnings treat, robust	// SATT = 2334.6
	su att     						// ATT = 2500
	
	* Nearest neighbor distance minimization
	teffects nnmatch (earnings age) (treat), gen(osample) atet // SATT = 2496.1
	su att										  // ATT = 2500

	list id treat age earnings o* // show matches used in osample1 and osample2 
	
	capture log close
	exit
	