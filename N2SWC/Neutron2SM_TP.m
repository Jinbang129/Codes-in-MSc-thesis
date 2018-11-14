%% Cat txt files
[fname] =uigetfile('*.638', 'MultiSelect','on');

outfid = fopen('all_Data.txt', 'wt');
for j = 1 : length(fname) 
    CC=importdata(fname, ',', 13);
    fwrite(outfid, CC.);
    Varnames=strsplit(CC.textdata{12,1}, ',');
end
fclose(outfid) 


%%
% clear all;
% clc

%% Raw Data
CC=importdata('E:\ITC\topics\20160606\1606010001.638', ',', 13);
Varnames=strsplit(CC.textdata{12,1}, ',');

%%
% col1   -> P4_mb: pressure sensor 1 (more reliable, less affected by temperature)
% col2   -> P1_mb: pressure sensor 2 (if available)
% col3   -> T1_C: internal temperature
% col4   -> RH1: internal relative humidity
% col5   -> T_CS215: external temperature (if available)
% col6   -> RH_CS215: external relative humidity (if available)
% col7   -> Vbat: input voltage
% col8   -> N1Cts: moderated detector counts
% col9   -> N2Cts: bare detector counts
% col10 -> N1ET_sec: elapsed time Tube 1
% col11 -> N2ET_sec: elapsed time Tube 2
% col12 -> N1T_C: external temperature Tube 1
% col13 -> N1RH: external relative humidity Tube 1
% col14 -> N2T_C: external temperature Tube 2
% col15 -> N2RH: external relative humidity Tube 2
%%
Rcd_data=CC.data;
N_rcd=Rcd_data(:,8);
P_rcd=Rcd_data(:,1);
Ta_rcd=Rcd_data(:,5);
RH_rcd=Rcd_data(:,6);


%% Constants
name        ='Maqu'; %
lat            =dms2degree(33, 54, 59.55);  % N
lon            =dms2degree(102, 09, 32.5);  % E
elev          =3436;  % m
tZone        =8;  % hours
% atmospheric constants
Beta      =0.0077;  % unit =hPa^-1, Attenuation Coefficient
k           =216.68;  % g k J^-1, Gas constant for water Vapor
% Reference conditions
P0         =669.27;  % hPa, Air Pressure P0
N0         =2609*7.44; %2887.315*0.5;  % counts h^-1, Theoretical dry counting rate N0, calibrated from Goor field Experiment
% Calibration Sampling Results
theta_g       =0.276;  % kg kg^-1, gravimetric water content
pho_b         =0.82;  % g cm^-3, soil bulk density
theta_lw      =0.001;   % kg kg^-1, clay lattice water
theta_soc    =0.024; % kg kg^-1, soil organic carbon
biomass_wet =0.7146;  % kg m^-2, standing wet biomass
biomass_dry  =0.2;  % kg m^-2, standing dry bimass
N                =845.6;  % counts h^-1, corrected neutron counting rate, average over 6 hr period during calibration sampling
% Calibration function
a0               =0.0808; %0.0808;  %
a1               =0.372;  %
a2               =0.115;  %
%% Correction Factors

f_bar       = exp((Beta.*(P_rcd-P0)));
e_w         = 6.112.*(exp((17.62.*Ta_rcd)./(243.12+Ta_rcd)));
AH          = (RH_rcd./100).*(e_w.*k./(Ta_rcd+273.15));
f_hum      = 1+(0.0054.*AH);

f_sol_fac=importdata('solar.csv', ',', 1);

f_sol        =1.02;

F_total     =f_bar.*f_hum.*f_sol;

% Corrected moderated counting rate
N_corr=N_rcd.*F_total;

% Final SM data (1hr average)
SWC_1hr=pho_b.*(((a0./(N_corr./N0-a1)-a2))-theta_lw-theta_soc);
Sigma_1hr=(a0.*N0.*sqrt(N_corr))./(N_corr-a1.*N0).^2;

SWC_raw=SWC_1hr(4:end);
N_corr_Count=N_corr(4:end);

AvgBase=12; % 4*15mins=1hr
for i=1:floor(length(SWC_raw)/AvgBase)
    SWC_raw_hr(i)=mean(SWC_raw(1+AvgBase*(i-1):AvgBase+AvgBase*(i-1)));
    N_corr_Count_hr(i)=mean(N_corr_Count(1+AvgBase*(i-1):AvgBase+AvgBase*(i-1)));
end

%%
figure; subplot(2,1,1)
plot(SWC_raw_hr);
title('Calculated SM')
subplot(2,1,2);
plot(N_corr_Count_hr);
title('Neutron Counts')

figure;
plot(SWC_raw_hr, N_corr_Count_hr)
