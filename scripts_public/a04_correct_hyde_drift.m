clear variables

load('../vars/hyde_tt_cleaned.mat')
load('../vars/hyde_tt_daily_cleaned.mat')

%% hyde vs. siika global

plot_font_size = 36;

figi3 = figure();
set(figi3,'outerposition',[200 200 1920 1080]);

yl = [-50 400];
xl = [-50 400];


lm = fitlm(timetable2table(hyde_tt),'Glob_SII~Glob_HYY_tower','robust',0);
for ii = min(hyde_tt_daily.Time.Year):max(hyde_tt_daily.Time.Year)
    both_exist = ~isnan(hyde_tt_daily.Glob_HYY_tower) & ~isnan(hyde_tt_daily.Glob_SII);
    v = pca([hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.Time.Year == ii) hyde_tt_daily.Glob_SII(hyde_tt_daily.Time.Year == ii)]);

    beta(ii-min(hyde_tt_daily.Time.Year)+1) = v(2,1)/v(1,1);

    intercept(ii-min(hyde_tt_daily.Time.Year)+1) = mean(hyde_tt_daily.Glob_SII(hyde_tt_daily.Time.Year == ii&both_exist)) - mean(beta(ii-min(hyde_tt_daily.Time.Year)+1)*hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.Time.Year == ii&both_exist));

end

r_hyy = corrcoef(hyde_tt.Glob_HYY_tower,hyde_tt.Glob_SII,'rows','pairwise');
% scatter(hyde_tt.Glob_HYY_tower,hyde_tt.Glob_SII,15,'filled')
hold on 
scatter(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_SII,80,hyde_tt_daily.Time.Year,'filled','MarkerEdgeColor','k')
cb = colorbar;
ylabel(cb,'year')
plot(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_HYY_tower*beta(1) + intercept(1),'b','LineWidth',4)
plot(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_HYY_tower*beta(end) + intercept(end),'LineWidth',4)
% plot(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_SII,'.',hyde_tt.Glob_HYY_tower,lm.Fitted,'LineWidth',6,'MarkerSize',20)
xlabel('Global radiation, Hyytiälä (W m^{-2})');ylabel('Global radiation, Siikaneva (W m^{-2})')

legend('Daily means',['{\it y} = ',num2str(beta(1),3),'{\it x} + ',num2str(intercept(1),1)],['{\it y} = ',num2str(beta(end),3),'{\it x} - ',num2str(-intercept(end),1)],'Location','northwest')
% legend('30 min values','Daily medians',['y = ',num2str(lm.Coefficients.Estimate(2),3),' \times x + ',num2str(lm.Coefficients.Estimate(1),3)],'Location','northwest')
set_plot_font(gca,plot_font_size)
ylim(yl)
xlim(xl)
% save_figure_OP(gcf,'../figs/hyde_drift_correct')



%%

for ii = min(hyde_tt_daily.Time.Year):max(hyde_tt_daily.Time.Year)
    % hyde_tt_daily.Glob_HYY_tower_corrected(hyde_tt_daily.Time.Year == ii) = (hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.Time.Year == ii)+intercept(ii-min(hyde_tt_daily.Time.Year)+1)).*beta(ii-min(hyde_tt_daily.Time.Year)+1);

    hyde_tt_daily.Glob_HYY_tower_corrected(hyde_tt_daily.Time.Year == ii) = hyde_tt_daily.Glob_HYY_tower(hyde_tt_daily.Time.Year == ii).*beta(ii-min(hyde_tt_daily.Time.Year)+1);
    hyde_tt.Glob_HYY_tower_corrected(hyde_tt.Time.Year == ii) = hyde_tt.Glob_HYY_tower(hyde_tt.Time.Year == ii).*beta(ii-min(hyde_tt_daily.Time.Year)+1);

end


%%
figi4 = figure();

set(figi4,'outerposition',[200 200 1920 1080]);
scatter(hyde_tt_daily.Glob_HYY_tower_corrected,hyde_tt_daily.Glob_SII,80,hyde_tt_daily.Time.Year,'filled','MarkerEdgeColor','k')

r_hyy_corr = corrcoef(hyde_tt.Glob_HYY_tower_corrected,hyde_tt.Glob_SII,'rows','pairwise');

