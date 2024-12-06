/*==============================================================================

	MTHIC - Avoidable Mortality
================================================================================
Programmer: Anousheh Marouzi
Task: merge VSD, NHS, and Census into one dataset. calculate all-cause, 
	premature, potentially avoidable, preventable, and treatable mortality rates
	at DA, cma, provincial, and national levels in Canada.
start date: May 18th, 2021
last update: November 9th, 2021
================================================================================
	Details
--------------------------------------------------------------------------------
Steps	
	0. setup 
	1. merge NHS with 2011-2015 VSD, pccf output, and Census 2011-16 (pop counts) to be used in DA-level MR calculation
	2. calculate DA-level age-standardized mortality rates (all-cause, premature, avoidable, preventable, treatable)
	3. calculate national/provincial/municipal age-standardized mortality rates
	4. calculate Standard Error
	5. merge mortality rates and SEs for each geo level  and calculate 95% Confidence Interval
	6. export mortality rates for release
	
	X. control

inputs
	1. outt.csv
	2. VSD - 2011-15 - MASTER
	3. NHS - 2011 - MASTER
	4. counts - between 2011-15 - `level'
	5. stdw - w_se - prov - 2011-15 - MASTER
	6. stdw - w_se - cma - 2011-15 - MASTER
	7. VSD - 2011-15 - appended
	8. out.csv
	9. VSD - 2011-15 - appended - pccf input
	
outputs
	1. VSD NHS Census - 2011-2015 - MASTER
	2. death and pop counts - DA - `geo level' - `mortality indicator'
	3. DA - `mortality indicator' rates - `geo level'
	4. VSD Census stdw - prov - 2011-15 - MASTER
	5. VSD Census stdw - cma - 2011-15 - MASTER
	6. death and pop counts - `geo level' - `mortality indicator'
	7. `mortality indicator' rates - `geo level'
==============================================================================*/


* 0. setup
*-------------------------------------------------------------------------------
//name project
	local projectname "Avoidable Mortality"
	local filename "calc AM - MCA"
		
//global settings
	set more off, permanently
	clear all
	
//set directory
	cd "H:\Plante_6734\Avoidable Mortality"
	
//set global
	set more off, permanently
	
//set ADO path
	adopath + ".\ADO\acround"
	
//set log
	capture log close main
	local date = subinstr(c(current_date)," "," ",.)
	log using "./log/`filename'_`date'.log", name(main) replace
		
//set graph scheme
	set scheme s1color
		
		
* 1. merge NHS with 2011-2015 VSD, pccf output, and Census 2011-16 (pop counts) to be used in DA-level MR calculation
capture program drop merge_data
program define merge_data
*-------------------------------------------------------------------------------
//open PCCF+ output for VSD 2011-2015 (without institutional obs)
	import delimited ".\Data\PCCF\outt.csv", clear
		
	//keep variables we need
		keep id dauid pr cma csduid
	
	//rename variables
		rename id ID
		rename dauid da
		rename pr prov
		rename csduid csd
	
		tostring ID, replace
			
//merge with VSD - 2011-2015 - harm (without institutional obs)
	merge 1:1 ID using ".\Data\VSD - 2011-15 - MASTER.dta", nogen
	
	//drop missing observations
		drop if missing(da) 
			
	//keep variables we need
		keep ID da prov csd cma age sex ICD_10 year
			
	//rename variables
		rename ID id
		
//merge with NHS - harm (income and quintiles)	
	merge m:1 da using ".\Data\NHS - 2011 - MASTER.dta", nogen keep(1 3)
		
//merge with Census (DA counts)
	merge m:1 da using ".\Data\counts - between 2011-15 - da - woinst.dta"	///
		, nogen keep(1 3)
		
//clean up and save
	compress
	save ".\Data\VSD NHS Census - 2011-2015 - MASTER.dta", replace
		
