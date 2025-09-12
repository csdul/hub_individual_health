################################################################################
#
# Copyright © 2025 Authors
# 
# This code is distributed under the Creative Commons Attribution 4.0 
# International License (CC BY 4.0).
# 
# By using this code, you agree to:
#
#   1. Cite the associated publication: 
#
#      Marouzi Anousheh, Plante Charles. "Introducing the Canadian Area-Level 
#      Social Determinants of Health Indicators (CASDOHI)," medRxiv, 2025. 
#
#   2. Credit Statistics Canada when using the code's produced datasets by 
#      citing the original data sources:
#      
#      Census Profile 2021. Statistics Canada Catalogue no. 98-316-X2021001.
#
#      Census Profile 2016. Statistics Canada Catalogue no. 98-316-X2016001.
#
#      Census Profile 2011. Statistics Canada Catalogue no. 98-316-X2011001. 
#
#      National Household Survey Profile 2011. Statistics Canada Catalogue
#      no. 99-004-X2011001
#
#   3. If you share this code or derivatives, include this copyright and terms 
#      of use statement. 
#
#   4. This code is provided "as-is," without warranty of any kind. 
#
################################################################################

# Canadian Social Determinants of Health Indicators (CASDOHI) Project       ####
# ============================================================================ #
# Summary: This R script uses Census Profiles 2011, 2016, and 2021, and National
#   Household Survey (NHS) Profile to create CASDOHI for 2011, 2016, and 2021 at 
#   Dissemination Area (DA) level. Additionally, we use attribute files to add
#   larger geographic variables to CASDOHI.
#
# Programmer: Anousheh Marouzi
#
# Start date: October 4th, 2024
# 
# Last update: June 23rd, 2025
# ============================================================================ #
 
# FILE NAMING CONVENTIONS                                                   ####
# ---------------------------------------------------------------------------- #
# This R Script uses the following rules to create meaningful names for datasets
# and objects as follows:
#
# In the current R Script, we name datasets according to a set of rules to 
# facilitate understanding what they contain, how they relate to other files, 
# and the process a dataset goes through. 
#
# The purpose of this R Script is to manipulate and link different datasets to 
# create a data product (i.e. CASDOHI) that can be used by other researchers. 
# Each section opens a dataset, manipulates it, and saves it by a meaningful 
# name. 
#
# An overview of the structure of a dataset file's name is presented below: 
#
#  'main information'_'geo unit'_'geo covered'_`years covered'_`stage'
#
# Each section of this structure is explained below:
#
# 1. Main information:
#    This part of the name indicates the type of information included in the 
#    file. In this script, this can be: 
#      a. census_profile -> means that the dataset include census profile data 
#         on both short and long form.
#      b. census_profile_short -> means dataset include only census profile 
#         short form.
#      c. nhs_profile -> means that the dataset include NHS profile, which is 
#         the long form of census 2011.
#      d. casdohi -> means the dataset include casdohi indicators which are 
#         built based on census profiles.
#      e. attribute_file -> the statistics Canada attribute files.
#
# 2. Geo unit:
#    This indicates the level of data. For example, da11 means that the dataset
#    is provided at Dissemination Area 2011 level.
#
# 3. Geo covered:
#    This is the gepgraphic area that is covered by a dataset. For example, a
#    province, or Canada.
#
# 4. Years covered:
#    This indicates the years that are covered in the dataset.
#
# 5. Stage:
#    Files in this do-file are classified into three main groups: Raw, Master, 
#    and Use. These are indicative of three main steps that a dataset usually
#    goes through in this do-file; A dataset matures from being a Raw file into  
#    a Master file and finally becomes a Use file. However, these are not the  
#    only three statuses of a dataset. Between the Raw and Master steps, we may  
#    save the dataset as a Reduced or Harmonized file. Following is a flow    
#    chart of how a dataset is processed in this do-file: 
#    
#             RAW --> (REDUCED) --> (HARM) --> MASTER --> USE 
#    
#    We add a suffix to the name of a dataset to show these stages. Below, we 
#    describe these 5 stages and provide the suffix in parentheses as they  
#    exist in the do-file:
#
#      a. Raw (_RAW): The first step in this do-file is to rename all raw  
#         datasets files according to our naming structure. This is done to    
#         have a consistent and meaningful name convention in our do-files 
#         across all our projects. We put the suffix "_RAW" at the end of the 
#         renamed raw files. These files are 100% similar to the original ones 
#         as provided in RDC.
#    
#      b. Reduced (_REDUCED): We add this suffix to datasets that we have 
#         dropped some of its variables or observations (reduced the number of 
#         variables or observations.) This step is usually done to speed up  
#         run times.
#     
#      c. Harmonized (_HARM): This suffix is added to datasets when its
#         variables are manipulated in a way to be harmonized in relation to
#         other datasets in the do-file. For example, variable sex is recorded
#         in different datasets to be consistent with how it is coded in the 
#         Census.
#     
#      d. Master (_MASTER): The Master stage of a dataset happens when general 
#         manipulations, such as reducing the number of variables and recoding
#         them, have been done, and the dataset is ready for more specialized
#         manipulation. A key feature of a Master file is that it usually 
#         contains the same number of rows as the raw file.
#    
#      e. Use (_USE): We add the suffix "USE" to a dataset when we have 
#         manipulated the Master dataset in a way that is ready for analysis.
#         This analysis can be descriptive, modeling, or any other type of 
#         analysis that produces the results of a research project. This step 
#         usually involves generating variables and dropping unnecessary 
#         observations.
#
#    In addition to these stages, we may save the files with other suffices
#    based on specific needs of the R script. Two examples are _APPENDED and
#    _RELEASE.
# ---------------------------------------------------------------------------- #

# LIST OF DATASETS IN THIS R SCRIPT                                         ####
# ---------------------------------------------------------------------------- #
# Inputs:
#   1.  nhs_profile_da11_can_2011_RAW.txt
#   2.  census_profile_short_da11_alta_2011_RAW.csv
#   3.  census_profile_short_da11_bc_2011_RAW.csv
#   4.  census_profile_short_da11_man_2011_RAW.csv
#   5.  census_profile_short_da11_nb_2011_RAW.csv
#   6.  census_profile_short_da11_nl_2011_RAW.csv
#   7.  census_profile_short_da11_ns_2011_RAW.csv
#   8.  census_profile_short_da11_nvt_2011_RAW.csv
#   9.  census_profile_short_da11_nwt_2011_RAW.csv
#   10. census_profile_short_da11_ont_2011_RAW.csv
#   11. census_profile_short_da11_pei_2011_RAW.csv
#   12. census_profile_short_da11_que_2011_RAW.csv
#   13. census_profile_short_da11_sask_2011_RAW.csv
#   14. census_profile_short_da11_yt_2011_RAW.csv
#   15. census_profile_da16_atl_2016_RAW.csv
#   16. census_profile_da16_bc_2016_RAW.csv
#   17. census_profile_da16_on_2016_RAW.csv
#   18. census_profile_da16_pra_2016_RAW.csv
#   19. census_profile_da16_que_2016_RAW.csv
#   20. census_profile_da16_ter_2016_RAW.csv
#   21. census_profile_da21_atl_2021_RAW.csv
#   22. census_profile_da21_bc_2021_RAW.csv
#   23. census_profile_da21_on_2021_RAW.csv
#   24. census_profile_da21_pra_2021_RAW.csv
#   25. census_profile_da21_que_2021_RAW.csv
#   26. census_profile_da21_ter_2021_RAW.csv
#   27. attribute_file_db11_2011_RAW.txt
#   28. attribute_file_db16_2016_RAW.csv
#   29. attribute_file_db21_2021_RAW.csv
#
# Outputs:
#   1.  nhs_profile_da11_can_2011_HARM.csv
#   2.  census_profile_short_da11_alta_2011_HARM.csv
#   3.  census_profile_short_da11_bc_2011_HARM.csv
#   4.  census_profile_short_da11_man_2011_HARM.csv
#   5.  census_profile_short_da11_nb_2011_HARM.csv
#   6.  census_profile_short_da11_nl_2011_HARM.csv
#   7.  census_profile_short_da11_ns_2011_HARM.csv
#   8.  census_profile_short_da11_nvt_2011_HARM.csv
#   9.  census_profile_short_da11_nwt_2011_HARM.csv
#   10. census_profile_short_da11_ont_2011_HARM.csv
#   11. census_profile_short_da11_pei_2011_HARM.csv
#   12. census_profile_short_da11_que_2011_HARM.csv
#   13. census_profile_short_da11_sask_2011_HARM.csv
#   14. census_profile_short_da11_yt_2011_HARM.csv
#   15. census_profile_short_da11_can_2011_HARM.csv
#   16. census_profile_da11_can_2011_HARM.csv
#   17. census_profile_da16_atl_2016_HARM.csv
#   18. census_profile_da16_bc_2016_HARM.csv
#   19. census_profile_da16_on_2016_HARM.csv
#   20. census_profile_da16_pra_2016_HARM.csv
#   21. census_profile_da16_que_2016_HARM.csv
#   22. census_profile_da16_ter_2016_HARM.csv
#   23. census_profile_da16_can_2016_HARM.csv
#   24. census_profile_da21_atl_2021_HARM.csv
#   25. census_profile_da21_bc_2021_HARM.csv
#   26. census_profile_da21_on_2021_HARM.csv
#   27. census_profile_da21_pra_2021_HARM.csv
#   28. census_profile_da21_que_2021_HARM.csv
#   29. census_profile_da21_ter_2021_HARM.csv
#   30. census_profile_da21_can_2021_HARM.csv
#   31. casdohi_da11_can_2011_MASTER.csv
#   32. casdohi_da16_can_2016_MASTER.csv
#   33. casdohi_da21_can_2021_MASTER.csv
#   34. attribute_file_da11_2011_USE.csv
#   35. attribute_file_da16_2016_USE.csv
#   36. attribute_file_da21_2021_USE.csv
#   37. casdohi_da11_can_2011_RELEASE.csv
#   38. casdohi_da16_can_2016_RELEASE.csv
#   39. casdohi_da21_can_2021_RELEASE.csv
# ---------------------------------------------------------------------------- #

# TABLE OF CONTENTS                                                         ####
# ---------------------------------------------------------------------------- #
# 0. SETUP
# 1. HARMONIZE DA-LEVEL NHS PROFILE, 2011
# 2. HARMONIZE DA-LEVEL CENSUS PROFILE (SHORT FORM), 2011
# 3. APPEND HARMONIZED DA-LEVEL CENSUS PROFILES (SHORT FORM), 2011
# 4. MERGE HARMONIZED 2011 CENSUS (SHORT) AND NHS PROFILES
# 5. HARMONIZE DA-LEVEL CENSUS PROFILES, 2016
# 6. APPEND HARMONIZED DA-LEVEL CENSUS PROFILES, 2016
# 7. HARMONIZE DA-LEVEL CENSUS PROFILES, 2021
# 8. APPEND HARMONIZED DA-LEVEL CENSUS PROFILES, 2021
#   8.1. APPEND HARMONIZED PROFILES FOR ATL, BC, AND ON, 2021
#   8.2. APPEND HARMONIZED PROFILES FOR PRA, QUE, AND TER, 2021
#   8.3. APPEND THE TWO APPENDED FILES AND EXPORT 
# 9. CONSTRUCT CASDOHI 2011
#   9.1. POPULATION AND AGE GROUPS
#   9.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT
#   9.3. EHNOCULTURAL INDICATORS
#   9.4. INCOME
#   9.5. EDUCATION
#   9.6. LABOUR FORCE
#   9.7. HOUSING
# 10. CONSTRUCT CASDOHI 2016
#   10.1. POPULATION AND AGE GROUPS
#   10.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT
#   10.3. EHNOCULTURAL INDICATORS
#   10.4. INCOME
#   10.5. EDUCATION
#   10.6. LABOUR FORCE
#   10.7. HOUSING
# 11. CONSTRUCT CASDOHI 2021
#   11.1. POPULATION AND AGE GROUPS
#   11.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT
#   11.3. EHNOCULTURAL INDICATORS
#   11.4. INCOME
#   11.5. EDUCATION
#   11.6. LABOUR FORCE
#   11.7. HOUSING
# 12. HARMONIZE ATTRIBUTE FILES, 2011, 2016, & 2021 
#   12.1. HARMONIZE ATTRIBUTE FILE, 2011
#   12.2. HARMONIZE ATTRIBUTE FILE, 2016
#   12.3. HARMONIZE ATTRIBUTE FILE, 2021
# 13. CREATE THE FINAL VERSION OF CASDOHI FOR CENSAL YEARS
#   13.1. JOIN CASDOHI MASTER AND HARMONIZED ATTRIBUTE FILES AT DA LEVEL
#   13.2. VALIDATE BY CHECKING IF POP COUNTS FROM ATTRIBUTE AND CP MATCH
#   13.3. CLEAN AND PREPARE THE FINAL VERSION OF CASDOHI
# ---------------------------------------------------------------------------- #

# VERSION 2                                                                 ####
# ---------------------------------------------------------------------------- #
# In this version, Census Profiles are harmonized and saved in a way that can be
# used in R script "casdohi - intercensal years - 2011to2021 - 01" to estimate
# census profile for intercensal years, which will be then used to calculate 
# casdohi for those years.
# ---------------------------------------------------------------------------- #

# 0. SETUP                                                                  ####
# ---------------------------------------------------------------------------- #
# Clear environment
rm(list=ls(all=TRUE)) 

# Call packages
library(tidyverse)
library(stringr)
library(janitor)

# Set directory
setwd("/Users/Anousheh/Desktop/Research/CASDOHI")
# ---------------------------------------------------------------------------- #
   
# 1. HARMONIZE DA-LEVEL NHS PROFILE, 2011                                   ####
# ---------------------------------------------------------------------------- #

# Open raw file
nhs_profile_da11_can_2011_RAW <- 
  read_csv("Data/nhs_profile_da11_can_2011_RAW.txt")

# Clean the raw file to be able to work with strings
nhs_profile_da11_can_2011_RAW <- nhs_profile_da11_can_2011_RAW |> 
  clean_names()

