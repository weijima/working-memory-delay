function NLL = nontargetmodel(pars, error_cond, error_distr)

kappa     = exp(pars(1));
lapse     = pars(2);

if length(pars) <= 2 % no non-target reports (when N = 1)
    p_resp = lapse/2/pi + (1-lapse)/2/pi/besseli0_fast(kappa,1) * exp(kappa * (cos(error_cond)-1));
    NLL = - sum(log(p_resp));
else
    weight_nt = pars(3);
    if lapse + weight_nt > 1
        NLL = Inf;
    else
        p_resp = lapse/2/pi + (1-lapse - weight_nt)/2/pi/besseli0_fast(kappa,1) * exp(kappa * (cos(error_cond)-1)) + ...
            weight_nt/2/pi/besseli0_fast(kappa,1) * mean(exp(kappa * (cos(error_distr)-1)),2);
        NLL = - sum(log(p_resp));
    end
end
