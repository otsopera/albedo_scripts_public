close all
clear variables

load('../vars/hyde_tt_zenith_filtered.mat')
% load('../vars/hyde_tt_daily.mat')



%% calculate daily values. Albedo and SW balance will be calculated later

% save a copy of the zenith filtered data
hyde_tt = hyde_tt_zenith_filtered;



% change the night-time values to zero if they are not missing for the
% calculation of daily averages
hyde_tt_zenith_filtered.Glob_HYY_tower(hyde_tt_zenith_filtered.zenith_hyde>90 & ~isnan(hyde_tt_zenith_filtered.Glob_HYY_tower)) = 0;
hyde_tt_zenith_filtered.Glob_SII(hyde_tt_zenith_filtered.zenith_siika>90 & ~isnan(hyde_tt_zenith_filtered.Glob_SII)) = 0;

hyde_tt_zenith_filtered.RGlob_HYY125(hyde_tt_zenith_filtered.zenith_hyde>90 & ~isnan(hyde_tt_zenith_filtered.RGlob_HYY125)) = 0;
hyde_tt_zenith_filtered.RGlob_SII(hyde_tt_zenith_filtered.zenith_siika>90 & ~isnan(hyde_tt_zenith_filtered.RGlob_SII)) = 0;



hyde_tt_daily = retime(hyde_tt_zenith_filtered,'daily',@mean); % use mean for daily values, as during half of the year the median radiation is zero. Nighttime values have been changed to zero so they don't add noise


%%

% calculate days when on average the reflected radiation is higher than
% incoming, or either is negative

% or the incoming radiation is over 20 % less than the other site
hyde_tt_daily.bad_days_hyde = (hyde_tt_daily.Glob_HYY_tower < hyde_tt_daily.RGlob_HYY125) | sign(hyde_tt_daily.Glob_HYY_tower) == -1 | sign(hyde_tt_daily.RGlob_HYY125) == -1 | hyde_tt_daily.Glob_HYY_tower./hyde_tt_daily.Glob_SII<0.8;
hyde_tt_daily.bad_days_siika = (hyde_tt_daily.Glob_SII < hyde_tt_daily.RGlob_SII) | sign(hyde_tt_daily.Glob_SII) == -1 | sign(hyde_tt_daily.RGlob_SII) == -1 | hyde_tt_daily.Glob_SII./hyde_tt_daily.Glob_HYY_tower<0.8;




hyde_tt.bad_times_siika = ismember(dateshift(hyde_tt.Time,'start','day'),hyde_tt_daily.Time(hyde_tt_daily.bad_days_siika));
hyde_tt.bad_times_hyde = ismember(dateshift(hyde_tt.Time,'start','day'),hyde_tt_daily.Time(hyde_tt_daily.bad_days_hyde));

%% plots
figure();plot(hyde_tt_daily.Time,hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Time,hyde_tt_daily.RGlob_HYY125,hyde_tt_daily.Time(hyde_tt_daily.bad_days_hyde),hyde_tt_daily.RGlob_HYY125(hyde_tt_daily.bad_days_hyde),'k*')
figure();plot(hyde_tt_daily.Time,hyde_tt_daily.Glob_SII,hyde_tt_daily.Time,hyde_tt_daily.RGlob_SII,hyde_tt_daily.Time(hyde_tt_daily.bad_days_siika),hyde_tt_daily.RGlob_SII(hyde_tt_daily.bad_days_siika),'k*')

% these bad days occur during the winter


%% plot albedo vs zenith, see how filtering improves

figure();
plot(hyde_tt_zenith_filtered.zenith_siika,hyde_tt_zenith_filtered.albedo_siika,'*')
hold on
plot(hyde_tt_zenith_filtered.zenith_hyde,hyde_tt_zenith_filtered.albedo_hyde,'*')
title('Before day mean filtering')
legend('Siikaneva','Hyytiälä')


figure();
plot(hyde_tt_zenith_filtered.zenith_siika(~hyde_tt.bad_times_siika),hyde_tt_zenith_filtered.albedo_siika(~hyde_tt.bad_times_siika),'*')
hold on
plot(hyde_tt_zenith_filtered.zenith_hyde(~hyde_tt.bad_times_hyde),hyde_tt_zenith_filtered.albedo_hyde(~hyde_tt.bad_times_hyde),'*')
title('After day mean filtering')
legend('Siikaneva','Hyytiälä')




%%
font_size = 36;

