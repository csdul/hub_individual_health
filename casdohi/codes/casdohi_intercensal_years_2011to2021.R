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
 
# Canadian Social Determinants of Health Indicators (CASDOHI) Project.      ####
# ============================================================================ #
# Summary: This R script uses the Census Profiles (CP) harmonized in R script 
#   "casdohi - censal years - 2011to2021 - 02" to estimate CASDOHI for 
#   intercensal years 2012 to 2015 and 2017 to 2020. To do so, we used 
#   Correspondence Files to join two adjacent harmonized CPs and then 
#   interpolated CPs for intercensal years. We use the estimated CPs for 
#   intercensal years to produce CASDOHI for those years. Additionally, we use 
#   attribute files to add larger geographic variables to the produced CASDOHIs.
#
# Programmer: Anousheh Marouzi
#
# Start date: December 4th, 2024
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

# LIST OF DATASETS IN THIS R SCRIPT                                        ####
# ---------------------------------------------------------------------------- #
# Inputs:
#   1. correspondence_file_2016_RAW.csv
#   2. correspondence_file_2021_RAW.csv
#   3. census_profile_da16_can_2016_HARM.csv
#   4. census_profile_da21_can_2021_HARM.csv
#   5. census_profile_da11_can_2011_HARM.csv
#   6. attribute_file_da11_2011_USE.csv
#   7. attribute_file_da16_2016_USE.csv
#
# Outputs:
#   1.  correspondence_file_2016_HARM.csv
#   2.  correspondence_file_2021_HARM.csv
#   3.  census_profile_da11_can_2016.csv
#   4.  census_profile_da16_can_2021.csv
#   5.  census_profile_da11_can_2012.csv
#   6.  census_profile_da11_can_2013.csv
#   7.  census_profile_da11_can_2014.csv
#   8.  census_profile_da11_can_2015.csv
#   9.  census_profile_da16_can_2017.csv
#   10. census_profile_da16_can_2018.csv
#   11. census_profile_da16_can_2019.csv
#   12. census_profile_da16_can_2020.csv
#   13. casdohi_da11_can_2012_MASTER.csv
#   14. casdohi_da11_can_2013_MASTER.csv
#   15. casdohi_da11_can_2014_MASTER.csv
#   16. casdohi_da11_can_2015_MASTER.csv
#   17. casdohi_da16_can_2017_MASTER.csv
#   18. casdohi_da16_can_2018_MASTER.csv
#   19. casdohi_da16_can_2019_MASTER.csv
#   20. casdohi_da16_can_2020_MASTER.csv
#   21. casdohi_da11_can_2012_RELEASE.csv
#   22. casdohi_da11_can_2013_RELEASE.csv
#   23. casdohi_da11_can_2014_RELEASE.csv
#   24. casdohi_da11_can_2015_RELEASE.csv
#   25. casdohi_da16_can_2017_RELEASE.csv
#   25. casdohi_da16_can_2018_RELEASE.csv
#   25. casdohi_da16_can_2019_RELEASE.csv
#   25. casdohi_da16_can_2020_RELEASE.csv
# ---------------------------------------------------------------------------- #

# TABLE OF CONTENTS                                                         ####
# ---------------------------------------------------------------------------- #
# 0. SETUP
# 1. HARMONIZE CORRESPONDENCE FILES, 2016 & 2021
#   1.1. HARMONIZE CORRESPONDENCE FILE, 2016
#   1.2. HARMONIZE CORRESPONDENCE FILE, 2021
# 2. JOIN HARMONIZED CENSUS PROFILE AND CORRESPONDENCE FILES, 2016 & 2021
#   2.1. JOIN CENSUS PROFILE AND CORRESPONDENCE FILE, 2016
#   2.2. JOIN CENSUS PROFILE AND CORRESPONDENCE FILE, 2021
# 3. ESTIMATE CP BASED ON PREVIOUS CENSUS BOUNDARY, 2016 & 2021 
#   3.1. AREAL INTERPOLATION OF CENSUS PROFILE 2016 ACCORDING TO DA 2011
#   3.2. AREAL INTERPOLATION OF CENSUS PROFILE 2021 ACCORDING TO DA 2016
# 4. LINEAR INTERPOLATION (EQ.1) & ESTIMATE INTERCENSAL CPs, 2011-2021
#   4.1 LINEAR INTERPOLATION, 2012 TO 2015
#   4.2 LINEAR INTERPOLATION, 2017 TO 2020
# 5. CONSTRUCT CASDOHI FOR INTERCENSAL YEARS, 2011 to 2021
#   5.1. CONSTRUCT CASDOHI FOR 2012 T0 2015 BASED ON 2011 DA
#     5.1.1. POPULATION AND AGE GROUPS
#     5.1.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT
#     5.1.3. EHNOCULTURAL INDICATORS
#     5.1.4. INCOME
#     5.1.5. EDUCATION
#     5.1.6. LABOUR FORCE
#     5.1.7. HOUSING
#   5.2. CONSTRUCT CASDOHI FOR 2017 T0 2020 BASED ON 2016 DA
#     5.2.1. POPULATION AND AGE GROUPS
#     5.2.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT
#     5.2.3. EHNOCULTURAL INDICATORS
#     5.2.4. INCOME
#     5.2.5. EDUCATION
#     5.2.6. LABOUR FORCE
#     5.2.7. HOUSING
# 6. CREATE THE FINAL VERSION OF CASDOHI FOR INTERCENSAL YEARS, 2011-2021
#   6.1. CREATE CASDOHI FOR RELEASE, 2012-2015
#     6.1.1. JOIN CASDOHI AND ATTRIBUTE FILE BASED ON DA_11, 2012-2015
#     6.1.2. CLEAN AND PREPARE THE FINAL VERSION OF CASDOHI, 2012-2015
#   6.2. CREATE CASDOHI FOR RELEASE, 2017-2020   
#     6.2.1. JOIN CASDOHI AND ATTRIBUTE FILE BASED ON DA_16, 2017-2020
#     6.2.2. CLEAN AND PREPARE THE FINAL VERSION OF CASDOHI, 2017-2020 
# ---------------------------------------------------------------------------- #

# VERSION 2                                                                 ####
# ---------------------------------------------------------------------------- #
# This version, first, estimate census profiles for intercensal years and then
# calculate CASDOHI for those years based on the estimated CPs. The first 
# version tried to estimate intercensal CASDOHIs directly from the calculated
# CASDOHI for censal years.
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

# 1. HARMONIZE CORRESPONDENCE FILES, 2016 & 2021                            ####
# ---------------------------------------------------------------------------- #
# This step harmonizes the raw correspondence files of 2016 and 2021 to be able
# to join census profiles of two adjacent censuses to interpolate intercensal 
# census profiles.

  # 1.1. HARMONIZE CORRESPONDENCE FILE, 2016                                ####
  # -------------------------------------------------------------------------- #

  # Import raw correspondence file 2016
  correspondence_file_2016_RAW <- 
    read_csv("Data/correspondence_file_2016_RAW.csv")
  
  # Count unique DAs in the file - total obs = 57,300
  n_distinct(correspondence_file_2016_RAW$"DAUID2016/ADIDU2016")  # 56,590
  n_distinct(correspondence_file_2016_RAW$"DAUID2011/ADIDU2011")  # 56,204
  
  # ** The number of DA 2016 is the same as the number of DAs that exist 
  # in CASDOHI. **
  
  # Harmonize correspondence file
  correspondence_file_2016_HARM <- correspondence_file_2016_RAW |>
    
    # Select variables we need and rename them
    select(da_id_16 = "DAUID2016/ADIDU2016",
           da_id_11 = "DAUID2011/ADIDU2011",
           area_w = "DA_area_percentage/AD_pourcentage_superficie") |>
    
    # Recode area coverage to act as a weight
    mutate(area_w = area_w/100) |>
    
    # Save CSV version of the file
    write_csv("Data/correspondence_file_2016_HARM.csv")
  
  # 1.2. HARMONIZE CORRESPONDENCE FILE, 2021                                ####
  # -------------------------------------------------------------------------- #
  
  # Set directory of raw 2016 correspondence file
  raw_path <- "Data/correspondence_file_2021_RAW.csv"
  
  # Import correspondence file 2021
  correspondence_file_2021_RAW <- read_csv(raw_path)
  
  # Count unique DAs in the file - total obs = 59,551
  n_distinct(correspondence_file_2021_RAW$"DAUID2021_ADIDU2021")  # 57,936
  n_distinct(correspondence_file_2021_RAW$"DAUID2016_ADIDU2016")  # 56,590
  
  # The number of DA 2021 is the same as the number of DAs that exist in CASDOHI
  
  # Harmonize correspondence file
  correspondence_file_2021_HARM <- correspondence_file_2021_RAW |>
    
    # Select variables we need and rename them
    select(da_id_21 = "DAUID2021_ADIDU2021",
           da_id_16 = "DAUID2016_ADIDU2016",
           area_w = "DAAREAPRCNT_ADPRCNTSUP") |>
    
    # Recode area coverage to act as a weight
    mutate(area_w = area_w/100) |>
    
    # Save CSV version of the file
    write_csv("Data/correspondence_file_2021_HARM.csv")
  
# 2. JOIN HARMONIZED CENSUS PROFILE AND CORRESPONDENCE FILES, 2016 & 2021   ####
# ---------------------------------------------------------------------------- #
# In this step, we join correspondence files to census profiles 2016 and 2021, 
# to translate DA_2016 to 2011 geographies, and DA_2021 to 2016 geographies. 
# This will later be used to interpolate census profile information for 
# intercensal years. 

  # 2.1. JOIN CENSUS PROFILE AND CORRESPONDENCE FILE, 2016                  ####
  # -------------------------------------------------------------------------- #  
  
  # Import harmonized census profile, 2016
  census_profile_da16_can_2016_HARM <- 
    read_csv("Data/census_profile_da16_can_2016_HARM.csv")

  # Join census profile and correspondence file, 2016 
  census_profile_da11_can_2016_MASTER <- 
    left_join(census_profile_da16_can_2016_HARM,
              correspondence_file_2016_HARM,
              by = "da_id_16")
  
  # Count unique DAs in the file - total obs = 57,300
  n_distinct(census_profile_da11_can_2016_MASTER$"da_id_16")  # 56,590
  n_distinct(census_profile_da11_can_2016_MASTER$"da_id_11")  # 56,204
  
  # 2.2. JOIN CENSUS PROFILE AND CORRESPONDENCE FILE, 2021                  ####
  # -------------------------------------------------------------------------- #  

  # Import harmonized census profile, 2021
  census_profile_da21_can_2021_HARM <- 
    read_csv("Data/census_profile_da21_can_2021_HARM.csv")
  
  # Join census profile and correspondence file, 2021
  census_profile_da16_can_2021_MASTER <- 
    left_join(census_profile_da21_can_2021_HARM,
              correspondence_file_2021_HARM,
              by = "da_id_21")

  # Count unique DAs in the file - total obs = 59,551
  n_distinct(census_profile_da16_can_2021_MASTER$"da_id_21")  # 57,936
  n_distinct(census_profile_da16_can_2021_MASTER$"da_id_16")  # 56,590

