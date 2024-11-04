% close all
clear variables

load('../vars/hyde_tt_cleaned_calibrated.mat')
load('../vars/hyde_tt_daily_cleaned_calibrated.mat')
load('../vars/skyla_tt_cleaned.mat')
load('../vars/skyla_tt_daily_cleaned.mat')



plot_font_size = 36;

%% hyde and siikaneva ts, daily: Fig. 2 in manuscript

figi11 = figure();
set(figi11,'outerposition',[200 200 1920 1080]);


% subi1 = subplot(9,1,1:4);
% subi2 = subplot(9,1,6:9);
% 


plot_m = 12;
plot_n = 4;

yl_rad = [-250 400];


subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
subi3 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,1:2));

subi1_2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));
subi2_2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));
subi3_2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,10:12,3:4));



axes(subi2)
plot(hyde_tt_daily.Time,[hyde_tt_daily.Glob_SII,-1*hyde_tt_daily.RGlob_SII]);
set_plot_font(subi2,plot_font_size)
% yl = ylim;
ylim(subi2,yl_rad)
title('Siikaneva')


axes(subi3)
bar(hyde_tt_daily.Time,hyde_tt_daily.SDepth_SII_gapfilled,'BarWidth',1)
set_plot_font(subi3,plot_font_size)
% yl = ylim;
text(subi3,-0.25,-0.3,'Snow depth (cm)','fontsize',plot_font_size,'units','normalized','Rotation',90)
% title('Siikaneva')
% [~, hobj, ~, ~] = legend('Global','Reflected');
% hl = findobj(hobj,'type','line');
% set(hl,'LineWidth',4);


axes(subi1)
plot(hyde_tt_daily.Time,[hyde_tt_daily.Glob_HYY_tower,-1*hyde_tt_daily.RGlob_HYY125]) 
ylim(subi1,yl_rad)
% legend('Siika Global','Siika Reflected Global','Hyde Global','HydeReflected Global')
title('Hyytiälä')
set_plot_font(gca,plot_font_size)
xl = xlim;
xlim(subi2,xl)


subi1.XTickLabel = [];
subi2.XTickLabel = [];
subi3.XTick = datetime(2017,1,1,'TimeZone','+02:00'):calyears(2):datetime(2023,1,1,'TimeZone','+02:00');
text(subi2,-0.25,0.5,'Shortwave radiation (W m^{-2})','fontsize',plot_font_size,'units','normalized','Rotation',90)




% save_figure_OP(figi1,'../figs/hyde_siika_ts')


% Halssiaapa and Sodankylä ts


% figi2 = figure();
% set(figi2,'outerposition',[200 200 1920 1080]);

% subi2_1 = subplot(9,1,1:4);
% subi2_2 = subplot(9,1,6:9);




axes(subi2_2)
plot(skyla_tt_daily.Time,[skyla_tt_daily.GLOB_peat,-1*skyla_tt_daily.REFL_peat]);
set_plot_font(subi2_2,plot_font_size)


subi2_2.YAxisLocation = 'right';
title('Halssiaapa')
xl = xlim;
ylim(subi2_2,yl_rad)




axes(subi1_2)

plot(skyla_tt_daily.Time,[skyla_tt_daily.GLOB_forest,-1*skyla_tt_daily.REFL_forest]) 
ylim(subi1_2,yl_rad)

subi1_2.YAxisLocation = 'right';
% legend('Siika Global','Siika Reflected Global','Hyde Global','HydeReflected Global')
title('Halssikangas')
set_plot_font(gca,plot_font_size)

[~, hobj, ~, ~] = legend('Global','Reflected','Location','southeast');
hl = findobj(hobj,'type','line');
set(hl,'LineWidth',4);


axes(subi3_2)
bar(skyla_tt_daily.Time,skyla_tt_daily.SDepth_peat_gapfilled,'BarWidth',1)
set_plot_font(subi3_2,plot_font_size)
yl = ylim();
ylim(subi3,yl)


xlim(subi1_2,xl)

text(subi1,-0.17,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.1,'b','fontsize',plot_font_size,'units','normalized')
text(subi3,-0.17,1.1,'c','fontsize',plot_font_size,'units','normalized')

