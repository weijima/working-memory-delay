function printfigure(name)
set(gcf,'Units','Inches'); 
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,strcat(name),'-dpdf','-r0')
