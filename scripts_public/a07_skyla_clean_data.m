close all
clear variables

load('../vars/skyla_tt_zenith_filtered.mat')

%% calculate daily values. Albedo and SW balance will be calculated later

% save a copy of the zenith filtered data
skyla_tt = skyla_tt_zenith_filtered;

% in 2013 and 2014 the Halssiaapa data has negative values set to NaN in
% some stage of the processing. THese occur mainly in the nighttime. This
% leads to no daily values being calculated. Change nighttime nan values
% from those years to zero
skyla_tt_zenith_filtered.GLOB_peat(skyla_tt_zenith_filtered.zenith_skyla>90 & skyla_tt_zenith_filtered.Time.Year<2014.1) = 0;
skyla_tt_zenith_filtered.REFL_peat(skyla_tt_zenith_filtered.zenith_skyla>90 & skyla_tt_zenith_filtered.Time.Year<2014.1) = 0;


% change the night-time values to zero also in other years, if they are not
% missing
skyla_tt_zenith_filtered.GLOB_forest(skyla_tt_zenith_filtered.zenith_skyla>90 & ~isnan(skyla_tt_zenith_filtered.GLOB_forest)) = 0;
skyla_tt_zenith_filtered.GLOB_peat(skyla_tt_zenith_filtered.zenith_skyla>90 & ~isnan(skyla_tt_zenith_filtered.GLOB_peat)) = 0;

skyla_tt_zenith_filtered.REFL_forest(skyla_tt_zenith_filtered.zenith_skyla>90 & ~isnan(skyla_tt_zenith_filtered.REFL_forest)) = 0;
skyla_tt_zenith_filtered.REFL_peat(skyla_tt_zenith_filtered.zenith_skyla>90 & ~isnan(skyla_tt_zenith_filtered.REFL_peat)) = 0;




% diffuse radiation is clipped at zero for early years

diffuse_to_zero = ((skyla_tt_zenith_filtered.Time.Year>2012.5 & skyla_tt_zenith_filtered.Time.Year<2015.5) | skyla_tt_zenith_filtered.Time.Year == 2023) & isnan(skyla_tt_zenith_filtered.diffGlob) & skyla_tt_zenith_filtered.GLOB_forest<0.1;
skyla_tt_zenith_filtered.diffGlob(diffuse_to_zero) = 0;



% halssiaapa often has 30 min breaks in the data, e.g. Jun 14, 2013.
% Gapfill these to get better data coverage for the daily values, linear
% interpolation


skyla_tt_zenith_filtered.REFL_peat = fillmissing(skyla_tt_zenith_filtered.REFL_peat,'linear','MaxGap',2);
skyla_tt_zenith_filtered.REFL_forest = fillmissing(skyla_tt_zenith_filtered.REFL_forest,'linear','MaxGap',2);

skyla_tt_zenith_filtered.GLOB_peat = fillmissing(skyla_tt_zenith_filtered.GLOB_peat,'linear','MaxGap',2);
skyla_tt_zenith_filtered.GLOB_forest = fillmissing(skyla_tt_zenith_filtered.GLOB_forest,'linear','MaxGap',2);


% for low zenith angles allow longer gaps
zenith_lim = 87;

skyla_tt_zenith_filtered.REFL_peat_gapfilled = fillmissing(skyla_tt_zenith_filtered.REFL_peat,'linear','MaxGap',3);
skyla_tt_zenith_filtered.REFL_forest_gapfilled  = fillmissing(skyla_tt_zenith_filtered.REFL_forest,'linear','MaxGap',3);

skyla_tt_zenith_filtered.GLOB_peat_gapfilled  = fillmissing(skyla_tt_zenith_filtered.GLOB_peat,'linear','MaxGap',3);
skyla_tt_zenith_filtered.GLOB_forest_gapfilled  = fillmissing(skyla_tt_zenith_filtered.GLOB_forest,'linear','MaxGap',3);



skyla_tt_zenith_filtered.REFL_peat(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim) = skyla_tt_zenith_filtered.REFL_peat_gapfilled(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim);
skyla_tt_zenith_filtered.REFL_forest(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim) = skyla_tt_zenith_filtered.REFL_forest_gapfilled(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim);

skyla_tt_zenith_filtered.GLOB_peat(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim) = skyla_tt_zenith_filtered.GLOB_peat_gapfilled(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim);
skyla_tt_zenith_filtered.GLOB_forest(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim) = skyla_tt_zenith_filtered.GLOB_forest_gapfilled(skyla_tt_zenith_filtered.zenith_skyla > zenith_lim);



