function [NLL, NLL_cond, allp_resp] = C_modelpredictions(pars, model, data)

logJvec = linspace(-6,2,500);

pardesign      = model.pardesign;
nJbar          = model.nJbar;
noisemodel     = model.noisemodel;
ncond          = model.ncond;
errorvec       = model.errorvec;

% Two types of parameters
logJbars       = pars(1:nJbar);
otherpars      = pars(nJbar+1:end);

% Fitting mode or model prediction mode?
nodata         = nargin < 3; % 1 when function is run with ML estimates of parameters
if ~nodata
    error      = data.allerror;
    allcondidx = data.allcondidx;
end

% Loop over conditions
NLL_cond  = NaN(1,ncond); % negative log likelihood by condition
allp_resp = NaN(ncond, length(errorvec));
for condidx = 1:ncond
    if nodata
        error_cond = errorvec;
    else
        error_cond = error(allcondidx == condidx);
    end
    
    Jbaridx_cond = pardesign(1,condidx);
    Jbar         = exp(logJbars(Jbaridx_cond));
    
    if size(pardesign,1) > 1
        otherparidx_cond = pardesign(2,condidx);
        otherpar = otherpars(otherparidx_cond);
    end
    
    switch noisemodel
        case 0
            kappa = Jtokappa(Jbar);
            p_resp = 1/2/pi/besseli0_fast(kappa,1) * exp(kappa * (cos(error_cond)-1));
        case 1 % Mixture of Von Mises and uniform
            kappa = Jtokappa(Jbar);
            lapse = otherpar;
            p_resp = lapse/2/pi + (1-lapse)/2/pi/besseli0_fast(kappa,1) * exp(kappa * (cos(error_cond)-1));
        case {2, 3} % Variable-precision model
            if noisemodel == 2
                scale = exp(otherpar);
                shape = Jbar/scale;
            elseif noisemodel == 3
                shape = 1/exp(otherpar);
                scale = Jbar/shape;
            end
            Jvec = exp(logJvec); % Vector used for numerical integration; use at least 250 steps
            [J,E] = meshgrid(Jvec, error_cond);
            kappa = Jtokappa(J);
            p_error_given_J = 1/2/pi./besseli0_fast(kappa,1) .* exp(kappa .* (cos(E)-1));
            p_J = gampdf(Jvec, shape, scale);
            p_resp = qtrapz(bsxfun(@times, p_error_given_J, p_J .* Jvec),2) * diff(logJvec(1:2));
    end
    
    if nodata
        allp_resp(condidx,:) = p_resp;
    end
    
    NLL_cond(condidx) = -sum(log(p_resp));
end

NLL = sum(NLL_cond);