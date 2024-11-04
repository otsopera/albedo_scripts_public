% close all
clear variables


load('../vars/skyla_tt_cleaned.mat')
load('../vars/skyla_tt_daily_cleaned_gapfilled.mat')


load('../vars/hyde_tt_cleaned.mat')
load('../vars/hyde_tt_daily_cleaned_calibrated_gapfilled.mat')



plot_font_size = 36;



%%

hyde_tt_daily.albedo_difference = hyde_tt_daily.albedo_siika-hyde_tt_daily.albedo_hyde;
skyla_tt_daily.albedo_difference = skyla_tt_daily.albedo_halssi-skyla_tt_daily.albedo_skyla;

hyde_DOY_stats = grpstats(hyde_tt_daily,'DOY',{@(x)prctile(x,25),@(x)prctile(x,50),@(x)prctile(x,75),@(x)prctile(x,5),@(x)prctile(x,95)});
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





%% median years SW balances + individual years



figi113 = figure();
set(figi113,'outerposition',[200 200 1920 1080]);



plot_m = 1;
plot_n = 2;

yl_rad = [-650 1000];


subi1 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,1:floor(plot_n/2)));
subi2 = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:plot_m,ceil(plot_n/2)+1:plot_n));

axes(subi1)
for ii = max(max(skyla_tt_daily.Time.Year),max(hyde_tt_daily.Time.Year)):-1:min(min(skyla_tt_daily.Time.Year),min(hyde_tt_daily.Time.Year))
    axes(subi1)

    % plot non-cumulative as average, only once
    if ii == max(max(skyla_tt_daily.Time.Year),max(hyde_tt_daily.Time.Year))
        plot(hyde_week_stats.week,hyde_week_stats.Fun2_SW_balance_difference_gapfilled,'-.',skyla_week_stats.week,skyla_week_stats.Fun2_SW_balance_difference_gapfilled,'LineWidth',3)
        xlabel('Week')
        ylabel({'Average difference in the','net SW radiation between sites (W m^{-2})'})
        set_plot_font(gca,plot_font_size)
        xlim([0 52])
        
        axes(subi2)
        plot(hyde_DOY_stats.DOY,cumsum(hyde_DOY_stats.Fun2_SW_balance_difference_gapfilled)*3600*24*1e-9,'-.',skyla_DOY_stats.DOY,cumsum(fillmissing(skyla_DOY_stats.Fun2_SW_balance_difference_gapfilled*3600*24*1e-9,"linear")),'LineWidth',10)
        legend('Hyytiälä-Siikaneva','Halssikangas-Halssiaapa','Location','southeast')
        hold on

        
    end
    axes(subi2)
    plot(hyde_tt_daily.DOY(hyde_tt_daily.Time.Year == ii),cumsum(hyde_tt_daily.SW_balance_difference_gapfilled(hyde_tt_daily.Time.Year == ii))*3600*24*1e-9,'-.','Color',[0 0.4470 0.7410],'LineWidth',2)
    hold on
    plot(skyla_tt_daily.DOY(skyla_tt_daily.Time.Year == ii),cumsum(skyla_tt_daily.SW_balance_difference_gapfilled(skyla_tt_daily.Time.Year == ii))*3600*24*1e-9,'Color',[0.8500 0.3250 0.0980],'LineWidth',2)
    if ii == max(max(skyla_tt_daily.Time.Year),max(hyde_tt_daily.Time.Year))
        ldg = legend('Hyytiälä-Siikaneva','Halssikangas-Halssiaapa','Location','southeast','autoupdate','off');
    end
    xlabel('DOY')
    ylabel({'Cumulative difference in the','net SW radiation between sites (GJ m^{-2})'})
    set_plot_font(gca,plot_font_size)
    xlim([0 365])
end



text(subi1,-0.17,1.05,'a','fontsize',plot_font_size,'units','normalized')
text(subi2,-0.17,1.05,'b','fontsize',plot_font_size,'units','normalized')

% save_figure_OP(figi113,'../figs/individual_cumulative_SW_differences')


%%

% calculate average annual absorbed SW radiation for the sites

hyde_annual_absorbed_SW = sum(hyde_DOY_stats.Fun2_net_SW_hyde)*3600*24*1e-9;
siika_annual_absorbed_SW = sum(hyde_DOY_stats.Fun2_net_SW_siika)*3600*24*1e-9;
skyla_annual_absorbed_SW = sum(skyla_DOY_stats.Fun2_net_SW_skyla)*3600*24*1e-9;
halssi_annual_absorbed_SW = sum(skyla_DOY_stats.Fun2_net_SW_halssi,'omitnan')*3600*24*1e-9;


