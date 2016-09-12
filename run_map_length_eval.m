

load('mapsV2.mat');
range=0.1:0.1:3;
res=[];
for I=range
    I
    res(end+1)=mean(compareMaps(mapGT,mapSeg,I));
end;

plot(range,res)