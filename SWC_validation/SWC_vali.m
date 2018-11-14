% This is a program to optimalize the K calue from the relationship between
% soil temperature and liquid soil water content(w_u=w_a+ (w_o-w_a )exp?(-k?))
% Kvalue_optimalization- Version 1.0 by Jinbang Peng 2017/01/13
% Parts of code copied from Re_COSMIC

%=================================================================================
% Read in parameter file
%=================================================================================

% fid = fopen('.\Re_cosmic_parlist','r');
% parameters=textscan(fid,'%f%s','Delimiter','%');            %parameters loaded the paramenters values and their comments
nlayers= 1000;%parameters{1,1}(1);                                 %Total number of soil layers
bd=1.063307;%parameters{1,1}(2);                                      %Dry soil bulk density (g/m3)
vwclat=0.07 ;%parameters{1,1}(3);                                  %Volumetric "lattice" water content (m3/m3)
%alpha=parameters{1,1}(4);                                  %Ratio of Fast Neutron Creation Factor (Soil to Water), alpha (-)
alpha=0.404-0.101*bd;
L1=161.98621864;%parameters{1,1}(5);                                      %High Energy Soil Attenuation Length (g/cm2)
L2=129.14558985;%parameters{1,1}(6);                                      %High Energy Water Attenuation Length (g/cm2)
%L3=parameters{1,1}(7);                                     %Fast Neutron Soil Attenuation Length (g/cm2)
L3=-31.65+99.29*bd;
L4=3.1627190566;%parameters{1,1}(8);                                      %Fast Neutron Water Attenuation Length (g/cm2)
N=671.2447;%parameters{1,1}(9);                                       %¡°fast-neutron creation¡± constant for pure water, C (-)
%wa=0.19960344;%parameters{1,1}(10);                                     %unfrozen soil water content parameter
%n=parameters{1,1}(11);                                      %unfrozen soil water content parameter
fprintf('1.parameter input is finished!\n');
%=================================================================================

%=================================================================================
% Input the point measurement results to model
%=================================================================================
%OP=xlsread('.\Kvalue.xlsx','Sheet1','B2:E2994'); 
%nprof=size(OP,1);
SM_l1=importdata('.\l1.txt','r');
SM_l2=importdata('.\l2.txt','r');
SM_l3=importdata('.\l3.txt','r');
SM_l4=importdata('.\l4.txt','r');%OP(:,1);            %soil water content from point mesurement
% NTS_TEM=importdata('.\NTS_TEM.txt','r');%OP(:,2);            %Soil temperature from point mesurement
Ncor=importdata('.\Ncor.txt','r');%OP(:,3);               %corrected neutron counts
nprof=size(SM_l1,1);

tran1=ones(1,70);
tran2=ones(1,80);
tran3=ones(1,250);
tran4=ones(1,600);
vwc1=(SM_l1*tran1)';
vwc2=(SM_l2*tran2)';
vwc3=(SM_l3*tran3)';
vwc4=(SM_l4*tran4)';
vwc= [vwc1;vwc2;vwc3;vwc4];%Soil moisture of each layer (m3/m3)
dz=(1:nlayers)';                 %Soil layers (cm)
fprintf('2.input data file reading is finished!\n');
%=================================================================================

%=================================================================================
%initialization of variables
%=================================================================================
h2odens=1000.0;   % Density of water (g/cm3)
wetsoidens=zeros(nlayers,nprof);
wetsoimass=zeros(nlayers,nprof);
iwetsoimass=zeros(nlayers,nprof);
isoimass=zeros(nlayers,nprof);
iwatmass=zeros(nlayers,nprof);
itotalwatmass=zeros(nlayers,nprof);
hiflux=zeros(nlayers,nprof);
fastpot=zeros(nlayers,nprof);
h2oeffmass=zeros(nlayers,nprof);
iceeffmass=zeros(nlayers,nprof);
ih2oeffmass=zeros(nlayers,nprof);
idegrad=zeros(nlayers,nprof);
fastflux=zeros(nlayers,nprof);
normfast=zeros(nlayers,nprof);
inormfast=zeros(nlayers,nprof);
totflux=zeros(1,nprof);
fprintf('3.variables initialization is finished!\n');
%=================================================================================

