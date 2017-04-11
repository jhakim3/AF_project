close all
labels={'Total Fibrosis Burden','ML Region Percentage','ML in RD Area','ML Proportion in RD Area','ML in Non RD Area','Fibrosis density','Fibrosis entropy','Lesion perim.','Lesion area','Lesion perim over area','min-EFA','Euclid','Dijkstra','Borderiness, LA','Borderiness, RA','# PSs','#PSs No Duplicates','# PS clusters (e = .05)','# PS clusters (e = .1)','Lesion AR','Lesion FF','Lesion R','Lesion Con','Dijstra to };
for i=1:size(M,2)
    figure

    AT_vals=(M(find(strcmp(DAO,'AT')),i));
    AF_vals=(M(find(strcmp(DAO,'AF')),i));
    
    AT_zero_vector=zeros(length(find(strcmp(DAO,'AT'))),1);
    AF_ones_vector=ones(length(find(strcmp(DAO,'AF'))),1);
    
    %scatter(AT_zero_vector,AT_vals);
    %hold on
    %scatter(AF_ones_vector,AF_vals);
    boxplot(M(:,i),strcmp(DAO,'AF'))
    
    
    xlim([0.5,2.5])
    %xticks([0,1])
    %xticklabels({'AT','AF'})
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[{'AT','AF'}])
    ylabel(labels{i})
    
    saveas(gcf,sprintf('./figs/%s.png',labels{i}))
end



sitesToOmit=[1,2,3,5,9,18,21,23,25,27,56];
sitesToOmitAgain=[13,36,44,55,57,61];


%misc stuff
dDists=dDist{3};
dDists=reshape(dDists,73,8);
dDists=dDists(setdiff(1:length(dDists),sitesToOmit),:);
dDists=dDists(setdiff(1:length(dDists),sitesToOmitAgain),:);
%dlmwrite('C:/Workspace/dDists.txt',dDists,'delimiter','\t')
dlmwrite('C:/Workspace/dDists.txt',min(dDists(:,1:4),[],2),'delimiter','\t')

eDists=eDist{3};
eDists=reshape(eDists,73,8);
eDists=eDists(setdiff(1:length(eDists),sitesToOmit),:);
eDists=eDists(setdiff(1:length(eDists),sitesToOmitAgain),:);
%dlmwrite('C:/Workspace/eDists.txt',eDists,'delimiter','\t')
dlmwrite('C:/Workspace/eDists.txt',min(eDists(:,1:4),[],2),'delimiter','\t')



%mutual info stuff

MIs=zeros(5,5);
M_temp2=M_temp;
M_temp2(:,10)=
M_zscore=zscore(M,0,1);
indices=[10,20,21,22,23];
for i=1:5
    for j=1:5
        MIs(i,j)=mutualinfo(M_zscore(:,indices(i)),M_zscore(:,indices(j)));
    end
end