# 3. ESTIMATE CP BASED ON PREVIOUS CENSUS BOUNDARY, 2016 & 2021             ####
# ---------------------------------------------------------------------------- #
# In this section, we estimate the 2016 and 2021 Census Profiles according to 
# the DA boundary of its previous censuses (i.e. 2011 and 2016) using the 
# areal-weighting interpolation technique.
#  
# There are two major groups of variables that can be areally interpolated 
# using the areal weighting method. Extensive variables depend on the size of a 
# geographic unit, such as population counts, while intensive variables do not 
# depend on the size of a geographic unit, such as percentages and means.
#
# Census Profile contains counts (extensive) and means and percentages 
# (intensive), and medians, each of which are areally interpolated differently.
# For the medians, we employed the weighted medians of medians approach.

  # 3.1. AREAL INTERPOLATION OF CENSUS PROFILE 2016 ACCORDING TO DA 2011    ####
  # -------------------------------------------------------------------------- #
  
  # Save 2016 profile ids that are used in CASDOHI in a vector
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
  
  # Save 2016 profile ids that are counts/pop density (extensive) in a vector
  prof_ext_16 <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 41, 43, 52, 57, 59, 60, 64, 
                   65, 66, 67, 74, 78, 79, 80, 100, 104, 661, 668, 1140, 1141, 
                   1142, 1149, 1150, 1289, 1290, 1323, 1324, 1325, 1326, 1327, 
                   1328, 1329, 1330, 1331, 1332, 1333, 1334, 1617, 1618, 1619, 
                   1620, 1640, 1642, 1651, 1653, 1667, 1669, 1683, 1684, 1692, 
                   1713, 1715, 1717, 1720, 1729, 1737, 1741, 1747, 1752, 1760, 
                   1763, 1767, 1879, 1883, 1884, 1887, 1888, 1889, 1890, 1891, 
                   1892, 1893, 1894, 1895, 1896, 1897, 1900, 1901, 1902, 1903, 
                   1904, 1905, 1906, 1907, 1908, 1909, 1910, 1911, 1912, 1913, 
                   1914, 1915, 1916, 1917, 1918, 1919, 2230, 2232, 2239, 2241)
  
  # Save 2016 profile ids that are percentages and means (intensive) in a vector
  prof_int_16 <- c(35, 37, 39, 58, 674, 676, 690, 751, 752, 857, 867, 1673, 
                   1677, 1680, 1870, 1871, 1872)
  
  # Save 2016 profile ids that are medians in a vector
  prof_med_16 <- c(40, 663, 665, 742, 743, 1676)
  
  # Save sex breakdown in a vector
  sex <- c("t", "f", "m")
  
  # Create a new dataset that contains 2016 profiles by 2011 DA (We change this 
  # dataset in several step. To control for the process and to have 
  # check-points, we name this datasets in each step by _s# to differentiate 
  # them.)
  census_profile_da11_can_2016_s1 <- census_profile_da11_can_2016_MASTER |>
    
    # Create a variable for population
    mutate(pop_t = p_1_t,
           pop_f = p_8_f,
           pop_m = p_8_m)

  # Calculate a section of extensive variable allocated to each DA16 to be
  # summed up when collapsing to DA11 level to get the variable estimate by DA11
  for (id in prof_inc_16) {
    for (s in sex) {
      
      # Save the name of profile variable in a vector
      var_name <- paste0("p_", id, "_" , s)
    
      # Create variable for what is in the parantheses in eq. 2
      census_profile_da11_can_2016_s1 <- census_profile_da11_can_2016_s1 |>
        mutate(!!paste0("p_", id, "_", s, "_eq2") := 
                 !!sym(var_name) * area_w) |>
  
        # Create what is in parentheses in the numerator of eq. 3
        mutate(!!paste0("p_", id, "_", s, "_eq3_num") := 
               .data[[paste0("pop_", s)]] * !!sym(var_name) * area_w)

    }
  }
  
  # Calculate the areally-weighted population, which will be 
  # summed up to generate Eq.3's denominator and the last section of Eq.4
  for (s in sex) {
  
    census_profile_da11_can_2016_s1 <- census_profile_da11_can_2016_s1 |>
    
      mutate(!!paste0("pop_", s, "_w") := .data[[paste0("pop_", s)]] * area_w)
  }
  
  # Save the dataset in a new one (step 2)
  census_profile_da11_can_2016_s2 <- census_profile_da11_can_2016_s1
  
  # Employ the weighted median of medians approach by incorporating 
  # area-weighting method
  for (id in prof_inc_16) {
    for (s in sex) {
      
      var_name <- paste0("p_", id, "_", s)
      
      census_profile_da11_can_2016_s2 <- census_profile_da11_can_2016_s2 |>
        
        # Sort data by median variable per DA11
        group_by(da_id_11) |>
        arrange(!!sym(var_name), .by_group = TRUE) |>
        
        # Calculate cumulative areally-weighted population per DA11
        mutate(!!paste0("pop_", id, "_", s, "_w_cum") := 
                 cumsum(.data[[paste0("pop_", s, "_w")]])) |>
        
        # Calculate population of each DA11
        mutate(!!paste0("pop_", id, "_", s, "_w_tot") := 
                 sum(.data[[paste0("pop_", s, "_w")]])) |>
        
        # Calculate the proportion of cumulative pop over total pop
        mutate(!!paste0("pop_", id, "_", s, "_w_frac") := 
                 .data[[paste0("pop_", id, "_", s, "_w_cum")]] /
                 .data[[paste0("pop_", id, "_", s, "_w_tot")]]) |>
        
        # Flag the first frac per DA11 is greater than 0.5
        mutate(temp_flag = ifelse(
          .data[[paste0("pop_", id, "_", s, "_w_frac")]] > 0.5, 1, 0)) |>   
        
        mutate(temp_flag_cum = cumsum(temp_flag)) |>
        
        # Create a variable for the median 
        mutate(!!paste0("p_", id, "_", s, "_med") := 
                 ifelse(temp_flag_cum == 1, .data[[var_name]], NA)) |>
        
        # Impute the NAs with the nonmissing per DA11
        fill(!!paste0("p_", id, "_", s, "_med"), .direction = "downup") |>
        
        ungroup()
      
    }
  }
      
  # Save the dataset in a new one (step 3)  
  census_profile_da11_can_2016_s3 <- census_profile_da11_can_2016_s2
  
  # Create a list to save the summarized dataset to be appended later
  cp_da11_can_2016_summary_list <- list()
  
  # Collapse to DA 2011 to calculate different parts of Eq. 2, 3, & 4
  for (id in prof_inc_16) {
    for (s in sex) {
      
      p_id_s <- paste0("p_", id, "_" , s)
      p_id_s_med <- paste0("p_", id, "_" , s, "_med")
      p_id_s_eq2 <- paste0("p_", id, "_" , s, "_eq2")
      p_id_s_eq3_num <- paste0("p_", id, "_" , s, "_eq3_num")
      pop_s_w <- paste0("pop_", s, "_w")
      
      p_id_s_eq2_sum <- paste0("p_", id, "_", s, "_eq2_sum")
      p_id_s_eq3_num_sum <- paste0("p_", id, "_" , s, "_eq3_num_sum")
      pop_s_w_sum <- paste0("pop_", s, "_w_sum_del")      
      
      cp_da11_can_2016_summary <- census_profile_da11_can_2016_s3 |>
      group_by(da_id_11) |>
        summarise(!!p_id_s_med := max(!!sym(p_id_s_med), na.rm = TRUE),
                  !!p_id_s_eq2_sum := sum(!!sym(p_id_s_eq2), na.rm = TRUE), 
                  !!p_id_s_eq3_num_sum := sum(!!sym(p_id_s_eq3_num), 
                                              na.rm = TRUE),
                  !!pop_s_w_sum := sum(!!sym(pop_s_w), na.rm = TRUE), 
                  .groups = "drop"
                  )
    
      cp_da11_can_2016_summary_list[[length(cp_da11_can_2016_summary_list)
                                     + 1]] <-
        cp_da11_can_2016_summary
    
    }
  }
  
  # Join the summary datasets that are saved in a list to produce the final
  # dataset
  census_profile_da11_can_2016_s4 <- reduce(cp_da11_can_2016_summary_list,
                                         full_join,
                                         by = "da_id_11")
  
  # Drop the duplicate variables for the weighted population
  for (s in sex) {
    
    census_profile_da11_can_2016_s4 <- census_profile_da11_can_2016_s4 |>
    mutate(!!paste("pop_", s, "_w_sum") := 
             .data[[paste0("pop_", s, "_w_sum_del.x")]])
    
  }

  census_profile_da11_can_2016 <- census_profile_da11_can_2016_s4 |>
  select(-starts_with("pop_t_w_sum_del"),
         -starts_with("pop_f_w_sum_del"),
         -starts_with("pop_m_w_sum_del")
         )
  
  # Clean all column names: remove any accidental internal spaces
  names(census_profile_da11_can_2016) <- 
    str_replace_all(names(census_profile_da11_can_2016), "\\s+", "")
  
  # Save extensive variables (counts) in a new variable
  for (id in prof_ext_16) {
    for (s in sex) {
      
      # Generate a new variable with a harmonized name for counts
      census_profile_da11_can_2016 <- census_profile_da11_can_2016 |>
        mutate(!!paste0("p_", id, "_", s, "_11") :=
                 .data[[paste0("p_", id, "_" , s, "_eq2_sum")]])
      
    } 
  }
  
  # Calculate intensive variables (means and percentages)
  for (id in prof_int_16) {
    for (s in sex) {
      
      # Calculate intensive variables
      census_profile_da11_can_2016 <- census_profile_da11_can_2016 |>
        mutate(!!paste0("p_", id, "_", s, "_11") :=
                 .data[[paste0("p_", id, "_" , s, "_eq3_num_sum")]] /
                 .data[[paste0("pop_", s, "_w_sum")]])
      
    } 
  }
  
  # Save medians, which are already calculated, in a new variable
  for (id in prof_med_16) {
    for (s in sex) {
      
      # Generate a new variable with a harmonized name for medians
      census_profile_da11_can_2016 <- census_profile_da11_can_2016 |>
        mutate(!!paste0("p_", id, "_", s, "_11") := 
                 .data[[paste0("p_", id, "_" , s, "_med")]])
      
    }
  }

  # VALIDATION - Calculate the population of 2016 by 2011 and 2016 DAs to ensure 
  # accuracy. The following should be the same:

  sum(census_profile_da11_can_2016$p_1_t_11, na.rm = TRUE) # 35,151,728
  
  test_11 <- census_profile_da11_can_2016 |>
    group_by(da_id_11)|>
    summarise(pop = first(p_1_t_11))
  sum(test_11$pop, na.rm = TRUE) # 35,151,728
  
  test_16 <- census_profile_da11_can_2016_s1 |>
    group_by(da_id_16)|>
    summarise(pop = first(p_1_t))
  sum(test_16$pop, na.rm = TRUE) # 35,151,728  
  
  # Keep only profiles by 2011 DA boundaries
  census_profile_da11_can_2016 <- census_profile_da11_can_2016 |>
    select(ends_with("_11"))
  
  # Save CSV file
  write_csv(census_profile_da11_can_2016, 
            "Data/census_profile_da11_can_2016.csv")

  # 3.2. AREAL INTERPOLATION OF CENSUS PROFILE 2021 ACCORDING TO DA 2016    ####
  # -------------------------------------------------------------------------- #  
  # Save 2021 profile ids that are used in CASDOHI in a vector
  prof_inc_21 <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 35, 37, 39, 40, 41, 47, 51, 
                   57, 58, 59, 67, 68, 69, 70, 78, 86, 87, 88, 89, 111, 113, 
                   115, 120, 128, 130, 151, 243, 244, 252, 253, 345, 360, 381, 
                   383, 387, 1402, 1403, 1414, 1415, 1416, 1417, 1437, 1439, 
                   1449, 1451, 1465, 1467, 1484, 1488, 1489, 1492, 1527, 1528, 
                   1529, 1536, 1537, 1683, 1684, 1685, 1686, 1687, 1688, 1689, 
                   1690, 1691, 1692, 1693, 1694, 1974, 1976, 1983, 1985, 1993, 
                   1998, 2008, 2030, 2032, 2034, 2037, 2046, 2054, 2058, 2064, 
                   2069, 2077, 2080, 2086, 2228, 2229, 2230, 2237, 2245, 2246, 
                   2249, 2250, 2251, 2252, 2253, 2254, 2255, 2256, 2257, 2258, 
                   2259, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 
                   2271, 2272, 2273, 2274, 2275, 2276, 2277, 2278, 2279, 2280, 
                   2281)
  
  # Save 2021 prof ids that are counts and pop density (extensive) in a vector
  prof_ext_21 <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 41, 47, 51, 58, 59, 67, 68, 
                   69, 70, 78, 86, 87, 88, 89, 111, 120, 383, 387, 1402, 1403, 
                   1414, 1415, 1416, 1417, 1437, 1439, 1449, 1451, 1465, 1467, 
                   1527, 1528, 1529, 1536, 1537, 1683, 1684, 1685, 1686, 1687, 
                   1688, 1689, 1690, 1691, 1692, 1693, 1694, 1974, 1976, 1983, 
                   1985, 1993, 1998, 2008, 2030, 2032, 2034, 2037, 2046, 2054, 
                   2058, 2064, 2069, 2077, 2080, 2086, 2237, 2245, 2246, 2249, 
                   2250, 2251, 2252, 2253, 2254, 2255, 2256, 2257, 2258, 2259, 
                   2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 
                   2272, 2273, 2274, 2275, 2276, 2277, 2278, 2279, 2280, 2281)
  
  # Save 2021 profile ids that are percentages and means (intensive) in a vector
  prof_int_21 <- c(35, 37, 39, 57, 128, 130, 151, 252, 253, 345, 360, 1484, 
                   1489, 1492, 2228, 2229, 2230)
  
  # Save 2021 profile ids that are medians in a vector
  prof_med_21 <- c(40, 113, 115, 243, 244, 1488)
  
  # Create a new dataset that contains 2021 profiles by 2016 DA (We change this 
  # dataset in several step. To control for the process and to have 
  # check-points, we name this datasets in each step by _s# to differentiate 
  # them.)
  census_profile_da16_can_2021_s1 <- census_profile_da16_can_2021_MASTER |>
    
    # Create a variable for population
    mutate(pop_t = p_1_t,
           pop_f = p_8_f,
           pop_m = p_8_m)
  
  # Calculate a section of extensive variable allocated to each DA16 to be
  # summed up when collapsing to DA16 level to get the variable estimate by DA16
  for (id in prof_inc_21) {
    for (s in sex) {
      
      # Save the name of profile variable in a vector
      var_name <- paste0("p_", id, "_" , s)
      
      # Create variable for what is in the parantheses in eq. 2
      census_profile_da16_can_2021_s1 <- census_profile_da16_can_2021_s1 |>
        mutate(!!paste0("p_", id, "_", s, "_eq2") := !!sym(var_name) * area_w) |>
        
        # Create what is in parentheses in the numerator of eq. 3
        mutate(!!paste0("p_", id, "_", s, "_eq3_num") := 
                 .data[[paste0("pop_", s)]] * !!sym(var_name) * area_w)
      
    }
  }
  
  # Calculate the areally-weighted population, which will be 
  # summed up to generate Eq.3's denominator and the last section of Eq.4
  for (s in sex) {
    
    census_profile_da16_can_2021_s1 <- census_profile_da16_can_2021_s1 |>
      
      mutate(!!paste0("pop_", s, "_w") := .data[[paste0("pop_", s)]] * area_w)
  }
  
  # Save the dataset in a new one (step 2)
  census_profile_da16_can_2021_s2 <- census_profile_da16_can_2021_s1
  
  # Employ the weighted median of medians approach by incorporating 
  # area-weighting method
  for (id in prof_inc_21) {
    for (s in sex) {
      
      var_name <- paste0("p_", id, "_", s)
      
      census_profile_da16_can_2021_s2 <- census_profile_da16_can_2021_s2 |>
        
        # Sort data by median variable per DA16
        group_by(da_id_16) |>
        arrange(!!sym(var_name), .by_group = TRUE) |>
        
        # Calculate cumulative areally-weighted population per DA16
        mutate(!!paste0("pop_", id, "_", s, "_w_cum") := 
                 cumsum(.data[[paste0("pop_", s, "_w")]])) |>
        
        # Calculate population of each DA16
        mutate(!!paste0("pop_", id, "_", s, "_w_tot") := 
                 sum(.data[[paste0("pop_", s, "_w")]])) |>
        
        # Calculate the proportion of cumulative pop over total pop
        mutate(!!paste0("pop_", id, "_", s, "_w_frac") := 
                 .data[[paste0("pop_", id, "_", s, "_w_cum")]] /
                 .data[[paste0("pop_", id, "_", s, "_w_tot")]]) |>
        
        # Flag the first frac per DA16 is greater than 0.5
        mutate(temp_flag = ifelse(
          .data[[paste0("pop_", id, "_", s, "_w_frac")]] > 0.5, 1, 0)) |>   
        
        mutate(temp_flag_cum = cumsum(temp_flag)) |>
        
        # Create a variable for the median 
        mutate(!!paste0("p_", id, "_", s, "_med") := 
                 ifelse(temp_flag_cum == 1, .data[[var_name]], NA)) |>
        
        # Impute the NAs with the nonmissing per DA16
        fill(!!paste0("p_", id, "_", s, "_med"), .direction = "downup") |>
        
        ungroup()
      
    }
  }
  
  # Save the dataset in a new one (step 3)  
  census_profile_da16_can_2021_s3 <- census_profile_da16_can_2021_s2
  
  # Create a list to save the summarized dataset to be appended later
  cp_da16_can_2021_summary_list <- list()
  
  # Collapse to DA 2016 to calculate different parts of Eq. 2, 3, & 4
  for (id in prof_inc_21) {
    for (s in sex) {
      
      p_id_s <- paste0("p_", id, "_" , s)
      p_id_s_med <- paste0("p_", id, "_" , s, "_med")
      p_id_s_eq2 <- paste0("p_", id, "_" , s, "_eq2")
      p_id_s_eq3_num <- paste0("p_", id, "_" , s, "_eq3_num")
      pop_s_w <- paste0("pop_", s, "_w")
      
      p_id_s_eq2_sum <- paste0("p_", id, "_", s, "_eq2_sum")
      p_id_s_eq3_num_sum <- paste0("p_", id, "_" , s, "_eq3_num_sum")
      pop_s_w_sum <- paste0("pop_", s, "_w_sum_del")      
      
      cp_da16_can_2021_summary <- census_profile_da16_can_2021_s3 |>
        group_by(da_id_16) |>
        summarise(!!p_id_s_med := max(!!sym(p_id_s_med), na.rm = TRUE),
                  !!p_id_s_eq2_sum := sum(!!sym(p_id_s_eq2), na.rm = TRUE), 
                  !!p_id_s_eq3_num_sum := sum(!!sym(p_id_s_eq3_num), na.rm = TRUE),
                  !!pop_s_w_sum := sum(!!sym(pop_s_w), na.rm = TRUE), 
                  .groups = "drop"
        )
      
      cp_da16_can_2021_summary_list[[length(cp_da16_can_2021_summary_list) + 1]] <-
        cp_da16_can_2021_summary
      
    }
  }
  
  # Join the summary datasets that are saved in a list to produce the final
  # dataset
  census_profile_da16_can_2021_s4 <- reduce(cp_da16_can_2021_summary_list,
                                            full_join,
                                            by = "da_id_16"
  )
  
  # Drop the duplicate variables for the weighted population
  for (s in sex) {
    
    census_profile_da16_can_2021_s4 <- census_profile_da16_can_2021_s4 |>
      mutate(!!paste("pop_", s, "_w_sum") := 
               .data[[paste0("pop_", s, "_w_sum_del.x")]])
    
  }
  
  census_profile_da16_can_2021 <- census_profile_da16_can_2021_s4 |>
    select(-starts_with("pop_t_w_sum_del"),
           -starts_with("pop_f_w_sum_del"),
           -starts_with("pop_m_w_sum_del")
    )
  
  # Clean all column names: remove any accidental internal spaces
  names(census_profile_da16_can_2021) <- 
    str_replace_all(names(census_profile_da16_can_2021), "\\s+", "")
  
  # Save extensive variables (counts) in a new variable
  for (id in prof_ext_21) {
    for (s in sex) {
      
      # Generate a new variable with a harmonized name for counts
      census_profile_da16_can_2021 <- census_profile_da16_can_2021 |>
        mutate(!!paste0("p_", id, "_", s, "_16") :=
                 .data[[paste0("p_", id, "_" , s, "_eq2_sum")]])
      
    } 
  }
  
  # Calculate intensive variables (means and percentages)
  for (id in prof_int_21) {
    for (s in sex) {
      
      # Calculate intensive variables
      census_profile_da16_can_2021 <- census_profile_da16_can_2021 |>
        mutate(!!paste0("p_", id, "_", s, "_16") :=
                 .data[[paste0("p_", id, "_" , s, "_eq3_num_sum")]] /
                 .data[[paste0("pop_", s, "_w_sum")]])
      
    } 
  }
  
  # Save medians, which are already calculated, in a new variable
  for (id in prof_med_21) {
    for (s in sex) {
      
      # Generate a new variable with a harmonized name for medians
      census_profile_da16_can_2021 <- census_profile_da16_can_2021 |>
        mutate(!!paste0("p_", id, "_", s, "_16") := 
                 .data[[paste0("p_", id, "_" , s, "_med")]])
      
    }
  }
  
  # VALIDATION - Calculate the population of 2021 by 2016 and 2021 DAs to ensure 
  # accuracy. The following should be the same:
  
  sum(census_profile_da16_can_2021$p_1_t_16, na.rm = TRUE) # 36,991,981
  
  test_16 <- census_profile_da16_can_2021 |>
    group_by(da_id_16)|>
    summarise(pop = first(p_1_t_16))
  sum(test_16$pop, na.rm = TRUE) # 36,991,981
  
  test_21 <- census_profile_da16_can_2021_s1 |>
    group_by(da_id_21)|>
    summarise(pop = first(p_1_t))
  sum(test_21$pop, na.rm = TRUE) # 36,991,981
  
  # Keep only profiles 2016 DA boundaries
  census_profile_da16_can_2021 <- census_profile_da16_can_2021 |>
    select(ends_with("_16"))
  
  # Save CSV file
  write_csv(census_profile_da16_can_2021, 
            "Data/census_profile_da16_can_2021.csv")
  
