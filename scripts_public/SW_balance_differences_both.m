close all
clear variables

load('../vars/skyla_tt_cleaned.mat')
load('../vars/skyla_tt_daily_cleaned.mat')
load('../vars/hyde_tt_cleaned_calibrated.mat')
load('../vars/hyde_tt_daily_cleaned_calibrated.mat')





plot_font_size = 36;

%% Peatland-forest albedo difference vs. mean global radiation: Fig. A10 in manuscript
figi313 = figure();
set(figi313,'outerposition',[200 200 1920 1080]);


marker_size = 40;

scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.albedo_siika-hyde_tt_daily.albedo_hyde,marker_size,'filled');
hold on;
scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.albedo_halssi-skyla_tt_daily.albedo_skyla,marker_size,'filled');
grid on;
set_plot_font(gca,plot_font_size)

legend('Siikaneva-Hyytiälä','Halssiaapa-Halssikangas')
xlabel('Average global radiation between the sites (Wm^{-2})')
ylabel('Albedo difference')

% save_figure_OP(figi313,'../figs/diff_albedo_vs_glob')


%% model the SW balance difference for gapfilling. Prepare variables

% exclude those points from the fit which have gapfilled snow depth
skyla_tt_daily.missing_snowcover = isnan(skyla_tt_daily.SDepth_peat);

hyde_tt_daily.missing_snowcover = isnan(hyde_tt_daily.SnowDepth_SII);



% classify days to deep snow, no snow, or shallow snow
snow_bool_threshold = 30;
nosnow_bool_threshold = 5;
% for SW-relevant times (spring), shallow snow most often observed around
% snowmelt

skyla_tt_daily.deepsnow= skyla_tt_daily.SDepth_peat_gapfilled > snow_bool_threshold;
skyla_tt_daily.nosnow= skyla_tt_daily.SDepth_peat_gapfilled < nosnow_bool_threshold;

skyla_tt.deepsnow= skyla_tt.SDepth_peat> snow_bool_threshold;
skyla_tt.nosnow= skyla_tt.SDepth_peat< nosnow_bool_threshold;

hyde_tt_daily.deepsnow= hyde_tt_daily.SDepth_SII_gapfilled > snow_bool_threshold;
hyde_tt_daily.nosnow= hyde_tt_daily.SDepth_SII_gapfilled < nosnow_bool_threshold;



% a three-category variable for snow depth (useful as interaction term,
% different slopes for each cat
skyla_tt_daily.snow_cat = ones(height(skyla_tt_daily),1);
skyla_tt_daily.snow_cat(skyla_tt_daily.SDepth_peat_gapfilled > nosnow_bool_threshold) = 2;
% now category has 0 if no snow, 1 if snow over lower threshold
skyla_tt_daily.snow_cat(skyla_tt_daily.SDepth_peat_gapfilled > snow_bool_threshold) = 3;
% now 2 if over upper threshold

skyla_tt_daily.summertime_model = skyla_tt_daily.snow_cat == 1&skyla_tt_daily.DOY<251;



% a three-category variable for snow depth (useful as interaction term,
% different slopes for each cat
hyde_tt_daily.snow_cat = ones(height(hyde_tt_daily),1);
hyde_tt_daily.snow_cat(hyde_tt_daily.SDepth_SII_gapfilled > nosnow_bool_threshold) = 2;
% now category has 0 if no snow, 1 if snow over lower threshold
hyde_tt_daily.snow_cat(hyde_tt_daily.SDepth_SII_gapfilled > snow_bool_threshold) = 3;
% now 2 if over upper threshold

hyde_tt_daily.summertime_model = hyde_tt_daily.snow_cat == 1&hyde_tt_daily.DOY<251&hyde_tt_daily.DOY>99;


%%
figure();scatter(skyla_tt.GLOB_forest(~skyla_tt.bad_times_skyla),skyla_tt.REFL_forest(~skyla_tt.bad_times_skyla),50,skyla_tt.zenith_skyla(~skyla_tt.bad_times_skyla),'filled','markeredgecolor',[0 0 0]);colorbar;clim([40 90])
figure();scatter(skyla_tt.GLOB_forest(~skyla_tt.bad_times_skyla),skyla_tt.REFL_forest(~skyla_tt.bad_times_skyla),50,skyla_tt.diff_frac(~skyla_tt.bad_times_skyla),'filled','markeredgecolor',[0 0 0]);colorbar;clim([0 1])
%% SW balance difference vs. glob. Seems to split to snow-cover and no-snow groups: Fig. 9 in manuscript
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_rad = [-60 200];
clim_snow = [0 90];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));





axes(subi1)
scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.SW_balance_difference,90,hyde_tt_daily.SnowDepth_SII,'filled');
% cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in net SW radiation between sites (W m^{-2})')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
ylim(yl_rad)

clim(clim_snow)


axes(subi2)
scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,90,skyla_tt_daily.SDepth_peat,'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Snow depth at the peatland site (cm)')
title('Halssikangas-Halssiaapa pair')
ylim(yl_rad)

clim(clim_snow)
text(subi1,-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')


% save_figure_OP(figi31,'../figs/both_SW_difference_scatter')
% skyla_SW_difference_scatter
%%




figi313 = figure();
set(figi313,'outerposition',[200 200 1920 1080]);


scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,90,skyla_tt_daily.snow_cat,'filled','markeredgecolor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Snow depth category')
title('Sodankylä-Halssiaapa pair')


figi313 = figure();
set(figi313,'outerposition',[200 200 1920 1080]);


scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,90,skyla_tt_daily.deepsnow,'filled','markeredgecolor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Deep snow')
title('Sodankylä-Halssiaapa pair')

%% Difference in net SW radiation vs. glob, only deep snow: Fig. A11 in manuscript
figi321 = figure();


set(figi321,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_rad = [-20 180];
clim_snow = [30 90];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));




axes(subi1)
scatter(hyde_tt_daily.mean_glob(hyde_tt_daily.deepsnow),hyde_tt_daily.SW_balance_difference(hyde_tt_daily.deepsnow),90,hyde_tt_daily.SnowDepth_SII(hyde_tt_daily.deepsnow),'filled','markeredgecolor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in net SW radiation between sites (W m^{-2})')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
clim(clim_snow)
ylim(yl_rad)


axes(subi2)
scatter(skyla_tt_daily.mean_glob(skyla_tt_daily.deepsnow),skyla_tt_daily.SW_balance_difference(skyla_tt_daily.deepsnow),90,skyla_tt_daily.SDepth_peat(skyla_tt_daily.deepsnow),'filled','markeredgecolor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Snow depth at the peatland site (cm)')

