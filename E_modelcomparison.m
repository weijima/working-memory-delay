clear; close all; warning off; addpath(genpath('./'));

experiment = 2;

switch experiment
    case 1
        load results/results_exp1_2017-01-30
    case 2
        load results/results_exp2_2017-08-28
end


nsubj = length(alldata);

for modelidx = 1:14
    for subjidx = 1:nsubj
        NLL(modelidx,subjidx) = modelresults{modelidx,subjidx}.NLL_total;
        AIC(modelidx,subjidx) = 2*models{modelidx}.npars + 2*modelresults{modelidx,subjidx}.NLL_total ;
        BIC(modelidx,subjidx) = log(alldata{1}.ntrials)*models{modelidx}.npars + 2*modelresults{modelidx,subjidx}.NLL_total
    end
end

display('is there a benefit of the extra parameter? negative = yes')
allLL = bsxfun(@minus, NLL([3 7 11],:),NLL(1,:))'
allAIC = bsxfun(@minus, AIC([3 7 11],:),AIC(1,:))'
allBIC = bsxfun(@minus, BIC([3 7 11],:),BIC(1,:))'

display('is there an effect of delay time? negative = yes')
allLL  = bsxfun(@minus, NLL([1 3 7 11],:),NLL([2 4 8 12],:))'
allAIC = bsxfun(@minus, AIC([1 3 7 11],:),AIC([2 4 8 12],:))'
allBIC = bsxfun(@minus, BIC([1 3 7 11],:),BIC([2 4 8 12],:))'

display('is there evidence for set size dependent lapses? negative = yes')
allLL  = bsxfun(@minus, NLL(5,:),NLL(3,:))'
allAIC = bsxfun(@minus, AIC(5,:),AIC(3,:))'
allBIC = bsxfun(@minus, BIC(5,:),BIC(3,:))'



% display('is the shared parameter set-size-specific?')
% allLL = bsxfun(@minus, LL([5 9 13],:),LL([3 7 11],:))'
% allAIC = bsxfun(@minus, AIC([5 9 13],:),AIC([3 7 11],:))'
% allBIC = bsxfun(@minus, BIC([5 9 13],:),BIC([3 7 11],:))'
% 
% display('is there an effect of delay time if the shared parameter set-size-specific?')
% allLL = bsxfun(@minus, LL([5 9 13],:),LL([6 10 14],:))'
% allAIC = bsxfun(@minus, AIC([5 9 13],:),AIC([6 10 14],:))'
% allBIC = bsxfun(@minus, BIC([5 9 13],:),BIC([6 10 14],:))'