end
		
			
* 2. calculate DA-level age-standardized mortality rates (all-cause, premature, avoidable, preventable, treatable)
capture program drop calc_da_mr
program define calc_da_mr
*-------------------------------------------------------------------------------
//set macros	
	//avoidable, treatable, and preventable causes of death
		local preventable ///
			A00 A01 A02 A03 A04 A05 A06 A07 A08 A09 A35 A36 A37 A39 A403 	///
			A413 A492 A80 B01 B05 B06 J09 J10 J11 J13 J14 G000 G001			///
			A50 A51 A52 A53 A54 A55 A56 A57 A58 A59 A60 A63 A64 			///
			B15 B16 B17 B18 B19 B20 B21 B22 B23 B24							///
			C00 C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 	///
			C15 C16 C22 C33 C34 C43 C44										///
			I01 I02 I05 I06 I07 I08 I09 I71 I26 I80 I829					///
			J40 J41 J42 J43 J44 C45 J60 J61 J62 J63 J64 J66 J67 J68 J69		///
			J70 J82 J92														///
			K73 K740 K741 K742 K746	A33		 								///
			H31.1 P V W X													///
			Y10 Y11 Y12 Y13 Y14 Y15 Y16 Y17 Y18 Y19	Y20 Y21 Y22 Y23 Y24 Y25	///
			Y26 Y27 Y28 Y29	Y30 Y31 Y32 Y33 Y34								///
			Y870 Y00 Y01 Y02 Y03 Y04 Y05 Y06 Y07 Y08 Y09 Y871				///
			F10 G312 G621 I426 K292 K70 K852 K860							///
			F11 F12 F13 F14 F15 F16 F18 F19									///
			D50 D51 D52 D53													///
			Y4 Y5 Y60 Y61 Y62 Y63 Y64 Y65 Y66 Y69 Y7 Y80 Y81 Y82 Y83 Y84	
			
		local treatable ///	
			A16 A17 A18 A19 B90 J65 A38 A481 A491 					 		///
			A400 A401 A402 A404 A405 A406 A407 A408 A409					///
			A410 A411 A412 A414 A415 A416 A417 A418 A419					///
			B50 B51 B52 B53 B54 											///
			G002 G003 G008 G009 A46 L03	J12 J15 J16 J18						///
			C18 C19	C20 C21 C50 C53 C54 C55 C62 C67 C73 C81 				///
			C910 C911 C921 													///
			D1 D2 D30 D31 D32 D33 D34 D35 D36								///
			I10 I11 I12 I13 I15												///
			J45 J47 J20 J22 J00 J01 J02 J03 J04 J05 J06						///
			J3 J80 J81 J85 J86												///
			J90 J93 J94 J98													///
			K25 K26 K27 K28 K35 K36 K37 K38 K40 K41 K42 K43 K44 K45 K46		///
			K80 K81 K82 K83 K850 K851 K853 K858 K859 						///
			K861 K862 K863 K868 K869										///
			N00 N01 N02 N03 N04 N05 N06 N07 N17 N18 N19 N13 N20 N21 N23		///
			N35 N40 N341 N70 N71 N72 N73 N750 N751 N764 N766 N25			///
			Q O																///
			E00 E01 E02 E03 E04 E05 E06 E07 E24 E25 E27 E740 E742			///
			G40 G41 M86

	//causes which are 50% treatable and 50% preventable	
		local pre_tre /// 
			I60 I61 I62 I63 I64 I67 I69 I20 I21 I22 I23 I24 I25 I70 I739	///
			E10 E11 E12 E13 E14 
		
		local avoidable `preventable' `treatable' `pre_tre'		

		
	//mortality indicators and geographic level by which we want to compare inequality later
		local level cma prov nat
		local ind all prem AM pre tre

					
