/*==============================================================================

	MTHIC - Avoidable Mortality
================================================================================	
Programmer: Anousheh Marouzi
Task: Open VSD 2011-2015 and keep place of usual residence and cause of death.
	  Delete institutional records. Harmonize and append 2011-2015. Create 
	  frequency tables.
Date started: 17th May, 2021
Last edited: Jan 18, 2022
================================================================================

	Details
================================================================================
steps
	0. setup
	1. identify postal codes with institutional death records	
	2. open and reduce VSD 2011-2015
	3. append VSD 2011-2015
	4. delete institutional records and prepare to use in PCCF+
	5. create frequency tables
	6. export frequency tables
	
	X. control

inputs
	1. VSD - 2011 - RAW
	2. VSD - 2012 - RAW
	3. VSD - 2013 - RAW
	4. VSD - 2014 - RAW
	5. VSD - 2015 - RAW
	6. VSD inst - 2011 - RAW
	7. VSD inst - 2012 - RAW
	8. VSD inst - 2013 - RAW
	9. VSD inst - 2014 - RAW
	10. VSD inst - 2015 - RAW

outputs
	1. VSD - 2011 - harm
	2. VSD - 2012 - harm
	3. VSD - 2013 - harm
	4. VSD - 2014 - harm
	5. VSD - 2015 - harm
	6. VSD - 2011-15 - appended
	7. VSD inst - 2011 - reduced
	8. VSD inst - 2012 - reduced
	9. VSD inst - 2013 - reduced
	10. VSD inst - 2014 - reduced
	11. VSD inst - 2015 - reduced
	12. VSD inst - 2011-15 - appended
	13. VSD - 2011-15 - MASTER
	14. freq - `geo level'
	
==============================================================================*/


* 0. setup
*-------------------------------------------------------------------------------
//name project
	local projectname "Avoidable Mortality"
	local filename "VSD 2011-15 harm"
	
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


* 1. identify postal codes with institutional death records	
capture program drop identify_inst
program define identify_inst
*-------------------------------------------------------------------------------	
//open and reduce CVSD_inst for years 2011 to 2015
	foreach i of numlist 1/5{
		use ".\Data\VSD inst - 201`i' - RAW.dta", clear
		
		//reduce data	
			collapse (first) instflag, by(pcode)
		
		//save
			save ".\Data\VSD inst - 201`i' - reduced.dta", replace
	}	
	
//append CVSD_inst 2011 to 2015
	//open first dataset
		use ".\Data\VSD inst - 2011 - reduced.dta", clear
	
	//append CVSD 2011-2015
		foreach i of numlist 2/5 {
			append using ".\Data\VSD inst - 201`i' - reduced.dta"
		}	
	
	//collapse to pcode
		collapse (first) instflag, by(pcode)
		
	//save
		save ".\Data\VSD inst - 2011-15 - appended.dta", replace
end		
	
* 2. open and reduce VSD 2011-2015
capture program drop reduce_cvsd
program define reduce_cvsd
*-------------------------------------------------------------------------------
//open CVSD 2011 to 2015 and reduce data
	foreach i of numlist 1/5{
		use ".\Data\VSD - 201`i' - RAW.dta", clear
		
	//reduce data
		keep event_year sex age_code age_value residence_province_3digit	///
			residence_postalcode death_cause_4digits
			
	//recode age variable
		destring age_value, replace 
		destring age_code, replace
		
		//replace minutes and hours to years
			replace age_value=0 if age_code==1
			replace age_value=0 if age_code==2
			replace age_value=0 if age_code==3
			replace age_value=0 if age_code==4
		
		drop age_code
		
	//drop death occured outside of Canada
		destring residence_province_3digit, replace
		drop if  residence_province_3digit <910 		
		
	//rename variables
		rename event_year 					year
		rename age_value 					age
		rename residence_province_3digit 	prov
	//	rename residence_censusdivision 	cd
	//	rename residence_censussubdivision 	csd
		rename residence_postalcode 		pcode
		rename death_cause_4digits 			ICD_10
	//	rename placeofdeath_locality		inst
		
	//clean up and save
		compress
		save ".\Data\VSD - 201`i' - harm.dta", replace
	}		
	
