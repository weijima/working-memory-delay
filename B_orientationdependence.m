clear; close all force; addpath(genpath('./')); plotsettings() 

experiment = 2;
filename = strcat('alldata_exp', num2str(experiment));
load(filename)

% For binning target orientation
ntargetbins      = 18;
targetbinedges   = linspace(-pi, pi, ntargetbins + 1);
targetbincenters = targetbinedges(1:end-1) + diff(targetbinedges(1:2))/2;

nsubj = length(alldata);

for subjidx = 1:nsubj
    delayvec    = alldata{subjidx}.delayvec;
    Nvec        = alldata{subjidx}.Nvec;
    alldelayidx = alldata{subjidx}.alldelayidx;
    allNidx     = alldata{subjidx}.allNidx;
    allerror    = alldata{subjidx}.allerror;
    target      = alldata{subjidx}.alltarget;
    resp        = alldata{subjidx}.allresp;
    alltarget(:,subjidx) = target;
    allresp(:,subjidx) = resp;
    
    for targetidx = 1:ntargetbins
        idx = find(target > targetbinedges(targetidx) & target < targetbinedges(targetidx+1));
        bias(targetidx,subjidx)       = 90/pi * circ_mean(allerror(idx));
        csd_target(targetidx,subjidx) = 90/pi * circ_std(allerror(idx));
    end
    
    for delayidx = 1:length(delayvec)
        for Nidx = 1:length(Nvec)
            idx = find(alldelayidx == delayidx & allNidx == Nidx);
            
            target_cond = target(idx);
            weight = ones(size(target_cond));
            weight(target_cond > -pi/2 & target_cond < 0) = -1;
            weight(target_cond > pi/2 & target_cond < pi) = -1;
            obliquebias(delayidx, Nidx, subjidx) = 90/pi * circ_mean(weight .* allerror(idx));
            
            for targetidx = 1:ntargetbins
                idx = find(alldelayidx == delayidx & allNidx == Nidx & target > targetbinedges(targetidx) & target < targetbinedges(targetidx+1));
                bias_cond(delayidx, Nidx,targetidx,subjidx) = 90/pi * circ_mean(allerror(idx));
                csd_cond(delayidx, Nidx,targetidx,subjidx)  = 90/pi * circ_std(allerror(idx));
                %% CSD seems contaminated by bias (since bins are not zero width) . BE acareful!!
            end
        end
    end
end

%% ANOVA on bias

% Effect of target orientation on bias and CSD (collapsed across delay time and set size)
factordesign = combvec(1:ntargetbins, 1:nsubj)';
factor_target = factordesign(:,1);
factor_subj   = factordesign(:,2);
[pbias, ~, stats] = anovan(bias(:), factordesign, 'random',2)
%[pcsd, ~, stats] = anovan(csd_target(:), factordesign, 'random',2)
 
% Effect of delay time and set size on net oblique bias
factordesign = combvec(delayvec', Nvec', 1:nsubj)';
factor_delay = factordesign(:,1);
factor_N     = factordesign(:,2);
factor_subj  = factordesign(:,3);

anova_obliquebias = rm_anova2(obliquebias(:), factor_subj, factor_delay, factor_N, {'delay', 'set size'})


%% Plotting

figure('Position', [100, 100, 1000, 600])
subplot(2,4,[1 2 5 6],'pos', [0 0.275  0.5 0.5])

hold on; axis square; box on
plot([-pi pi], [-pi pi], 'r--','Linewidth',0.5)
h = scatter(alltarget(:), allresp(:),'k.'); axis([-pi pi -pi pi]);
set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90)
set(gca, 'ytick', -pi:pi/2:pi, 'yticklabel', -90:45:90)
xlabel('Target orientation (\circ)'); ylabel('Reported orientation (\circ)')
plotsettings(); 
hChildren = get(h, 'Children');
set(hChildren, 'Markersize', 3)

subplot(2,4,3, 'pos', [0.5 0.6  0.18 0.33]); hold on;
plot([-pi pi], [0 0], 'k--')
plot(targetbincenters, bias,'Color',[.7 .7 .7])
myerrorbar(targetbincenters, bias); xlabel('Target orientation (\circ)'); ylabel('Estimation bias (\circ)');
%axis square;
axis([-pi pi -20 20]);
set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90)
set(gca, 'ytick', -20:10:20, 'yticklabel', -20:10:20)

%% CSD seems contaminated by bias (since bins are not zero width)
% subplot(1,3,3, 'pos', [0.76 0.25  0.23 0.6]); hold on;
% plot(targetbincenters, csd_target,'Color',[.7 .7 .7])
% myerrorbar(targetbincenters, csd_target); xlabel('Target orientation (\circ)'); ylabel('Circular standard deviation (\circ)');
% axis square; grid on; box off;
% axis([-pi pi 0 40]);
% set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90)
% set(gca, 'ytick', 0:10:40, 'yticklabel', 0:10:40)
% 
% ax = axes('position',[0,0,1,1],'visible','off');
% text(0.02,0.9,'A','FontSize',20);
% text(0.35,0.9,'B','FontSize',20);
% text(0.67,0.9,'C','FontSize',20);

% printfigure(strcat('results/figures/exp', num2str(experiment), '_orientation1'))

% Summary of oblique bias
%figure('Position', [100, 100, 1000, 300])
subjidx =1; delayidx = 1; Nidx = 1;
alldelayidx = alldata{subjidx}.alldelayidx;
allNidx     = alldata{subjidx}.allNidx;
target      = alldata{subjidx}.alltarget;
allerror    = alldata{subjidx}.allerror;
idx         = find(alldelayidx == delayidx & allNidx == Nidx);

