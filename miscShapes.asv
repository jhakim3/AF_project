function miscShapeParams=miscShapes(outlineCell)


miscShapeParams=zeros(length(outlineCell),1);
for i =1:length(outlineCell)
    Xs=outlineCell{i}(:,1);Ys=outlineCell{i}(:,2);
    miscShapeParams(i,1)=getPerim(Xs,Ys);   
    miscShapeParams(i,2)=getArea(Xs,Ys);
    miscShapeParams(i,3)=miscShapeParams(i,1)/miscShapeParams(i,2); %area / perim
    [AR,FF,R,Con]=getFeretShapes(Xs,Ys,miscShapeParams(i,1),miscShapeParams(i,2));
    miscShapeParams(i,4)=AR;
    miscShapeParams(i,5)=FF;
    miscShapeParams(i,6)=R;
    miscShapeParams(i,7)=Con;
end

end

function perim = getPerim(Xs,Ys)
perim=0;
for i=1:length(Xs)-1
    perim=perim+norm([Xs(i+1)-Xs(i) Ys(i+1)-Ys(i)]);
end
perim=perim+norm([Xs(1)-Xs(end) Ys(1)-Ys(end)]);
end

function area = getArea(Xs,Ys)
[~,area]=boundary(Xs,Ys);
end

function [AR,FF,R,Con]=getFeretShapes(Xs,Ys,perim,area)
%caluclate feret distances
ferets=zeros(length(0.01:0.01:2*pi),1);
ind=0;
for theta = 0.01:0.01:2*pi
    ind=ind+1;
    rotated=[Xs,Ys]*[cos(theta) -sin(theta);sin(theta) cos(theta)];
    X_temp=rotated(:,1);Y_temp=rotated(:,2);
    ferets(ind)=max(X_temp)-min(X_temp);
end

AR=min(ferets)/max(ferets);
FF=(4*pi*area)/(perim^2);
R=(4*area)/(pi*max(ferets)^2);
Con=(pi*mean(ferets))/perim;
end