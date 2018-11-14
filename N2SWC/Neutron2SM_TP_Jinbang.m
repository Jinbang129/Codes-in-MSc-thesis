% This program is revised from Neutron2SM_TP.m
% Version 1.0 by Peng Jinbang 2016/11/11
% The function of this program is calculating Soil Water Content from RCP Data and Solar Factor

%%% 1.Choose the CRP file
[fname,pathname] =uigetfile('*.638', 'MultiSelect','on');
if isequal(fname,0)
    error('No CRP file selected.');
elseif ~iscell(fname)  
   filename1{1}=fname;  
else  
   filename1=fname;  
end  

%%% 2.Read CRP file and its size
outfid = fopen('all_Data.txt', 'w');
datasize=zeros(length(filename1),2);
row=0;
column=0;
for j = 1 : length(filename1)
    fullname=strcat(pathname,filename1{j});  
    CRP(j)=importdata(fullname, ',', 13);
    if isequal(j,1)
        Varnames=strsplit(CRP(j).textdata{12,1}, ',');
       %fwrite(outfid, Varnames);
       %fwrite(outfid, CRP(j).textdata{12,1});
    end
%      fwrite(outfid, CRP(j).data);
%     alldata(1,1:length(Varnames))=Varnames{1:length(Varnames)};
%     alldata[,1:length(Varnames)]=CRP(j).data;
    fprintf(outfid,'%s', CRP(j).data);
    datasize(j,:)=size(CRP(j).data);
    textsize(j,:)=size(CRP(j).textdata);
    if ~isequal((textsize(j,:)-datasize(j,:)),[12,-13])
        error('Incorrect CRP file format!');
    else
    row= datasize(j,1)+row;
    column=max(datasize(j,2),column);
    end
end

%%% 3.Choose the solar factor file
[fname_sol,pathname_sol] =uigetfile({'*.csv;*.xlsx'}, 'MultiSelect','off');
if isequal(fname,0)
    error('No solar factor file selected.');
else  
    fullname_sol=strcat(pathname_sol,fname_sol);
end 

%%% 4.read solar factor file and transform it to an array
f_sol_file=importdata(fullname_sol);
row_sol=length(f_sol_file.textdata);
    Num_ftime=zeros(row_sol-1,6);  % The first row is the title, so it should be deducted.
    for k=1:(row_sol-1)
        Num_ftime(k,:)=datevec(f_sol_file.textdata(k+1,1));
%         Char_ftime=char(f_sol_file.textdata(k+1,1));
%         Num_ftime(k,1)=str2num(Char_ftime([1:4,6:7,9:10,12:13,15:16]));
    
        Allsolar(1:(row_sol-1),7)=f_sol_file.data;
        Allsolar(1:row_sol-1,1:6)=Num_ftime;
    end

% [row_f,column_f]=size(f_sol_file.textdata);

% %%%integrate CRP and solar factor file into one array
% Alldata=zeros(row,column+1);    %Add 1 more column here for RCP time
% % Alldata=(CRP(1).data:CC(length(filename1)).data);
% row_new=0;

row_new=0;
for i = 1 : length(filename1)
    
    %transform CRP time into an array
    Num_time=zeros(length(CRP(i).textdata)-12,6);
    for k=1:length(CRP(i).textdata)-12
        Num_time(k,:)=datevec(CRP(i).textdata(k+12,2));
%         Char_time=char(CRP(i).textdata(k+12,2));
%         Num_time(k,1)=str2num(Char_time([1:4,6:7,9:10,12:13,15:16]));
    end
    
    if isequal(i,1)
        Alldata(1:datasize(i,1),7:column+6)=CRP(i).data;
        Alldata(1:datasize(i,1),1:6)=Num_time;
    else
        Alldata((row_new+1:row_new+datasize(i,1)),7:column+6)=CRP(i).data;
        Alldata((row_new+1:row_new+datasize(i,1)),1:6)=Num_time;
    end
    row_new=row_new+datasize(i,1);
end

fwrite(outfid, Alldata);
fclose(outfid);

%%% 5. assign the solar factor to the RCP according to the time
Solar_missing_count=0;
site_record=1;
flag=0;
for ii=1:row
    if isequal(flag,1)
        break;
    end
    for jj=site_record:row_sol-1
        interval=etime(Alldata(ii,1:6),Allsolar(jj,1:6));
        if  (interval<3600 && interval>=0)
            Alldata(ii,22)=Allsolar(jj,7);
            break;
        elseif interval<0
            Alldata(ii,22)=1.0;
            Solar_missing_count=Solar_missing_count+1;
            No_solar_time(Solar_missing_count,:)=Alldata(ii,1:6); 
            break;
        elseif isequal(jj,row_sol-1)
            Alldata(ii:end,22)=1.0;
            Solar_missing_count=Solar_missing_count+1;
            No_solar_time(Solar_missing_count:Solar_missing_count+row-ii,:)=Alldata(ii:row,1:6);
            Solar_missing_count=Solar_missing_count+row-ii;
            flag=1;
            break;
        end
    end
    site_record=jj;
 end