subplot(2,4,4, 'pos', [0.77 0.6  0.18 0.33]); hold on;
plot([-pi pi], [0 0], 'k--')
scatter(target(idx), 90/pi * allerror(idx),'k.');
axis([-pi pi -90 90]);
set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90,'ytick', -90:45:90);
xlabel('Target orientation (\circ)'); ylabel('Error')
plotsettings()

h = subplot(2,4,7, 'pos', [0.5 0.225  0.18 0.15]); hold on;
plot([-pi pi], [0 0], 'k--')
targetvec = linspace(-pi,pi,361);
mask = ones(size(targetvec));
mask(targetvec > -pi/2 & targetvec < 0) = -1;
mask(targetvec > pi/2 & targetvec < pi) = -1;
plot(targetvec(targetvec < -pi/2), mask(targetvec < -pi/2),'k');
plot(targetvec(targetvec > -pi/2 & targetvec < 0), mask(targetvec > -pi/2 & targetvec < 0),'k');
plot(targetvec(targetvec > 0 & targetvec < pi/2), mask(targetvec > 0 & targetvec < pi/2),'k');
plot(targetvec(targetvec > pi/2 & targetvec < pi), mask(targetvec > pi/2 & targetvec < pi),'k');
plot([-pi/2 -pi/2],[-1 1],'k--'); plot([0 0],[-1 1],'k--'); plot([pi/2 pi/2],[-1 1],'k--');
plotsettings(); box off; grid off;
axis([-pi pi -1.1 1.1]);
set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90,'ytick', -1:1);
xlabel('Target orientation (\circ)'); ylabel('Weight')

subplot(2,4,8, 'pos', [0.77 0.15  0.18 0.33]);

myerrorbar(delayvec, obliquebias,[],[],Ncolors); 
xlabel('Delay duration (s)'); ylabel('Net oblique bias (\circ)');
axis([0.5 6.5 -20 20])
set(gca,'xtick', delayvec); 
set(gca, 'ytick', -20:10:20, 'yticklabel', -20:10:20)
[L, objh] = legend(strcat({'{\it N} = '},num2str(Nvec)),'Location','SouthEast');
set(findobj(objh,'type','line'), 'LineWidth',2)
plotsettings()
plot([0.5 6.5], [0 0], 'k--')

ax = axes('position',[0,0,1,1],'visible','off');
text(0.03,0.96,'A','FontSize',20);
text(0.43,0.96,'B','FontSize',20);
text(0.70,0.96,'C','FontSize',20);
text(0.43,0.48,'D','FontSize',20);
text(0.70,0.48,'E','FontSize',20);

printfigure(strcat('results/figures/exp', num2str(experiment), '_orientation2'))


% Bias vs target orientation by condition
ndelays         = alldata{1}.ndelays;
nN              = alldata{1}.nN;

figure('Position', [100, 100, 1000, 300])
for Nidx = 1:nN
    subplot(1,nN,Nidx,'pos', [0.1+(Nidx-1)*0.2,  0.25,  0.15, 0.6]);
    hold on;
    for delayidx = 1:ndelays
        myerrorbar(targetbincenters, squeeze(bias_cond(:,Nidx,:,:)),2,[],delaycolors);
    end
    
    if Nidx == 1; ylabel('Bias (\circ)'); set(gca,'yticklabel',-40:10:40); else set(gca,'yticklabel',[]); end
    set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90,'ytick', -40:10:40)
    axis([-pi pi -40 40]);
    xlabel('Target orientation (\circ)')
    title(strcat({'{\it N} = '},num2str(Nvec(Nidx))),'Color',Ncolors(Nidx,:))
    grid on; plotsettings()
end
[L, objh] = legend(strcat(['delay = ',' '],num2str(delayvec), [' s']));
set(L,'Position', [0.9 0.35 0.07 0.3])
set(findobj(objh,'type','line'), 'LineWidth',2)
plotsettings()

printfigure(strcat('results/figures/exp', num2str(experiment), '_orientation3'))


% % CSD vs target orientation by condition
% figure('Position', [100, 100, 1000, 300])
% for Nidx = 1:nN
%     subplot(1,nN,Nidx,'pos', [0.1+(Nidx-1)*0.2,  0.25,  0.15, 0.6]);
%     hold on;
%     for delayidx = 1:ndelays
%         myerrorbar(targetbincenters, squeeze(csd_cond(:,Nidx,:,:)),2,[],delaycolors);
%     end
%     
%     if Nidx == 1; ylabel('Circular standard deviation (\circ)'); set(gca,'yticklabel',0:10:50); else set(gca,'yticklabel',[]); end
%     set(gca, 'xtick', -pi:pi/2:pi, 'xticklabel', -90:45:90,'ytick', 0:10:50)
%     axis([-pi pi 0 50]);
%     xlabel('Target orientation (\circ)')
%     title(['N =',' ',num2str(Nvec(Nidx))],'Color',Ncolors(Nidx,:))
%     grid on; plotsettings()
% end
% [L, objh] = legend(strcat(['delay = ',' '],num2str(delayvec), [' s']));
% set(L,'Position', [0.9 0.35 0.07 0.3])
% 
% printfigure(strcat('results/figures/exp', num2str(experiment), '_orientation4'))
% 
% set(findobj(objh,'type','line'), 'LineWidth',2)
% plotsettings()