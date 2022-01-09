function model = C_specifymodel(modelidx, conditions)

models = [0 0 1 1 1 1 2 2 2 2 3 3 3 3;  % first row: noisemodel (pure Von Mises, mixture model, etc)
          1 2 1 2 3 4 1 2 3 4 1 2 3 4]; % second row: model variant: which parameters shared among which conditions

% (In parentheses number of parameters)
% Model  1: Pure von Mises model, one Jbar per condition (16)
% Model  2: Pure von Mises model, one Jbar per set size (4)

% Model  3: Mixture of Von Mises and uniform, one Jbar per condition, one lapse rate across all conditions (17)
% Model  4: Mixture of Von Mises and uniform, one Jbar per set size, one lapse rate across all conditions (5)
% Model  5: Mixture of Von Mises and uniform, one Jbar per condition, one lapse rate per set size (20)
% Model  6: Mixture of Von Mises and uniform, one Jbar per set size, one lapse rate per set size (8)

% Model  7: Variable-precision model, one Jbar per condition, one scale par across all conditions (17)
% Model  8: Variable-precision model, one Jbar per set size, one scale par across all conditions (5)
% Model  9: Variable-precision model, one Jbar per condition, one scale par per set size (20)
% Model 10: Variable-precision model, one Jbar per set size, one scale par per set size (8)

% Model 11: Variable-precision model, one Jbar per condition, one inverse shape par across all conditions (17)
% Model 12: Variable-precision model, one Jbar per set size, one inverse shape par across all conditions (5)
% Model 13: Variable-precision model, one Jbar per condition, one inverse shape par per set size (20)
% Model 14: Variable-precision model, one Jbar per set size, one inverse shape par per set size (8)


noisemodel = models(1,modelidx);
variant    = models(2,modelidx);
ncond      = size(conditions,2);

switch noisemodel
    case 0
        display('Pure Von Mises model')
    case 1
        display('Mixture of Von Mises and uniform')
    case 2
        display('Variable-precision model with constant scale par')
    case 3
        display('Variable-precision model with constant inverse shape par')
end

switch variant
    case 1
        if noisemodel == 0
            display('One Jbar per condition, no other parameters')
            pardesign = 1:ncond;
        else
            display('One Jbar per condition, one other parameter across all conditions')
            pardesign = [1:ncond; ones(1,ncond)];
        end
    case 2
        if noisemodel == 0
            display('One Jbar per set size, no other parameters')
            pardesign = conditions(2,:);
        else
            display('One Jbar per set size, one other parameter across all conditions')
            pardesign = [conditions(2,:); ones(1,ncond)];
        end
    case 3
        display('One Jbar per condition, one other par per set size')
        pardesign = [1:ncond; conditions(2,:)];
    case 4
        display('One Jbar and one other par per set size')
        pardesign = [conditions(2,:); conditions(2,:)];
end

% Counting precision and other parameters
nJbar  = max(pardesign(1,:));
if noisemodel == 0
    nother = 0;
else
    nother = max(pardesign(2,:));
end
npars = nJbar + nother;

% Initialization of parameter fitting
logJbar_init = 0;
logJbar_lb   = -6;
logJbar_ub   = 4;

logtau_init  = 0;
logtau_lb    = -6;
logtau_ub    = 4;

logkinv_init = 0;
logkinv_lb   = -6;
logkinv_ub   = 4;

lapse_init   = 0;
lapse_lb     = 0;
lapse_ub     = 1;

init(1:nJbar) = logJbar_init * ones(1,nJbar);
lb(1:nJbar)   = logJbar_lb   * ones(1,nJbar);
ub(1:nJbar)   = logJbar_ub   * ones(1,nJbar);

switch noisemodel
    case 1
        init = [init  lapse_init   * ones(1,nother)];
        lb   = [lb    lapse_lb     * ones(1,nother)];
        ub   = [ub    lapse_ub     * ones(1,nother)];
    case 2
        init = [init  logtau_init  * ones(1,nother)];
        lb   = [lb    logtau_lb    * ones(1,nother)];
        ub   = [ub    logtau_ub    * ones(1,nother)];
    case 3
        init = [init  logkinv_init * ones(1,nother)];
        lb   = [lb    logkinv_lb   * ones(1,nother)];
        ub   = [ub    logkinv_ub   * ones(1,nother)];
end

model.noisemodel      = noisemodel;
model.variant         = variant;
model.ncond           = ncond;
model.pardesign       = pardesign;
model.nJbar           = nJbar;
model.nother          = nother;
model.npars           = npars;
model.init            = init;
model.lb              = lb;
model.ub              = ub;
model.errorvec        = linspace(-pi, pi, 61);

