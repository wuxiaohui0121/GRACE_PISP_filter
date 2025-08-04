function fuc_figure_global(grd,clb_val,filename)


[rows,cols]=size(grd);
if (rows==720 && cols==1440) 
    lon = 0.125:0.25:359.875;
    lat = 89.875:-0.25:-89.875;
elseif (rows==180 && cols==360)
    lon=0.5:359.5;
    lat=89.5:-1:-89.5;
elseif (rows==360 && cols==720)
    lon=0.25:0.5:359.75;
    lat=89.75:-0.5:-89.75;
end

c1 = 1; c3 = 0.3;
colors = [c3, 0, 0;       
          c1, c3, c3;      
          c1, c1, c3;       
          1, 1, 1;          
          c3, 1, 1;         
          c3, c3, 1;         
          0, 0, c3];         
n_bins = 250; 
x = linspace(0, 1, size(colors, 1)); 
xq = linspace(0, 1, n_bins);  
custom_cmap = interp1(x, colors, xq, 'linear');


% Hf_fig=figure;
[LON,LAT]=meshgrid(lon,lat);
set(gcf,'Units','centimeters');
set(gcf,'Position',[2 20 25 15]);
m_proj('Equidistant Cylindrical','lon',[0 360], 'lat',[-90 90],'sph','wgs84');
m_pcolor(LON,LAT,grd);
shading flat;
colormap(custom_cmap);
m_coast('linewidth',0.8,'color','k');
m_grid('box','on','tickdir','out','xtick',6,'ytick',7,'linewi',1,'xlabeldir','middle',...
    'TickLength',0.005,'FontSize',15);
h_cl=colorbar('FontSize',12);
clim([-clb_val clb_val]);
set(get(h_cl,'title'),'string','cm','FontSize',14);
title(filename,'fontsize',16,'fontname','consolas');

end