%=================================================================================
% Model calculation
%=================================================================================
% Soil layer thickness
zthick(1)=dz(1)-0.0;                %Surface layer

zthick(2:nlayers)=dz(2:nlayers)-dz(1:nlayers-1);    %Remaining layers

%Angle distribution parameters (HARDWIRED)
ideg=0.5;                           %ideg ultimately controls the number of trips through
angledz=round(ideg*10.0);           %the ANGLE loop. Make sure the 10.0 is enough
maxangle=900-angledz;               %to create integers with no remainder
dtheta=ideg*(pi/180.0);

 if angledz ~= ideg*10.0
     error('ideg*10.0 must result in an integer - it results in:%f',angledz);
 end     

%High energy neutron downward flux
%The integration is now performed at the node of each layer (i.e., center of the layer)
h2oeffdens=((vwc+vwclat)*h2odens)/1000.0;  

for j = 1:nprof
    for i=1:nlayers
        if(i > 1) 
            % Assuming an area of 1 cm2
            isoimass(i,j)=isoimass(i-1,j)+bd*(0.5*zthick(i-1))*1.0+bd*(0.5*zthick(i))*1.0;
            %Assuming an area of 1 cm2
            iwatmass(i,j)=iwatmass(i-1,j) + h2oeffdens(i-1,j)*(0.5*zthick(i-1))*1.0+ h2oeffdens(i,j)*(0.5*zthick(i))*1.0;
        else
            %Assuming an area of 1 cm2
            isoimass(i,j) = bd*(0.5*zthick(i))*1.0;
            iwatmass(i,j) = h2oeffdens(i,j)*(0.5*zthick(i))*1.0;
        end
        
        hiflux(i,j)  = N*exp(-(isoimass(i,j)/L1 + iwatmass(i,j)/L2) );
        fastpot(i,j) = zthick(i)*hiflux(i,j)*(alpha*bd + h2oeffdens(i,j));

        %This second loop needs to be done for the distribution of angles for fast neutron release
        %the intent is to loop from 0 to 89.5 by 0.5 degrees - or similar.
        %Because Fortran loop indices are integers, we have to divide the indices by 10 - you get the idea.  

        for angle=0:angledz:maxangle
            zdeg     = angle/10.0;   % 0.0  0.5  1.0  1.5 ...
        	zrad     = zdeg*pi/180.0;
        	costheta = cos(zrad);
        
        %Angle-dependent low energy (fast) neutron upward flux
        fastflux(i,j) = fastflux(i,j) + fastpot(i,j)*exp(-(isoimass(i,j)/L3 + iwatmass(i,j)/L4)/costheta)*dtheta;
        end

        %After contribution from all directions are taken into account,
        %need to multiply fastflux by 2/PI
        fastflux(i,j) = (2.0/pi)*fastflux(i,j);
        
        %Low energy (fast) neutron upward flux,
        totflux(j) = totflux(j) + fastflux(i,j);
    end
 
    % These quantities need to be calculated after totflux is being computed
    for i = 1:nlayers
        normfast(i,j) = fastflux(i,j)/totflux(j);
    end
end
fprintf('4.model calculation is finished!\n');
%=================================================================================

%=================================================================================
% Output file
%=================================================================================
% Write to output matrix
 output_data=zeros(1+nlayers,1+nprof);
 % First row is for Total flux (9999. is a dummy value)
 output_data(1,1)=9999;
%Next rows are for weighting factors by soil layer
output_data(1,2:nprof+1)=totflux;
output_data(2:nlayers+1,1)=dz;
output_data(2:nlayers+1,2:nprof+1)=normfast;

%write to output file
save('.\output.dat','output_data','-ascii');
fprintf('5.result output is finished!\n');
fprintf('Great! COSMIC is finished!^_^\n');
%=================================================================================