# Create a new dataset for harmonized NHS Profile
nhs_profile_da11_can_2011_HARM <- nhs_profile_da11_can_2011_RAW |>
  
  # Filter dataset to DAs only
  filter(grepl("^[1-6]", x2011_nhs)) |>

  # Drop the percentage from DAs
  mutate(da_id_11 = as.numeric(substr(x2011_nhs, 1, 8))) |>
  
  # Select profile characteristics we need
  select(da_id_11, median_income_2283, median_income_2265, median_income_2247, 
         median_after_tax_income_2331, median_after_tax_income_2315, 
         median_after_tax_income_2299, average_income_2284, average_income_2266, 
         average_income_2248, average_after_tax_income_2332, 
         average_after_tax_income_2316, average_after_tax_income_2300, 
         females_in_private_households_by_aboriginal_identity, 
         males_in_private_households_by_aboriginal_identity, 
         total_population_in_private_households_by_aboriginal_identity, 
         aboriginal_identity_1369, aboriginal_identity_1361, 
         aboriginal_identity_1353, total_number_of_private_households_by_tenure, 
         owner, renter, band_housing, 
         total_number_of_private_households_by_housing_suitability, 
         not_suitable, 
         total_number_of_occupied_private_dwellings_by_condition_of_dwelling, 
         major_repairs_needed, 
         total_number_of_owner_and_tenant_households_with_household_total_income_greater_than_zero_in_non_farm_non_reserve_private_dwellings_by_shelter_cost_to_income_ratio, 
         spending_30_percent_or_more_of_household_total_income_on_shelter_costs, 
         percent_of_owner_households_spending_30_percent_or_more_of_household_total_income_on_shelter_costs, 
         median_value_of_dwellings, average_value_of_dwellings, 
         percent_of_tenant_households_spending_30_percent_or_more_of_household_total_income_on_shelter_costs, 
         government_transfer_payments_percent_2375, 
         government_transfer_payments_percent_2358, 
         government_transfer_payments_percent_2341, 
         females_in_private_households_by_immigrant_status_and_period_of_immigration, 
         males_in_private_households_by_immigrant_status_and_period_of_immigration, 
         total_population_in_private_households_by_immigrant_status_and_period_of_immigration, 
         non_immigrants_40, non_immigrants_29, non_immigrants_18, immigrants_41, 
         immigrants_30, immigrants_19, x2006_to_2011_48, x2006_to_2011_37, 
         x2006_to_2011_26, non_permanent_residents_49, 
         non_permanent_residents_38, non_permanent_residents_27, 
         males_in_private_households_by_visible_minority, 
         females_in_private_households_by_visible_minority, 
         total_population_in_private_households_by_visible_minority, 
         total_visible_minority_population_474, 
         total_visible_minority_population_489, 
         total_visible_minority_population_459, 
         south_asian_475, south_asian_490, south_asian_460, chinese_476, 
         chinese_491, chinese_461, black_477, black_492, black_462, 
         filipino_478, filipino_493, filipino_463, arab_480, arab_495, arab_465, 
         latin_american_479, latin_american_494, latin_american_464, 
         southeast_asian_481, southeast_asian_496, southeast_asian_466, 
         west_asian_482, west_asian_497, west_asian_467, korean_483, korean_498, 
         korean_468, japanese_484, japanese_499, japanese_469, 
         females_mobility_status_1_year_ago, males_mobility_status_1_year_ago, 
         total_mobility_status_1_year_ago, movers_1738, movers_1729, 
         movers_1720, females_mobility_status_5_years_ago, 
         males_mobility_status_5_years_ago, total_mobility_status_5_years_ago, 
         movers_1765, movers_1756, movers_1747, 
         no_certificate_diploma_or_degree_1793, 
         no_certificate_diploma_or_degree_1783, 
         no_certificate_diploma_or_degree_1773, 
         females_aged_15_years_and_over_by_highest_certificate_diploma_or_degree, 
         males_aged_15_years_and_over_by_highest_certificate_diploma_or_degree, 
         total_population_aged_15_years_and_over_by_highest_certificate_diploma_or_degree, 
         university_certificate_diploma_or_degree_at_bachelor_level_or_above_1799, 
         university_certificate_diploma_or_degree_at_bachelor_level_or_above_1789, 
         university_certificate_diploma_or_degree_at_bachelor_level_or_above_1779, 
         females_aged_15_years_and_over_by_major_field_of_study_classification_of_instructional_programs_cip_2011, 
         males_aged_15_years_and_over_by_major_field_of_study_classification_of_instructional_programs_cip_2011, 
         total_population_aged_15_years_and_over_by_major_field_of_study_classification_of_instructional_programs_cip_2011, 
         education_1862, education_1848, education_1834, visual_and_performing_arts_and_communications_technologies_1863, 
         visual_and_performing_arts_and_communications_technologies_1849, visual_and_performing_arts_and_communications_technologies_1835, 
         humanities_1864, humanities_1850, humanities_1836, 
         social_and_behavioural_sciences_and_law_1865, 
         social_and_behavioural_sciences_and_law_1851, 
         social_and_behavioural_sciences_and_law_1837, 
         business_management_and_public_administration_1866, 
         business_management_and_public_administration_1852, 
         business_management_and_public_administration_1838, 
         physical_and_life_sciences_and_technologies_1867, 
         physical_and_life_sciences_and_technologies_1853, 
         physical_and_life_sciences_and_technologies_1839, 
         mathematics_computer_and_information_sciences_1868, 
         mathematics_computer_and_information_sciences_1854, 
         mathematics_computer_and_information_sciences_1840, 
         architecture_engineering_and_related_technologies_1869, 
         architecture_engineering_and_related_technologies_1855, 
         architecture_engineering_and_related_technologies_1841, 
         agriculture_natural_resources_and_conservation_1870, 
         agriculture_natural_resources_and_conservation_1856, 
         agriculture_natural_resources_and_conservation_1842, 
         health_and_related_fields_1871, health_and_related_fields_1857, 
         health_and_related_fields_1843, 
         personal_protective_and_transportation_services_1872, 
         personal_protective_and_transportation_services_1858, 
         personal_protective_and_transportation_services_1844, 
         participation_rate_2009, participation_rate_2001, 
         participation_rate_1993, employment_rate_2010, employment_rate_2002, 
         employment_rate_1994, unemployment_rate_2011, unemployment_rate_2003, 
         unemployment_rate_1995, 
         female_labour_force_aged_15_years_and_over_by_class_of_worker, 
         male_labour_force_aged_15_years_and_over_by_class_of_worker, 
         total_labour_force_aged_15_years_and_over_by_class_of_worker, 
         self_employed_2026, self_employed_2021, self_employed_2016, 
         female_labour_force_aged_15_years_and_over_by_occupation_national_occupational_classification_noc_2011, 
         male_labour_force_aged_15_years_and_over_by_occupation_national_occupational_classification_noc_2011, 
         total_labour_force_population_aged_15_years_and_over_by_occupation_national_occupational_classification_noc_2011, 
         x0_management_occupations_2056, x0_management_occupations_2043, 
         x0_management_occupations_2030, 
         x1_business_finance_and_administration_occupations_2057, 
         x1_business_finance_and_administration_occupations_2044, 
         x1_business_finance_and_administration_occupations_2031, 
         x2_natural_and_applied_sciences_and_related_occupations_2058, 
         x2_natural_and_applied_sciences_and_related_occupations_2045, 
         x2_natural_and_applied_sciences_and_related_occupations_2032, 
         x3_health_occupations_2059, x3_health_occupations_2046, 
         x3_health_occupations_2033, 
         x4_occupations_in_education_law_and_social_community_and_government_services_2060, 
         x4_occupations_in_education_law_and_social_community_and_government_services_2047, 
         x4_occupations_in_education_law_and_social_community_and_government_services_2034, 
         x5_occupations_in_art_culture_recreation_and_sport_2061, 
         x5_occupations_in_art_culture_recreation_and_sport_2048, 
         x5_occupations_in_art_culture_recreation_and_sport_2035, 
         x6_sales_and_service_occupations_2062, 
         x6_sales_and_service_occupations_2049, 
         x6_sales_and_service_occupations_2036, 
         x7_trades_transport_and_equipment_operators_and_related_occupations_2063, 
         x7_trades_transport_and_equipment_operators_and_related_occupations_2050, 
         x7_trades_transport_and_equipment_operators_and_related_occupations_2037, 
         x8_natural_resources_agriculture_and_related_production_occupations_2064, 
         x8_natural_resources_agriculture_and_related_production_occupations_2051, 
         x8_natural_resources_agriculture_and_related_production_occupations_2038, 
         x9_occupations_in_manufacturing_and_utilities_2065, 
         x9_occupations_in_manufacturing_and_utilities_2052, 
         x9_occupations_in_manufacturing_and_utilities_2039, 
         female_labour_force_aged_15_years_and_over_by_industry_north_american_industry_classification_system_naics_2007, 
         male_labour_force_aged_15_years_and_over_by_industry_north_american_industry_classification_system_naics_2007, 
         total_labour_force_population_aged_15_years_and_over_by_industry_north_american_industry_classification_system_naics_2007, 
         x11_agriculture_forestry_fishing_and_hunting_2115, 
         x11_agriculture_forestry_fishing_and_hunting_2092, 
         x11_agriculture_forestry_fishing_and_hunting_2069, 
         x21_mining_quarrying_and_oil_and_gas_extraction_2116, 
         x21_mining_quarrying_and_oil_and_gas_extraction_2093, 
         x21_mining_quarrying_and_oil_and_gas_extraction_2070, 
         x22_utilities_2117, x22_utilities_2094, x22_utilities_2071, 
         x23_construction_2118, x23_construction_2095, x23_construction_2072, 
         x31_33_manufacturing_2119, x31_33_manufacturing_2096, 
         x31_33_manufacturing_2073, x41_wholesale_trade_2120, 
         x41_wholesale_trade_2097, x41_wholesale_trade_2074, 
         x44_45_retail_trade_2121, x44_45_retail_trade_2098, 
         x44_45_retail_trade_2075, x48_49_transportation_and_warehousing_2122, 
         x48_49_transportation_and_warehousing_2099, 
         x48_49_transportation_and_warehousing_2076, 
         x51_information_and_cultural_industries_2123, 
         x51_information_and_cultural_industries_2100, 
         x51_information_and_cultural_industries_2077, 
         x52_finance_and_insurance_2124, x52_finance_and_insurance_2101, 
         x52_finance_and_insurance_2078, 
         x53_real_estate_and_rental_and_leasing_2125, 
         x53_real_estate_and_rental_and_leasing_2102, 
         x53_real_estate_and_rental_and_leasing_2079, 
         x54_professional_scientific_and_technical_services_2126, 
         x54_professional_scientific_and_technical_services_2103, 
         x54_professional_scientific_and_technical_services_2080, 
         x55_management_of_companies_and_enterprises_2127, 
         x55_management_of_companies_and_enterprises_2104, 
         x55_management_of_companies_and_enterprises_2081, 
         x56_administrative_and_support_waste_management_and_remediation_services_2128, 
         x56_administrative_and_support_waste_management_and_remediation_services_2105, 
         x56_administrative_and_support_waste_management_and_remediation_services_2082, 
         x61_educational_services_2129, x61_educational_services_2106, 
         x61_educational_services_2083, 
         x62_health_care_and_social_assistance_2130, 
         x62_health_care_and_social_assistance_2107, 
         x62_health_care_and_social_assistance_2084, 
         x71_arts_entertainment_and_recreation_2131, 
         x71_arts_entertainment_and_recreation_2108, 
         x71_arts_entertainment_and_recreation_2085, 
         x72_accommodation_and_food_services_2132, 
         x72_accommodation_and_food_services_2109, 
         x72_accommodation_and_food_services_2086, 
         x81_other_services_except_public_administration_2133, 
         x81_other_services_except_public_administration_2110, 
         x81_other_services_except_public_administration_2087, 
         x91_public_administration_2134, x91_public_administration_2111, 
         x91_public_administration_2088, median_household_total_income_2584, 
         median_after_tax_household_income_2586, 
         average_household_total_income_2585, 
         average_after_tax_household_income_2587, 
         prevalence_of_low_income_in_2010_based_on_after_tax_low_income_measure_percent_2487, 
         prevalence_of_low_income_in_2010_based_on_after_tax_low_income_measure_percent_2472, 
         prevalence_of_low_income_in_2010_based_on_after_tax_low_income_measure_percent_2457) |>

  # Rename variables to be as similar to census profile 2021 as possible 
  rename(p_113_f = median_income_2283, 
         p_113_m = median_income_2265, 
         p_113_t = median_income_2247, 
         p_115_f = median_after_tax_income_2331, 
         p_115_m = median_after_tax_income_2315, 
         p_115_t = median_after_tax_income_2299, 
         p_128_f = average_income_2284, 
         p_128_m = average_income_2266, 
         p_128_t = average_income_2248, 
         p_130_f = average_after_tax_income_2332, 
         p_130_m = average_after_tax_income_2316, 
         p_130_t = average_after_tax_income_2300, 
         p_1402_f = females_in_private_households_by_aboriginal_identity, 
         p_1402_m = males_in_private_households_by_aboriginal_identity, 
         p_1402_t = total_population_in_private_households_by_aboriginal_identity, 
         p_1403_f = aboriginal_identity_1369, 
         p_1403_m = aboriginal_identity_1361, 
         p_1403_t = aboriginal_identity_1353, 
         p_1414_t = total_number_of_private_households_by_tenure, 
         p_1415_t = owner, 
         p_1416_t = renter, 
         p_1417_t = band_housing, 
         p_1437_t = total_number_of_private_households_by_housing_suitability, 
         p_1439_t = not_suitable, 
         p_1449_t = total_number_of_occupied_private_dwellings_by_condition_of_dwelling, 
         p_1451_t = major_repairs_needed, 
         p_1465_t = total_number_of_owner_and_tenant_households_with_household_total_income_greater_than_zero_in_non_farm_non_reserve_private_dwellings_by_shelter_cost_to_income_ratio, 
         p_1467_t = spending_30_percent_or_more_of_household_total_income_on_shelter_costs, 
         p_1484_t = percent_of_owner_households_spending_30_percent_or_more_of_household_total_income_on_shelter_costs, 
         p_1488_t = median_value_of_dwellings, 
         p_1489_t = average_value_of_dwellings, 
         p_1492_t = percent_of_tenant_households_spending_30_percent_or_more_of_household_total_income_on_shelter_costs, 
         p_151_f = government_transfer_payments_percent_2375, 
         p_151_m = government_transfer_payments_percent_2358, 
         p_151_t = government_transfer_payments_percent_2341, 
         p_1527_f = females_in_private_households_by_immigrant_status_and_period_of_immigration, 
         p_1527_m = males_in_private_households_by_immigrant_status_and_period_of_immigration, 
         p_1527_t = total_population_in_private_households_by_immigrant_status_and_period_of_immigration, 
         p_1528_f = non_immigrants_40, 
         p_1528_m = non_immigrants_29, 
         p_1528_t = non_immigrants_18, 
         p_1529_f = immigrants_41, 
         p_1529_m = immigrants_30, 
         p_1529_t = immigrants_19, 
         p_1536_f = x2006_to_2011_48, 
         p_1536_m = x2006_to_2011_37, 
         p_1536_t = x2006_to_2011_26, 
         p_1537_f = non_permanent_residents_49, 
         p_1537_m = non_permanent_residents_38, 
         p_1537_t = non_permanent_residents_27, 
         p_1683_m = males_in_private_households_by_visible_minority, 
         p_1683_f = females_in_private_households_by_visible_minority, 
         p_1683_t = total_population_in_private_households_by_visible_minority, 
         p_1684_m = total_visible_minority_population_474, 
         p_1684_f = total_visible_minority_population_489, 
         p_1684_t = total_visible_minority_population_459, 
         p_1685_m = south_asian_475, 
         p_1685_f = south_asian_490, 
         p_1685_t = south_asian_460, 
         p_1686_m = chinese_476, 
         p_1686_f = chinese_491, 
         p_1686_t = chinese_461, 
         p_1687_m = black_477, 
         p_1687_f = black_492, 
         p_1687_t = black_462, 
         p_1688_m = filipino_478, 
         p_1688_f = filipino_493, 
         p_1688_t = filipino_463, 
         p_1689_m = arab_480, 
         p_1689_f = arab_495, 
         p_1689_t = arab_465, 
         p_1690_m = latin_american_479, 
         p_1690_f = latin_american_494, 
         p_1690_t = latin_american_464, 
         p_1691_m = southeast_asian_481, 
         p_1691_f = southeast_asian_496, 
         p_1691_t = southeast_asian_466, 
         p_1692_m = west_asian_482, 
         p_1692_f = west_asian_497, 
         p_1692_t = west_asian_467, 
         p_1693_m = korean_483, 
         p_1693_f = korean_498, 
         p_1693_t = korean_468, 
         p_1694_m = japanese_484, 
         p_1694_f = japanese_499, 
         p_1694_t = japanese_469, 
         p_1974_f = females_mobility_status_1_year_ago, 
         p_1974_m = males_mobility_status_1_year_ago, 
         p_1974_t = total_mobility_status_1_year_ago, 
         p_1976_f = movers_1738, 
         p_1976_m = movers_1729, 
         p_1976_t = movers_1720, 
         p_1983_f = females_mobility_status_5_years_ago, 
         p_1983_m = males_mobility_status_5_years_ago, 
         p_1983_t = total_mobility_status_5_years_ago, 
         p_1985_f = movers_1765, 
         p_1985_m = movers_1756, 
         p_1985_t = movers_1747, 
         p_1993_f = no_certificate_diploma_or_degree_1793, 
         p_1993_m = no_certificate_diploma_or_degree_1783, 
         p_1993_t = no_certificate_diploma_or_degree_1773, 
         p_1998_f = females_aged_15_years_and_over_by_highest_certificate_diploma_or_degree, 
         p_1998_m = males_aged_15_years_and_over_by_highest_certificate_diploma_or_degree, 
         p_1998_t = total_population_aged_15_years_and_over_by_highest_certificate_diploma_or_degree, 
         p_2008_f = university_certificate_diploma_or_degree_at_bachelor_level_or_above_1799, 
         p_2008_m = university_certificate_diploma_or_degree_at_bachelor_level_or_above_1789, 
         p_2008_t = university_certificate_diploma_or_degree_at_bachelor_level_or_above_1779, 
         p_2030_f = females_aged_15_years_and_over_by_major_field_of_study_classification_of_instructional_programs_cip_2011, 
         p_2030_m = males_aged_15_years_and_over_by_major_field_of_study_classification_of_instructional_programs_cip_2011, 
         p_2030_t = total_population_aged_15_years_and_over_by_major_field_of_study_classification_of_instructional_programs_cip_2011, 
         p_2032_f = education_1862, 
         p_2032_m = education_1848, 
         p_2032_t = education_1834, 
         p_2034_f = visual_and_performing_arts_and_communications_technologies_1863, 
         p_2034_m = visual_and_performing_arts_and_communications_technologies_1849, 
         p_2034_t = visual_and_performing_arts_and_communications_technologies_1835, 
         p_2037_f = humanities_1864, 
         p_2037_m = humanities_1850, 
         p_2037_t = humanities_1836, 
         p_2046_f = social_and_behavioural_sciences_and_law_1865, 
         p_2046_m = social_and_behavioural_sciences_and_law_1851, 
         p_2046_t = social_and_behavioural_sciences_and_law_1837, 
         p_2054_f = business_management_and_public_administration_1866, 
         p_2054_m = business_management_and_public_administration_1852, 
         p_2054_t = business_management_and_public_administration_1838, 
         p_2058_f = physical_and_life_sciences_and_technologies_1867, 
         p_2058_m = physical_and_life_sciences_and_technologies_1853, 
         p_2058_t = physical_and_life_sciences_and_technologies_1839, 
         p_2064_f = mathematics_computer_and_information_sciences_1868, 
         p_2064_m = mathematics_computer_and_information_sciences_1854, 
         p_2064_t = mathematics_computer_and_information_sciences_1840, 
         p_2069_f = architecture_engineering_and_related_technologies_1869, 
         p_2069_m = architecture_engineering_and_related_technologies_1855, 
         p_2069_t = architecture_engineering_and_related_technologies_1841, 
         p_2077_f = agriculture_natural_resources_and_conservation_1870, 
         p_2077_m = agriculture_natural_resources_and_conservation_1856, 
         p_2077_t = agriculture_natural_resources_and_conservation_1842, 
         p_2080_f = health_and_related_fields_1871, 
         p_2080_m = health_and_related_fields_1857, 
         p_2080_t = health_and_related_fields_1843, 
         p_2086_f = personal_protective_and_transportation_services_1872, 
         p_2086_m = personal_protective_and_transportation_services_1858, 
         p_2086_t = personal_protective_and_transportation_services_1844, 
         p_2228_f = participation_rate_2009, 
         p_2228_m = participation_rate_2001, 
         p_2228_t = participation_rate_1993, 
         p_2229_f = employment_rate_2010, 
         p_2229_m = employment_rate_2002, 
         p_2229_t = employment_rate_1994, 
         p_2230_f = unemployment_rate_2011, 
         p_2230_m = unemployment_rate_2003, 
         p_2230_t = unemployment_rate_1995, 
         p_2237_f = female_labour_force_aged_15_years_and_over_by_class_of_worker, 
         p_2237_m = male_labour_force_aged_15_years_and_over_by_class_of_worker, 
         p_2237_t = total_labour_force_aged_15_years_and_over_by_class_of_worker, 
         p_2245_f = self_employed_2026, 
         p_2245_m = self_employed_2021, 
         p_2245_t = self_employed_2016, 
         p_2246_f = female_labour_force_aged_15_years_and_over_by_occupation_national_occupational_classification_noc_2011, 
         p_2246_m = male_labour_force_aged_15_years_and_over_by_occupation_national_occupational_classification_noc_2011, 
         p_2246_t = total_labour_force_population_aged_15_years_and_over_by_occupation_national_occupational_classification_noc_2011, 
         p_2249_f = x0_management_occupations_2056, 
         p_2249_m = x0_management_occupations_2043, 
         p_2249_t = x0_management_occupations_2030, 
         p_2250_f = x1_business_finance_and_administration_occupations_2057, 
         p_2250_m = x1_business_finance_and_administration_occupations_2044, 
         p_2250_t = x1_business_finance_and_administration_occupations_2031, 
         p_2251_f = x2_natural_and_applied_sciences_and_related_occupations_2058, 
         p_2251_m = x2_natural_and_applied_sciences_and_related_occupations_2045, 
         p_2251_t = x2_natural_and_applied_sciences_and_related_occupations_2032, 
         p_2252_f = x3_health_occupations_2059, 
         p_2252_m = x3_health_occupations_2046, 
         p_2252_t = x3_health_occupations_2033, 
         p_2253_f = x4_occupations_in_education_law_and_social_community_and_government_services_2060, 
         p_2253_m = x4_occupations_in_education_law_and_social_community_and_government_services_2047, 
         p_2253_t = x4_occupations_in_education_law_and_social_community_and_government_services_2034, 
         p_2254_f = x5_occupations_in_art_culture_recreation_and_sport_2061, 
         p_2254_m = x5_occupations_in_art_culture_recreation_and_sport_2048, 
         p_2254_t = x5_occupations_in_art_culture_recreation_and_sport_2035, 
         p_2255_f = x6_sales_and_service_occupations_2062, 
         p_2255_m = x6_sales_and_service_occupations_2049, 
         p_2255_t = x6_sales_and_service_occupations_2036, 
         p_2256_f = x7_trades_transport_and_equipment_operators_and_related_occupations_2063, 
         p_2256_m = x7_trades_transport_and_equipment_operators_and_related_occupations_2050, 
         p_2256_t = x7_trades_transport_and_equipment_operators_and_related_occupations_2037, 
         p_2257_f = x8_natural_resources_agriculture_and_related_production_occupations_2064, 
         p_2257_m = x8_natural_resources_agriculture_and_related_production_occupations_2051, 
         p_2257_t = x8_natural_resources_agriculture_and_related_production_occupations_2038, 
         p_2258_f = x9_occupations_in_manufacturing_and_utilities_2065, 
         p_2258_m = x9_occupations_in_manufacturing_and_utilities_2052, 
         p_2258_t = x9_occupations_in_manufacturing_and_utilities_2039, 
         p_2259_f = female_labour_force_aged_15_years_and_over_by_industry_north_american_industry_classification_system_naics_2007, 
         p_2259_m = male_labour_force_aged_15_years_and_over_by_industry_north_american_industry_classification_system_naics_2007, 
         p_2259_t = total_labour_force_population_aged_15_years_and_over_by_industry_north_american_industry_classification_system_naics_2007, 
         p_2262_f = x11_agriculture_forestry_fishing_and_hunting_2115, 
         p_2262_m = x11_agriculture_forestry_fishing_and_hunting_2092, 
         p_2262_t = x11_agriculture_forestry_fishing_and_hunting_2069, 
         p_2263_f = x21_mining_quarrying_and_oil_and_gas_extraction_2116, 
         p_2263_m = x21_mining_quarrying_and_oil_and_gas_extraction_2093, 
         p_2263_t = x21_mining_quarrying_and_oil_and_gas_extraction_2070, 
         p_2264_f = x22_utilities_2117, 
         p_2264_m = x22_utilities_2094, 
         p_2264_t = x22_utilities_2071, 
         p_2265_f = x23_construction_2118, 
         p_2265_m = x23_construction_2095, 
         p_2265_t = x23_construction_2072, 
         p_2266_f = x31_33_manufacturing_2119, 
         p_2266_m = x31_33_manufacturing_2096, 
         p_2266_t = x31_33_manufacturing_2073, 
         p_2267_f = x41_wholesale_trade_2120, 
         p_2267_m = x41_wholesale_trade_2097, 
         p_2267_t = x41_wholesale_trade_2074, 
         p_2268_f = x44_45_retail_trade_2121, 
         p_2268_m = x44_45_retail_trade_2098, 
         p_2268_t = x44_45_retail_trade_2075, 
         p_2269_f = x48_49_transportation_and_warehousing_2122, 
         p_2269_m = x48_49_transportation_and_warehousing_2099, 
         p_2269_t = x48_49_transportation_and_warehousing_2076, 
         p_2270_f = x51_information_and_cultural_industries_2123, 
         p_2270_m = x51_information_and_cultural_industries_2100, 
         p_2270_t = x51_information_and_cultural_industries_2077, 
         p_2271_f = x52_finance_and_insurance_2124, 
         p_2271_m = x52_finance_and_insurance_2101, 
         p_2271_t = x52_finance_and_insurance_2078, 
         p_2272_f = x53_real_estate_and_rental_and_leasing_2125, 
         p_2272_m = x53_real_estate_and_rental_and_leasing_2102, 
         p_2272_t = x53_real_estate_and_rental_and_leasing_2079, 
         p_2273_f = x54_professional_scientific_and_technical_services_2126, 
         p_2273_m = x54_professional_scientific_and_technical_services_2103, 
         p_2273_t = x54_professional_scientific_and_technical_services_2080, 
         p_2274_f = x55_management_of_companies_and_enterprises_2127, 
         p_2274_m = x55_management_of_companies_and_enterprises_2104, 
         p_2274_t = x55_management_of_companies_and_enterprises_2081, 
         p_2275_f = x56_administrative_and_support_waste_management_and_remediation_services_2128, 
         p_2275_m = x56_administrative_and_support_waste_management_and_remediation_services_2105, 
         p_2275_t = x56_administrative_and_support_waste_management_and_remediation_services_2082, 
         p_2276_f = x61_educational_services_2129, 
         p_2276_m = x61_educational_services_2106, 
         p_2276_t = x61_educational_services_2083, 
         p_2277_f = x62_health_care_and_social_assistance_2130, 
         p_2277_m = x62_health_care_and_social_assistance_2107, 
         p_2277_t = x62_health_care_and_social_assistance_2084, 
         p_2278_f = x71_arts_entertainment_and_recreation_2131, 
         p_2278_m = x71_arts_entertainment_and_recreation_2108, 
         p_2278_t = x71_arts_entertainment_and_recreation_2085, 
         p_2279_f = x72_accommodation_and_food_services_2132, 
         p_2279_m = x72_accommodation_and_food_services_2109, 
         p_2279_t = x72_accommodation_and_food_services_2086, 
         p_2280_f = x81_other_services_except_public_administration_2133, 
         p_2280_m = x81_other_services_except_public_administration_2110, 
         p_2280_t = x81_other_services_except_public_administration_2087, 
         p_2281_f = x91_public_administration_2134, 
         p_2281_m = x91_public_administration_2111, 
         p_2281_t = x91_public_administration_2088, 
         p_243_t = median_household_total_income_2584, 
         p_244_t = median_after_tax_household_income_2586, 
         p_252_t = average_household_total_income_2585, 
         p_253_t = average_after_tax_household_income_2587, 
         p_345_f = prevalence_of_low_income_in_2010_based_on_after_tax_low_income_measure_percent_2487, 
         p_345_m = prevalence_of_low_income_in_2010_based_on_after_tax_low_income_measure_percent_2472, 
         p_345_t = prevalence_of_low_income_in_2010_based_on_after_tax_low_income_measure_percent_2457)

