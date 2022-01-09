# working-memory-delay

This repository contains the experimental code, experimental data, and the analysis code from the paper
Shin H, Zou Q, Ma WJ (2017), [<I>The effects of delay duration on visual working memory for orientation</I>](https://jov.arvojournals.org/article.aspx?articleid=2666126), Journal of Vision 17 (14): 10. DOI: 10.1167/17.14.10

Experiment 1 is with delay duration blocked, Experiment 2 is with delay durations interleaved. Delay duration was 1, 2, 3, or 6 seconds. Set size was 1, 2, 4, or 6.
The experimental code is in Exp 1 code.zip and Exp 2 code.zip. The data are in data_raw_Exp1.zip and data_raw_Exp2.zip.

The analysis code (Matlab) is in the following files: A_readdata.m, B_comparison.m, B_nontargeterrors.m, B_orientationdependence.m, B_plotsummstats.m, C_modelfitting.m, C_modelpredictions.m, C_specifymodel.m, D_plotdatawithfits.m, E_modelcomparison.m, F_parestimates.m, and nontargetmodel.m. They should ideally be run in this order. 

The remaining .m files are auxiliary functions. You will also need the [Circular Statistics Toolbox (created for Matlab R2012a)](https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics). In C_modelfitting.m, we are using BPS (Bayesian pattern search). This is a global optimization algorithm that has since been improved to [Bayesian Adaptive Direct Search (BADS)](https://github.com/lacerbi/bads). You will need to download that code and replace the bps command by a bads command in C_modelfitting.m. 

For questions, please contact Wei Ji Ma at weijima@nyu.edu.
