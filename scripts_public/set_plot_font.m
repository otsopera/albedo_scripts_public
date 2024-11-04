function set_plot_font(axes,size_of_font)


title_handle = get(axes,'title');
xlabel_handle = get(axes,'xlabel');
ylabel_handle = get(axes,'ylabel');
zlabel_handle = get(axes,'zlabel');
legend_handle = get(axes,'legend');

set(axes,'FontSize',size_of_font);
set(xlabel_handle,'FontSize',size_of_font);
set(ylabel_handle,'FontSize',size_of_font);
set(zlabel_handle,'FontSize',size_of_font);
set(legend_handle,'FontSize',size_of_font);
set(title_handle,'FontSize',size_of_font);