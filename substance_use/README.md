# Substance Use

Research on substance use harm in Saskatchewan has been hampered by an absence of linked data to analyze and report on the social drivers of substance use harm. 
This study and indicator aims to address this gap by providing a fully annotated STATA do-file that links sociodemographic data to 11 years of hospitalization 
and death outcomes. This do-file will greatly facilitate the creation of provincial and national substance use cohorts using line-level data available
through Statistics Canada’s Research Data Centres (RDC) program.

We used [Canadian Census Health and Environment Cohorts (CanCHEC)](https://github.com/csdul/pre_beta_datasets/blob/main/README.md) 2006 to create a cohort of Saskatchewanians followed from 2006 to 2016. We linked
sociodemographic information of the 2006 Census (long-form) respondents to their hospitalization data captured in the 
[Discharge Abstract Database (DAD)](https://github.com/csdul/pre_beta_datasets/blob/main/README.md) (2006 to 2016) and their mortality records in the [Canadian Vital Statistics Death Database (CVSD)]((https://github.com/csdul/pre_beta_datasets/blob/main/README.md)) (2006 to
2016). We developed an algorithm to identify Saskatchewanians who experienced a substance use harm event. We validated the cohort by comparing our
descriptive findings with those from other Canadian studies on substance use.

## [Datasets](https://github.com/csdul/pre_beta_datasets)

- Canadian Census Health and Environment Cohorts (CanCHEC)
- Discharge Abstract Database (DAD)
- Canadian Vital Statistics Death Database (CVSD)

## Files

- [**Codes**](https://github.com/csdul/pre_beta_hub_individual/tree/main/avoidable_mortality/codes): Contains scripts or algorithms used to calculate and process the indicator.
- [**Documents**](https://drive.google.com/drive/folders/16JdXB271MFI0rIS73d8nUd_fqXZ5Gw2T): Includes detailed documentation outlining the methodology, purpose, and any relevant notes for the indicator.
- [**Data**](https://drive.google.com/drive/folders/16JdXB271MFI0rIS73d8nUd_fqXZ5Gw2T): Contains the data used for calculating or representing the indicator.
- [**Results**](https://drive.google.com/drive/folders/1Zb0YiiOH-pHuEfiH91RCPFGxW11kfsOw): Table with the indicators calculated.