title('Halssikangas-Halssiaapa pair')
clim(clim_snow)
ylim(yl_rad)
text(subi1,-0.3,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')


% save_figure_OP(figi321,'../figs/both_SW_difference_scatter_deepsnow')




%% some high albedo points with no snow. Check what's up

figure();
scatter(skyla_tt_daily.SDepth_peat,skyla_tt_daily.albedo_halssi,300,skyla_tt_daily.DOY,'filled','MarkerEdgeColor',[0 0 0]);
colormap(gca,'hsv');
cb=colorbar;
ylabel(cb,'DOY')
title('Halssiaapa')

% these stand out in green on the left edge of the plot

weird_snowless_points_skyla = skyla_tt_daily.albedo_halssi>0.3 & skyla_tt_daily.SDepth_peat < 0.1 & skyla_tt_daily.DOY>70 & skyla_tt_daily.DOY<170;
weird_snowless_points_hyde = hyde_tt_daily.albedo_siika>0.3 & hyde_tt_daily.SnowDepth_SII < 0.1 & hyde_tt_daily.DOY>70 & hyde_tt_daily.DOY<170;
figure();plot(skyla_tt_daily.Time(weird_snowless_points_skyla),[skyla_tt_daily.SDepth_peat(weird_snowless_points_skyla),skyla_tt_daily.SDepth_forest(weird_snowless_points_skyla)],'.','Markersize',100)
hold on;plot(skyla_tt_daily.Time,[skyla_tt_daily.SDepth_peat,skyla_tt_daily.SDepth_forest],'LineWidth',5)


% halssiaapa snow depth goes to zero before the forest one. Maybe snow
% blown away? 
% the highest albedo point is on apr 24., 2021

% this is the webcam image from the intensive observation area:
% https://litdb.fmi.fi/data/webcam/Ccam1/2021/210424_143002_Ccam1.jpg
% shows snow cover
% compared to day before, fresh snow is also seen (explaining high albedo)
% see next to tree trunks:
% https://litdb.fmi.fi/data/webcam/Ccam1/2021/210423_113004_Ccam1.jpg

% exclude these points from the model fit, as the snow depth at the
% peatland site clearly is not representative of the whole area in these
% cases

%% fit a model with snowcover and glob as predictors

% no intercept as sw difference zero when glob is zero. Exclude gapfilled
% snow depths
lm_daily_skyla = fitlm(timetable2table(skyla_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow-1','Exclude',(skyla_tt_daily.missing_snowcover|weird_snowless_points_skyla));
% RMSE 13




figi = figure();scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,100,skyla_tt_daily.SDepth_peat,'filled');colorbar
hold on
plot(skyla_tt_daily.mean_glob,lm_daily_skyla.Fitted,'*')
title('Skyla')
xlabel('Mean global radiation between sites')
ylabel('SW balance difference')
legend('Observed','Predicted')

% general features fitted OK
% the slope of the snow-covered days seems to be a bit low



figure();
plot(skyla_tt_daily.DOY,lm_daily_skyla.Residuals.Raw,'*')
xlabel('DOY')
ylabel('Residuals')
% clear pattern seen in residuals wrt. DOY. 
% first an increase in springtime, prob. due to too low slope for
% snow-covered days
% this is prob. caused by outliers, that have high snow depths but low SW
% balance differences. Try robust fitting next to see if improves


%% fit a model with snowcover and glob as predictors: invludes Fig. A15 in manuscript

% no intercept as sw difference zero when glob is zero. Exclude gapfilled
% snow depths
lm_daily_skyla_2 = fitlm(timetable2table(skyla_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow-1','Exclude',(skyla_tt_daily.missing_snowcover|weird_snowless_points_skyla),'robustopts','on');
% RMSE drops to 5.47 ??? only with a change to robust fitting

lm_daily_hyde_2 = fitlm(timetable2table(hyde_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow-1','Exclude',(hyde_tt_daily.missing_snowcover|weird_snowless_points_hyde),'robustopts','on');
% RMSE drops to 7.06 ??? only with a change to robust fitting


figi = figure();
set(figi,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl = [-50 200];

cl = [0 90];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));


axes(subi(1))

scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.SW_balance_difference,150,hyde_tt_daily.SnowDepth_SII,'filled');
hold on
plot(hyde_tt_daily.mean_glob,lm_daily_hyde_2.Fitted,'*','MarkerSize',10)
title('Hyytiälä-Siikaneva pair')
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in net SW radiation between sites (W m^{-2})')
legend('Observed','Predicted')
set_plot_font(gca,plot_font_size)
clim(cl)

axes(subi(2))
scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,150,skyla_tt_daily.SDepth_peat,'filled');
cb = colorbar;
hold on
plot(skyla_tt_daily.mean_glob,lm_daily_skyla_2.Fitted,'*','MarkerSize',10)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Snow depth at the peatland site (cm)')
title('Halssikangas-Halssiaapa pair')

legend('Observed','Predicted')
set_plot_font(gca,plot_font_size)


ylim(subi,yl)
clim(cl)
text(subi(1),-0.3,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi(2),-0.3,1.05,'b','fontsize',plot_font_size,'units','normalized')


% save_figure_OP(figi,'../figs/both_net_SW_model1')
% general features fitted OK
% the slope of the snow-covered days seems to be a bit low

%% includes Fig. A16 in manuscript

figi24323 = figure();


set(figi24323,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl = [-60 140];

cl = [0 90];

subi_2(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi_2(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));


axes(subi_2(1))
plot(hyde_tt_daily.DOY,lm_daily_hyde_2.Residuals.Raw,'*')
xlabel('DOY')
ylabel('Residuals')
set_plot_font(gca,plot_font_size)
title('Hyytiälä-Siikaneva pair')

axes(subi_2(2))
plot(skyla_tt_daily.DOY,lm_daily_skyla_2.Residuals.Raw,'*')
xlabel('DOY')
ylabel('Residuals')
set_plot_font(gca,plot_font_size)
title('Halssikangas-Halssiaapa pair')
ylim(subi_2,yl)

% still clear pattern seen in residuals wrt. DOY. 
% save_figure_OP(figi24323,'../figs/both_residuals_1')

% now try fix the summertime points where there is again a clear increasing
% trend


figi243213123 = figure();
scatter(skyla_tt_daily.DOY,lm_daily_skyla_2.Residuals.Raw,150,skyla_tt_daily.mean_glob,'filled')
xlabel('DOY')
ylabel('Residuals')
set_plot_font(gca,plot_font_size)

%% only plot the no-deep-snow points: Fig. A12 in manuscript
figi444 = figure();
set(figi444,'outerposition',[200 200 1920 1080]);




plot_m = 1;
plot_n = 2;

yl_rad = [-60 160];
clim_snow = [30 90];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));


axes(subi1)


scatter(hyde_tt_daily.mean_glob(~hyde_tt_daily.deepsnow),hyde_tt_daily.SW_balance_difference(~hyde_tt_daily.deepsnow),150,hyde_tt_daily.DOY(~hyde_tt_daily.deepsnow),'filled','MarkerEdgeColor',[0 0 0]);
% cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in net SW radiation between sites (W m^{-2})')
% ylabel(cb,'DOY')
title('Hyytiälä-Siikaneva pair')
ylim(yl_rad)


axes(subi2)

scatter(skyla_tt_daily.mean_glob(~skyla_tt_daily.deepsnow),skyla_tt_daily.SW_balance_difference(~skyla_tt_daily.deepsnow),150,skyla_tt_daily.DOY(~skyla_tt_daily.deepsnow),'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'DOY')
title('Halssikangas-Halssiaapa pair')
ylim(yl_rad)

text(subi1,-0.3,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')

% % save_figure_OP(figi444,'../figs/both_SW_DOY')




%% check WTD
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_rad = [-60 200];
clim_WTD = [-40 10];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));





axes(subi1)
scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.SW_balance_difference,90,hyde_tt_daily.WTD_SII,'filled');
% cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
ylim(yl_rad)

clim(clim_WTD)


axes(subi2)
scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,90,skyla_tt_daily.WTL1_peat,'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Water table depth at the peatland site (cm)')
title('Sodankylä-Halssiaapa pair')
ylim(yl_rad)

clim(clim_WTD)
text(subi1,-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')



%% check WTD vs albedo
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_alb = [0 1];
clim_WTD = [-40 10];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));





axes(subi1)
scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.albedo_siika,90,hyde_tt_daily.WTD_SII,'filled');
% cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
ylim(yl_alb)

clim(clim_WTD)


axes(subi2)
scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.albedo_halssi,90,skyla_tt_daily.WTL1_peat,'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Water table depth at the peatland site (cm)')
title('Sodankylä-Halssiaapa pair')
ylim(yl_alb)

clim(clim_WTD)
text(subi1,-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')



%% check WTD vs albedo, plot other way
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_alb = [0 1];
% clim_WTD = [-40 10];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));



select_plot_hyde = hyde_tt_daily.SDepth_SII_gapfilled < 0.5 & hyde_tt_daily.DOY < 240 & hyde_tt_daily.DOY > 100;
select_plot_skyla = skyla_tt_daily.SDepth_peat_gapfilled< 0.5 & skyla_tt_daily.DOY < 240 & skyla_tt_daily.DOY > 100;

