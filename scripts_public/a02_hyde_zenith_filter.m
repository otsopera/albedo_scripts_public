close all
clear variables

load('../vars/hyde_tt_raw.mat')

% or read from text file
% hyde_tt_raw = readtimetable('../data/hyde_raw_data.txt');
% hyde_tt_raw.Time.TimeZone= '+02:00';
%% calculate albedoes and net radiations


hyde_tt_raw.albedo_siika = hyde_tt_raw.RGlob_SII./hyde_tt_raw.Glob_SII;


hyde_tt_raw.albedo_hyde = hyde_tt_raw.RGlob_HYY125./hyde_tt_raw.Glob_HYY_tower;


hyde_tt_raw.net_SW_hyde = hyde_tt_raw.Glob_HYY_tower - hyde_tt_raw.RGlob_HYY125;


hyde_tt_raw.net_SW_siika = hyde_tt_raw.Glob_SII - hyde_tt_raw.RGlob_SII;


%% plot data for checking

idx = 1;

figure();plot(hyde_tt_raw.Time, [hyde_tt_raw.Glob_HYY_tower,-1*hyde_tt_raw.RGlob_HYY125])
title('Hyde glob and refl')
aksi(idx) = gca;
idx = idx + 1;


figure();plot(hyde_tt_raw.Time, [hyde_tt_raw.Glob_SII,-1*hyde_tt_raw.RGlob_SII])
title('Siika glob and refl')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(hyde_tt_raw.Time,hyde_tt_raw.albedo_hyde)
title('Hyde albedo, no filtering')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(hyde_tt_raw.Time,hyde_tt_raw.albedo_siika)
title('Siika albedo, no filtering')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(hyde_tt_raw.Time,hyde_tt_raw.net_SW_hyde)
title('Hyde net, no filtering')
aksi(idx) = gca;
idx = idx + 1;

figure();plot(hyde_tt_raw.Time,hyde_tt_raw.net_SW_siika)
title('Siika net, no filtering')
aksi(idx) = gca;
idx = idx + 1;

figure();plot(hyde_tt_raw.Time,hyde_tt_raw.net_SW_hyde-hyde_tt_raw.net_SW_siika)
title('Hyde net - Siika net, no filtering')
aksi(idx) = gca;
idx = idx + 1;


linkaxes(aksi,'x')



%% calculate zenith angles



location_hyde.longitude = 24.294731344303457; 
location_hyde.latitude = 61.847410676923516; 
location_hyde.altitude = 181;



location_siika.longitude = 24.192757771128644; 
location_siika.latitude = 61.8327067547153; 
location_siika.altitude = 181;


tic
for ii = 1:height(hyde_tt_raw)
    time.year = hyde_tt_raw.Time.Year(ii);
    time.month = hyde_tt_raw.Time.Month(ii);
    time.day = hyde_tt_raw.Time.Day(ii);  
    time.hour = hyde_tt_raw.Time.Hour(ii);
    time.min = hyde_tt_raw.Time.Minute(ii) + 15; % calculate position in the middle of the averaging time
    time.sec = 0;
    time.UTC = 2;
    % uses sun_position function from e.g. https://web.mit.edu/acmath/matlab/IAP2007/Practice/MatlabCentral/sun_position/sun_position.m
    sunp = sun_position(time, location_siika);
    hyde_tt_raw.zenith_siika(ii) = sunp.zenith;
    hyde_tt_raw.azimuth_siika(ii) = sunp.azimuth;
    sunp = sun_position(time, location_hyde);
    hyde_tt_raw.zenith_hyde(ii) = sunp.zenith;
    hyde_tt_raw.azimuth_hyde(ii) = sunp.azimuth;
end
toc

% save the solar angles so that don't need to calculate again if something
% changes 
% save('../vars/hyde_tt_raw_sunp.mat',"hyde_tt_raw")
%%

% if the sun position has already been calculated earlier, save time and
% load that

calculated_earlier = true;
if calculated_earlier
    hyde_tt_zeniths = load('../vars/hyde_tt_zenith_filtered');


    hyde_tt_raw.zenith_hyde = hyde_tt_zeniths.hyde_tt_zenith_filtered.zenith_hyde;
    hyde_tt_raw.zenith_siika = hyde_tt_zeniths.hyde_tt_zenith_filtered.zenith_siika;

    hyde_tt_raw.azimuth_hyde = hyde_tt_zeniths.hyde_tt_zenith_filtered.azimuth_hyde;
    hyde_tt_raw.azimuth_siika = hyde_tt_zeniths.hyde_tt_zenith_filtered.azimuth_siika;
end




%% filter albedo and net radiation values, leave original values untouched

zenith_threshold_albedo = 92;


yl = [-5 5];

figure();
plot(hyde_tt_raw.zenith_hyde,[hyde_tt_raw.albedo_siika,hyde_tt_raw.albedo_hyde],'*')
hold on
plot([zenith_threshold_albedo zenith_threshold_albedo],yl,'LineWidth',5)

ylim(yl)
%%

hyde_tt_zenith_filtered = hyde_tt_raw;

hyde_tt_zenith_filtered.albedo_siika(hyde_tt_zenith_filtered.zenith_siika > zenith_threshold_albedo) = NaN;


hyde_tt_zenith_filtered.albedo_hyde(hyde_tt_zenith_filtered.zenith_hyde > zenith_threshold_albedo) = NaN;


hyde_tt_zenith_filtered.albedo_siika(hyde_tt_zenith_filtered.albedo_siika>2) = NaN;
hyde_tt_zenith_filtered.albedo_siika(hyde_tt_zenith_filtered.albedo_siika<-1) = NaN;
hyde_tt_zenith_filtered.albedo_hyde(hyde_tt_zenith_filtered.albedo_hyde>2) = NaN;
hyde_tt_zenith_filtered.albedo_hyde(hyde_tt_zenith_filtered.albedo_hyde<-1) = NaN;

%% plot data for checking

idx = 1;

figure();plot(hyde_tt_zenith_filtered.Time,hyde_tt_zenith_filtered.albedo_hyde)
title('Hyde albedo')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(hyde_tt_zenith_filtered.Time,hyde_tt_zenith_filtered.albedo_siika)
title('Siika albedo')
aksi(idx) = gca;
idx = idx + 1;




linkaxes(aksi,'x')


%%


% uncomment to save variables
% save('../vars/hyde_tt_zenith_filtered','hyde_tt_zenith_filtered')
% writetimetable(hyde_tt_zenith_filtered,'../data/hyde_tt_zenith_filtered.txt');