# Save 2011 NHS Profiles we need (that we assigned) by their profile id
prof_inc_nhs_11 <- c(113, 115, 128, 130, 151, 243, 244, 252, 253, 345, 1402, 
                     1403, 1414, 1415, 1416, 1417, 1437, 1439, 1449, 1451, 1465,
                     1467, 1484, 1488, 1489, 1492, 1527, 1528, 1529, 1536, 1537,
                     1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 1692,
                     1693, 1694, 1974, 1976, 1983, 1985, 1993, 1998, 2008, 2030,
                     2032, 2034, 2037, 2046, 2054, 2058, 2064, 2069, 2077, 2080, 
                     2086, 2228, 2229, 2230, 2237, 2245, 2246, 2249, 2250, 2251, 
                     2252, 2253, 2254, 2255, 2256, 2257, 2258, 2259, 2262, 2263, 
                     2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 
                     2274, 2275, 2276, 2277, 2278, 2279, 2280, 2281) 

# Save sex in a vector
sex <- c("t", "f", "m")

# Save values of "x" and "r" as missing to be able to save all variables in 
# numeric format
for (id in prof_inc_nhs_11) {
  for (s in sex){
    
    # Construct the dynamic variable name
    var_name <- paste0("p_", id, "_" , s)
    
    # Check if the variable exists in the dataset
    if (var_name %in% colnames(nhs_profile_da11_can_2011_HARM)){
    
    # Harmonize indicator variables
    nhs_profile_da11_can_2011_HARM <- nhs_profile_da11_can_2011_HARM |>
      mutate(!!var_name := case_when(
        !!sym(var_name) == "x" ~ NA,
        !!sym(var_name) == "F" ~ NA,
        !!sym(var_name) == ".." ~ NA,
        !!sym(var_name) == "..." ~ NA,
        TRUE ~ as.numeric(!!sym(var_name))
      ) )
    
  }
  }
}

# Count the number of DAs in NHS Profile
n_distinct(nhs_profile_da11_can_2011_HARM$da_id_11)  # 54,534

# Save file
write_csv(nhs_profile_da11_can_2011_HARM, 
          "Data/nhs_profile_da11_can_2011_HARM.csv")

# 2. HARMONIZE DA-LEVEL CENSUS PROFILE (SHORT FORM), 2011                   ####
# ---------------------------------------------------------------------------- #

# Define different chunks of data by geography (Census Profile were downloaded 
# in chunks because of their huge size)
geo <- c("da11_alta", "da11_bc", "da11_man", "da11_nb", "da11_nl", "da11_ns",
         "da11_nvt", "da11_nwt", "da11_ont", "da11_pei", "da11_que", 
         "da11_sask", "da11_yt")

# Open and harmonize data for each geographic area
for (g in geo){
  
  # Open raw data
  data_da_temp_2011 <- 
    read_csv(paste0("Data/census_profile_short_", g, "_2011_RAW.csv"))
  
  # Create a reduced version of data
  data_da_temp_2011_reduced <- data_da_temp_2011 |>
    
    # Keep variables we need
    select(da_id_11 = "Geo_Code", 
           prof_name = "Characteristic",  
           t = "Total",
           f = "Female", 
           m = "Male") |>
  
    # Create a temporary variable to work with profile characteristics easily
    group_by(da_id_11) |>
      mutate(prof_id_temp = row_number()) |>
    
    ungroup() |>
    
    # Create a prof_id variable to later use in creating CASDOHI
    mutate(prof_id = case_when(
      prof_id_temp == 1 ~ 1,
      prof_id_temp == 6 ~ 6,
      prof_id_temp == 8 ~ 8,
      prof_id_temp == 9 ~ 10,
      prof_id_temp == 10 ~ 11,
      prof_id_temp == 11 ~ 12,
      prof_id_temp == 27 ~ 25,
      prof_id_temp == 28 ~ 26,
      prof_id_temp == 29 ~ 27,
      prof_id_temp == 30 ~ 28,
      prof_id_temp == 31 ~ 29,
      prof_id_temp == 32 ~ 40,
      prof_id_temp == 108 ~ 41,
      prof_id_temp == 110 ~ 47,
      prof_id_temp == 119 ~ 51,
      prof_id_temp == 126 ~ 57,
      prof_id_temp == 34 ~ 58,
      prof_id_temp == 35 ~ 59,
      prof_id_temp == 39 ~ 67,
      prof_id_temp == 40 ~ 68,
      prof_id_temp == 41 ~ 69,
      prof_id_temp == 42 ~ 70,
      prof_id_temp == 48 ~ 78,
      prof_id_temp == 62 ~ 86,
      prof_id_temp == 63 ~ 87,
      prof_id_temp == 67 ~ 88,
      prof_id_temp == 125 ~ 89,
      prof_id_temp == 18 ~ 90,
      prof_id_temp == 19 ~ 91,
      prof_id_temp == 20 ~ 92,
      prof_id_temp == 21 ~ 93,
      prof_id_temp == 22 ~ 94,
      prof_id_temp == 23 ~ 95,
      prof_id_temp == 24 ~ 96,
      prof_id_temp == 25 ~ 97,
      prof_id_temp == 26 ~ 98,
      prof_id_temp == 238 ~ 383,
      prof_id_temp == 242 ~ 387,
      TRUE ~ NA_real_ )) |>

    # Keep only profile characteristics we need in CASDOHI
    filter(!is.na(prof_id)) |>
    
    # Drop variables we don't need    
    select(-prof_id_temp, -prof_name)
    
  # Rename values
  data_da_temp_2011_reduced$prof_id <- paste0("p_", 
                                              data_da_temp_2011_reduced$prof_id) 
  
  # Reshape dataset to a long version
  data_da_temp_long <- gather(data_da_temp_2011_reduced, 
                              key = "n_type", 
                              value = "all", "t", "f", "m")
  
  # Create a new variable by concatenating prof_id and n_type variables
  data_da_temp_long$indicator <- paste(data_da_temp_long$prof_id, 
                                       data_da_temp_long$n_type, sep = "_")
  
  # Drop variables we don't need
  data_da_temp_long <- select(data_da_temp_long, -prof_id, -n_type)
  
  # Reshape long data to a wide version
  data_da_temp_wide <- spread(data_da_temp_long, 
                              key = "indicator", 
                              value = all)
  
  # There are no duplicates in terms of DA at this point -> Each observations
  # represents information of one DA.
  
  # Save 2011 Census Profiles we need (that we assigned) by their profile id
  prof_inc_census_short_11 <- c(1, 6, 8, 10, 11, 12, 25, 26, 27, 28, 29, 40, 41, 
                                47, 51, 57, 58, 59, 67, 68, 69, 70, 78, 86, 87, 
                                88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 383,
                                387) 
  
  # Save reshaped data in a vector
  output <- paste0("census_profile_short_", g, "_2011_HARM")
  
  # Save reshaped data in R environment
  assign(output, data_da_temp_wide)
  
  # Save reshaped data as CSV
  output <- data_da_temp_wide |>
    write_csv(paste0("Data/census_profile_short_", g, "_2011_HARM.csv"))
}  

# 3. APPEND HARMONIZED DA-LEVEL CENSUS PROFILES (SHORT FORM), 2011          ####
# ---------------------------------------------------------------------------- #

# Create a list of files to append
files_to_append_11 <- c("census_profile_short_da11_alta_2011_HARM",
                        "census_profile_short_da11_bc_2011_HARM",
                        "census_profile_short_da11_man_2011_HARM",
                        "census_profile_short_da11_nb_2011_HARM",
                        "census_profile_short_da11_nl_2011_HARM",
                        "census_profile_short_da11_ns_2011_HARM",
                        "census_profile_short_da11_nvt_2011_HARM",
                        "census_profile_short_da11_nwt_2011_HARM",
                        "census_profile_short_da11_ont_2011_HARM",
                        "census_profile_short_da11_pei_2011_HARM",
                        "census_profile_short_da11_que_2011_HARM",
                        "census_profile_short_da11_sask_2011_HARM",
                        "census_profile_short_da11_yt_2011_HARM")

# Append datasets and save in R environment
census_profile_short_da11_can_2011_HARM <- files_to_append_11 |> 
  map_dfr(~ get(.x))

# Write the appended dataset as CSV
write_csv(census_profile_short_da11_can_2011_HARM, 
          "Data/census_profile_short_da11_can_2011_HARM.csv")

# Count the number of DAs in 2011 Census Profile
n_distinct(census_profile_short_da11_can_2011_HARM$da_id_11)  # 56,204

# Clear R environment from data files
rm(list = ls()[sapply(ls(), 
                      function(x) inherits(get(x), 
                                           c("data.frame", 
                                             "tibble", 
                                             "matrix")))])

# 4. MERGE HARMONIZED 2011 CENSUS (SHORT) AND NHS PROFILES                  ####
# ---------------------------------------------------------------------------- #

# Import harmonized 2011 Census Profile (short form) 
census_profile_short_da11_can_2011_HARM <- 
  read.csv("Data/census_profile_short_da11_can_2011_HARM.csv")

# Import harmonized 2011 NHS Profile
nhs_profile_da11_can_2011_HARM <- 
  read.csv("Data/nhs_profile_da11_can_2011_HARM.csv")

# Note that the number of DAs covered in 2011 Census Profile (=56,204) is more 
# than the number of DAs covered in NHS (=54,534). We consider those DAs missing
# for NHS Profile.

# Join 2011 Census and NHS Profiles
census_profile_da11_can_2011_HARM <- 
  left_join(census_profile_short_da11_can_2011_HARM, 
            nhs_profile_da11_can_2011_HARM,
            by = "da_id_11")

# Count the number of DAs in 2011 Census Profile
n_distinct(census_profile_da11_can_2011_HARM$da_id_11)  # 56,204

# Save 2011 Census Profile, consisting short form and NHS
write_csv(census_profile_da11_can_2011_HARM, 
          "Data/census_profile_da11_can_2011_HARM.csv")

# 5. HARMONIZE DA-LEVEL CENSUS PROFILES, 2016                               ####
# ---------------------------------------------------------------------------- #

# Define different chunks of data by geography (Census Profile were downloaded 
# in chunks to reduce the size)
geo <- c("da16_atl", "da16_bc", "da16_on", "da16_pra", "da16_que", "da16_ter")

# Save Census variables we need in a vector by their profile id
prof_inc_16 <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 35, 37, 39, 40, 41, 43, 52, 
                 57, 58, 59, 60, 64, 65, 66, 67, 74, 78, 79, 80, 100, 104, 
                 661, 663, 665, 668, 674, 676, 690, 742, 743, 751, 752, 857, 
                 867, 1140, 1141, 1142, 1149, 1150, 1289, 1290, 1323, 1324, 
                 1325, 1326, 1327, 1328, 1329, 1330, 1331, 1332, 1333, 1334, 
                 1617, 1618, 1619, 1620, 1640, 1642, 1651, 1653, 1667, 1669, 
                 1673, 1676, 1677, 1680, 1683, 1684, 1692, 1713, 1715, 1717, 
                 1720, 1729, 1737, 1741, 1747, 1752, 1760, 1763, 1767, 1870, 
                 1871, 1872, 1879, 1883, 1884, 1887, 1888, 1889, 1890, 1891, 
                 1892, 1893, 1894, 1895, 1896, 1897, 1900, 1901, 1902, 1903, 
                 1904, 1905, 1906, 1907, 1908, 1909, 1910, 1911, 1912, 1913, 
                 1914, 1915, 1916, 1917, 1918, 1919, 2230, 2232, 2239, 2241) 

# Save sex in a vector
sex <- c("t", "f", "m")

# Open and harmonize data for each geographic area
for (g in geo){

  # Open raw data
  data_da_temp_2016 <- 
    read_csv(paste0("Data/census_profile_", g, "_2016_RAW.csv"))
  
  # Keep variables we need
  data_da_temp_2016_reduced <- data_da_temp_2016 |>
    select(geo_code = "GEO_CODE (POR)", 
           geo_level = "GEO_LEVEL", 
           prof_name = "DIM: Profile of Dissemination Areas (2247)",  
           prof_id = "Member ID: Profile of Dissemination Areas (2247)", 
           t = "Dim: Sex (3): Member ID: [1]: Total - Sex",
           f = "Dim: Sex (3): Member ID: [3]: Female", 
           m = "Dim: Sex (3): Member ID: [2]: Male")
  
  # Keep Dissemination Area level data and Profile IDs that we need
  data_da_temp_2016_reduced <- data_da_temp_2016_reduced |>
    filter(geo_level == 4 & (prof_id %in% prof_inc_16) ) |>
    
    # Drop variables we don't need    
    select(-geo_level, -prof_name) |>
    
    # Rename variables
    rename(da_id_16 = geo_code)
  
  # Rename values
  data_da_temp_2016_reduced$prof_id <- paste0("p_", 
                                              data_da_temp_2016_reduced$prof_id) 
  
  # Reshape dataset to a long version
  data_da_temp_long <- gather(data_da_temp_2016_reduced, 
                              key = "n_type", 
                              value = "all", "t", "f", "m")
  
  # Create a new variable by concatenating prof_id and n_type variables
  data_da_temp_long$indicator <- paste(data_da_temp_long$prof_id, 
                                       data_da_temp_long$n_type, sep = "_")
  
  # Drop variables we don't need
  data_da_temp_long <- select(data_da_temp_long, -prof_id, -n_type)
  
  # Reshape long data to a wide version
  data_da_temp_wide <- spread(data_da_temp_long, 
                              key = "indicator", 
                              value = all)
  
  # There are no duplicates in terms of DA at this point -> Each observations
  # represents information of one DA.
  
  # Save values of "x" and "r" as missing to be able to save all variables in 
  # numeric format
  for (id in prof_inc_16) {
    for (s in sex){
      
      # Construct the dynamic variable name
      var_name <- paste0("p_", id, "_" , s)

      # Harmonize indicator variables
      data_da_temp_wide <- data_da_temp_wide |>
        mutate(!!var_name := case_when(
          !!sym(var_name) == "x" ~ NA,
          !!sym(var_name) == "F" ~ NA,
          !!sym(var_name) == ".." ~ NA,
          !!sym(var_name) == "..." ~ NA,
          TRUE ~ as.numeric(!!sym(var_name))
        ) )
      
    }
  }
  
  # Save reshaped data in a vector
  output <- paste0("census_profile_", g, "_2016_HARM")
  
  # Save reshaped data in R environment
  assign(output, data_da_temp_wide)
  
  # Save reshaped data as CSV
  output <- data_da_temp_wide |>
    write_csv(paste0("Data/census_profile_", g, "_2016_HARM.csv"))
}  

# 6. APPEND HARMONIZED DA-LEVEL CENSUS PROFILES, 2016                       ####
# ---------------------------------------------------------------------------- #

# Create a list of files to append
files_to_append_16 <- c("census_profile_da16_atl_2016_HARM",
                        "census_profile_da16_bc_2016_HARM",
                        "census_profile_da16_on_2016_HARM",
                        "census_profile_da16_pra_2016_HARM",
                        "census_profile_da16_que_2016_HARM",
                        "census_profile_da16_ter_2016_HARM")

# Append datasets and save in R environment
census_profile_da16_can_2016_HARM <- files_to_append_16 |> 
  map_dfr(~ get(.x))

# Count the number of DAs in 2016 Census Profile
n_distinct(census_profile_da16_can_2016_HARM$da_id_16)  # 56,590

# Write the appended dataset as CSV
write_csv(census_profile_da16_can_2016_HARM, 
          "Data/census_profile_da16_can_2016_HARM.csv")

# 7. HARMONIZE DA-LEVEL CENSUS PROFILES, 2021                               ####
# ---------------------------------------------------------------------------- #
  
# Clear R environment from data files
rm(list = ls()[sapply(ls(), 
                      function(x) inherits(get(x), 
                                           c("data.frame", 
                                             "tibble", 
                                             "matrix")))])

# Save 2021 Census variables we need in a vector by their profile id
prof_inc_21 <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 35, 37, 39, 40, 41, 47, 51, 57, 
                 58, 59, 67, 68, 69, 70, 78, 86, 87, 88, 89, 111, 113, 115, 120,
                 128, 130, 151, 243, 244, 252, 253, 345, 360, 381, 383, 387, 
                 1402, 1403, 1414, 1415, 1416, 1417, 1437, 1439, 1449, 1451, 
                 1465, 1467, 1484, 1488, 1489, 1492, 1527, 1528, 1529, 1536, 
                 1537, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 1690, 1691, 
                 1692, 1693, 1694, 1974, 1976, 1983, 1985, 1993, 1998, 2008, 
                 2030, 2032, 2034, 2037, 2046, 2054, 2058, 2064, 2069, 2077, 
                 2080, 2086, 2228, 2229, 2230, 2237, 2245, 2246, 2249, 2250, 
                 2251, 2252, 2253, 2254, 2255, 2256, 2257, 2258, 2259, 2262, 
                 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 
                 2273, 2274, 2275, 2276, 2277, 2278, 2279, 2280, 2281) 

# Define different chunks of data by geography (Census Profile were downloaded 
# in chunks to reduce the size)
geo <- c("da21_atl", "da21_bc", "da21_on", "da21_pra", "da21_que", "da21_ter")

# Open and harmonize data for each geographic area 
for (g in geo){
  
  # Clear R environment from data files
  rm(list = ls()[sapply(ls(), 
                        function(x) inherits(get(x), 
                                             c("data.frame", 
                                               "tibble", 
                                               "matrix")))])
  
  # Open raw data
  data_da_temp_2021 <- 
    read_csv(paste0("Data/census_profile_", g, "_2021_RAW.csv"))
  
  # Keep variables we need
  data_da_temp_2021_reduced <- data_da_temp_2021 |>
    select(geo_code = "ALT_GEO_CODE", 
           geo_level = "GEO_LEVEL", 
           prof_name = "CHARACTERISTIC_NAME",  
           prof_id = "CHARACTERISTIC_ID", 
           t = "C1_COUNT_TOTAL",
           f = "C3_COUNT_WOMEN+", 
           m = "C2_COUNT_MEN+")
  
  # Keep Dissemination Area level data and Profile IDs that we need
  data_da_temp_2021_reduced <- data_da_temp_2021_reduced |>
    filter(geo_level == "Dissemination area" & (prof_id %in% prof_inc_21) ) |>
    
    # Drop variables we don't need    
    select(-geo_level, -prof_name) |>
    
    # Rename variables
    rename(da_id_21 = geo_code)
  
  # Rename values
  data_da_temp_2021_reduced$prof_id <- 
    paste0("p_", data_da_temp_2021_reduced$prof_id) 
  
  # Reshape dataset to a long version
  data_da_temp_long <- gather(data_da_temp_2021_reduced, 
                              key = "n_type", 
                              value = "all", "t", "f", "m")
  
  # Create a new variable by concatenating prof_id and n_type variables
  data_da_temp_long$indicator <- paste(data_da_temp_long$prof_id, 
                                       data_da_temp_long$n_type, sep = "_")
  
  # Drop variables we don't need
  data_da_temp_long <- select(data_da_temp_long, -prof_id, -n_type)
  
  # Reshape long data to a wide version
  data_da_temp_wide <- spread(data_da_temp_long, 
                              key = "indicator", 
                              value = all)
  
  # There are no duplicates in terms of DA at this point -> Each observations
  # represents information of one DA.
  
  # Save reshaped data as CSV
  output <- data_da_temp_wide |>
    write_csv(paste0("Data/census_profile_", g, "_2021_HARM.csv"))
}  
  
