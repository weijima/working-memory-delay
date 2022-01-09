function myerrorbar(x, y, dim, linestyle, mycolors)
% x is a vector, y is a 2d or 3d matrix where the third dimension is subjects
% dim (1 or 2) is the dimension that goes on the x-axis

plotsettings()
if nargin < 3 || isempty(dim); dim = 1; end
if nargin < 4 || isempty(linestyle); linestyle = '-'; end
if nargin < 5 || isempty(mycolors); mycolors = colormap('lines'); end 
if dim == 2; y = permute(y,[2 1 3]); end

if ndims(y) == 2
    nsubj = size(y,2);
    ymean = squeeze(mean(y,2));
    ysem  = squeeze(std(y,[],2))/sqrt(nsubj);
    
    h = errorbar(x, ymean, ysem, linestyle);
    set(h,'Color','k','LineWidth',1.5)
else
    nsubj = size(y,3);
    ymean = squeeze(mean(y,3));
    ysem  = squeeze(std(y,[],3))/sqrt(nsubj);
    
    hold on;
    for idx = 1:size(y,2)
        h = errorbar(x, ymean(:,idx), ysem(:,idx), linestyle);
        set(h,'Color',mycolors(idx,:),'LineWidth',1.5)
    end
end
plotsettings()