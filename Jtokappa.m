function kappa = Jtokappa(J)

kappa_map = exp([linspace(-4,2.3,250) linspace(2.31,7,250)]);
J_map     = kappa_map .* besseli(1,kappa_map,1) ./ besseli(0,kappa_map,1);
kappa     = interp1(J_map,kappa_map,J);