# 8. APPEND HARMONIZED DA-LEVEL CENSUS PROFILES, 2021                       ####
# ---------------------------------------------------------------------------- #
# Since the size of the files are large, we append the 6 files in 3 steps.

# Clear R environment from data files
rm(list = ls()[sapply(ls(), 
                      function(x) inherits(get(x), 
                                           c("data.frame", 
                                             "tibble", 
                                             "matrix")))])

  # 8.1. APPEND HARMONIZED PROFILES FOR ATL, BC, AND ON, 2021               ####
  # -------------------------------------------------------------------------- #
    
  # Create a list of files to append
  files_to_append_21_1 <- c("census_profile_da21_atl_2021_HARM",
                            "census_profile_da21_bc_2021_HARM",
                            "census_profile_da21_on_2021_HARM")

  # Import data in R
  for (file in files_to_append_21_1) {
    assign(file, read_csv(paste0("Data/", file, ".csv")))
  }
  
  # Append datasets and save in R environment
  census_profile_da21_atl_bc_on_2021_HARM <- files_to_append_21_1 |> 
    map_dfr(~ get(.x))
  
  # Clear R environment from the files we don't need
  rm(list=files_to_append_21_1)
  
  # 8.2. APPEND HARMONIZED PROFILES FOR PRA, QUE, AND TER, 2021             ####
  # -------------------------------------------------------------------------- #
  
  # Create a list of files to append
  files_to_append_21_2 <- c("census_profile_da21_pra_2021_HARM",
                            "census_profile_da21_que_2021_HARM",
                            "census_profile_da21_ter_2021_HARM")
  
  # Import data in R
  for (file in files_to_append_21_2) {
    assign(file, read_csv(paste0("Data/", file, ".csv")))
  }
  
  # Append datasets and save in R environment
  census_profile_da21_pra_que_ter_2021_HARM <- files_to_append_21_2 |> 
    map_dfr(~ get(.x))
  
  # Clear R environment from the files we don't need
  rm(list=files_to_append_21_2)
  
  # 8.3. APPEND THE TWO APPENDED FILES AND EXPORT                           ####
  # -------------------------------------------------------------------------- #
  
  # Create a list of dataset names
  datasets <- c("census_profile_da21_atl_bc_on_2021_HARM", 
                "census_profile_da21_pra_que_ter_2021_HARM")
  
  # Append datasets and save in R environment
  census_profile_da21_can_2021_HARM <- datasets |> 
    map_dfr(~ get(.x))
  
  # Count the number of DAs in 2021 Census Profile
  n_distinct(census_profile_da21_can_2021_HARM$da_id_21)  # 57,936
  
  # Write the appended dataset as CSV
  write_csv(census_profile_da21_can_2021_HARM, 
            "Data/census_profile_da21_can_2021_HARM.csv")
  
# 9. CONSTRUCT CASDOHI 2011                                                 ####
# ---------------------------------------------------------------------------- #
# This step constructs CASDOHI 2011 based on Appendix C of the paper.
  
# Import the harmonized 2011 census profile (NHS + Short form) 
casdohi_da11_can_2011_MASTER <- 
    read_csv("Data/census_profile_da11_can_2011_HARM.csv") |>
    
  # 9.1. POPULATION AND AGE GROUPS                                          ####
  # -------------------------------------------------------------------------- #
  
  # Rename population counts
  rename(pop_t = p_1_t, 
         pop_f = p_8_f, 
         pop_m = p_8_m) |>
    
    # Calculate percentage of population who are female
    mutate(pct_pop_f = pop_f / pop_t * 100) |>
    
    # Rename population density
    rename(pop_density = p_6_t) |>
    
    # Rename population median age ** Census 2011 doesn't provide average age **
    rename(med_age_t = p_40_t,
           med_age_f = p_40_f,
           med_age_m = p_40_m) |>
    
    # Create age groups
    mutate(pct_age_under5_t = p_10_t / pop_t * 100,
           pct_age_under5_f = p_10_f / pop_f * 100,
           pct_age_under5_m = p_10_m / pop_m * 100) |>
    
    mutate(pct_age_under15_t = (p_10_t + p_11_t + p_12_t) / pop_t * 100,
           pct_age_under15_f = (p_10_f + p_11_f + p_12_f) / pop_f * 100,
           pct_age_under15_m = (p_10_m + p_11_m + p_12_m) / pop_m * 100,
           pct_age_5to14_t = (p_11_t + p_12_t) / pop_t * 100,
           pct_age_5to14_f = (p_11_f + p_12_f) / pop_f * 100,
           pct_age_5to14_m = (p_11_m + p_12_m) / pop_m * 100,
           pct_age_65plus_t = p_25_t + p_26_t + p_27_t + p_28_t + p_29_t 
             / pop_t *100,
           pct_age_65plus_f = p_25_f + p_26_f + p_27_f + p_28_f + p_29_f 
             / pop_f *100,
           pct_age_65plus_m = p_25_m + p_26_m + p_27_m + p_28_m + p_29_m 
             / pop_m *100) |>
    
    # Calculate dependency ratio
    mutate(ratio_dep_t = p_10_t + p_11_t + p_12_t + p_25_t + p_26_t + p_27_t + 
             p_28_t + p_29_t / p_90_t + p_91_t + p_92_t + p_93_t + p_94_t + 
             p_95_t + p_96_t + p_97_t + p_98_t,
           ratio_dep_f = p_10_f + p_11_f + p_12_f + p_25_f + p_26_f + p_27_f + 
             p_28_f + p_29_f / p_90_f + p_91_f + p_92_f + p_93_f + p_94_f + 
             p_95_f + p_96_f + p_97_f + p_98_f,
           ratio_dep_m = p_10_m + p_11_m + p_12_m + p_25_m + p_26_m + p_27_m + 
             p_28_m + p_29_m / p_90_m + p_91_m + p_92_m + p_93_m + p_94_m + 
             p_95_m + p_96_m + p_97_m + p_98_m) |>
    
  # 9.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT                              ####
  # -------------------------------------------------------------------------- #
  
  # Rename average household size
  rename(mean_hh_size = p_57_t) |>
    
  # Calculate the percentage of pop 15+ by marriage status
  mutate(pct_mcl_t = p_59_t / p_58_t * 100,
         pct_mcl_f = p_59_f / p_58_f * 100,
         pct_mcl_m = p_59_m / p_58_m * 100,
         pct_nm_t = p_67_t / p_58_t * 100,
         pct_nm_f = p_67_f / p_58_f * 100,
         pct_nm_m = p_67_m / p_58_m * 100,
         pct_sdw_t = (p_68_t + p_69_t + p_70_t) / p_58_t * 100,
         pct_sdw_f = (p_68_f + p_69_f + p_70_f) / p_58_f * 100,
         pct_sdw_m = (p_68_m + p_69_m + p_70_m) / p_58_m * 100) |>
  
  # Calculate the percentage of single-parent families
  mutate(pct_single_parent_t = p_86_t / p_78_t * 100,
         pct_single_parent_f = p_87_f / p_78_f * 100,
         pct_single_parent_m = p_88_m / p_78_m * 100) |>
  
  # Calculate percentage of population who are living alone
  mutate(pct_alone_t = p_51_t / p_89_t * 100,
         pct_alone_f = p_51_f / p_89_f * 100,
         pct_alone_m = p_51_m / p_89_m * 100) |>
  
  # 9.3. EHNOCULTURAL INDICATORS                                            ####
  # -------------------------------------------------------------------------- #
  
  # Calculate the percentage of pop with no knowledge of official languages 
  # (English and French)
  mutate(pct_no_eng_fr_t = p_387_t / p_383_t * 100,
         pct_no_eng_fr_f = p_387_f / p_383_f * 100,
         pct_no_eng_fr_m = p_387_m / p_383_m * 100) |>
    
  # Calculate percentages for immigration status
  mutate(pct_non_immig_t = p_1528_t / p_1527_t * 100,
         pct_non_immig_f = p_1528_f / p_1527_f * 100,
         pct_non_immig_m = p_1528_m / p_1527_m * 100,
         pct_immig_t = p_1529_t / p_1527_t * 100,
         pct_immig_f = p_1529_f / p_1527_f * 100,
         pct_immig_m = p_1529_m / p_1527_m * 100,
         pct_non_pr_t = p_1537_t / p_1527_t * 100,
         pct_non_pr_f = p_1537_f / p_1527_f * 100,
         pct_non_pr_m = p_1537_m / p_1527_m * 100) |>
  
  # Calculate percentage of recent immigrants
  mutate(pct_recent_immig_t = p_1536_t / p_1527_t * 100,
         pct_recent_immig_f = p_1536_f / p_1527_f * 100,
         pct_recent_immig_m = p_1536_m / p_1527_m * 100) |>
  
  # Calculate percentage of Indigenous pop
  mutate(pct_indigenous_t = p_1403_t / p_1402_t * 100,
         pct_indigenous_f = p_1403_f / p_1402_f * 100,
         pct_indigenous_m = p_1403_m / p_1402_m * 100) |>
  
  # Calculate percentage of pop who self-identify as visible minority
  mutate(pct_vm_t = p_1684_t / p_1683_t * 100,
         pct_vm_f = p_1684_f / p_1683_f * 100,
         pct_vm_m = p_1684_m / p_1683_m * 100) |>
  
  # Calculate percentage of ethnicity categories pop
  mutate(pct_south_asian_t = p_1685_t / p_1683_t * 100,
         pct_south_asian_f = p_1685_f / p_1683_f * 100,
         pct_south_asian_m = p_1685_m / p_1683_m * 100,
         pct_east_asian_t = (p_1686_t + p_1693_t + p_1694_t) / p_1683_t * 100,
         pct_east_asian_f = (p_1686_f + p_1693_f + p_1694_f) / p_1683_f * 100,
         pct_east_asian_m = (p_1686_m + p_1693_m + p_1694_m) / p_1683_m * 100,
         pct_black_t = p_1687_t / p_1683_t * 100,
         pct_black_f = p_1687_f / p_1683_f * 100,
         pct_black_m = p_1687_m / p_1683_m * 100,
         pct_southeast_asian_t = (p_1688_t + p_1691_t) / p_1683_t * 100,
         pct_southeast_asian_f = (p_1688_f + p_1691_f) / p_1683_f * 100,
         pct_southeast_asian_m = (p_1688_m + p_1691_m) / p_1683_m * 100,
         pct_latin_american_t = p_1690_t / p_1683_t * 100,
         pct_latin_american_f = p_1690_f / p_1683_f * 100,
         pct_latin_american_m = p_1690_m / p_1683_m * 100,
         pct_middle_eastern_t = (p_1689_t + p_1692_t) / p_1683_t * 100,
         pct_middle_eastern_f = (p_1689_f + p_1692_f) / p_1683_f * 100,
         pct_middle_eastern_m = (p_1689_m + p_1692_m) / p_1683_m * 100) |>
    
  # 9.4. INCOME                                                             ####
  # -------------------------------------------------------------------------- #
  
  # Rename median/average individual/household total/after-tax income
  rename(med_ttinc_hh = p_243_t,
         med_atinc_hh = p_244_t,
         mean_ttinc_hh = p_252_t,
         mean_atinc_hh = p_253_t,
         med_ttinc_ind_t = p_113_t,
         med_ttinc_ind_f = p_113_f,
         med_ttinc_ind_m = p_113_m,
         mean_ttinc_ind_t = p_128_t,
         mean_ttinc_ind_f = p_128_f,
         mean_ttinc_ind_m = p_128_m,
         med_atinc_ind_t = p_115_t,
         med_atinc_ind_f = p_115_f,
         med_atinc_ind_m = p_115_m,
         mean_atinc_ind_t = p_130_t,
         mean_atinc_ind_f = p_130_f,
         mean_atinc_ind_m = p_130_m) |>
    
  # Calculate median after-tax household income adjusted for household siz
  mutate(med_atinc_hh_adj = med_atinc_hh / sqrt(mean_hh_size)) |>
  
  # Rename the percentage of total income from gov. transfer
  rename(pct_inc_gtransfer_t = p_151_t,
         pct_inc_gtransfer_f = p_151_f,
         pct_inc_gtransfer_m = p_151_m,) |>
  
  # Rename percentage of low-income pop based on LIM 
  # ** NHS doesn't provide LICO and Gini **
  rename(pct_lim_at_t = p_345_t,
         pct_lim_at_f = p_345_f,
         pct_lim_at_m = p_345_m) |>
  
  # 9.5. EDUCATION                                                          ####
  # -------------------------------------------------------------------------- #
  
  # Calculate percentage of the pop 15+ by education
  mutate(pct_no_diploma_t = p_1993_t / p_1998_t * 100,
         pct_no_diploma_f = p_1993_f / p_1998_f * 100,
         pct_no_diploma_m = p_1993_m / p_1998_m * 100,
         pct_uni_diploma_t = p_2008_t / p_1998_t * 100,
         pct_uni_diploma_f = p_2008_f / p_1998_f * 100,
         pct_uni_diploma_m = p_2008_m / p_1998_m * 100) |>
    
  # Calculate percentage of pop 15+ by thir field of the study - CIP
  mutate(pct_cip_education_t = p_2032_t / p_2030_t * 100,
         pct_cip_education_f = p_2032_f / p_2030_f * 100,
         pct_cip_education_m = p_2032_m  /p_2030_m * 100,
         pct_cip_art_t = p_2034_t / p_2030_t * 100,
         pct_cip_art_f = p_2034_f / p_2030_f * 100,
         pct_cip_art_m = p_2034_m / p_2030_m * 100,
         pct_cip_humanities_t = p_2037_t / p_2030_t * 100,
         pct_cip_humanities_f = p_2037_f / p_2030_f * 100,
         pct_cip_humanities_m = p_2037_m / p_2030_m * 100,
         pct_cip_social_t = p_2046_t / p_2030_t * 100,
         pct_cip_social_f = p_2046_f / p_2030_f * 100,
         pct_cip_social_m = p_2046_m / p_2030_m * 100,
         pct_cip_buisiness_t = p_2054_t / p_2030_t * 100,
         pct_cip_buisiness_f = p_2054_f / p_2030_f * 100,
         pct_cip_buisiness_m = p_2054_m / p_2030_m * 100,
         pct_cip_physical_t = p_2058_t / p_2030_t * 100,
         pct_cip_physical_f = p_2058_f / p_2030_f * 100,
         pct_cip_physical_m = p_2058_m / p_2030_m * 100,
         pct_cip_math_t = p_2064_t / p_2030_t * 100,
         pct_cip_math_f = p_2064_f / p_2030_f * 100,
         pct_cip_math_m = p_2064_m / p_2030_m * 100,
         pct_cip_architecture_t = p_2069_t / p_2030_t * 100,
         pct_cip_architecture_f = p_2069_f / p_2030_f * 100,
         pct_cip_architecture_m = p_2069_m / p_2030_m * 100,
         pct_cip_agriculture_t = p_2077_t / p_2030_t * 100,
         pct_cip_agriculture_f = p_2077_f / p_2030_f * 100,
         pct_cip_agriculture_m = p_2077_m / p_2030_m * 100,
         pct_cip_health_t = p_2080_t / p_2030_t * 100,
         pct_cip_health_f = p_2080_f / p_2030_f * 100,
         pct_cip_health_m = p_2080_m / p_2030_m * 100,
         pct_cip_personal_t = p_2086_t / p_2030_t * 100,
         pct_cip_personal_f = p_2086_f / p_2030_f * 100,
         pct_cip_personal_m = p_2086_m / p_2030_m * 100) |>
  
  # 9.6. LABOUR FORCE                                                       ####
  # -------------------------------------------------------------------------- #
  
  # Rename labour force participation rate and employment rate
  rename(pct_lf_participation_t = p_2228_t,
         pct_lf_participation_f = p_2228_f,
         pct_lf_participation_m = p_2228_m,
         pct_emp_t = p_2229_t,
         pct_emp_f = p_2229_f,
         pct_emp_m = p_2229_m,
         pct_unemp_t = p_2230_t,
         pct_unemp_f = p_2230_f,
         pct_unemp_m = p_2230_m) |>
    
  # Calculate percentage of labour force who are self-employed
  mutate(pct_self_emp_t = p_2245_t / p_2237_t * 100,
         pct_self_emp_f = p_2245_f / p_2237_f * 100,
         pct_self_emp_m = p_2245_m / p_2237_m * 100) |>
  
  # Calculate percentage of labour force by NOC
  mutate(pct_noc_0_t = p_2249_t / p_2246_t * 100,
         pct_noc_0_f = p_2249_f / p_2246_f * 100,
         pct_noc_0_m = p_2249_m / p_2246_m * 100,
         pct_noc_1_t = p_2250_t / p_2246_t * 100,
         pct_noc_1_f = p_2250_f / p_2246_f * 100,
         pct_noc_1_m = p_2250_m / p_2246_m * 100,
         pct_noc_2_t = p_2251_t / p_2246_t * 100,
         pct_noc_2_f = p_2251_f / p_2246_f * 100,
         pct_noc_2_m = p_2251_m / p_2246_m * 100,
         pct_noc_3_t = p_2252_t / p_2246_t * 100,
         pct_noc_3_f = p_2252_f / p_2246_f * 100,
         pct_noc_3_m = p_2252_m / p_2246_m * 100,
         pct_noc_4_t = p_2253_t / p_2246_t * 100,
         pct_noc_4_f = p_2253_f / p_2246_f * 100,
         pct_noc_4_m = p_2253_m / p_2246_m * 100,
         pct_noc_5_t = p_2254_t / p_2246_t * 100,
         pct_noc_5_f = p_2254_f / p_2246_f * 100,
         pct_noc_5_m = p_2254_m / p_2246_m * 100,
         pct_noc_6_t = p_2255_t / p_2246_t * 100,
         pct_noc_6_f = p_2255_f / p_2246_f * 100,
         pct_noc_6_m = p_2255_m / p_2246_m * 100,
         pct_noc_7_t = p_2256_t / p_2246_t * 100,
         pct_noc_7_f = p_2256_f / p_2246_f * 100,
         pct_noc_7_m = p_2256_m / p_2246_m * 100,
         pct_noc_8_t = p_2257_t / p_2246_t * 100,
         pct_noc_8_f = p_2257_f / p_2246_f * 100,
         pct_noc_8_m = p_2257_m / p_2246_m * 100,
         pct_noc_9_t = p_2258_t / p_2246_t * 100,
         pct_noc_9_f = p_2258_f / p_2246_f * 100,
         pct_noc_9_m = p_2258_m / p_2246_m * 100) |>
  
  # Calculate percentage of labour force industries by NAICS
  mutate(pct_naics_11_t = p_2262_t / p_2259_t * 100,
         pct_naics_11_f = p_2262_f / p_2259_f * 100,
         pct_naics_11_m = p_2262_m / p_2259_m * 100,
         pct_naics_21_t = p_2263_t / p_2259_t * 100,
         pct_naics_21_f = p_2263_f / p_2259_f * 100,
         pct_naics_21_m = p_2263_m / p_2259_m * 100,
         pct_naics_22_t = p_2264_t / p_2259_t * 100,
         pct_naics_22_f = p_2264_f / p_2259_f * 100,
         pct_naics_22_m = p_2264_m / p_2259_m * 100,
         pct_naics_23_t = p_2265_t / p_2259_t * 100,
         pct_naics_23_f = p_2265_f / p_2259_f * 100,
         pct_naics_23_m = p_2265_m / p_2259_m * 100,
         pct_naics_31to33_t = p_2266_t / p_2259_t * 100,
         pct_naics_31to33_f = p_2266_f / p_2259_f * 100,
         pct_naics_31to33_m = p_2266_m / p_2259_m * 100,
         pct_naics_41_t = p_2267_t / p_2259_t * 100,
         pct_naics_41_f = p_2267_f / p_2259_f * 100,
         pct_naics_41_m = p_2267_m / p_2259_m * 100,
         pct_naics_44to45_t = p_2268_t / p_2259_t * 100,
         pct_naics_44to45_f = p_2268_f / p_2259_f * 100,
         pct_naics_44to45_m = p_2268_m / p_2259_m * 100,
         pct_naics_48to49_t = p_2269_t / p_2259_t * 100,
         pct_naics_48to49_f = p_2269_f / p_2259_f * 100,
         pct_naics_48to49_m = p_2269_m / p_2259_m * 100,
         pct_naics_51_t = p_2270_t / p_2259_t * 100,
         pct_naics_51_f = p_2270_f / p_2259_f * 100,
         pct_naics_51_m = p_2270_m / p_2259_m * 100,
         pct_naics_52_t = p_2271_t / p_2259_t * 100,
         pct_naics_52_f = p_2271_f / p_2259_f * 100,
         pct_naics_52_m = p_2271_m / p_2259_m * 100,
         pct_naics_53_t = p_2272_t / p_2259_t * 100,
         pct_naics_53_f = p_2272_f / p_2259_f * 100,
         pct_naics_53_m = p_2272_m / p_2259_m * 100,
         pct_naics_54_t = p_2273_t / p_2259_t * 100,
         pct_naics_54_f = p_2273_f / p_2259_f * 100,
         pct_naics_54_m = p_2273_m / p_2259_m * 100,
         pct_naics_55_t = p_2274_t / p_2259_t * 100,
         pct_naics_55_f = p_2274_f / p_2259_f * 100,
         pct_naics_55_m = p_2274_m / p_2259_m * 100,
         pct_naics_56_t = p_2275_t / p_2259_t * 100,
         pct_naics_56_f = p_2275_f / p_2259_f * 100,
         pct_naics_56_m = p_2275_m / p_2259_m * 100,
         pct_naics_61_t = p_2276_t / p_2259_t * 100,
         pct_naics_61_f = p_2276_f / p_2259_f * 100,
         pct_naics_61_m = p_2276_m / p_2259_m * 100,
         pct_naics_62_t = p_2277_t / p_2259_t * 100,
         pct_naics_62_f = p_2277_f / p_2259_f * 100,
         pct_naics_62_m = p_2277_m / p_2259_m * 100,
         pct_naics_71_t = p_2278_t / p_2259_t * 100,
         pct_naics_71_f = p_2278_f / p_2259_f * 100,
         pct_naics_71_m = p_2278_m / p_2259_m * 100,
         pct_naics_72_t = p_2279_t / p_2259_t * 100,
         pct_naics_72_f = p_2279_f / p_2259_f * 100,
         pct_naics_72_m = p_2279_m / p_2259_m * 100,
         pct_naics_81_t = p_2280_t / p_2259_t * 100,
         pct_naics_81_f = p_2280_f / p_2259_f * 100,
         pct_naics_81_m = p_2280_m / p_2259_m * 100,
         pct_naics_91_t = p_2281_t / p_2259_t * 100,
         pct_naics_91_f = p_2281_f / p_2259_f * 100,
         pct_naics_91_m = p_2281_m / p_2259_m * 100) |>
  
  # 9.7. HOUSING                                                            ####
  # -------------------------------------------------------------------------- #
  
  # Calculate percentage of occupied dwellings that are apartment buildings 
  # with five or more storeys
  mutate(pct_apt_5plus = p_47_t / p_41_t * 100) |> 
    
  # Calculate percentage of occupied dwellings that need major repairs
  mutate(pct_major_repair = p_1451_t / p_1449_t * 100) |> 
  
  # Calculate percentage of movers
  mutate(pct_mover_1y_t = p_1976_t / p_1974_t * 100,
         pct_mover_1y_f = p_1976_f / p_1974_f * 100,
         pct_mover_1y_m = p_1976_m / p_1974_m * 100,
         pct_mover_5y_t = p_1985_t / p_1983_t * 100,
         pct_mover_5y_f = p_1985_f / p_1983_f * 100,
         pct_mover_5y_m = p_1985_m / p_1983_m * 100) |> 
  
  # Calculate percentage of private households living in not suitable 
  # accommodations
  mutate(pct_not_suitable = p_1439_t / p_1437_t * 100) |> 
  
  # Rename percentage of tenant households spending 30% or more of income 
  # on shelter costs	
  rename(pct_shelter_cost_30plus_tenant = p_1492_t) |> 
  
  # Rename percentage of owner households spending 30% or more of income on 
  # shelter costs	
  rename(pct_shelter_cost_30plus_owner = p_1484_t) |>
  
  # Calculate percentage of owner and tenants households spending 30% or more 
  # of income on shelter costs	
  mutate(pct_shelter_cost_30plus_tenant_owner = p_1467_t / p_1465_t * 100) |>
  
  # Rename median value of owned dwellings	
  rename(med_dwelling_value = p_1488_t) |>
  
  # Rename average value of owned dwellings	
  rename(mean_dwelling_value = p_1489_t) |>
  
  # Calculate percentage of households who are tenure owner/renter/band  
  mutate(pct_owner = p_1415_t / p_1414_t * 100,
         pct_renter = p_1416_t / p_1414_t * 100,
         pct_band_housing = p_1417_t / p_1414_t * 100) 
  
