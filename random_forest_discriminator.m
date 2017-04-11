M=dlmread('C:/Workspace/all_metrics.csv');

%M=M(:,[1 9 10 12 13]);

dynamicFile=fopen('C:/Workspace/dynamic_ablate_outcomes');
reinduceFile=fopen('C:/Workspace/reinduce_outcomes');
DAO=textscan(dynamicFile,'%s');
RIO=textscan(reinduceFile,'%s');

DAO=DAO{1};
RIO=RIO{1};

Dscore=zeros(length(M),2);
Rscore=Dscore;

for i=1:length(M)
    disp(i)
    M_temp=M;
    M_temp(i,:)=[];
    
    DAO_temp=DAO;
    DAO_temp(i,:)=[];
    
    RIO_temp=RIO;
    RIO_temp(i,:)=[];
    
%BD=stepwiseglm(M_temp,strcmp(DAO_temp,'AF'),'constant');
%BR=stepwiseglm(M_temp,strcmp(RIO_temp,'AF'),'constant');

BD=TreeBagger(1000,M_temp,strcmp(DAO_temp,'AF'));
BR=TreeBagger(1000,M_temp,strcmp(RIO_temp,'AF'));

[DPredict,Dscore(i,:)]=predict(BD,M(i,:));
[RPredict,Rscore(i,:)]=predict(BR,M(i,:));

end

Dscore=Dscore(:,2);
Rscore=Rscore(:,2);

[X_D,Y_D,~,AUC_D]=perfcurve(DAO,Dscore,'AF');
[X_R,Y_R,~,AUC_R]=perfcurve(RIO,Rscore,'AF');

plot(X_R,Y_R)
hold on
plot(X_D,Y_D)
hold off