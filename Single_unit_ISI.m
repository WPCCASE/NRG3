clear all,
dir_name='H:/matlab_cui/SingleUnit/'
clu2=load('All.clu.1');
det=load('All.det.1');
clu3=clu2(2:end,1);
spike=[det clu3];
spiketime= spike(find(spike(:,2)==5),1); 
isi_vect=diff(spiketime)*1000;
figure
histogram(isi_vect,500,'DisplayStyle','bar','FaceColor','k','EdgeColor','k','EdgeAlpha',1)
xlabel('Time (s)','fontsize',20);
xlabel('ISI (ms)')
xlim ([0 200])

ylabel('Cell', 'Color', 'black','fontsize',20);
ylabel('Number of events')
print(gcf,'-dmeta',[dir_name,'ISI.emf']) %%%DPI 600

