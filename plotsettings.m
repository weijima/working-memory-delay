set(0,'DefaultLineLineWidth',1.5)
set(0,'DefaultAxesFontSize',15)
set(0,'DefaultAxesTickDir', 'out')
set(0,'DefaultAxesTickLength',[0.02 0.05])

myorange = [254,204,0]/255;
myred = [255,0,100]/255;

Ncolors = [myorange;
    2/3 * myorange + 1/3 * myred;
    1/3 * myorange + 2/3 * myred;
    myred];

mygreen = [0,180,0]/255;
myblue = [0 0 1];
mypurple = [150, 0, 250]/255;

delaycolors = [mygreen;
    0.5 * mygreen + 0.5 * myblue;
    myblue;
    mypurple];

grid off;

% For binning error
nbins           = 9;
errorbinedges   = linspace(-pi, pi, nbins + 1);
errorbincenters = errorbinedges(1:end-1) + diff(errorbinedges(1:2))/2;

