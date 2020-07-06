clear all
dir_name='D:\submission paper\DAT__NRG3\Figure18_FSCV\';
data=xlsread('Raw_trace.xlsx');
Time=data(:,1);
ckodata=data(:,2:6);
cko1=ckodata(:,1)/349.333*1000;
cko2=ckodata(:,2)/304.66*1000;
cko3=ckodata(:,3)/232.3*1000;
cko4=ckodata(:,4)/439.3*1000;
cko5=ckodata(:,5)/250*1000;
ckodata1=[cko1 cko2 cko3 cko4 cko5];
condata=data(:,7:11);
con1=condata(:,1)/345.3*1000;
con2=condata(:,2)/238.6*1000;
con3=condata(:,3)/420*1000;
con4=condata(:,4)/221.6*1000;
con5=condata(:,5)/240.6*1000;
condata1=[con1 con2 con3 con4 con5]
cko_mean=mean(ckodata1,2);
con_mean=mean(condata1,2);
cko_ste=ste(ckodata1,2);
con_ste=ste(condata1,2);

figure
shadedErrorBar(Time,cko_mean,cko_ste')
hold on
shadedErrorBar2(Time,con_mean,con_ste')
xlabel('Time (s)','fontsize',25)%%% fontsize
ylabel('DA (nM)','fontsize',25)
%xlim([-10,12]) %%%seting x axis range
%set(gca,'XTick',[-10:2:12]) %
%set(gca,'fontsize',20) %%%cui added the font size of the number on the x and y axis
print(gcf,'-dtiff','-r600',[dir_name,'evoked_DA.tif']) %%%DPI 600

