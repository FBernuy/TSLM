function [ corres ] = getCorrespondance( mapSeg, mapGT )
%GETCORRESPONDANCE Summary of this function goes here
%   Detailed explanation goes here
[indGT,~]=getTopologicalMap(mapGT);
corres=zeros(length(indGT),length(mapSeg));
for I=1:length(mapSeg)
    [~,ind]=max(indGT(indGT<I));
    corres(ind,I)=1;
end;

end

