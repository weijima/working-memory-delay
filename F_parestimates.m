%% Plot parameter estimates
clear; close all; warning off; addpath(genpath('./')); plotsettings()

experiment = 1;

switch experiment
    case 1
        load results/results_exp1_2017-01-30
    case 2
        load results/results_exp2_2017-08-28
end

nsubj      = length(alldata)
delayvec   = alldata{1}.delayvec;
Nvec   = alldata{1}.Nvec;
conditions = alldata{1}.conditions;
ndelays    = alldata{1}.ndelays;
nN         = alldata{1}.nN;

% Repeated-measures ANOVA
factordesign = combvec(delayvec', Nvec', 1:nsubj)';
factor_delay = factordesign(:,1);
factor_N     = factordesign(:,2);
factor_subj  = factordesign(:,3);

plotmodelvec = [1 3 7 11];

figure('Position', [100, 100, 1000, 300])
for plotmodelidx = 1:length(plotmodelvec)
    modelidx = plotmodelvec(plotmodelidx);
    for subjidx = 1:nsubj
        par_est = modelresults{modelidx,subjidx}.par_est;
        nJbar = models{modelidx}.nJbar;
        
        for delayidx = 1:ndelays
            for Nidx = 1:nN
                condidx = find(conditions(1,:) == delayidx & conditions(2,:) == Nidx);
                logJbar(delayidx, Nidx,subjidx) = par_est(condidx);
            end
        end
    end
    subplot(1,4, plotmodelidx, 'pos', [0.07 + (plotmodelidx-1) * 0.22 0.25  0.17 0.6]); hold on;
    myerrorbar(delayvec, logJbar,[],[],Ncolors)
    set(gca,'xtick', delayvec);
    xlabel('Delay duration (s)');
    if plotmodelidx == 1
        ylabel('Estimated log (mean) precision');
    end
    xlim([0.5 6.5])
    
    anova_logJbar = rm_anova2(logJbar(:), factor_subj, factor_delay, factor_N, {'delay', 'set size'})
end
plotsettings()
[L, objh] = legend(strcat({'{\it N} = '},num2str(Nvec)));
set(L,'Position', [0.92 0.35 0.07 0.3])
set(findobj(objh,'type','line'), 'LineWidth',2)

ax = axes('position',[0,0,1,1],'visible','off');
text(0.01,0.95,'A','FontSize',20);
text(0.23,0.95,'B','FontSize',20);
text(0.45,0.95,'C','FontSize',20);
text(0.67,0.95,'D','FontSize',20);

printfigure(strcat('results/figures/exp', num2str(experiment), '_estimates'))
