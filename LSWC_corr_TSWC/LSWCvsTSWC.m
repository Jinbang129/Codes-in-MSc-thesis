%THis is a program for filter the liquid soil water content at specific
%temperature from point measurment; and compare it with total soil water
%content from cosmic-ray neutron soil water content method

%%Input point measuring data
SMST=xlsread('.\SMST.xlsx','Sheet1','A5:K3967');
Time=SMST(:,1);
SM1=SMST(:,2);
ST1=SMST(:,3);
% SM2=SMST(:,4);
% ST2=SMST(:,5);
% SM3=SMST(:,6);
% ST3=SMST(:,7);

%%Input cosmic-ray neutron soil water content
N_SM=xlsread('.\SMST.xlsx','Sheet2','A1:C3957');
TimeN=N_SM(:,1);
TSWC=N_SM(:,3);

%%Plot point measuring soil temperature and soil water content at 5 cm 
figure;
plot(ST1,SM1,'.');

% mat=zeros(200,40);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-1°C~-10°C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 for count=1:6
    T(count)=-count-1;
    i=0;
    for j=1:size(SMST,1)
         if(ST1(j) == T(count))
             i=i+1;
             mat(i,4*count-3)=Time(j);
             mat(i,4*count-2)=SM1(j);
         end
    end
    n=1;
    recor4=0;
    for m=1:i
        while (n<=size(TSWC,1))
            if(mat(m,4*count-3)-N_SM(n,1)<0.00347222222626442&&mat(m,4*count-3)-N_SM(n,1)>-0.00347222222626442)
                mat(m,4*count-1)=TSWC(n);
                mat(m,4*count)=TimeN(n);
                recor4=recor4+1;
                n=n+1;
            elseif(mat(m,4*count-3)-N_SM(n,1)<-0.00347222222626442)
                break;
            else
                n=n+1;
            end
        end
    end
    p(count)=plot( mat(:,4*count-2),mat(:,4*count-1),'.');
    xlabel('LSWC');
    ylabel('TSWC');
    title('Soil temperature');
    xlim([0.05 0.1]);
    ylim([0.2 0.35]);
    hold on;
 end
	legend([p(1),p(2),p(3),p(4),p(5),p(6)],'-2','-3','-4','-5','-6','-7');

% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %-4°C
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i=0;
% for j=1:size(SMST,1)
%     if(ST1(j) == -4)
%      i=i+1;
%      mat(i,2)=SM1(j);
%      mat(i,1)=Time(j);
%     end
% end
% 
% n=1;
% recor4=0;
% for m=1:i
%     while (n<=size(TSWC,1))
%         if(mat(m,1)-N_SM(n,1)<0.00347222222626442&&mat(m,1)-N_SM(n,1)>-0.00347222222626442)
%             mat(m,3)=N_SM(n,2);
%             mat(m,4)=N_SM(n,1);
%             recor4=recor4+1;
%             n=n+1;
%         elseif(mat(m,1)-N_SM(n,1)<-0.00347222222626442)
%             break;
%         else
%             n=n+1;
%         end
%     end
% end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %-4.5°C
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i=0;
% for j=1:5088
%     if(ST1(j) == -4.5)
%      i=i+1;
%      m45(i,2)=SM1(j);
%      m45(i,1)=Time(j);
%     end
% end
% 
% n=1;
% recor45=0;
% for m=1:i
%     while (n<=3957)
%         if(m45(m,1)-N_SM(n,1)<0.00347222222626442&&m45(m,1)-N_SM(n,1)>-0.00347222222626442)
%             m45(m,3)=N_SM(n,2);
%             m45(m,4)=N_SM(n,1);
%             recor45=recor45+1;
%             n=n+1;
%         elseif(m45(m,1)-N_SM(n,1)<-0.00347222222626442)
%             break;
%         else
%             n=n+1;
%         end
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %-5°C
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i=0;
% for j=1:5088
%     if(ST1(j) == -5)
%      i=i+1;
%      m5(i,2)=SM1(j);
%      m5(i,1)=Time(j);
%     end
% end
% 
% n=1;
% recor5=0;
% for m=1:i
%     while (n<=3957)
%         if(m5(m,1)-N_SM(n,1)<0.00347222222626442&&m5(m,1)-N_SM(n,1)>-0.00347222222626442)
%             m5(m,3)=N_SM(n,2);
%             m5(m,4)=N_SM(n,1);
%             recor5=recor5+1;
%             n=n+1;
%         elseif(m5(m,1)-N_SM(n,1)<-0.00347222222626442)
%             break;
%         else
%             n=n+1;
%         end
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %-5.5°C
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i=0;
% for j=1:5088
%     if(ST1(j) == -5.5)
%      i=i+1;
%      m55(i,2)=SM1(j);
%      m55(i,1)=Time(j);
%     end
% end
% 
% n=1;
% recor55=0;
% for m=1:i
%     while (n<=3957)
%         if(m55(m,1)-N_SM(n,1)<0.00347222222626442&&m55(m,1)-N_SM(n,1)>-0.00347222222626442)
%             m55(m,3)=N_SM(n,2);
%             m55(m,4)=N_SM(n,1);
%             recor55=recor55+1;
%             n=n+1;
%         elseif(m55(m,1)-N_SM(n,1)<-0.00347222222626442)
%             break;
%         else
%             n=n+1;
%         end
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %-6°C
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i=0;
% for j=1:5088
%     if(ST1(j) == -6)
%      i=i+1;
%      m6(i,2)=SM1(j);
%      m6(i,1)=Time(j);
%     end
% end
% 
% n=1;
% recor6=0;
% for m=1:i
%     while (n<=3957)
%         if(m6(m,1)-N_SM(n,1)<0.00347222222626442&&m6(m,1)-N_SM(n,1)>-0.00347222222626442)
%             m6(m,3)=N_SM(n,2);
%             m6(m,4)=N_SM(n,1);
%             recor6=recor6+1;
%             n=n+1;
%         elseif(m6(m,1)-N_SM(n,1)<-0.00347222222626442)
%             break;
%         else
%             n=n+1;
%         end
%     end
% end
