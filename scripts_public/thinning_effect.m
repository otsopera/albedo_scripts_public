% close all
clear variables


load('../vars/skyla_tt_cleaned.mat')
load('../vars/skyla_tt_daily_cleaned.mat')


load('../vars/hyde_tt_cleaned_calibrated.mat')
load('../vars/hyde_tt_daily_cleaned_calibrated.mat')



plot_font_size = 36;
%%

hyde_tt_daily.prethin = hyde_tt_daily.Time<datetime(2020,2,1,'TimeZone','+02:00');
hyde_tt_daily.postthin = hyde_tt_daily.Time>datetime(2020,3,31,'TimeZone','+02:00');

hyde_tt.prethin = hyde_tt.Time<datetime(2020,2,1,'TimeZone','+02:00');
hyde_tt.postthin = hyde_tt.Time>datetime(2020,3,31,'TimeZone','+02:00');



%%
hyde_tt_daily.deepsnow = hyde_tt_daily.SnowDepth_HYY > 10;
thinning_lm = fitlm(timetable2table(hyde_tt_daily),'RGlob_HYY125~Glob_HYY_tower+Glob_HYY_tower:postthin+Glob_HYY_tower:deepsnow+Glob_HYY_tower:deepsnow:postthin-1');



figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);

% the plain coefficient for Glob
albedo_prethin_nosnow = thinning_lm.Coefficients.Estimate(1);
% The coefficient for glob plus postthing interaction. Double check the
% order of the coeffs, seems that matlab sometimes orders them differently
albedo_postthin_nosnow = sum(thinning_lm.Coefficients.Estimate([1 3]));
albedo_prethin_snow = sum(thinning_lm.Coefficients.Estimate([1:2]));
albedo_postthin_snow = sum(thinning_lm.Coefficients.Estimate(1:4));



plot_m = 1;
plot_n = 2;

yl_rad = [-60 200];
clim_snow = [0 90];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));

axes(subi(1))
scatter(hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.prethin&~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.RGlob_HYY125(hyde_tt_daily.prethin&~hyde_tt_daily.bad_days_hyde),150,hyde_tt_daily.SnowDepth_HYY(hyde_tt_daily.prethin&~hyde_tt_daily.bad_days_hyde),'filled','MarkerEdgeColor',[0 0 0]);

hold on 
plot([0 350],[0 350*albedo_prethin_nosnow],[0 200],[0 200*albedo_prethin_snow],'LineWidth',5)

% colormap('turbo');
title('Before thinning')
set_plot_font(gca,plot_font_size)  
ylabel('Reflected radiation (Wm^{-2})')
xlabel('Global radiation (Wm^{-2})')
% ylabel(cb,'Snow depth in Hyytiälä (cm)')
clim([0 90])

legend('Daily values',['Albedo ',num2str(albedo_prethin_nosnow,3)],['Albedo ',num2str(albedo_prethin_snow,3)],'location','southeast')


axes(subi(2))
scatter(hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.postthin&~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.RGlob_HYY125(hyde_tt_daily.postthin&~hyde_tt_daily.bad_days_hyde),150,hyde_tt_daily.SnowDepth_HYY(hyde_tt_daily.postthin&~hyde_tt_daily.bad_days_hyde),'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
% colormap('turbo');
title('After thinning')
set_plot_font(gca,plot_font_size)
hold on 
plot([0 350],[0 350*albedo_postthin_nosnow],[0 200],[0 200*albedo_postthin_snow],'LineWidth',5)


legend('Daily values',['Albedo ',num2str(albedo_postthin_nosnow,3)],['Albedo ',num2str(albedo_postthin_snow,3)],'location','southeast')

ylabel('Reflected radiation (Wm^{-2})')
xlabel('Global radiation (Wm^{-2})')
ylabel(cb,'Snow depth in Hyytiälä (cm)')
clim([0 90])

text(subi(1),-0.17,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi(2),-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')


% save_figure_OP(figi31,'../figs/hyde_thinning_effect_LM')

%%



figi31 = figure();
set(figi31,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_rad = [-60 200];
clim_snow = [0 90];

subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));

axes(subi(1))
scatter(hyde_tt_daily.SnowDepth_HYY(hyde_tt_daily.prethin&~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.albedo_hyde(hyde_tt_daily.prethin&~hyde_tt_daily.bad_days_hyde),150,hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.prethin&~hyde_tt_daily.bad_days_hyde),'filled','MarkerEdgeColor',[0 0 0]);

% colormap('turbo');
title('Before thinning')
set_plot_font(gca,plot_font_size)  
% ylabel('Reflected radiation (Wm^{-2})')
% xlabel('Global radiation (Wm^{-2})')

ylabel('Albedo')
% ylabel(cb,'Global radiation (Wm^{-2})')
xlabel('Snow depth in Hyytiälä (cm)')
% ylabel(cb,'Snow depth in Hyytiälä (cm)')
clim([0 250])
ylim([0 0.8])
axes(subi(2))
scatter(hyde_tt_daily.SnowDepth_HYY(hyde_tt_daily.postthin&~hyde_tt_daily.bad_days_hyde),hyde_tt_daily.albedo_hyde(hyde_tt_daily.postthin&~hyde_tt_daily.bad_days_hyde),150,hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.postthin&~hyde_tt_daily.bad_days_hyde),'filled','MarkerEdgeColor',[0 0 0]);
cb = colorbar;
% colormap('turbo');
title('After thinning')
set_plot_font(gca,plot_font_size)

% ylabel('Albedo')
ylabel(cb,'Global radiation (Wm^{-2})')
xlabel('Snow depth in Hyytiälä (cm)')
clim([0 250])
ylim([0 0.8])
% save_figure_OP(figi31,'../figs/hyde_thinning_effect_2')