axes(subi(1))
scatter(hyde_tt_daily.WTD_SII(select_plot_hyde),hyde_tt_daily.albedo_siika(select_plot_hyde),90,hyde_tt_daily.DOY(select_plot_hyde),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Water table depth at the peatland site (cm)')
ylabel('Albedo')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
% ylim(yl_alb)

% clim(clim_WTD)
% 

axes(subi(2))
scatter(skyla_tt_daily.WTL1_peat(select_plot_skyla),skyla_tt_daily.albedo_halssi(select_plot_skyla),90,skyla_tt_daily.DOY(select_plot_skyla),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Water table depth at the peatland site (cm)')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'DOY')
title('Sodankylä-Halssiaapa pair')
% ylim(yl_alb)

% clim(clim_WTD)
text(subi(1),-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi(2),-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')

linkaxes(subi,'y')


%% check WTD vs albedo, plot other way
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_alb = [0 1];
% clim_WTD = [-40 10];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));



select_plot_hyde = hyde_tt_daily.SDepth_SII_gapfilled < 0.5 & hyde_tt_daily.DOY < 240 & hyde_tt_daily.DOY > 100;
select_plot_skyla = skyla_tt_daily.SDepth_peat_gapfilled< 0.5 & skyla_tt_daily.DOY < 240 & skyla_tt_daily.DOY > 100;

axes(subi(1))
scatter(hyde_tt_daily.DOY(select_plot_hyde),hyde_tt_daily.albedo_siika(select_plot_hyde),90,hyde_tt_daily.WTD_SII(select_plot_hyde),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel(cb,'Water table depth at the peatland site (cm)')
ylabel('Albedo')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
% ylim(yl_alb)

% clim(clim_WTD)
% 

axes(subi(2))
scatter(skyla_tt_daily.DOY(select_plot_skyla),skyla_tt_daily.albedo_halssi(select_plot_skyla),90,skyla_tt_daily.WTL1_peat(select_plot_skyla),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel(cb,'Water table depth at the peatland site (cm)')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel('DOY')
title('Sodankylä-Halssiaapa pair')
% ylim(yl_alb)

% clim(clim_WTD)
text(subi(1),-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi(2),-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')

linkaxes(subi,'y')


%% check WTD vs albedo, plot other way
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_alb = [0 1];
% clim_WTD = [-40 10];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));



select_plot_hyde = hyde_tt_daily.SDepth_SII_gapfilled < 0.5 & hyde_tt_daily.DOY < 240 & hyde_tt_daily.DOY > 100;
select_plot_skyla = skyla_tt_daily.SDepth_peat_gapfilled< 0.5 & skyla_tt_daily.DOY < 240 & skyla_tt_daily.DOY > 100;

axes(subi(1))
scatter(hyde_tt_daily.DOY(select_plot_hyde),hyde_tt_daily.albedo_siika(select_plot_hyde),90,hyde_tt_daily.Time.Year(select_plot_hyde),'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel(cb,'Year')
ylabel('Albedo')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
% ylim(yl_alb)

% clim(clim_WTD)
% 

axes(subi(2))
scatter(skyla_tt_daily.DOY(select_plot_skyla),skyla_tt_daily.albedo_halssi(select_plot_skyla),90,skyla_tt_daily.Time.Year(select_plot_skyla),'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel(cb,'Year')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel('DOY')
title('Sodankylä-Halssiaapa pair')
% ylim(yl_alb)

% clim(clim_WTD)
text(subi(1),-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi(2),-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')

linkaxes(subi,'y')


%% check DOY vs albedo
% with some points between the groups

figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_alb = [0 1];
clim_DOY = [100 300];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));





axes(subi1)
scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.albedo_siika,90,hyde_tt_daily.DOY,'filled');
% cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
% ylabel(cb,'Snow depth at the peatland site (cm)')
title('Hyytiälä-Siikaneva pair')
ylim(yl_alb)

clim(clim_DOY)


axes(subi2)
scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.albedo_halssi,90,skyla_tt_daily.DOY,'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Water table depth at the peatland site (cm)')
title('Sodankylä-Halssiaapa pair')
ylim(yl_alb)

clim(clim_DOY)
text(subi1,-0.25,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')



%%

figi555 = figure();
set(figi555,'outerposition',[200 200 1920 1080]);
scatter(skyla_tt_daily.mean_glob(~skyla_tt_daily.deepsnow),skyla_tt_daily.SW_balance_difference(~skyla_tt_daily.deepsnow),90,skyla_tt_daily.WTL1_peat(~skyla_tt_daily.deepsnow),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Water table depth at the peatland site (cm)')
title('Sodankylä-Halssiaapa pair')
% save_figure_OP(figi555,'../figs/skyla_SW_WTL')
%%


% still have a bunch of high reflectances, limit to the no/low snow cover

figure();

scatter(skyla_tt_daily.mean_glob(skyla_tt_daily.snow_cat == 1),skyla_tt_daily.SW_balance_difference(skyla_tt_daily.snow_cat == 1),90,skyla_tt_daily.DOY(skyla_tt_daily.snow_cat == 1),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'DOY')
title('Sodankylä-Halssiaapa pair')

figure();

scatter(skyla_tt_daily.mean_glob(skyla_tt_daily.snow_cat == 1),skyla_tt_daily.SW_balance_difference(skyla_tt_daily.snow_cat == 1),90,skyla_tt_daily.WTL1_peat(skyla_tt_daily.snow_cat == 1),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Water table depth at the peatland site (cm)')
title('Sodankylä-Halssiaapa pair')


figure();

scatter(skyla_tt_daily.mean_glob(skyla_tt_daily.snow_cat == 1),skyla_tt_daily.SW_balance_difference(skyla_tt_daily.snow_cat == 1),90,skyla_tt_daily.albedo_halssi(skyla_tt_daily.snow_cat == 1),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Albedo at Halssi')
title('Sodankylä-Halssiaapa pair')


%  DOY *seems* to explain the variation better than water table. Plot
%  residuals agains each



figure();

scatter(skyla_tt_daily.mean_glob(skyla_tt_daily.snow_cat == 1),skyla_tt_daily.SW_balance_difference(skyla_tt_daily.snow_cat == 1),90,skyla_tt_daily.T_peat(skyla_tt_daily.snow_cat == 1),'filled');
cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in the SW balances between sites (W m^{-2})')
ylabel(cb,'Air temperature at Halssiaapa')
title('Sodankylä-Halssiaapa pair')


figure();
plot(skyla_tt_daily.DOY,lm_daily_skyla.Residuals.Raw,'*',skyla_tt_daily.DOY(skyla_tt_daily.snow_cat == 1),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.snow_cat == 1),'*')
xlabel('DOY')
ylabel('Residuals')
legend('All','No snow')
figure();
plot(skyla_tt_daily.WTL1_peat,lm_daily_skyla.Residuals.Raw,'*',skyla_tt_daily.WTL1_peat(skyla_tt_daily.snow_cat == 1),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.snow_cat == 1),'*')
xlabel('WTL')
ylabel('Residuals')
legend('All','No snow')

% esp no snow residuals much more dependent on DOY up to DOY around 250.
% Limit to this still



figure();
plot(skyla_tt_daily.DOY,lm_daily_skyla.Residuals.Raw,'*',skyla_tt_daily.DOY(skyla_tt_daily.summertime_model),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.summertime_model),'*')
xlabel('DOY')
ylabel('Residuals')
legend('All','No snow, up to DOY 250')
figure();
plot(skyla_tt_daily.WTL1_peat,lm_daily_skyla.Residuals.Raw,'*',skyla_tt_daily.WTL1_peat(skyla_tt_daily.summertime_model),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.summertime_model),'*')
xlabel('WTL')
ylabel('Residuals')
legend('All','No snow, up to DOY 250')


%% includes Fig. A18 in manuscript
resid_corrs_skyla = corrcoef([skyla_tt_daily.DOY(skyla_tt_daily.summertime_model),skyla_tt_daily.WTL1_peat(skyla_tt_daily.summertime_model),lm_daily_skyla_2.Residuals.Raw(skyla_tt_daily.summertime_model)],'rows','pairwise');
resid_corrs_hyde = corrcoef([hyde_tt_daily.DOY(hyde_tt_daily.summertime_model),hyde_tt_daily.WTD_SII(hyde_tt_daily.summertime_model),lm_daily_hyde_2.Residuals.Raw(hyde_tt_daily.summertime_model)],'rows','pairwise');


figi6666 = figure();
set(figi6666,'outerposition',[200 200 1920 1080]);



plot_m = 5;
plot_n = 5;

yl_alb = [0 1];
clim_DOY = [100 300];

subi_3(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:2,1:2));
subi_3(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,4:5,1:2));


subi_3(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:2,4:5));
subi_3(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,4:5,4:5));



axes(subi_3(1))


