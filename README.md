Filenames starting with a0x load and preprocess the data, these should be ran first in numerical order. The Hyytiälä-Siikaneva data is downloaded from the internet, but the raw data in text format used in the manuscript is also provided in a separate folder. If using that data, start from the a02 script. The Halssiaapa-Sodankylä data is provided. The data are available under Creative Commons 4.0 Attribution (CC BY 4.0) and  Creative Commons Attribution-NonCommercial 4.0 (CC BY-NC 4.0) licenses, respectively.

The data used as a starting point in the majority of the figures is also provided as text files: skyla_tt_daily_cleaned.txt and hyde_tt_daily_cleaned_calibrated.txt. If using matlab, load these to the workspace with readtimetable


Scripts use some custom functions written by Otso Peräkylä, these are included as separate files. In addition, they use the sun_position function from e.g. https://web.mit.edu/acmath/matlab/IAP2007/Practice/MatlabCentral/sun_position/sun_position.m

The calculated zenith angles are also provided in a text file along with other data. 


After the preprocessing scripts, SW_balance_differences_both does further gapfillind, and should be ran next. The other scripts are mainly for plotting data, and contain the code for creating the figures in the manuscript as follows:

plots_for_ms.m has figs. 2, 3, A3, A5

SW_balance_differences_both.m has figs 9, 11, A1, A2, A10, A11, A12, A13, A14, A15, A16, A18, A19

thinning_effect.m has figs 8 and A7

whitesky_diffuse_par_checks.m has figs 7, A4, A8, A17

yearly_albedo_plots.m has figs 4, 5, 6, 10, A6, A9


For any questions on the scripts contact Otso Peräkylä at otso.perakyla (at) helsinki.fi or otso.perakyla (at) gmail.com