figure('OuterPosition',[200 200 1920 1080]);
histogram(hyde_tt.net_SW_hyde)
xlabel('Net SW radiation','FontSize',font_size)
title({'Hyytiälä, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_hyde_sw_balance.pdf')
%%
font_size = 36;



figure('OuterPosition',[200 200 1920 1080]);
histogram(hyde_tt.albedo_hyde(hyde_tt.albedo_hyde<2 & hyde_tt.albedo_hyde > -1))
xlabel('Albedo','FontSize',font_size)
% title({'Hyytiälä, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_hyde_sw_balance.pdf')
% run this on no zenith filtering data
% vast majority of the non-filtered albedoes during daytime still fall
% between 0 and 1

hyde_within_lims = sum(hyde_tt.albedo_hyde(hyde_tt.zenith_hyde <90)>0 & hyde_tt.albedo_hyde(hyde_tt.zenith_hyde <90)<1)/sum(~isnan(hyde_tt.albedo_hyde) & hyde_tt.zenith_hyde <90);
hyde_within_lims_wide = sum(hyde_tt.albedo_hyde(hyde_tt.zenith_hyde <90)>-0.3 & hyde_tt.albedo_hyde(hyde_tt.zenith_hyde <90)<1.1)/sum(~isnan(hyde_tt.albedo_hyde) & hyde_tt.zenith_hyde <90);

title(['Hyytiälä daytime albedoes, ',num2str(hyde_within_lims*100),' % between 0 and 1'])


% specifically 97.15 %



%%
figure('OuterPosition',[200 200 1920 1080]);
histogram(hyde_tt.net_SW_siika)
xlabel('Net SW radiation','FontSize',font_size)
title({'Siikaneva, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_siika_sw_balance.pdf')

% based on the histograms we won't bias the observations too much if we
% clip the 30 min values below zero

%%
figure('OuterPosition',[200 200 1920 1080]);
histogram(hyde_tt.albedo_siika(hyde_tt.albedo_siika<5 & hyde_tt.albedo_siika > -5 & hyde_tt.zenith_hyde <90))
xlabel('Albedo','FontSize',font_size)
% title({'Hyytiälä, 30 min data','After zenith angle filtering, no other filtering'},'FontSize',font_size)
ylabel('Count','FontSize',font_size)
set(gca,'FontSize',font_size)
% exportgraphics(gcf,'../figs/histogram_hyde_sw_balance.pdf')
% run this on no zenith filtering data
% vast majority of the non-filtered albedoes during daytime still fall
% between 0 and 1

siika_within_lims = sum(hyde_tt.albedo_siika(hyde_tt.zenith_siika<90)>0 & hyde_tt.albedo_siika(hyde_tt.zenith_siika<90)<1)/sum(~isnan(hyde_tt.albedo_siika(hyde_tt.zenith_siika<90)));
siika_within_lims_wide = sum(hyde_tt.albedo_siika(hyde_tt.zenith_siika<90)>-0.3 & hyde_tt.albedo_siika(hyde_tt.zenith_siika<90)<1.3)/sum(~isnan(hyde_tt.albedo_siika(hyde_tt.zenith_siika<90)));

title(['Siikaneva albedoes, ',num2str(siika_within_lims*100),' % between 0 and 1'])

% here 96 %


%% filter out outrageously low and high values, 
albedo_threshold_high = 1.3;
albedo_threshold_low = -0.3;

hyde_tt.albedo_hyde(hyde_tt.albedo_hyde<albedo_threshold_low|hyde_tt.albedo_hyde>albedo_threshold_high) = NaN;

hyde_tt.albedo_siika(hyde_tt.albedo_siika<albedo_threshold_low|hyde_tt.albedo_siika>albedo_threshold_high) = NaN;

%%
figure();
histogram2(hyde_tt.Glob_HYY_tower,hyde_tt.RGlob_HYY125)

figure();plot(hyde_tt.zenith_hyde,hyde_tt.Glob_HYY_tower,'*')



figure();plot(hyde_tt.Glob_HYY_tower,hyde_tt.albedo_hyde,'*')
grid on
%  in Hyde all ridiculously high albedoes at glob under 6 w/m2
%%

figure();plot(hyde_tt.Glob_SII,hyde_tt.albedo_siika,'*')
grid on
% siikaneva has a considerable number of high albedoes (around 1.5) at
% higher radiations as well (around 100 w/m2)

hold on
plot(hyde_tt.Glob_SII(hyde_tt.bad_times_siika),hyde_tt.albedo_siika(hyde_tt.bad_times_siika),'r*')

% majority of those will be filtered by the daily mean approach


%%

figure();plot(hyde_tt.Time,hyde_tt.albedo_hyde)
hold on
plot(hyde_tt.Time(hyde_tt.Glob_HYY_tower<6),hyde_tt.albedo_hyde(hyde_tt.Glob_HYY_tower<6),'r*')


% filter out global radiations under 6 w/m2



figure();plot(hyde_tt.Time(~(hyde_tt.Glob_HYY_tower<6)),hyde_tt.albedo_hyde(~(hyde_tt.Glob_HYY_tower<6)))
% still messy picture: typically the first and last values of day are bad.
% Daily medians might help:






%% calculate the daily albedoes and SW balances based on the filtered data

% possibilities:
% 1. calculate the daily median or mean of the half-hour sw balances and
% albedoes
% there was a bug/error in thought. Earlier the net sw balances were
% calculated as a mean of the zenith filtered sw balances, which excluded
% all the nighttime values. so it was daytime sw balance, not average over
% whole day
% 2. first calculate the daily mean glob and refl, and then calculate
% albedo based on that


% the first option has not been zenith-filtered
hyde_tt_daily_albe = retime(hyde_tt,'daily','median');

% this has below-horizon values changed to zero
hyde_tt_daily_albe_2 = retime(hyde_tt_zenith_filtered,'daily',@mean);


hyde_tt_daily.albedo_siika_1 = hyde_tt_daily_albe.albedo_siika;
hyde_tt_daily.albedo_hyde_1 = hyde_tt_daily_albe.albedo_hyde;

% also calculate the net values for the daily data here
hyde_tt_daily.net_SW_hyde_1 = hyde_tt_daily_albe.net_SW_hyde;
hyde_tt_daily.net_SW_siika_1 = hyde_tt_daily_albe.net_SW_siika;


% calculate the final daily albedoes from zenith-filtered data, as
% below-horizon time points only add noise. Calculate as a ratio of daily means
hyde_tt_daily.albedo_siika = hyde_tt_daily_albe_2.RGlob_SII./hyde_tt_daily_albe_2.Glob_SII;
hyde_tt_daily.albedo_hyde = hyde_tt_daily_albe_2.RGlob_HYY125./hyde_tt_daily_albe_2.Glob_HYY_tower;


hyde_tt_daily.PAR_albedo_siika = hyde_tt_daily_albe_2.RPAR_SII./hyde_tt_daily_albe_2.PAR_SII;
hyde_tt_daily.PAR_albedo_hyde = hyde_tt_daily_albe_2.RPAR_HYY./hyde_tt_daily_albe_2.PAR_HYY;


hyde_tt_daily.diff_frac = hyde_tt_daily_albe_2.diffPAR_HYY./hyde_tt_daily_albe_2.PAR_HYY;
hyde_tt.diff_frac = hyde_tt.diffPAR_HYY./hyde_tt.PAR_HYY;


% also calculate the net values for the daily data here. Again
% zenith-filtered
hyde_tt_daily.net_SW_hyde = hyde_tt_daily_albe_2.Glob_HYY_tower - hyde_tt_daily_albe_2.RGlob_HYY125;
hyde_tt_daily.net_SW_siika = hyde_tt_daily_albe_2.Glob_SII - hyde_tt_daily_albe_2.RGlob_SII;



% this one calculated as ratio of means, but without zenith filtering.
% Nighttime values are low anyway, so probably no big effect
hyde_tt_daily.net_SW_hyde_3 = hyde_tt_daily.Glob_HYY_tower - hyde_tt_daily.RGlob_HYY125;
hyde_tt_daily.net_SW_siika_3 = hyde_tt_daily.Glob_SII - hyde_tt_daily.RGlob_SII;


% hyde_tt_daily.albedo_hyde_2 = hyde_tt_daily.RGlob_HYY125./hyde_tt_daily.Glob_HYY_tower;
% hyde_tt_daily.albedo_siika_2 = hyde_tt_daily.RGlob_SII./hyde_tt_daily.Glob_SII;

%% plot SW balances calculated with different methods

figure(); 
plot(hyde_tt.Time,[hyde_tt.Glob_HYY_tower,-1*hyde_tt.RGlob_HYY125]);
hold on;
plot(hyde_tt_daily.Time+hours(12),[hyde_tt_daily.Glob_HYY_tower,-1*hyde_tt_daily.RGlob_HYY125,hyde_tt_daily.Glob_HYY_tower-hyde_tt_daily.RGlob_HYY125],'-*');
title('Hyde');
aksi(1) = gca;

figure(); 
plot(hyde_tt.Time,[hyde_tt.Glob_SII,-1*hyde_tt.RGlob_SII]);
hold on;
plot(hyde_tt_daily.Time+hours(12),[hyde_tt_daily.Glob_SII,-1*hyde_tt_daily.RGlob_SII,hyde_tt_daily.Glob_SII-hyde_tt_daily.RGlob_SII],'-*');
title('Siika');
aksi(2) = gca;

figure();plot(hyde_tt_daily.Time+hours(12),hyde_tt_daily.net_SW_hyde_1-hyde_tt_daily.net_SW_siika_1);aksi(3) = gca;linkaxes(aksi,'x')

figure();plot(hyde_tt_daily.Time+hours(12),hyde_tt_daily.net_SW_hyde-hyde_tt_daily.net_SW_siika);aksi(4) = gca;linkaxes(aksi,'x')

figure();plot(hyde_tt_daily.Time+hours(12),hyde_tt_daily.net_SW_hyde_3-hyde_tt_daily.net_SW_siika_3);aksi(5) = gca;linkaxes(aksi,'x')


% with or without zenith filtering, net sw. Very similar values
figure();plot(hyde_tt_daily.net_SW_hyde_3-hyde_tt_daily.net_SW_siika_3,hyde_tt_daily.net_SW_hyde-hyde_tt_daily.net_SW_siika,'*')


%% plot albedoes calculated in different methods

figure(); 
plot(hyde_tt.Time,[hyde_tt.Glob_HYY_tower,-1*hyde_tt.RGlob_HYY125]);
hold on;
plot(hyde_tt_daily.Time+hours(12),[hyde_tt_daily.Glob_HYY_tower,-1*hyde_tt_daily.RGlob_HYY125,hyde_tt_daily.Glob_HYY_tower-hyde_tt_daily.RGlob_HYY125],'-*');
title('Hyde');
aksi(1) = gca;

figure(); 
plot(hyde_tt.Time,[hyde_tt.Glob_SII,-1*hyde_tt.RGlob_SII]);
hold on;
plot(hyde_tt_daily.Time+hours(12),[hyde_tt_daily.Glob_SII,-1*hyde_tt_daily.RGlob_SII,hyde_tt_daily.Glob_SII-hyde_tt_daily.RGlob_SII],'-*');
title('Siika');
aksi(2) = gca;


figure();plot(hyde_tt_daily.Time+hours(12),[hyde_tt_daily.albedo_siika_1,hyde_tt_daily.albedo_siika,hyde_tt_daily.bad_days_siika]);aksi(3) = gca;linkaxes(aksi,'x')
title('Siika')
legend('Average of ratios','ratio of averages')
aksi(3) = gca;

figure();plot(hyde_tt_daily.Time+hours(12),[hyde_tt_daily.albedo_hyde_1,hyde_tt_daily.albedo_hyde,hyde_tt_daily.bad_days_hyde]);aksi(4) = gca;linkaxes(aksi,'x')
title('Hyde')
legend('Average of ratios','ratio of averages')
aksi(4) = gca;

linkaxes(aksi,'x')

figure();plot(hyde_tt_daily.albedo_siika_1,hyde_tt_daily.albedo_siika,'.')


%% discard the non-chosen ones

hyde_tt_daily.net_SW_hyde_1 = [];
hyde_tt_daily.net_SW_siika_1 = [];

hyde_tt_daily.net_SW_hyde_3 = [];
hyde_tt_daily.net_SW_siika_3 = [];

hyde_tt_daily.albedo_siika_1 = [];
hyde_tt_daily.albedo_hyde_1 = [];



%%
figure();plot(hyde_tt_daily.Time,hyde_tt_daily.albedo_hyde)
figure();plot(hyde_tt_daily.Time,hyde_tt_daily.albedo_siika)

% hyde looks pretty good, but noisy

% siika still has some too high values towards the end.
% the days with mean reflected higher than mean global still remain
% plot without

figure();plot(hyde_tt_daily.Time(~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.albedo_hyde(~hyde_tt_daily.bad_days_hyde))
figure();plot(hyde_tt_daily.Time(~hyde_tt_daily.bad_days_siika),hyde_tt_daily.albedo_siika(~hyde_tt_daily.bad_days_siika))

% now both albedo time series look OK without outrageous filtering


%%
% drop the days with mean reflected higher than mean global from both
% daily, and negative daliy values
% and 30 min data (only for albedo and sw balance, other data remains)
hyde_tt.albedo_siika(hyde_tt.bad_times_siika) = NaN;
hyde_tt.albedo_hyde(hyde_tt.bad_times_hyde) = NaN;

hyde_tt_daily.albedo_siika(hyde_tt_daily.bad_days_siika) = NaN;
hyde_tt_daily.albedo_hyde(hyde_tt_daily.bad_days_hyde) = NaN;


hyde_tt.net_SW_siika(hyde_tt.bad_times_siika) = NaN;
hyde_tt.net_SW_hyde(hyde_tt.bad_times_hyde) = NaN;

hyde_tt_daily.net_SW_siika(hyde_tt_daily.bad_days_siika) = NaN;
hyde_tt_daily.net_SW_hyde(hyde_tt_daily.bad_days_hyde) = NaN;



%% then check the net radiation, and calculate their difference



figure();plot(hyde_tt.Time,hyde_tt.net_SW_hyde)

figure();plot(hyde_tt.Time,hyde_tt.net_SW_siika)

% some gaps

hyde_tt.net_difference = hyde_tt.net_SW_siika-hyde_tt.net_SW_hyde;
hyde_tt_daily.net_difference = hyde_tt_daily.net_SW_siika-hyde_tt_daily.net_SW_hyde;

figure();plot(hyde_tt.Time,hyde_tt.net_difference)
figure();plot(hyde_tt_daily.Time,hyde_tt_daily.net_difference)


%%







%%

figure();
aksi(1) = subplot(2,1,1);
plot(hyde_tt.Time,hyde_tt.Glob_SII,hyde_tt.Time,hyde_tt.RGlob_SII)
grid on
legend('Glob','RGlob')
title('Siika')
aksi(2) = subplot(2,1,2);
plot(hyde_tt.Time,hyde_tt.albedo_siika)
hold on 
plot(hyde_tt.Time,hyde_tt.bad_times_siika,'*')
plot(hyde_tt_daily.Time + hours(12),hyde_tt_daily.bad_days_siika,'*')
legend('Albedo','Bad times','Bad days')

linkaxes(aksi,'x')


%% calculate derivative quantities


% mainly focus on daily values as there is less random scatter
hyde_tt.mean_glob = mean([hyde_tt.Glob_HYY_tower,hyde_tt.Glob_SII],2,'omitnan');
hyde_tt.SW_balance_difference = hyde_tt.net_SW_hyde - hyde_tt.net_SW_siika;



hyde_tt_daily.mean_glob = mean([hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_SII],2,'omitnan');
hyde_tt_daily.SW_balance_difference = hyde_tt_daily.net_SW_hyde - hyde_tt_daily.net_SW_siika;
hyde_tt_daily.DOY = day(hyde_tt_daily.Time,'dayofyear');
hyde_tt_daily.week = week(hyde_tt_daily.Time);

hyde_tt_daily.SDepth_SII_gapfilled = fillmissing(hyde_tt_daily.SnowDepth_SII,'linear','SamplePoints',hyde_tt_daily.Time,'EndValues','none');
% Hyytiälä has long gaps in the summer. Sometimes non-zero values only
% start at snowfall, so cannot extrapolate over the whole summer without
% getting a linear increase throughout. Define max gap to be interpolated
hyde_tt_daily.SDepth_HYY_gapfilled = fillmissing(hyde_tt_daily.SnowDepth_HYY,'linear','SamplePoints',hyde_tt_daily.Time,'EndValues','none','MaxGap',days(20));
figure();plot(hyde_tt_daily.Time+hours(12),hyde_tt_daily.SnowDepth_SII,'.-',hyde_tt_daily.Time+hours(12),hyde_tt_daily.SDepth_SII_gapfilled+90,'*-')
title('Siikaneva snow depth')
legend('Original','Gapfilled')

hyde_tt_daily.Snowcover_SII = hyde_tt_daily.SDepth_SII_gapfilled>1;
hyde_tt_daily.Snowcover_HYY = hyde_tt_daily.SDepth_HYY_gapfilled>1;


%%


% uncomment to save variables
% save('../vars/hyde_tt_cleaned.mat','hyde_tt')
% save('../vars/hyde_tt_daily_cleaned.mat','hyde_tt_daily')
