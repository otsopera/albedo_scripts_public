close all
clear variables


load('../vars/skyla_tt_cleaned.mat')
load('../vars/skyla_tt_daily_cleaned.mat')


load('../vars/hyde_tt_cleaned_calibrated.mat')
load('../vars/hyde_tt_daily_cleaned_calibrated.mat')



plot_font_size = 36;



%%

hyde_DOY_stats = grpstats(hyde_tt_daily,'DOY',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75)});
skyla_DOY_stats = grpstats(skyla_tt_daily,'DOY',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75),@(x)prctile(x,5),@(x)prctile(x,95)});


hyde_week_stats = grpstats(hyde_tt_daily,'week',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75),@(x)prctile(x,5),@(x)prctile(x,95)});
skyla_week_stats = grpstats(skyla_tt_daily,'week',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75),@(x)prctile(x,5),@(x)prctile(x,95)});

hyde_week_stats_prethin = grpstats(hyde_tt_daily(hyde_tt_daily.Time.Year<2019.5,:),'week',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75),@(x)prctile(x,5),@(x)prctile(x,95)});
hyde_week_stats_thinned = grpstats(hyde_tt_daily(hyde_tt_daily.Time.Year>2019.5,:),'week',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75),@(x)prctile(x,5),@(x)prctile(x,95)});
%%

whitesky_threshold_hyde = 0.85;
bluesky_threshold_hyde = 0.4;

whitesky_threshold_skyla = 0.95;
bluesky_threshold_skyla = 0.35;






%%

whitesky_hyde_siika = hyde_tt_daily.diff_frac>whitesky_threshold_hyde;

bluesky_hyde_siika = hyde_tt_daily.diff_frac<bluesky_threshold_hyde;


whitesky_skyla_halssi = skyla_tt_daily.diff_frac>whitesky_threshold_skyla;

bluesky_skyla_halssi = skyla_tt_daily.diff_frac<bluesky_threshold_skyla;



whitesky_hyde_siika_30min = hyde_tt.diff_frac>whitesky_threshold_hyde;

bluesky_hyde_siika_30min  = hyde_tt.diff_frac<bluesky_threshold_hyde;


whitesky_skyla_halssi_30min  = skyla_tt.diff_frac>whitesky_threshold_skyla;

bluesky_skyla_halssi_30min  = skyla_tt.diff_frac<bluesky_threshold_skyla;



%%


figi2 = figure();
set(figi2,'outerposition',[200 200 1920 1080]);

plot_m = 10;
plot_n = 12;

yl_rad = [-650 1000];


subi22(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:3));

subi22(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,5:7));


subi22(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,9:12));

subi22(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,7:10,1:6));


subi22(5) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,7:10,7:12));

axes(subi22(1))
scatter(hyde_tt_daily.DOY(bluesky_hyde_siika&hyde_tt_daily.SDepth_SII_gapfilled<0.1),hyde_tt_daily.albedo_siika(bluesky_hyde_siika&hyde_tt_daily.SDepth_SII_gapfilled<0.1),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'WTD (cm)')
% title('Blue sky albedo, siika')
set_plot_font(gca,plot_font_size)
xlabel('DOY')
ylabel('Albedo')

axes(subi22(2))
scatter(hyde_tt_daily.WTD_SII(bluesky_hyde_siika&hyde_tt_daily.SDepth_SII_gapfilled<0.1),hyde_tt_daily.albedo_siika(bluesky_hyde_siika&hyde_tt_daily.SDepth_SII_gapfilled<0.1),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'DOY')
xlabel('WTD (cm)')
title('Clear sky albedo, Siikaneva, only no-snow points')
set_plot_font(gca,plot_font_size)
yticklabels([])