//calculate mortality rates at different geo levels
	foreach x of local level{
	    foreach y of local ind{
		    
//open dataset
	use ".\Data\VSD NHS Census - 2011-2015 - MASTER.dta", clear
	
	//construct age group categories to merge with age-standardization later
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
		
//drop observations with missing income, so we exclude non-urban areas
	drop if missing(income) 
	
//generate national variable to use levelsof command later
	generate nat = 1
	
//prepare data to calculate AM, treatable and preventable mortality rates	
	//generate younger than 45 years old
		generate age45=1 if age<45
		replace age45=0 if missing(age45)		
					
	    //merge with age-standardization indicators
			if "`x'" != "cma"{ 
				destring year, replace
				merge m:1 age_group `x' using ".\Data\stdw - w_se - `x' - 2011-15 - woinst - MASTER.dta", nogen
			}

			if "`x'" == "cma" {
				destring year, replace
				merge m:1 age_group `x' using ".\Data\stdw - w_se - `x' - 2011-15 - woinst - MASTER.dta", nogen
					
				//keep the eight most populous cities 
					keep if inlist(cma,421,462,505,535,602,825,835,933)
			}
	    
		//set age-standardization indicator 
			local stdw "stdw_`x'Xnat"
				
			//generate ONE age-standardization var for all years
				gen `stdw' = .
				
				foreach i of numlist 1/5{
					replace `stdw' = `stdw'_1`i' if year == 201`i'
				}		
		
	//identify all_cause mortalities 	
		if "`y'" == "all" {
			generate all = 1
		}				

	//identify premature mortalities 	
		if "`y'" == "prem"{
			generate prem = 1 if age<75
		}	

	//identify avoidable mortalities 	
		if "`y'" == "AM"{
		//drop males with breast cancer
			drop if inlist(ICD_10, "C50") & sex == "male"
		//drop persons 45 years or older with specific leukemia
			drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0

			generate AM = .
			foreach z of local avoidable{
				replace AM = 1 if regexm(ICD_10, "^`z'") & age<75 
			}
		}	
	
	//identify preventable mortalities 	
		if "`y'" == "pre"{
		//drop males with breast cancer
			drop if inlist(ICD_10, "C50") & sex == "male"
		//drop persons 45 years or older with specific leukemia
			drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0

			generate pre = .
			foreach z of local preventable{
				replace pre = 1 if regexm(ICD_10, "^`z'") & age<75 
			}
				
			foreach z of local pre_tre{
				replace pre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
			}
		}

	//identify treatable mortalities 	
		if "`y'" == "tre"{
		//drop males with breast cancer
			drop if inlist(ICD_10, "C50") & sex == "male"
		//drop persons 45 years or older with specific leukemia
			drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0

			generate tre = .
			foreach z of local treatable{
				replace tre = 1 if regexm(ICD_10, "^`z'") & age<75 
			}	
				
			foreach z of local pre_tre{
				replace tre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
			}
		}	
	
	//calculate and age-standardize numerators
		if "`y'" == "all" {
			collapse (first) `x' all_count_da_11 all_count_da_12			///
				all_count_da_13 all_count_da_14 all_count_da_15				///
				income (sum) all [pw=`stdw'], by (year da)
		}
	
		if "`y'" != "all" {
			collapse (first) `x' to74_count_da_11 to74_count_da_12 			///
				to74_count_da_13 to74_count_da_14 to74_count_da_15			///
				income (sum) `y' [pw=`stdw'], by (year da)
		}
	
	//save
		save ".\Data\death and pop counts - DA - `x' - `y'.dta", replace
		}	
}


//calculate mortality RATES
	foreach x of local level{
		foreach y of local ind{
			//open dataset contaning numerators and denominators
				use ".\Data\death and pop counts - DA - `x' - `y'.dta", clear
				
			//generate denominator and round numerator and denominator
				if "`y'" == "all"{
					generate tot_pop_nr = .
					
					foreach i of numlist 1/5{
					    destring year, replace
						replace tot_pop_nr = all_count_da_1`i' if year == 201`i'
					}
				
				//round numerator and denominator
					generate tot_pop = round(tot_pop_nr, 5)
					drop tot_pop_nr
					
					generate tot_death = round(all, 5)
					
					//calculate rates
						generate r_all = (tot_death/tot_pop) *100000
						
					//get an average of mortality rates in years 2011-15
						bysort da: egen r_all_11to15_mean = mean(r_all)
						
					//get an average of population counts in DAs in years 2011-15 to be used as weigh when calculating concentration indices
				gen tot_pop_da_11to15_mean = (all_count_da_11 + 			///
					all_count_da_12 + all_count_da_13 + all_count_da_14 +	///
					all_count_da_15)/5
				}

				if "`y'" != "all"{
					generate tot_pop_0to74_nr = .
					
					foreach i of numlist 1/5{
   					    destring year, replace
						replace tot_pop_0to74_nr = to74_count_da_1`i' if year == 201`i'
					}
				
				//round numerator and denominator
					generate tot_pop_0to74 = round(tot_pop_0to74_nr, 5)
					drop tot_pop_0to74_nr

					generate tot_`y'_death = round(`y', 5)
					
					//calculate rates
						generate r_`y' = (tot_`y'_death / tot_pop_0to74) *100000 
			
					//get an average of mortality rates in years 2011-15 (numerator)
						bysort da: egen r_`y'_11to15_mean = mean(r_`y')
				
					//get an average of population counts in DAs in years 2011-15 to be used as weigh when calculating concentration indices
						gen tot_pop_da_0to74_11to15_mean = (to74_count_da_11 + 	///
							to74_count_da_12 + to74_count_da_13 + to74_count_da_14 +	///
							to74_count_da_15)/5	
			}
			
			//save
				save ".\Data\DA - rates - `y' - `x'.dta", replace
		}	
	}			
		
