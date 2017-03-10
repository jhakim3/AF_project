inputImage1 = imread('./Fossil.png');
inputImage2 = imread('./mouse.jpg');
[B1,~] = bwboundaries(imbinarize(rgb2gray(inputImage1)));
[B2,~] = bwboundaries(imbinarize(rgb2gray(inputImage2)));

close all
hold on
for i = 1:length(B1)
    plot(B1{i}(:,1),B1{i}(:,2))
end
figure
for i = 1:length(B2)
    plot(B2{i}(:,1),B2{i}(:,2))
end

boundary1=B1{3};
boundary2=B2{158};

numSamples=300;
boundaryDS=downsample(boundary1,round(length(boundary1)/numSamples));

numSteps=length(boundaryDS);
stepLengths=zeros(numSteps,1);
angles=zeros(numSteps,1);
for i=1:numSteps-1
    a=boundaryDS(i,:);b=boundaryDS(i+1,:);
    stepLengths(i)=norm(b-a);
    angles(i)=atan2(b(2)-a(2),b(1)-a(1));
end
stepLengths(end)=norm(boundaryDS(1,:)-boundaryDS(end,:));
angles(end)=atan2(boundaryDS(1,2)-boundaryDS(end,2),boundaryDS(1,1)-boundaryDS(end,1));

angles_plus_ramp=angles+((1:numSteps)*2*pi/numSteps)';

figure
plot(angles)
plot(angles_plus_ramp)