# 4. LINEAR INTERPOLATION (EQ.1) & ESTIMATE INTERCENSAL CPs, 2011-2021      ####  
# ---------------------------------------------------------------------------- #  
# In this step, we use the linear interpolation approach described in the paper
# (eq. 1) to interpolate census profiles for years 2012-2015 and 2017-2020.
  
# Clear the R environment  
rm(list=ls(all=TRUE))   
  
  # 4.1 LINEAR INTERPOLATION, 2012 TO 2015                                  ####  
  # -------------------------------------------------------------------------- # 
  # In this section, we estimate harmonized census profiles between years 2011
  # and 2016 based on DA 2011 boundaries using the linear interpolation 
  # technique.
  
  # Import harmonized CP 2011 based on DA 2011
  census_profile_da11_can_2011 <- 
    read_csv("Data/census_profile_da11_can_2011_HARM.csv")
  
  # Import harmonized CP 2016 based on DA 2011
  census_profile_da11_can_2016 <- 
    read_csv("Data/census_profile_da11_can_2016.csv")
  
  # Save sex breakdown in a vector
  sex <- c("t", "f", "m")
  
  # Harmonize 2011 CP according to 2016 CP
  for (s in sex) {
  
    census_profile_da11_can_2011 <- census_profile_da11_can_2011 |>
    
      # create profiles that exist in 2016 CP but missing in 2011 CP
      mutate(!!paste0("p_9_", s, "_2011") := 
               .data[[paste0("p_10_", s)]] +
               .data[[paste0("p_11_", s)]] +
               .data[[paste0("p_12_", s)]],
             
             !!paste0("p_13_", s, "_2011") := 
               .data[[paste0("p_90_", s)]] +
               .data[[paste0("p_91_", s)]] +
               .data[[paste0("p_92_", s)]] +
               .data[[paste0("p_93_", s)]] +
               .data[[paste0("p_94_", s)]] +
               .data[[paste0("p_95_", s)]] +
               .data[[paste0("p_96_", s)]] +
               .data[[paste0("p_97_", s)]] +
               .data[[paste0("p_98_", s)]],
             
             !!paste0("p_24_", s, "_2011") := 
               .data[[paste0("p_25_", s)]] +
               .data[[paste0("p_26_", s)]] +
               .data[[paste0("p_27_", s)]] +
               .data[[paste0("p_28_", s)]] +
               .data[[paste0("p_29_", s)]],
             
             !!paste0("p_35_", s, "_2011") := 
               .data[[paste0("p_9_", s, "_2011")]] /
               .data[[paste0("p_8_", s)]],
             
             !!paste0("p_37_", s, "_2011") := 
               .data[[paste0("p_24_", s, "_2011")]] /
               .data[[paste0("p_8_", s)]]) |>
      
      # Rename 2011 profiles to their 2016 profile counterparts
      rename( !!paste0("p_43_", s, "_2011") := all_of(paste0("p_47_", s)),
              !!paste0("p_52_", s, "_2011") := all_of(paste0("p_51_", s)),
              !!paste0("p_57_", s, "_2011") := all_of(paste0("p_89_", s)),
              !!paste0("p_58_", s, "_2011") := all_of(paste0("p_57_", s)),
              !!paste0("p_59_", s, "_2011") := all_of(paste0("p_58_", s)),
              !!paste0("p_60_", s, "_2011") := all_of(paste0("p_59_", s)),
              !!paste0("p_64_", s, "_2011") := all_of(paste0("p_67_", s)),
              !!paste0("p_65_", s, "_2011") := all_of(paste0("p_68_", s)),
              !!paste0("p_66_", s, "_2011") := all_of(paste0("p_69_", s)),
              !!paste0("p_67_", s, "_2011") := all_of(paste0("p_70_", s)),
              !!paste0("p_74_", s, "_2011") := all_of(paste0("p_78_", s)),
              !!paste0("p_78_", s, "_2011") := all_of(paste0("p_86_", s)),
              !!paste0("p_79_", s, "_2011") := all_of(paste0("p_87_", s)),
              !!paste0("p_80_", s, "_2011") := all_of(paste0("p_88_", s)),
              !!paste0("p_100_", s, "_2011") := all_of(paste0("p_383_", s)),
              !!paste0("p_104_", s, "_2011") := all_of(paste0("p_387_", s)),
              !!paste0("p_663_", s, "_2011") := all_of(paste0("p_113_", s)),
              !!paste0("p_665_", s, "_2011") := all_of(paste0("p_115_", s)),
              !!paste0("p_674_", s, "_2011") := all_of(paste0("p_128_", s)),
              !!paste0("p_676_", s, "_2011") := all_of(paste0("p_130_", s)),
              !!paste0("p_690_", s, "_2011") := all_of(paste0("p_151_", s)),
              !!paste0("p_857_", s, "_2011") := all_of(paste0("p_345_", s)),
              !!paste0("p_1140_", s, "_2011") := all_of(paste0("p_1527_", s)),
              !!paste0("p_1141_", s, "_2011") := all_of(paste0("p_1528_", s)),
              !!paste0("p_1142_", s, "_2011") := all_of(paste0("p_1529_", s)),
              !!paste0("p_1149_", s, "_2011") := all_of(paste0("p_1536_", s)),
              !!paste0("p_1150_", s, "_2011") := all_of(paste0("p_1537_", s)),
              !!paste0("p_1289_", s, "_2011") := all_of(paste0("p_1402_", s)),
              !!paste0("p_1290_", s, "_2011") := all_of(paste0("p_1403_", s)),
              !!paste0("p_1323_", s, "_2011") := all_of(paste0("p_1683_", s)),
              !!paste0("p_1324_", s, "_2011") := all_of(paste0("p_1684_", s)),
              !!paste0("p_1325_", s, "_2011") := all_of(paste0("p_1685_", s)),
              !!paste0("p_1326_", s, "_2011") := all_of(paste0("p_1686_", s)),
              !!paste0("p_1327_", s, "_2011") := all_of(paste0("p_1687_", s)),
              !!paste0("p_1328_", s, "_2011") := all_of(paste0("p_1688_", s)),
              !!paste0("p_1329_", s, "_2011") := all_of(paste0("p_1689_", s)),
              !!paste0("p_1330_", s, "_2011") := all_of(paste0("p_1690_", s)),
              !!paste0("p_1331_", s, "_2011") := all_of(paste0("p_1691_", s)),
              !!paste0("p_1332_", s, "_2011") := all_of(paste0("p_1692_", s)),
              !!paste0("p_1333_", s, "_2011") := all_of(paste0("p_1693_", s)),
              !!paste0("p_1334_", s, "_2011") := all_of(paste0("p_1694_", s)),
              !!paste0("p_1683_", s, "_2011") := all_of(paste0("p_1998_", s)),
              !!paste0("p_1684_", s, "_2011") := all_of(paste0("p_1993_", s)),
              !!paste0("p_1692_", s, "_2011") := all_of(paste0("p_2008_", s)),
              !!paste0("p_1713_", s, "_2011") := all_of(paste0("p_2030_", s)),
              !!paste0("p_1715_", s, "_2011") := all_of(paste0("p_2032_", s)),
              !!paste0("p_1717_", s, "_2011") := all_of(paste0("p_2034_", s)),
              !!paste0("p_1720_", s, "_2011") := all_of(paste0("p_2037_", s)),
              !!paste0("p_1729_", s, "_2011") := all_of(paste0("p_2046_", s)),
              !!paste0("p_1737_", s, "_2011") := all_of(paste0("p_2054_", s)),
              !!paste0("p_1741_", s, "_2011") := all_of(paste0("p_2058_", s)),
              !!paste0("p_1747_", s, "_2011") := all_of(paste0("p_2064_", s)),
              !!paste0("p_1752_", s, "_2011") := all_of(paste0("p_2069_", s)),
              !!paste0("p_1760_", s, "_2011") := all_of(paste0("p_2077_", s)),
              !!paste0("p_1763_", s, "_2011") := all_of(paste0("p_2080_", s)),
              !!paste0("p_1767_", s, "_2011") := all_of(paste0("p_2086_", s)),
              !!paste0("p_1870_", s, "_2011") := all_of(paste0("p_2228_", s)),
              !!paste0("p_1871_", s, "_2011") := all_of(paste0("p_2229_", s)),
              !!paste0("p_1872_", s, "_2011") := all_of(paste0("p_2230_", s)),
              !!paste0("p_1879_", s, "_2011") := all_of(paste0("p_2237_", s)),
              !!paste0("p_1883_", s, "_2011") := all_of(paste0("p_2245_", s)),
              !!paste0("p_1884_", s, "_2011") := all_of(paste0("p_2246_", s)),
              !!paste0("p_1887_", s, "_2011") := all_of(paste0("p_2249_", s)),
              !!paste0("p_1888_", s, "_2011") := all_of(paste0("p_2250_", s)),
              !!paste0("p_1889_", s, "_2011") := all_of(paste0("p_2251_", s)),
              !!paste0("p_1890_", s, "_2011") := all_of(paste0("p_2252_", s)),
              !!paste0("p_1891_", s, "_2011") := all_of(paste0("p_2253_", s)),
              !!paste0("p_1892_", s, "_2011") := all_of(paste0("p_2254_", s)),
              !!paste0("p_1893_", s, "_2011") := all_of(paste0("p_2255_", s)),
              !!paste0("p_1894_", s, "_2011") := all_of(paste0("p_2256_", s)),
              !!paste0("p_1895_", s, "_2011") := all_of(paste0("p_2257_", s)),
              !!paste0("p_1896_", s, "_2011") := all_of(paste0("p_2258_", s)),
              !!paste0("p_1897_", s, "_2011") := all_of(paste0("p_2259_", s)),
              !!paste0("p_1900_", s, "_2011") := all_of(paste0("p_2262_", s)),
              !!paste0("p_1901_", s, "_2011") := all_of(paste0("p_2263_", s)),
              !!paste0("p_1902_", s, "_2011") := all_of(paste0("p_2264_", s)),
              !!paste0("p_1903_", s, "_2011") := all_of(paste0("p_2265_", s)),
              !!paste0("p_1904_", s, "_2011") := all_of(paste0("p_2266_", s)),
              !!paste0("p_1905_", s, "_2011") := all_of(paste0("p_2267_", s)),
              !!paste0("p_1906_", s, "_2011") := all_of(paste0("p_2268_", s)),
              !!paste0("p_1907_", s, "_2011") := all_of(paste0("p_2269_", s)),
              !!paste0("p_1908_", s, "_2011") := all_of(paste0("p_2270_", s)),
              !!paste0("p_1909_", s, "_2011") := all_of(paste0("p_2271_", s)),
              !!paste0("p_1910_", s, "_2011") := all_of(paste0("p_2272_", s)),
              !!paste0("p_1911_", s, "_2011") := all_of(paste0("p_2273_", s)),
              !!paste0("p_1912_", s, "_2011") := all_of(paste0("p_2274_", s)),
              !!paste0("p_1913_", s, "_2011") := all_of(paste0("p_2275_", s)),
              !!paste0("p_1914_", s, "_2011") := all_of(paste0("p_2276_", s)),
              !!paste0("p_1915_", s, "_2011") := all_of(paste0("p_2277_", s)),
              !!paste0("p_1916_", s, "_2011") := all_of(paste0("p_2278_", s)),
              !!paste0("p_1917_", s, "_2011") := all_of(paste0("p_2279_", s)),
              !!paste0("p_1918_", s, "_2011") := all_of(paste0("p_2280_", s)),
              !!paste0("p_1919_", s, "_2011") := all_of(paste0("p_2281_", s)),
              !!paste0("p_2230_", s, "_2011") := all_of(paste0("p_1974_", s)),
              !!paste0("p_2232_", s, "_2011") := all_of(paste0("p_1976_", s)),
              !!paste0("p_2239_", s, "_2011") := all_of(paste0("p_1983_", s)),
              !!paste0("p_2241_", s, "_2011") := all_of(paste0("p_1985_", s))
              ) |>
    
      # Add "_2011" at the end of variables we need and lacking it
      rename(!!paste0("p_1_", s, "_2011") :=  all_of(paste0("p_1_", s)),
             !!paste0("p_6_", s, "_2011") :=  all_of(paste0("p_6_", s)),
             !!paste0("p_8_", s, "_2011") :=  all_of(paste0("p_8_", s)),
             !!paste0("p_10_", s, "_2011") := all_of(paste0("p_10_", s)),
             !!paste0("p_11_", s, "_2011") := all_of(paste0("p_11_", s)),
             !!paste0("p_12_", s, "_2011") := all_of(paste0("p_12_", s)),
             !!paste0("p_40_", s, "_2011") := all_of(paste0("p_40_", s)),
             !!paste0("p_41_", s, "_2011") := all_of(paste0("p_41_", s)) ) 
  }
  
  # Rename variables that we only have total measures for them
  census_profile_da11_can_2011_HARM <- census_profile_da11_can_2011 |>
    rename( p_742_t_2011 = p_243_t,
            p_743_t_2011 = p_244_t,
            p_751_t_2011 = p_252_t,
            p_752_t_2011 = p_253_t,
            p_1617_t_2011 = p_1414_t,
            p_1618_t_2011 = p_1415_t,
            p_1619_t_2011 = p_1416_t,
            p_1620_t_2011 = p_1417_t,
            p_1640_t_2011 = p_1437_t,
            p_1642_t_2011 = p_1439_t,
            p_1651_t_2011 = p_1449_t,
            p_1653_t_2011 = p_1451_t,
            p_1667_t_2011 = p_1465_t,
            p_1669_t_2011 = p_1467_t,
            p_1673_t_2011 = p_1484_t,
            p_1676_t_2011 = p_1488_t,
            p_1677_t_2011 = p_1489_t,
            p_1680_t_2011 = p_1492_t) |>
  
    # Drop variables we don't need (we used them to create other variables.)
    select(-ends_with("_t"),
           -ends_with("_f"),
           -ends_with("_m"))
 
  # Add _16 at the end of vars in 2016 CP to differentiate them from 2011 CP
  census_profile_da11_can_2016_HARM <- census_profile_da11_can_2016 |>
    rename_with(~ if_else(.x == "da_id_11", .x, str_c(.x, "_2016"))) |>
    
    # Drop variables in 2016 that is missing in 2011 like average age and those
    # that are not available for female and male
    select(-starts_with("p_39"),
           -starts_with("p_661"),
           -starts_with("p_668"),
           -starts_with("p_867"),
           -starts_with("p_742_f"),
           -starts_with("p_743_f"),
           -starts_with("p_751_f"),
           -starts_with("p_752_f"),
           -starts_with("p_1617_f"),
           -starts_with("p_1618_f"),
           -starts_with("p_1619_f"),
           -starts_with("p_1620_f"),
           -starts_with("p_1640_f"),
           -starts_with("p_1642_f"),
           -starts_with("p_1651_f"),
           -starts_with("p_1653_f"),
           -starts_with("p_1667_f"),
           -starts_with("p_1669_f"),
           -starts_with("p_1673_f"),
           -starts_with("p_1676_f"),
           -starts_with("p_1677_f"),
           -starts_with("p_1680_f"),
           -starts_with("p_742_m"),
           -starts_with("p_743_m"),
           -starts_with("p_751_m"),
           -starts_with("p_752_m"),
           -starts_with("p_1617_m"),
           -starts_with("p_1618_m"),
           -starts_with("p_1619_m"),
           -starts_with("p_1620_m"),
           -starts_with("p_1640_m"),
           -starts_with("p_1642_m"),
           -starts_with("p_1651_m"),
           -starts_with("p_1653_m"),
           -starts_with("p_1667_m"),
           -starts_with("p_1669_m"),
           -starts_with("p_1673_m"),
           -starts_with("p_1676_m"),
           -starts_with("p_1677_m"),
           -starts_with("p_1680_m"))
    
  # Merge CP 2011 and 2016 based on DA 2011
  census_profile_da11_can_2011to2016 <- 
    left_join(census_profile_da11_can_2011_HARM,
              census_profile_da11_can_2016_HARM,
              by = "da_id_11")
  
  # Save profiles that have been harmonized across 2011 and 2016 CPs and exist
  # for both sex
  prof_harm_11_16_tfm <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 35, 37, 40, 41, 43,
                           52, 57, 58, 59, 60, 64, 65, 66, 67, 74, 78, 79, 80, 
                           100, 104, 663, 665, 674, 676, 690, 857, 1140, 1141, 
                           1142, 1149, 1150, 1289, 1290, 1323, 1324, 1325, 1326, 
                           1327, 1328, 1329, 1330, 1331, 1332, 1333, 1334, 1683, 
                           1684, 1692, 1713, 1715, 1717, 1720, 1729, 1737, 1741, 
                           1747, 1752, 1760, 1763, 1767, 1870, 1871, 1872, 1879, 
                           1883, 1884, 1887, 1888, 1889, 1890, 1891, 1892, 1893, 
                           1894, 1895, 1896, 1897, 1900, 1901, 1902, 1903, 1904, 
                           1905, 1906, 1907, 1908, 1909, 1910, 1911, 1912, 1913, 
                           1914, 1915, 1916, 1917, 1918, 1919, 2230, 2232, 2239, 
                           2241) 

  # Save profiles that have been harmonized across 2011 and 2016 CPs and are not
  # disaggregated by sex
  prof_harm_11_16_t <- c(742, 743, 751, 752, 1617, 1618, 1619, 1620, 1640, 1642,
                         1651, 1653, 1667, 1669, 1673, 1676, 1677, 1680)

  # Save the years between 2011 and 2016 that we want to interpolate
  years_12to15 <- c(2012, 2013, 2014, 2015)
  
  # Count unique DA 2011 in the file - total obs = 56,204
  n_distinct(census_profile_da11_can_2011to2016$"da_id_11")  # 56,204
  # Therefore, each row in the joined dataset is one DA 2011
  
  # Employ linear interpolation formula (eq. 1) to estimate intercensal CPs for
  # profiles available for total, female, and male
  for (id in prof_harm_11_16_tfm) {
    for (s in sex) {
      for (year in years_12to15) {
      
        census_profile_da11_can_2011to2016 <- 
          census_profile_da11_can_2011to2016 |>
       
          # Calculate the difference between 2011 and 2016 prof ids 
          mutate(!!paste0("p_", id, "_", s, "_dif") :=
                   .data[[paste0("p_", id, "_", s, "_11_2016")]] -
                   .data[[paste0("p_", id, "_", s, "_2011")]],
                
                 # Employ equation one
                 !!paste0("p_", id, "_", s, "_", year) :=
                   .data[[paste0("p_", id, "_", s, "_2011")]] +
                   (year - 2011) *
                   .data[[paste0("p_", id, "_", s, "_dif")]] / 5)
        
      }
    }
  }
  
  # Employ linear interpolation formula (eq. 1) to estimate intercensal CPs for
  # profiles only available for total population and not disaggregated by sex
  for (id in prof_harm_11_16_t) {
    for (year in years_12to15) {
      
      census_profile_da11_can_2011to2016 <- 
        census_profile_da11_can_2011to2016 |>
        
        # Calculate the difference between 2011 and 2016 prof ids 
        mutate(!!paste0("p_", id, "_t_dif") :=
                 .data[[paste0("p_", id, "_t_11_2016")]] -
                 .data[[paste0("p_", id, "_t_2011")]],
               
               # Employ equation one
               !!paste0("p_", id, "_t_", year) :=
                 .data[[paste0("p_", id, "_t_2011")]] +
                 (year - 2011) *
                 .data[[paste0("p_", id, "_t_dif")]] / 5)
      
    }
  }
  
  # Save estimated CPs for intercensal years in separate files
  for (year in years_12to15) {
    
    cp_year_temp <- census_profile_da11_can_2011to2016 |>
      select(ends_with(as.character(year)), da_id_11) |>
  
    # Save the dataset
    write_csv(paste0("Data/census_profile_da11_can_", year, ".csv"))
    
  }
  
  # 4.2 LINEAR INTERPOLATION, 2017 TO 2020                                  ####  
  # -------------------------------------------------------------------------- # 
  # In this section, we estimate harmonized census profiles between years 2016
  # and 2021 based on DA 2016 boundaries using the linear interpolation 
  # technique.
  
  # Import harmonized CP 2016 based on DA 2016
  census_profile_da16_can_2016 <- 
    read_csv("Data/census_profile_da16_can_2016_HARM.csv")
  
   # Import harmonized CP 2021 based on DA 2016
  census_profile_da16_can_2021 <- 
    read_csv("Data/census_profile_da16_can_2021.csv")
  
  # Save sex breakdown in a vector
  sex <- c("t", "f", "m")
  
  # Harmonize 2021 CP according to 2016 CP
  for (s in sex) {
    
    census_profile_da16_can_2021 <- census_profile_da16_can_2021 |>
      
      # Rename 2021 profiles to their 2016 profile counterparts
      rename( !!paste0("p_43_", s, "_16_2021") := 
                all_of(paste0("p_47_", s, "_16")),
              !!paste0("p_52_", s, "_16_2021") := 
                all_of(paste0("p_51_", s, "_16")),
              !!paste0("p_57_", s, "_16_2021") := 
                all_of(paste0("p_89_", s, "_16")),
              !!paste0("p_58_", s, "_16_2021") := 
                all_of(paste0("p_57_", s, "_16")),
              !!paste0("p_59_", s, "_16_2021") := 
                all_of(paste0("p_58_", s, "_16")),
              !!paste0("p_60_", s, "_16_2021") := 
                all_of(paste0("p_59_", s, "_16")),
              !!paste0("p_64_", s, "_16_2021") := 
                all_of(paste0("p_67_", s, "_16")),
              !!paste0("p_65_", s, "_16_2021") := 
                all_of(paste0("p_68_", s, "_16")),
              !!paste0("p_66_", s, "_16_2021") := 
                all_of(paste0("p_69_", s, "_16")),
              !!paste0("p_67_", s, "_16_2021") := 
                all_of(paste0("p_70_", s, "_16")),
              !!paste0("p_74_", s, "_16_2021") := 
                all_of(paste0("p_78_", s, "_16")),
              !!paste0("p_78_", s, "_16_2021") := 
                all_of(paste0("p_86_", s, "_16")),
              !!paste0("p_79_", s, "_16_2021") := 
                all_of(paste0("p_87_", s, "_16")),
              !!paste0("p_80_", s, "_16_2021") := 
                all_of(paste0("p_88_", s, "_16")),
              !!paste0("p_100_", s, "_16_2021") := 
                all_of(paste0("p_383_", s, "_16")),
              !!paste0("p_104_", s, "_16_2021") := 
                all_of(paste0("p_387_", s, "_16")),
              !!paste0("p_661_", s, "_16_2021") := 
                all_of(paste0("p_111_", s, "_16")),
              !!paste0("p_663_", s, "_16_2021") := 
                all_of(paste0("p_113_", s, "_16")),
              !!paste0("p_665_", s, "_16_2021") := 
                all_of(paste0("p_115_", s, "_16")),
              !!paste0("p_668_", s, "_16_2021") := 
                all_of(paste0("p_120_", s, "_16")),
              !!paste0("p_674_", s, "_16_2021") := 
                all_of(paste0("p_128_", s, "_16")),
              !!paste0("p_676_", s, "_16_2021") := 
                all_of(paste0("p_130_", s, "_16")),
              !!paste0("p_690_", s, "_16_2021") := 
                all_of(paste0("p_151_", s, "_16")),
              !!paste0("p_857_", s, "_16_2021") := 
                all_of(paste0("p_345_", s, "_16")),
              !!paste0("p_867_", s, "_16_2021") := 
                all_of(paste0("p_360_", s, "_16")),
              !!paste0("p_1140_", s, "_16_2021") := 
                all_of(paste0("p_1527_", s, "_16")),
              !!paste0("p_1141_", s, "_16_2021") := 
                all_of(paste0("p_1528_", s, "_16")),
              !!paste0("p_1142_", s, "_16_2021") := 
                all_of(paste0("p_1529_", s, "_16")),
              !!paste0("p_1149_", s, "_16_2021") := 
                all_of(paste0("p_1536_", s, "_16")),
              !!paste0("p_1150_", s, "_16_2021") := 
                all_of(paste0("p_1537_", s, "_16")),
              !!paste0("p_1289_", s, "_16_2021") := 
                all_of(paste0("p_1402_", s, "_16")),
              !!paste0("p_1290_", s, "_16_2021") := 
                all_of(paste0("p_1403_", s, "_16")),
              !!paste0("p_1323_", s, "_16_2021") := 
                all_of(paste0("p_1683_", s, "_16")),
              !!paste0("p_1324_", s, "_16_2021") := 
                all_of(paste0("p_1684_", s, "_16")),
              !!paste0("p_1325_", s, "_16_2021") := 
                all_of(paste0("p_1685_", s, "_16")),
              !!paste0("p_1326_", s, "_16_2021") := 
                all_of(paste0("p_1686_", s, "_16")),
              !!paste0("p_1327_", s, "_16_2021") := 
                all_of(paste0("p_1687_", s, "_16")),
              !!paste0("p_1328_", s, "_16_2021") := 
                all_of(paste0("p_1688_", s, "_16")),
              !!paste0("p_1329_", s, "_16_2021") := 
                all_of(paste0("p_1689_", s, "_16")),
              !!paste0("p_1330_", s, "_16_2021") := 
                all_of(paste0("p_1690_", s, "_16")),
              !!paste0("p_1331_", s, "_16_2021") := 
                all_of(paste0("p_1691_", s, "_16")),
              !!paste0("p_1332_", s, "_16_2021") := 
                all_of(paste0("p_1692_", s, "_16")),
              !!paste0("p_1333_", s, "_16_2021") := 
                all_of(paste0("p_1693_", s, "_16")),
              !!paste0("p_1334_", s, "_16_2021") := 
                all_of(paste0("p_1694_", s, "_16")),
              !!paste0("p_1683_", s, "_16_2021") := 
                all_of(paste0("p_1998_", s, "_16")),
              !!paste0("p_1684_", s, "_16_2021") := 
                all_of(paste0("p_1993_", s, "_16")),
              !!paste0("p_1692_", s, "_16_2021") := 
                all_of(paste0("p_2008_", s, "_16")),
              !!paste0("p_1713_", s, "_16_2021") := 
                all_of(paste0("p_2030_", s, "_16")),
              !!paste0("p_1715_", s, "_16_2021") := 
                all_of(paste0("p_2032_", s, "_16")),
              !!paste0("p_1717_", s, "_16_2021") := 
                all_of(paste0("p_2034_", s, "_16")),
              !!paste0("p_1720_", s, "_16_2021") := 
                all_of(paste0("p_2037_", s, "_16")),
              !!paste0("p_1729_", s, "_16_2021") := 
                all_of(paste0("p_2046_", s, "_16")),
              !!paste0("p_1737_", s, "_16_2021") := 
                all_of(paste0("p_2054_", s, "_16")),
              !!paste0("p_1741_", s, "_16_2021") := 
                all_of(paste0("p_2058_", s, "_16")),
              !!paste0("p_1747_", s, "_16_2021") := 
                all_of(paste0("p_2064_", s, "_16")),
              !!paste0("p_1752_", s, "_16_2021") := 
                all_of(paste0("p_2069_", s, "_16")),
              !!paste0("p_1760_", s, "_16_2021") := 
                all_of(paste0("p_2077_", s, "_16")),
              !!paste0("p_1763_", s, "_16_2021") := 
                all_of(paste0("p_2080_", s, "_16")),
              !!paste0("p_1767_", s, "_16_2021") := 
                all_of(paste0("p_2086_", s, "_16")),
              !!paste0("p_1870_", s, "_16_2021") := 
                all_of(paste0("p_2228_", s, "_16")),
              !!paste0("p_1871_", s, "_16_2021") := 
                all_of(paste0("p_2229_", s, "_16")),
              !!paste0("p_1872_", s, "_16_2021") := 
                all_of(paste0("p_2230_", s, "_16")),
              !!paste0("p_1879_", s, "_16_2021") := 
                all_of(paste0("p_2237_", s, "_16")),
              !!paste0("p_1883_", s, "_16_2021") := 
                all_of(paste0("p_2245_", s, "_16")),
              !!paste0("p_1884_", s, "_16_2021") := 
                all_of(paste0("p_2246_", s, "_16")),
              !!paste0("p_1887_", s, "_16_2021") := 
                all_of(paste0("p_2249_", s, "_16")),
              !!paste0("p_1888_", s, "_16_2021") := 
                all_of(paste0("p_2250_", s, "_16")),
              !!paste0("p_1889_", s, "_16_2021") := 
                all_of(paste0("p_2251_", s, "_16")),
              !!paste0("p_1890_", s, "_16_2021") := 
                all_of(paste0("p_2252_", s, "_16")),
              !!paste0("p_1891_", s, "_16_2021") := 
                all_of(paste0("p_2253_", s, "_16")),
              !!paste0("p_1892_", s, "_16_2021") := 
                all_of(paste0("p_2254_", s, "_16")),
              !!paste0("p_1893_", s, "_16_2021") := 
                all_of(paste0("p_2255_", s, "_16")),
              !!paste0("p_1894_", s, "_16_2021") := 
                all_of(paste0("p_2256_", s, "_16")),
              !!paste0("p_1895_", s, "_16_2021") := 
                all_of(paste0("p_2257_", s, "_16")),
              !!paste0("p_1896_", s, "_16_2021") := 
                all_of(paste0("p_2258_", s, "_16")),
              !!paste0("p_1897_", s, "_16_2021") := 
                all_of(paste0("p_2259_", s, "_16")),
              !!paste0("p_1900_", s, "_16_2021") := 
                all_of(paste0("p_2262_", s, "_16")),
              !!paste0("p_1901_", s, "_16_2021") := 
                all_of(paste0("p_2263_", s, "_16")),
              !!paste0("p_1902_", s, "_16_2021") := 
                all_of(paste0("p_2264_", s, "_16")),
              !!paste0("p_1903_", s, "_16_2021") := 
                all_of(paste0("p_2265_", s, "_16")),
              !!paste0("p_1904_", s, "_16_2021") := 
                all_of(paste0("p_2266_", s, "_16")),
              !!paste0("p_1905_", s, "_16_2021") := 
                all_of(paste0("p_2267_", s, "_16")),
              !!paste0("p_1906_", s, "_16_2021") := 
                all_of(paste0("p_2268_", s, "_16")),
              !!paste0("p_1907_", s, "_16_2021") := 
                all_of(paste0("p_2269_", s, "_16")),
              !!paste0("p_1908_", s, "_16_2021") := 
                all_of(paste0("p_2270_", s, "_16")),
              !!paste0("p_1909_", s, "_16_2021") := 
                all_of(paste0("p_2271_", s, "_16")),
              !!paste0("p_1910_", s, "_16_2021") := 
                all_of(paste0("p_2272_", s, "_16")),
              !!paste0("p_1911_", s, "_16_2021") := 
                all_of(paste0("p_2273_", s, "_16")),
              !!paste0("p_1912_", s, "_16_2021") := 
                all_of(paste0("p_2274_", s, "_16")),
              !!paste0("p_1913_", s, "_16_2021") := 
                all_of(paste0("p_2275_", s, "_16")),
              !!paste0("p_1914_", s, "_16_2021") := 
                all_of(paste0("p_2276_", s, "_16")),
              !!paste0("p_1915_", s, "_16_2021") := 
                all_of(paste0("p_2277_", s, "_16")),
              !!paste0("p_1916_", s, "_16_2021") := 
                all_of(paste0("p_2278_", s, "_16")),
              !!paste0("p_1917_", s, "_16_2021") := 
                all_of(paste0("p_2279_", s, "_16")),
              !!paste0("p_1918_", s, "_16_2021") := 
                all_of(paste0("p_2280_", s, "_16")),
              !!paste0("p_1919_", s, "_16_2021") := 
                all_of(paste0("p_2281_", s, "_16")),
              !!paste0("p_2230_", s, "_16_2021") := 
                all_of(paste0("p_1974_", s, "_16")),
              !!paste0("p_2232_", s, "_16_2021") := 
                all_of(paste0("p_1976_", s, "_16")),
              !!paste0("p_2239_", s, "_16_2021") := 
                all_of(paste0("p_1983_", s, "_16")),
              !!paste0("p_2241_", s, "_16_2021") := 
                all_of(paste0("p_1985_", s, "_16"))) |>
      
      # Add "_2021" at the end of variables lacking it
      rename(!!paste0("p_1_", s, "_16_2021") :=  
               all_of(paste0("p_1_", s, "_16")),
             !!paste0("p_6_", s, "_16_2021") :=  
               all_of(paste0("p_6_", s, "_16")),
             !!paste0("p_8_", s, "_16_2021") :=  
               all_of(paste0("p_8_", s, "_16")),
             !!paste0("p_9_", s, "_16_2021") :=  
               all_of(paste0("p_9_", s, "_16")),
             !!paste0("p_10_", s, "_16_2021") := 
               all_of(paste0("p_10_", s, "_16")),
             !!paste0("p_11_", s, "_16_2021") := 
               all_of(paste0("p_11_", s, "_16")),
             !!paste0("p_12_", s, "_16_2021") := 
               all_of(paste0("p_12_", s, "_16")),
             !!paste0("p_13_", s, "_16_2021") := 
               all_of(paste0("p_13_", s, "_16")),
             !!paste0("p_24_", s, "_16_2021") := 
               all_of(paste0("p_24_", s, "_16")),
             !!paste0("p_35_", s, "_16_2021") := 
               all_of(paste0("p_35_", s, "_16")),
             !!paste0("p_37_", s, "_16_2021") := 
               all_of(paste0("p_37_", s, "_16")),
             !!paste0("p_39_", s, "_16_2021") := 
               all_of(paste0("p_39_", s, "_16")),
             !!paste0("p_40_", s, "_16_2021") := 
               all_of(paste0("p_40_", s, "_16")),
             !!paste0("p_41_", s, "_16_2021") := 
               all_of(paste0("p_41_", s, "_16"))) 
  }
  
  # Rename variables that we only have total measures for them
  census_profile_da16_can_2021_HARM <- census_profile_da16_can_2021 |>
    rename( p_742_t_16_2021 = p_243_t_16,
            p_743_t_16_2021 = p_244_t_16,
            p_751_t_16_2021 = p_252_t_16,
            p_752_t_16_2021 = p_253_t_16,
            p_1617_t_16_2021 = p_1414_t_16,
            p_1618_t_16_2021 = p_1415_t_16,
            p_1619_t_16_2021 = p_1416_t_16,
            p_1620_t_16_2021 = p_1417_t_16,
            p_1640_t_16_2021 = p_1437_t_16,
            p_1642_t_16_2021 = p_1439_t_16,
            p_1651_t_16_2021 = p_1449_t_16,
            p_1653_t_16_2021 = p_1451_t_16,
            p_1667_t_16_2021 = p_1465_t_16,
            p_1669_t_16_2021 = p_1467_t_16,
            p_1673_t_16_2021 = p_1484_t_16,
            p_1676_t_16_2021 = p_1488_t_16,
            p_1677_t_16_2021 = p_1489_t_16,
            p_1680_t_16_2021 = p_1492_t_16) |>
    
    # Drop variables we don't need (we used them to create other variables.)
    select(-ends_with("t_16"),
           -ends_with("f_16"),
           -ends_with("m_16"))
  
  # Add _16_2016 for geo and year at the end of vars in 2016 CP 
  census_profile_da16_can_2016_HARM <- census_profile_da16_can_2016 |>
    rename_with(~ if_else(.x == "da_id_16", .x, str_c(.x, "_16_2016"))) |>
    
    # Drop variables in 2016 that are not available for female and male
    select(-starts_with("p_742_f"),
           -starts_with("p_743_f"),
           -starts_with("p_751_f"),
           -starts_with("p_752_f"),
           -starts_with("p_1617_f"),
           -starts_with("p_1618_f"),
           -starts_with("p_1619_f"),
           -starts_with("p_1620_f"),
           -starts_with("p_1640_f"),
           -starts_with("p_1642_f"),
           -starts_with("p_1651_f"),
           -starts_with("p_1653_f"),
           -starts_with("p_1667_f"),
           -starts_with("p_1669_f"),
           -starts_with("p_1673_f"),
           -starts_with("p_1676_f"),
           -starts_with("p_1677_f"),
           -starts_with("p_1680_f"),
           -starts_with("p_742_m"),
           -starts_with("p_743_m"),
           -starts_with("p_751_m"),
           -starts_with("p_752_m"),
           -starts_with("p_1617_m"),
           -starts_with("p_1618_m"),
           -starts_with("p_1619_m"),
           -starts_with("p_1620_m"),
           -starts_with("p_1640_m"),
           -starts_with("p_1642_m"),
           -starts_with("p_1651_m"),
           -starts_with("p_1653_m"),
           -starts_with("p_1667_m"),
           -starts_with("p_1669_m"),
           -starts_with("p_1673_m"),
           -starts_with("p_1676_m"),
           -starts_with("p_1677_m"),
           -starts_with("p_1680_m"))
  
  # Merge CP 2011 and 2016 based on DA 2011
  census_profile_da16_can_2016to2021 <- 
    left_join(census_profile_da16_can_2016_HARM,
              census_profile_da16_can_2021_HARM,
              by = "da_id_16")
  
  # Save profiles that have been harmonized across 2016 and 2021 CPs and exist
  # for both sex
  prof_harm_16_21_tfm <- c(1, 6, 8, 9, 10, 11, 12, 13, 24, 35, 37, 39, 40, 41, 
                           43, 52, 57, 58, 59, 60, 64, 65, 66, 67, 74, 78, 79, 
                           80, 100, 104, 661, 663, 665, 668, 674, 676, 690, 857, 
                           867, 1140, 1141, 1142, 1149, 1150, 1289, 1290, 1323, 
                           1324, 1325, 1326, 1327, 1328, 1329, 1330, 1331, 1332,
                           1333, 1334, 1683, 1684, 1692, 1713, 1715, 1717, 1720, 
                           1729, 1737, 1741, 1747, 1752, 1760, 1763, 1767, 1870, 
                           1871, 1872, 1879, 1883, 1884, 1887, 1888, 1889, 1890, 
                           1891, 1892, 1893, 1894, 1895, 1896, 1897, 1900, 1901, 
                           1902, 1903, 1904, 1905, 1906, 1907, 1908, 1909, 1910, 
                           1911, 1912, 1913, 1914, 1915, 1916, 1917, 1918, 1919, 
                           2230, 2232, 2239, 2241) 
  
  # Save profiles that have been harmonized across 2011 and 2016 CPs and are not
  # disaggregated by sex
  prof_harm_16_21_t <- c(742, 743, 751, 752, 1617, 1618, 1619, 1620, 1640, 1642,
                         1651, 1653, 1667, 1669, 1673, 1676, 1677, 1680)
  
  # Save the years between 2011 and 2016 that we want to interpolate
  years_17to20 <- c(2017, 2018, 2019, 2020)
  
  # Count unique DA 2016 in the file - total obs = 56,590
  n_distinct(census_profile_da16_can_2016to2021$"da_id_16")  # 56,590
  # Therefore, each row in the joined dataset is one DA 2016
  
  # Employ linear interpolation formula (eq. 1) to estimate intercensal CPs for
  # profiles available for total, female, and male
  for (id in prof_harm_16_21_tfm) {
    for (s in sex) {
      for (year in years_17to20) {
        
        census_profile_da16_can_2016to2021 <- 
          census_profile_da16_can_2016to2021 |>
          
          # Calculate the difference between 2016 and 2021 prof ids 
          mutate(!!paste0("p_", id, "_", s, "_dif") :=
                   .data[[paste0("p_", id, "_", s, "_16_2021")]] -
                   .data[[paste0("p_", id, "_", s, "_16_2016")]],
                 
                 # Employ equation one
                 !!paste0("p_", id, "_", s, "_", year) :=
                   .data[[paste0("p_", id, "_", s, "_16_2016")]] +
                   (year - 2016) *
                   .data[[paste0("p_", id, "_", s, "_dif")]] / 5)
      }
    }
  }
  
  # Employ linear interpolation formula (eq. 1) to estimate intercensal CPs for
  # profiles only available for total population and not disaggregated by sex
  for (id in prof_harm_16_21_t) {
    for (year in years_17to20) {
      
      census_profile_da16_can_2016to2021 <- 
        census_profile_da16_can_2016to2021 |>
        
        # Calculate the difference between 2016 and 2021 prof ids 
        mutate(!!paste0("p_", id, "_t_dif") :=
                 .data[[paste0("p_", id, "_t_16_2021")]] -
                 .data[[paste0("p_", id, "_t_16_2016")]],
               
               # Employ equation one
               !!paste0("p_", id, "_t_", year) :=
                 .data[[paste0("p_", id, "_t_16_2016")]] +
                 (year - 2016) *
                 .data[[paste0("p_", id, "_t_dif")]] / 5)
      
    }
  }
  
  # Save estimated CPs for intercensal years in separate files
  for (year in years_17to20) {
    
    cp_year_temp <- census_profile_da16_can_2016to2021 |>
      select(ends_with(as.character(year)), da_id_16) |>
      
      # Save the dataset
      write_csv(paste0("Data/census_profile_da16_can_", year, ".csv"))
    
  }  
  
