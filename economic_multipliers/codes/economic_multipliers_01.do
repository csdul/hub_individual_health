/*
********************************************************************************
  Author: Daniel Yupanqui
  First update (MM-DD-YY): 09-08-2025
  Last update  (MM-DD-YY): 09-08-2025
  Task: Harmonize Input-Output multipliers by provinces and territories

*******************************************************************************/

*0. Set
{
  clear
  cd "\\cabinet.usask.ca\work$\ymn403\My Documents\Work\data_analysis\CSDUL\Building CSDUL\CDUL pilot - out and RDC\Hub\economic_multipliers"
}

*1. Import Raw Data
{
 *Import Final Demand
  import delimited "data\36100595.csv"
 
 *Keep variables
  keep ref_date geo multipliertype variable geographicalcoverage ///
       industry uom value
 
 *Renames
  rename ref_date year
  rename geo province
  rename uom unit
  rename multipliertype multiplier_type
  rename geographicalcoverage coverage
  rename value multiplier_value
  
 *Save file
  save results\economic_multipliers, replace 
}
 
*2. Save annual files
{ 
 *Loop and save
  forvalues i = 2010/2020 {
    use if year == `i' using data\economic_multipliers, clear
    save data\economic_multipliers_`i', replace
  }
   
}

*3. Save in CSV
{
 *Loop and save
  forvalues i = 2010/2020 {
    use data\economic_multipliers_`i', clear
    export delimited using "results\economic_multipliers_`i'.csv", replace
  }
}	