scatter(hyde_tt_daily.DOY(hyde_tt_daily.summertime_model),lm_daily_hyde_2.Residuals.Raw(hyde_tt_daily.summertime_model),100,hyde_tt_daily.mean_glob(hyde_tt_daily.summertime_model),'filled')
xlabel('DOY')
ylabel('Residuals')
cb = colorbar;
ylabel(cb,'Global radiation (W m^{-2})')
title(['Hyytiälä-Siikaneva, r = ',num2str(resid_corrs_hyde(1,3))])
set_plot_font(gca,plot_font_size)

axes(subi_3(2))


scatter(hyde_tt_daily.WTD_SII(hyde_tt_daily.summertime_model),lm_daily_hyde_2.Residuals.Raw(hyde_tt_daily.summertime_model),100,hyde_tt_daily.mean_glob(hyde_tt_daily.summertime_model),'filled')
xlabel('WTD')
ylabel('Residuals')
cb = colorbar;
ylabel(cb,'Global radiation (W m^{-2})')
title(['Hyytiälä-Siikaneva, r = ',num2str(resid_corrs_hyde(2,3))])
set_plot_font(gca,plot_font_size)

axes(subi_3(3))


scatter(skyla_tt_daily.DOY(skyla_tt_daily.summertime_model),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.summertime_model),100,skyla_tt_daily.mean_glob(skyla_tt_daily.summertime_model),'filled')
xlabel('DOY')
cb = colorbar;
ylabel(cb,'Global radiation (W m^{-2})')
ylabel('Residuals')
title(['Halssikangas-Halssiaapa, r = ',num2str(resid_corrs_skyla(1,3))])
set_plot_font(gca,plot_font_size)



axes(subi_3(4))
scatter(skyla_tt_daily.WTL1_peat(skyla_tt_daily.summertime_model),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.summertime_model),100,skyla_tt_daily.mean_glob(skyla_tt_daily.summertime_model),'filled')
% plot(skyla_tt_daily.WTL1_peat(skyla_tt_daily.summertime_model),lm_daily_skyla.Residuals.Raw(skyla_tt_daily.summertime_model),'*')
xlabel('WTD')
ylabel('Residuals')
cb = colorbar;
ylabel(cb,'Global radiation (W m^{-2})')
title(['Halssikangas-Halssiaapa, r = ',num2str(resid_corrs_skyla(2,3))])
set_plot_font(gca,plot_font_size)
% save_figure_OP(figi6666,'../figs/both_resid_DOY_WTD_summer')

% save_figure_OP(figi7777,'../figs/skyla_resid_WTD_summer')


% conclusion: DOY slightly more correlated with residuals, add own
% intercept and slope for DOY in the summertime




%% do the models: includes Fig. A19 in manuscript
 
% lm_daily_skyla_3 = fitlm(timetable2table(skyla_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow+summertime_model+summertime_model:DOY','Exclude',(skyla_tt_daily.missing_snowcover|weird_snowless_points),'robustopts','on');
lm_daily_skyla_3 = fitlm(timetable2table(skyla_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow+summertime_model+summertime_model:DOY','Exclude',(skyla_tt_daily.missing_snowcover|weird_snowless_points_skyla),'robustopts','on');
% lm_daily_skyla_3 = fitlm(timetable2table(skyla_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow+mean_glob:deepsnow:DOY+summertime_model+summertime_model:DOY','Exclude',(skyla_tt_daily.missing_snowcover|weird_snowless_points),'robustopts','on');
% RMSE drops from 5.47 to 4.59 when including DOY slope and intercept for
% summertime values

lm_daily_hyde_3 = fitlm(timetable2table(hyde_tt_daily),'SW_balance_difference~mean_glob+mean_glob:deepsnow+summertime_model+summertime_model:DOY','Exclude',(hyde_tt_daily.missing_snowcover),'robustopts','on');
% RMSE from 7.04 to 6.76 when including DOY slope and intercept for
% summertime values


figi434 = figure();
set(figi434,'outerposition',[200 200 1920 1080]);




plot_m = 1;
plot_n = 2;

yl_rad = [-60 160];
clim_snow = [0 90];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));

axes(subi1)


scatter(hyde_tt_daily.mean_glob,hyde_tt_daily.SW_balance_difference,100,hyde_tt_daily.SnowDepth_SII,'filled');

hold on
plot(hyde_tt_daily.mean_glob,lm_daily_hyde_3.Fitted,'*')
title('Hyytiälä-Siikaneva pair')
legend('Observed','Predicted')
set_plot_font(gca,plot_font_size)


set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
ylabel('Difference in net SW radiation between sites (W m^{-2})')
% cb = colorbar;
% ylabel(cb,'Snow depth at the peatland site (cm)')

ylim(yl_rad)

clim(clim_snow)


axes(subi2)


scatter(skyla_tt_daily.mean_glob,skyla_tt_daily.SW_balance_difference,100,skyla_tt_daily.SDepth_peat,'filled');colorbar
hold on
plot(skyla_tt_daily.mean_glob,lm_daily_skyla_3.Fitted,'*')
title('Halssikangas-Halssiaapa pair')
legend('Observed','Predicted')
set_plot_font(gca,plot_font_size)
text(subi1,-0.3,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')
% cb = colorbar;
set_plot_font(gca,plot_font_size)
xlabel('Daily mean global radiation (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
cb = colorbar;
ylabel(cb,'Snow depth at the peatland site (cm)')

ylim(yl_rad)

clim(clim_snow)
% ylabel(cb,'DOY')

% save_figure_OP(figi434,'../figs/both_SW_model')

%%
% general features fitted OK
% the slope of the snow-covered days seems to be a bit low



resid_corrs_2 = corrcoef([skyla_tt_daily.DOY(skyla_tt_daily.summertime_model),skyla_tt_daily.WTL1_peat(skyla_tt_daily.summertime_model),lm_daily_skyla_3.Residuals.Raw(skyla_tt_daily.summertime_model)],'rows','pairwise');

figure();
plot(skyla_tt_daily.DOY(skyla_tt_daily.summertime_model),lm_daily_skyla_3.Residuals.Raw(skyla_tt_daily.summertime_model),'*')
xlabel('DOY')
ylabel('Residuals')
title(['No snow, up to DOY 250, r = ',num2str(resid_corrs_2(1,3))])
% very much less pronounced pattern in resid wrt DOY

figure();
plot(skyla_tt_daily.diff_frac(skyla_tt_daily.summertime_model),lm_daily_skyla_3.Residuals.Raw(skyla_tt_daily.summertime_model),'*')
xlabel('Diff fraction')
ylabel('Residuals')
title(['No snow, up to DOY 250, r = ',num2str(resid_corrs_2(1,3))])

figure();
plot(skyla_tt_daily.WTL1_peat(skyla_tt_daily.summertime_model),lm_daily_skyla_3.Residuals.Raw(skyla_tt_daily.summertime_model),'*')
xlabel('DOY')
ylabel('Residuals')
title(['No snow, up to DOY 250, r = ',num2str(resid_corrs_2(2,3))])

% wtl has some independent effect, but leave out for clarity

figure();
plot(hyde_tt_daily.diff_frac(hyde_tt_daily.summertime_model),lm_daily_hyde_3.Residuals.Raw(hyde_tt_daily.summertime_model),'*')
xlabel('Diff fraction')
ylabel('Residuals')
title(['Hyde'])



%%

% skyla_tt_daily.SW_balance_difference_predicted_old = lm_daily_skyla.predict(timetable2table(skyla_tt_daily));
skyla_tt_daily.SW_balance_difference_predicted = lm_daily_skyla_3.predict(timetable2table(skyla_tt_daily));
skyla_tt_daily.SW_balance_difference_predicted_infilled = fillmissing(skyla_tt_daily.SW_balance_difference_predicted,'linear');
% hyde_tt_daily.SW_balance_difference_predicted = lm_daily_hyde.predict(timetable2table(hyde_tt_daily));

hyde_tt_daily.SW_balance_difference_predicted = lm_daily_hyde_3.predict(timetable2table(hyde_tt_daily));
hyde_tt_daily.SW_balance_difference_predicted_infilled = fillmissing(hyde_tt_daily.SW_balance_difference_predicted,'linear');



%% Fig. A14 in manuscript


figi4343 = figure();
set(figi4343,'outerposition',[200 200 1920 1080]);




plot_m = 1;
plot_n = 2;

yl_rad = [-50 180];
clim_snow = [0 90];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));

axes(subi1)


scatter(hyde_tt_daily.SW_balance_difference,hyde_tt_daily.SW_balance_difference_predicted,100,'filled');
hold on
plot(hyde_tt_daily.SW_balance_difference,hyde_tt_daily.SW_balance_difference,'LineWidth',8)

% hold on
% plot(hyde_tt_daily.mean_glob,lm_daily_hyde_3.Fitted,'*')
title('Hyytiälä-Siikaneva pair')
% legend('Observed','Predicted')
set_plot_font(gca,plot_font_size)


set_plot_font(gca,plot_font_size)
ylabel('Fitted difference (W m^{-2})')
xlabel('Observed difference (W m^{-2})')
% cb = colorbar;
% ylabel(cb,'Snow depth at the peatland site (cm)')

ylim(yl_rad)
xlim(yl_rad)

% clim(clim_snow)


axes(subi2)


scatter(skyla_tt_daily.SW_balance_difference,skyla_tt_daily.SW_balance_difference_predicted,100,'filled');
hold on
plot(skyla_tt_daily.SW_balance_difference,skyla_tt_daily.SW_balance_difference,'LineWidth',8)
title('Halssikangas-Halssiaapa pair')
% legend('Observed','Predicted')
set_plot_font(gca,plot_font_size)
text(subi1,-0.3,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')
% cb = colorbar;
set_plot_font(gca,plot_font_size)

xlabel('Observed difference (W m^{-2})')
% ylabel('Difference in the SW balances between sites (W m^{-2})')
% cb = colorbar;
% ylabel(cb,'Snow depth at the peatland site (cm)')

ylim(yl_rad)
xlim(yl_rad)
% clim(clim_snow)
% ylabel(cb,'DOY')

% save_figure_OP(figi4343,'../figs/both_fitted_vs_measured')

%%

% lm_daily_skyla_3.PredictorNames

figure();plot(skyla_tt_daily.Time,[isnan(skyla_tt_daily.SW_balance_difference_predicted),isnan(skyla_tt_daily.mean_glob),isnan(skyla_tt_daily.DOY),isnan(skyla_tt_daily.deepsnow),isnan(skyla_tt_daily.summertime_model)],'-o')
title(['Total missing: ',num2str(sum(isnan(skyla_tt_daily.SW_balance_difference_predicted)))])
legend('Any predictor','Mean glob','DOY','Deepsnow','summertime')

% 12 observations still missing, these miss the global radiation for both
% sites. Mainly single days, 2 times 2 consecutive days. Linear
% interpolation for these


figure();
plot(skyla_tt_daily.Time,skyla_tt_daily.SW_balance_difference_predicted,skyla_tt_daily.Time(isnan(skyla_tt_daily.SW_balance_difference_predicted)),skyla_tt_daily.SW_balance_difference_predicted_infilled(isnan(skyla_tt_daily.SW_balance_difference_predicted)),'.','markersize',20)
% mainly pretty low values, accept imputation



%% gapfill SW balance difference

skyla_tt_daily.SW_balance_difference_gapfilled = skyla_tt_daily.SW_balance_difference;
skyla_tt_daily.SW_balance_difference_gapfilled(isnan(skyla_tt_daily.SW_balance_difference)) = skyla_tt_daily.SW_balance_difference_predicted_infilled(isnan(skyla_tt_daily.SW_balance_difference));

hyde_tt_daily.SW_balance_difference_gapfilled = hyde_tt_daily.SW_balance_difference;
hyde_tt_daily.SW_balance_difference_gapfilled(isnan(hyde_tt_daily.SW_balance_difference)) = hyde_tt_daily.SW_balance_difference_predicted_infilled(isnan(hyde_tt_daily.SW_balance_difference));







%% Fig. A2 in manuscript


figi5 = figure();
set(figi5,'outerposition',[200 200 1920 1080]);



plot_m = 2;
plot_n = 1;

yl_rad = [-60 160];
clim_snow = [0 90];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1,1));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,2,1));

axes(subi1)

plot(hyde_tt_daily.Time,hyde_tt_daily.SW_balance_difference_gapfilled,hyde_tt_daily.Time,hyde_tt_daily.SW_balance_difference,'LineWidth',5)
set_plot_font(gca,36)
title('Hyytiälä-Siikaneva pair')
axes(subi2)


plot(skyla_tt_daily.Time,skyla_tt_daily.SW_balance_difference_gapfilled,skyla_tt_daily.Time,skyla_tt_daily.SW_balance_difference,'LineWidth',5)
title('Halssikangas-Halssiaapa pair')
legend('Gapfilled','Measured')
set_plot_font(gca,36)
% ylabel('SW balance difference (W m^{-2})')
% save_figure_OP(figi5,'../figs/skyla_net_SW_gapfilled')

text(subi1,-0.07,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.07,1.05,'b','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.13,0.5,'SW balance difference (W m^{-2})','fontsize',36,'units','normalized','Rotation',90)


% save_figure_OP(figi5,'../figs/both_net_SW_gapfilled')

%% snow depth interpolation plot: Fig. A1 in manuscript

figu = figure();
set(figu,'outerposition',[200 200 1920 1080]);

plot_m = 2;
plot_n = 2;

yl_rad = [-60 160];
clim_snow = [0 90];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1,1));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1,2));
subi(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,2,1));
subi(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,2,2));

