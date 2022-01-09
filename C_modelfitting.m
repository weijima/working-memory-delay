clear; close all; warning off; addpath(genpath('./'));
% Todo: save general settings above subject level in superstructure e.g.
% modelresults{modelidx}. and modelresults{modelidx}.bysubject{subjidx}.paridx

experiment = 2;
filename = strcat('alldata_exp', num2str(experiment));
load(filename)

nsubj = length(alldata);

nmodels = 14;
nruns = 10;
modelresults = cell(nmodels, nsubj);
models       = cell(nmodels);
for modelidx = 1:nmodels
    modelidx
    model = C_specifymodel(modelidx, alldata{1}.conditions)
    models{modelidx} = model;
    
    for subjidx = 1:nsubj
        subjidx
        data = alldata{subjidx};
        
        % Fit parameters by subject, plug fitted parameters back into model 
        out1 = NaN(nruns,model.npars);
        out2 = NaN(1,nruns);
        for run = 1:nruns
            run
            model.init = unifrnd(model.lb, model.ub);            
            [out1(run,:), out2(run)] = bps(@(par) C_modelpredictions(par, model, data), model.init, model.lb, model.ub);
        end
        out2
        [NLL_total, runidx] = min(out2);
        par_est = out1(runidx,:);
        [~, NLL_cond, ~]     = C_modelpredictions(par_est, model, data);
        [~, ~, p_resp]       = C_modelpredictions(par_est, model);
        
        % Saving for this model and this subject
        modelresults{modelidx,subjidx}.par_est   = par_est;
        modelresults{modelidx,subjidx}.NLL_total = NLL_total;
        modelresults{modelidx,subjidx}.NLL_cond  = NLL_cond;
        modelresults{modelidx,subjidx}.modelpred = p_resp;
    end
end
save(strcat('results/results_exp', num2str(experiment), '_', datestr(now, 29)),'alldata','models','modelresults')
D_plotdatawithfits
