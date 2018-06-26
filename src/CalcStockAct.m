function [stock_scanned_act] = CalcStockAct(stock_act,stock_res,res_time,stock_time,acq_time,tau)
res_time_elapsed = res_time-stock_time;
stock_total_act = stock_act.*exp(-res_time_elapsed./tau) - stock_res;
time_elapsed = acq_time-res_time;
stock_scanned_act = stock_total_act.*exp(-time_elapsed./tau);