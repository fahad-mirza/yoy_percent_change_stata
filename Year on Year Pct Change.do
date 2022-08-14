	clear

	* Loading the data
	input long year float(students_sch_high students_sch_sec students_sch_prim students_sch_total)
	 1          .          .          .          .
	 2  -24.79147   20.72112 -10.882794  4.2819424
	 3  -1.755232   .7972246  -6.606953  -.8899664
	 4  -8.766074 -2.0810065 -3.4279745 -3.3549566
	 5   .3443082   7.423184  -2.497542  4.7529798
	 6  -1.329616  -2.522265   3.257362 -1.4757383
	 7  1.2497283   5.721907  .56646156  4.2638063
	 8   2.318343   .5235602   3.418471  1.2162625
	 9  1.8462183   .0376506 -2.3570287 -.08383586
	10   5.283757   6.776649 -15.570302  3.1428025
	11  -21.73743  22.681967  -9.807495  12.131073
	12      -12.5   5.738228   4.306643    3.73689
	13  -7.142857   1.966941 -4.7221212   .5067236
	14  -3.076923 -4.5419555  -7.002161  -4.662036
	15  -20.63492  -9.723946  -10.49467  -10.67633
	16        -10  4.1367464   1.480916    2.87414
	17 -33.333332    1.16797 -16.157665  -2.600153
	18 -33.333332  -4.931025   3.606675   -5.46932
	19        -50  -3.862646  -6.667821  -5.504268
	end

	* Applying value labels
	label values year year_n
	label def year_n 1 "1999-2000", modify
	label def year_n 2 "2000-2001", modify
	label def year_n 3 "2001-2002", modify
	label def year_n 4 "2002-2003", modify
	label def year_n 5 "2003-2004", modify
	label def year_n 6 "2004-2005", modify
	label def year_n 7 "2005-2006", modify
	label def year_n 8 "2006-2007", modify
	label def year_n 9 "2007-2008", modify
	label def year_n 10 "2008-2009", modify
	label def year_n 11 "2009-2010", modify
	label def year_n 12 "2010-2011", modify
	label def year_n 13 "2011-2012", modify
	label def year_n 14 "2012-2013", modify
	label def year_n 15 "2013-2014", modify
	label def year_n 16 "2014-2015", modify
	label def year_n 17 "2015-2016", modify
	label def year_n 18 "2016-2017", modify
	label def year_n 19 "2017-2018", modify

	* Install relevant packages (One time only)
	ssc install schemepack, replace
	ssc install palettes, replace
	ssc install colrspace, replace
	
	* Reshaping from Wide to Long format
	reshape long students_sch_, i(year) j(category) string
	
	* Generating variables that will allow us to bring gap between years
	generate srno = _n
	by year: replace srno = . if _n == _N
	
	by year: generate srno1 = _n if _n == 1
	replace srno1 = sum(srno1)
	
	replace srno = srno + srno1
	drop srno1
	
	by year: egen srno_total = median(srno)
	by year: replace srno_total = . if _n != _N

	* Separating the percentage change variable by category
	separate students_sch_, by(category)
	
	
	* Plotting the graph
		
		* Storing min and max year values
		quietly: summarize year
		local max = `r(max)'
		local min = `r(min)'
		
		
		* Storing center values for group in local called med and generating 
		* another local that counts number of words in med
		* This is used in the xlab loop below
		levelsof srno_total, local(med)
		local n : word count `med'
		
		* Sometimes median can be in decimals and we cant ask stata to assign
		* value label to decimal, hence using a loop to form a text based input
		* for xlabel to be used in the plot below
		local xlab
		forval i = `min'(2)`max'{
			local medi : word `i' of `med'
			local xlab "`xlab' `medi' `" "`:lab (year) `i''" "'"
		}
		
		* The plot itself
		twoway 	(bar students_sch_4 srno_total, barwidth(4) fcolor(%0)) ///
				(bar students_sch_1 srno, lwidth(0)) ///
				(bar students_sch_2 srno, lwidth(0)) ///
				(bar students_sch_3 srno, lwidth(0)) ///
				, ///
				ylabel(-60(20)60, nogrid labsize(2)) ///
				xlabel(`xlab', nogrid labsize(1.75) angle(45)) ///
				yscale(noline) ///
				xscale(noline) ///
				ytitle("{bf}%", orient(horizontal) size(2)) ///
				legend(order(2 "High" 3 "Secondary" 4 "Primary" 1 "Total") size(1.75) pos(11) ring(0) bmargin(l=10)) ///
				title("{bf} Year on Year % Change in Number of Students",  pos(11) margin(b+3 t=-1) size(*.6)) ///
				subtitle("Timeline: 1999 to 2018",  pos(11) margin(b+6 t=-3 l=1.75) size(*.6)) ///
				graphregion(margin(b=0 t=3 l=3)) ///
				scheme(white_tableau)
	
	* Exporting the plot as PNG
	graph export "~/Desktop/YOY_pct_chg_student.png", as(png) width(1920) replace