end

		
* 3. append VSD 2011-2015
capture program drop append_cvsd
program define append_cvsd
*-------------------------------------------------------------------------------
//open first dataset
	use ".\Data\VSD - 2011 - harm.dta", clear
	
//append CVSD 2011-2015
	foreach i of numlist 2/5 {
		append using ".\Data\VSD - 201`i' - harm.dta"
	}
		
//recode sex 
	replace sex="male"   if sex=="1"	
	replace sex="female" if sex=="2"
		
//clean up and save
	compress
	save ".\Data\VSD - 2011-15 - appended.dta", replace
		
//prepare to use in PCCF+ for mortality rates municipal level	
	drop if missing(pcode)
		
	generate ID =_n
	tostring ID, replace	
				
	save ".\Data\VSD - 2011-15 - appended - pccf input.dta", replace
end

	
* 4. delete institutional records and prepare to use in PCCF+
capture program drop drop_inst
program define drop_inst
*-------------------------------------------------------------------------------
//open dataset
	use ".\Data\VSD - 2011-15 - appended.dta", replace
	
//merge with VSD inst data
	merge m:1 pcode using ".\Data\VSD inst - 2011-15 - appended.dta"	///
		,nogen keep(1 3) //only 14 obs were not matched

//delete institutional records
	keep if missing(instflag)
			
//generate ID to use in PCCF+
	generate ID =_n
	tostring ID, replace	
		
//delete missing variables
	drop if missing(pcode) 	
		
//clean up and save
	compress
	save ".\Data\VSD - 2011-15 - MASTER.dta", replace

//save a dataset for using in PCCF+
	keep ID pcode
	save ".\Data\PCCF\pccf_input.dta", replace
end 


* 5. create frequency tables
capture program drop freq_tab
program define freq_tab
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

	//causes which are treatable and preventable	
	local pre_tre /// 
			I60 I61 I62 I63 I64 I67 I69 I20 I21 I22 I23 I24 I25 I70 I739	///
			E10 E11 E12 E13 E14 
		
	local avoidable `preventable' `treatable' `pre_tre'			