# Save in CSV
write_csv(casdohi_da11_can_2011_MASTER, 
          "Data/casdohi_da11_can_2011_MASTER.csv")
 
# 10. CONSTRUCT CASDOHI 2016                                                ####
# ---------------------------------------------------------------------------- #
# This step constructs CASDOHI 2016 based on Appendix C of the paper.
  
# Import the harmonized census profile 2016 
casdohi_da16_can_2016_MASTER <- 
  read_csv("Data/census_profile_da16_can_2016_HARM.csv") |>
    
  # 10.1. POPULATION AND AGE GROUPS                                         ####
  # -------------------------------------------------------------------------- #
  
  # Rename population counts
  rename(pop_t = p_1_t, 
         pop_f = p_8_f, 
         pop_m = p_8_m) |>
    
  # Calculate percentage of population who are female
  mutate(pct_pop_f = pop_f / pop_t * 100) |>
  
  # Rename population density
  rename(pop_density = p_6_t) |>
  
  # Rename population average and median age
  rename(mean_age_t = p_39_t, 
         mean_age_f = p_39_f, 
         mean_age_m = p_39_m,
         med_age_t = p_40_t,
         med_age_f = p_40_f,
         med_age_m = p_40_m) |>
  
  # Create age groups
  mutate(pct_age_under5_t = p_10_t / pop_t * 100,
         pct_age_under5_f = p_10_f / pop_f * 100,
         pct_age_under5_m = p_10_m / pop_m * 100) |>
  
  mutate(pct_age_under15_t = p_35_t,
         pct_age_under15_f = p_35_f,
         pct_age_under15_m = p_35_m,
         pct_age_5to14_t = (p_11_t + p_12_t) / pop_t * 100,
         pct_age_5to14_f = (p_11_f + p_12_f) / pop_f * 100,
         pct_age_5to14_m = (p_11_m + p_12_m) / pop_m * 100,
         pct_age_65plus_t = p_37_t,
         pct_age_65plus_f = p_37_f,
         pct_age_65plus_m = p_37_m) |>
  
  # Calculate dependency ratio
  mutate(ratio_dep_t = (p_9_t + p_24_t) / p_13_t,
         ratio_dep_f = (p_9_f + p_24_f) / p_13_f,
         ratio_dep_m = (p_9_m + p_24_m) / p_13_m) |>
  
  # 10.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT                             ####
  # -------------------------------------------------------------------------- #
  
  # Rename average household size
  rename(mean_hh_size = p_58_t) |>
    
  # Calculate the percentage of pop 15+ by marriage status
  mutate(pct_mcl_t = p_60_t / p_59_t * 100,
         pct_mcl_f = p_60_f / p_59_f * 100,
         pct_mcl_m = p_60_m / p_59_m * 100,
         pct_nm_t = p_64_t / p_59_t * 100,
         pct_nm_f = p_64_f / p_59_f * 100,
         pct_nm_m = p_64_m / p_59_m * 100,
         pct_sdw_t = (p_65_t + p_66_t + p_67_t) / p_59_t * 100,
         pct_sdw_f = (p_65_f + p_66_f + p_67_f) / p_59_f * 100,
         pct_sdw_m = (p_65_m + p_66_m + p_67_m) / p_59_m * 100) |>
  
  # Calculate the percentage of single-parent families
  mutate(pct_single_parent_t = p_78_t / p_74_t * 100,
         pct_single_parent_f = p_79_f / p_74_f * 100,
         pct_single_parent_m = p_80_m / p_74_m * 100) |>
  
  # Calculate percentage of population who are living alone
  mutate(pct_alone_t = p_52_t / p_57_t * 100,
         pct_alone_f = p_52_f / p_57_f * 100,
         pct_alone_m = p_52_m / p_57_m * 100) |>
  
  # 10.3. EHNOCULTURAL INDICATORS                                           ####
  # -------------------------------------------------------------------------- #

  # Calculate the percentage of pop with no knowledge of official languages 
  # (English and French)
  mutate(pct_no_eng_fr_t = p_104_t / p_100_t * 100,
         pct_no_eng_fr_f = p_104_f / p_100_f * 100,
         pct_no_eng_fr_m = p_104_m / p_100_m * 100) |>
    
  # Calculate percentages for immigration status
  mutate(pct_non_immig_t = p_1141_t / p_1140_t * 100,
         pct_non_immig_f = p_1141_f / p_1140_f * 100,
         pct_non_immig_m = p_1141_m / p_1140_m * 100,
         pct_immig_t = p_1142_t / p_1140_t * 100,
         pct_immig_f = p_1142_f / p_1140_f * 100,
         pct_immig_m = p_1142_m / p_1140_m * 100,
         pct_non_pr_t = p_1150_t / p_1140_t * 100,
         pct_non_pr_f = p_1150_f / p_1140_f * 100,
         pct_non_pr_m = p_1150_m / p_1140_m * 100) |>
  
  # Calculate percentage of recent immigrants
  mutate(pct_recent_immig_t = p_1149_t / p_1140_t * 100,
         pct_recent_immig_f = p_1149_f / p_1140_f * 100,
         pct_recent_immig_m = p_1149_m / p_1140_m * 100) |>
  
  # Calculate percentage of Indigenous pop
  mutate(pct_indigenous_t = p_1290_t / p_1289_t * 100,
         pct_indigenous_f = p_1290_f / p_1289_f * 100,
         pct_indigenous_m = p_1290_m / p_1289_m * 100) |>
  
  # Calculate percentage of pop who self-identify as visible minority
  mutate(pct_vm_t = p_1324_t / p_1323_t * 100,
         pct_vm_f = p_1324_f / p_1323_f * 100,
         pct_vm_m = p_1324_m / p_1323_m * 100) |>
  
  # Calculate percentage of ethnicity categories pop
  mutate(pct_south_asian_t = p_1325_t / p_1323_t * 100,
         pct_south_asian_f = p_1325_f / p_1323_f * 100,
         pct_south_asian_m = p_1325_m / p_1323_m * 100,
         pct_east_asian_t = (p_1326_t + p_1333_t + p_1334_t) / p_1323_t * 100,
         pct_east_asian_f = (p_1326_f + p_1333_f + p_1334_f) / p_1323_f * 100,
         pct_east_asian_m = (p_1326_m + p_1333_m + p_1334_m) / p_1323_m * 100,
         pct_black_t = p_1327_t / p_1323_t * 100,
         pct_black_f = p_1327_f / p_1323_f * 100,
         pct_black_m = p_1327_m / p_1323_m * 100,
         pct_southeast_asian_t = (p_1328_t + p_1331_t) / p_1323_t * 100,
         pct_southeast_asian_f = (p_1328_f + p_1331_f) / p_1323_f * 100,
         pct_southeast_asian_m = (p_1328_m + p_1331_m) / p_1323_m * 100,
         pct_latin_american_t = p_1329_t / p_1323_t * 100,
         pct_latin_american_f = p_1329_f / p_1323_f * 100,
         pct_latin_american_m = p_1329_m / p_1323_m * 100,
         pct_middle_eastern_t = (p_1330_t + p_1332_t) / p_1323_t * 100,
         pct_middle_eastern_f = (p_1330_f + p_1332_f) / p_1323_f * 100,
         pct_middle_eastern_m = (p_1330_m + p_1332_m) / p_1323_m * 100) |>
  
  # 10.4. INCOME                                                            ####
  # -------------------------------------------------------------------------- #
  
  # Rename median/average individual/household total/after-tax income
  rename(med_ttinc_hh = p_742_t,
         med_atinc_hh = p_743_t,
         mean_ttinc_hh = p_751_t,
         mean_atinc_hh = p_752_t,
         med_ttinc_ind_t = p_663_t,
         med_ttinc_ind_f = p_663_f,
         med_ttinc_ind_m = p_663_m,
         mean_ttinc_ind_t = p_674_t,
         mean_ttinc_ind_f = p_674_f,
         mean_ttinc_ind_m = p_674_m,
         med_atinc_ind_t = p_665_t,
         med_atinc_ind_f = p_665_f,
         med_atinc_ind_m = p_665_m,
         mean_atinc_ind_t = p_676_t,
         mean_atinc_ind_f = p_676_f,
         mean_atinc_ind_m = p_676_m) |>
    
  # Calculate the percentage of pop who received gov. transfer
  mutate(pct_pop_gtransfer_t = p_668_t / p_661_t * 100,
         pct_pop_gtransfer_f = p_668_f / p_661_f * 100,
         pct_pop_gtransfer_m = p_668_m / p_661_m * 100) |>
  
  # Rename the percentage of total income from gov. transfer
  rename(pct_inc_gtransfer_t = p_690_t,
         pct_inc_gtransfer_f = p_690_f,
         pct_inc_gtransfer_m = p_690_m,) |>
  
  # Rename percentage of low-income pop based on LIM and LICO
  rename(pct_lico_at_t = p_867_t,
         pct_lico_at_f = p_867_f,
         pct_lico_at_m = p_867_m,
         pct_lim_at_t = p_857_t,
         pct_lim_at_f = p_857_f,
         pct_lim_at_m = p_857_m) |>
  
  # Calculate median after-tax household income adjusted for household siz
  mutate(med_atinc_hh_adj = med_atinc_hh / sqrt(mean_hh_size)) |>
  
  # 10.5. EDUCATION                                                         ####
  # -------------------------------------------------------------------------- #
  
  # Calculate percentage of the pop 15+ by education
  mutate(pct_no_diploma_t = p_1684_t / p_1683_t * 100,
         pct_no_diploma_f = p_1684_f / p_1683_f * 100,
         pct_no_diploma_m = p_1684_m / p_1683_m * 100,
         pct_uni_diploma_t = p_1692_t / p_1683_t * 100,
         pct_uni_diploma_f = p_1692_f / p_1683_f * 100,
         pct_uni_diploma_m = p_1692_m / p_1683_m * 100) |>
    
  # Calculate percentage of pop 15+ by thir field of the study - CIP
  mutate(pct_cip_education_t = p_1715_t / p_1713_t * 100,
         pct_cip_education_f = p_1715_f / p_1713_f * 100,
         pct_cip_education_m = p_1715_m  /p_1713_m * 100,
         pct_cip_art_t = p_1717_t / p_1713_t * 100,
         pct_cip_art_f = p_1717_f / p_1713_f * 100,
         pct_cip_art_m = p_1717_m / p_1713_m * 100,
         pct_cip_humanities_t = p_1720_t / p_1713_t * 100,
         pct_cip_humanities_f = p_1720_f / p_1713_f * 100,
         pct_cip_humanities_m = p_1720_m / p_1713_m * 100,
         pct_cip_social_t = p_1729_t / p_1713_t * 100,
         pct_cip_social_f = p_1729_f / p_1713_f * 100,
         pct_cip_social_m = p_1729_m / p_1713_m * 100,
         pct_cip_buisiness_t = p_1737_t / p_1713_t * 100,
         pct_cip_buisiness_f = p_1737_f / p_1713_f * 100,
         pct_cip_buisiness_m = p_1737_m / p_1713_m * 100,
         pct_cip_physical_t = p_1741_t / p_1713_t * 100,
         pct_cip_physical_f = p_1741_f / p_1713_f * 100,
         pct_cip_physical_m = p_1741_m / p_1713_m * 100,
         pct_cip_math_t = p_1747_t / p_1713_t * 100,
         pct_cip_math_f = p_1747_f / p_1713_f * 100,
         pct_cip_math_m = p_1747_m / p_1713_m * 100,
         pct_cip_architecture_t = p_1752_t / p_1713_t * 100,
         pct_cip_architecture_f = p_1752_f / p_1713_f * 100,
         pct_cip_architecture_m = p_1752_m / p_1713_m * 100,
         pct_cip_agriculture_t = p_1760_t / p_1713_t * 100,
         pct_cip_agriculture_f = p_1760_f / p_1713_f * 100,
         pct_cip_agriculture_m = p_1760_m / p_1713_m * 100,
         pct_cip_health_t = p_1763_t / p_1713_t * 100,
         pct_cip_health_f = p_1763_f / p_1713_f * 100,
         pct_cip_health_m = p_1763_m / p_1713_m * 100,
         pct_cip_personal_t = p_1767_t / p_1713_t * 100,
         pct_cip_personal_f = p_1767_f / p_1713_f * 100,
         pct_cip_personal_m = p_1767_m / p_1713_m * 100) |>
  
  # 10.6. LABOUR FORCE                                                      ####
  # -------------------------------------------------------------------------- #
  
  # Rename labour force participation rate and employment rate
  rename(pct_lf_participation_t = p_1870_t,
         pct_lf_participation_f = p_1870_f,
         pct_lf_participation_m = p_1870_m,
         pct_emp_t = p_1871_t,
         pct_emp_f = p_1871_f,
         pct_emp_m = p_1871_m,
         pct_unemp_t = p_1872_t,
         pct_unemp_f = p_1872_f,
         pct_unemp_m = p_1872_m) |>
    
  # Calculate percentage of labour force who are self-employed
  mutate(pct_self_emp_t = p_1883_t / p_1879_t * 100,
         pct_self_emp_f = p_1883_f / p_1879_f * 100,
         pct_self_emp_m = p_1883_m / p_1879_m * 100) |>
  
  # Calculate percentage of labour force by NOC
  mutate(pct_noc_0_t = p_1887_t / p_1884_t * 100,
         pct_noc_0_f = p_1887_f / p_1884_f * 100,
         pct_noc_0_m = p_1887_m / p_1884_m * 100,
         pct_noc_1_t = p_1888_t / p_1884_t * 100,
         pct_noc_1_f = p_1888_f / p_1884_f * 100,
         pct_noc_1_m = p_1888_m / p_1884_m * 100,
         pct_noc_2_t = p_1889_t / p_1884_t * 100,
         pct_noc_2_f = p_1889_f / p_1884_f * 100,
         pct_noc_2_m = p_1889_m / p_1884_m * 100,
         pct_noc_3_t = p_1890_t / p_1884_t * 100,
         pct_noc_3_f = p_1890_f / p_1884_f * 100,
         pct_noc_3_m = p_1890_m / p_1884_m * 100,
         pct_noc_4_t = p_1891_t / p_1884_t * 100,
         pct_noc_4_f = p_1891_f / p_1884_f * 100,
         pct_noc_4_m = p_1891_m / p_1884_m * 100,
         pct_noc_5_t = p_1892_t / p_1884_t * 100,
         pct_noc_5_f = p_1892_f / p_1884_f * 100,
         pct_noc_5_m = p_1892_m / p_1884_m * 100,
         pct_noc_6_t = p_1893_t / p_1884_t * 100,
         pct_noc_6_f = p_1893_f / p_1884_f * 100,
         pct_noc_6_m = p_1893_m / p_1884_m * 100,
         pct_noc_7_t = p_1894_t / p_1884_t * 100,
         pct_noc_7_f = p_1894_f / p_1884_f * 100,
         pct_noc_7_m = p_1894_m / p_1884_m * 100,
         pct_noc_8_t = p_1895_t / p_1884_t * 100,
         pct_noc_8_f = p_1895_f / p_1884_f * 100,
         pct_noc_8_m = p_1895_m / p_1884_m * 100,
         pct_noc_9_t = p_1896_t / p_1884_t * 100,
         pct_noc_9_f = p_1896_f / p_1884_f * 100,
         pct_noc_9_m = p_1896_m / p_1884_m * 100) |>
  
  # Calculate percentage of labour force industries by NAICS
  mutate(pct_naics_11_t = p_1900_t / p_1897_t * 100,
         pct_naics_11_f = p_1900_f / p_1897_f * 100,
         pct_naics_11_m = p_1900_m / p_1897_m * 100,
         pct_naics_21_t = p_1901_t / p_1897_t * 100,
         pct_naics_21_f = p_1901_f / p_1897_f * 100,
         pct_naics_21_m = p_1901_m / p_1897_m * 100,
         pct_naics_22_t = p_1902_t / p_1897_t * 100,
         pct_naics_22_f = p_1902_f / p_1897_f * 100,
         pct_naics_22_m = p_1902_m / p_1897_m * 100,
         pct_naics_23_t = p_1903_t / p_1897_t * 100,
         pct_naics_23_f = p_1903_f / p_1897_f * 100,
         pct_naics_23_m = p_1903_m / p_1897_m * 100,
         pct_naics_31to33_t = p_1904_t / p_1897_t * 100,
         pct_naics_31to33_f = p_1904_f / p_1897_f * 100,
         pct_naics_31to33_m = p_1904_m / p_1897_m * 100,
         pct_naics_41_t = p_1905_t / p_1897_t * 100,
         pct_naics_41_f = p_1905_f / p_1897_f * 100,
         pct_naics_41_m = p_1905_m / p_1897_m * 100,
         pct_naics_44to45_t = p_1906_t / p_1897_t * 100,
         pct_naics_44to45_f = p_1906_f / p_1897_f * 100,
         pct_naics_44to45_m = p_1906_m / p_1897_m * 100,
         pct_naics_48to49_t = p_1907_t / p_1897_t * 100,
         pct_naics_48to49_f = p_1907_f / p_1897_f * 100,
         pct_naics_48to49_m = p_1907_m / p_1897_m * 100,
         pct_naics_51_t = p_1908_t / p_1897_t * 100,
         pct_naics_51_f = p_1908_f / p_1897_f * 100,
         pct_naics_51_m = p_1908_m / p_1897_m * 100,
         pct_naics_52_t = p_1909_t / p_1897_t * 100,
         pct_naics_52_f = p_1909_f / p_1897_f * 100,
         pct_naics_52_m = p_1909_m / p_1897_m * 100,
         pct_naics_53_t = p_1910_t / p_1897_t * 100,
         pct_naics_53_f = p_1910_f / p_1897_f * 100,
         pct_naics_53_m = p_1910_m / p_1897_m * 100,
         pct_naics_54_t = p_1911_t / p_1897_t * 100,
         pct_naics_54_f = p_1911_f / p_1897_f * 100,
         pct_naics_54_m = p_1911_m / p_1897_m * 100,
         pct_naics_55_t = p_1912_t / p_1897_t * 100,
         pct_naics_55_f = p_1912_f / p_1897_f * 100,
         pct_naics_55_m = p_1912_m / p_1897_m * 100,
         pct_naics_56_t = p_1913_t / p_1897_t * 100,
         pct_naics_56_f = p_1913_f / p_1897_f * 100,
         pct_naics_56_m = p_1913_m / p_1897_m * 100,
         pct_naics_61_t = p_1914_t / p_1897_t * 100,
         pct_naics_61_f = p_1914_f / p_1897_f * 100,
         pct_naics_61_m = p_1914_m / p_1897_m * 100,
         pct_naics_62_t = p_1915_t / p_1897_t * 100,
         pct_naics_62_f = p_1915_f / p_1897_f * 100,
         pct_naics_62_m = p_1915_m / p_1897_m * 100,
         pct_naics_71_t = p_1916_t / p_1897_t * 100,
         pct_naics_71_f = p_1916_f / p_1897_f * 100,
         pct_naics_71_m = p_1916_m / p_1897_m * 100,
         pct_naics_72_t = p_1917_t / p_1897_t * 100,
         pct_naics_72_f = p_1917_f / p_1897_f * 100,
         pct_naics_72_m = p_1917_m / p_1897_m * 100,
         pct_naics_81_t = p_1918_t / p_1897_t * 100,
         pct_naics_81_f = p_1918_f / p_1897_f * 100,
         pct_naics_81_m = p_1918_m / p_1897_m * 100,
         pct_naics_91_t = p_1919_t / p_1897_t * 100,
         pct_naics_91_f = p_1919_f / p_1897_f * 100,
         pct_naics_91_m = p_1919_m / p_1897_m * 100) |>
  
  # 10.7. HOUSING                                                           ####
  # -------------------------------------------------------------------------- #
  
  # Calculate percentage of occupied dwellings that are apartment buildings 
  # with five or more storeys
  mutate(pct_apt_5plus = p_43_t / p_41_t * 100) |> 
    
  # Calculate percentage of occupied dwellings that need major repairs
  mutate(pct_major_repair = p_1653_t / p_1651_t * 100) |> 
  
  # Calculate percentage of movers
  mutate(pct_mover_1y_t = p_2232_t / p_2230_t * 100,
         pct_mover_1y_f = p_2232_f / p_2230_f * 100,
         pct_mover_1y_m = p_2232_m / p_2230_m * 100,
         pct_mover_5y_t = p_2241_t / p_2239_t * 100,
         pct_mover_5y_f = p_2241_f / p_2239_f * 100,
         pct_mover_5y_m = p_2241_m / p_2239_m * 100) |> 
  
  # Calculate percentage of private households living in not suitable 
  # accommodations
  mutate(pct_not_suitable = p_1642_t / p_1640_t * 100) |> 
  
  # Rename percentage of tenant households spending 30% or more of income 
  # on shelter costs	
  rename(pct_shelter_cost_30plus_tenant = p_1680_t) |> 
  
  # Rename percentage of owner households spending 30% or more of income on 
  # shelter costs	
  rename(pct_shelter_cost_30plus_owner = p_1673_t) |>
  
  # Calculate percentage of owner and tenants households spending 30% or more 
  # of income on shelter costs	
  mutate(pct_shelter_cost_30plus_tenant_owner = p_1669_t / p_1667_t * 100) |>
  
  # Rename median value of owned dwellings	
  rename(med_dwelling_value = p_1676_t) |>
  
  # Rename average value of owned dwellings	
  rename(mean_dwelling_value = p_1677_t) |>
  
  # Calculate percentage of households who are tenure owner/renter/band  
  mutate(pct_owner = p_1618_t / p_1617_t * 100,
         pct_renter = p_1619_t / p_1617_t * 100,
         pct_band_housing = p_1620_t / p_1617_t * 100)

