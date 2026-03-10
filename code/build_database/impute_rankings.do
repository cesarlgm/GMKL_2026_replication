/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	Imputes missing institution rankings for unranked schools
*					(institution_type==3) by regressing observed rankings on US
*					News regional rankings (us_rank) via OLS and weighted OLS,
*					separately by ranking category. Outputs regression diagnostics
*					and a count of imputed schools, and classifies institutions
*					into an updated type variable (new_type).

*   Input: 		Default frame in memory; requires variables rank_uni, rank_coll,
*				rank_type, us_rank, the_rank, institution_type, inst_fe.
*   Output: 	Modifies default frame: imputes rank_uni/rank_coll for unranked
*				institutions; adds rank_uni_w, rank_coll_w, new_type,
*				imputed_ranking, rank_type_o.
*				results/tables/imputation_tables.csv — OLS regression tables
*				  by ranking category.
*				results/tables/number_schools_imputed.csv — count of imputed
*				  schools by rank type.
	

*===============================================================================
*/

*RANKINGS TO USE FOR IMPUTATION
local r_type national liberal north south midwest west north_colleges  south_colleges west_colleges midwest_colleges


replace rank_coll=the_rank if !missing(the_rank)&missing(rank_coll)&institution_type!=1
replace institution_type=2 if !missing(rank_coll)&institution_type!=1


generate rank_uni_w=rank_uni
generate rank_coll_w=rank_coll
foreach ranking in `r_type' {
	if "`ranking'"=="national" {
		local yvar rank_uni
	}
	else {
		local yvar rank_coll
	}
	
	*OLS
	eststo `ranking': reg `yvar' us_rank if rank_type=="`ranking'"
	cap drop r_`ranking'
	predict r_`ranking' if rank_type=="`ranking'"
	replace `yvar'=r_`ranking' if institution_type==3&!missing(r_`ranking')
	
	*WEIGHTED OLS
	eststo `ranking'_w: reg `yvar' us_rank [aw=us_rank] if rank_type=="`ranking'"
	cap drop r_`ranking'
	predict r_`ranking' if rank_type=="`ranking'"
	replace `yvar'_w=r_`ranking' if institution_type==3&!missing(r_`ranking')
}

*OUTPUTTING REGRESSION TABLES
*===============================================================================
esttab national liberal north south midwest west north_colleges south_colleges midwest_colleges ///
	west_colleges using "results/tables/imputation_tables.csv", label  ///
	mtitles(National Liberal North South Midwest West North South Midwest West) ///
	nostar stats(r2 F N) coeflab(us_rank `"US News ranking"') par se(%9.3fc) ///
	replace
	
cap drop r_*
*===============================================================================


cap drop new_type
cap drop inst_rank
generate 	new_type=3
replace 	new_type=1 	if institution_type==1|(institution_type==3&!missing(rank_uni))
replace		new_type=2 	if institution_type==2|(institution_type==3&!missing(rank_coll))


generate imputed_ranking=institution_type!=new_type

label define imputed_ranking 0 "Not imputed" 1 "Imputed ranking`'"

label define new_type 1 "Research university" 2 "Colleges" 3 "No ranking"
label values new_type new_type



*TABLE WITH HOW MANY SCHOOLS WAS I ABLE TO IMPUTE
*===============================================================================
*Here I output the number of schools I imputing
generate rank_type_o=.
replace rank_type_o=1 if rank_type=="national"
replace rank_type_o=2 if rank_type=="liberal"
replace rank_type_o=3 if rank_type=="north"
replace rank_type_o=4 if rank_type=="south"
replace rank_type_o=5 if rank_type=="west"
replace rank_type_o=6 if rank_type=="midwest"
replace rank_type_o=7 if rank_type=="north_colleges"
replace rank_type_o=8 if rank_type=="south_colleges"
replace rank_type_o=9 if rank_type=="west_colleges"
replace rank_type_o=10 if rank_type=="midwest_colleges"

labmask rank_type_o, values(rank_type)

estpost tabulate rank_type_o if  !missing(us_rank)&missing(the_rank)&!missing(inst_fe)

esttab . using "results/tables/number_schools_imputed.csv", ///
	cells("b(f(0)) pct(f(2))") replace
	
