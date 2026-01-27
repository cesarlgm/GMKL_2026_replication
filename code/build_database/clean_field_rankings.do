
/*
*===============================================================================
* Do Elite Universities Overpay Their Faculty?
*===============================================================================

*	Authors: 	César Garro-Marín (cgarrom@ed.ac.uk)
*				Shulamit Kahn (skahn@bu.edu)
*				Kevin Lang (lang@bu.edu)

*	Description: 	cleans and processes field-specific rankings from US News & World Report (biology and engineering)

*   Input: data/raw/USNWR_bio_rankings_processed.dta
*          data/raw/USNWR_eng_rankings_processed.dta
*          data/output/institution_level_database_raw.dta
*   Output: data/temporary/USNWR_bio_rankings_clean.dta
*           data/temporary/USNWR_eng_rankings_clean.dta
					

*===============================================================================
*/


capture program drop clean_strings
program define clean_strings
	syntax varlist, [keep]
	
	foreach variable in `varlist' {
		replace `variable'=regexr(`variable', "Â", "")
		forvalues i=1/30 {
			replace `variable'=ustrregexra(`variable',char(`i'),"")
		}
		forvalues i=8203/8205 {
			replace `variable'=ustrregexra(`variable',char(`i'),"")
		}
		replace `variable'=ustrregexra(`variable',"[\p{Cc}]","")
		if "`keep'"!="" {
			replace `variable'=ustrregexra(`variable',"[^\p{L}\p{N}p{P}p{Z}]","")
		}
		else {
			replace `variable'=ustrregexra(`variable',"[^\p{L}\p{N}p{P}]","")
		}
		replace `variable'=stritrim(lower(`variable'))
		replace  `variable'= ustrltrim( `variable')
		replace  `variable'=  strltrim( `variable')
		replace  `variable'=  trim( `variable')
		replace `variable'=  ustrto(ustrnormalize( `variable',"nfc"),"ascii",2)
	}
end


capture program drop clean_field_names 