# 5. CONSTRUCT CASDOHI FOR INTERCENSAL YEARS, 2011 to 2021                  ####  
# ---------------------------------------------------------------------------- # 
  
  # 5.1. CONSTRUCT CASDOHI FOR 2012 T0 2015 BASED ON 2011 DA                ####  
  # -------------------------------------------------------------------------- #

  # Clear the R environment  
  rm(list=ls(all=TRUE)) 
  
  # Save the years between 2011 and 2016 that we want to interpolate
  years_12to15 <- c("2012", "2013", "2014", "2015")
  
  # Import estimated CP for intercensal years
  for (year in years_12to15) {
    
    cp_temp <- read_csv(paste0("Data/census_profile_da11_can_", year, ".csv"))
      
    # Drop the year from the end of the variables
    casdohi_temp <- cp_temp |>
        rename_with(
        ~ if_else(.x == "da_id_11", .x, str_remove(.x, paste0("_", year)))
      ) |>
      
    # 5.1.1. POPULATION AND AGE GROUPS                                      ####
      # ---------------------------------------------------------------------- #
    # Rename population counts
    rename(pop_t = p_1_t, 
           pop_f = p_8_f, 
           pop_m = p_8_m) |>
      
      # Calculate percentage of population who are female
      mutate(pct_pop_f = pop_f / pop_t * 100) |>
      
      # Rename population density
      rename(pop_density = p_6_t) |>
      
      # Rename population average and median age
      rename(med_age_t = p_40_t,
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
      
    # 5.1.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT                          ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.1.3. EHNOCULTURAL INDICATORS                                        ####
    # ------------------------------------------------------------------------ #
    
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
             pct_east_asian_t = (p_1326_t + p_1333_t + p_1334_t) / 
               p_1323_t * 100,
             pct_east_asian_f = (p_1326_f + p_1333_f + p_1334_f) / 
               p_1323_f * 100,
             pct_east_asian_m = (p_1326_m + p_1333_m + p_1334_m) / 
               p_1323_m * 100,
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
      
    # 5.1.4. INCOME                                                         ####
    # ----------------------------------------------------------------------- #
    
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

      # Rename the percentage of total income from gov. transfer
      rename(pct_inc_gtransfer_t = p_690_t,
             pct_inc_gtransfer_f = p_690_f,
             pct_inc_gtransfer_m = p_690_m,) |>
      
      # Rename percentage of low-income pop based on LIM and LICO
      rename(pct_lim_at_t = p_857_t,
             pct_lim_at_f = p_857_f,
             pct_lim_at_m = p_857_m) |>
      
      # Calculate median after-tax household income adjusted for household siz
      mutate(med_atinc_hh_adj = med_atinc_hh / sqrt(mean_hh_size)) |>
      
    # 5.1.5. EDUCATION                                                      ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.1.6. LABOUR FORCE                                                   ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.1.7. HOUSING                                                        ####
    # ------------------------------------------------------------------------ #
    
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
    write_csv(casdohi_temp, 
              paste0("Data/casdohi_da11_can_", year, "_MASTER.csv"))
    
  }

  # 5.2. CONSTRUCT CASDOHI FOR 2017 T0 2020 BASED ON 2016 DA                ####  
  # -------------------------------------------------------------------------- #
  
  # Clear the R environment  
  rm(list=ls(all=TRUE)) 
  
  # Save the years between 2017 and 2021 that we want to interpolate
  years_17to20 <- c("2017", "2018", "2019", "2020")
  
  # Import estimated CP for intercensal years
  for (year in years_17to20) {
    
    cp_temp <- read_csv(paste0("Data/census_profile_da16_can_", year, ".csv"))
    
    # Drop the year from the end of the variables
    casdohi_temp <- cp_temp |>
      rename_with(
        ~ if_else(.x == "da_id_16", .x, str_remove(.x, paste0("_", year)))
      ) |>
      
    # 5.2.1. POPULATION AND AGE GROUPS                                      ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.2.2. HOUSEHOLD SIZE AND LIVING ARRANGEMENT                          ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.2.3. EHNOCULTURAL INDICATORS                                        ####
    # ------------------------------------------------------------------------ #
    
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
             pct_east_asian_t = (p_1326_t + p_1333_t + p_1334_t) / 
               p_1323_t * 100,
             pct_east_asian_f = (p_1326_f + p_1333_f + p_1334_f) / 
               p_1323_f * 100,
             pct_east_asian_m = (p_1326_m + p_1333_m + p_1334_m) / 
               p_1323_m * 100,
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
      
    # 5.2.4. INCOME                                                         ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.2.5. EDUCATION                                                      ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.2.6. LABOUR FORCE                                                   ####
    # ------------------------------------------------------------------------ #
    
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
      
    # 5.2.7. HOUSING                                                        ####
    # ------------------------------------------------------------------------ #
    
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
      mutate(pct_shelter_cost_30plus_tenant_owner = 
               p_1669_t / p_1667_t * 100) |>
      
      # Rename median value of owned dwellings	
      rename(med_dwelling_value = p_1676_t) |>
      
      # Rename average value of owned dwellings	
      rename(mean_dwelling_value = p_1677_t) |>
      
      # Calculate percentage of households who are tenure owner/renter/band  
      mutate(pct_owner = p_1618_t / p_1617_t * 100,
             pct_renter = p_1619_t / p_1617_t * 100,
             pct_band_housing = p_1620_t / p_1617_t * 100)
  
    # Save in CSV
    write_csv(casdohi_temp, paste0("Data/casdohi_da16_can_", year, "_MASTER.csv"))
    
  }
  
# 6. CREATE THE FINAL VERSION OF CASDOHI FOR INTERCENSAL YEARS, 2011-2021   ####
# ---------------------------------------------------------------------------- #  
# In this step, we merge the harmonized attribute file with CASDOHI based on DA
# to add higher geographic identifiers to CASDOHI. Then, we prepare
# ready-to-use CASDOHI files for each year between 2011 to 2016 and 2016 to 2021
# in separate files. 
#
# We have harmonized the attribute files in a project titled "Estimating 
# Population Counts for Dissemination Areas and Census Tracts in Canada from 
# 2011 to 2021", which can be accessed here:
# https://www.medrxiv.org/content/10.1101/2025.02.28.25322945v1
  
  # 6.1. CREATE CASDOHI FOR RELEASE, 2012-2015                              ####  
  # -------------------------------------------------------------------------- #  
  
    # 6.1.1. JOIN CASDOHI AND ATTRIBUTE FILE BASED ON DA_11, 2012-2015      ####  
    # ------------------------------------------------------------------------ #  
  
    # Clear the R environment  
    rm(list=ls(all=TRUE)) 
  
    # Save the years between 2011 and 2016 that we want to interpolate
    years_12to15 <- c(2012, 2013, 2014, 2015)
  
    # Import the attribute file with DA 2011
    attribute_file_da11_2011_USE <- 
      read_csv("Data/attribute_file_da11_2011_USE.csv")
    
    # Start a loop to join attribute file to CASDOHI for each census year
    for (year in years_12to15) {
      
      # Import the estimated CASDOHI for intercensal years
      casdohi_MASTER_temp <- 
        read_csv(paste0("Data/casdohi_da11_can_", year, "_MASTER.csv"))
      
      # Join CASDOHI to attribute file based on DA 2011
      merged_data <- left_join(casdohi_MASTER_temp, 
                               attribute_file_da11_2011_USE,
                               by = "da_id_11")
      
      assign(paste0("casdohi_da11_can_", year, "_USE"), merged_data)
      
    }
  
    # 6.1.2. CLEAN AND PREPARE THE FINAL VERSION OF CASDOHI, 2012-2015      #### 
    # ------------------------------------------------------------------------ #
  
    # Keep variables we need in CASDOHI, 2012 to 2015
    for (year in years_12to15) {  
    
      casdohi_RELEASE_temp <- get(paste0("casdohi_da11_can_", year, "_USE")) |>
    
        select(da_id_11, pr_id_11, pr_name_11, csd_id_11, csd_name_11, cd_id_11, 
               cma_id_11, ct_id_11, sactype_11, pop_t, pop_f, pop_m, pct_pop_f, 
               pop_density, med_age_t, med_age_f, med_age_m, pct_age_under5_t, 
               pct_age_under5_f, pct_age_under5_m, pct_age_under15_t, 
               pct_age_under15_f, pct_age_under15_m, pct_age_5to14_t, 
               pct_age_5to14_f, pct_age_5to14_m, pct_age_65plus_t, 
               pct_age_65plus_f, pct_age_65plus_m, ratio_dep_t, ratio_dep_f, 
               ratio_dep_m, mean_hh_size, pct_mcl_t, pct_mcl_f, pct_mcl_m, 
               pct_nm_t, pct_nm_f, pct_nm_m, pct_sdw_t, pct_sdw_f, pct_sdw_m, 
               pct_single_parent_t, pct_single_parent_f, pct_single_parent_m, 
               pct_alone_t, pct_alone_f, pct_alone_m, pct_no_eng_fr_t, 
               pct_no_eng_fr_f, pct_no_eng_fr_m, med_ttinc_hh, med_atinc_hh, 
               mean_ttinc_hh, mean_atinc_hh, med_ttinc_ind_t, med_ttinc_ind_f, 
               med_ttinc_ind_m, mean_ttinc_ind_t, mean_ttinc_ind_f, 
               mean_ttinc_ind_m, med_atinc_ind_t, med_atinc_ind_f, 
               med_atinc_ind_m, mean_atinc_ind_t, mean_atinc_ind_f, 
               mean_atinc_ind_m, med_atinc_hh_adj, pct_inc_gtransfer_t, 
               pct_inc_gtransfer_f, pct_inc_gtransfer_m, pct_lim_at_t, 
               pct_lim_at_f, pct_lim_at_m, pct_non_immig_t, pct_non_immig_f, 
               pct_non_immig_m, pct_immig_t, pct_immig_f, pct_immig_m, 
               pct_non_pr_t, pct_non_pr_f, pct_non_pr_m, pct_recent_immig_t, 
               pct_recent_immig_f, pct_recent_immig_m, pct_indigenous_t, 
               pct_indigenous_f, pct_indigenous_m, pct_vm_t, pct_vm_f, pct_vm_m, 
               pct_south_asian_t, pct_south_asian_f, pct_south_asian_m, 
               pct_east_asian_t, pct_east_asian_f, pct_east_asian_m,  
               pct_black_t, pct_black_f, pct_black_m, pct_southeast_asian_t, 
               pct_southeast_asian_f, pct_southeast_asian_m, 
               pct_latin_american_t, pct_latin_american_f, pct_latin_american_m, 
               pct_middle_eastern_t, pct_middle_eastern_f, pct_middle_eastern_m, 
               pct_apt_5plus, pct_major_repair, pct_mover_1y_t, pct_mover_1y_f, 
               pct_mover_1y_m, pct_mover_5y_t, pct_mover_5y_f, pct_mover_5y_m, 
               pct_not_suitable, pct_shelter_cost_30plus_tenant, 
               pct_shelter_cost_30plus_owner, 
               pct_shelter_cost_30plus_tenant_owner, med_dwelling_value, 
               mean_dwelling_value, pct_owner, pct_renter, pct_band_housing, 
               pct_no_diploma_t, pct_no_diploma_f, pct_no_diploma_m, 
               pct_uni_diploma_t, pct_uni_diploma_f, pct_uni_diploma_m, 
               pct_cip_education_t, pct_cip_education_f, pct_cip_education_m, 
               pct_cip_art_t, pct_cip_art_f, pct_cip_art_m, 
               pct_cip_humanities_t, pct_cip_humanities_f, pct_cip_humanities_m, 
               pct_cip_social_t, pct_cip_social_f, pct_cip_social_m, 
               pct_cip_buisiness_t, pct_cip_buisiness_m, pct_cip_buisiness_f, 
               pct_cip_physical_t, pct_cip_physical_f, pct_cip_physical_m, 
               pct_cip_math_t, pct_cip_math_f, pct_cip_math_m, 
               pct_cip_architecture_t, pct_cip_architecture_f, 
               pct_cip_architecture_m, pct_cip_agriculture_t, 
               pct_cip_agriculture_f, pct_cip_agriculture_m, pct_cip_health_t, 
               pct_cip_health_f, pct_cip_health_m, pct_cip_personal_t, 
               pct_cip_personal_f, pct_cip_personal_m, pct_lf_participation_t, 
               pct_lf_participation_f, pct_lf_participation_m, pct_emp_t, 
               pct_emp_f, pct_emp_m, pct_unemp_t, pct_unemp_f, pct_unemp_m, 
               pct_self_emp_t, pct_self_emp_f, pct_self_emp_m, pct_noc_0_t, 
               pct_noc_0_f, pct_noc_0_m, pct_noc_1_t, pct_noc_1_f, pct_noc_1_m, 
               pct_noc_2_t, pct_noc_2_f, pct_noc_2_m, pct_noc_3_t, pct_noc_3_f, 
               pct_noc_3_m, pct_noc_4_t, pct_noc_4_f, pct_noc_4_m, pct_noc_5_t, 
               pct_noc_5_f, pct_noc_5_m, pct_noc_6_t, pct_noc_6_f, pct_noc_6_m, 
               pct_noc_7_t, pct_noc_7_f, pct_noc_7_m, pct_noc_8_t, pct_noc_8_f, 
               pct_noc_8_m, pct_noc_9_t, pct_noc_9_f, pct_noc_9_m, 
               pct_naics_11_t, pct_naics_11_f, pct_naics_11_m, pct_naics_21_t, 
               pct_naics_21_f, pct_naics_21_m, pct_naics_22_t, pct_naics_22_f, 
               pct_naics_22_m, pct_naics_23_t, pct_naics_23_f, pct_naics_23_m, 
               pct_naics_31to33_t, pct_naics_31to33_f, pct_naics_31to33_m, 
               pct_naics_41_t, pct_naics_41_f, pct_naics_41_m, 
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
               pct_naics_81_m, pct_naics_91_t, pct_naics_91_f, pct_naics_91_m)|>
      
        # Create a variable indicating the year
        mutate(year = as.character(year)) |>
        relocate(year, .before = da_id_11)
  
    # Write the dataset to a CSV file with the same name
    write_csv(casdohi_RELEASE_temp, 
              paste0("Data/casdohi_da11_can_", year, "_RELEASE.csv"))
  
  }

  # 6.2. CREATE CASDOHI FOR RELEASE, 2017-2020                              ####  
  # -------------------------------------------------------------------------- #  
    
    # 6.2.1. JOIN CASDOHI AND ATTRIBUTE FILE BASED ON DA_16, 2017-2020      ####  
    # ------------------------------------------------------------------------ #  
    
    # Clear the R environment  
    rm(list=ls(all=TRUE)) 
    
    # Save the years between 2016 and 2021 that we want to interpolate
    years_17to20 <- c(2017, 2018, 2019, 2020)
    
    # Import the attribute file with DA 2016
    attribute_file_da16_2016_USE <- 
      read_csv("Data/attribute_file_da16_2016_USE.csv")
    
    # Start a loop to join attribute file to CASDOHI for each census year
    for (year in years_17to20) {
      
      # Import the estimated CASDOHI for intercensal years
      casdohi_MASTER_temp <- 
        read_csv(paste0("Data/casdohi_da16_can_", year, "_MASTER.csv"))
      
      # Join CASDOHI to attribute file based on DA 2016
      merged_data <- left_join(casdohi_MASTER_temp, 
                               attribute_file_da16_2016_USE,
                               by = "da_id_16")
      
      assign(paste0("casdohi_da16_can_", year, "_USE"), merged_data)
      
    }
    
    # 6.2.2. CLEAN AND PREPARE THE FINAL VERSION OF CASDOHI, 2017-2020      #### 
    # ------------------------------------------------------------------------ #
    
    # Keep variables we need in CASDOHI, 2017 to 2020
    for (year in years_17to20) {  
      
      casdohi_RELEASE_temp <- get(paste0("casdohi_da16_can_", year, "_USE")) |>
        
        select(da_id_16, pr_id_16, pr_name_16, csd_id_16, csd_name_16, cd_id_16,
               cma_id_16, ct_id_16, sactype_16, pop_t, pop_f, pop_m, pct_pop_f, 
               pop_density, mean_age_t, mean_age_f, mean_age_m, med_age_t, 
               med_age_f, med_age_m, pct_age_under5_t, pct_age_under5_f, 
               pct_age_under5_m, pct_age_under15_t, pct_age_under15_f, 
               pct_age_under15_m, pct_age_5to14_t, pct_age_5to14_f, 
               pct_age_5to14_m, pct_age_65plus_t, pct_age_65plus_f, 
               pct_age_65plus_m, ratio_dep_t, ratio_dep_f, ratio_dep_m, 
               mean_hh_size, pct_mcl_t, pct_mcl_f, pct_mcl_m, pct_nm_t, 
               pct_nm_f, pct_nm_m, pct_sdw_t, pct_sdw_f, pct_sdw_m, 
               pct_single_parent_t, pct_single_parent_f, pct_single_parent_m, 
               pct_alone_t, pct_alone_f, pct_alone_m, pct_no_eng_fr_t, 
               pct_no_eng_fr_f, pct_no_eng_fr_m, med_ttinc_hh, med_atinc_hh, 
               mean_ttinc_hh, mean_atinc_hh, med_ttinc_ind_t, med_ttinc_ind_f, 
               med_ttinc_ind_m, mean_ttinc_ind_t, mean_ttinc_ind_f, 
               mean_ttinc_ind_m, med_atinc_ind_t, med_atinc_ind_f, 
               med_atinc_ind_m, mean_atinc_ind_t, mean_atinc_ind_f, 
               mean_atinc_ind_m, med_atinc_hh_adj, pct_pop_gtransfer_t, 
               pct_pop_gtransfer_f, pct_pop_gtransfer_m, pct_inc_gtransfer_t, 
               pct_inc_gtransfer_f, pct_inc_gtransfer_m, pct_lico_at_t, 
               pct_lico_at_f, pct_lico_at_m, pct_lim_at_t, pct_lim_at_f, 
               pct_lim_at_m, pct_non_immig_t, pct_non_immig_f, pct_non_immig_m, 
               pct_immig_t, pct_immig_f, pct_immig_m, pct_non_pr_t, 
               pct_non_pr_f, pct_non_pr_m, pct_recent_immig_t, 
               pct_recent_immig_f, pct_recent_immig_m, pct_indigenous_t, 
               pct_indigenous_f, pct_indigenous_m, pct_vm_t, pct_vm_f, pct_vm_m, 
               pct_south_asian_t, pct_south_asian_f, pct_south_asian_m, 
               pct_east_asian_t, pct_east_asian_f, pct_east_asian_m, 
               pct_black_t, pct_black_f, pct_black_m, pct_southeast_asian_t, 
               pct_southeast_asian_f, pct_southeast_asian_m, 
               pct_latin_american_t, pct_latin_american_f, pct_latin_american_m, 
               pct_middle_eastern_t, pct_middle_eastern_f, pct_middle_eastern_m, 
               pct_apt_5plus, pct_major_repair, pct_mover_1y_t, pct_mover_1y_f, 
               pct_mover_1y_m, pct_mover_5y_t, pct_mover_5y_f, pct_mover_5y_m, 
               pct_not_suitable, pct_shelter_cost_30plus_tenant, 
               pct_shelter_cost_30plus_owner, 
               pct_shelter_cost_30plus_tenant_owner, med_dwelling_value, 
               mean_dwelling_value, pct_owner, pct_renter, pct_band_housing, 
               pct_no_diploma_t, pct_no_diploma_f, pct_no_diploma_m, 
               pct_uni_diploma_t, pct_uni_diploma_f, pct_uni_diploma_m, 
               pct_cip_education_t, pct_cip_education_f, pct_cip_education_m, 
               pct_cip_art_t, pct_cip_art_f, pct_cip_art_m, 
               pct_cip_humanities_t, pct_cip_humanities_f, pct_cip_humanities_m, 
               pct_cip_social_t, pct_cip_social_f, pct_cip_social_m, 
               pct_cip_buisiness_t, pct_cip_buisiness_m, pct_cip_buisiness_f, 
               pct_cip_physical_t, pct_cip_physical_f, pct_cip_physical_m, 
               pct_cip_math_t, pct_cip_math_f, pct_cip_math_m, 
               pct_cip_architecture_t, pct_cip_architecture_f, 
               pct_cip_architecture_m, pct_cip_agriculture_t, 
               pct_cip_agriculture_f, pct_cip_agriculture_m, pct_cip_health_t, 
               pct_cip_health_f, pct_cip_health_m, pct_cip_personal_t, 
               pct_cip_personal_f, pct_cip_personal_m, pct_lf_participation_t, 
               pct_lf_participation_f, pct_lf_participation_m, pct_emp_t, 
               pct_emp_f, pct_emp_m, pct_unemp_t, pct_unemp_f, pct_unemp_m, 
               pct_self_emp_t, pct_self_emp_f, pct_self_emp_m, pct_noc_0_t, 
               pct_noc_0_f, pct_noc_0_m, pct_noc_1_t, pct_noc_1_f, pct_noc_1_m, 
               pct_noc_2_t, pct_noc_2_f, pct_noc_2_m, pct_noc_3_t, pct_noc_3_f, 
               pct_noc_3_m, pct_noc_4_t, pct_noc_4_f, pct_noc_4_m, pct_noc_5_t, 
               pct_noc_5_f, pct_noc_5_m, pct_noc_6_t, pct_noc_6_f, pct_noc_6_m, 
               pct_noc_7_t, pct_noc_7_f, pct_noc_7_m, pct_noc_8_t, pct_noc_8_f, 
               pct_noc_8_m, pct_noc_9_t, pct_noc_9_f, pct_noc_9_m, 
               pct_naics_11_t, pct_naics_11_f, pct_naics_11_m, pct_naics_21_t, 
               pct_naics_21_f, pct_naics_21_m, pct_naics_22_t, pct_naics_22_f, 
               pct_naics_22_m, pct_naics_23_t, pct_naics_23_f, pct_naics_23_m, 
               pct_naics_31to33_t, pct_naics_31to33_f, pct_naics_31to33_m, 
               pct_naics_41_t, pct_naics_41_f, pct_naics_41_m, 
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
               pct_naics_81_m, pct_naics_91_t, pct_naics_91_f, pct_naics_91_m)|>
        
        # Create a variable indicating the year
        mutate(year = as.character(year)) |>
        relocate(year, .before = da_id_16)
      
      # Write the dataset to a CSV file to release
      write_csv(casdohi_RELEASE_temp, 
                paste0("Data/casdohi_da16_can_", year, "_RELEASE.csv"))
      
    }        

  
  
  
  
  
                
