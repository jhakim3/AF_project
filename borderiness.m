
addpath('D:\DownloadsD\matlab_bgl-4.0.1\matlab_bgl\')

close all
ptsFileList=dir('D:/files_for_borderiness_FIRM/CARP_FIRM/*.pts');
elemFileList=dir('D:/files_for_borderiness_FIRM/CARP_FIRM/*.elem');

ind=0;
patnum=0;

for ptsFileListItem=ptsFileList'
    patnum=patnum+1;
    
    patientName=strsplit(ptsFileListItem.name,'_');
    patientName=patientName(1);
    
    fprintf('Patient %s...\n',patientName{1});
    
    ptsFile=fopen(strcat('D:/files_for_borderiness_FIRM/CARP_FIRM/',ptsFileListItem.name));
    pts_cell=textscan(ptsFile,'%f %f %f','HeaderLines',1);
    pts=[pts_cell{1} pts_cell{2} pts_cell{3}];
    
    elemFile=fopen(strcat('D:/files_for_borderiness_FIRM/CARP_FIRM/',elemFileList(patnum).name));
    elem_cell=textscan(elemFile,'%*3s %d %d %d %d %d','HeaderLines',1);
    elem=[elem_cell{1} elem_cell{2} elem_cell{3} elem_cell{4} elem_cell{5}];
    elem(:,1:4)=elem(:,1:4)+1;%convert to matlab indexing
    
    LA_fib=find(elem(:,5)==128);
    RA_fib=find(elem(:,5)==32);
    
    res=1000000;
    
    LA_numFibBors=zeros(floor(length(LA_fib)/res),2);
    RA_numFibBors=zeros(floor(length(RA_fib)/res),2);
    
    tic
    reverseStr = '';
    for i=1:res:length(LA_fib)
        msg = sprintf('LA: processed %.0f percent', i/length(LA_fib)*100);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        [rows,~]=find(elem(LA_fib(i),1)==elem);
        LA_numFibBors(floor(i/res)+1,1)=length(find(elem(rows,5)==128));
        LA_numFibBors(floor(i/res)+1,2)=length(rows);
    end
    LA_mean=mean(LA_numFibBors(:,1)./LA_numFibBors(:,2));
    fprintf('\n')
    toc
    
    tic
    reverseStr = '';
    for i=1:res:length(RA_fib)
        msg = sprintf('RA: processed %.0f percent', i/length(RA_fib)*100);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        [rows,~]=find(elem(RA_fib(i),1)==elem);
        RA_numFibBors(floor(i/res)+1,1)=length(find(elem(rows,5)==32));
        RA_numFibBors(floor(i/res)+1,2)=length(rows);
    end
    RA_mean=mean(RA_numFibBors(:,1)./RA_numFibBors(:,2));
    fprintf('\n')
    toc
    
    fprintf('Res: %d\tLA: %f -- RA: %f\n',res,LA_mean,RA_mean)
    
    fclose(ptsFile);
    fclose(elemFile);
    
end






