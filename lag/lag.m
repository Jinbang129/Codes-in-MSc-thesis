SMST=xlsread('.\lag.xls','1h','L2212:Z5187');


%%  -3
%%%%%%%
Dsm3=SMST(:,2);
DT3=SMST(:,3);
i=0;
for j=1:size(SMST,1)
if (Dsm3(j)~=0)
    i=i+1;
    DSM3i(i)=Dsm3(j);
    DT3i(i)=DT3(j);
end
end
figure;
p3=plot(DT3i,DSM3i,'s','markersize',3);
ylabel('LSWC (m^3 m^-3)');
xlabel('Dfference of ST (°„C)');
    xlim([-4 5]);
    ylim([0.05 0.08]);
    title('1 h');
    hold on;
f = polyfit(DT3i,DSM3i,1);
xi=-3:0.001:4;
yi=polyval(f,xi);
plot(xi,yi,'linewidth',0.5,'markersize',3,'color','k');
hold on;

%%  -4
%%%%%%%
Dsm4=SMST(:,5);
DT4=SMST(:,6);
i=0;
for j=1:size(SMST,1)
if (Dsm4(j)~=0)
    i=i+1;
    DSM4i(i)=Dsm4(j);
    DT4i(i)=DT4(j);
end
end
p4=plot(DT4i,DSM4i,'+','markersize',3);
    hold on;
f = polyfit(DT4i,DSM4i,1);
xi=-3:0.001:4;
yi=polyval(f,xi);
plot(xi,yi,'linewidth',0.5,'markersize',3,'color','k');
hold on;

%%  -5
%%%%%%%
Dsm5=SMST(:,8);
DT5=SMST(:,9);
i=0;

for j=1:size(SMST,1)
if (Dsm5(j)~=0)
    i=i+1;
    DSM5i(i)=Dsm5(j);
    DT5i(i)=DT5(j);
end
end


p5=plot(DT5i,DSM5i,'o','markersize',3);
hold on;
f = polyfit(DT5i,DSM5i,1);
xi=-3:0.001:4;
yi=polyval(f,xi);
plot(xi,yi,'linewidth',0.5,'markersize',3,'color','k');
hold on;

%%  -6
%%%%%%%
Dsm6=SMST(:,11);
DT6=SMST(:,12);
i=0;
for j=1:size(SMST,1)
if (Dsm6(j)~=0)
    i=i+1;
    DSM6i(i)=Dsm6(j);
    DT6i(i)=DT6(j);
end
end
p6=plot(DT6i,DSM6i,'x','markersize',3);
hold on;
f = polyfit(DT6i,DSM6i,1);
xi=-3:0.001:4;
yi=polyval(f,xi);
plot(xi,yi,'linewidth',0.5,'markersize',3,'color','k');
hold on;

%  -7
%%%%%%%
Dsm7=SMST(:,14);
DT7=SMST(:,15);
i=0;
for j=1:size(SMST,1)
if (Dsm7(j)~=0)
    i=i+1;
    DSM7i(i)=Dsm7(j);
    DT7i(i)=DT7(j);
end
end
p7=plot(DT7i,DSM7i,'*','markersize',3);
hold on;
f = polyfit(DT7i,DSM7i,1);
xi=-3:0.001:4;
yi=polyval(f,xi);
plot(xi,yi,'linewidth',0.5,'markersize',3,'color','k');
hold on;


legend([p3,p4,p5,p6,p7],'-3','-4','-5','-6','-7');
hold on;


a=[DT5i,DT4i,DT6i,DT7i];
b=[DSM5i,DSM4i,DSM6i,DSM7i];
% f = polyfit(a,b,1);
% xi=-2.5:0.001:3.7;
% yi=polyval(f,xi);
% plot(xi,yi,'linewidth',0.5,'markersize',3,'color','k');
% text(0.1,-0.003,' y = 0.005031*x - 0.00002238');
% text(0.3,-0.005,'R2 = 0.8753');
% line([0,0],[1 ,-1],'linestyle',':','color','k');
% line([-10,10],[0,0],'linestyle',':','color','k');