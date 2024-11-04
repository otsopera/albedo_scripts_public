close all
clear variables


webopts = weboptions;
webopts.Timeout = inf;

% template query copied from SmartSMEAR web gui. Construct the query to
% look like this
template_query = 'https://smear-backend.rahtiapp.fi/search/timeseries/csv?tablevariable=HYY_EDDY233.NEE&tablevariable=HYY_META.T168&from=1996-01-01T00%3A00%3A00.000&to=1997-12-31T23%3A59%3A59.999&quality=ANY&aggregation=ARITHMETIC&interval=30';

select_vars = {'HYY_META.T168','HYY_META.Td','HYY_META.SD_gpm','HYY_META.tsoil_humus','HYY_META.tsoil_0','SII1_META.T_a','SII1_META.SD','SII1_META.T_p_0','SII1_META.T_p_B5','SII1_META.PAR','SII1_META.R_PAR','SII1_META.Glob','SII1_META.R_Glob','SII1_META.LWin','SII1_META.LWout','HYY_META.UV_A','HYY_META.UV_B','HYY_META.Net','HYY_META.Glob','HYY_META.PAR','HYY_META.RPAR','HYY_META.diffGLOB','HYY_META.RGlob125','HYY_META.diffPAR','HYY_META.LWin','HYY_META.LWout','SII1_META.WTD','SII1_META.Wsoil_1'};


% Siikaneva WTD only seems to be available for part of 2016 
% ,'SII1_META.WTD'
% ,'WTD_SII'

% in the same order as the variables in select_vars above
short_varnames = {'Tair_HYY','Tdew_HYY','SnowDepth_HYY','Tsoil_HYY','Tsoil_HYY_ICOS','Tair_SII','SnowDepth_SII','TSoil_SII_ICOS','TSoil_SII','PAR_SII','RPAR_SII','Glob_SII','RGlob_SII','LWin_SII','LWout_SII','UVA_HYY','UVB_HYY','Net_HYY','Glob_HYY_tower','PAR_HYY','RPAR_HYY','diffGlob_HYY','RGlob_HYY125','diffPAR_HYY','LWin_HYY','LWout_HYY','WTD_SII','Wsoil_SII'};


format_query_1 = 'https://smear-backend.rahtiapp.fi/search/timeseries/csv?';
format_query_2 = '&from=';
format_query_3 = '&to=';
format_query_4 = '&quality=ANY&aggregation=ARITHMETIC&interval=30';

for ii = 1:length(select_vars)
    if ii == 1
        pick_vars_query = ['tablevariable=',select_vars{ii}];
    else
        pick_vars_query = [pick_vars_query,'&tablevariable=',select_vars{ii}];
    end
end



% download in blocks to avoid server timeouts. Adjust to shorter blocks if
% needed


start_time_1 = datetime(2016,1,1,0,0,0);
end_time_1 = datetime(2017,12,31,23,59,59,999);

% 
start_time_2 = datetime(2018,1,1,0,0,0);
end_time_2 = datetime(2019,12,31,23,59,59,999);
% 
% 
start_time_3 = datetime(2020,1,1,0,0,0);
end_time_3 = datetime(2021,12,31,23,59,59,999);
% 
% 
start_time_4 = datetime(2022,1,1,0,0,0);
end_time_4 = datetime(2023,12,31,23,59,59,999);
% 
% 
% start_time_5 = datetime(2019,1,1,0,0,0);
% end_time_5 = datetime(2021,12,31,23,59,59,999);

fmt = 'yyyy-MM-dd''T''hh''%3A''mm''%3A''ss.SSS';
start_str_1 = char(string(start_time_1,fmt));
end_str_1 = char(string(end_time_1,fmt));

start_str_2 = char(string(start_time_2,fmt));
end_str_2 = char(string(end_time_2,fmt));
% 

start_str_3 = char(string(start_time_3,fmt));
end_str_3 = char(string(end_time_3,fmt));


start_str_4 = char(string(start_time_4,fmt));
end_str_4 = char(string(end_time_4,fmt));
% 
% 
% start_str_5 = char(string(start_time_5,fmt));
% end_str_5 = char(string(end_time_5,fmt));


db_query_1 = [format_query_1,pick_vars_query,format_query_2,start_str_1,format_query_3,end_str_1,format_query_4];
db_query_2 = [format_query_1,pick_vars_query,format_query_2,start_str_2,format_query_3,end_str_2,format_query_4];
db_query_3 = [format_query_1,pick_vars_query,format_query_2,start_str_3,format_query_3,end_str_3,format_query_4];
db_query_4 = [format_query_1,pick_vars_query,format_query_2,start_str_4,format_query_3,end_str_4,format_query_4];
% db_query_5 = [format_query_1,pick_vars_query,format_query_2,start_str_5,format_query_3,end_str_5,format_query_4];


disp(['Starting at ',char(datetime)])
data_table_1 = webread(db_query_1,webopts);
disp(['First done at ',char(datetime)])
data_table_2 = webread(db_query_2,webopts);
disp(['Second done at ',char(datetime)])
data_table_3 = webread(db_query_3,webopts);
disp(['Third done at ',datestr(now)])
data_table_4 = webread(db_query_4,webopts);
disp(['Fourth done at ',datestr(now)])
% data_table_5 = webread(db_query_5,webopts);
% disp(['Fifth done at ',datestr(now)])

%%

combined_data = [data_table_1;data_table_2;data_table_3;data_table_4];



%%
hyde_tt_raw = table2timetable(combined_data,'RowTimes',datetime(combined_data{:,1:6}));
hyde_tt_raw(:,1:6)= [];
%%




new_varnames = cell(1,length(select_vars));

for ii = 1:length(select_vars)
    idx = strcmp(strrep(select_vars{ii},'.','_'),hyde_tt_raw.Properties.VariableNames);
    if sum(idx) ~= 1
        break
    end
    disp(['Original variable number ',num2str(ii),' ',select_vars{ii},' or ',short_varnames{ii},', is going on place ',num2str(find(idx)),' ',hyde_tt_raw.Properties.VariableNames{idx}])
    new_varnames{idx} = short_varnames{ii};
end
%%
hyde_tt_raw.Properties.VariableNames = new_varnames;
hyde_tt_raw.Time.TimeZone = '+02:00';

% uncomment to save variables
% save('../vars/hyde_tt_raw','hyde_tt_raw')
% writetimetable(hyde_tt_raw,'../data/hyde_raw_data.txt');