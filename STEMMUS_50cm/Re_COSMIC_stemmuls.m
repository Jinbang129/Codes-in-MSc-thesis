% This is a program translated from fortran program COsmic-ray Soil
% Moisture Interaction Code (COSMIC) in FORTRAN - Version 1.5 by W. James Shuttlewort 
% and Rafael Rosolem
% Re_COSMIC in matlab version 1.0 by Peng Jinbang 2016/10/17
% The function of this program is to assimilat data from cosmic ray
% neutron probe

%=================================================================================
% Read in parameter file
%=================================================================================

fid = fopen('.\Re_cosmic_parlist','r');
parameters=textscan(fid,'%f%s','Delimiter','%');            %parameters loaded the paramenters values and their comments
nlayers=parameters{1,1}(1);                                 %Total number of soil layers
nprof=parameters{1,1}(2);                                   %Total number of soil moisture profiles
bd=parameters{1,1}(3);                                      %Dry soil bulk density (g/m3)
vwclat=parameters{1,1}(4);                                  %Volumetric "lattice" water content (m3/m3)
Nhe=parameters{1,1}(5);                                     %High energy neutron flux (-)
%alpha=parameters{1,1}(6);                                  %Ratio of Fast Neutron Creation Factor (Soil to Water), alpha (-)
alpha=0.404-0.101*bd;
L1=parameters{1,1}(7);                                      %High Energy Soil Attenuation Length (g/cm2)
L2=parameters{1,1}(8);                                      %High Energy Water Attenuation Length (g/cm2)
%L3=parameters{1,1}(9);                                     %Fast Neutron Soil Attenuation Length (g/cm2)
L3=-31.65+99.29*bd;
L4=parameters{1,1}(10);                                     %Fast Neutron Water Attenuation Length (g/cm2)
C=parameters{1,1}(11);                                  %Soil temperature 
delta=parameters{1,1}(12);                                      %¡°fast-neutron creation¡± constant for pure water, C (-)
fi=parameters{1,1}(13);                                     %unfrozen soil water content parameter
k=parameters{1,1}(14);                                      %unfrozen soil water content parameter
N=parameters{1,1}(15);
fprintf('1.parameter input is finished!\n');
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
fprintf('2.variables initialization is finished!\n');
%=================================================================================

%=================================================================================
% Read in input file
%=================================================================================
TSWC1=xlsread('.\STEMMUS_50cm.xlsx','Sheet1','A1:AK5040');
TSWC=TSWC1';
[n_layer,n_prof]=size(TSWC);
vwc=TSWC(1:n_layer,2:n_prof);   %Soil moisture of each layer (m3/m3)
dz=TSWC(1:nlayers,1);                 %Soil layers (cm)
fprintf('3.input data file reading is finished!\n');
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
iceeffdens=h2oeffdens*0.9;
%N=Nhe*C;

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
        itotalwatmass(i,j) = iwatmass(i,j)*(fi+(1-fi )/exp(-k*delta));
        hiflux(i,j)  = N*exp(-(isoimass(i,j)/L1 + itotalwatmass(i,j)/L2) );
        fastpot(i,j) = zthick(i)*hiflux(i,j)*(alpha*bd + h2oeffdens(i,j));
        
        %hiflux(i,j)  = N*exp(-(isoimass(i,j)/L1 + iwatmass(i,j)/(L2*(fi+(1-fi )*exp(-k*delta)))));
        %fastpot(i,j) = zthick(i)*hiflux(i,j)*(alpha*bd + h2oeffdens(i,j)+iceeffdens(i,j));

        %This second loop needs to be done for the distribution of angles for fast neutron release
        %the intent is to loop from 0 to 89.5 by 0.5 degrees - or similar.
        %Because Fortran loop indices are integers, we have to divide the indices by 10 - you get the idea.  

        for angle=0:angledz:maxangle
            zdeg     = angle/10.0;   % 0.0  0.5  1.0  1.5 ...
        	zrad     = zdeg*pi/180.0;
        	costheta = cos(zrad);
        
        %Angle-dependent low energy (fast) neutron upward flux
        fastflux(i,j) = fastflux(i,j) + fastpot(i,j)*exp(-(isoimass(i,j)/L3 + itotalwatmass(i,j)/L4)/costheta)*dtheta;
        %fastflux(i,j) = fastflux(i,j) + fastpot(i,j)*exp(-(isoimass(i,j)/L3 + iwatmass(i,j)/(L4*(fi+(1-fi )*exp(-k*delta))))/costheta)*dtheta;
        end

        %After contribution from all directions are taken into account,
        %need to multiply fastflux by 2/PI
        fastflux(i,j) = (2.0/pi)*fastflux(i,j);
        
        %Low energy (fast) neutron upward flux
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
fprintf('Great! Re_COSMIC is finished!^_^\n');
%=================================================================================