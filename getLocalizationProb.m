function [ out , loc ] = getLocalizationProb( mapGT , mapSeg , len )
%GETLOCALIZATIONPROB Summary of this function goes here
%   Detailed explanation goes here
   
    if nargin ~=3
        len=1.5;
    end;
    comp2=compareMaps(mapGT,mapSeg,len);
    [indGT,freqGT]=getTopologicalMap(mapGT);
    globalMap.ind=indGT;
    globalMap.len=freqGT;                       %revisar!1
    globalMap.des=mapGT(indGT);
    
    
    %% Calcular Matriz de transiciones
    
    transMat=zeros(length(globalMap.ind));
    
    % x+y+z=1
    
    for I=1:length(globalMap.ind)-2
        ss=sum(globalMap.len(I:I+2));
        transMat(I,I)=globalMap.len(I)/(globalMap.len(I)+0.035);%0.9;%globalMap.len(I)/ss;
        transMat(I+1,I)=1-transMat(I,I);%0.075;%globalMap.len(I+1)/ss;
        transMat(I+2,I)=0;%0.025;%globalMap.len(I+2)/ss;
    end;
    transMat(end-1,end-1)=0.9;%globalMap.len(end-1)/(globalMap.len(end-1)+globalMap.len(end));
    transMat(end,end-1)=0.1;%;globalMap.len(end)/(globalMap.len(end-1)+globalMap.len(end));
    transMat(end,end)=1;
    
    %% Calcular Probabilidades por imagen.
    prob=ones(length(globalMap.ind),1);
    
    prob(1:end)=0.1/(length(globalMap.ind-1));
    prob(7)=0.9;
    prob=prob/sum(prob);
    
    out=0*comp2;
    loc=0*comp2;
    
    for I=49:length(mapSeg)
        obsp=1-comp2(:,I);
        obsp=obsp/sum(obsp);
        trans=transMat*prob;
        prob=trans.*obsp;
        prob=prob/sum(prob);
        out(:,I)=prob;
        [~,argmax]=max(prob);
        loc(argmax,I)=1;
    end;
    %imagesc(out)
    
    
end

