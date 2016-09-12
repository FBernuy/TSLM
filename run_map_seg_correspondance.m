load('mapsV2.mat');

[indSeg,freqSeg]=getTopologicalMap(mapSeg);
[indGT,freqGT]=getTopologicalMap(mapGT);

corres(length(indGT),length(mapSeg))=0;

for I=1:length(mapSeg)
    [~,ind]=max(indGT(indGT<I));
    I
    ind
    corres(ind,I)=1;
end;