% mean where any nan returns nan
skyla_tt_daily = retime(skyla_tt_zenith_filtered,'daily',@mean);

% save('../vars/skyla_tt_daily','skyla_tt_daily')


%% check days that have average reflected higher, or that have negative daily average radiation





skyla_tt_daily.bad_days_skyla = (skyla_tt_daily.GLOB_forest< skyla_tt_daily.REFL_forest) | sign(skyla_tt_daily.GLOB_forest) == -1 | sign(skyla_tt_daily.REFL_forest) == -1 | skyla_tt_daily.GLOB_forest./skyla_tt_daily.GLOB_peat<0.8;
skyla_tt_daily.bad_days_halssi = (skyla_tt_daily.GLOB_peat < skyla_tt_daily.REFL_peat) | sign(skyla_tt_daily.GLOB_peat) == -1 | sign(skyla_tt_daily.REFL_peat) == -1 | skyla_tt_daily.GLOB_peat./skyla_tt_daily.GLOB_forest<0.8;

skyla_tt.bad_times_skyla = ismember(dateshift(skyla_tt.Time,'start','day'),skyla_tt_daily.Time(skyla_tt_daily.bad_days_skyla));
skyla_tt.bad_times_halssi = ismember(dateshift(skyla_tt.Time,'start','day'),skyla_tt_daily.Time(skyla_tt_daily.bad_days_halssi));



%% check days where the sites have substantially different global radiation


badbad = (skyla_tt_daily.GLOB_forest.\skyla_tt_daily.GLOB_peat)<0.8;
figure();histogram(skyla_tt_daily.GLOB_forest(badbad)./skyla_tt_daily.GLOB_peat(badbad))


fortopeat = skyla_tt_daily.GLOB_forest.\skyla_tt_daily.GLOB_peat;
figure();plot(fortopeat,skyla_tt_daily.GLOB_forest.\skyla_tt_daily.GLOB_peat,'.')

badbad2 = fortopeat<0.8;
figure();histogram(fortopeat(badbad2))
%% plot to check
figure();plot(skyla_tt.Time,skyla_tt.GLOB_peat,skyla_tt.Time,skyla_tt.REFL_peat,skyla_tt_daily.Time+hours(12),skyla_tt_daily.GLOB_peat,'*-',skyla_tt_daily.Time+hours(12),skyla_tt_daily.REFL_peat,'*-',skyla_tt_daily.Time(skyla_tt_daily.bad_days_halssi)+hours(12),skyla_tt_daily.REFL_peat(skyla_tt_daily.bad_days_halssi),'k*')
title('Halssiaapa')
figure();plot(skyla_tt.Time,skyla_tt.GLOB_forest,skyla_tt.Time,skyla_tt.REFL_forest,skyla_tt_daily.Time+hours(12),skyla_tt_daily.GLOB_forest,skyla_tt_daily.Time+hours(12),skyla_tt_daily.REFL_forest,skyla_tt_daily.Time(skyla_tt_daily.bad_days_skyla)+hours(12),skyla_tt_daily.REFL_forest(skyla_tt_daily.bad_days_skyla),'k*')
title('Skyla')


% bad days during winter, in Halssiaapa longer towards spring


%% plot albedo vs zenith, see how filtering improves


figure();
plot(skyla_tt_zenith_filtered.zenith_skyla,skyla_tt_zenith_filtered.albedo_halssi,'*')
hold on
plot(skyla_tt_zenith_filtered.zenith_skyla,skyla_tt_zenith_filtered.albedo_skyla,'*')
title('Before day mean filtering')
legend('Halssiaapa','Sodankylä forest')



figure();
plot(skyla_tt_zenith_filtered.zenith_skyla(~skyla_tt.bad_times_halssi),skyla_tt_zenith_filtered.albedo_halssi(~skyla_tt.bad_times_halssi),'*')
hold on
plot(skyla_tt_zenith_filtered.zenith_skyla(~skyla_tt.bad_times_skyla),skyla_tt_zenith_filtered.albedo_skyla(~skyla_tt.bad_times_skyla),'*')
title('After day mean filtering')
legend('Halssiaapa','Sodankylä forest')



%%
font_size = 36;