axes(subi(4))


plot(skyla_tt_daily.Time+hours(12),skyla_tt_daily.SDepth_peat,'.-',skyla_tt_daily.Time+hours(12),skyla_tt_daily.SDepth_peat_gapfilled,'.-','LineWidth',5,'MarkerSize',30)
title('Halssiaapa')
ylabel('Snow depth (cm)')
% legend('Original','Gapfilled','autoupdate','off')
set_plot_font(gca,plot_font_size)
grid on

subi(4).Children = subi(4).Children(end:-1:1);

axes(subi(3))


plo = plot(hyde_tt_daily.Time+hours(12),hyde_tt_daily.SnowDepth_SII,'.-',hyde_tt_daily.Time+hours(12),hyde_tt_daily.SDepth_SII_gapfilled,'.-','LineWidth',5,'MarkerSize',30);
title('Siikaneva')
ylabel('Snow depth (cm)')
% legend('Original','Gapfilled','autoupdate','off')
set_plot_font(gca,plot_font_size)
grid on
subi(3).Children = subi(3).Children(end:-1:1);

% save_figure_OP(figu,'../figs/both_SD_gapfilled')



axes(subi(2))


plot(skyla_tt_daily.Time+hours(12),skyla_tt_daily.SDepth_forest,'.-',skyla_tt_daily.Time+hours(12),skyla_tt_daily.SDepth_forest_gapfilled,'.-','LineWidth',5,'MarkerSize',30)
title('Halssikangas')
ylabel('Snow depth (cm)')
% legend('Original','Gapfilled','autoupdate','off')
set_plot_font(gca,plot_font_size)
grid on

subi(2).Children = subi(2).Children(end:-1:1);

axes(subi(1))


plo = plot(hyde_tt_daily.Time+hours(12),hyde_tt_daily.SnowDepth_HYY,'.-',hyde_tt_daily.Time+hours(12),hyde_tt_daily.SDepth_HYY_gapfilled,'.-','LineWidth',5,'MarkerSize',30);
title('Hyytiälä')
ylabel('Snow depth (cm)')
legend('Original','Gapfilled','autoupdate','off','Location','northwest')
set_plot_font(gca,plot_font_size)
grid on
subi(1).Children = subi(1).Children(end:-1:1);

xl1 = subi(1).XLim;

subi(1).XLim = xl1;%[datetime(2016,1,1,12,0,0,'timezone','+02:00') xl1(2)];
subi(3).XLim = xl1;%[datetime(2016,1,1,12,0,0,'timezone','+02:00') xl1(2)];


xl2 = subi(4).XLim;

subi(2).XLim = xl2;%[datetime(2016,1,1,12,0,0,'timezone','+02:00') xl1(2)];
subi(4).XLim = xl2;%[datetime(2016,1,1,12,0,0,'timezone','+02:00') xl1(2)];

linkaxes(subi([1 3]),'x')
linkaxes(subi([2 4]),'x')