end


* 3. calculate national/provincial/municipal age-standardized MRs
capture program drop calc_mr
program define calc_mr
*-------------------------------------------------------------------------------
//set macros
	local level cma prov nat
	local ind all prem AM pre tre
	
	local preventable ///
			A00 A01 A02 A03 A04 A05 A06 A07 A08 A09 A35 A36 A37 A39 A403 	///
			A413 A492 A80 B01 B05 B06 J09 J10 J11 J13 J14 G000 G001			///
			A50 A51 A52 A53 A54 A55 A56 A57 A58 A59 A60 A63 A64 			///
			B15 B16 B17 B18 B19 B20 B21 B22 B23 B24							///
			C00 C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 	///
			C15 C16 C22 C33 C34 C43 C44										///
			I01 I02 I05 I06 I07 I08 I09 I71 I26 I80 I829					///
			J40 J41 J42 J43 J44 C45 J60 J61 J62 J63 J64 J66 J67 J68 J69		///
			J70 J82 J92														///
			K73 K740 K741 K742 K746	A33		 								///
			H31.1 P V W X													///
			Y10 Y11 Y12 Y13 Y14 Y15 Y16 Y17 Y18 Y19	Y20 Y21 Y22 Y23 Y24 Y25	///
			Y26 Y27 Y28 Y29	Y30 Y31 Y32 Y33 Y34								///
			Y870 Y00 Y01 Y02 Y03 Y04 Y05 Y06 Y07 Y08 Y09 Y871				///
			F10 G312 G621 I426 K292 K70 K852 K860							///
			F11 F12 F13 F14 F15 F16 F18 F19									///
			D50 D51 D52 D53													///
			Y4 Y5 Y60 Y61 Y62 Y63 Y64 Y65 Y66 Y69 Y7 Y80 Y81 Y82 Y83 Y84	
			
	local treatable ///	
			A16 A17 A18 A19 B90 J65 A38 A481 A491 					 		///
			A400 A401 A402 A404 A405 A406 A407 A408 A409					///
			A410 A411 A412 A414 A415 A416 A417 A418 A419					///
			B50 B51 B52 B53 B54 											///
			G002 G003 G008 G009 A46 L03	J12 J15 J16 J18						///
			C18 C19	C20 C21 C50 C53 C54 C55 C62 C67 C73 C81 				///
			C910 C911 C921 													///
			D1 D2 D30 D31 D32 D33 D34 D35 D36								///
			I10 I11 I12 I13 I15												///
			J45 J47 J20 J22 J00 J01 J02 J03 J04 J05 J06						///
			J3 J80 J81 J85 J86												///
			J90 J93 J94 J98													///
			K25 K26 K27 K28 K35 K36 K37 K38 K40 K41 K42 K43 K44 K45 K46		///
			K80 K81 K82 K83 K850 K851 K853 K858 K859 						///
			K861 K862 K863 K868 K869										///
			N00 N01 N02 N03 N04 N05 N06 N07 N17 N18 N19 N13 N20 N21 N23		///
			N35 N40 N341 N70 N71 N72 N73 N750 N751 N764 N766 N25			///
			Q O																///
			E00 E01 E02 E03 E04 E05 E06 E07 E24 E25 E27 E740 E742			///
			G40 G41 M86

	//causes which are 50% treatable and 50% preventable	
	local pre_tre /// 
			I60 I61 I62 I63 I64 I67 I69 I20 I21 I22 I23 I24 I25 I70 I739	///
			E10 E11 E12 E13 E14 
		
	local avoidable `preventable' `treatable' `pre_tre'		