figure('OuterPosition',[200 200 1920 1080]);
histogram(skyla_tt.net_SW_skyla)
xlabel('Net SW radiation','FontSize',font_size)
title({'Sodadnkylä, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_skyla_sw_balance.pdf')

%%


figure('OuterPosition',[200 200 1920 1080]);
histogram(skyla_tt.albedo_skyla(skyla_tt.albedo_skyla<5 & skyla_tt.albedo_skyla > -5))
xlabel('Albedo','FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_skyla_sw_balance.pdf')
% run this on no zenith filtering data
% vast majority of the non-filtered albedoes during daytime still fall
% between 0 and 1

skyla_within_lims = sum(skyla_tt.albedo_skyla(skyla_tt.albedo_skyla<5 & skyla_tt.albedo_skyla > -5)>0 & skyla_tt.albedo_skyla(skyla_tt.albedo_skyla<5 & skyla_tt.albedo_skyla > -5)<1)/sum(skyla_tt.albedo_skyla<5 & skyla_tt.albedo_skyla > -5);

title(['Skyla daytime albedoes, ',num2str(skyla_within_lims*100),' % between 0 and 1'])

% histogram has peaks at 0, 0.5, 1, 2 etc: some processing has been done to
% at least part of data. Clip values where reflected is above incoming? 



%%
figure('OuterPosition',[200 200 1920 1080]);
histogram(skyla_tt.net_SW_halssi)
xlabel('Net SW radiation','FontSize',font_size)
title({'Halssiaapa, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_halssi_sw_balance.pdf')

% skyla has most values above zero, clipping at zero won't biat too much.
% Halssi has substantial amount of data below zero


%%
figure('OuterPosition',[200 200 1920 1080]);
histogram(skyla_tt.albedo_halssi(skyla_tt.albedo_halssi<5 & skyla_tt.albedo_halssi > -5))
xlabel('Albedo','FontSize',font_size)
% title({'Hyytiälä, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_skyla_sw_balance.pdf')
% run this on no zenith filtering data
% vast majority of the non-filtered albedoes during daytime still fall
% between 0 and 1

halssi_within_lims = sum(skyla_tt.albedo_halssi(skyla_tt.albedo_halssi<5 & skyla_tt.albedo_halssi > -5)>0 & skyla_tt.albedo_halssi(skyla_tt.albedo_halssi<5 & skyla_tt.albedo_halssi > -5)<1)/sum(skyla_tt.albedo_halssi<5 & skyla_tt.albedo_halssi > -5);

title(['Halssiaapa albedoes, ',num2str(halssi_within_lims*100),' % between 0 and 1'])




%%
% filter out too low and high values, 
albedo_threshold_high = 1.1;
albedo_threshold_low = -0.3;



skyla_tt.albedo_skyla(skyla_tt.albedo_skyla<albedo_threshold_low|skyla_tt.albedo_skyla>albedo_threshold_high) = NaN;


skyla_tt.albedo_halssi(skyla_tt.albedo_halssi<albedo_threshold_low|skyla_tt.albedo_halssi>albedo_threshold_high) = NaN;




%%
figure();
histogram2(skyla_tt.GLOB_peat,skyla_tt.REFL_peat)

figure();plot(skyla_tt.zenith_skyla,skyla_tt.GLOB_peat,'*')



figure();plot(skyla_tt.GLOB_peat,skyla_tt.albedo_halssi,'*')
grid on
ylim([-2 6])
%  halssiaapa has substantial number of albedoes over one even at higher
%  global radiations

hold on
plot(skyla_tt.GLOB_peat(skyla_tt.bad_times_halssi),skyla_tt.albedo_halssi(skyla_tt.bad_times_halssi),'r*')
% large fraction of those are filtered by the daily mean approach

%%

figure();plot(skyla_tt.GLOB_forest,skyla_tt.albedo_skyla,'*')
grid on
% skyla has a considerable number of high albedoes (around 1.5) at
% higher radiations as well (around 100 w/m2)

hold on
plot(skyla_tt.GLOB_forest(skyla_tt.bad_times_skyla),skyla_tt.albedo_skyla(skyla_tt.bad_times_skyla),'r*')

% large fraction of those are filtered by the daily mean approach


%%
glob_threshold = 6;
figure();plot(skyla_tt.Time,skyla_tt.albedo_skyla)
hold on
plot(skyla_tt.Time(skyla_tt.GLOB_forest<glob_threshold),skyla_tt.albedo_skyla(skyla_tt.GLOB_forest<glob_threshold),'r*')


% filter out global radiations under 6 w/m2



figure();plot(skyla_tt.Time(~(skyla_tt.GLOB_forest<glob_threshold)),skyla_tt.albedo_skyla(~(skyla_tt.GLOB_forest<glob_threshold)))
% still messy picture: typically the first and last values of day are bad.
% Daily medians might help:


figure();plot(skyla_tt.Time,skyla_tt.albedo_halssi)
hold on
plot(skyla_tt.Time(skyla_tt.GLOB_peat<glob_threshold),skyla_tt.albedo_halssi(skyla_tt.GLOB_peat<glob_threshold),'r*')


% filter out global radiations under 6 w/m2



figure();plot(skyla_tt.Time(~(skyla_tt.GLOB_peat<glob_threshold)),skyla_tt.albedo_halssi(~(skyla_tt.GLOB_peat<glob_threshold)))
% still messy picture: typically the first and last values of day are bad.
% Daily medians might help:


%%


% calculate the final daily albedoes from zenith-filtered data, as
% below-horizon time points only add noise. Calculate as a ratio of daily means
skyla_tt_daily.albedo_skyla = skyla_tt_daily.REFL_forest./skyla_tt_daily.GLOB_forest;
skyla_tt_daily.albedo_halssi = skyla_tt_daily.REFL_peat./skyla_tt_daily.GLOB_peat;


skyla_tt_daily.PAR_albedo_skyla = skyla_tt_daily.RPAR_forest./skyla_tt_daily.PAR_forest;
skyla_tt_daily.PAR_albedo_halssi = skyla_tt_daily.RPAR_peat./skyla_tt_daily.PAR_peat;

skyla_tt_daily.diff_frac = skyla_tt_daily.diffGlob./skyla_tt_daily.GLOB_forest;
skyla_tt.diff_frac = skyla_tt.diffGlob./skyla_tt.GLOB_forest;


% also calculate the net values for the daily data here. Again
% zenith-filtered
skyla_tt_daily.net_SW_skyla = skyla_tt_daily.GLOB_forest - skyla_tt_daily.REFL_forest;
skyla_tt_daily.net_SW_halssi = skyla_tt_daily.GLOB_peat - skyla_tt_daily.REFL_peat;




%% plot albedoes calculated in different methods



figure(); 
plot(skyla_tt.Time,[skyla_tt.GLOB_peat,-1*skyla_tt.REFL_peat]);
hold on;
plot(skyla_tt_daily.Time+hours(12),[skyla_tt_daily.GLOB_peat,-1*skyla_tt_daily.REFL_peat,skyla_tt_daily.GLOB_peat-skyla_tt_daily.REFL_peat],'-*');
title('Halssi');
aksi(1) = gca;


figure(); 
plot(skyla_tt.Time,[skyla_tt.GLOB_forest,-1*skyla_tt.REFL_forest]);
hold on;
plot(skyla_tt_daily.Time+hours(12),[skyla_tt_daily.GLOB_forest,-1*skyla_tt_daily.REFL_forest,skyla_tt_daily.GLOB_forest-skyla_tt_daily.REFL_forest],'-*');
title('Skyla');
aksi(2) = gca;


figure();plot(skyla_tt_daily.Time+hours(12),[skyla_tt_daily.albedo_halssi,skyla_tt_daily.bad_days_halssi]);aksi(3) = gca;
title('halssi')
% legend('Average of ratios','ratio of averages')
aksi(3) = gca;

figure();plot(skyla_tt_daily.Time+hours(12),[skyla_tt_daily.albedo_skyla,skyla_tt_daily.bad_days_skyla]);aksi(4) = gca;
title('skyla')
% legend('Average of ratios','ratio of averages')
aksi(4) = gca;
linkaxes(aksi,'x')




%%

figure();plot(skyla_tt_daily.Time,skyla_tt_daily.albedo_halssi)
aksi(5) = gca;
figure();plot(skyla_tt_daily.Time,skyla_tt_daily.albedo_skyla)
aksi(6) = gca;

linkaxes(aksi,'x')

% now both albedo time series look OK without outrageous filtering

%%

% drop the days with mean reflected higher than mean global from both daily
% and 30 min data (only for albedo and net SW, other data remains)
skyla_tt.albedo_halssi(skyla_tt.bad_times_halssi) = NaN;
skyla_tt.albedo_skyla(skyla_tt.bad_times_skyla) = NaN;

skyla_tt.net_SW_halssi(skyla_tt.bad_times_halssi) = NaN;
skyla_tt.net_SW_skyla(skyla_tt.bad_times_skyla) = NaN;

skyla_tt_daily.albedo_skyla(skyla_tt_daily.bad_days_skyla) = NaN;
skyla_tt_daily.albedo_halssi(skyla_tt_daily.bad_days_halssi) = NaN;


skyla_tt_daily.net_SW_skyla(skyla_tt_daily.bad_days_skyla) = NaN;
skyla_tt_daily.net_SW_halssi(skyla_tt_daily.bad_days_halssi) = NaN;


%%

figure();plot(skyla_tt_daily.Time,skyla_tt_daily.albedo_halssi,'-*')
aksi(7) = gca;
figure();plot(skyla_tt_daily.Time,skyla_tt_daily.albedo_skyla,'-*')
aksi(8) = gca;

linkaxes(aksi,'x')

%% then check the net radiation



figure();plot(skyla_tt.Time,skyla_tt.net_SW_skyla)
title('Skyla net radiation. 30 min')

figure();plot(skyla_tt.Time,skyla_tt.net_SW_halssi)
title('Halssi net radiation, 30 min ')
% some gaps


figure();plot(skyla_tt.Time,skyla_tt.net_SW_halssi-skyla_tt.net_SW_skyla)
title('Net radiation difference, 30 min')
figure();plot(skyla_tt_daily.Time,skyla_tt_daily.net_SW_halssi-skyla_tt_daily.net_SW_skyla)
title('Net radiation difference, daily')

%%

skyla_tt.net_difference = skyla_tt.net_SW_halssi-skyla_tt.net_SW_skyla;


%% calculate derivative quantities

% mainly focus on daily values as there is less random scatter

skyla_tt.mean_glob = mean([skyla_tt.GLOB_forest,skyla_tt.GLOB_peat],2);
skyla_tt.SW_balance_difference = skyla_tt.net_SW_skyla - skyla_tt.net_SW_halssi;



% calculate the mean glob from the two sites. If other one has no data, use
% only one site
skyla_tt_daily.mean_glob = mean([skyla_tt_daily.GLOB_forest,skyla_tt_daily.GLOB_peat],2,'omitnan');
skyla_tt_daily.SW_balance_difference = skyla_tt_daily.net_SW_skyla - skyla_tt_daily.net_SW_halssi;


skyla_tt_daily.DOY = day(skyla_tt_daily.Time,'dayofyear');
skyla_tt_daily.week = week(skyla_tt_daily.Time);



% gapfill the snow depth data. This will be used to calculate yearly
% statistics
% There are many gaps of a couple of days,
% some longer gaps in the summertime. The longest gap starts in Jan 2012,
% don't fill that 
skyla_tt_daily.SDepth_peat_gapfilled = fillmissing(skyla_tt_daily.SDepth_peat,'linear','SamplePoints',skyla_tt_daily.Time,'MaxGap',days(35));
skyla_tt_daily.SDepth_forest_gapfilled = fillmissing(skyla_tt_daily.SDepth_forest,'linear','SamplePoints',skyla_tt_daily.Time,'MaxGap',days(35));

%%

figu = figure();plot(skyla_tt_daily.Time+hours(12),skyla_tt_daily.SDepth_peat,'.-',skyla_tt_daily.Time+hours(12),skyla_tt_daily.SDepth_peat_gapfilled+90,'*-')
title('Halssiaapa snow depth')
legend('Original','Gapfilled')
% the snow cover data from the forest is more sparse, only use peatland
% site
% save_figure_OP(figu,'../figs/halssi_SD_gapfill')

% indicator variable for if the ground is snowcovered 
% (daily average snow depth over 1 cm)
skyla_tt_daily.Snowcover_peat = skyla_tt_daily.SDepth_peat_gapfilled>1;
skyla_tt_daily.Snowcover_forest = skyla_tt_daily.SDepth_forest_gapfilled>1;


figure();histogram(skyla_tt_daily.SDepth_peat(skyla_tt_daily.Time.Month<6),'NumBins',50)


%%
% save('../vars/skyla_tt_cleaned.mat','skyla_tt')
% save('../vars/skyla_tt_daily_cleaned.mat','skyla_tt_daily')

% writetimetable(skyla_tt_daily,'../data/skyla_tt_daily_cleaned.txt');
% writetimetable(skyla_tt,'../data/skyla_tt_cleaned.txt');
