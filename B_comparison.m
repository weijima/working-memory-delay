% Comparison between experiments and with Pertzov et al. (2017)
clear; close all; addpath(genpath('./')); plotsettings()

%% Experiment 1

experiment = 1;
filename = strcat('alldata_exp', num2str(experiment));
load(filename)
nsubj_1 = length(alldata);

for subjidx = 1:nsubj_1
    delayvec    = alldata{subjidx}.delayvec;
    Nvec        = alldata{subjidx}.Nvec;
    alldelayidx = alldata{subjidx}.alldelayidx;
    allNidx     = alldata{subjidx}.allNidx;
    allerror    = alldata{subjidx}.allerror;
    
    for delayidx = 1:length(delayvec)
        for Nidx = 1:length(Nvec)
            idx = find(alldelayidx == delayidx & allNidx == Nidx);
            
            error = allerror(idx);            
            abserror(delayidx, Nidx) = 90/pi * mean(abs(error));
        end
    end
    allabserror_exp1(:,:,subjidx) = abserror;

    % Linear regression per set size to compare with Pertzov
    for Nidx = 1:length(Nvec)
        beta_abserror_exp1(:,Nidx,subjidx)  = regress(abserror(:,Nidx),   [ones(length(delayvec),1), delayvec]);
    end
end

%% Experiment 2

experiment = 2;
filename = strcat('alldata_exp', num2str(experiment));
load(filename)
nsubj_2 = length(alldata);

for subjidx = 1:nsubj_2
    delayvec    = alldata{subjidx}.delayvec;
    Nvec        = alldata{subjidx}.Nvec;
    alldelayidx = alldata{subjidx}.alldelayidx;
    allNidx     = alldata{subjidx}.allNidx;
    allerror    = alldata{subjidx}.allerror;
    
    for delayidx = 1:length(delayvec)
        for Nidx = 1:length(Nvec)
            idx = find(alldelayidx == delayidx & allNidx == Nidx);
            
            error = allerror(idx);            
            abserror(delayidx, Nidx) = 90/pi * mean(abs(error));
        end
    end
    allabserror_exp2(:,:,subjidx) = abserror;

    % Linear regression per set size to compare with Pertzov
    for Nidx = 1:length(Nvec)
        beta_abserror_exp2(:,Nidx,subjidx)  = regress(abserror(:,Nidx),   [ones(length(delayvec),1), delayvec]);
    end
end


%% Comparison

% Overall mean error on common delay times
a1 = squeeze(mean(mean(allabserror_exp1(1:3,:,:),2),1))
[mean(a1) std(a1)/sqrt(nsubj_1)]

a2 = squeeze(mean(mean(allabserror_exp2(1:3,:,:),2),1))
[mean(a2) std(a2)/sqrt(nsubj_2)]

[h,p] = ttest2(a1, a2)

% "Forgetting slopes"
b1 = squeeze(beta_abserror_exp1(2,:,:)); % 2 for slope (1 would be intercept)
[mean(b1,2) std(b1,[],2)/sqrt(nsubj_1)]
b2 = squeeze(beta_abserror_exp2(2,:,:));
[mean(b2,2) std(b2,[],2)/sqrt(nsubj_2)]

group1 = combvec(Nvec', 1:nsubj_1)';
group2 = combvec(Nvec', 1:nsubj_2)';

[p, ~, stats] = anovan(b1(:), group1, 'random',1)
[p, ~, stats] = anovan(b2(:), group2, 'random',1)

% Pertzov Fig 4
mean1 = 0.340; upper1 = 0.51 ; sem1 = upper1 - mean1;
mean2 = 0.876; upper2 = 0.996; sem2 = upper2 - mean2;
mean3 = 2.042; upper3 = 2.311; sem3 = upper3 - mean3;
mean6 = 4.299; upper6 = 4.724; sem6 = upper6 - mean6;
slopes_Pertzov = [mean1 sem1; mean2 sem2; mean3 sem3; mean6 sem6];

% Pertzov Fig 1B; rows are delays 1, 2, 3 s; columns are set sizes 1, 2, 4, 6
abserror_Pertzov = [
    8.5900   11.1800   13.9700   19.4800
    9.3300   11.1400   15.6200   24.4500
    9.0000   13.6800   17.7500   27.1600];

for Nidx = 1:length(Nvec)
    beta_abserror_Pertzov(:,Nidx)  = regress(abserror_Pertzov(:,Nidx), [ones(3,1), [1 2 3]']);
end

figure('Position', [100, 100, 400, 300])
hold on;
errorbar(Nvec, mean(b1,2), std(b1,[],2)/sqrt(nsubj_1),'LineWidth',1.5);
errorbar(Nvec, mean(b2,2), std(b2,[],2)/sqrt(nsubj_2),'LineWidth',1.5);
errorbar(Nvec, slopes_Pertzov(:,1),slopes_Pertzov(:,2),'k','LineWidth',1.5)
plot(Nvec, beta_abserror_Pertzov(2,:), 'ko','LineWidth',1.5)
legend('Experiment 1', 'Experiment 2', 'Pertzov et al. (all conditions)', 'Pertzov et al. (WM conditions)','Location', 'NorthWest')
xlabel('Set size')
ylabel('Forgetting slope (^\circ/s)')
set(gca, 'xtick', Nvec,'xlim', [0.5 6.5])
set(gca, 'ytick', 0:0.5:5, 'ylim', [0 5])
printfigure(strcat('results/figures/forgettingslopes'))


