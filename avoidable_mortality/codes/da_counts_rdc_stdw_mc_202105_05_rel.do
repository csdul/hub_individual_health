/*==============================================================================

	MTHIC - Avoidable Mortality
================================================================================	
Programmer: Anousheh Marouzi
Task: generate population counts at national, provincial, CMA, and DA level (to use as 
	denominator when calculating mortality rates in other do-files) and calculate 
	age-standardization and standard error indicators.
Date started: 20th May, 2021
Last edited: 12th Nov, 2021
================================================================================

	Details
--------------------------------------------------------------------------------
steps
	0. setup
	1. open and harmonize Census 2011
	2. open and harmonize correspondence file
	3. open and harmonize Census 2016 and change 2016da to 2011da using 
	   correspondence file
	4. calculate population counts between years 2011 and 2016
	5. calculate age-standardization and standard error indicators

	X. control
	
inputs
	1. Census - 2011 - RDC - RAW
	2. Census - 2016 - RAW
	3. DA correspondence - 2011-16 - RAW.csv 
	
outputs
	1. Census - 2011 - harm - woinst
	2. Census - 2011 - harm - winst
	3. Census - 2011 - harm - woinst - MASTER
	4. Census - 2011 - harm - winst - MASTER
	5. land correspondence - 2011-16 - harm
	6. Census - 2016 - harm - woinst
	7. Census - 2016 - harm - winst
	8. Census - 2016 - harm - woinst - MASTER
	9. Census - 2016 - harm - winst - MASTER
	10. counts - between 2011-15 - `geo level' - woinst
	11. counts - between 2011-15 - `geo level' - winst
	12. stdw - w_se - `geo level' - 2011-15 - woinst - MASTER
	13. stdw - w_se - `geo level' - 2011-15 - winst - MASTER

==============================================================================*/


* 0. setup
*-------------------------------------------------------------------------------
//name project
	local projectname "Avoidable Mortality"
	local filename "DA counts (RDC) - stdw"
	
//global settings
	set more off, permanently
	clear all
	
//set directory
	cd "H:\Plante_6734\Avoidable Mortality"
	
//set ado path
	adopath + ".\ADO"
	
//open log
	capture log close main
	local date= subinstr(c(current_date)," ","",.)
	log using "./Log/`filename'_`date'.log", name(main) replace
	
//set graph scheme
	set scheme s1color
	
	
* 1. open and harmonize Census 2011
capture program drop harm_cens2011 
program define harm_cens2011
*-------------------------------------------------------------------------------
//set macros
	local inst winst woinst
	
//open dataset
	use ".\Data\Census - 2011 - RDC - RAW.dta", clear
	
//keep variables we need
	keep weight age prcdda cmaca_hh doctp
	
//generate prov variable
	tostring prcdda, replace
	gen prov= ustrleft(prcdda,2)
	
//recode variables
	gen pop_to74_rdc = 1 if age < 75
	gen pop_rdc = 1
	gen private = inlist(doctp,1,2,4,5,7,9) if !missing(doctp)
	
	rename prcdda da
	rename cmaca_hh cma

	destring da, replace
	destring prov, replace
	
//calculate weights for age standardization (national, prov, cma)
	//construct age group categories
		gen age_group = .
		replace age_group = 1 if inrange(age,0,4)
		replace age_group = 2 if inrange(age,5,9)
		replace age_group = 3 if inrange(age,10,14)
		replace age_group = 4 if inrange(age,15,19)
		replace age_group = 5 if inrange(age,20,24)
		replace age_group = 6 if inrange(age,25,29)
		replace age_group = 7 if inrange(age,30,34)
		replace age_group = 8 if inrange(age,35,39)
		replace age_group = 9 if inrange(age,40,44)
		replace age_group = 10 if inrange(age,45,49)
		replace age_group = 11 if inrange(age,50,54)
		replace age_group = 12 if inrange(age,55,59)
		replace age_group = 13 if inrange(age,60,64)
		replace age_group = 14 if inrange(age,65,69)
		replace age_group = 15 if inrange(age,70,74)
		replace age_group = 16 if inrange(age,75,79)
		replace age_group = 17 if inrange(age,80,84)
		replace age_group = 18 if inrange(age,85,89)
		replace age_group = 19 if age>=90

	//calculate and save for with and without institutional records separately
		foreach y of local inst{
		
		preserve
			if "`y'" == "woinst" {
				keep if private
			}
		
			//tabulate weighted pop counts with age groups
				egen all_count_nat_11= total(weight)
				bysort prov: egen all_count_prov_11= total(weight)
				bysort  cma: egen all_count_cma_11= total(weight)
			
				bysort age_group     : egen age_count_nat_11= total(weight)
				bysort age_group  cma: egen age_count_cma_11= total(weight)
				bysort age_group prov: egen age_count_prov_11= total(weight)
		
			//calculate population aged 0-74
				generate to74_w = pop_to74_rdc * weight
			
				egen to74_count_nat_11 = total(to74_w)
				bysort cma: egen to74_count_cma_11 = total(to74_w)
				bysort prov: egen to74_count_prov_11 = total(to74_w)	
		
			//save for age-standardization indicator
				gen nat = 1

				compress
				save ".\Data\Census - 2011 - harm - `y'.dta", replace
	
			//clean up and save for between years counts calculation
				collapse (first) all_count_cma_11 all_count_nat_11 			///
					all_count_prov_11 cma prov to74_count_cma_11 			///
					to74_count_prov_11 to74_count_nat_11					/// 
					(sum) to74_count_da_11=pop_to74_rdc						/// 
					all_count_da_11=pop_rdc [pw=weight], by (da)
		
				save ".\Data\Census - 2011 - harm - `y' - MASTER.dta", replace	
		restore
		
		}
