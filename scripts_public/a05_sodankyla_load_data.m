close all
clear variables


%%


% download data from here: https://litdb.fmi.fi

sodankyla_forest = readtable('../data/skyla_raw/MET0002_2013-01-01_2023-12-31_050124121236.txt');
sodankyla_forest_PAR_vuo2 = readtable('../data/skyla_raw/VUO0002_2012-01-01_2019-12-31_040324102356.txt');

sodankyla_peat_suo0006 = readtable('../data/skyla_raw/SUO0006_2013-01-01_2023-12-31_050124121624.txt');
sodankyla_peat_suo0003 = readtable('../data/skyla_raw/SUO0003_2013-01-01_2023-12-31_050124121744.txt');
sodankyla_peat_suo0009 = readtable('../data/skyla_raw/SUO0009_2013-01-01_2021-12-31_120224130837.txt');
sodankyla_peat_suo0010 = readtable('../data/skyla_raw/SUO0010_2013-01-01_2021-12-31_120224130710.txt');

%%

% these data from https://en.ilmatieteenlaitos.fi/download-observations,
% station Sodankylä Tähtelä
data_dir = '../data/skyla_diffuse/';

fls = dir([data_dir,'*.csv']);

imp_opts = detectImportOptions([data_dir,fls(1).name]);

diff_tab = [];
for ii = 1:length(fls)
    diff_tab_temp = readtable([data_dir,fls(ii).name],imp_opts);
    diff_tab = [diff_tab;diff_tab_temp];
end


dttime_diff = datetime(diff_tab.Time_UTC_,'InputFormat','HH:mm') - datetime(year(datetime()),month(datetime()),day(datetime())) + datetime(diff_tab.Year,diff_tab.Month,diff_tab.Day,'TimeZone','GMT');
diff_tt = table2timetable(diff_tab,'RowTimes',dttime_diff);


diff_tt(:,[1 2 3 4 5]) = [];

diff_tt.Properties.VariableNames = {'diffGlob'};

%% convert to timetables
dttime_peat_suo0006 = datetime(sodankyla_peat_suo0006.DATETIME,'InputFormat','yyyy-MM-dd HH:mm:ssZ','TimeZone','GMT');
suo0006 = table2timetable(sodankyla_peat_suo0006,'RowTimes',dttime_peat_suo0006);

dttime_peat_suo0003 = datetime(sodankyla_peat_suo0003.DATETIME,'InputFormat','yyyy-MM-dd HH:mm:ssZ','TimeZone','GMT');
suo0003 = table2timetable(sodankyla_peat_suo0003,'RowTimes',dttime_peat_suo0003);

dttime_peat_suo0009 = datetime(sodankyla_peat_suo0009.DATETIME,'InputFormat','yyyy-MM-dd HH:mm:ssZ','TimeZone','GMT');
suo0009 = table2timetable(sodankyla_peat_suo0009,'RowTimes',dttime_peat_suo0009);

dttime_peat_suo0010 = datetime(sodankyla_peat_suo0010.DATETIME,'InputFormat','yyyy-MM-dd HH:mm:ssZ','TimeZone','GMT');
suo0010 = table2timetable(sodankyla_peat_suo0010,'RowTimes',dttime_peat_suo0010);

suo0009.Properties.VariableNames{4} = 'GLOB_SUO0009';
suo0010.Properties.VariableNames{8} = 'REFL_SUO0010';


dttime_forest = datetime(sodankyla_forest.DATETIME,'InputFormat','yyyy-MM-dd HH:mm:ssZ','TimeZone','GMT');
forest_tt = table2timetable(sodankyla_forest,'RowTimes',dttime_forest);

%%

forest_tt(:,[1 2 4 5 6 7 9 10 11 12 14 15 16 17 18]) = [];

varnames_new =  {'T_forest','RH_forest','WS_forest','GLOB_forest','REFL_forest','NET_forest','PAR_forest','RPAR_forest','SDepth_forest'};

forest_tt.Properties.VariableNames = varnames_new;
%%

peat_tt = synchronize(suo0006,suo0003,suo0009,suo0010);

peat_tt(:,[1 2 5 6 9 12 13 14 15 24 25]) = [];

varnames_new_peat = {'GLOB_peat','REFL_peat','T_peat','TD_peat','RH_peat','SDepth_peat','PAR_peat','GLOB_peat_suo09','Tsoil5_suo09','Tsoil10_peat','Tsoil20_peat','Tsoil30_peat','Tsoil50_peat','Soil_heat_flux_peat','T_peat_suo10','RH_peat_suo10','WTL1_peat','WTL2_peat','NET_R_peat','REFL_peat_suo10','RPAR_peat','TSoil5_peat_suo10'};

for ii = 1:length(varnames_new_peat)
    disp([peat_tt.Properties.VariableNames(ii),' is now ',varnames_new_peat(ii)])
end

%%
peat_tt.Properties.VariableNames = varnames_new_peat;

%%

skyla_tt_orig = synchronize(peat_tt,forest_tt,diff_tt);

% mean like nanmean
skyla_tt_raw = retime(skyla_tt_orig,'regular','mean','TimeStep',minutes(30));
skyla_tt_raw.Time.TimeZone = '+02:00';

% save('../vars/skyla_tt_raw',"skyla_tt_raw")