text(subi1_2,-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')
text(subi2_2,-0.1,1.1,'e','fontsize',plot_font_size,'units','normalized')
text(subi3_2,-0.1,1.1,'f','fontsize',plot_font_size,'units','normalized')

subi1_2.XTickLabel = [];
subi2_2.XTickLabel = [];

subi3_2.YAxisLocation = 'right';
% text(subi2_2,-0.1,0.5,'Shortwave radiation (W m^{-2})','fontsize',plot_font,'units','normalized','Rotation',90)


% save_figure_OP(figi11,'../figs/all_sites_ts_daily')

%% forest vs. peatland global: Fig. A3 in manuscript

figi3 = figure();
set(figi3,'outerposition',[200 200 1920 1080]);

yl = [-50 1100];
xl = [-50 1000];

subi3_1 = subplot(1,2,1);
subi3_2 = subplot(1,2,2);


lm = fitlm(timetable2table(hyde_tt),'Glob_SII~Glob_HYY_tower','robust',0);

both_exist = ~isnan(hyde_tt.Glob_HYY_tower) & ~isnan(hyde_tt.Glob_SII);

v = pca([hyde_tt.Glob_HYY_tower hyde_tt.Glob_SII]);
beta = v(2,1)/v(1,1);

intercept = mean(hyde_tt.Glob_SII(both_exist)) - mean(beta*hyde_tt.Glob_HYY_tower(both_exist));

r_hyy = corrcoef(hyde_tt.Glob_HYY_tower,hyde_tt.Glob_SII,'rows','pairwise');


axes(subi3_1)
scatter(hyde_tt.Glob_HYY_tower,hyde_tt.Glob_SII,15,'filled')
hold on 
scatter(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_SII,30,'filled')
plot(hyde_tt.Glob_HYY_tower,hyde_tt.Glob_HYY_tower*beta + intercept,'LineWidth',4)
% plot(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_SII,'.',hyde_tt.Glob_HYY_tower,lm.Fitted,'LineWidth',6,'MarkerSize',20)
xlabel('Global radiation, Hyytiälä (W m^{-2})');ylabel('Global radiation, Siikaneva (W m^{-2})')

legend('30 min values','Daily means',['{\it y} = ',num2str(beta,3),'{\it x} - ',num2str(-intercept,1),', {\it r}^2 = ',num2str(r_hyy(1,2)^2,2)],'Location','northwest')
% legend('30 min values','Daily medians',['y = ',num2str(lm.Coefficients.Estimate(2),3),' \times x + ',num2str(lm.Coefficients.Estimate(1),3)],'Location','northwest')
set_plot_font(gca,plot_font_size)
ylim(yl)
xlim(xl)
% save_figure_OP(gcf,'../figs/hyde_vs_siik_glob')
% save_figure_OP(gcf,'../figs/hyde_vs_siik_glob_robust')



% sodankylä vs. halssiaapa global
lm_skyla = fitlm(timetable2table(skyla_tt),'GLOB_peat~GLOB_forest','robust',0);

both_exist_skyla = ~isnan(skyla_tt.GLOB_peat) & ~isnan(skyla_tt.GLOB_forest);

v2 = pca([skyla_tt.GLOB_forest skyla_tt.GLOB_peat]);
beta_skyla = v2(2,1)/v2(1,1);

intercept_skyla = mean(skyla_tt.GLOB_peat(both_exist_skyla)) - mean(beta_skyla*skyla_tt.GLOB_forest(both_exist_skyla));

r_skyla = corrcoef(skyla_tt.GLOB_forest,skyla_tt.GLOB_peat,'rows','pairwise');


% figi4 = figure();
% set(figi4,'outerposition',[200 200 1920 1080]);

axes(subi3_2)
scatter(skyla_tt.GLOB_forest,skyla_tt.GLOB_peat,15,'filled')
hold on 
scatter(skyla_tt_daily.GLOB_forest,skyla_tt_daily.GLOB_peat,50,'filled')
hold on 
plot(skyla_tt.GLOB_forest,skyla_tt.GLOB_forest*beta_skyla + intercept_skyla,'LineWidth',4)
% plot(skyla_tt_daily.GLOB_forest,skyla_tt_daily.GLOB_peat,'.',skyla_tt.GLOB_forest,lm_skyla.Fitted,'LineWidth',6,'MarkerSize',20)
ylim(yl)
xlim(xl)

legend('30 min values','Daily means',['{\it y} = ',num2str(beta_skyla,3),'{\it x} + ',num2str(intercept_skyla,2),', {\it r}^2 = ',num2str(r_skyla(1,2)^2,2)],'Location','northwest');
% legend('30 min values','Daily medians',['y = ',num2str(lm_skyla.Coefficients.Estimate(2),3),' \times x + ',num2str(lm_skyla.Coefficients.Estimate(1),3)],'Location','northwest')

% legend({'one','two'}); % Instead of "h_legend" use "[~, objh]"
% objhl = findobj(objh, 'type', 'line');
% objht = findobj(objh, 'type', 'text');
% set(objhl, 'Markersize', 15,'LineWidth',4);
% set(objht, 'FontSize', plot_font);

xlabel('Global radiation, Halssikangas (W m^{-2})');ylabel('Global radiation, Halssiaapa (W m^{-2})')
% legend('Observations',['Linear regression: Peat = ',num2str(lm_skyla.Coefficients.Estimate(2),3),'\times Forest + ',num2str(lm_skyla.Coefficients.Estimate(1),3)],'Location','best')
set_plot_font(gca,plot_font_size)
% save_figure_OP(gcf,'../figs/hyde_vs_siik_glob')
% save_figure_OP(gcf,'../figs/hyde_vs_siik_glob_robust')

% save_figure_OP(figi3,'../figs/glob_comparisons')


%% albedo vs. snow depth: Fig. A5 in manuscript


figi_snow_albedo = figure();
set(figi_snow_albedo,'outerposition',[200 200 1920 1080]);





plot_m = 1;
plot_n = 2;

yl_rad = [-650 1000];


subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));




