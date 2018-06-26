function [mean_cf,sigma_cf] = Calc_cfuncert_stock(stock_act,stock_res,act_uncert,res_act_uncert,full_weight,full_weight_uncert,empty_weight,empty_weight_uncert,insert_full_weight,insert_full_weight_uncert,insert_empty_weight,insert_empty_weight_uncert,act_time,res_time,acq_time,act_time_uncert,res_time_uncert,meancounts,stdcounts,ScanDur,tau_Lu)

%% Constant factors
% hours = 60*60;
% minutes = 60;
% seconds = 1;
% tau_Lu = 230.1675668*hours;
NPL_Calibration_Sigma = 2.1/100;
Calibration_Sigma = 0.03/100; % Syringe
% Calibration_Sigma = 0.025/100; % Vial
Cs137_Sigma = 0.15/100;
Sigma_calibration = sqrt(NPL_Calibration_Sigma.^2 + Calibration_Sigma.^2 + Cs137_Sigma.^2);
%%
res_time_elapsed = res_time - act_time;
res_time_elapsed_uncert = sqrt(act_time_uncert.^2 + res_time_uncert.^2);
stock_total_act = stock_act.*exp(-res_time_elapsed./tau_Lu) - stock_res;
stock_act_sigma = act_uncert;
stock_res_sigma = res_act_uncert;
stock_total_act_sigma = sqrt((exp(-res_time_elapsed./tau_Lu).^2).*(stock_act_sigma .^2) + ((-stock_act.*exp(-res_time_elapsed./tau_Lu)./tau_Lu).^2).*(res_time_elapsed_uncert.^2) + stock_res_sigma.^2 + (stock_total_act.^2)*(Sigma_calibration.^2));

stock_vol = full_weight - empty_weight;
stock_vol_uncert = sqrt(full_weight_uncert.^2 + empty_weight_uncert.^2);
stock_total_act_conc = stock_total_act./stock_vol;
stock_total_act_conc_sigma = sqrt(((1./stock_vol).^2) .* (stock_total_act_sigma.^2) + ((-stock_total_act./(stock_vol.^2)).^2).*(stock_vol_uncert.^2));

insert_vol = insert_full_weight - insert_empty_weight;
insert_vol_uncert = sqrt(insert_full_weight_uncert.^2 + insert_empty_weight_uncert.^2);
insert_total_act = insert_vol.*stock_total_act_conc;
insert_total_act_sigma = sqrt((insert_vol.^2).*(stock_total_act_conc_sigma.^2) + (stock_total_act_conc.^2).*(insert_vol_uncert.^2));

time_elapsed = acq_time - res_time;
time_uncert = res_time_uncert;
insert_scanned_act = insert_total_act.*exp(-time_elapsed./tau_Lu);
insert_scanned_act_sigma = sqrt((exp(-time_elapsed./tau_Lu).^2).*(insert_total_act_sigma.^2) + ((-insert_total_act.*exp(-time_elapsed./tau_Lu)./tau_Lu).^2).*(time_uncert.^2));
mean_cf = meancounts./(insert_scanned_act.*ScanDur);
sigma_cf = sqrt(((1./(insert_scanned_act.*ScanDur)).^2).*(stdcounts.^2) + ((-meancounts./(ScanDur.*(insert_scanned_act.^2))).^2).*(insert_scanned_act_sigma.^2));