program define clean_field_names
	replace inst_name="floridaatlanticuniversitybocaraton" if inst_name=="floridaatlanticuniversity"
	replace inst_name="louisianastateuniversityshreveport" if inst_name=="louisianastateuniversityhealthsciencescentershreveport"
	replace inst_name="miamiuniversityoxford" if inst_name=="miamiuniversity"
	replace inst_name="montanastateuniversitybozeman" if inst_name=="montanastateuniversity"
	replace inst_name="montanastateuniversitybozeman" if inst_name=="montanastateuniversity"
	replace inst_name="ohiostateuniversitycolumbus" if inst_name=="ohiostateuniversity"
	replace inst_name="pennsylvaniastateuniversity" if inst_name=="pennsylvaniastateuniversityuniversitypark"
	replace inst_name="rutgersuniversitycamden" if inst_name=="rutgersthestateuniversityofnewjerseycamden"
	replace inst_name="rutgersuniversitynewark" if inst_name=="rutgersthestateuniversityofnewjerseynewark"
	replace inst_name="rutgersuniversitynewbrunswick" if inst_name=="rutgersthestateuniversityofnewjerseynewbrunswick"
	replace inst_name="southernmethodistuniversity" if inst_name=="smu"
	replace inst_name="sunystonybrook" if inst_name=="stonybrookuniversitysuny"
	replace inst_name="texasamuniversity" if inst_name=="texasamuniversitycollegestation"
	replace inst_name="universityofalabamahuntsville" if inst_name=="universityofalabamahunstville"
	replace inst_name="universityofalabamabirmingham" if inst_name=="universityofalabamaatbirmingham"
	replace inst_name="universityofarkansas" if inst_name=="universityofarkansasfayetteville"
	replace inst_name="universityofmissouricolumbia" if inst_name=="universityofmissouri"
	replace inst_name="universityoftennessee" if inst_name=="universityoftennesseeknoxville"
	replace inst_name="sunyalbany" if inst_name=="universityatalbanysuny"
	replace inst_name="sunybuffalo" if inst_name=="universityatbuffalosuny"
	replace inst_name="arizonastateuniversity" if inst_name=="arizonastateuniversityfulton"
	replace inst_name="auburnuniversity" if inst_name=="auburnuniversityginn"
	replace inst_name="brighamyounguniversity" if inst_name=="brighamyounguniversityfulton"
	replace inst_name="carnegiemellonuniversity" if inst_name=="carnegiemellonuniversitycarnegie"
	replace inst_name="casewesternreserveuniversity" if inst_name=="casewesternreserveuniversitycase"
	replace inst_name="clarksonuniversity" if inst_name=="clarksonuniversitycoulter"	
	replace inst_name="coloradostateuniversity" if inst_name=="coloradostateuniversityscott"
	replace inst_name="columbiauniversity" if inst_name=="columbiauniversityfufoundation"
	replace inst_name="cunycitycollege" if inst_name=="cunycitycollegegrove"
	replace inst_name="dartmouthcollege" if inst_name=="dartmouthcollegethayer"
	replace inst_name="dukeuniversity" if inst_name=="dukeuniversitypratt"
	replace inst_name="embryriddleaeronauticaluniversity" if inst_name=="embryriddleaeronauticaluniversitydaytona"
	replace inst_name="georgemasonuniversity" if inst_name=="georgemasonuniversityvolgenau"
	replace inst_name="harvarduniversity" if inst_name=="harvarduniversitypaulson"
	replace inst_name="illinoisinstituteoftechnology" if inst_name=="illinoisinstituteoftechnologyarmour"
	replace inst_name="johnshopkinsuniversity" if inst_name=="johnshopkinsuniversitywhiting"
	replace inst_name="lehighuniversity" if inst_name=="lehighuniversityrossin"
	replace inst_name="louisianatechuniversity" if inst_name=="louisianatechuniversity2"	
	replace inst_name="marquetteuniversity" if inst_name=="marquetteuniversityopus"	
	replace inst_name="mississippistateuniversity" if inst_name=="mississippistateuniversitybagley"	
	replace inst_name="morganstateuniversity" if inst_name=="morganstateuniversitymitchell"	
	replace inst_name="newyorkuniversity" if inst_name=="newyorkuniversitytandon"	
	replace inst_name="northwesternuniversity" if inst_name=="northwesternuniversitymccormick"	
	replace inst_name="olddominionuniversity" if inst_name=="olddominionuniversitybatten"	
	replace inst_name="portlandstateuniversity" if inst_name=="portlandstateuniversitymaseeh"	
	replace inst_name="purdueuniversitywestlafayette" if inst_name=="purdueuniversitymaincampus"	
	replace inst_name="riceuniversity" if inst_name=="riceuniversitybrown"	
	replace inst_name="rochesterinstituteoftechnology" if inst_name=="rochesterinstituteoftechnologygleason"	
	replace inst_name="southernmethodistuniversity" if inst_name=="southernmethodistuniversitylyle"	
	replace inst_name="stevensinstituteoftechnology" if inst_name=="stevensinstituteoftechnologyschaefer"	
	replace inst_name="sunycollegeofenvironmentalscienceandforestry" if inst_name=="sunycollegeofenvironmentalscienceandforestry1"
	replace inst_name="texasamuniversitykingsville" if inst_name=="texasamuniversitykingsvilledotterweich"
	replace inst_name="texasamuniversitykingsville" if inst_name=="texasamuniversitykingsvilledotterweich"
	replace inst_name="texastechuniversity" if inst_name=="texastechuniversitywhitacre"
	replace inst_name="sunyalbany" if inst_name=="universityatalbanysuny2"
	replace inst_name="universityofarkansaslittlerock" if inst_name=="universityofarkansaslittlerockdonaghey"
	replace inst_name="universityofcaliforniairvine" if inst_name=="universityofcaliforniairvinesamueli"
	replace inst_name="universityofcalifornialosangeles" if inst_name=="universityofcalifornialosangelessamueli"
	replace inst_name="universityofcaliforniariverside" if inst_name=="universityofcaliforniariversidebourns"
	replace inst_name="universityofcaliforniasandiego" if inst_name=="universityofcaliforniasandiegojacobs"
	replace inst_name="universityofcaliforniasantacruz" if inst_name=="universityofcaliforniasantacruzbaskin"
	replace inst_name="universityofdenver" if inst_name=="universityofdenverritchie"
	replace inst_name="universityofflorida" if inst_name=="universityoffloridawertheim"
	replace inst_name="universityofillinoisurbanachampaign" if inst_name=="universityofillinoisurbanachampaigngrainger"
	replace inst_name="universityoflouisville" if inst_name=="universityoflouisvillespeed"
	replace inst_name="universityofmarylandcollegepark" if inst_name=="universityofmarylandcollegeparkclark"
	replace inst_name="universityofmassachusettslowell" if inst_name=="universityofmassachusettslowellfrancis"
	replace inst_name="universityofmemphis" if inst_name=="universityofmemphisherff"
	replace inst_name="universityofminnesota" if inst_name=="universityofminnesotatwincities"
	replace inst_name="universityofhouston" if inst_name=="universityofhoustoncullen"
	replace inst_name="universityofnevadalasvegas" if inst_name=="universityofnevadalasvegashughes"
	replace inst_name="universityofnorthcarolinacharlotte" if inst_name=="universityofnorthcarolinacharlottewslee"
	replace inst_name="universityofoklahoma" if inst_name=="universityofoklahomagallogly"
	replace inst_name="universityofpittsburgh" if inst_name=="universityofpittsburghswanson"
	replace inst_name="universityofrochester" if inst_name=="universityofrochesterhajim"
	replace inst_name="universityofsouthcarolinacolumbia" if inst_name=="universityofsouthcarolinamolinaroli"
	replace inst_name="universityofsoutherncalifornia" if inst_name=="universityofsoutherncaliforniaviterbi"
	replace inst_name="universityoftennessee" if inst_name=="universityoftennesseeknoxvilletickle"
	replace inst_name="universityoftexasaustin" if inst_name=="universityoftexasaustincockrell"
	replace inst_name="universityoftexasarlington" if inst_name=="theuniversityoftexasatarlington"
	replace inst_name="universityoftexaselpaso" if inst_name=="theuniversityoftexasatelpaso"
	replace inst_name="universityoftexasdallas" if inst_name=="theuniversityoftexasatdallasjonsson"
	replace inst_name="universityoftexassanantonio" if inst_name=="universityoftexassanantonioklesse"
	replace inst_name="universityofwyoming" if inst_name=="universityofwyoming1"
	replace inst_name="washingtonstateuniversity" if inst_name=="washingtonstateuniversityvoiland"
	replace inst_name="washingtonuniversityinstlouis" if inst_name=="washingtonuniversityinstlouismckelvey"
	replace inst_name="westvirginiauniversity" if inst_name=="westvirginiauniversitystatler"
	replace inst_name="ohiouniversity" if inst_name=="ohiouniversityruss"
	replace inst_name="universityofvermontandstateagriculturalcoll" if inst_name=="universityofvermont"																																																			
										
										
				
						
					
					
				
		
			
		
	
	
	
	
	
	