subi(3).YLim = subi(1).YLim;
subi(4).YLim = subi(2).YLim;




% save_figure_OP(figu,'../figs/all_SD_gapfilled')

% snowmelt is always the first zero snow depth of the year. 
%% calculate additional parameters for the annual values




skyla_springtime_maxDOY = 150;
hyde_springtime_maxDOY = 130;

skyla_summertime_minDOY = 145;
hyde_summertime_minDOY = 115;

skyla_summertime_maxDOY = 260;
hyde_summertime_maxDOY = 270;



skyla_tt_daily.snowmelt_dummy = skyla_tt_daily.Snowcover_peat;
skyla_tt_daily.snowmelt_dummy(skyla_tt_daily.DOY>180) = 0;

skyla_tt_daily.snowmelt_dummy_forest = skyla_tt_daily.Snowcover_forest;
skyla_tt_daily.snowmelt_dummy_forest(skyla_tt_daily.DOY>180) = 0;
% Halssikangas snow cover data missing in beginning of 2013, based on
% Halssiaapa data it has been snow covered:
skyla_tt_daily.snowmelt_dummy_forest(skyla_tt_daily.Time<datetime(2013,5,1,'TimeZone','+02:00')) = 1;

skyla_tt_daily.snow_sun_day = skyla_tt_daily.Snowcover_peat.*skyla_tt_daily.mean_glob;

skyla_tt_daily.springtime_SW_diff = skyla_tt_daily.SW_balance_difference_gapfilled;
skyla_tt_daily.springtime_SW_diff(skyla_tt_daily.DOY>skyla_springtime_maxDOY) = NaN;


skyla_tt_daily.springtime_glob = skyla_tt_daily.mean_glob;
skyla_tt_daily.springtime_glob(skyla_tt_daily.DOY>skyla_springtime_maxDOY) = NaN;

skyla_tt_daily.peatland_summer_albedo = skyla_tt_daily.albedo_halssi;
skyla_tt_daily.peatland_summer_albedo(skyla_tt_daily.DOY<skyla_summertime_minDOY|skyla_tt_daily.DOY>skyla_summertime_maxDOY) = NaN;

skyla_tt_daily.summer_diffuse = skyla_tt_daily.diff_frac;
skyla_tt_daily.summer_diffuse(skyla_tt_daily.DOY<skyla_summertime_minDOY|skyla_tt_daily.DOY>skyla_summertime_maxDOY) = NaN;

skyla_tt_daily.spring_diffuse = skyla_tt_daily.diff_frac;
skyla_tt_daily.spring_diffuse(skyla_tt_daily.DOY>skyla_springtime_maxDOY) = NaN;
skyla_tt_daily.spring_diffuse(skyla_tt_daily.GLOB_forest<5) = NaN;



skyla_tt_daily.summer_glob= skyla_tt_daily.mean_glob;
skyla_tt_daily.summer_glob(skyla_tt_daily.DOY<skyla_summertime_minDOY|skyla_tt_daily.DOY>skyla_summertime_maxDOY) = NaN;

% skyla_tt_daily.summer_albedo_diff = skyla_tt_daily.albedo_difference;
% skyla_tt_daily.summer_albedo_diff(skyla_tt_daily.DOY<145|skyla_tt_daily.DOY>260) = NaN;
% 


hyde_tt_daily.snowmelt_dummy = hyde_tt_daily.Snowcover_SII;
% siikaneva snow cover data missing in beginning of 2016, based on Hyytiälä
% data it has been snow covered:
hyde_tt_daily.snowmelt_dummy(hyde_tt_daily.Time<datetime(2016,3,1,'TimeZone','+02:00')) = 1;

hyde_tt_daily.snowmelt_dummy(hyde_tt_daily.DOY>180) = 0;

hyde_tt_daily.snowmelt_dummy_forest = hyde_tt_daily.Snowcover_HYY;
hyde_tt_daily.snowmelt_dummy_forest(hyde_tt_daily.DOY>180) = 0;


hyde_tt_daily.snow_sun_day = hyde_tt_daily.Snowcover_SII.*hyde_tt_daily.mean_glob;


hyde_tt_daily.springtime_SW_diff= hyde_tt_daily.SW_balance_difference_gapfilled;
hyde_tt_daily.springtime_SW_diff(hyde_tt_daily.DOY>hyde_springtime_maxDOY) = NaN;


hyde_tt_daily.springtime_glob= hyde_tt_daily.mean_glob;
hyde_tt_daily.springtime_glob(hyde_tt_daily.DOY>hyde_springtime_maxDOY) = NaN;

hyde_tt_daily.peatland_summer_albedo = hyde_tt_daily.albedo_siika;
hyde_tt_daily.peatland_summer_albedo(hyde_tt_daily.DOY<hyde_summertime_minDOY|hyde_tt_daily.DOY>hyde_summertime_maxDOY) = NaN;


hyde_tt_daily.summer_diffuse= hyde_tt_daily.diff_frac;
hyde_tt_daily.summer_diffuse(hyde_tt_daily.DOY<hyde_summertime_minDOY|hyde_tt_daily.DOY>hyde_summertime_maxDOY) = NaN;


hyde_tt_daily.summer_glob= hyde_tt_daily.mean_glob;
hyde_tt_daily.summer_glob(hyde_tt_daily.DOY<hyde_summertime_minDOY|hyde_tt_daily.DOY>hyde_summertime_maxDOY) = NaN;

hyde_tt_daily.spring_diffuse= hyde_tt_daily.diff_frac;
hyde_tt_daily.spring_diffuse(hyde_tt_daily.DOY>hyde_springtime_maxDOY) = NaN;

% hyde_tt_daily.summer_albedo_diff = hyde_tt_daily.albedo_difference;
% hyde_tt_daily.summer_albedo_diff(hyde_tt_daily.DOY<115|hyde_tt_daily.DOY>270) = NaN;






hyde_tt_daily.SDepth_peat_gapfilled_only_snowcovered = hyde_tt_daily.SDepth_SII_gapfilled;
hyde_tt_daily.SDepth_peat_gapfilled_only_snowcovered(hyde_tt_daily.SDepth_peat_gapfilled_only_snowcovered <0.5) = NaN;



skyla_tt_daily.SDepth_peat_gapfilled_only_snowcovered = skyla_tt_daily.SDepth_peat_gapfilled;
skyla_tt_daily.SDepth_peat_gapfilled_only_snowcovered(skyla_tt_daily.SDepth_peat_gapfilled_only_snowcovered<0.5) = NaN;



% 
% save('../vars/hyde_tt_daily_cleaned_calibrated_gapfilled.mat','hyde_tt_daily')
% save('../vars/skyla_tt_daily_cleaned_gapfilled.mat','skyla_tt_daily')

% 
% load('../vars/hyde_tt_daily_cleaned_calibrated_gapfilled.mat')
% load('../vars/skyla_tt_daily_cleaned_gapfilled.mat')


% if we count only springtime snow cover days, we get snowmelt DOY
%% calculate annual averages of the difference in SW radiation

% first hydrologocal year starts aug 13, last full one ends 23
annual_time_vector = datetime(2013,1,1,'TimeZone','+02:00'):calyears(1):datetime(2024,1,1,'TimeZone','+02:00');





skyla_tt_annual_raw = retime(skyla_tt_daily,annual_time_vector,'mean');
skyla_tt_annual = skyla_tt_annual_raw(1:end-1,:);
% discard final year as that is incomplete




annual_time_vector_hyde = datetime(2016,1,1,'TimeZone','+02:00'):calyears(1):datetime(2024,1,1,'TimeZone','+02:00');

hyde_tt_annual_raw = retime(hyde_tt_daily,annual_time_vector_hyde,'mean');
hyde_tt_annual = hyde_tt_annual_raw(1:end-1,:);

% 
% save('../vars/skyla_tt_annual.mat','skyla_tt_annual')
% save('../vars/hyde_tt_annual.mat','hyde_tt_annual')
%%

figure();plot(skyla_tt_annual.Snowcover_peat*365,skyla_tt_annual.SW_balance_difference_gapfilled,'*')
figure();plot(skyla_tt_annual.SDepth_peat_gapfilled,skyla_tt_annual.SW_balance_difference_gapfilled,'*')


