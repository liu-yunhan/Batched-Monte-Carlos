version 18.0
clear all
set more off

// -------- inputs --------
local r "<<r>>"

// this ensures random numbers are unique across batches, provided
// there are less than 32,767 batches
set rng mt64s
set rngstream `r'

// change seed number if desired
// set seed `myseed'
cd ..

// -------- setup --------
capture mkdir "Outputs"
// capture mkdir "scratch"


// -------- simulate --------
// Generate 10,000 standard normal draws
set obs 10000
generate x = rnormal()

// Compute mean
quietly summarize x, meanonly
local m = r(mean)

//save result
clear
set obs 1
gen mean = r(mean) 
save "Outputs/mean_r`r'.dta", replace


exit
