clear; 
%close all; 
addpath(genpath('./')); 
plotsettings()
% Fit Bays' model for nontarget reports

experiment = 1;
filename = strcat('alldata_exp', num2str(experiment));
load(filename)
nsubj = length(alldata);

delayvec          = alldata{1}.delayvec;
Nvec_distr        = alldata{1}.Nvec_distr;
Nvec              = alldata{1}.Nvec;

for subjidx = 1:nsubj
    subjidx
    alldelayidx    = alldata{subjidx}.alldelayidx;
    allNidx        = alldata{subjidx}.allNidx;
    allerror       = alldata{subjidx}.allerror;
    allerror_distr = alldata{subjidx}.allerror_distr; % error w.r.t. distractors
    for delayidx   = 1:length(delayvec)
        delayidx
        for Nidx   = 1:length(Nvec)
            N = Nvec(Nidx)
            idx    = find(alldelayidx == delayidx & allNidx == Nidx);
            
            error_cond = allerror(idx);
            error_distr = NaN(length(idx), Nvec(Nidx)-1);
            
            if N == 1
                lb = [0 0];
                ub = [4 0.5];
                init = lb + (ub-lb) .* rand(1,2);
                par_est = fmincon(@(par) nontargetmodel(par, error_cond, error_distr), init, [],[],[],[],lb, ub);
                allpar_est(subjidx,:,delayidx,Nidx) = [par_est 0];
            else
                for trialidx = 1:length(idx)
                    error_distr(trialidx,:) = allerror_distr{idx(trialidx)};
                end
                
                lb = [0 0 0];
                ub = [4 0.5 0.5];
                init = lb + (ub-lb) .* rand(1,3);
                par_est = fmincon(@(par) nontargetmodel(par, error_cond, error_distr), init, [],[],[],[],lb, ub);
                allpar_est(subjidx,:,delayidx,Nidx) = par_est;
            end
            
            error_hist_distr(delayidx, Nidx,:,subjidx) = hist(error_distr(:), errorbincenters)/length(error_distr(:));
        end
    end
end

allkappa     = permute(squeeze(allpar_est(:,1,:,:)), [2 3 1]);
alllapse     = permute(squeeze(allpar_est(:,2,:,:)), [2 3 1]);
allweight_nt = permute(squeeze(allpar_est(:,3,:,:)), [2 3 1]);

%% Plotting
ndelays         = alldata{1}.ndelays;
nN              = alldata{1}.nN;

% Individual subjects' histograms of nontarget errors
figure('Position', [100, 100, 1100, 700 * nsubj/5])

yspacing1 = 0.14 /(nsubj/5);
yspacing2 = 0.17 /(nsubj/5);

nN_distr = nN -1;

for subjidx = 1:nsubj
    for N_dist_idx = 1:nN_distr % Each plot corresponds to one delay time
        subplot(nsubj,nN_distr,(subjidx-1)*nN_distr+N_dist_idx,'pos', [0.13+(N_dist_idx-1)*0.25,  0.1+(nsubj-subjidx)*0.17/(nsubj/5),  0.2, 0.14/(nsubj/5)]);
        hold on;
        for delayidx = 1:ndelays
            plot(errorbincenters, squeeze(error_hist_distr(delayidx,N_dist_idx+1,:,subjidx)),'Color',delaycolors(delayidx,:));
        end
        axis([-pi, pi, 0, 1]); set(gca,'ytick',0:0.2:1)
        
        if N_dist_idx == 1
            ylabel('Proportion')
            set(gca,'yticklabel',[0:0.2:1]);
            L = legend(strcat({'delay = '},num2str(delayvec), [' s']));
            set(L,'Position',[0.89 .44 .05 .15],'FontSize',16)
        else
            set(gca,'yticklabel',[]);
        end
        if subjidx == 1 & N_dist_idx <=nN_distr
            title(strcat({'{\it N} = '},num2str(Nvec(N_dist_idx+1))),'Color',Ncolors(N_dist_idx+1,:))
        end
        if subjidx == nsubj
            set(gca,'xtick', [-pi:pi/3:pi],'xticklabel',[-90:30:90]);
            xlabel('Estimation error (\circ)')
        else
            set(gca,'xticklabel', [])
        end
        grid on; plotsettings()
    end
end

ax = axes('position',[0,0,1,1],'visible','off');
for subjidx = 1:nsubj
    text(0.02, 0.1 + yspacing1/2 + (nsubj-subjidx) * yspacing2,strcat('S', num2str(subjidx)),'FontSize',20);
end
printfigure(strcat('results/figures/exp', num2str(experiment), '_nontarget'))



figure('Position', [100, 100, 750, 300])
h1 = subplot(1,3,1); set(h1, 'pos', [0.09 0.25  0.2 0.6]);
myerrorbar(delayvec, allkappa,[],[], Ncolors); xlabel('Delay time (s)'); ylabel('Log concentration parameter');

[L, objh] = legend(strcat({'{\it N} = '},num2str(Nvec)));
set(L,'Position',[0.9 .35 .093 .3])
set(findobj(objh,'type','line'), 'LineWidth',2)

h2 = subplot(1,3,2); set(h2, 'pos', [0.38 0.25  0.2 0.6]);
myerrorbar(delayvec, alllapse,[],[], Ncolors); xlabel('Delay time (s)'); ylabel('Weight to uniform');

h3 = subplot(1,3,3); set(h3, 'pos', [0.67 0.25  0.2 0.6]);
myerrorbar(delayvec, allweight_nt(:,2:end,:),[],[], Ncolors(2:end,:)); xlabel('Delay time (s)'); ylabel('Weight to nontarget'); ylim([0 1])

set([h1 h2 h3], 'xtick', delayvec,'xlim', [0.5 6.5])
set([h2 h3],'ylim',[0 1])
plotsettings()
ax = axes('position',[0,0,1,1],'visible','off');
text(0.01,0.95,'A','FontSize',20);
text(0.30,0.95,'B','FontSize',20);
text(0.59,0.95,'C','FontSize',20);
printfigure(strcat('results/figures/exp', num2str(experiment), '_weights'))