//calculate age-standardized mortality rates at different geo levels
	foreach x of local level{
		foreach y of local ind{
		//open data
			if "`x'" != "cma" { 		
				use ".\Data\VSD - 2011-15 - appended.dta", clear
				
				//construct age group categories to merge with age-standardization indicator
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
				
				//recode province variable to match Census data
					tostring prov, replace
					replace prov = subinstr(prov,"9","",1)
					destring prov, replace
				
					destring year, replace
					
				//merge with population counts to get denominators
					gen nat = 1 
					
					merge m:1 `x' using ".\Data\counts - between 2011-15 - `x' - winst.dta", nogen
					
				//merge with age-standardization indicators
					merge m:1 age_group `x' using ".\Data\stdw - w_se - `x' - 2011-15 - winst - MASTER.dta", nogen

				//save
					save ".\Data\VSD Census stdw - `x' - 2011-15 - MASTER.dta", replace
			}
			
			if "`x'" == "cma" {
				//import pccf output to get cmas
					import delimited ".\Data\PCCF\for cma rates\out.csv", clear
			
					keep id pcode cma 
					rename id ID
					tostring ID, replace
		
				//merge with death data
					merge 1:1 ID using ".\Data\VSD - 2011-15 - appended - pccf input.dta", nogen
				
				//construct age group categories to merge with age-standardization indicator
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
				
				//merge with population counts to get denominators
					merge m:1 cma using ".\Data\counts - between 2011-15 - cma - winst.dta", nogen	
				
				//merge with age-standardization indicators
					destring year, replace
					merge m:1 age_group `x' using ".\Data\stdw - w_se - `x' - 2011-15 - winst - MASTER.dta", nogen
					
				//keep the eight most populous cities 
					keep if inlist(cma,421,462,505,535,602,825,835,933)
					
				//save 
					save ".\Data\VSD Census stdw - cma - 2011-15 - MASTER.dta", replace	
			}

		
	//prepare data to calculate AM, treatable and preventable mortality rates	
		//generate younger than 45 years old
			generate age45=1 if age<45
			replace age45=0 if missing(age45)	
	    
	//set age-standardization indicator at different geo levels
		local stdw "stdw_`x'Xnat"
			
		//generate ONE age-standardization car for all years
			gen `stdw' = .
			foreach i of numlist 1/5{
				replace `stdw' = `stdw'_1`i' if year == 201`i'
			}

		
	//identify all_cause mortalities 	
		if "`y'" == "all" {
			generate all = 1
		}				

	//identify premature mortalities 	
		if "`y'" == "prem"{
			generate prem = 1 if age<75
		}	

	//identify avoidable mortalities 	
		if "`y'" == "AM"{
		//drop males with breast cancer
			drop if inlist(ICD_10, "C50") & sex == "male"
		//drop persons 45 years or older with specific leukemia
			drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0
			
			generate AM = .
			foreach z of local avoidable{
				replace AM = 1 if regexm(ICD_10, "^`z'") & age<75 
			}
		}	
	
	//identify preventable mortalities 	
		if "`y'" == "pre"{
		//drop males with breast cancer
			drop if inlist(ICD_10, "C50") & sex == "male"
		//drop persons 45 years or older with specific leukemia
			drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0
			
			generate pre = .
			foreach z of local preventable{
				replace pre = 1 if regexm(ICD_10, "^`z'") & age<75 
			}
				
			foreach z of local pre_tre{
				replace pre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
			}
		}

	//identify treatable mortalities	
		if "`y'" == "tre"{
		//drop males with breast cancer
			drop if inlist(ICD_10, "C50") & sex == "male"
		//drop persons 45 years or older with specific leukemia
			drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0
			
			generate tre = .
			foreach z of local treatable{
				replace tre = 1 if regexm(ICD_10, "^`z'") & age<75 
			}	
				
			foreach z of local pre_tre{
				replace tre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
			}
		}	
	
	//calculate and age-standardize numerators
		if "`y'" == "all" {
			collapse (first) all_count_`x'_11 all_count_`x'_12 				///
				all_count_`x'_13 all_count_`x'_14 all_count_`x'_15			///
				(sum) all [pw=`stdw'], by (year `x')
		}
	
		if "`y'" != "all" {
			collapse (first) to74_count_`x'_11 to74_count_`x'_12 			///
				to74_count_`x'_13 to74_count_`x'_14 to74_count_`x'_15		///
				(sum) `y' [pw=`stdw'], by (year `x')
		}	
	
	//save
		save ".\Data\death and pop counts - `x' - `y'.dta", replace
		}	
	}
	
	
