clear; close all; addpath(genpath('./')); plotsettings()

experiment = 1;
filename = strcat('alldata_exp', num2str(experiment));
load(filename)
nsubj = length(alldata);

for subjidx = 1:nsubj
    delayvec    = alldata{subjidx}.delayvec;
    Nvec        = alldata{subjidx}.Nvec;
    alldelayidx = alldata{subjidx}.alldelayidx;
    allNidx     = alldata{subjidx}.allNidx;
    allerror    = alldata{subjidx}.allerror;
    
    for delayidx = 1:length(delayvec)
        for Nidx = 1:length(Nvec)
            idx = find(alldelayidx == delayidx & allNidx == Nidx);
            
            error = allerror(idx);
            error_hist(delayidx, Nidx,:,subjidx) = hist(error, errorbincenters)/length(idx);
            
            abserror(delayidx, Nidx) = 90/pi * mean(abs(error));
            cmean(delayidx, Nidx)    = 90/pi * circ_mean(error);
            csd(delayidx, Nidx)      = 90/pi * circ_std(error);
            range(delayidx, Nidx)    = 90/pi * iqr(error);
            cv(delayidx, Nidx)       = circ_var(error);
            skewness(delayidx, Nidx) = circ_skewness(error);
            kurtosis(delayidx, Nidx) = circ_kurtosis(error);
            
        end
    end
    allabserror(:,:,subjidx) = abserror;
    allcmean(:,:,subjidx)    = cmean;
    allcsd(:,:,subjidx)      = csd;
    allrange(:,:,subjidx)    = range;
    allcv(:,:,subjidx)       = cv;
    allskewness(:,:,subjidx) = skewness;
    allkurtosis(:,:,subjidx) = kurtosis;
    
    % Multiple linear regression (with centering of independent variables
    factordesign = combvec(delayvec', Nvec')';
    factor_delay = factordesign(:,1) - mean(alldata{1}.delayvec);
    factor_N     = factordesign(:,2) - mean(alldata{1}.Nvec);
    ncond        = size(factordesign,1);
    
    [beta_csd(:,subjidx),   beta_csd_ci(:,:,subjidx)]   = regress(csd(:),   [ones(ncond,1), factor_N, factor_delay, factor_delay .* factor_N]);
    [beta_range(:,subjidx), beta_range_ci(:,:,subjidx)] = regress(range(:), [ones(ncond,1), factor_N, factor_delay, factor_delay .* factor_N]);
    [beta_cv(:,subjidx),~, beta_cv_stats]               = glmfit([factor_delay, factor_N, factor_delay .* factor_N], cv(:));
    beta_cv_p(:,subjidx) = beta_cv_stats.p;
    
end

beta_csd
beta_csd_ci
beta_range
beta_range_ci
beta_cv
beta_cv_p


%% Repeated-measures ANOVA
factordesign = combvec(delayvec', Nvec', 1:nsubj)';
factor_delay = factordesign(:,1);
factor_N     = factordesign(:,2);
factor_subj  = factordesign(:,3);

anova_abserror = rm_anova2(allabserror(:), factor_subj, factor_delay, factor_N, {'delay', 'set size'})
anova_cmean    = rm_anova2(allcmean(:),    factor_subj, factor_delay, factor_N, {'delay', 'set size'})
anova_csd      = rm_anova2(allcsd(:),      factor_subj, factor_delay, factor_N, {'delay', 'set size'})
anova_range    = rm_anova2(allrange(:),    factor_subj, factor_delay, factor_N, {'delay', 'set size'})
anova_cv       = rm_anova2(allcv(:),       factor_subj, factor_delay, factor_N, {'delay', 'set size'})
anova_skewness = rm_anova2(allskewness(:), factor_subj, factor_delay, factor_N, {'delay', 'set size'})
anova_kurtosis = rm_anova2(allkurtosis(:), factor_subj, factor_delay, factor_N, {'delay', 'set size'})

%% Plotting

ndelays         = alldata{1}.ndelays;
nN              = alldata{1}.nN;

% Individual subjects
figdims = [100, 100, 1100, 700 * nsubj/5];
yspacing1 = 0.14 /(nsubj/5);
yspacing2 = 0.17 /(nsubj/5);

figure('Position', figdims)
for subjidx = 1:nsubj
    for Nidx = 1:nN
        subplot(nsubj,nN+1,(subjidx-1)*(nN+1)+Nidx,'pos', [0.1+(Nidx-1)*0.155,  0.1+(nsubj-subjidx)*yspacing2,  0.125, yspacing1]);
        hold on;
        for delayidx = 1:ndelays
            plot(errorbincenters, squeeze(error_hist(delayidx,Nidx,:,subjidx)),'Color',delaycolors(delayidx,:));
        end
        axis([-pi, pi, 0, 1]); set(gca,'ytick',0:0.2:1)
        
        if Nidx == 1
            ylabel('Proportion')
            set(gca,'yticklabel',[0:0.2:1]);
            L = legend(strcat({'delay = '},num2str(delayvec), [' s']));
            set(L,'Position',[0.73 .54 .05 .15],'FontSize',16)
        else
            set(gca,'yticklabel',[]);
        end
        if subjidx == 1 & Nidx <=nN
            title(['{\it N} =',' ',num2str(Nvec(Nidx))],'Color',Ncolors(Nidx,:))
        end
        if subjidx == nsubj
            set(gca,'xtick', [-pi:pi/3:pi],'xticklabel',[-90:30:90]);
            xlabel('Estimation error (\circ)')
        else
            set(gca,'xticklabel', [])
        end
        grid on;
        plotsettings()
    end
    subplot(nsubj,nN+1,subjidx*(nN+1),'pos', [0.23+nN * 0.155 0.1 + (nsubj-subjidx) * yspacing2  0.125 yspacing1]);
    hold on;
    for Nidx = 1:length(Nvec)
        plot(delayvec, allcsd(:,Nidx,subjidx),'o-','Color',Ncolors(Nidx,:))
    end
    grid on;
    L2 = legend(strcat({'{\it N} = '},num2str(Nvec)));
    set(L2,'Position',[0.74 .34 .07 .15],'FontSize',16)
    set(gca, 'xtick', delayvec,'xlim', [0.5 6.5],'ylim',[0 60], 'ytick',0:20:60);
    if subjidx == nsubj
        set(gca,'xticklabel', delayvec);     xlabel('Delay duration (s)');
    else
        set(gca,'xticklabel', []);
    end
    plotsettings()
    
end

ax = axes('position',[0,0,1,1],'visible','off');
text(0.01,0.95,'A','FontSize',20);
text(0.78,0.95,'B','FontSize',20);
text(0.8,0.95,'Circular standard deviation (\circ)','FontSize',16);

ax = axes('position',[0,0,1,1],'visible','off');
for subjidx = 1:nsubj
    text(0.02, 0.1 + yspacing1/2 + (nsubj-subjidx) * yspacing2,strcat('S', num2str(subjidx)),'FontSize',20);
end

printfigure(strcat('results/figures/exp', num2str(experiment), '_individuals'))

% Standard deviation, interquartile range, variance
figure('Position', [100, 100, 1000, 300])
h1 = subplot(1,4,1); set(h1, 'pos', [0.07 0.25  0.15 0.6]);
myerrorbar(delayvec, allabserror,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Mean absolute error (\circ)');
h2 = subplot(1,4,2); set(h2, 'pos', [0.29 0.25  0.15 0.6]);
myerrorbar(delayvec, allcsd,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Circular standard deviation (\circ)');
h3 = subplot(1,4,3); set(h3, 'pos', [0.51 0.25  0.15 0.6]);
myerrorbar(delayvec, allrange,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Interquartile range (\circ)');
h4 = subplot(1,4,4); set(h4, 'pos', [0.73 0.25  0.15 0.6]);
myerrorbar(delayvec, allcv,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Circular variance'); set(gca,'ytick',0:0.2:1)
set([h1 h2 h3 h4], 'xtick', delayvec,'xlim', [0.5 6.5])
set([h1 h2 h3], 'ylim',[0 60], 'ytick',0:10:60); set(h4, 'ylim',[0 1])

[L, objh] = legend(strcat({'{\it N} = '},num2str(Nvec)));
set(L,'Position', [0.89 0.35 0.075 0.3])
set(findobj(objh,'type','line'), 'LineWidth',2)
plotsettings()

ax = axes('position',[0,0,1,1],'visible','off');
text(0.01,0.95,'A','FontSize',20);
text(0.23,0.95,'B','FontSize',20);
text(0.45,0.95,'C','FontSize',20);
text(0.67,0.95,'D','FontSize',20);

printfigure(strcat('results/figures/exp', num2str(experiment), '_dispersion'))

% Mean, skewness, and kurtosis
figure('Position', [100, 100, 750, 300])
h1 = subplot(1,3,1); set(h1, 'pos', [0.09 0.25  0.2 0.6]);
myerrorbar(delayvec, allcmean,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Circular mean (\circ)'); ylim([-60 60])
h2= subplot(1,3,2); set(h2, 'pos', [0.38 0.25  0.2 0.6]);
myerrorbar(delayvec, allskewness,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Circular skewness'); ylim([-1 1]); set(gca,'ytick',-1:0.5:1)
h3 = subplot(1,3,3); set(h3, 'pos', [0.67 0.25  0.2 0.6]);
myerrorbar(delayvec, allkurtosis,[],[], Ncolors); xlabel('Delay duration (s)'); ylabel('Circular kurtosis'); ylim([0 1]); set(gca,'ytick',0:0.2:1)
set([h1 h2 h3], 'xtick',delayvec, 'xlim', [0.5 6.5])

[L, objh] = legend(strcat({'{\it N} = '},num2str(Nvec)));
set(L,'Position',[0.89 .35 .1 .3])
set(findobj(objh,'type','line'), 'LineWidth',2)
plotsettings()

ax = axes('position',[0,0,1,1],'visible','off');
text(0.01,0.95,'A','FontSize',20);
text(0.30,0.95,'B','FontSize',20);
text(0.59,0.95,'C','FontSize',20);

printfigure(strcat('results/figures/exp', num2str(experiment), '_kurtosis'))


