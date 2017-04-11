function [] = nearest_obstacle()

addpath('D:\DownloadsD\matlab_bgl-4.0.1\matlab_bgl\')

close all
ptsFileList=dir('D:/reod_pts_FIRMProject/*.pts');
trisFileList=dir('C:/Workspace/FIRM_obstacles/*.tris');
obstaclesFileList=dir('C:/Workspace/Pats_scripts/*EpiAblated.pts');

ind=0;
patnum=0;

for ptsFileListItem=ptsFileList'
    patnum=patnum+1;
    
    patientName=strsplit(ptsFileListItem.name,'_');
    patientName=patientName(1);
    
    %if(patientName{1}=='CM'), continue; end
    %if(patientName{1}=='CW'), continue; end
    %if(patientName{1}=='DB'), continue; end
    %if(patientName{1}=='DC'), continue; end
    
    fprintf('Patient %s...\n',patientName{1});
    
    ptsFile=fopen(strcat('D:/reod_pts_FIRMProject/',ptsFileListItem.name));
    pts_cell=textscan(ptsFile,'%f %f %f','HeaderLines',1);
    pts=[pts_cell{1} pts_cell{2} pts_cell{3}];
    
    trisFile=fopen(strcat('C:/Workspace/FIRM_obstacles/',trisFileList(patnum).name));
    tris_cell=textscan(trisFile,'%d %d %d %d','HeaderLines',1);
    tris=[tris_cell{1} tris_cell{2} tris_cell{3}];
    tris=tris+1;%convert to matlab indexing
    
    %
    pts_obs_each=cell(8,1);
    ind2=0;
    for name={'LIPV','LSPV','RIPV','RSPV','IVC','SVC','MV','TV'}
        ind2=ind2+1;
        pts_obs_each{ind2}=struct('name','pts');
        pts_obs_each{ind2}.name=name;
        obsFileName=strcat('C:/Workspace/Pats_scripts/specific_obs/',patientName,'_marked-Marked_as_',name,'.pts');
        obsFile=fopen(obsFileName{1});
        pts_obs_cell=textscan(obsFile,'%f %f %f','HeaderLines',1);
        pts_obs=[pts_obs_cell{1} pts_obs_cell{2} pts_obs_cell{3}];
        pts_obs_each{ind2}.pts=pts_obs;
    end
    %
    
    vtxFileDir=strcat('D:/SailedFIRMProject/',patientName,'*.vtx');
    vtxFileList=dir(vtxFileDir{1});
    
    ptsSimpleDir=strcat('C:/Workspace/Pats_scripts/',patientName,'_reod_200k.pts');
    ptsSimpleFile=fopen(ptsSimpleDir{1});
    pts_simple_cell=textscan(ptsSimpleFile,'%f %f %f','HeaderLines',1);
    ptsSimple=[pts_simple_cell{1} pts_simple_cell{2} pts_simple_cell{3}];
    
    trisSimpleDir=strcat('C:/Workspace/Pats_scripts/',patientName,'_reod_200k.tris');
    trisSimpleFile=fopen(trisSimpleDir{1});
    tris_simple_cell=textscan(trisSimpleFile,'%d %d %d %d','HeaderLines',1);
    trisSimple=[tris_simple_cell{1} tris_simple_cell{2} tris_simple_cell{3}];
    trisSimple=trisSimple+1;%convert to matlab indexing
    
    tic
    costMatrix=makeCostMatrix(ptsSimple,trisSimple);
    toc
    
    for vtxFileListItem=vtxFileList'
        ind=ind+1;
        
        vtxFile=fopen(strcat('D:/SailedFIRMProject/',vtxFileListItem.name));
        vtx_cell=textscan(vtxFile,'%d','HeaderLines',2);
        vtx=vtx_cell{1};
        
        ptsAblate=pts(vtx,:);
        
        %findDist_euclid(ptsAblate,pts_obs);
        %findDist_dijkstra(ptsAblate,pts_obs,costMatrix,ptsSimple);
        
        findDists_euclid(ptsAblate,pts_obs_each);
        findDists_dijkstra(ptsAblate,pts_obs_each,costMatrix,ptsSimple);
        
        fclose(vtxFile);
    end
    fclose(ptsFile);
    fclose(trisFile);
    fclose(obsFile);
    
end

disp('a')

end

function findDist_euclid(ptsAblate,ptsObstacles)
eachKnn=knnsearch(KDTreeSearcher(ptsObstacles),ptsAblate);
[minPt,minInd]=min(eachKnn);
minDist=norm(ptsObstacles(minPt,:)-ptsAblate(minInd,:));
fprintf('Euclid: %f\n',(minDist));
end

function findDist_dijkstra(ptsAblate,ptsObstacle,costMatrix,ptsSimple)
simpleIndAblate=unique(knnsearch(KDTreeSearcher(ptsSimple),ptsAblate));
simpleIndObstacle=unique(knnsearch(KDTreeSearcher(ptsSimple),ptsObstacle));


[dists,~]=dijkstra_sp(costMatrix,simpleIndAblate(1));
fprintf('Dijkstra: %f\n',(min(dists(simpleIndObstacle))));
end

function findDists_euclid(ptsAblate,ptsObstaclesEach)
for i=1:length(ptsObstaclesEach)
    ptsObstacles=ptsObstaclesEach{i}.pts;
    eachKnn=knnsearch(KDTreeSearcher(ptsObstacles),ptsAblate);
    [minPt,minInd]=min(eachKnn);
    minDist=norm(ptsObstacles(minPt,:)-ptsAblate(minInd,:));
    fprintf('Euclid %s: %f\n',ptsObstaclesEach{i}.name{1},(minDist));q
end
end

function findDists_dijkstra(ptsAblate,ptsObstaclesEach,costMatrix,ptsSimple)
for i=1:length(ptsObstaclesEach)
    ptsObstacle=ptsObstaclesEach{i}.pts;
    simpleIndAblate=unique(knnsearch(KDTreeSearcher(ptsSimple),ptsAblate));
    simpleIndObstacle=unique(knnsearch(KDTreeSearcher(ptsSimple),ptsObstacle));
    
    [dists,~]=dijkstra_sp(costMatrix,simpleIndAblate(1));
    fprintf('Dijkstra %s: %f\n',ptsObstaclesEach{i}.name{1},(min(dists(simpleIndObstacle))));
end
end

function C= makeCostMatrix(pts,tris)
C=sparse([],[],[],length(pts),length(pts));
for i=1:length(tris)
    if(mod(i,10000)==0)
        %disp('a')
        toc
        tic
    end
    vecdists=pdist(pts(tris(i,:)',:));
    %vecs=pts(tris(i,:)',:);
    
    if((C(tris(i,1),tris(i,2))==0))
        %C(tris(i,1),tris(i,2))=norm(vecs(1,:)-vecs(2,:));
        C(tris(i,1),tris(i,2))=vecdists(1);
    end
    if((C(tris(i,2),tris(i,3))==0))
        %C(tris(i,2),tris(i,3))=norm(vecs(2,:)-vecs(3,:));
        C(tris(i,2),tris(i,3))=vecdists(3);
    end
    if((C(tris(i,1),tris(i,3))==0))
        %C(tris(i,1),tris(i,3))=norm(vecs(1,:)-vecs(3,:));
        C(tris(i,1),tris(i,3))=vecdists(2);
    end
    %C(tris(i,1),tris(i,2))=pdist([vecs(1,:);vecs(2,:)]);
    %C(tris(i,2),tris(i,3))=pdist([vecs(2,:);vecs(3,:)]);
    %C(tris(i,1),tris(i,2))=pdist([vecs(1,:);vecs(2,:)]);
    
    C(tris(i,2),tris(i,1))=C(tris(i,1),tris(i,2));
    C(tris(i,3),tris(i,2))=C(tris(i,2),tris(i,3));
    C(tris(i,3),tris(i,1))=C(tris(i,3),tris(i,1));
end
end