//calculate mortality RATES
	foreach x of local level{
		foreach y of local ind{
			//open dataset contaning numerators and denominators
				use ".\Data\death and pop counts - `x' - `y'.dta", clear
				
			//generate denominator and round numerator and denominator
				if "`y'" == "all"{
					generate total_population_nr = .
					
					foreach i of numlist 1/5{
						replace total_population_nr = all_count_`x'_1`i' if year == 201`i'
					}
					
					generate total_population = round(total_population_nr, 5)
					drop total_population_nr
					generate total_death = round(all, 5)
					
					//calculate rates
						generate all_mortality_rate = (total_death/total_population) *100000
				}

				if "`y'" != "all"{
					generate total_population_aged_0to74_nr = .
					
					foreach i of numlist 1/5{
						replace total_population_aged_0to74_nr = to74_count_`x'_1`i' if year == 201`i'
					}
					
					generate total_population_aged_0to74 = round(total_population_aged_0to74_nr, 5)
					drop total_population_aged_0to74_nr

					generate total_`y'_death = round(`y', 5)
					//calculate rates
						generate `y'_mortality_rate = (total_`y'_death / total_population_aged_0to74) *100000 
			
			}	
			
			//save
				save ".\Data\rates - `y' - `x'.dta", replace
				
		}
	}
	
end


* 4. calculate Standard Error
capture program drop calc_se
program define calc_se
*-------------------------------------------------------------------------------
//set macros
	local level cma prov nat
	
	local ind all prem AM pre tre
	
	local preventable ///
			A00 A01 A02 A03 A04 A05 A06 A07 A08 A09 A35 A36 A37 A39 A403 	///
			A413 A492 A80 B01 B05 B06 J09 J10 J11 J13 J14 G000 G001			///
			A50 A51 A52 A53 A54 A55 A56 A57 A58 A59 A60 A63 A64 			///
			B15 B16 B17 B18 B19 B20 B21 B22 B23 B24							///
			C00 C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 	///
			C15 C16 C22 C33 C34 C43 C44										///
			I01 I02 I05 I06 I07 I08 I09 I71 I26 I80 I829					///
			J40 J41 J42 J43 J44 C45 J60 J61 J62 J63 J64 J66 J67 J68 J69		///
			J70 J82 J92														///
			K73 K740 K741 K742 K746	A33		 								///
			H31.1 P V W X													///
			Y10 Y11 Y12 Y13 Y14 Y15 Y16 Y17 Y18 Y19	Y20 Y21 Y22 Y23 Y24 Y25	///
			Y26 Y27 Y28 Y29	Y30 Y31 Y32 Y33 Y34								///
			Y870 Y00 Y01 Y02 Y03 Y04 Y05 Y06 Y07 Y08 Y09 Y871				///
			F10 G312 G621 I426 K292 K70 K852 K860							///
			F11 F12 F13 F14 F15 F16 F18 F19									///
			D50 D51 D52 D53													///
			Y4 Y5 Y60 Y61 Y62 Y63 Y64 Y65 Y66 Y69 Y7 Y80 Y81 Y82 Y83 Y84	
			
			
	local treatable ///	
			A16 A17 A18 A19 B90 J65 A38 A481 A491 					 		///
			A400 A401 A402 A404 A405 A406 A407 A408 A409					///
			A410 A411 A412 A414 A415 A416 A417 A418 A419					///
			B50 B51 B52 B53 B54 											///
			G002 G003 G008 G009 A46 L03	J12 J15 J16 J18						///
			C18 C19	C20 C21 C50 C53 C54 C55 C62 C67 C73 C81 				///
			C910 C911 C921 													///
			D1 D2 D30 D31 D32 D33 D34 D35 D36								///
			I10 I11 I12 I13 I15												///
			J45 J47 J20 J22 J00 J01 J02 J03 J04 J05 J06						///
			J3 J80 J81 J85 J86												///
			J90 J93 J94 J98													///
			K25 K26 K27 K28 K35 K36 K37 K38 K40 K41 K42 K43 K44 K45 K46		///
			K80 K81 K82 K83 K850 K851 K853 K858 K859 						///
			K861 K862 K863 K868 K869										///
			N00 N01 N02 N03 N04 N05 N06 N07 N17 N18 N19 N13 N20 N21 N23		///
			N35 N40 N341 N70 N71 N72 N73 N750 N751 N764 N766 N25			///
			Q O																///
			E00 E01 E02 E03 E04 E05 E06 E07 E24 E25 E27 E740 E742			///
			G40 G41 M86

	//local causes which are treatable and preventable	
	local pre_tre /// 
			I60 I61 I62 I63 I64 I67 I69 I20 I21 I22 I23 I24 I25 I70 I739	///
			E10 E11 E12 E13 E14 
		
	local AM `preventable' `treatable' `pre_tre'	