# Save in CSV
write_csv(casdohi_da16_can_2016_MASTER, "Data/casdohi_da16_can_2016_MASTER.csv")
  
# 11. CONSTRUCT CASDOHI 2021                                                ####
# ---------------------------------------------------------------------------- #
# This step constructs CASDOHI 2021 based on Appendix C of the paper.
  
# Import the harmonized census profile 2021 
casdohi_da21_can_2021_MASTER <- 
  read_csv("Data/census_profile_da21_can_2021_HARM.csv") |>
    
  # 11.1. POPULATION AND AGE GROUPS                                         ####
  # -------------------------------------------------------------------------- #
  
  # Rename population counts
  rename(pop_t = p_1_t, 
         pop_f = p_8_f, 
         pop_m = p_8_m) |>
    
  # Calculate percentage of population who are female
  mutate(pct_pop_f = pop_f / pop_t * 100) |>
  
  # Rename population density
  rename(pop_density = p_6_t) |>
  
  # Rename population average and median age
  rename(mean_age_t = p_39_t, 
         mean_age_f = p_39_f, 
         mean_age_m = p_39_m,
         med_age_t = p_40_t,
         med_age_f = p_40_f,
         med_age_m = p_40_m) |>
  
  # Create age groups
  mutate(pct_age_under5_t = p_10_t / pop_t * 100,
         pct_age_under5_f = p_10_f / pop_f * 100,
         pct_age_under5_m = p_10_m / pop_m * 100) |>
  
  mutate(pct_age_under15_t = p_35_t,
         pct_age_under15_f = p_35_f,
         pct_age_under15_m = p_35_m,
         pct_age_5to14_t = (p_11_t + p_12_t) / pop_t * 100,
         pct_age_5to14_f = (p_11_f + p_12_f) / pop_f * 100,
         pct_age_5to14_m = (p_11_m + p_12_m) / pop_m * 100,
         pct_age_65plus_t = p_37_t,
         pct_age_65plus_f = p_37_f,
         pct_age_65plus_m = p_37_m) |>
  
  # Calculate dependency ratio
  mutate(ratio_dep_t = (p_9_t + p_24_t) / p_13_t,
         ratio_dep_f = (p_9_f + p_24_f) / p_13_f,
         ratio_dep_m = (p_9_m + p_24_m) / p_13_m) |>
    
  # 11.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT                             ####
  # -------------------------------------------------------------------------- #
  
  # Rename average household size
  rename(mean_hh_size = p_57_t) |>
    
  # Calculate the percentage of pop 15+ by marriage status
  mutate(pct_mcl_t = p_59_t / p_58_t * 100,
         pct_mcl_f = p_59_f / p_58_f * 100,
         pct_mcl_m = p_59_m / p_58_m * 100,
         pct_nm_t = p_67_t / p_58_t * 100,
         pct_nm_f = p_67_f / p_58_f * 100,
         pct_nm_m = p_67_m / p_58_m * 100,
         pct_sdw_t = (p_68_t + p_69_t + p_70_t) / p_58_t * 100,
         pct_sdw_f = (p_68_f + p_69_f + p_70_f) / p_58_f * 100,
         pct_sdw_m = (p_68_m + p_69_m + p_70_m) / p_58_m * 100) |>
  
  # Calculate the percentage of single-parent families
  mutate(pct_single_parent_t = p_86_t / p_78_t * 100,
         pct_single_parent_f = p_87_f / p_78_f * 100,
         pct_single_parent_m = p_88_m / p_78_m * 100) |>
  
  # Calculate percentage of population who are living alone
  mutate(pct_alone_t = p_51_t / p_89_t * 100,
         pct_alone_f = p_51_f / p_89_f * 100,
         pct_alone_m = p_51_m / p_89_m * 100) |>
  
  # 11.3. EHNOCULTURAL INDICATORS                                           ####
  # -------------------------------------------------------------------------- #
  
  # Calculate the percentage of pop with no knowledge of official languages 
  # (English and French)
  mutate(pct_no_eng_fr_t = p_387_t / p_383_t * 100,
         pct_no_eng_fr_f = p_387_f / p_383_f * 100,
         pct_no_eng_fr_m = p_387_m / p_383_m * 100) |>
    
  # Calculate percentages for immigration status
  mutate(pct_non_immig_t = p_1528_t / p_1527_t * 100,
         pct_non_immig_f = p_1528_f / p_1527_f * 100,
         pct_non_immig_m = p_1528_m / p_1527_m * 100,
         pct_immig_t = p_1529_t / p_1527_t * 100,
         pct_immig_f = p_1529_f / p_1527_f * 100,
         pct_immig_m = p_1529_m / p_1527_m * 100,
         pct_non_pr_t = p_1537_t / p_1527_t * 100,
         pct_non_pr_f = p_1537_f / p_1527_f * 100,
         pct_non_pr_m = p_1537_m / p_1527_m * 100) |>
  
  # Calculate percentage of recent immigrants
  mutate(pct_recent_immig_t = p_1536_t / p_1527_t * 100,
         pct_recent_immig_f = p_1536_f / p_1527_f * 100,
         pct_recent_immig_m = p_1536_m / p_1527_m * 100) |>
  
  # Calculate percentage of Indigenous pop
  mutate(pct_indigenous_t = p_1403_t / p_1402_t * 100,
         pct_indigenous_f = p_1403_f / p_1402_f * 100,
         pct_indigenous_m = p_1403_m / p_1402_m * 100) |>
  
  # Calculate percentage of pop who self-identify as visible minority
  mutate(pct_vm_t = p_1684_t / p_1683_t * 100,
         pct_vm_f = p_1684_f / p_1683_f * 100,
         pct_vm_m = p_1684_m / p_1683_m * 100) |>
  
  # Calculate percentage of ethnicity categories pop
  mutate(pct_south_asian_t = p_1685_t / p_1683_t * 100,
         pct_south_asian_f = p_1685_f / p_1683_f * 100,
         pct_south_asian_m = p_1685_m / p_1683_m * 100,
         pct_east_asian_t = (p_1686_t + p_1693_t + p_1694_t) / p_1683_t * 100,
         pct_east_asian_f = (p_1686_f + p_1693_f + p_1694_f) / p_1683_f * 100,
         pct_east_asian_m = (p_1686_m + p_1693_m + p_1694_m) / p_1683_m * 100,
         pct_black_t = p_1687_t / p_1683_t * 100,
         pct_black_f = p_1687_f / p_1683_f * 100,
         pct_black_m = p_1687_m / p_1683_m * 100,
         pct_southeast_asian_t = (p_1688_t + p_1691_t) / p_1683_t * 100,
         pct_southeast_asian_f = (p_1688_f + p_1691_f) / p_1683_f * 100,
         pct_southeast_asian_m = (p_1688_m + p_1691_m) / p_1683_m * 100,
         pct_latin_american_t = p_1690_t / p_1683_t * 100,
         pct_latin_american_f = p_1690_f / p_1683_f * 100,
         pct_latin_american_m = p_1690_m / p_1683_m * 100,
         pct_middle_eastern_t = (p_1689_t + p_1692_t) / p_1683_t * 100,
         pct_middle_eastern_f = (p_1689_f + p_1692_f) / p_1683_f * 100,
         pct_middle_eastern_m = (p_1689_m + p_1692_m) / p_1683_m * 100) |>
    
  # 11.4. INCOME                                                            ####
  # -------------------------------------------------------------------------- #
  
  # Rename median/average individual/household total/after-tax income
  rename(med_ttinc_hh = p_243_t,
         med_atinc_hh = p_244_t,
         mean_ttinc_hh = p_252_t,
         mean_atinc_hh = p_253_t,
         med_ttinc_ind_t = p_113_t,
         med_ttinc_ind_f = p_113_f,
         med_ttinc_ind_m = p_113_m,
         mean_ttinc_ind_t = p_128_t,
         mean_ttinc_ind_f = p_128_f,
         mean_ttinc_ind_m = p_128_m,
         med_atinc_ind_t = p_115_t,
         med_atinc_ind_f = p_115_f,
         med_atinc_ind_m = p_115_m,
         mean_atinc_ind_t = p_130_t,
         mean_atinc_ind_f = p_130_f,
         mean_atinc_ind_m = p_130_m) |>
    
  # Calculate median after-tax household income adjusted for household siz
  mutate(med_atinc_hh_adj = med_atinc_hh / sqrt(mean_hh_size)) |>
  
  # Calculate the percentage of pop who received gov. transfer
  mutate(pct_pop_gtransfer_t = p_120_t / p_111_t * 100,
         pct_pop_gtransfer_f = p_120_f / p_111_f * 100,
         pct_pop_gtransfer_m = p_120_m / p_111_m * 100) |>
  
  # Rename the percentage of total income from gov. transfer
  rename(pct_inc_gtransfer_t = p_151_t,
         pct_inc_gtransfer_f = p_151_f,
         pct_inc_gtransfer_m = p_151_m,) |>
  
  # Rename percentage of low-income pop based on LIM and LICO
  rename(pct_lico_at_t = p_360_t,
         pct_lico_at_f = p_360_f,
         pct_lico_at_m = p_360_m,
         pct_lim_at_t = p_345_t,
         pct_lim_at_f = p_345_f,
         pct_lim_at_m = p_345_m) |>
  
  # Rename Gini Index
  rename(gini_index = p_381_t) |>
  
  # 11.5. EDUCATION                                                         ####
  # -------------------------------------------------------------------------- #
  
  # Calculate percentage of the pop 15+ by education
  mutate(pct_no_diploma_t = p_1993_t / p_1998_t * 100,
         pct_no_diploma_f = p_1993_f / p_1998_f * 100,
         pct_no_diploma_m = p_1993_m / p_1998_m * 100,
         pct_uni_diploma_t = p_2008_t / p_1998_t * 100,
         pct_uni_diploma_f = p_2008_f / p_1998_f * 100,
         pct_uni_diploma_m = p_2008_m / p_1998_m * 100) |>
    
  # Calculate percentage of pop 15+ by thir field of the study - CIP
  mutate(pct_cip_education_t = p_2032_t / p_2030_t * 100,
         pct_cip_education_f = p_2032_f / p_2030_f * 100,
         pct_cip_education_m = p_2032_m  /p_2030_m * 100,
         pct_cip_art_t = p_2034_t / p_2030_t * 100,
         pct_cip_art_f = p_2034_f / p_2030_f * 100,
         pct_cip_art_m = p_2034_m / p_2030_m * 100,
         pct_cip_humanities_t = p_2037_t / p_2030_t * 100,
         pct_cip_humanities_f = p_2037_f / p_2030_f * 100,
         pct_cip_humanities_m = p_2037_m / p_2030_m * 100,
         pct_cip_social_t = p_2046_t / p_2030_t * 100,
         pct_cip_social_f = p_2046_f / p_2030_f * 100,
         pct_cip_social_m = p_2046_m / p_2030_m * 100,
         pct_cip_buisiness_t = p_2054_t / p_2030_t * 100,
         pct_cip_buisiness_f = p_2054_f / p_2030_f * 100,
         pct_cip_buisiness_m = p_2054_m / p_2030_m * 100,
         pct_cip_physical_t = p_2058_t / p_2030_t * 100,
         pct_cip_physical_f = p_2058_f / p_2030_f * 100,
         pct_cip_physical_m = p_2058_m / p_2030_m * 100,
         pct_cip_math_t = p_2064_t / p_2030_t * 100,
         pct_cip_math_f = p_2064_f / p_2030_f * 100,
         pct_cip_math_m = p_2064_m / p_2030_m * 100,
         pct_cip_architecture_t = p_2069_t / p_2030_t * 100,
         pct_cip_architecture_f = p_2069_f / p_2030_f * 100,
         pct_cip_architecture_m = p_2069_m / p_2030_m * 100,
         pct_cip_agriculture_t = p_2077_t / p_2030_t * 100,
         pct_cip_agriculture_f = p_2077_f / p_2030_f * 100,
         pct_cip_agriculture_m = p_2077_m / p_2030_m * 100,
         pct_cip_health_t = p_2080_t / p_2030_t * 100,
         pct_cip_health_f = p_2080_f / p_2030_f * 100,
         pct_cip_health_m = p_2080_m / p_2030_m * 100,
         pct_cip_personal_t = p_2086_t / p_2030_t * 100,
         pct_cip_personal_f = p_2086_f / p_2030_f * 100,
         pct_cip_personal_m = p_2086_m / p_2030_m * 100) |>
    
  # 11.6. LABOUR FORCE                                                      ####
  # -------------------------------------------------------------------------- #
  
  # Rename labour force participation rate and employment rate
  rename(pct_lf_participation_t = p_2228_t,
         pct_lf_participation_f = p_2228_f,
         pct_lf_participation_m = p_2228_m,
         pct_emp_t = p_2229_t,
         pct_emp_f = p_2229_f,
         pct_emp_m = p_2229_m,
         pct_unemp_t = p_2230_t,
         pct_unemp_f = p_2230_f,
         pct_unemp_m = p_2230_m) |>
    
  # Calculate percentage of labour force who are self-employed
  mutate(pct_self_emp_t = p_2245_t / p_2237_t * 100,
         pct_self_emp_f = p_2245_f / p_2237_f * 100,
         pct_self_emp_m = p_2245_m / p_2237_m * 100) |>
  
  # Calculate percentage of labour force by NOC
  mutate(pct_noc_0_t = p_2249_t / p_2246_t * 100,
         pct_noc_0_f = p_2249_f / p_2246_f * 100,
         pct_noc_0_m = p_2249_m / p_2246_m * 100,
         pct_noc_1_t = p_2250_t / p_2246_t * 100,
         pct_noc_1_f = p_2250_f / p_2246_f * 100,
         pct_noc_1_m = p_2250_m / p_2246_m * 100,
         pct_noc_2_t = p_2251_t / p_2246_t * 100,
         pct_noc_2_f = p_2251_f / p_2246_f * 100,
         pct_noc_2_m = p_2251_m / p_2246_m * 100,
         pct_noc_3_t = p_2252_t / p_2246_t * 100,
         pct_noc_3_f = p_2252_f / p_2246_f * 100,
         pct_noc_3_m = p_2252_m / p_2246_m * 100,
         pct_noc_4_t = p_2253_t / p_2246_t * 100,
         pct_noc_4_f = p_2253_f / p_2246_f * 100,
         pct_noc_4_m = p_2253_m / p_2246_m * 100,
         pct_noc_5_t = p_2254_t / p_2246_t * 100,
         pct_noc_5_f = p_2254_f / p_2246_f * 100,
         pct_noc_5_m = p_2254_m / p_2246_m * 100,
         pct_noc_6_t = p_2255_t / p_2246_t * 100,
         pct_noc_6_f = p_2255_f / p_2246_f * 100,
         pct_noc_6_m = p_2255_m / p_2246_m * 100,
         pct_noc_7_t = p_2256_t / p_2246_t * 100,
         pct_noc_7_f = p_2256_f / p_2246_f * 100,
         pct_noc_7_m = p_2256_m / p_2246_m * 100,
         pct_noc_8_t = p_2257_t / p_2246_t * 100,
         pct_noc_8_f = p_2257_f / p_2246_f * 100,
         pct_noc_8_m = p_2257_m / p_2246_m * 100,
         pct_noc_9_t = p_2258_t / p_2246_t * 100,
         pct_noc_9_f = p_2258_f / p_2246_f * 100,
         pct_noc_9_m = p_2258_m / p_2246_m * 100) |>
  
  # Calculate percentage of labour force industries by NAICS
  mutate(pct_naics_11_t = p_2262_t / p_2259_t * 100,
         pct_naics_11_f = p_2262_f / p_2259_f * 100,
         pct_naics_11_m = p_2262_m / p_2259_m * 100,
         pct_naics_21_t = p_2263_t / p_2259_t * 100,
         pct_naics_21_f = p_2263_f / p_2259_f * 100,
         pct_naics_21_m = p_2263_m / p_2259_m * 100,
         pct_naics_22_t = p_2264_t / p_2259_t * 100,
         pct_naics_22_f = p_2264_f / p_2259_f * 100,
         pct_naics_22_m = p_2264_m / p_2259_m * 100,
         pct_naics_23_t = p_2265_t / p_2259_t * 100,
         pct_naics_23_f = p_2265_f / p_2259_f * 100,
         pct_naics_23_m = p_2265_m / p_2259_m * 100,
         pct_naics_31to33_t = p_2266_t / p_2259_t * 100,
         pct_naics_31to33_f = p_2266_f / p_2259_f * 100,
         pct_naics_31to33_m = p_2266_m / p_2259_m * 100,
         pct_naics_41_t = p_2267_t / p_2259_t * 100,
         pct_naics_41_f = p_2267_f / p_2259_f * 100,
         pct_naics_41_m = p_2267_m / p_2259_m * 100,
         pct_naics_44to45_t = p_2268_t / p_2259_t * 100,
         pct_naics_44to45_f = p_2268_f / p_2259_f * 100,
         pct_naics_44to45_m = p_2268_m / p_2259_m * 100,
         pct_naics_48to49_t = p_2269_t / p_2259_t * 100,
         pct_naics_48to49_f = p_2269_f / p_2259_f * 100,
         pct_naics_48to49_m = p_2269_m / p_2259_m * 100,
         pct_naics_51_t = p_2270_t / p_2259_t * 100,
         pct_naics_51_f = p_2270_f / p_2259_f * 100,
         pct_naics_51_m = p_2270_m / p_2259_m * 100,
         pct_naics_52_t = p_2271_t / p_2259_t * 100,
         pct_naics_52_f = p_2271_f / p_2259_f * 100,
         pct_naics_52_m = p_2271_m / p_2259_m * 100,
         pct_naics_53_t = p_2272_t / p_2259_t * 100,
         pct_naics_53_f = p_2272_f / p_2259_f * 100,
         pct_naics_53_m = p_2272_m / p_2259_m * 100,
         pct_naics_54_t = p_2273_t / p_2259_t * 100,
         pct_naics_54_f = p_2273_f / p_2259_f * 100,
         pct_naics_54_m = p_2273_m / p_2259_m * 100,
         pct_naics_55_t = p_2274_t / p_2259_t * 100,
         pct_naics_55_f = p_2274_f / p_2259_f * 100,
         pct_naics_55_m = p_2274_m / p_2259_m * 100,
         pct_naics_56_t = p_2275_t / p_2259_t * 100,
         pct_naics_56_f = p_2275_f / p_2259_f * 100,
         pct_naics_56_m = p_2275_m / p_2259_m * 100,
         pct_naics_61_t = p_2276_t / p_2259_t * 100,
         pct_naics_61_f = p_2276_f / p_2259_f * 100,
         pct_naics_61_m = p_2276_m / p_2259_m * 100,
         pct_naics_62_t = p_2277_t / p_2259_t * 100,
         pct_naics_62_f = p_2277_f / p_2259_f * 100,
         pct_naics_62_m = p_2277_m / p_2259_m * 100,
         pct_naics_71_t = p_2278_t / p_2259_t * 100,
         pct_naics_71_f = p_2278_f / p_2259_f * 100,
         pct_naics_71_m = p_2278_m / p_2259_m * 100,
         pct_naics_72_t = p_2279_t / p_2259_t * 100,
         pct_naics_72_f = p_2279_f / p_2259_f * 100,
         pct_naics_72_m = p_2279_m / p_2259_m * 100,
         pct_naics_81_t = p_2280_t / p_2259_t * 100,
         pct_naics_81_f = p_2280_f / p_2259_f * 100,
         pct_naics_81_m = p_2280_m / p_2259_m * 100,
         pct_naics_91_t = p_2281_t / p_2259_t * 100,
         pct_naics_91_f = p_2281_f / p_2259_f * 100,
         pct_naics_91_m = p_2281_m / p_2259_m * 100) |>
    
  # 11.7. HOUSING                                                           ####
  # -------------------------------------------------------------------------- #
  
  # Calculate percentage of occupied dwellings that are apartment buildings 
  # with five or more storeys
  mutate(pct_apt_5plus = p_47_t / p_41_t * 100) |> 
    
  # Calculate percentage of occupied dwellings that need major repairs
  mutate(pct_major_repair = p_1451_t / p_1449_t * 100) |> 
  
  # Calculate percentage of movers
  mutate(pct_mover_1y_t = p_1976_t / p_1974_t * 100,
         pct_mover_1y_f = p_1976_f / p_1974_f * 100,
         pct_mover_1y_m = p_1976_m / p_1974_m * 100,
         pct_mover_5y_t = p_1985_t / p_1983_t * 100,
         pct_mover_5y_f = p_1985_f / p_1983_f * 100,
         pct_mover_5y_m = p_1985_m / p_1983_m * 100) |> 
  
  # Calculate percentage of private households living in not suitable 
  # accommodations
  mutate(pct_not_suitable = p_1439_t / p_1437_t * 100) |> 
  
  # Rename percentage of tenant households spending 30% or more of income 
  # on shelter costs	
  rename(pct_shelter_cost_30plus_tenant = p_1492_t) |> 
  
  # Rename percentage of owner households spending 30% or more of income on 
  # shelter costs	
  rename(pct_shelter_cost_30plus_owner = p_1484_t) |>
  
  # Calculate percentage of owner and tenants households spending 30% or more 
  # of income on shelter costs	
  mutate(pct_shelter_cost_30plus_tenant_owner = p_1467_t / p_1465_t * 100) |>
  
  # Rename median value of owned dwellings	
  rename(med_dwelling_value = p_1488_t) |>
  
  # Rename average value of owned dwellings	
  rename(mean_dwelling_value = p_1489_t) |>
  
  # Calculate percentage of households who are tenure owner/renter/band  
  mutate(pct_owner = p_1415_t / p_1414_t * 100,
         pct_renter = p_1416_t / p_1414_t * 100,
         pct_band_housing = p_1417_t / p_1414_t * 100)
  