end		
	
* 2. open and harmonize correspondense file
capture program drop harm_crsp
program define harm_crsp
*-------------------------------------------------------------------------------
//open data
	import delimited using ".\Data\DA land area correspondence file - 2011-16 - RAW.csv", clear
	
//rename variables
	rename dauid2016adidu2016 da_16
	rename dauid2011adidu2011 da_11
	rename da_area_percentagead_pourcentage land    
	
//recode land area to use it later as weight for DAs 
	replace land = land/100
	
//collapse to drop duplicates and drop variables we don't need
	collapse (first) land da_11, by(da_16)	//no duplicates
	
//save	
	save ".\Data\land correspondence - 2011-16 - harm.dta", replace
end	
	
* 3. open and harmonize Census 2016 and change 2016da to 2011da using correspondence file
capture program drop harm_cens2016
program define harm_cens2016
*-------------------------------------------------------------------------------
//set macros
	local inst winst woinst
	
//open data
	use ".\Data\Census - 2016 - RAW.dta", clear

//keep variables we need
	keep compw2 age prcdda pr cma doctp

//rename  variables
	rename compw2 weight
	rename prcdda da_16   
	rename pr prov
	
//generate pop count younger than 75 and total	
	gen to74_count_16 = 1 if age < 75	
	gen all_count_16 = 1
	gen private = inlist(doctp,1,2,4,5,7,9,16,17,23,26) if !missing(doctp)
	
//construct age group categories
	gen age_group = .
	replace age_group = 1 if inrange(age,0,4)
	replace age_group = 2 if inrange(age,5,9)
	replace age_group = 3 if inrange(age,10,14)
	replace age_group = 4 if inrange(age,15,19)
	replace age_group = 5 if inrange(age,20,24)
	replace age_group = 6 if inrange(age,25,29)
	replace age_group = 7 if inrange(age,30,34)
	replace age_group = 8 if inrange(age,35,39)
	replace age_group = 9 if inrange(age,40,44)
	replace age_group = 10 if inrange(age,45,49)
	replace age_group = 11 if inrange(age,50,54)
	replace age_group = 12 if inrange(age,55,59)
	replace age_group = 13 if inrange(age,60,64)
	replace age_group = 14 if inrange(age,65,69)
	replace age_group = 15 if inrange(age,70,74)
	replace age_group = 16 if inrange(age,75,79)
	replace age_group = 17 if inrange(age,80,84)
	replace age_group = 18 if inrange(age,85,89)
	replace age_group = 19 if age>=90

//calculate and save for with and without institutional records separately
	foreach y of local inst{
	
	preserve	
		if "`y'" == "woinst" {
		    keep if private
		}			
	
		//tabulate weighted pop counts
			egen all_count_nat_16= total(weight)
			bysort prov: egen all_count_prov_16= total(weight)
			bysort  cma: egen all_count_cma_16= total(weight)
	
			bysort age_group     : egen age_count_nat_16= total(weight)
			bysort age_group  cma: egen age_count_cma_16= total(weight)
			bysort age_group prov: egen age_count_prov_16= total(weight)

		//save for age-standardization indicator
			gen nat = 1
	
			compress
			save ".\Data\Census - 2016 - harm - `y'.dta", replace
	
	
		//merge with correspondense file to translate 2016DA to 2011DA
			merge m:m da_16 using ".\Data\land correspondence - 2011-16 - harm.dta", nogen
		
		//generate new weight variable to consider land area percentage when changing 2016da to 2011da
			gen weight_land = weight * land
	
		//collapse to DA to get DA counts
			collapse (first) all_count_cma_16 all_count_nat_16 all_count_prov_16 ///
				cma prov (sum) all_count_da_16=all_count_16						/// 
				to74_count_da_16=to74_count_16 [pw=weight_land] , by (da_11) 
		
		//rename DA variable 
			rename da_11 da
		
		//calculate population younger than 75 in each cma/prov and in Canada
			egen to74_count_nat_16 = total(to74_count_da_16)
			bysort cma: egen to74_count_cma_16 = total(to74_count_da_16)	
			bysort prov: egen to74_count_prov_16 = total(to74_count_da_16)	
	
		//collapse to DA and drop variables we don't need
			collapse (first) all_count_cma_16 all_count_nat_16 all_count_prov_16 ///
				to74_count_nat_16 to74_count_cma_16 to74_count_prov_16 cma prov ///
				(sum) all_count_da_16 to74_count_da_16, by (da)
		
		//clean up and save
			compress
			save ".\Data\Census - 2016 - harm - `y' - MASTER.dta", replace
	restore
	
	}
