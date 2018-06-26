function [mean_cf,sigma_cf,insert_scanned_act,insert_scanned_act_sigma] = Calc_cfuncert_insert(stock_act,stock_res,act_uncert,act_res_uncert,act_time,res_time,acq_time,act_time_uncert,res_time_uncert,meancounts,stdcounts,ScanDur,tau)

%% Constant factors

NPL_Calibration_Sigma = 2.1/100;
Calibration_Sigma = 0.03/100; % Syringe
% Calibration_Sigma = 0.025/100; % Vial
Cs137_Sigma = 0.15/100;
Sigma_calibration = sqrt(NPL_Calibration_Sigma.^2 + Calibration_Sigma.^2 + Cs137_Sigma.^2);
%%
res_time_elapsed = res_time-act_time;
res_time_elapsed_sigma = sqrt(act_time_uncert.^2 + res_time_uncert.^2);
stock_total_act = stock_act.*exp(-res_time_elapsed./tau) - stock_res;
stock_act_sigma = act_uncert;
stock_res_sigma = act_res_uncert;
stock_total_act_sigma = sqrt((exp(-res_time_elapsed./tau).^2).*(stock_act_sigma .^2) + ((-stock_act.*exp(-res_time_elapsed./tau)./tau).^2).*(res_time_elapsed_sigma.^2) + stock_res_sigma.^2 + (stock_total_act.^2).*(Sigma_calibration.^2));
time_elapsed = acq_time - res_time;
insert_scanned_act = stock_total_act.*exp(-time_elapsed./tau);
insert_scanned_act_sigma = sqrt((exp(-time_elapsed./tau).^2).*(stock_total_act_sigma.^2) + ((-stock_total_act.*exp(-time_elapsed./tau)./tau).^2).*(res_time_uncert.^2));
mean_cf = meancounts./(insert_scanned_act.*ScanDur);
sigma_cf = sqrt(((1./(insert_scanned_act.*ScanDur)).^2).*(stdcounts.^2) + ((-meancounts./(ScanDur.*(insert_scanned_act.^2))).^2).*(insert_scanned_act_sigma.^2));