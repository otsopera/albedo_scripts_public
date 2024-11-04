close all
clear variables

load('../vars/skyla_tt_raw.mat')

%% calculate albedoes and net radiations

skyla_tt_raw.albedo_skyla = skyla_tt_raw.REFL_forest./skyla_tt_raw.GLOB_forest;
skyla_tt_raw.albedo_halssi = skyla_tt_raw.REFL_peat./skyla_tt_raw.GLOB_peat;

skyla_tt_raw.net_SW_skyla = skyla_tt_raw.GLOB_forest - skyla_tt_raw.REFL_forest;
skyla_tt_raw.net_SW_halssi = skyla_tt_raw.GLOB_peat- skyla_tt_raw.REFL_peat;


%% plot data for checking

idx = 1;

figure();plot(skyla_tt_raw.Time, [skyla_tt_raw.GLOB_forest,-1*skyla_tt_raw.REFL_forest])
title('skyla glob and refl')
aksi(idx) = gca;
idx = idx + 1;


figure();plot(skyla_tt_raw.Time, [skyla_tt_raw.GLOB_peat,-1*skyla_tt_raw.REFL_peat])
title('halssi glob and refl')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(skyla_tt_raw.Time,skyla_tt_raw.albedo_skyla)
title('skyla albedo, no filtering')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(skyla_tt_raw.Time,skyla_tt_raw.albedo_halssi)
title('halssi albedo, no filtering')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(skyla_tt_raw.Time,skyla_tt_raw.net_SW_skyla)
title('skyla net, no filtering')
aksi(idx) = gca;
idx = idx + 1;

figure();plot(skyla_tt_raw.Time,skyla_tt_raw.net_SW_halssi)
title('halssi net, no filtering')
aksi(idx) = gca;
idx = idx + 1;

figure();plot(skyla_tt_raw.Time,skyla_tt_raw.net_SW_skyla-skyla_tt_raw.net_SW_halssi)
title('skyla net - halssi net, no filtering')
aksi(idx) = gca;
idx = idx + 1;


linkaxes(aksi,'x')




%% calculate zenith angles



location_halssi.longitude = 26.65117; 
location_halssi.latitude = 67.36707; 
location_halssi.altitude = 180;




location_skyla.longitude =  26.633; 
location_skyla.latitude = 67.368; 
location_skyla.altitude = 179;

tic
for ii = 1:height(skyla_tt_raw)
    time.year = skyla_tt_raw.Time.Year(ii);
    time.month = skyla_tt_raw.Time.Month(ii);
    time.day = skyla_tt_raw.Time.Day(ii);  
    time.hour = skyla_tt_raw.Time.Hour(ii);
    time.min = skyla_tt_raw.Time.Minute(ii) + 15; % calculate position in the middle of the averaging time
    time.sec = 0;
    time.UTC = 0;

    sunp = sun_position(time, location_skyla);
    skyla_tt_raw.zenith_skyla(ii) = sunp.zenith;
    skyla_tt_raw.azimuth_skyla(ii) = sunp.azimuth;
end
toc
% takes 20 min



% save('../vars/skyla_tt_zeniths',"skyla_tt")

%% bypass calculation if they've been calculated previously

skyla_tt_zeniths = load('../vars/skyla_tt_zeniths');


skyla_tt_raw.zenith_skyla = skyla_tt_zeniths.skyla_tt.zenith_skyla;
skyla_tt_raw.azimuth_skyla = skyla_tt_zeniths.skyla_tt.azimuth_skyla;


%%

zenith_threshold_albedo = 92;


yl = [-5 5];

figure();
plot(skyla_tt_raw.zenith_skyla,[skyla_tt_raw.albedo_halssi,skyla_tt_raw.albedo_skyla],'*')
hold on
plot([zenith_threshold_albedo zenith_threshold_albedo],yl,'LineWidth',5)

ylim(yl)

%% only filter albedo, leave original values untouched





skyla_tt_zenith_filtered = skyla_tt_raw;

skyla_tt_zenith_filtered.albedo_skyla(skyla_tt_zenith_filtered.zenith_skyla> zenith_threshold_albedo) = NaN;
skyla_tt_zenith_filtered.albedo_halssi(skyla_tt_zenith_filtered.zenith_skyla > zenith_threshold_albedo) = NaN;


skyla_tt_zenith_filtered.albedo_halssi(skyla_tt_zenith_filtered.albedo_halssi>2) = NaN;
skyla_tt_zenith_filtered.albedo_halssi(skyla_tt_zenith_filtered.albedo_halssi<-1) = NaN;
skyla_tt_zenith_filtered.albedo_skyla(skyla_tt_zenith_filtered.albedo_skyla>2) = NaN;
skyla_tt_zenith_filtered.albedo_skyla(skyla_tt_zenith_filtered.albedo_skyla<-1) = NaN;



%% plot data for checking

idx = 1;

figure();plot(skyla_tt_zenith_filtered.Time,skyla_tt_zenith_filtered.albedo_skyla)
title('Skyla albedo')
aksi(idx) = gca;
idx = idx + 1;



figure();plot(skyla_tt_zenith_filtered.Time,skyla_tt_zenith_filtered.albedo_halssi)
title('Halssi albedo')
aksi(idx) = gca;
idx = idx + 1;




linkaxes(aksi,'x')


% still have bad values in albedo



%%

% save('../vars/skyla_tt_zenith_filtered','skyla_tt_zenith_filtered')
% writetimetable(skyla_tt_zenith_filtered,'../data/skyla_tt_zenith_filtered.txt');