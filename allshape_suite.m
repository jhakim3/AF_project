close all
ptsFileList=dir('D:/reod_pts_FIRMProject/*.pts');

lesionCart={};
lesionBoundary={};
ind=0;

FourierStuff=0;

for ptsFileListItem=ptsFileList'
    %for ptsFileListItem=ptsFileList(1)
    
    patientName=strsplit(ptsFileListItem.name,'_');
    patientName=patientName(1);
    
    fprintf('Patient %s...\n',patientName{1});
    
    ptsFile=fopen(strcat('D:/reod_pts_FIRMProject/',ptsFileListItem.name));
    pts_cell=textscan(ptsFile,'%f %f %f','HeaderLines',1);
    pts=[pts_cell{1} pts_cell{2} pts_cell{3}];
    
    vtxFileDir=strcat('D:/SailedFIRMProject/',patientName,'*.vtx');
    vtxFileList=dir(vtxFileDir{1});
    for vtxFileListItem=vtxFileList'
        ind=ind+1;
        
        vtxFile=fopen(strcat('D:/SailedFIRMProject/',vtxFileListItem.name));
        vtx_cell=textscan(vtxFile,'%d','HeaderLines',2);
        vtx=vtx_cell{1};
        
        ptsAblate=pts(vtx,:);
        
        %         %%OUTLIERS??
        %         ptCloudDenoised=pcdenoise(pointCloud(ptsAblate));
        %         fprintf('%d --> ',length(ptsAblate));
        %         ptsAblate=ptCloudDenoised.Location;
        %         fprintf('%d\n',length(ptsAblate));
        %         %
        
        numVerts=length(ptsAblate);
        normList=zeros(numVerts,1);
        for i=1:numVerts-1
            normList(i)=norm(double(ptsAblate(i,:)-ptsAblate(i+1,:)));
        end
        normList(end)=norm(double(ptsAblate(end,:)-ptsAblate(1,:)));
        
        centroid=[sum(ptsAblate(:,1)) sum(ptsAblate(:,2)) sum(ptsAblate(:,3))]./numVerts;
        
        ptsCentered=ptsAblate-repmat(centroid,numVerts,1);
        
        %get regressing plane betweeen all points
        [u,s,v]=svd(ptsCentered,0);
        plane=v(:,3); %this is normalized, so just crossprod
        
        magnitudes=zeros(numVerts,1);
        angles=zeros(numVerts,1);
        for i=2:numVerts
            magnitudes(i)=norm(cross(plane,ptsCentered(i,:)));
            normProd=norm(ptsCentered(i-1,:))*norm(ptsCentered(i,:));
            angles(i)=acos(dot(ptsCentered(i-1,:),ptsCentered(i,:))/normProd);
        end
        magnitudes(1)=norm(cross(plane,ptsCentered(1,:)));
        angles(i)=0;
            
        %figure
        %polarplot(angles,magnitudes);
        [lesionCartX,lesionCartY]=pol2cart(angles,magnitudes);
        lesionCart{ind}=[lesionCartX lesionCartY];
        
        shrinkFactor=1;
        boundaryInd=boundary(lesionCart{ind}(:,1),lesionCart{ind}(:,2),shrinkFactor);
        lesionBoundary{ind}=[lesionCart{ind}(boundaryInd,1),lesionCart{ind}(boundaryInd,2)];
        
        if(FourierStuff)
            rFSDs=fEfourier(lesionCart{ind},30,1,1);
            rFSDs=rFSDs(:,2:end); %omit constant terms
            %         figure
            %         plot(rFSDs(1,:))
            %         hold on
            %         plot(rFSDs(2,:))
            %         plot(rFSDs(3,:))
            %         plot(rFSDs(4,:))
            %         hold off
            %
            fit_bs=zeros(1,4);
            for j=1:4
                f=fit((1:29)',rFSDs(j,:)','exp1','StartPoint',[1 0]);
                %fun=@(a,b) (a*exp(b*(1:30)')-rFSDs(1,:)).^2 + (a*exp(b*(1:30)')-rFSDs(1,:)).^2 + (a*exp(b*(2:30)')-rFSDs(3,:)).^2 + (a*exp(b*(1:30)')-rFSDs(4,:)).^2;
                %[a,b]=lsqnonlin(fun,[1 1]);
                fit_bs(j)=f.b;
            end
            %fprintf('Site %d: %f %f %f %f\n',ind,fit_bs(1),fit_bs(2),fit_bs(3),fit_bs(4))
            fprintf('Site %d min coeff: %f\n',ind,min(fit_bs))
        end
        
        fclose(vtxFile);
    end
    fclose(ptsFile);
    
end

%get rid of extra sites that i did
sitesToOmit=[1,2,3,5,9,18,21,23,25,27,56];
lesionBoundary=lesionBoundary(setdiff(1:length(lesionBoundary),sitesToOmit));
sitesToOmitAgain=[13,36,44,55,57,61];

miscShapes(lesionBoundary)

disp('a')