/******************************** README *********************************

Figure 1, "Interstate Variation in Occupational Licensing Policy for Six Example Occupations"

*************************************************************************/
clear

cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/data_cleaning/updated"

ssc install maptile

maptile_install using "http://files.michaelstepner.com/geo_state.zip"

net install grc1leg,from( http://www.stata.com/users/vwiggins/)

		
/*use truth_licensing


rename statefip statefips


* Make maps

	maptile licensed if occ == 2540, geo(state) geoid(statefips) fcolor(white gs11) twopt(legend(order(1 "Licensed" 2 "Unlicensed") rows(1)) title("Teacher Assistants") name(map1, replace))
	maptile licensed if occ == 3640, geo(state) geoid(statefips) fcolor(white gs11) twopt(legend(order(1 "Licensed" 2 "Unlicensed") rows(1)) title("Dental Assistants") name(map2, replace))
	maptile license if occ == 3257, geo(state) geoid(statefips) fcolor(white gs11) twopt(legend(order(1 "Licensed" 2 "Unlicensed") rows(1)) title("Nurse Midwives") name(map3, replace))
	maptile license if occ == 4460, geo(state) geoid(statefips) fcolor(white gs11) twopt(legend(order(1 "Licensed" 2 "Unlicensed") rows(1)) title("Funeral Service Workers") name(map4, replace))
	maptile license if occ == 3750, geo(state) geoid(statefips) fcolor(white gs11) twopt(legend(order(1 "Licensed" 2 "Unlicensed") rows(1)) title("Fire Inspectors") name(map5, replace))
	maptile license if occ == 3520, geo(state) geoid(statefips) fcolor(white gs11) twopt(legend(order(1 "Licensed" 2 "Unlicensed") rows(1)) title("Dispensing Opticians") name(map6, replace))

	
	grc1leg map1 map2 map3 map4 map5 map6, rows(3) name(combined, replace)
	graph display combined, ysize(5.5) xsize(6.5)
	graph export "$figs/licensing_maps.eps", as(eps) replace

*/

cd "/Users/wenchenwang/Desktop/Dissertation/Public_Updated_data/revision/CPS1/data_cleaning/updated"

*** Load data

	use cps_cleaned, clear

*** Prepare data

	ssc install gtools
	
	gcollapse license [aw=wtfinl], by(statefip)
	rename statefip statefips

*** Make graph

	maptile license, geo(state) geoid(statefips) fcolor(Greens)
	
	graph export state_map.png, as(png) replace