figi4 = figure();
set(figi4,'outerposition',[200 200 1920 1080]);
scatter(skyla_tt_annual.Snowcover_peat*365,skyla_tt_annual.SW_balance_difference_gapfilled,400,skyla_tt_annual.SDepth_peat_gapfilled,'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
title('Sodankylä')
xlabel('Number of snow covered days in the winter')
ylabel('Annual average difference in the SW radiation balances')
ylabel(cb,'Annual average snow depth')
% save_figure_OP(figi4,'../figs/skyla_net_SW_vs_snow')




figi5 = figure();
set(figi5,'outerposition',[200 200 1920 1080]);
scatter(skyla_tt_annual.snowmelt_dummy*365,skyla_tt_annual.SW_balance_difference_gapfilled,400,skyla_tt_annual.SDepth_peat_gapfilled,'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
title('Sodankylä')
xlabel('Peatland snowmelt DOY')
ylabel('Annual average difference in the SW radiation balances')
ylabel(cb,'Annual average snow depth')
% save_figure_OP(figi4,'../figs/skyla_net_SW_vs_snow')



figi6 = figure();
set(figi6,'outerposition',[200 200 1920 1080]);
scatter(skyla_tt_annual.snow_sun_day,skyla_tt_annual.SW_balance_difference_gapfilled,400,skyla_tt_annual.SDepth_peat_gapfilled,'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
title('Sodankylä')
xlabel('Measure of sunny snowy days')
ylabel('Annual average difference in the SW radiation balances')
ylabel(cb,'Annual average snow depth')
% save_figure_OP(figi4,'../figs/skyla_net_SW_vs_snow')



figure();plot(skyla_tt_annual.Time+calmonths(6),skyla_tt_annual.SW_balance_difference_gapfilled,skyla_tt_annual.Time+calmonths(6),skyla_tt_annual.SDepth_peat_gapfilled)
legend('SW balance','SDepth')
figure();plot(skyla_tt_annual.Time+calmonths(6),skyla_tt_annual.Snowcover_peat*365)
title('Snow covered days')


% 2021, the outlier, has around 2 weeks later snow melt in the forest site,
% so there is undetected snow also on the peatland site 



%% Fig. 11 in manuscript



average_flux_to_annual_budget = 3600*24*365.25*1e-9;%W/m2/s --> GJ/m2
average_flux_to_springtime_budget_skyla = 3600*24*skyla_springtime_maxDOY*1e-9;%W/m2/s --> GJ/m2
average_flux_to_springtime_budget_hyde = 3600*24*hyde_springtime_maxDOY*1e-9;%W/m2/s --> GJ/m2


figi5 = figure();
set(figi5,'outerposition',[200 200 1920 1080]);




plot_m = 1;
plot_n = 2;

yl_rad = [-50 180];
clim_snow = [0 90];

xl_snow = [70 150];

subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));

axes(subi1)


scatter(skyla_tt_annual.snowmelt_dummy*365,skyla_tt_annual.SW_balance_difference_gapfilled*average_flux_to_annual_budget,400,skyla_tt_annual.summer_glob,'^','filled','MarkerEdgeColor',[0 0 0]);
% cb = colorbar;
set_plot_font(gca,plot_font_size)
% title('Sodankylä')
xlabel('Peatland snowmelt DOY')
ylabel({'Annual difference','in net SW radiation (GJ m^{-2})'})
% ylabel(cb,'Annual average snow depth at the peatland site (cm)')

hold on

scatter(hyde_tt_annual.snowmelt_dummy*365,hyde_tt_annual.SW_balance_difference_gapfilled*average_flux_to_annual_budget,400,hyde_tt_annual.summer_glob,'filled','MarkerEdgeColor',[0 0 0]);

% legend('Sodankylä','Hyytiälä','Location','northwest');




yl = ylim;
ylim([0 yl(2)])
xl1 = xlim;
% xlim([80 xl(2)])
xlim(xl_snow)

axes(subi2)
scatter(skyla_tt_annual.snowmelt_dummy*365,skyla_tt_annual.springtime_SW_diff*average_flux_to_springtime_budget_skyla,400,skyla_tt_annual.summer_glob ,'^','filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
set_plot_font(gca,plot_font_size)
% title('Sodankylä')
xlabel('Peatland snowmelt DOY')
% ylabel({'Springtime average difference','in the SW radiation balances (W m^{-2})'})
ylabel({'Springtime difference','in net SW radiation (GJ m^{-2})'})
ylabel(cb,'Average global radiation in the summer (W m^{-2})')
hold on

scatter(hyde_tt_annual.snowmelt_dummy*365,hyde_tt_annual.springtime_SW_diff*average_flux_to_springtime_budget_hyde,400,hyde_tt_annual.summer_glob,'filled','MarkerEdgeColor',[0 0 0]);

[lgd,lgd2] = legend('Halssikangas-Halssiaapa','Hyytiälä-Siikaneva','Location','northwest');


lgd2(3).Children.MarkerSize = 20;
lgd2(4).Children.MarkerSize = 20;


yl = ylim;
ylim([0 yl(2)])
xl1 = xlim;
% xlim([80 xl(2)])
xlim(xl_snow)   

% save_figure_OP(figi5,'../figs/both_net_SW_vs_snow_spring_subplot')



%% model the annual difference based on summertime albedo, snowmelt, and springtime glob


hyde_tt_annual.spring_y = hyde_tt_annual.springtime_SW_diff*average_flux_to_springtime_budget_hyde;
skyla_tt_annual.spring_y = skyla_tt_annual.springtime_SW_diff*average_flux_to_springtime_budget_skyla;



hyde_tt_annual.year_y = hyde_tt_annual.SW_balance_difference_gapfilled*average_flux_to_annual_budget;
skyla_tt_annual.year_y = skyla_tt_annual.SW_balance_difference_gapfilled*average_flux_to_annual_budget;


comb_table = outerjoin(timetable2table(hyde_tt_annual),timetable2table(skyla_tt_annual),'MergeKeys',true);



both_springtime_fit_minimal =      fitlm(comb_table,'spring_y~snowmelt_dummy');
both_annual_fit_minimal_3 = fitlm(comb_table,'year_y~snowmelt_dummy+summer_glob');



%% peatland vs forest snowmelt
fiigi = figure();
set(fiigi,'outerposition',[200 200 1920 1080]);
scatter(hyde_tt_annual.snowmelt_dummy*365,hyde_tt_annual.snowmelt_dummy_forest*365,500,'filled');
xlabel('Peatland snowmelt DOY');
ylabel('Forest snowmelt DOY');
hold on;
% discard first sodankylä year due to missing data at beginning of year
scatter(skyla_tt_annual.snowmelt_dummy*365,skyla_tt_annual.snowmelt_dummy_forest*365,500,'^','filled');

set_plot_font(gca,plot_font_size) 
plot([80 140],[80 140],'linewidth',5);
[lege lege2] = legend('Hyytiälä-Siikaneva','Halssikangas-Halssiaapa','1:1','location','northwest');



lege.FontSize = plot_font_size;

% lege2(2).FontSize = plot_font_size;
% lege2(1).FontSize = plot_font_size;

lege2(4).Children.MarkerSize = 20;
lege2(5).Children.MarkerSize = 20;
% lege.FontSize = plot_font_size;



% set_plot_font(gca,plot_font_size)   
% save_figure_OP(fiigi,'../figs/peatland_vs_forest_snowmelt')



%% these not in manuscript: exploring what variables associate with the annual differences in the net SW radiation
both_annual_fit =      fitlm(comb_table,'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo + SDepth_peat_gapfilled_only_snowcovered');
both_annual_fit_diff = fitlm(comb_table,'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo+summer_diffuse+spring_diffuse');
both_annual_fit_minimal = fitlm(comb_table,'SW_balance_difference_gapfilled~snowmelt_dummy+peatland_summer_albedo');
both_annual_fit_minimal_2 = fitlm(comb_table,'SW_balance_difference_gapfilled~snowmelt_dummy');
both_annual_fit_minimal_4 = fitlm(comb_table,'SW_balance_difference_gapfilled~snowmelt_dummy+summer_glob+peatland_summer_albedo');



both_springtime_fit =      fitlm(comb_table,'springtime_SW_diff~springtime_glob+snowmelt_dummy');
both_springtime_fit_diff = fitlm(comb_table,'springtime_SW_diff~springtime_glob+snowmelt_dummy+peatland_summer_albedo+summer_diffuse+spring_diffuse');


B2 = lasso([comb_table.snowmelt_dummy,comb_table.springtime_glob,comb_table.peatland_summer_albedo,comb_table.summer_diffuse,comb_table.spring_diffuse,comb_table.SDepth_peat_gapfilled_only_snowcovered,comb_table.summer_glob],comb_table.SW_balance_difference_gapfilled);
B2(:,25)

%% individual site pair fits, not in manuscript


hyde_annual_fit_onlysnowmelt = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~snowmelt_dummy');
hyde_annual_fit_snowmelt_and_summer_albedo = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~snowmelt_dummy+peatland_summer_albedo');
hyde_annual_fit = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo');
hyde_annual_fit_all_but_spring_sd = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo+summer_diffuse+spring_diffuse');
hyde_annual_fit_all = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo+summer_diffuse+spring_diffuse+SDepth_peat_gapfilled_only_snowcovered');
hyde_annual_fit_all_alsosummerglob = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo+summer_diffuse+spring_diffuse+SDepth_peat_gapfilled_only_snowcovered+summer_glob');
skyla_annual_fit = fitlm(timetable2table(skyla_tt_annual),'SW_balance_difference_gapfilled~springtime_glob+snowmelt_dummy+peatland_summer_albedo');
skyla_annual_fit_snowmelt_and_summer_albedo = fitlm(timetable2table(skyla_tt_annual),'SW_balance_difference_gapfilled~snowmelt_dummy+peatland_summer_albedo');


% B = lasso([hyde_tt_annual.snowmelt_dummy,hyde_tt_annual.springtime_glob,hyde_tt_annual.peatland_summer_albedo,hyde_tt_annual.summer_diffuse,hyde_tt_annual.spring_diffuse,hyde_tt_annual.SDepth_peat_gapfilled_only_snowcovered],hyde_tt_annual.SW_balance_difference_gapfilled);
B = lasso([hyde_tt_annual.snowmelt_dummy,hyde_tt_annual.springtime_glob,hyde_tt_annual.peatland_summer_albedo,hyde_tt_annual.summer_diffuse,hyde_tt_annual.spring_diffuse,hyde_tt_annual.SDepth_peat_gapfilled_only_snowcovered,hyde_tt_annual.summer_glob],hyde_tt_annual.SW_balance_difference_gapfilled);
B(:,25)
hyde_annual_fit_lassoselected = fitlm(timetable2table(hyde_tt_annual),'SW_balance_difference_gapfilled~snowmelt_dummy+summer_diffuse+spring_diffuse+SDepth_peat_gapfilled_only_snowcovered');




%% Hyde only
plotmatrix_fontsize = 16;


figi55 = figure();
set(figi55,'outerposition',[200 200 1920 1920]); [~,AX] = plotmatrix([hyde_tt_annual.SW_balance_difference_gapfilled,hyde_tt_annual.snowmelt_dummy*365,hyde_tt_annual.springtime_glob,hyde_tt_annual.peatland_summer_albedo,hyde_tt_annual.summer_diffuse,hyde_tt_annual.spring_diffuse,hyde_tt_annual.SDepth_peat_gapfilled_only_snowcovered]);
ylabel(AX(1,1),'Diff. in abs. SW','FontSize',plotmatrix_fontsize)
ylabel(AX(2,1),'Snowmelt','FontSize',plotmatrix_fontsize)
ylabel(AX(3,1),'Spring glob.','FontSize',plotmatrix_fontsize)
ylabel(AX(4,1),'Peat Summer albedo','FontSize',plotmatrix_fontsize)
ylabel(AX(5,1),'Summer diffuse','FontSize',plotmatrix_fontsize)
ylabel(AX(6,1),'Spring diffuse','FontSize',plotmatrix_fontsize)
ylabel(AX(7,1),'Snowdepth peat','FontSize',plotmatrix_fontsize)


xlabel(AX(7,1),'Diff. in abs. SW','FontSize',plotmatrix_fontsize)
xlabel(AX(7,2),'Snowmelt','FontSize',plotmatrix_fontsize)
xlabel(AX(7,3),'Spring glob.','FontSize',plotmatrix_fontsize)
xlabel(AX(7,4),'Peat Summer albedo','FontSize',plotmatrix_fontsize)
xlabel(AX(7,5),'Summer diffuse','FontSize',plotmatrix_fontsize)
xlabel(AX(7,6),'Spring diffuse','FontSize',plotmatrix_fontsize)
xlabel(AX(7,7),'Snowdepth peat','FontSize',plotmatrix_fontsize)

% set_plot_font(gca,plot_font   _size)


corrcoef([hyde_tt_annual.SW_balance_difference_gapfilled,hyde_tt_annual.snowmelt_dummy*365,hyde_tt_annual.springtime_glob,hyde_tt_annual.peatland_summer_albedo,hyde_tt_annual.summer_diffuse,hyde_tt_annual.spring_diffuse,hyde_tt_annual.SDepth_peat_gapfilled_only_snowcovered])

%%
% figi66 = figure();
% set(figi66,'outerposition',[200 200 1920 1920]); [~,AX] = plotmatrix([comb_table.SW_balance_difference_gapfilled,comb_table.snowmelt_dummy*365,comb_table.springtime_glob,comb_table.peatland_summer_albedo,comb_table.summer_diffuse,comb_table.spring_diffuse,comb_table.SDepth_peat_gapfilled_only_snowcovered]);

corrs_both = corrcoef([comb_table.SW_balance_difference_gapfilled,comb_table.snowmelt_dummy*365,comb_table.springtime_glob,comb_table.peatland_summer_albedo,comb_table.summer_diffuse,comb_table.spring_diffuse,comb_table.SDepth_peat_gapfilled_only_snowcovered]);
corrs_both.^2;
figi66 = figure();
set(figi66,'outerposition',[200 200 1920 1920]);

[~,AX,bigax] = gplotmatrix([comb_table.SW_balance_difference_gapfilled,comb_table.snowmelt_dummy*365,comb_table.springtime_glob,comb_table.peatland_summer_albedo,comb_table.summer_diffuse,comb_table.spring_diffuse,comb_table.SDepth_peat_gapfilled_only_snowcovered],[],comb_table.peatland_summer_albedo>0.1589);
ylabel(AX(1,1),'Diff. in absorb. SW','FontSize',plotmatrix_fontsize)
ylabel(AX(2,1),'Snowmelt','FontSize',plotmatrix_fontsize)
ylabel(AX(3,1),'Spring glob.','FontSize',plotmatrix_fontsize)
ylabel(AX(4,1),'Peat Summer albedo','FontSize',plotmatrix_fontsize)
ylabel(AX(5,1),'Summer diffuse','FontSize',plotmatrix_fontsize)
ylabel(AX(6,1),'Spring diffuse','FontSize',plotmatrix_fontsize)
ylabel(AX(7,1),'Snowdepth peat','FontSize',plotmatrix_fontsize)


xlabel(AX(7,1),'Diff. in absorb. SW','FontSize',plotmatrix_fontsize)
xlabel(AX(7,2),'Snowmelt','FontSize',plotmatrix_fontsize)
xlabel(AX(7,3),'Spring glob.','FontSize',plotmatrix_fontsize)
xlabel(AX(7,4),'Peat Summer albedo','FontSize',plotmatrix_fontsize)
xlabel(AX(7,5),'Summer diffuse','FontSize',plotmatrix_fontsize)
xlabel(AX(7,6),'Spring diffuse','FontSize',plotmatrix_fontsize)
xlabel(AX(7,7),'Snowdepth peat','FontSize',plotmatrix_fontsize)

for ii = 1:7
    for jj = 1:7
        if ii ~= jj
           text(AX(ii,jj),0.5,0.1,['r^2 = ',num2str(corrs_both(ii,jj).^2)],'units','normalized','FontSize', plotmatrix_fontsize)
        end
    end
end
        


 AX(1,7).Legend.String = {'North','South'};

 AX(1,7).Legend.Location = 'northwest';
 AX(1,7).Legend.FontSize = plotmatrix_fontsize;

 % save_figure_OP(figi66,'../figs/explanatory_plotmatrix')