end


*First I clean the biology rankings
{	
	clear
	use "data\raw\USNWR_bio_rankings_processed.dta", clear


	rename position bio_ranking
	rename school_name inst_name

	drop ranking

	clean_strings  state city, keep
	clean_strings inst_name
	
	clean_field_names
	

	tempfile bio_ranking
	save `bio_ranking'
}


{
	use "data/output/institution_level_database_raw", clear

	keep instcod inst_name state
	
	replace inst_name=trim(lower(inst_name))

	
	
	clean_strings inst_name
	

	merge 1:1 inst_name using `bio_ranking', keep(3) nogen


	xtile bio_ranking_p=bio_ranking, nq(100)
	
	generate l_bio_raking_p=log(bio_ranking_p)
	
	keep instcod *bio*
	
	save "data/temporary/USNWR_bio_rankings_clean", replace
	
}

{
	clear
	use "data\raw\USNWR_eng_rankings_processed.dta", clear
	
	rename position eng_ranking
	rename school_name inst_name

	drop ranking

	clean_strings  state city, keep
	clean_strings inst_name

	clean_field_names
	
	tempfile eng_ranking
	save `eng_ranking'
}


{
	use "data/output/institution_level_database_raw", clear

	keep instcod inst_name state
	
	replace inst_name=trim(lower(inst_name))

	
	
	clean_strings inst_name
	

	merge 1:1 inst_name using `eng_ranking',  keep(3) 
	
	
	sort inst_name 

	
	xtile eng_ranking_p=eng_ranking, nq(100)
	
	generate l_eng_raking_p=log(eng_ranking_p)
	
	keep instcod *eng*
	
	save "data/temporary/USNWR_eng_rankings_clean", replace

}

	