axes(subi22(3))
scatter(hyde_tt_daily.Wsoil_SII(bluesky_hyde_siika&hyde_tt_daily.SDepth_SII_gapfilled<0.1),hyde_tt_daily.albedo_siika(bluesky_hyde_siika&hyde_tt_daily.SDepth_SII_gapfilled<0.1),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'DOY')
xlabel('Soil moisture')
% title('Blue sky albedo, siika')
set_plot_font(gca,plot_font_size)
yticklabels([])


axes(subi22(4))
scatter(skyla_tt_daily.DOY(bluesky_skyla_halssi&skyla_tt_daily.SDepth_peat_gapfilled<0.1),skyla_tt_daily.albedo_halssi(bluesky_skyla_halssi&skyla_tt_daily.SDepth_peat_gapfilled<0.1),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'WTD (cm)')
% title('Blue sky albedo, siika')
set_plot_font(gca,plot_font_size)
xlabel('DOY')
ylabel('Albedo')

axes(subi22(5))
scatter(skyla_tt_daily.WTL1_peat(bluesky_skyla_halssi&skyla_tt_daily.SDepth_peat_gapfilled<0.1),skyla_tt_daily.albedo_halssi(bluesky_skyla_halssi&skyla_tt_daily.SDepth_peat_gapfilled<0.1),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'DOY')
xlabel('WTD (cm)')
text(-0.7,1.1,'\bf{Clear sky albedo, Halssiaapa, only no-snow points}','fontsize',36,'units','normalized')
set_plot_font(gca,plot_font_size)
yticklabels([])

% save_figure_OP(figi2,'../figs/peatlands_wtl_doy_wsoil')





%% diffuse radiation on x-axis, winter

figi111 = figure();
set(figi111,'outerposition',[200 200 1920 1080]);

plot_m = 9;
plot_n = 4;

yl_rad = [-650 1000];


subi_alb(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
subi_alb(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
% subi3 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,1:2));

subi_alb(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));
subi_alb(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));
% subi3_2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,3:4));



SD_cutoff_winter = 10;

axes(subi_alb(1))
scatter(hyde_tt_daily.diff_frac(hyde_tt_daily.SnowDepth_HYY > SD_cutoff_winter),hyde_tt_daily.albedo_hyde(hyde_tt_daily.SnowDepth_HYY > SD_cutoff_winter),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'Diffuse fraction')
title('Hyytiälä')
set_plot_font(gca,plot_font_size)
grid on



axes(subi_alb(2))

scatter(hyde_tt_daily.diff_frac(hyde_tt_daily.SnowDepth_SII > SD_cutoff_winter),hyde_tt_daily.albedo_siika(hyde_tt_daily.SnowDepth_SII > SD_cutoff_winter),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'Diffuse fraction')
title('Siikaneva')
xlabel('Diffuse fraction of PAR')
set_plot_font(gca,plot_font_size)
grid on

axes(subi_alb(3))

scatter(skyla_tt_daily.diff_frac(skyla_tt_daily.SDepth_forest>SD_cutoff_winter),skyla_tt_daily.albedo_skyla(skyla_tt_daily.SDepth_forest>SD_cutoff_winter),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
xlim([0 1])
% ylabel(cb,'Snow depth (cm)')
title('Halssikangas')
set_plot_font(gca,plot_font_size)

grid on

axes(subi_alb(4))

scatter(skyla_tt_daily.diff_frac(skyla_tt_daily.SDepth_peat>SD_cutoff_winter),skyla_tt_daily.albedo_halssi(skyla_tt_daily.SDepth_peat>SD_cutoff_winter),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
xlim([0 1])
% ylabel(cb,'Snow depth (cm)')
xlabel('Diffuse fraction of SW radiation')
title('Halssiaapa')
set_plot_font(gca,plot_font_size)

grid on


% xlim(subi_alb,[0 366])
ylim(subi_alb,[0 1])

clim(subi_alb(1),[0 110])
clim(subi_alb(2),[0 110])
clim(subi_alb(3),[0 110])
clim(subi_alb(4),[0 110])

text(subi_alb(2),-0.25,0.4,'Shortwave albedo, snow-covered','fontsize',plot_font_size,'rotation',90,'units','normalized')

text(subi_alb(1),-0.17,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi_alb(2),-0.17,1.1,'b','fontsize',plot_font_size,'units','normalized')
% text(subi3,-0.17,1.1,'c','fontsize',plot_font_size,'units','normalized')

text(subi_alb(3),-0.1,1.1,'c','fontsize',plot_font_size,'units','normalized')
text(subi_alb(4),-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')


% save_figure_OP(figi111,'../figs/albedo_vs_diffuse_winter')


%% diffuse radiation on x-axis, summer
figi112 = figure();
set(figi112,'outerposition',[200 200 1920 1080]);

plot_m = 9;
plot_n = 4;

yl_rad = [-650 1000];


subi_alb(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
subi_alb(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
% subi3 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,1:2));

subi_alb(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));
subi_alb(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));
% subi3_2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,3:4));