%% Raw Data
% CRP=importdata('E:\ITC\topics\20160606\1606010001.638', ',', 13);
% Varnames=strsplit(CC.textdata{12,1}, ',');

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
% col10  -> N1ET_sec: elapsed time Tube 1
% col11  -> N2ET_sec: elapsed time Tube 2
% col12  -> N1T_C: external temperature Tube 1
% col13  -> N1RH: external relative humidity Tube 1
% col14  -> N2T_C: external temperature Tube 2
% col15  -> N2RH: external relative humidity Tube 2


%%% 6.Neutron counts correction
% Rcd_data=CC.data;
N_rcd=Alldata(:,14);
P_rcd=Alldata(:,7);
Ta_rcd=Alldata(:,11);
RH_rcd=Alldata(:,12);
f_sol=Alldata(:,22);

%%% 6.1Fliter for ecluding abnormal neutron counts from the probe initialization
for kk=(row-1):-1:1
    if N_rcd(kk)<1000
        N_rcd(kk)=N_rcd(kk+1);
    end
end

%%% 6.2 Constants
name        ='Maqu'; %
lat            =dms2degree(33, 54, 59.55);  % N
lon            =dms2degree(102, 09, 32.5);  % E
elev          =3436;  % m
tZone        =8;  % hours
% atmospheric constants
Beta      =0.0077;  % unit =hPa^-1, Attenuation Coefficient
k           =216.68;  % g k J^-1, Gas constant for water Vapor
R_sol       =0.4;   %Solar factor corection Coefficient
% Reference conditions
P0         =672.8073684;%669.27;  % hPa, Air Pressure P0
N0         =3751.2734;%2609*7.44; %2887.315*0.5;  % counts h^-1, Theoretical dry counting rate N0, calibrated from Goor field Experiment
% Calibration Sampling Results
theta_g       =0.316;%0.276;  % kg kg^-1, gravimetric water content
pho_b         =1.063307;%0.82;  % g cm^-3, soil bulk density
theta_lw      =0;%0.001;   % kg kg^-1, clay lattice water
theta_soc    =0.04;%0.024; % kg kg^-1, soil organic carbon
biomass_wet =0.714555556;%0.7146;  % kg m^-2, standing wet biomass
biomass_dry  =0.2;  % kg m^-2, standing dry bimass
N                =2009.2760;%845.6;  % counts h^-1, corrected neutron counting rate, average over 6 hr period during calibration sampling
% Calibration function
a0               =0.0808; %0.0808;  %
a1               =0.372;  %
a2               =0.115;  %
%% Correction Factors

f_bar       = exp((Beta.*(P_rcd-P0)));
e_w         = 6.112.*(exp((17.62.*Ta_rcd)./(243.12+Ta_rcd)));
AH          = (RH_rcd./100).*(e_w.*k./(Ta_rcd+273.15));
f_hum       = 1+(0.0054.*AH);
f_sol_cor   =(f_sol-1).*R_sol+1;%Solar factor correction

%f_sol        =1.02;

F_total     =f_bar.*f_hum.*f_sol_cor;

% Corrected moderated counting rate
N_corr=N_rcd.*F_total;

% Final SM data (15 min average)
SWC_15min=pho_b.*(((a0./(N_corr./N0-a1)-a2))-theta_lw-theta_soc);
Sigma_15min=(a0.*N0.*sqrt(N_corr))./(N_corr-a1.*N0).^2;

SWC_raw=SWC_15min(18:end);
N_corr_Count=N_corr(18:end);

AvgBase=12; % 4*15mins=1hr
for i=1:floor(length(SWC_raw)/AvgBase)
    SWC_raw_hr(i)=mean(SWC_raw(1+AvgBase*(i-1):AvgBase+AvgBase*(i-1)));
    N_corr_Count_hr(i)=mean(N_corr_Count(1+AvgBase*(i-1):AvgBase+AvgBase*(i-1)));
end

%%% 7.Present the results
figure;
subplot(2,1,1)
plot(SWC_raw_hr);
title('Calculated SM')
subplot(2,1,2);
plot(N_corr_Count_hr);
title('Neutron Counts')

figure;
subplot(2,1,1)
plot(SWC_raw);
title('Calculated SM')
subplot(2,1,2);
plot(N_corr_Count);
title('Neutron Counts')

figure;
plot(SWC_raw_hr, N_corr_Count_hr)

figure;
plot(SWC_raw, N_corr_Count)
