function myshadedarea(x, y, dim, mycolors)
% x is a vector, y is a 3-d matrix where the third dimension is subjects
% dim (1 or 2) is the dimension that goes on the x-axis

plotsettings()

if nargin < 3 | isempty(dim); dim = 1; end
if nargin < 4; mycolors = colormap('lines'); end
if dim == 2; y = permute(y,[2 1 3]); end

nsubj = size(y,3);
ymean = squeeze(mean(y,3));
ysem  = squeeze(std(y,[],3))/sqrt(nsubj);
ymin  = ymean - ysem;
ymax  = ymean + ysem;

hold on;
for idx = 1:size(y,2)
    h = patch([x x(end:-1:1)], [ymin(:,idx); ymax(end:-1:1,idx)]', mycolors(idx,:));
    set(h,'LineWidth',2,'EdgeColor','None','FaceAlpha',0.3)
end
set(gca,'TickDir','out');