SD_cutoff_summer = 1e-3;

axes(subi_alb(1))
scatter(hyde_tt_daily.diff_frac(hyde_tt_daily.SnowDepth_HYY < SD_cutoff_summer & hyde_tt_daily.SnowDepth_SII < SD_cutoff_summer),hyde_tt_daily.albedo_hyde(hyde_tt_daily.SnowDepth_HYY < SD_cutoff_summer & hyde_tt_daily.SnowDepth_SII < SD_cutoff_summer),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'Diffuse fraction')
title('Hyytiälä')
set_plot_font(gca,plot_font_size)
grid on



axes(subi_alb(2))

scatter(hyde_tt_daily.diff_frac(hyde_tt_daily.SnowDepth_HYY < SD_cutoff_summer & hyde_tt_daily.SnowDepth_SII < SD_cutoff_summer),hyde_tt_daily.albedo_siika(hyde_tt_daily.SnowDepth_HYY < SD_cutoff_summer & hyde_tt_daily.SnowDepth_SII < SD_cutoff_summer),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'Diffuse fraction')
title('Siikaneva')
xlabel('Diffuse fraction of PAR')
set_plot_font(gca,plot_font_size)
grid on

axes(subi_alb(3))

scatter(skyla_tt_daily.diff_frac(skyla_tt_daily.SDepth_forest<SD_cutoff_summer & skyla_tt_daily.SDepth_peat<SD_cutoff_summer),skyla_tt_daily.albedo_skyla(skyla_tt_daily.SDepth_forest<SD_cutoff_summer & skyla_tt_daily.SDepth_peat<SD_cutoff_summer),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
xlim([0 1])
% ylabel(cb,'Snow depth (cm)')
title('Halssikangas')
set_plot_font(gca,plot_font_size)

grid on

axes(subi_alb(4))

scatter(skyla_tt_daily.diff_frac(skyla_tt_daily.SDepth_forest<SD_cutoff_summer & skyla_tt_daily.SDepth_peat<SD_cutoff_summer),skyla_tt_daily.albedo_halssi(skyla_tt_daily.SDepth_forest<SD_cutoff_summer & skyla_tt_daily.SDepth_peat<SD_cutoff_summer),60,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
xlim([0 1])
% ylabel(cb,'Snow depth (cm)')
xlabel('Diffuse fraction of SW radiation')
title('Halssiaapa')
set_plot_font(gca,plot_font_size)

grid on


% xlim(subi_alb,[0 366])
ylim(subi_alb,[0 0.3])

clim(subi_alb(1),[0 110])
clim(subi_alb(2),[0 110])
clim(subi_alb(3),[0 110])
clim(subi_alb(4),[0 110])

text(subi_alb(2),-0.25,0.5,'Shortwave albedo, snow-free','fontsize',plot_font_size,'rotation',90,'units','normalized')

text(subi_alb(1),-0.17,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi_alb(2),-0.17,1.1,'b','fontsize',plot_font_size,'units','normalized')
% text(subi3,-0.17,1.1,'c','fontsize',plot_font_size,'units','normalized')

text(subi_alb(3),-0.1,1.1,'c','fontsize',plot_font_size,'units','normalized')
text(subi_alb(4),-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')


% save_figure_OP(figi112,'../figs/albedo_vs_diffuse_summer')



%%
figi2 = figure();
set(figi2,'outerposition',[200 200 1920 1080]);

plot_m = 9;
plot_n = 4;

yl_rad = [-650 1000];


subi_alb(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
subi_alb(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
% subi3 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,1:2));

subi_alb(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));
subi_alb(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));
% subi3_2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,3:4));

