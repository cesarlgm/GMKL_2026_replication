*===============================================================================
*Project AKM-SDR
*===============================================================================
/*
	Author: 	Garro-Marín, Kahn, and Lang
				
	Outputs:    computes KSS correction
*/
*==============================================================================



*First I output the datasets for the correction
do "code/build_database/output_KSS_datasets.do"


*This can take upto 10 hours
rscript using "code/build_database/kss_correction_full.R"


*Reviewing the number of schools per type
do "code/build_database/get_number_schools_per_type.do"