hyde_annual_absorbed_SW_diff = sum(hyde_DOY_stats.Fun2_SW_balance_difference)*3600*24*1e-9;
skyla_annual_absorbed_SW_diff = sum(skyla_DOY_stats.Fun2_SW_balance_difference,'omitnan')*3600*24*1e-9;






%% all average albedoes in onw

maxweek_skyla_alb = 50.5;
minweek_skyla_alb = 0.5;


week_patch_skyla_alb = [skyla_week_stats.week(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];

halssi_week_Qpatch_alb = [skyla_week_stats.Fun1_albedo_halssi(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.Fun3_albedo_halssi(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];
halssi_week_prcPatch_alb = [skyla_week_stats.Fun4_albedo_halssi(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.Fun5_albedo_halssi(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];
   

skyla_week_Qpatch_alb = [skyla_week_stats.Fun1_albedo_skyla(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.Fun3_albedo_skyla(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];
skyla_week_prcPatch_alb = [skyla_week_stats.Fun4_albedo_skyla(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.Fun5_albedo_skyla(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];
   
skyla_week_Qpatch_alb_diff = [skyla_week_stats.Fun1_albedo_difference(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.Fun3_albedo_difference(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];
skyla_week_prcPatch_alb_diff = [skyla_week_stats.Fun4_albedo_difference(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb);flipud(skyla_week_stats.Fun5_albedo_difference(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb))];
   


maxweek_hyde = 53.5;
minweek_hyde = -0.5;


week_patch_hyde = [hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];

siika_week_Qpatch_alb = [hyde_week_stats.Fun1_albedo_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun3_albedo_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
siika_week_prcPatch_alb = [hyde_week_stats.Fun4_albedo_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun5_albedo_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
   

hyde_week_Qpatch_alb = [hyde_week_stats.Fun1_albedo_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun3_albedo_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
hyde_week_prcPatch_alb = [hyde_week_stats.Fun4_albedo_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun5_albedo_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
   
hyde_week_Qpatch_alb_diff = [hyde_week_stats.Fun1_albedo_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun3_albedo_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
hyde_week_prcPatch_alb_diff = [hyde_week_stats.Fun4_albedo_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun5_albedo_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
   
      
xl_week = [1 53];
      




figi1 = figure();
set(figi1,'outerposition',[200 200 1920 1080]);

plot_m = 13;
plot_n = 4;

yl_rad = [-650 1000];


subi_alb(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
subi_alb(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
subi_alb(5) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,11:13,1:2));

subi_alb(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));
subi_alb(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));
subi_alb(6) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,11:13,3:4));






axes(subi_alb(1))
plot(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),hyde_week_stats.Fun2_albedo_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),'LineWidth',5)


hold on

patch(week_patch_hyde,hyde_week_Qpatch_alb,'blue','FaceAlpha',.3)
patch(week_patch_hyde,hyde_week_prcPatch_alb,'blue','FaceAlpha',.3)

title('Hyytiälä')
xticklabels([])
ylabel('Albedo')

set_plot_font(gca,36)

axes(subi_alb(2))

plot(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),hyde_week_stats.Fun2_albedo_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),'LineWidth',5)


hold on

patch(week_patch_hyde,siika_week_Qpatch_alb,'blue','FaceAlpha',.3)
patch(week_patch_hyde,siika_week_prcPatch_alb,'blue','FaceAlpha',.3)

title('Siikaneva')
xticklabels([])

ylabel('Albedo')

set_plot_font(gca,36)



axes(subi_alb(5))
plot(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),hyde_week_stats.Fun2_albedo_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),'LineWidth',5)
xlabel('Week')

hold on

patch(week_patch_hyde,hyde_week_Qpatch_alb_diff,'blue','FaceAlpha',.3)
patch(week_patch_hyde,hyde_week_prcPatch_alb_diff,'blue','FaceAlpha',.3)


ylabel('Difference')
title('Difference')
set_plot_font(gca,36)








axes(subi_alb(3))
plot(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb),skyla_week_stats.Fun2_albedo_skyla(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb),'LineWidth',5)


hold on

patch(week_patch_skyla_alb,skyla_week_Qpatch_alb,'blue','FaceAlpha',.3)
patch(week_patch_skyla_alb,skyla_week_prcPatch_alb,'blue','FaceAlpha',.3)

title('Halssikangas')
xticklabels([])
[~, hobj, ~, ~]  = legend('Median','Interquartile range','5^{th} to 95^{th} percentile','FontSize',36,'location','north');

hl = findobj(hobj,'type','patch');
set(hl(2),'FaceAlpha',0.6);

set_plot_font(gca,36)

axes(subi_alb(4))

plot(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb),skyla_week_stats.Fun2_albedo_halssi(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb),'LineWidth',5)


hold on

patch(week_patch_skyla_alb,halssi_week_Qpatch_alb,'blue','FaceAlpha',.3)
patch(week_patch_skyla_alb,halssi_week_prcPatch_alb,'blue','FaceAlpha',.3)

title('Halssiaapa')
xticklabels([])

set_plot_font(gca,36)



axes(subi_alb(6))

plot(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb),skyla_week_stats.Fun2_albedo_difference(skyla_week_stats.week>minweek_skyla_alb & skyla_week_stats.week<maxweek_skyla_alb),'LineWidth',5)


hold on

patch(week_patch_skyla_alb,skyla_week_Qpatch_alb_diff,'blue','FaceAlpha',.3)
patch(week_patch_skyla_alb,skyla_week_prcPatch_alb_diff,'blue','FaceAlpha',.3)

title('Difference')
xlabel('Week')

set_plot_font(gca,36)


xlim(subi_alb,xl_week)
ylim(subi_alb,[0 1])
ylim(subi_alb(5:6),[-0.2 1])



text(subi_alb(1),-0.17,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi_alb(2),-0.17,1.1,'b','fontsize',plot_font_size,'units','normalized')
text(subi_alb(5),-0.17,1.1,'c','fontsize',plot_font_size,'units','normalized')

text(subi_alb(3),-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')
text(subi_alb(4),-0.1,1.1,'e','fontsize',plot_font_size,'units','normalized')
text(subi_alb(6),-0.1,1.1,'f','fontsize',plot_font_size,'units','normalized')

% save_figure_OP(figi1,'../figs/all_average_albedo')

%% all SW balances in one

maxweek_skyla = 53.5;
minweek_skyla = 0.5;


week_patch_skyla_netSW = [skyla_week_stats.week(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];

halssi_week_Qpatch_netSW = [skyla_week_stats.Fun1_net_SW_halssi(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.Fun3_net_SW_halssi(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];
halssi_week_prcPatch_netSW = [skyla_week_stats.Fun4_net_SW_halssi(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.Fun5_net_SW_halssi(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];
   

skyla_week_Qpatch_netSW = [skyla_week_stats.Fun1_net_SW_skyla(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.Fun3_net_SW_skyla(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];
skyla_week_prcPatch_netSW = [skyla_week_stats.Fun4_net_SW_skyla(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.Fun5_net_SW_skyla(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];
   
 


maxweek_hyde = 53.5;
minweek_hyde = -0.5;


week_patch_hyde = [hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];

siika_week_Qpatch_netSW = [hyde_week_stats.Fun1_net_SW_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun3_net_SW_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
siika_week_prcPatch_netSW = [hyde_week_stats.Fun4_net_SW_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun5_net_SW_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
   

hyde_week_Qpatch_netSW = [hyde_week_stats.Fun1_net_SW_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun3_net_SW_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
hyde_week_prcPatch_netSW = [hyde_week_stats.Fun4_net_SW_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun5_net_SW_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
   
      



north_week_Qpatch_netSW = [skyla_week_stats.Fun1_SW_balance_difference(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.Fun3_SW_balance_difference(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];
north_week_prcPatch_netSW = [skyla_week_stats.Fun4_SW_balance_difference(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla);flipud(skyla_week_stats.Fun5_SW_balance_difference(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla))];
   


south_week_Qpatch_netSW = [hyde_week_stats.Fun1_SW_balance_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun3_SW_balance_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
south_week_prcPatch_netSW = [hyde_week_stats.Fun4_SW_balance_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde);flipud(hyde_week_stats.Fun5_SW_balance_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde))];
   
      





xl_week = [1 53];
      




figi3 = figure();
set(figi3,'outerposition',[200 200 1920 1080]);

plot_m = 14;
plot_n = 4;

yl_SW = [0 360];
yl_SW_diff = [-30 140];


subi(1) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,1:2));
subi(2) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,1:2));
subi(5) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,11:14,1:2));

subi(3) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,1:4,3:4));
subi(4) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,6:9,3:4));
subi(6) = subplot(plot_m,plot_n,m_n_grid_coordinates_to_lin_row_idx(plot_m,plot_n,11:14,3:4));




axes(subi(2))

plot(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),hyde_week_stats.Fun2_net_SW_siika(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),'LineWidth',5)


hold on

patch(week_patch_hyde,siika_week_Qpatch_netSW,'blue','FaceAlpha',.3)
patch(week_patch_hyde,siika_week_prcPatch_netSW,'blue','FaceAlpha',.3)

title('Siikaneva')

set_plot_font(gca,36)





axes(subi(1))
plot(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),hyde_week_stats.Fun2_net_SW_hyde(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),'LineWidth',5)


hold on

patch(week_patch_hyde,hyde_week_Qpatch_netSW,'blue','FaceAlpha',.3)
patch(week_patch_hyde,hyde_week_prcPatch_netSW,'blue','FaceAlpha',.3)

title('Hyytiälä')

set_plot_font(gca,36)





axes(subi(4))

plot(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla),skyla_week_stats.Fun2_net_SW_halssi(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla),'LineWidth',5)


hold on

patch(week_patch_skyla_netSW,halssi_week_Qpatch_netSW,'blue','FaceAlpha',.3)
patch(week_patch_skyla_netSW,halssi_week_prcPatch_netSW,'blue','FaceAlpha',.3)

title('Halssiaapa')

set_plot_font(gca,36)



axes(subi(3))
plot(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla),skyla_week_stats.Fun2_net_SW_skyla(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla),'LineWidth',5)


hold on

patch(week_patch_skyla_netSW,skyla_week_Qpatch_netSW,'blue','FaceAlpha',.3)
patch(week_patch_skyla_netSW,skyla_week_prcPatch_netSW,'blue','FaceAlpha',.3)

title('Halssikangas')

set_plot_font(gca,36)



axes(subi(5))
plot(hyde_week_stats.week(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),hyde_week_stats.Fun2_SW_balance_difference(hyde_week_stats.week>minweek_hyde & hyde_week_stats.week<maxweek_hyde),'LineWidth',5)


hold on

patch(week_patch_hyde,south_week_Qpatch_netSW,'blue','FaceAlpha',.3)
patch(week_patch_hyde,south_week_prcPatch_netSW,'blue','FaceAlpha',.3)

title('Difference')
ylabel('Difference (W m^{-2})')
set_plot_font(gca,36)


xlabel('Week')

axes(subi(6))
plot(skyla_week_stats.week(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla),skyla_week_stats.Fun2_SW_balance_difference(skyla_week_stats.week>minweek_skyla & skyla_week_stats.week<maxweek_skyla),'LineWidth',5)


hold on

patch(week_patch_skyla_netSW,north_week_Qpatch_netSW,'blue','FaceAlpha',.3)
patch(week_patch_skyla_netSW,north_week_prcPatch_netSW,'blue','FaceAlpha',.3)

title('Difference')

set_plot_font(gca,36)
xlabel('Week')


for ii = 1:4
    subi(ii).XTickLabel = [];
end

xlim(subi,xl_week)
ylim(subi(1:4),yl_SW)
ylim(subi(5:6),yl_SW_diff)




[~, hobj, ~, ~]  = legend(subi(6),'Median','Interquartile range','5^{th} to 95^{th} percentile','FontSize',36,'location','northeast');

hl = findobj(hobj,'type','patch');
set(hl(2),'FaceAlpha',0.6);


text(subi(2),-0.25,-0.13,'Absorbed shortwave radiation (Wm^{-2})','fontsize',plot_font_size,'units','normalized','Rotation',90)


text(subi(1),-0.21,1.1,'a','fontsize',plot_font_size,'units','normalized')
text(subi(2),-0.21,1.1,'b','fontsize',plot_font_size,'units','normalized')
text(subi(5),-0.21,1.1,'c','fontsize',plot_font_size,'units','normalized')

text(subi(3),-0.1,1.1,'d','fontsize',plot_font_size,'units','normalized')
text(subi(4),-0.1,1.1,'e','fontsize',plot_font_size,'units','normalized')
text(subi(6),-0.1,1.1,'f','fontsize',plot_font_size,'units','normalized')

% save_figure_OP(figi3,'../figs/all_average_net_SW')