axes(subi_alb(1))
scatter(hyde_tt_daily.DOY,hyde_tt_daily.PAR_albedo_hyde,60,hyde_tt_daily.diff_frac,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
% ylabel(cb,'Diffuse fraction')
title('Hyytiälä')
set_plot_font(gca,plot_font_size)



axes(subi_alb(2))
scatter(hyde_tt_daily.DOY,hyde_tt_daily.PAR_albedo_siika,60,hyde_tt_daily.diff_frac,'filled','MarkerEdgeColor',[0 0 0])
% cb  = colorbar;
xlabel('DOY')
% ylabel(cb,'Diffuse fraction')
title('Siikaneva')
set_plot_font(gca,plot_font_size)


axes(subi_alb(3))
scatter(skyla_tt_daily.DOY,skyla_tt_daily.PAR_albedo_skyla,60,skyla_tt_daily.diff_frac,'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
clim([0 1])
ylabel(cb,'Diffuse fraction')
title('Halssikangas')
set_plot_font(gca,plot_font_size)


axes(subi_alb(4))
scatter(skyla_tt_daily.DOY,skyla_tt_daily.PAR_albedo_halssi,60,skyla_tt_daily.diff_frac,'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
clim([0 1])
xlabel('DOY')
ylabel(cb,'Diffuse fraction')
title('Halssiaapa')
set_plot_font(gca,plot_font_size)





xlim(subi_alb,[0 366])
ylim(subi_alb,[0 0.15])


text(subi_alb(2),-0.25,0.8,'PAR albedo','fontsize',plot_font_size,'rotation',90,'units','normalized')

text(subi_alb(1),-0.17,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi_alb(2),-0.17,1.1,'b','fontsize',plot_font_size,'units','normalized')
% text(subi3,-0.17,1.1,'c','fontsize',plot_font_size,'units','normalized')

text(subi_alb(3),-0.1,1.1,'c','fontsize',plot_font_size,'units','normalized')
text(subi_alb(4),-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')
% 
% save_figure_OP(figi2,'../figs/all_par_albedo')


%%

figi5 = figure();
set(figi5,'outerposition',[200 200 1920 1080]);

scatter(hyde_tt_daily.DOY(bluesky_hyde_siika),hyde_tt_daily.PAR_albedo_hyde(bluesky_hyde_siika),150,hyde_tt_daily.Time.Year(bluesky_hyde_siika),'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
ylabel(cb,'Year')
title('Hyytiälä clear sky PAR albedo')
set_plot_font(gca,plot_font_size)
ylim([0 0.15])
colormap('turbo')
xlabel('DOY')
ylabel('PAR albedo')
% save_figure_OP(figi5,'../figs/hyde_par_albedo_years')


figure();
scatter(hyde_tt_daily.DOY(whitesky_hyde_siika),hyde_tt_daily.PAR_albedo_hyde(whitesky_hyde_siika),60,hyde_tt_daily.Time.Year(whitesky_hyde_siika),'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
ylabel(cb,'Year')
title('Hyde white sky PAR albedo')
set_plot_font(gca,plot_font_size)
ylim([0 0.15])
colormap('turbo')
xlabel('DOY')


figure();
scatter(hyde_tt_daily.DOY(bluesky_hyde_siika),hyde_tt_daily.PAR_albedo_siika(bluesky_hyde_siika),60,hyde_tt_daily.Time.Year(bluesky_hyde_siika),'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
ylabel(cb,'Year')
title('Siikaneva blue sky PAR albedo')
set_plot_font(gca,plot_font_size)
ylim([0 0.15])
colormap('turbo')

figure();
scatter(skyla_tt_daily.DOY(bluesky_skyla_halssi),skyla_tt_daily.PAR_albedo_skyla(bluesky_skyla_halssi),60,skyla_tt_daily.Time.Year(bluesky_skyla_halssi),'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
ylabel(cb,'Year')
title('Skyla blue sky PAR albedo')
set_plot_font(gca,plot_font_size)
ylim([0 0.15])
colormap('turbo')

figure();
scatter(skyla_tt_daily.DOY(bluesky_skyla_halssi),skyla_tt_daily.PAR_albedo_halssi(bluesky_skyla_halssi),60,skyla_tt_daily.Time.Year(bluesky_skyla_halssi),'filled','MarkerEdgeColor',[0 0 0])
cb  = colorbar;
ylabel(cb,'Year')
title('Halssi blue sky PAR albedo')
set_plot_font(gca,plot_font_size)
ylim([0 0.15])
colormap('turbo')





%%



figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 2;
plot_n = 2;

yl_rad = [-60 200];
clim_snow = [0 90];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1,ceil(plot_n/2)+1:plot_n));

subi(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,plot_m,1:floor(plot_n/2)));
subi(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,plot_m,ceil(plot_n/2)+1:plot_n));



axes(subi(1))
scatter(hyde_tt.Glob_HYY_tower(~hyde_tt.bad_times_hyde),hyde_tt.RGlob_HYY125(~hyde_tt.bad_times_hyde),20,hyde_tt.diff_frac(~hyde_tt.bad_times_hyde),'filled');

% colormap('turbo');
title('Hyytiälä')
set_plot_font(gca,plot_font_size)  
% ylabel('Reflected SW radiation')
% xlabel('Global radiation')
% cb = colorbar;
% ylabel(cb,'Diffuse radiation fraction')
clim([0 1])

axes(subi(3))
scatter(hyde_tt.Glob_HYY_tower(~hyde_tt.bad_times_hyde),hyde_tt.RGlob_HYY125(~hyde_tt.bad_times_hyde),20,hyde_tt.zenith_hyde(~hyde_tt.bad_times_hyde),'filled');
% cb = colorbar;
% colormap('turbo');
% title('Hyytiälä')
set_plot_font(gca,plot_font_size)

% ylabel('Reflected SW radiation')
xlabel('Global radiation (W m^{-2})')
% ylabel(cb,'Zenith angle')
clim([40 90])



axes(subi(2))
scatter(skyla_tt.GLOB_forest(~skyla_tt.bad_times_skyla),skyla_tt.REFL_forest(~skyla_tt.bad_times_skyla),20,skyla_tt.diff_frac(~skyla_tt.bad_times_skyla),'filled');

% colormap('turbo');
title('Halssikangas')
set_plot_font(gca,plot_font_size)  
% ylabel('Reflected SW radiation')
% xlabel('Global radiation')
cb = colorbar;
ylabel(cb,'Diffuse radiation fraction')
clim([0 1])

axes(subi(4))
scatter(skyla_tt.GLOB_forest(~skyla_tt.bad_times_skyla),skyla_tt.REFL_forest(~skyla_tt.bad_times_skyla),20,skyla_tt.zenith_skyla(~skyla_tt.bad_times_skyla),'filled');
cb = colorbar;
% colormap('turbo');
% title('Sodankylä')
set_plot_font(gca,plot_font_size)

% ylabel('Reflected glob')
xlabel('Global radiation (W m^{-2})')
ylabel(cb,'Zenith angle')
clim([40 90])

text(subi(3),-0.25,0.45,'Reflected SW radiation (W m^{-2})','fontsize',36,'units','normalized','Rotation',90)


% save_figure_OP(figi31,'../figs/forests_albedo_diff_zenith')

%%



figi2 = figure();
set(figi2,'outerposition',[200 200 1920 1080]);

plot_m = 9;
plot_n = 4;

yl_rad = [-650 1000];


subi22(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
hold on
subi22(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));


subi22(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
hold on
subi22(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));

axes(subi22(1))
plot(hyde_tt_daily.DOY(whitesky_hyde_siika&~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.albedo_hyde(whitesky_hyde_siika&~hyde_tt_daily.bad_days_hyde),'.','MarkerSize',20,'MarkerEdgeColor',[0.5 0.5 0.5])
hold on
plot(hyde_tt_daily.DOY(bluesky_hyde_siika&~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.albedo_hyde(bluesky_hyde_siika&~hyde_tt_daily.bad_days_hyde),'b.','MarkerSize',20)
title('Hyytiälä')
% xlabel('DOY')
ylabel('Albedo')
legend('White sky','Clear sky')
% grid on
set_plot_font(gca,36)


axes(subi22(2))
plot(skyla_tt_daily.DOY(whitesky_skyla_halssi&~skyla_tt_daily.bad_days_skyla),skyla_tt_daily.albedo_skyla(whitesky_skyla_halssi&~skyla_tt_daily.bad_days_skyla),'.','MarkerSize',20,'MarkerEdgeColor',[0.5 0.5 0.5])
hold on
plot(skyla_tt_daily.DOY(bluesky_skyla_halssi&~skyla_tt_daily.bad_days_skyla),skyla_tt_daily.albedo_skyla(bluesky_skyla_halssi&~skyla_tt_daily.bad_days_skyla),'b.','MarkerSize',20)
set_plot_font(gca,36)
% legend('White sky','Clear sky')
% xlabel('DOY')
% ylabel('Albedo')
title('Halssikangas')



axes(subi22(3))
plot(hyde_tt_daily.DOY(whitesky_hyde_siika&~hyde_tt_daily.bad_days_siika),hyde_tt_daily.albedo_siika(whitesky_hyde_siika&~hyde_tt_daily.bad_days_siika),'.','MarkerSize',20,'MarkerEdgeColor',[0.5 0.5 0.5])
hold on
plot(hyde_tt_daily.DOY(bluesky_hyde_siika&~hyde_tt_daily.bad_days_siika),hyde_tt_daily.albedo_siika(bluesky_hyde_siika&~hyde_tt_daily.bad_days_siika),'b.','MarkerSize',20)
title('Siikaneva')
xlabel('DOY')
ylabel('Albedo')
% legend('White sky','Clear sky')
% grid on
set_plot_font(gca,36)


axes(subi22(4))
plot(skyla_tt_daily.DOY(whitesky_skyla_halssi&~skyla_tt_daily.bad_days_halssi),skyla_tt_daily.albedo_halssi(whitesky_skyla_halssi&~skyla_tt_daily.bad_days_halssi),'.','MarkerSize',20,'MarkerEdgeColor',[0.5 0.5 0.5])
hold on
plot(skyla_tt_daily.DOY(bluesky_skyla_halssi&~skyla_tt_daily.bad_days_halssi),skyla_tt_daily.albedo_halssi(bluesky_skyla_halssi&~skyla_tt_daily.bad_days_halssi),'b.','MarkerSize',20)
set_plot_font(gca,36)
% legend('White sky','Clear sky')
xlabel('DOY')
% ylabel('Albedo')
title('Halssiaapa')


text(subi22(1),-0.2,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi22(3),-0.2,1.1,'b','fontsize',plot_font_size,'units','normalized')

text(subi22(2),-0.1,1.1,'c','fontsize',plot_font_size,'units','normalized')
text(subi22(4),-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')


ylim(subi22,[0 1])
xlim(subi22,[0 366])
% save_figure_OP(figi2,'../figs/all_white_bluesky_albedo')