cb = colorbar;
ylabel(cb,'year')
% plot(hyde_tt_daily.Glob_HYY_tower,hyde_tt_daily.Glob_SII,'.',hyde_tt.Glob_HYY_tower,lm.Fitted,'LineWidth',6,'MarkerSize',20)
xlabel('Global radiation, Hyytiälä (W m^{-2})');ylabel('Global radiation, Siikaneva (W m^{-2})')

legend('Daily means after correction','Location','northwest')
% legend('30 min values','Daily medians',['y = ',num2str(lm.Coefficients.Estimate(2),3),' \times x + ',num2str(lm.Coefficients.Estimate(1),3)],'Location','northwest')
set_plot_font(gca,plot_font_size)
ylim(yl)
xlim(xl)
% save_figure_OP(gcf,'../figs/hyde_drift_after_correction')

%%

hyde_tt.albedo_hyde(~isnan(hyde_tt.albedo_hyde)) = hyde_tt.RGlob_HYY125(~isnan(hyde_tt.albedo_hyde))./hyde_tt.Glob_HYY_tower_corrected(~isnan(hyde_tt.albedo_hyde));
hyde_tt.net_SW_hyde(~isnan(hyde_tt.net_SW_hyde)) = hyde_tt.Glob_HYY_tower_corrected(~isnan(hyde_tt.net_SW_hyde))-hyde_tt.RGlob_HYY125(~isnan(hyde_tt.net_SW_hyde));
hyde_tt.SW_balance_difference(~isnan(hyde_tt.SW_balance_difference)) = hyde_tt.net_SW_hyde(~isnan(hyde_tt.SW_balance_difference))-hyde_tt.net_SW_siika(~isnan(hyde_tt.SW_balance_difference));
hyde_tt.mean_glob(~isnan(hyde_tt.mean_glob)) = mean([hyde_tt.Glob_HYY_tower_corrected(~isnan(hyde_tt.mean_glob)),hyde_tt.Glob_SII(~isnan(hyde_tt.mean_glob))],2,'omitnan');




hyde_tt_daily.albedo_hyde(~isnan(hyde_tt_daily.albedo_hyde)) = hyde_tt_daily.RGlob_HYY125(~isnan(hyde_tt_daily.albedo_hyde))./hyde_tt_daily.Glob_HYY_tower_corrected(~isnan(hyde_tt_daily.albedo_hyde));
hyde_tt_daily.net_SW_hyde(~isnan(hyde_tt_daily.net_SW_hyde)) = hyde_tt_daily.Glob_HYY_tower_corrected(~isnan(hyde_tt_daily.net_SW_hyde))-hyde_tt_daily.RGlob_HYY125(~isnan(hyde_tt_daily.net_SW_hyde));
hyde_tt_daily.SW_balance_difference(~isnan(hyde_tt_daily.SW_balance_difference)) = hyde_tt_daily.net_SW_hyde(~isnan(hyde_tt_daily.SW_balance_difference))-hyde_tt_daily.net_SW_siika(~isnan(hyde_tt_daily.SW_balance_difference));
hyde_tt_daily.mean_glob(~isnan(hyde_tt_daily.mean_glob)) = mean([hyde_tt_daily.Glob_HYY_tower_corrected(~isnan(hyde_tt_daily.mean_glob)),hyde_tt_daily.Glob_SII(~isnan(hyde_tt_daily.mean_glob))],2,'omitnan');

hyde_tt.Glob_HYY_tower_uncorrected = hyde_tt.Glob_HYY_tower;
hyde_tt.Glob_HYY_tower = hyde_tt.Glob_HYY_tower_corrected;
hyde_tt_daily.Glob_HYY_tower_uncorrected = hyde_tt_daily.Glob_HYY_tower;
hyde_tt_daily.Glob_HYY_tower = hyde_tt_daily.Glob_HYY_tower_corrected;
% 
% save('../vars/hyde_tt_cleaned_calibrated.mat','hyde_tt')
% save('../vars/hyde_tt_daily_cleaned_calibrated.mat','hyde_tt_daily')

% writetimetable(hyde_tt,'../data/hyde_tt_cleaned_calibrated.txt');
% writetimetable(hyde_tt_daily,'../data/hyde_tt_daily_cleaned_calibrated.txt');