//create frequency tables for mortality rates at different geo levels
	foreach x of local level{
		foreach y of local ind{
		//open data
			if "`x'" != "cma" { 		
				use ".\Data\VSD - 2011-15 - appended.dta", clear
				
				//recode province variable to match Census data
					tostring prov, replace
					replace prov = subinstr(prov,"9","",1)
					destring prov, replace
				
//					destring year, replace
					
				//merge with VSD inst data
					merge m:1 pcode using ".\Data\VSD inst - 2011-15 - appended.dta" ///
						,nogen keep(1 3) 
				
				//generate national variable to be used later
					gen nat = 1 
										
				//save 
					save ".\Data\VSD - prov - 2011-15 - MASTER.dta", replace
			}
			
			if "`x'" == "cma" {
				//import pccf output to get cmas
					import delimited ".\Data\PCCF\for cma rates\out.csv", clear
			
					keep id pcode cma 
					rename id ID
					tostring ID, replace
		
				//merge with death data
					merge 1:1 ID using ".\Data\VSD - 2011-15 - appended - pccf input.dta", nogen
				
				//merge with VSD inst data
					merge m:1 pcode using ".\Data\VSD inst - 2011-15 - appended.dta" ///
						,nogen keep(1 3)
				
				//keep the eight most populous cities 
					keep if inlist(cma,421,462,505,535,602,825,835,933)
					
				//save 
					save ".\Data\VSD - cma - 2011-15 - MASTER.dta", replace	
			}
	
		
		//identify all_cause mortalities 	
			if "`y'" == "all" {
				generate all = 1
				generate all_inst = 1 if !missing(instflag)
				generate all_f = 1 if sex =="female"
				generate all_m = 1 if sex =="male"
				generate all_age = age
			}				

		//identify premature mortalities 	
			if "`y'" == "prem"{
				generate prem = 1 if age<75
				generate prem_inst = 1 if age<75 & !missing(instflag)
				generate prem_f = 1 if age<75 & sex =="female"
				generate prem_m = 1 if age<75 & sex =="male"
				generate prem_age = age if age<75
			}	
			
	
		//prepare data to identify AM, treatable and preventable mortality rates	
			//generate younger than 45 years old
				generate age45=1 if age<45
				replace age45=0 if missing(age45)	


		//identify avoidable mortalities 	
			if "`y'" == "AM"{
			
			//drop males with breast cancer
				drop if inlist(ICD_10, "C50") & sex == "male"
			//drop persons 45 years or older with specific leukemia
				drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0
				
				generate AM = .
				generate AM_inst = .
				generate AM_f = .
				generate AM_m = .
				generate AM_age = .
				
				foreach z of local avoidable{
					replace AM = 1 if regexm(ICD_10, "^`z'") & age<75
					replace AM_inst = 1 if regexm(ICD_10, "^`z'") & age<75 & !missing(instflag) 
					replace AM_f = 1 if regexm(ICD_10, "^`z'") & age<75 & sex == "female"
 					replace AM_m = 1 if regexm(ICD_10, "^`z'") & age<75 & sex == "male"
					replace AM_age = age if regexm(ICD_10, "^`z'") & age<75
				}
					
			}	
	
		//identify preventable mortalities 	
			if "`y'" == "pre"{
			
			//drop males with breast cancer
				drop if inlist(ICD_10, "C50") & sex == "male"
			//drop persons 45 years or older with specific leukemia
				drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0
				
				generate pre = .
				generate pre_inst = .
				generate pre_f = .
				generate pre_m = .
				generate pre_age = .
				
				foreach z of local preventable{
					replace pre = 1 if regexm(ICD_10, "^`z'") & age<75 
					replace pre_inst = 1 if regexm(ICD_10, "^`z'") & age<75 & !missing(instflag) 
					replace pre_f = 1 if regexm(ICD_10, "^`z'") & age<75 & sex == "female"
 					replace pre_m = 1 if regexm(ICD_10, "^`z'") & age<75 & sex == "male"	
					replace pre_age = age if regexm(ICD_10, "^`z'") & age<75
				}
				
				foreach z of local pre_tre{
					replace pre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
					replace pre_inst = 0.5 if regexm(ICD_10, "^`z'") & age<75 & !missing(instflag)
					replace pre_f = 0.5 if regexm(ICD_10, "^`z'") & age<75 & sex == "female"
					replace pre_m = 0.5 if regexm(ICD_10, "^`z'") & age<75 & sex == "male"
					replace pre_age = age if regexm(ICD_10, "^`z'") & age<75
				}			
				
			}

		//identify treatable mortalities	
			if "`y'" == "tre"{
			//drop males with breast cancer
				drop if inlist(ICD_10, "C50") & sex == "male"
			//drop persons 45 years or older with specific leukemia
				drop if inlist(ICD_10, "C910", "C911", "C921") & age45 == 0
				
				generate tre = .
				generate tre_inst = .
				generate tre_f = .
				generate tre_m = .
				generate tre_age = .
				
				foreach z of local treatable{
					replace tre = 1 if regexm(ICD_10, "^`z'") & age<75 
					replace tre_inst = 1 if regexm(ICD_10, "^`z'") & age<75 & !missing(instflag)
 					replace tre_f = 1 if regexm(ICD_10, "^`z'") & age<75 & sex == "female"
 					replace tre_m = 1 if regexm(ICD_10, "^`z'") & age<75 & sex == "male"
					replace tre_age = age if regexm(ICD_10, "^`z'") & age<75
				}	
				
				foreach z of local pre_tre{
					replace tre = 0.5 if regexm(ICD_10, "^`z'") & age<75 
					replace tre_inst = 0.5 if regexm(ICD_10, "^`z'") & age<75 & !missing(instflag)
					replace tre_f = 0.5 if regexm(ICD_10, "^`z'") & age<75 & sex == "female"
					replace tre_m = 0.5 if regexm(ICD_10, "^`z'") & age<75 & sex == "male"
					replace tre_age = age if regexm(ICD_10, "^`z'") & age<75
				}
			}			
		
		//generate a variable for mortality category
			gen mortality_type = "`y'"
		
		//calculate death counts in each mortality category
			collapse (first) mortality_type (sum) total_death=`y'			/// 
				total_inst_death=`y'_inst female=`y'_f male=`y'_m			///
				(mean)age_mean=`y'_age (sd)age_sd=`y'_age, by (`x')
			
		//save
			save ".\Data\freq - `x' - `y'.dta", replace
		}
	}	
		
		
//append frequency tables of different mortality types at different geo levels
	//set macros 
		local mtype prem AM pre tre
		local level cma prov nat
	
	//append freq tables at different geo levels
	foreach x of local level{
	
		//open first dataset
			use ".\Data\freq - `x' - all.dta", clear

		//append freq tables 
			foreach y of local mtype{
				append using ".\Data\freq - `x' - `y'.dta"		
			}
		
		//save
			save ".\Data\freq - appended - `x'.dta", replace
	}
	
//reshape frequency tables
	foreach x of local level{
		//open data
			use ".\Data\freq - appended - `x'.dta", clear
			
		//recode mortality type for using xpose command later
			replace mortality_type = "1" if mortality_type == "all" 
			replace mortality_type = "2" if mortality_type == "prem" 
			replace mortality_type = "3" if mortality_type == "AM" 
			replace mortality_type = "4" if mortality_type == "pre"
			replace mortality_type = "5" if mortality_type == "tre"
			
			destring mortality_type, replace
		
		//round for vetting reasons
			replace total_death = round(total_death, 5)
			replace total_inst_death = round(total_inst_death, 5)
			replace female = round(female, 5)
			replace male = round(male, 5)
		
		//reshape dataset
			reshape wide total_death total_inst_death female male age_mean,  ///
				i(mortality_type) j(`x')
				
		//transpose dataset
			xpose, clear varname
			
		//rename variables
			rename v1 all_cause_mortality
			rename v2 premature_mortality
			rename v3 avoidable_mortality
			rename v4 preventable_mortality
			rename v5 treatable_mortality
			
			rename _varname freq
			
		//generate geo level variable and recode charachteristics variable	
			local prov_c 10 11 12 13 24 35 46 47 48 59 60 61 62
			local cma_c 421 462 505 535 602 825 835 933
			
			if "`x'" == "prov"{
				generate prov = substr(freq,-2,2) 
				
				foreach c of local prov_c {
					replace freq = subinstr(freq,"`c'","",1)
				}
			}
		
			if "`x'" == "cma"{
				generate cma = substr(freq,-3,3)
				
				foreach c of local cma_c {
					replace freq = subinstr(freq,"`c'","",1)
				}
			}
			
		//order and save
			if "`x'" == "cma" {
				order cma freq
			}

			if "`x'" == "prov" {
				order prov freq
			}
			
			if "`x'" == "nat" {
				order freq
			}
			
			drop in 1 
			
			save ".\Data\freq - `x'.dta", replace
	}
end		
		
* 6. export frequency tables
capture program drop release_freq
program define release_freq
*-------------------------------------------------------------------------------
//set macros
	local level cma prov nat
	
//export in excel
	foreach x of local level{
		//open data
			use ".\Data\freq - `x'.dta", clear
		
		//define lables for provinces
			if "`x'" == "prov" {
				destring prov, replace
				label define provinces 10 "NFL"								///
									   11 "PEI"								///
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
			
		//define lables for cmas
			if "`x'" == "cma" {
				destring cma, replace
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
		
		//export
			export excel using ".\Data\to release\freq - `x'.xls",			///
				firstrow(variables) sheet("`x' frequency") replace
	}	
		
end


* X. Control		
*-------------------------------------------------------------------------------
//identify institutional death pcodes
	identify_inst
	
//reduce cvsd
	reduce_cvsd
	
//append cvsd
	append_cvsd
	
//delete institutional deaths
	drop_inst
	
//create frequency tables
	freq_tab
	
//release frequency tables
	release_freq
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		





		