# Save in CSV
write_csv(casdohi_da21_can_2021_MASTER, "Data/casdohi_da21_can_2021_MASTER.csv")

# 12. HARMONIZE ATTRIBUTE FILES, 2011, 2016, & 2021                         ####
# ---------------------------------------------------------------------------- #
# In this step, we harmonize the attribute files available on StatsCan website 
# to add larger geographic variables to CASDOHI.
  
  # 12.1. HARMONIZE ATTRIBUTE FILE, 2011                                    ####
  # -------------------------------------------------------------------------- #
  
  # Define column positions in the raw attribute file according to the codebook
  # to import the txt file in the next step
  col_positions <- fwf_positions(

    # Define where variables start
    start = c(1, 11, 19, 27, 35, 48, 49, 57, 74, 91, 100, 111, 113, 168, 198, 
              228, 238, 248, 253, 338, 342, 427, 431, 471, 474, 481, 536, 539, 
              540, 543, 550, 605, 611, 696, 699, 704, 707, 807, 808, 818, 822, 
              829, 835, 839, 939, 940),
   
    # Define where variables end 
    end = c(10, 18, 26, 34, 47, 48, 56, 73, 90, 99, 110, 112, 167, 197, 227, 
            237, 247, 252, 337, 341, 426, 430, 470, 473, 480, 535, 538, 539, 
            542, 549, 604, 610, 695, 698, 703, 706, 806, 807, 817, 821, 828, 
            834, 838, 938, 939, 941),
    
    # Define variable names
    col_names = c("DBuid", "DBpop2011", "DBtdwell2011", "DBurdwell2011", 
                  "DBarea", "DB_ir2011", "DAuid", "DAlamx", "DAlamy", "DAlat", 
                  "DAlong", "PRuid", "PRname", "PRename", "PRfname", "PReabbr", 
                  "PRfabbr", "FEDuid", "FEDname", "ERuid", "ERname", "CDuid", 
                  "CDname", "CDtype", "CSDuid", "CSDname", "CSDtype", "SACtype", 
                  "SACcode", "CCSuid", "CCSname", "DPLuid", "DPLname", 
                  "DPLtype", "CMAPuid", "CMAuid", "CMAname", "CMAtype", "CTuid", 
                  "CTcode", "CTname", "POPCTRRAPuid", "POPCTRRAuid", 
                  "POPCTRRAname", "POPCTRRAtype", "POPCTRRAclass")
  )

  # Read raw 2011 attribute file 
  attribute_file_db11_2011_RAW <- 
    read_fwf("Data/attribute_file_db11_2011_RAW.txt", col_positions, skip = 1)

  # Rename variables and keep those we need
  attribute_file_db11_2011_REDUCED <- attribute_file_db11_2011_RAW |>
    select(da_id_11 = "DAuid",
           db_pop = "DBpop2011",
           pr_id = "PRuid",
           pr_name = "PRname",
           cd_id = "CDuid",
           csd_id = "CSDuid",
           csd_name = "CSDname",
           sactype = "SACtype",
           cma_id = "CMAuid",
           ct_id = "CTuid") |>
  
  # Save da_pop as a numeric variable
  mutate(db_pop = as.numeric(db_pop))
  
  # Collapse attribute file to DA level
  attribute_file_da11_2011_MASTER <- attribute_file_db11_2011_REDUCED |>
    group_by(da_id_11) |>
    summarise(da_pop_11 = sum(db_pop, na.rm = TRUE),
              pr_id_11 = first(pr_id),
              pr_name_11 = first(pr_name),
              cd_id_11 = first(cd_id),
              csd_id_11 = first(csd_id),
              csd_name_11 = first(csd_name),
              sactype_11 = first(sactype),
              cma_id_11 = first(cma_id),
              ct_id_11 = first(ct_id))
  
  # Count the number of unique DAs in 2011 attribute file
  n_distinct(attribute_file_da11_2011_MASTER$da_id_11)  # 56,204
  
  # Save the CSV file of the harmonized attribute file
  attribute_file_da11_2011_USE <- attribute_file_da11_2011_MASTER |>
    write_csv("Data/attribute_file_da11_2011_USE.csv")

  # 12.2. HARMONIZE ATTRIBUTE FILE, 2016                                    ####
  # -------------------------------------------------------------------------- #
  
  # Add attribute file 2016 to R environment
  attribute_file_db16_2016_RAW <- 
    read_csv("Data/attribute_file_db16_2016_RAW.csv")
  
  # Rename variables
  attribute_file_db16_2016_REDUCED <- attribute_file_db16_2016_RAW |>
    select(da_id_16 = "DAuid/ADidu",
           db_id = "DBuid/IDidu",
           db_pop = "DBpop2016/IDpop2016",
           pr_id = "PRuid/PRidu",
           pr_name = "PRename/PRanom",
           cd_id = "CDuid/DRidu",
           csd_id = "CSDuid/SDRidu",
           csd_name = "CSDname/SDRnom",
           sactype = "SACtype/CSSgenre",
           cma_id = "CMAuid/RMRidu",
           ct_id = "CTuid/SRidu")
  
  # Collapse attribute file to DA level
  attribute_file_da16_2016_MASTER <- attribute_file_db16_2016_REDUCED |>
    group_by(da_id_16) |>
    summarise(da_pop_16 = sum(db_pop, na.rm = TRUE),
              pr_id_16 = first(pr_id),
              pr_name_16 = first(pr_name),
              cd_id_16 = first(cd_id),
              csd_id_16 = first(csd_id),
              csd_name_16 = first(csd_name),
              sactype_16 = first(sactype),
              cma_id_16 = first(cma_id),
              ct_id_16 = first(ct_id))
  
  # Count the number of unique DAs in 2016 attribute file
  n_distinct(attribute_file_da16_2016_MASTER$da_id_16)  # 56,590
  
  # Save the CSV file of the harmonized attribute file
  attribute_file_da16_2016_USE <- attribute_file_da16_2016_MASTER |>
    write_csv("Data/attribute_file_da16_2016_USE.csv")
  
  # 12.3. HARMONIZE ATTRIBUTE FILE, 2021                                    ####
  # -------------------------------------------------------------------------- #
  
  # Add attribute file 2021 to R environment
  attribute_file_db21_2021_RAW <- 
    read_csv("Data/attribute_file_db21_2021_RAW.csv")
  
  # Rename variables and keep variables we need
  attribute_file_db21_2021_REDUCED <- attribute_file_db21_2021_RAW |>
    select(da_id_21 = "DAUID_ADIDU",
           db_id = "DBUID_IDIDU",
           db_pop = "DBPOP2021_IDPOP2021",
           pr_id = "PRUID_PRIDU",
           pr_name = "PRENAME_PRANOM",
           cd_id = "CDUID_DRIDU",
           csd_id = "CSDUID_SDRIDU",
           csd_name = "CSDNAME_SDRNOM",
           sactype = "SACTYPE_CSSGENRE",
           cma_id = "CMAUID_RMRIDU",
           ct_id = "CTUID_SRIDU")
  
  # Collapse attribute file to DA level
  attribute_file_da21_2021_MASTER <- attribute_file_db21_2021_REDUCED |>
    group_by(da_id_21) |>
    summarise(da_pop_21 = sum(db_pop, na.rm = TRUE),
              pr_id_21 = first(pr_id),
              pr_name_21 = first(pr_name),
              cd_id_21 = first(cd_id),
              csd_id_21 = first(csd_id),
              csd_name_21 = first(csd_name),
              sactype_21 = first(sactype),
              cma_id_21 = first(cma_id),
              ct_id_21 = first(ct_id))
  
  # Count the number of unique DAs in 2021 attribute file
  n_distinct(attribute_file_da21_2021_MASTER$da_id_21)  # 57,936
  
  # Save the CSV file of the harmonized attribute file
  attribute_file_da21_2021_USE <- attribute_file_da21_2021_MASTER |>
    write_csv("Data/attribute_file_da21_2021_USE.csv")
  
