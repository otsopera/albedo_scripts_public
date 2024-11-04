function save_figure_OP(fig_obj,filename)

set(fig_obj,'Units','Inches');
pos = get(fig_obj,'Position');
set(fig_obj,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(fig_obj,filename,'-dpdf','-r0')
% print(fig_obj,filename,'-dmeta','-r0')
print(filename,'-dpng')