scatter(subi1,hyde_tt_daily.SnowDepth_SII(~hyde_tt_daily.bad_days_siika),hyde_tt_daily.albedo_siika(~hyde_tt_daily.bad_days_siika),150,hyde_tt_daily.DOY(~hyde_tt_daily.bad_days_siika),'filled','MarkerEdgeColor',[0 0 0]);
colormap(subi1,'hsv');

xlabel(subi1,'Peatland snow depth (cm)')
ylabel(subi1,'Albedo')
title(subi1,'Siikaneva')
set_plot_font(subi1,plot_font_size)


scatter(subi2,skyla_tt_daily.SDepth_peat(~skyla_tt_daily.bad_days_halssi),skyla_tt_daily.albedo_halssi(~skyla_tt_daily.bad_days_halssi),150,skyla_tt_daily.DOY(~skyla_tt_daily.bad_days_halssi),'filled','MarkerEdgeColor',[0 0 0]);
colormap(subi2,'hsv');
cb = colorbar(subi2);
ylabel(cb,'Day of year')
% cb = colorbar;
xlabel(subi2,'Peatland snow depth (cm)')
ylabel(subi2,'Albedo')
% ylabel(cb,'Day of year')
title(subi2,'Halssiaapa')
set_plot_font(subi2,plot_font_size)

text(subi1,-0.17,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')



% save_figure_OP(figi_snow_albedo,'../figs/albedo_vs_snow')





%% refl vs glob plot in daily time resolution: Fig. 3 in manuscript

figi44 = figure();

set(figi44,'outerposition',[200 200 1920 1080]);

yl = [0 1000];
cl_snow = [0 120];
% m = 11;
% n = 11;
% 
% 
% 
% 
% m_n_grid_coordinates_to_lin_row_idx(m,n,1:floor(m/2),1:floor(n/2));
% 
% 
% subi4_1 = subplot(m,n,m_n_grid_coordinates_to_lin_row_idx(m,n,1:floor(m/2),1:floor(n/2)));
% subi4_2 = subplot(m,n,m_n_grid_coordinates_to_lin_row_idx(m,n,ceil(m/2)+1:m,1:floor(n/2)));
% 
% subi4_3 = subplot(m,n,m_n_grid_coordinates_to_lin_row_idx(m,n,1:floor(m/2),ceil(n/2)+1:n));
% subi4_4 = subplot(m,n,m_n_grid_coordinates_to_lin_row_idx(m,n,ceil(m/2)+1:m,ceil(n/2)+1:n));



subi4(1) = subplot(2,2,1);
subi4(2) = subplot(2,2,3);
subi4(3) = subplot(2,2,2);
subi4(4) = subplot(2,2,4);


siika_albedoes = [0.16 0.77];
hyde_albedoes = [0.105 0.18];
halssiaapa_albedoes = [0.13 0.8];
sodankyla_albedoes = [0.115 0.18];


axes(subi4(1))
scatter(hyde_tt_daily.Glob_HYY_tower(~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.RGlob_HYY125(~hyde_tt_daily.bad_days_hyde),[],hyde_tt_daily.SnowDepth_HYY(~hyde_tt_daily.bad_days_hyde),'filled')%,'markeredgecolor','k')
title('Hyytiälä')

ylabel('Reflected radiation (Wm^{-2})')
set_plot_font(gca,plot_font_size)
hold on
plot(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_HYY_tower*hyde_albedoes(1),hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_HYY_tower*hyde_albedoes(2),'LineWidth',3)
legend('Daily values',['Albedo ',num2str(hyde_albedoes(1))],['Albedo ',num2str(hyde_albedoes(2))],'Location','northwest')
cb(1) = colorbar;
% ylabel(cb,'Snow depth (cm)')
% save_figure_OP(gcf,'../figs/hyde_refl_vs_glob')
% 0.11
% 0.22
% clim([0 120])
clim(cl_snow)
axes(subi4(2))
scatter(hyde_tt_daily.Glob_SII(~hyde_tt_daily.bad_days_siika),hyde_tt_daily.RGlob_SII(~hyde_tt_daily.bad_days_siika),[],hyde_tt_daily.SnowDepth_SII(~hyde_tt_daily.bad_days_siika),'filled')%,'markeredgecolor','k')
title('Siikaneva')
ylabel('Reflected radiation (Wm^{-2})')
set_plot_font(gca,plot_font_size)
hold on
plot(hyde_tt_daily.Glob_SII,[hyde_tt_daily.Glob_SII*siika_albedoes(1),hyde_tt_daily.Glob_SII*siika_albedoes(2)],'LineWidth',3)
legend('Daily values',['Albedo ',num2str(siika_albedoes(1))],['Albedo ',num2str(siika_albedoes(2))],'Location','northwest')
cb(2) = colorbar;
% ylabel(cb,'Snow depth (cm)')
% save_figure_OP(gcf,'../figs/siik_refl_vs_glob')
% 0.15
% 0.8
% clim([0 120])



