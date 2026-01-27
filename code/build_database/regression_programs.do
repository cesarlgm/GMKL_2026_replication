
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	this file centralizes all the regression specifications 
*					all the programs that build regression tables
					

*===============================================================================
*/




cap program drop get_spec 
program define get_spec, rclass
	syntax, type(str) [NOsen]
	
	di "`nosen'"
	
	if "`nosen'"=="" {
		local seniority time_current_job_f
	}
	else {
		local seniority 
	}
	
	if "`type'"=="fs:main" {
		
		return local unife u_instcod* 
		
		return local controls  years_since_phd 	 				///
							c.years_since_phd#c.years_since_phd  			///
							i.tenured_f ib3.faculty_rank_f 					///
							ib0.married##ib0.female							///
							ib0.has_ch_6##ib0.female						/// 
							ib0.has_ch_611##ib0.female						///
							ib0.has_ch_1218##ib0.female						///
							ib0.has_ch_19##ib0.female `seniority'
	
	
		return local allcontrol ib3.new_locale  l_r_endowment_per_student 		///
						l_enrollment_total_m l_faculty_per_student 		///
						i.ug_only  i.control
						
		return local sscontrol 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
						
		return local base ib3.institution_type#c.l_inst_ranking_p ib3.institution_type 
	}
	else if "`type'"=="fs:endowment" {
		return local unife u_instcod* 
		
		return local controls 	years_since_phd 	 				///
							c.years_since_phd#c.years_since_phd  			///
							i.tenured_f ib3.faculty_rank_f 					///
							ib0.married##ib0.female							///
							ib0.has_ch_6##ib0.female						/// 
							ib0.has_ch_611##ib0.female						///
							ib0.has_ch_1218##ib0.female						///
							ib0.has_ch_19##ib0.female `seniority'
	
	
		return local allcontrol ib3.new_locale  l_r_endowment_per_student 		///
						l_enrollment_total_m l_faculty_per_student 		///
						i.ug_only  i.control
						
		return local sscontrol 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
						
		return local base ib3.institution_type 
	}
	else if "`type'"=="fs:tenured" {
		//#########################################
		//# TO MODIFY
		return local unife ib????.n_instcod   
		//#########################################

		return local controls  years_since_phd 	 				///
							c.years_since_phd#c.years_since_phd  			///
							i.tenured_f ib3.faculty_rank_f 					///
							ib0.married##ib0.female							///
							ib0.has_ch_6##ib0.female						/// 
							ib0.has_ch_611##ib0.female						///
							ib0.has_ch_1218##ib0.female						///
							ib0.has_ch_19##ib0.female 	`seniority'
	
	
		return local allcontrol ib3.new_locale  l_r_endowment_per_student 		///
						l_enrollment_total_m l_faculty_per_student 		///
						i.ug_only  i.control
						
		return local sscontrol 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
						
		return local base ib3.institution_type#c.l_inst_ranking_p ib3.institution_type 
	}
	else if "`type'"=="fs:jobsat" {
		//#########################################
		//# TO MODIFY
		return local unife ib????.n_instcod 
		//#########################################  
		
		return local controls  l_r_salary ///
					c.years_since_phd##c.years_since_phd ///
					i.tenured_f ib3.faculty_rank_f 					///
					ib0.married##ib0.female							///
					ib0.has_ch_6##ib0.female						/// 
					ib0.has_ch_611##ib0.female						///
					ib0.has_ch_1218##ib0.female						///
					ib0.has_ch_19##ib0.female 						///
					`seniority' i.refyr
				
	
		return local allcontrol ib3.new_locale  l_r_endowment_per_student 		///
						l_enrollment_total_m l_faculty_per_student 		///
						i.ug_only  i.control
						
		return local sscontrol 	ib3.new_locale 		///
							l_enrollment_total_m  ///
							i.ug_only  i.control
						
		return local base ib3.institution_type#c.l_inst_ranking_p ib3.institution_type 
	}
end