# 13. CREATE THE FINAL VERSION OF CASDOHI FOR CENSAL YEARS                  ####
# ---------------------------------------------------------------------------- #  
# In this step, we merge the harmonized attribute files to CASDOHI based on DA
# and prepare the ready-to-use CASDOHI for years 2011, 2016, and 2021 in 
# separate files.
  
  # 13.1. JOIN CASDOHI MASTER AND HARMONIZED ATTRIBUTE FILES AT DA LEVEL    ####  
  # -------------------------------------------------------------------------- #  
  
  # Set census years in a vector
  census_year <- c(11, 16, 21)
  
  # Start a loop to join attribute file to CASDOHI for each census year
  for (census in census_year) {
    
    # Join CASDOHI to its attribute file
    merged_data <- left_join(get(paste0("casdohi_da", census, "_can_20", census, 
                                        "_MASTER")), 
                             get(paste0("attribute_file_da", census, "_20", 
                                        census, "_USE")),
                             by = paste0("da_id_", census))
    
    assign(paste0("casdohi_da", census, "_can_20", census, "_USE"), merged_data)
    
  }
  
  # 13.2. VALIDATE BY CHECKING IF POP COUNTS FROM ATTRIBUTE AND CP MATCH    ####
  # -------------------------------------------------------------------------- #  
  
  # List of datasets
  datasets <- list(casdohi_da11_can_2011_USE, 
                   casdohi_da16_can_2016_USE, 
                   casdohi_da21_can_2021_USE) 
  
  # Initialize an empty list to store results
  results <- list()
  
  # Loop through each dataset
  for (i in seq_along(datasets)) {
    
    # Extract the dataset
    dataset <- datasets[[i]]
    
    # Check if variables match
    match_check <- all(dataset$pop_da == dataset$da_pop, na.rm = TRUE) 
    
    # Store the result
    results[[i]] <- list(
      dataset_name = paste0("Dataset_", i), 
      matches = match_check
    )
  }
  
  # Print results
  results
  
  # ** All DA populations from attribute and CASDOHI match **  
  
  # 13.3. CLEAN AND PREPARE THE FINAL VERSION OF CASDOHI                    #### 
  # -------------------------------------------------------------------------- #
  
  # Create a version of CASDOHI 2011 to release
  casdohi_da11_can_2011_RELEASE <- casdohi_da11_can_2011_USE |>
    
    # Keep variables we need in CASDOHI 2011
    select(da_id_11, pr_id_11, pr_name_11, csd_id_11, csd_name_11, cd_id_11, 
           cma_id_11, ct_id_11, sactype_11, pop_t, pop_f, pop_m, pct_pop_f, 
           pop_density, med_age_t, med_age_f, med_age_m, pct_age_under5_t, 
           pct_age_under5_f, pct_age_under5_m, pct_age_under15_t, 
           pct_age_under15_f, pct_age_under15_m, pct_age_5to14_t, 
           pct_age_5to14_f, pct_age_5to14_m, pct_age_65plus_t, pct_age_65plus_f, 
           pct_age_65plus_m, ratio_dep_t, ratio_dep_f, ratio_dep_m, 
           mean_hh_size, pct_mcl_t, pct_mcl_f, pct_mcl_m, pct_nm_t, pct_nm_f, 
           pct_nm_m, pct_sdw_t, pct_sdw_f, pct_sdw_m, pct_single_parent_t, 
           pct_single_parent_f, pct_single_parent_m, pct_alone_t, pct_alone_f, 
           pct_alone_m, pct_no_eng_fr_t, pct_no_eng_fr_f, pct_no_eng_fr_m, 
           med_ttinc_hh, med_atinc_hh, mean_ttinc_hh, mean_atinc_hh, 
           med_ttinc_ind_t, med_ttinc_ind_f, med_ttinc_ind_m, mean_ttinc_ind_t, 
           mean_ttinc_ind_f, mean_ttinc_ind_m, med_atinc_ind_t, med_atinc_ind_f, 
           med_atinc_ind_m, mean_atinc_ind_t, mean_atinc_ind_f, 
           mean_atinc_ind_m, med_atinc_hh_adj, pct_inc_gtransfer_t, 
           pct_inc_gtransfer_f, pct_inc_gtransfer_m, pct_lim_at_t, pct_lim_at_f, 
           pct_lim_at_m, pct_non_immig_t, pct_non_immig_f, pct_non_immig_m, 
           pct_immig_t, pct_immig_f, pct_immig_m, pct_non_pr_t, pct_non_pr_f, 
           pct_non_pr_m, pct_recent_immig_t, pct_recent_immig_f, 
           pct_recent_immig_m, pct_indigenous_t, pct_indigenous_f, 
           pct_indigenous_m, pct_vm_t, pct_vm_f, pct_vm_m, pct_south_asian_t, 
           pct_south_asian_f, pct_south_asian_m, pct_east_asian_t, 
           pct_east_asian_f, pct_east_asian_m, pct_black_t, pct_black_f, 
           pct_black_m, pct_southeast_asian_t, pct_southeast_asian_f, 
           pct_southeast_asian_m, pct_latin_american_t, pct_latin_american_f, 
           pct_latin_american_m, pct_middle_eastern_t, pct_middle_eastern_f, 
           pct_middle_eastern_m, pct_apt_5plus, pct_major_repair, 
           pct_mover_1y_t, pct_mover_1y_f, pct_mover_1y_m, pct_mover_5y_t, 
           pct_mover_5y_f, pct_mover_5y_m, pct_not_suitable, 
           pct_shelter_cost_30plus_tenant, pct_shelter_cost_30plus_owner, 
           pct_shelter_cost_30plus_tenant_owner, med_dwelling_value, 
           mean_dwelling_value, pct_owner, pct_renter, pct_band_housing, 
           pct_no_diploma_t, pct_no_diploma_f, pct_no_diploma_m, 
           pct_uni_diploma_t, pct_uni_diploma_f, pct_uni_diploma_m, 
           pct_cip_education_t, pct_cip_education_f, pct_cip_education_m, 
           pct_cip_art_t, pct_cip_art_f, pct_cip_art_m, pct_cip_humanities_t, 
           pct_cip_humanities_f, pct_cip_humanities_m, pct_cip_social_t, 
           pct_cip_social_f, pct_cip_social_m, pct_cip_buisiness_t, 
           pct_cip_buisiness_m, pct_cip_buisiness_f, pct_cip_physical_t, 
           pct_cip_physical_f, pct_cip_physical_m, pct_cip_math_t, 
           pct_cip_math_f, pct_cip_math_m, pct_cip_architecture_t, 
           pct_cip_architecture_f, pct_cip_architecture_m, 
           pct_cip_agriculture_t, pct_cip_agriculture_f, pct_cip_agriculture_m, 
           pct_cip_health_t, pct_cip_health_f, pct_cip_health_m, 
           pct_cip_personal_t, pct_cip_personal_f, pct_cip_personal_m, 
           pct_lf_participation_t, pct_lf_participation_f, 
           pct_lf_participation_m, pct_emp_t, pct_emp_f, pct_emp_m, pct_unemp_t, 
           pct_unemp_f, pct_unemp_m, pct_self_emp_t, pct_self_emp_f, 
           pct_self_emp_m, pct_noc_0_t, pct_noc_0_f, pct_noc_0_m, pct_noc_1_t, 
           pct_noc_1_f, pct_noc_1_m, pct_noc_2_t, pct_noc_2_f, pct_noc_2_m, 
           pct_noc_3_t, pct_noc_3_f, pct_noc_3_m, pct_noc_4_t, pct_noc_4_f, 
           pct_noc_4_m, pct_noc_5_t, pct_noc_5_f, pct_noc_5_m, pct_noc_6_t, 
           pct_noc_6_f, pct_noc_6_m, pct_noc_7_t, pct_noc_7_f, pct_noc_7_m, 
           pct_noc_8_t, pct_noc_8_f, pct_noc_8_m, pct_noc_9_t, pct_noc_9_f, 
           pct_noc_9_m, pct_naics_11_t, pct_naics_11_f, pct_naics_11_m, 
           pct_naics_21_t, pct_naics_21_f, pct_naics_21_m, pct_naics_22_t, 
           pct_naics_22_f, pct_naics_22_m, pct_naics_23_t, pct_naics_23_f, 
           pct_naics_23_m, pct_naics_31to33_t, pct_naics_31to33_f, 
           pct_naics_31to33_m, pct_naics_41_t, pct_naics_41_f, pct_naics_41_m, 
           pct_naics_44to45_t, pct_naics_44to45_f, pct_naics_44to45_m, 
           pct_naics_48to49_t, pct_naics_48to49_f, pct_naics_48to49_m, 
           pct_naics_51_t, pct_naics_51_f, pct_naics_51_m, pct_naics_52_t, 
           pct_naics_52_f, pct_naics_52_m, pct_naics_53_t, pct_naics_53_f, 
           pct_naics_53_m, pct_naics_54_t, pct_naics_54_f, pct_naics_54_m, 
           pct_naics_55_t, pct_naics_55_f, pct_naics_55_m, pct_naics_56_t, 
           pct_naics_56_f, pct_naics_56_m, pct_naics_61_t, pct_naics_61_f, 
           pct_naics_61_m, pct_naics_62_t, pct_naics_62_f, pct_naics_62_m, 
           pct_naics_71_t, pct_naics_71_f, pct_naics_71_m, pct_naics_72_t, 
           pct_naics_72_f, pct_naics_72_m, pct_naics_81_t, pct_naics_81_f, 
           pct_naics_81_m, pct_naics_91_t, pct_naics_91_f, pct_naics_91_m) |>
    
    # Create a variable indicating the year
    mutate(year = 2011, .before = da_id_11) |>
  
    # Write the dataset in a CSV file to release
    write_csv("Data/casdohi_da11_can_2011_RELEASE.csv")
  
  # Create a version of CASDOHI 2016 to release
  casdohi_da16_can_2016_RELEASE <- casdohi_da16_can_2016_USE |>
    
    # Keep variables we need in CASDOHI 2016
    select(da_id_16, pr_id_16, pr_name_16, csd_id_16, csd_name_16, cd_id_16, 
           cma_id_16, ct_id_16, sactype_16, pop_t, pop_f, pop_m, pct_pop_f, 
           pop_density, mean_age_t, mean_age_f, mean_age_m, med_age_t, 
           med_age_f, med_age_m, pct_age_under5_t, pct_age_under5_f, 
           pct_age_under5_m, pct_age_under15_t, pct_age_under15_f, 
           pct_age_under15_m, pct_age_5to14_t, pct_age_5to14_f, pct_age_5to14_m, 
           pct_age_65plus_t, pct_age_65plus_f, pct_age_65plus_m, ratio_dep_t, 
           ratio_dep_f, ratio_dep_m, mean_hh_size, pct_mcl_t, pct_mcl_f, 
           pct_mcl_m, pct_nm_t, pct_nm_f, pct_nm_m, pct_sdw_t, pct_sdw_f, 
           pct_sdw_m, pct_single_parent_t, pct_single_parent_f, 
           pct_single_parent_m, pct_alone_t, pct_alone_f, pct_alone_m, 
           pct_no_eng_fr_t, pct_no_eng_fr_f, pct_no_eng_fr_m, med_ttinc_hh, 
           med_atinc_hh, mean_ttinc_hh, mean_atinc_hh, med_ttinc_ind_t, 
           med_ttinc_ind_f, med_ttinc_ind_m, mean_ttinc_ind_t, mean_ttinc_ind_f, 
           mean_ttinc_ind_m, med_atinc_ind_t, med_atinc_ind_f, med_atinc_ind_m, 
           mean_atinc_ind_t, mean_atinc_ind_f, mean_atinc_ind_m, 
           med_atinc_hh_adj, pct_pop_gtransfer_t, pct_pop_gtransfer_f, 
           pct_pop_gtransfer_m, pct_inc_gtransfer_t, pct_inc_gtransfer_f, 
           pct_inc_gtransfer_m, pct_lico_at_t, pct_lico_at_f, pct_lico_at_m, 
           pct_lim_at_t, pct_lim_at_f, pct_lim_at_m, pct_non_immig_t, 
           pct_non_immig_f, pct_non_immig_m, pct_immig_t, pct_immig_f, 
           pct_immig_m, pct_non_pr_t, pct_non_pr_f, pct_non_pr_m, 
           pct_recent_immig_t, pct_recent_immig_f, pct_recent_immig_m, 
           pct_indigenous_t, pct_indigenous_f, pct_indigenous_m, pct_vm_t, 
           pct_vm_f, pct_vm_m, pct_south_asian_t, pct_south_asian_f, 
           pct_south_asian_m, pct_east_asian_t, pct_east_asian_f, 
           pct_east_asian_m, pct_black_t, pct_black_f, pct_black_m, 
           pct_southeast_asian_t, pct_southeast_asian_f, pct_southeast_asian_m, 
           pct_latin_american_t, pct_latin_american_f, pct_latin_american_m, 
           pct_middle_eastern_t, pct_middle_eastern_f, pct_middle_eastern_m, 
           pct_apt_5plus, pct_major_repair, pct_mover_1y_t, pct_mover_1y_f, 
           pct_mover_1y_m, pct_mover_5y_t, pct_mover_5y_f, pct_mover_5y_m, 
           pct_not_suitable, pct_shelter_cost_30plus_tenant, 
           pct_shelter_cost_30plus_owner, pct_shelter_cost_30plus_tenant_owner, 
           med_dwelling_value, mean_dwelling_value, pct_owner, pct_renter, 
           pct_band_housing, pct_no_diploma_t, pct_no_diploma_f, 
           pct_no_diploma_m, pct_uni_diploma_t, pct_uni_diploma_f, 
           pct_uni_diploma_m, pct_cip_education_t, pct_cip_education_f, 
           pct_cip_education_m, pct_cip_art_t, pct_cip_art_f, pct_cip_art_m, 
           pct_cip_humanities_t, pct_cip_humanities_f, pct_cip_humanities_m, 
           pct_cip_social_t, pct_cip_social_f, pct_cip_social_m, 
           pct_cip_buisiness_t, pct_cip_buisiness_m, pct_cip_buisiness_f, 
           pct_cip_physical_t, pct_cip_physical_f, pct_cip_physical_m, 
           pct_cip_math_t, pct_cip_math_f, pct_cip_math_m, 
           pct_cip_architecture_t, pct_cip_architecture_f, 
           pct_cip_architecture_m, pct_cip_agriculture_t, pct_cip_agriculture_f, 
           pct_cip_agriculture_m, pct_cip_health_t, pct_cip_health_f, 
           pct_cip_health_m, pct_cip_personal_t, pct_cip_personal_f, 
           pct_cip_personal_m, pct_lf_participation_t, pct_lf_participation_f, 
           pct_lf_participation_m, pct_emp_t, pct_emp_f, pct_emp_m, pct_unemp_t, 
           pct_unemp_f, pct_unemp_m, pct_self_emp_t, pct_self_emp_f, 
           pct_self_emp_m, pct_noc_0_t, pct_noc_0_f, pct_noc_0_m, pct_noc_1_t, 
           pct_noc_1_f, pct_noc_1_m, pct_noc_2_t, pct_noc_2_f, pct_noc_2_m, 
           pct_noc_3_t, pct_noc_3_f, pct_noc_3_m, pct_noc_4_t, pct_noc_4_f, 
           pct_noc_4_m, pct_noc_5_t, pct_noc_5_f, pct_noc_5_m, pct_noc_6_t, 
           pct_noc_6_f, pct_noc_6_m, pct_noc_7_t, pct_noc_7_f, pct_noc_7_m, 
           pct_noc_8_t, pct_noc_8_f, pct_noc_8_m, pct_noc_9_t, pct_noc_9_f, 
           pct_noc_9_m, pct_naics_11_t, pct_naics_11_f, pct_naics_11_m, 
           pct_naics_21_t, pct_naics_21_f, pct_naics_21_m, pct_naics_22_t, 
           pct_naics_22_f, pct_naics_22_m, pct_naics_23_t, pct_naics_23_f, 
           pct_naics_23_m, pct_naics_31to33_t, pct_naics_31to33_f, 
           pct_naics_31to33_m, pct_naics_41_t, pct_naics_41_f, pct_naics_41_m, 
           pct_naics_44to45_t, pct_naics_44to45_f, pct_naics_44to45_m, 
           pct_naics_48to49_t, pct_naics_48to49_f, pct_naics_48to49_m, 
           pct_naics_51_t, pct_naics_51_f, pct_naics_51_m, pct_naics_52_t, 
           pct_naics_52_f, pct_naics_52_m, pct_naics_53_t, pct_naics_53_f, 
           pct_naics_53_m, pct_naics_54_t, pct_naics_54_f, pct_naics_54_m, 
           pct_naics_55_t, pct_naics_55_f, pct_naics_55_m, pct_naics_56_t, 
           pct_naics_56_f, pct_naics_56_m, pct_naics_61_t, pct_naics_61_f, 
           pct_naics_61_m, pct_naics_62_t, pct_naics_62_f, pct_naics_62_m, 
           pct_naics_71_t, pct_naics_71_f, pct_naics_71_m, pct_naics_72_t, 
           pct_naics_72_f, pct_naics_72_m, pct_naics_81_t, pct_naics_81_f, 
           pct_naics_81_m, pct_naics_91_t, pct_naics_91_f, pct_naics_91_m) |>
    
    # Create a variable indicating the year
    mutate(year = 2016, .before = da_id_16) |>
    
    # Write the dataset in a CSV file to release
    write_csv("Data/casdohi_da16_can_2016_RELEASE.csv")
  
  # Create a version of CASDOHI 2021 to release
  casdohi_da21_can_2021_RELEASE <- casdohi_da21_can_2021_USE |>
    
    # Keep variables we need in CASDOHI 2021
    select(da_id_21, pr_id_21, pr_name_21, csd_id_21, csd_name_21, cd_id_21, 
           cma_id_21, ct_id_21, sactype_21, pop_t, pop_f, pop_m, pct_pop_f, 
           pop_density, mean_age_t, mean_age_f, mean_age_m, med_age_t, 
           med_age_f, med_age_m, pct_age_under5_t, pct_age_under5_f, 
           pct_age_under5_m, pct_age_under15_t, pct_age_under15_f, 
           pct_age_under15_m, pct_age_5to14_t, pct_age_5to14_f, pct_age_5to14_m, 
           pct_age_65plus_t, pct_age_65plus_f, pct_age_65plus_m, ratio_dep_t, 
           ratio_dep_f, ratio_dep_m, mean_hh_size, pct_mcl_t, pct_mcl_f, 
           pct_mcl_m, pct_nm_t, pct_nm_f, pct_nm_m, pct_sdw_t, pct_sdw_f, 
           pct_sdw_m, pct_single_parent_t, pct_single_parent_f, 
           pct_single_parent_m, pct_alone_t, pct_alone_f, pct_alone_m, 
           pct_no_eng_fr_t, pct_no_eng_fr_f, pct_no_eng_fr_m, med_ttinc_hh, 
           med_atinc_hh, mean_ttinc_hh, mean_atinc_hh, med_ttinc_ind_t, 
           med_ttinc_ind_f, med_ttinc_ind_m, mean_ttinc_ind_t, mean_ttinc_ind_f, 
           mean_ttinc_ind_m, med_atinc_ind_t, med_atinc_ind_f, med_atinc_ind_m, 
           mean_atinc_ind_t, mean_atinc_ind_f, mean_atinc_ind_m, 
           med_atinc_hh_adj, pct_pop_gtransfer_t, pct_pop_gtransfer_f, 
           pct_pop_gtransfer_m, pct_inc_gtransfer_t, pct_inc_gtransfer_f, 
           pct_inc_gtransfer_m, pct_lico_at_t, pct_lico_at_f, pct_lico_at_m, 
           pct_lim_at_t, pct_lim_at_f, pct_lim_at_m, gini_index, 
           pct_non_immig_t, pct_non_immig_f, pct_non_immig_m, pct_immig_t, 
           pct_immig_f, pct_immig_m, pct_non_pr_t, pct_non_pr_f, pct_non_pr_m, 
           pct_recent_immig_t, pct_recent_immig_f, pct_recent_immig_m, 
           pct_indigenous_t, pct_indigenous_f, pct_indigenous_m, pct_vm_t, 
           pct_vm_f, pct_vm_m, pct_south_asian_t, pct_south_asian_f, 
           pct_south_asian_m, pct_east_asian_t, pct_east_asian_f, 
           pct_east_asian_m, pct_black_t, pct_black_f, pct_black_m, 
           pct_southeast_asian_t, pct_southeast_asian_f, pct_southeast_asian_m, 
           pct_latin_american_t, pct_latin_american_f, pct_latin_american_m, 
           pct_middle_eastern_t, pct_middle_eastern_f, pct_middle_eastern_m, 
           pct_apt_5plus, pct_major_repair, pct_mover_1y_t, pct_mover_1y_f, 
           pct_mover_1y_m, pct_mover_5y_t, pct_mover_5y_f, pct_mover_5y_m, 
           pct_not_suitable, pct_shelter_cost_30plus_tenant, 
           pct_shelter_cost_30plus_owner, pct_shelter_cost_30plus_tenant_owner, 
           med_dwelling_value, mean_dwelling_value, pct_owner, pct_renter, 
           pct_band_housing, pct_no_diploma_t, pct_no_diploma_f, 
           pct_no_diploma_m, pct_uni_diploma_t, pct_uni_diploma_f, 
           pct_uni_diploma_m, pct_cip_education_t, pct_cip_education_f, 
           pct_cip_education_m, pct_cip_art_t, pct_cip_art_f, pct_cip_art_m, 
           pct_cip_humanities_t, pct_cip_humanities_f, pct_cip_humanities_m, 
           pct_cip_social_t, pct_cip_social_f, pct_cip_social_m, 
           pct_cip_buisiness_t, pct_cip_buisiness_m, pct_cip_buisiness_f, 
           pct_cip_physical_t, pct_cip_physical_f, pct_cip_physical_m, 
           pct_cip_math_t, pct_cip_math_f, pct_cip_math_m, 
           pct_cip_architecture_t, pct_cip_architecture_f, 
           pct_cip_architecture_m, pct_cip_agriculture_t, pct_cip_agriculture_f, 
           pct_cip_agriculture_m, pct_cip_health_t, pct_cip_health_f, 
           pct_cip_health_m, pct_cip_personal_t, pct_cip_personal_f, 
           pct_cip_personal_m, pct_lf_participation_t, pct_lf_participation_f, 
           pct_lf_participation_m, pct_emp_t, pct_emp_f, pct_emp_m, pct_unemp_t, 
           pct_unemp_f, pct_unemp_m, pct_self_emp_t, pct_self_emp_f, 
           pct_self_emp_m, pct_noc_0_t, pct_noc_0_f, pct_noc_0_m, pct_noc_1_t, 
           pct_noc_1_f, pct_noc_1_m, pct_noc_2_t, pct_noc_2_f, pct_noc_2_m, 
           pct_noc_3_t, pct_noc_3_f, pct_noc_3_m, pct_noc_4_t, pct_noc_4_f, 
           pct_noc_4_m, pct_noc_5_t, pct_noc_5_f, pct_noc_5_m, pct_noc_6_t, 
           pct_noc_6_f, pct_noc_6_m, pct_noc_7_t, pct_noc_7_f, pct_noc_7_m, 
           pct_noc_8_t, pct_noc_8_f, pct_noc_8_m, pct_noc_9_t, pct_noc_9_f, 
           pct_noc_9_m, pct_naics_11_t, pct_naics_11_f, pct_naics_11_m, 
           pct_naics_21_t, pct_naics_21_f, pct_naics_21_m, pct_naics_22_t, 
           pct_naics_22_f, pct_naics_22_m, pct_naics_23_t, pct_naics_23_f, 
           pct_naics_23_m, pct_naics_31to33_t, pct_naics_31to33_f, 
           pct_naics_31to33_m, pct_naics_41_t, pct_naics_41_f, pct_naics_41_m, 
           pct_naics_44to45_t, pct_naics_44to45_f, pct_naics_44to45_m, 
           pct_naics_48to49_t, pct_naics_48to49_f, pct_naics_48to49_m, 
           pct_naics_51_t, pct_naics_51_f, pct_naics_51_m, pct_naics_52_t, 
           pct_naics_52_f, pct_naics_52_m, pct_naics_53_t, pct_naics_53_f, 
           pct_naics_53_m, pct_naics_54_t, pct_naics_54_f, pct_naics_54_m, 
           pct_naics_55_t, pct_naics_55_f, pct_naics_55_m, pct_naics_56_t, 
           pct_naics_56_f, pct_naics_56_m, pct_naics_61_t, pct_naics_61_f, 
           pct_naics_61_m, pct_naics_62_t, pct_naics_62_f, pct_naics_62_m, 
           pct_naics_71_t, pct_naics_71_f, pct_naics_71_m, pct_naics_72_t, 
           pct_naics_72_f, pct_naics_72_m, pct_naics_81_t, pct_naics_81_f, 
           pct_naics_81_m, pct_naics_91_t, pct_naics_91_f, pct_naics_91_m) |>
  
    # Create a variable indicating the year
    mutate(year = 2021, .before = da_id_21) |>
    
    # Write the dataset in a CSV file to release
    write_csv("Data/casdohi_da21_can_2021_RELEASE.csv")
  
  
  