end	
	
* 4. calculate population counts between years 2011 and 2016
capture program drop calc_btw_counts
program define calc_btw_counts
*-------------------------------------------------------------------------------
//set macros
	local level da cma prov nat
	local inst winst woinst

//calculate and save for with and without institutional records separately
	foreach y of local inst{
	
		//open Census 2011
			use ".\Data\Census - 2011 - harm - `y' - MASTER.dta", clear
	
		//merge with Census 2016 
			merge 1:1 da using ".\Data\Census - 2016 - harm - `y' - MASTER.dta", nogen
	
		//generate national variable to collapse to it later	
			gen nat = 1
	
		//calculate all counts for years 2012-15
			foreach x of local level {
		
		preserve
			//calculate the difference between 2011 and 2016
				gen dif5_11_16_`x' = (all_count_`x'_16 - all_count_`x'_11)/5
				gen dif5_to74_11_16_`x' = (to74_count_`x'_16 - to74_count_`x'_11)/5
		
			//construct national/provincial/municipal/da counts for years 2012-15
				foreach i of numlist 2/5 {
					gen all_count_`x'_1`i' = all_count_`x'_11 + (`i' - 1) * dif5_11_16_`x'
					gen to74_count_`x'_1`i' = to74_count_`x'_11 + 			///
						(`i' - 1) * dif5_to74_11_16_`x'
				}
			//collapse and save
				collapse all_count_`x'_11 all_count_`x'_12 all_count_`x'_13  ///
					all_count_`x'_14 all_count_`x'_15 to74_count_`x'_11		 ///
					to74_count_`x'_12 to74_count_`x'_13 to74_count_`x'_14	 ///
					to74_count_`x'_15, by (`x')
				
				save ".\Data\counts - between 2011-15 - `x' - `y'.dta", replace
		restore
	
		}
	}
end
		
* 5. calculate age-standardization and standard error indicators
capture program drop calc_stdw_wse
program define calc_stdw_wse
*-------------------------------------------------------------------------------	
//set macros
	local level cma prov nat
	local inst winst woinst
	
//calculate and save for with and without institutional records and geo level separately
	foreach y of local inst{
		foreach x of local level{
		//open between years data
			use ".\Data\counts - between 2011-15 - `x' - `y'.dta", clear 
			
		//merge with 2011 and 2016 data
			merge 1:m `x' using ".\Data\Census - 2011 - harm - `y'.dta", nogen
		
			merge m:m age_group `x' using ".\Data\Census - 2016 - harm - `y'.dta", nogen
		
		//drop variables we don't need 	
			if "`x'" != "nat"{	
				collapse (first) all_count_`x'_11 all_count_`x'_12 			///
					all_count_`x'_13 all_count_`x'_14 all_count_`x'_15 		///
					age_count_`x'_11 age_count_`x'_16 age_count_nat_11 		///
					all_count_nat_11, by (`x' age_group)
			}		
				
			if "`x'" == "nat"{	
				collapse (first) all_count_`x'_11 all_count_`x'_12 			///
				all_count_`x'_13 all_count_`x'_14 all_count_`x'_15 			///
				age_count_`x'_11 age_count_`x'_16, by (`x' age_group)
			}
			
		//calculate age group counts between years 2011 and 2016
			gen dif5_age_11_16_`x' = (age_count_`x'_16 - age_count_`x'_11)/5 
		
			foreach i of numlist 2/5 {
				gen age_count_`x'_1`i' = age_count_`x'_11 + (`i' - 1) * dif5_age_11_16_`x'
			}
		
		//for each year 
			foreach i of numlist 1/5 {	
				//construct age-standardization and standard error indicators
					gen stdw_`x'Xnat_1`i' = (age_count_nat_11*all_count_`x'_1`i')/(age_count_`x'_1`i'*all_count_nat_11)
					gen w_se_`x'Xnat_1`i' = (age_count_nat_11*age_count_nat_11)/(all_count_nat_11*all_count_nat_11*age_count_`x'_1`i')
			}
		
		//collapse and save 	 
			collapse (first) w_se_`x'Xnat_11 w_se_`x'Xnat_12				///
			w_se_`x'Xnat_13 w_se_`x'Xnat_14 w_se_`x'Xnat_15 				///
			stdw_`x'Xnat_11 stdw_`x'Xnat_12 stdw_`x'Xnat_13 				///
			stdw_`x'Xnat_14 stdw_`x'Xnat_15 age_count_`x'_11 				///
			age_count_`x'_12 age_count_`x'_13 age_count_`x'_14				///
			age_count_`x'_15, by(age_group `x')
		
			save ".\Data\stdw - w_se - `x' - 2011-15 - `y' - MASTER.dta", replace	
		}	
	}
end

* X. control	
*-------------------------------------------------------------------------------
//harmonize Census 2011
	harm_cens2011
	
//harmonize correspondence file
	harm_crsp
	
//harmonize Census 2016
	harm_cens2016
	
//calculate between years counts
	calc_btw_counts
	
//calculate age-standardization and SE weights
	calc_stdw_wse
	