xlabel(subi4(2),'Global radiation (Wm^{-2})');
clim(cl_snow)


axes(subi4(3))
scatter(skyla_tt_daily.GLOB_forest(~skyla_tt_daily.bad_days_skyla),skyla_tt_daily.REFL_forest(~skyla_tt_daily.bad_days_skyla),[],skyla_tt_daily.SDepth_forest(~skyla_tt_daily.bad_days_skyla),'filled')
title('Halssikangas')

set_plot_font(gca,plot_font_size)
hold on
plot(skyla_tt_daily.GLOB_forest,[skyla_tt_daily.GLOB_forest*sodankyla_albedoes(1),skyla_tt_daily.GLOB_forest*sodankyla_albedoes(2)],'LineWidth',3)
legend('Daily values',['Albedo ',num2str(sodankyla_albedoes(1))],['Albedo ',num2str(sodankyla_albedoes(2))],'Location','northwest')
cb(3) = colorbar;
% ylabel(cb,'Snow depth (cm)')
clim(cl_snow)

axes(subi4(4))
scatter(skyla_tt_daily.GLOB_peat(~skyla_tt_daily.bad_days_halssi),skyla_tt_daily.REFL_peat(~skyla_tt_daily.bad_days_halssi),[],skyla_tt_daily.SDepth_peat(~skyla_tt_daily.bad_days_halssi),'filled')
title('Halssiaapa')
set_plot_font(gca,plot_font_size)
hold on
plot(skyla_tt_daily.GLOB_peat,[skyla_tt_daily.GLOB_peat*halssiaapa_albedoes(1),skyla_tt_daily.GLOB_peat*halssiaapa_albedoes(2)],'LineWidth',3)
legend('Daily values',['Albedo ',num2str(halssiaapa_albedoes(1))],['Albedo ',num2str(halssiaapa_albedoes(2))],'Location','northwest')
cb(4) = colorbar;
ylabel(cb,'Snow depth (cm)')
% clim([0 120])


clim(cl_snow)
xlabel(subi4(4),'Global radiation (Wm^{-2})')





% ylim(subi4([1,3]),[0 600])
% ylim(subi4([2,4]),[0 600])


text(subi4(1),-0.3,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi4(2),-0.3,1.1,'b','fontsize',plot_font_size,'units','normalized')

text(subi4(3),-0.15,1.1,'c','fontsize',plot_font_size,'units','normalized')
text(subi4(4),-0.15,1.1,'d','fontsize',plot_font_size,'units','normalized')

% for ii = 1:length(subi4)
%     axes(subi4(ii))
%     caxis([0 100])
% end


% save_figure_OP(figi44,'../figs/refl_vs_glob_daily')





