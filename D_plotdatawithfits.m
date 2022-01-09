clear; close all; warning off; addpath(genpath('./')); plotsettings()

experiment = 1;
switch experiment
    case 1
        load results/results_exp1_2017-01-30
    case 2
        load results/results_exp2_2017-08-28
end

nsubj           = length(alldata);
delayvec        = alldata{1}.delayvec;
Nvec            = alldata{1}.Nvec;
ndelays         = alldata{1}.ndelays;
nN              = alldata{1}.nN;
conditions      = alldata{1}.conditions;

plotmodel = 0

if plotmodel > 0
    errorvec        = models{plotmodel}.errorvec;
    modelpredmatrix = NaN(ndelays, nN, length(errorvec), nsubj);
end

error_hist      = NaN(ndelays, nN, nbins, nsubj);

for subjidx = 1:nsubj
    alldelayidx = alldata{subjidx}.alldelayidx;
    allNidx     = alldata{subjidx}.allNidx;
    allerror    = alldata{subjidx}.allerror;
    
    for delayidx = 1:ndelays
        for Nidx = 1:nN
            idx = find(alldelayidx == delayidx & allNidx == Nidx);
            error_hist(delayidx, Nidx,:,subjidx) = hist(allerror(idx), errorbincenters)/length(idx);
            if plotmodel > 0
                condidx = find(conditions(1,:) == delayidx & conditions(2,:) == Nidx);
                modelpredmatrix(delayidx, Nidx,:,subjidx) = modelresults{plotmodel,subjidx}.modelpred(condidx,:);
            end
        end
    end
end

if plotmodel > 0
    modelpredmatrix = modelpredmatrix * diff(errorbincenters(1:2)); % normalization
end

figure('Position', [100, 100, 1200, 500])
for Nidx = 1:nN % Each plot corresponds to one set size
    subplot(2,4, 4+Nidx, 'pos', [0.07 + (Nidx-1) * 0.2 0.15  0.175 0.3]); hold on;
    
    for delayidx = 1:ndelays
        if plotmodel == 0 % No model
            myerrorbar(errorbincenters, squeeze(error_hist(:,Nidx,:,:)),2,[],Ncolors);
        else
            myshadedarea(errorvec, squeeze(modelpredmatrix(:,Nidx,:,:)),2,Ncolors);
            myerrorbar(errorbincenters, squeeze(error_hist(:,Nidx,:,:)),2,'.',Ncolors);
        end
    end
    
    if Nidx == 1
        ylabel('Proportion')
        set(gca,'ytick',0:0.2:1,'yticklabel',[0:0.2:1]);
        L = legend(strcat({'Delay = '},num2str(delayvec),' s'));
        set(L,'Position',[0.87 .225 .1 .15])
    else
        set(gca,'yticklabel',[]);
    end
    
    title(strcat({'{\it N} = '}, num2str(Nvec(Nidx))))
    axis([-pi, pi, 0, 1]);
    set(gca,'xtick', [-pi:pi/3:pi],'xticklabel',[-90:30:90],'LineWidth',1.5, 'TickDir','out','TickLength',[0.02 0.05]);
    xlabel('Estimation error (\circ)')
end

for delayidx = 1:ndelays % Each plot corresponds to one delay time
    subplot(2,4,delayidx,'pos', [0.07 + (delayidx-1) * 0.2 0.6  0.175 0.3]); hold on;
    
    if plotmodel == 0 % No model
        myerrorbar(errorbincenters, squeeze(error_hist(delayidx,:,:,:)),2,[],delaycolors);
    else
        myshadedarea(errorvec, squeeze(modelpredmatrix(delayidx,:,:,:)),2,delaycolors);
        myerrorbar(errorbincenters, squeeze(error_hist(delayidx,:,:,:)),2,'.',delaycolors);
    end
    
    if delayidx == 1
        ylabel('Proportion')
        set(gca,'ytick',0:0.2:1,'yticklabel',[0:0.2:1]);
        L = legend(strcat({'{\it N} = '},num2str(Nvec)));
        set(L,'Position',[0.87 .675 .08 .15])
    else
        set(gca,'yticklabel',[]);
    end
    title(strcat({'Delay = '}, num2str(delayvec(delayidx)),' s'))
    axis([-pi, pi, 0, 1]);
    set(gca,'xtick', [-pi:pi/3:pi],'xticklabel',[-90:30:90],'LineWidth',1.5, 'TickDir','out','TickLength',[0.02 0.05]);
end

ax = axes('position',[0,0,1,1],'visible','off');
text(0.02,0.95,'A','FontSize',20);
text(0.02,0.5,'B','FontSize',20);


printfigure(strcat('results/figures/exp', num2str(experiment), '_model', num2str(plotmodel)))