//start calculation for each geo level	
	foreach x of local level{ 
		foreach y of local ind{
		//open data
			use ".\Data\VSD Census stdw - `x' - 2011-15 - MASTER.dta", clear	
			
		//prepare data to count AM, treatable and preventable mortalities
			if "`y'" == "AM" | "`y'" == "pre" | "`y'" == "tre" {
			//generate younger than 45 years old
				generate age45=1 if age<45
				replace age45=0 if missing(age45)	
			//drop males with breast cancer
				drop if inlist(ICD_10, "C50") & sex == "male"
			//drop persons 45 years or older with specific leukemia
				drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0

		//calculate SE in provinces and cmas
			//identify different types of mortalities				
				generate AM = .
					foreach z of local AM{
						replace AM = 1 if regexm(ICD_10, "^`z'") & age<75 
					}
		
				generate pre = .
					foreach z of local preventable{
						replace pre = 1 if regexm(ICD_10, "^`z'") & age<75 
					}
				
					foreach z of local pre_tre{
						replace pre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
					}
				
				generate tre = .
					foreach z of local treatable{
						replace tre = 1 if regexm(ICD_10, "^`z'") & age<75 
					}	
				
					foreach z of local pre_tre{
						replace tre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
					}		
			}			
		
	preserve	
		//merge with w_se for each geo level separately			
			merge m:1 age_group `x' 									     ///
				using ".\Data\stdw - w_se - `x' - 2011-15 - winst - MASTER.dta", 	///
				nogen keep(1 3)
				
		//generate ONE w_se variable
			generate w_se_`x' = .
			
			foreach i of numlist 1/5{
				replace w_se_`x' = w_se_`x'Xnat_1`i' if year == 201`i'
			}	
			
	//count all-cause and premature mortalities by age groups and year
		//identify different types of mortalities
			generate all = 1 
			generate prem = 1 if age<75 
			
		//generate ONE age_count to use in the SE formula	
			generate age_count_nr = .
				foreach i of numlist 1/5{
					replace age_count_nr = age_count_`x'_1`i' if year == 201`i'
				}
				
		//calculate SE in provinces/cmas
			//collapse and count mortalities in each age group, year, and province/cma (i.e. Ami in formula)
				collapse (first) w_se_`x' age_count_nr (sum) `y'_n=`y' 		///
					,by(age_group year `x')
						
			//round for vetting reasons
				generate `y'_n_rnd = round(`y', 5)
				generate age_count_rnd = round(age_count_nr)
					
			//generate the "first" and "second" variables to be able to calculate SE later
				generate in1_se_`y'_`x' = w_se_`x' * `y'_n_rnd * (age_count_rnd - `y'_n_rnd)
				bysort year `x': egen in2_se_`y'_`x'= total(in1_se_`y'_`x')
				
			//calculate SE
				generate se_`y'_`x' = sqrt(in2_se_`y'_`x')
				
		//clean and save
			collapse (first) se_`y'_`x', by(year `x')
			
			save "./Data/SE - `y' - `x'.dta", replace	
		
	restore
		}
	}

end


* 5. merge mortality rates and SEs and calculate %95 CI
capture program drop merge_mr_se
program define merge_mr_se
*-------------------------------------------------------------------------------
//set macros
	local se_level cma prov nat
	local ind all prem AM pre tre
	
//merge mortality rates with SE and calculate %95CI for each geo level
	foreach x of local se_level{
		foreach y of local ind{
		//open mortality data
			use "./Data/rates - `y' - `x'.dta", clear
			
		//merge with SE
			//crude and premature SE
			merge 1:1 `x' year using 										///
				"./Data/SE - `y' - `x'.dta", nogen
				
		//calculate %95CI
				generate ci_l_`y'_`x' = `y'_mortality_rate - (1.96 * se_`y'_`x')
				generate ci_u_`y'_`x' = `y'_mortality_rate + (1.96 * se_`y'_`x')	
	
		//order
			if "`y'" == "all"{
				order year `x' `y'_mortality_rate total_death 				///
					total_population se_`y'_`x' ci_l_`y'_`x' ci_u_`y'_`x'
			}
			
			if "`y'" != "all"{
				order year `x' `y'_mortality_rate total_`y'_death			///
					total_population_aged_0to74 se_`y'_`x' ci_l_`y'_`x' 	///
					ci_u_`y'_`x'
			}
			
		//delete missing observations
			drop if `x' == 99
				
		//save
			save "./Data/rates - SE - `y' - `x'.dta", replace
		}	
	}
	
end
	

* 6. export mortality rates for release
capture program drop for_release
program define for_release
*-------------------------------------------------------------------------------
//set macros 
	local level nat prov cma
	local ind all prem AM pre tre

//append for each geo level
	//harmonize datasets
		foreach x of local level{
			foreach y of local ind{
				//open data	
					use "./Data/rates - SE - `y' - `x'.dta", clear
				
					if "`y'" != "all"{
						rename total_`y'_death total_death
						rename total_population_aged_0to74 total_population
					}
					
					rename `y'_mortality_rate ASDR
					rename se_`y'_`x' se
					rename ci_l_`y'_`x' ci_l
					rename ci_u_`y'_`x' ci_u
				
					gen death_type = "`y'"
				
				//save
					save "./Data/rates - SE - `y' - `x' - to append.dta", replace
		}		
	}
	
	local ind prem AM pre tre
	
	foreach x of local level{
		//open data	
			use "./Data/rates - SE - all - `x' - to append.dta", clear
				
				foreach y of local ind{
					append using "./Data/rates - SE - `y' - `x' - to append.dta"
				}
		
			save "./Data/rates - SE - `x' - appended.dta", replace
	}		
	
	foreach x of local level{
	    
			use "./Data/rates - SE - `x' - appended.dta", clear
			
			if "`x'"=="prov" {
				
			//define labels for provinces
				label define provinces 10 "NFL"								///
									   11 "PEI"    							///
									   12 "NS"								///	
								       13 "NB"								///
									   24 "Quebec"							///	
									   35 "ON"								///
									   46 "Manitoba"						///
									   47 "SK"								///
									   48 "Alberta"							///
									   59 "BC"								///
									   60 "Yukon"							///
									   61 "NWT"								///
									   62 "Nunavut"
						   
				label values prov provinces	
			}
		
			if "`x'"=="cma" {
				
			//keep the eight most populous cities in Canada
				keep if inlist(cma,421,462,505,535,602,825,835,933)
			
			//define lables for eight most populous cities in Canada
				label define cities 421 "Quebec"							///
									462 "Montreal"							///	
									505 "Ottawa - Gatineau"					///
									535 "Toronto"							///
									602 "Winnipeg"							///
									825 "Calgary"							///
									835 "Edmonton"							///
									933 "Vancouver"
						
				label values cma cities
			}
				
			//drop missing observations
				drop if missing(year)			
				
	//export									
		export excel using "./Data/to release/rates - `x'.xls",	///
			firstrow(variables) sheet("`x' mortality rates") replace 
		}	
	

end

			
* X. Control
*-------------------------------------------------------------------------------
//merge VSD and Census datasets
	merge_data
	
//calculate DA-level mortality rates
	calc_da_mr
	
//calculate mortality rates
	calc_mr
	
//calculate SE and 95%CI
	calc_se
	
//merge mortalities and SEs	
	merge_mr_se

//export spreadsheets
	for_release
	

	
	

	