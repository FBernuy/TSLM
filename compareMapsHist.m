function [ dist ] = compareMapsHist( mapGT , mapSeg , N )
%COMPAREMAPSHIST Summary of this function goes here
%   Detailed explanation goes here

[indGT,freqGT,descGT]=getTopologicalMapHistFix(mapGT);
[indSeg,freqSeg,descSeg]=getTopologicalMapHistFix(mapSeg);
globalMap.ind=indGT;
globalMap.len=freqGT;                       %revisar!1
globalMap.des=descGT;
cumDistSeg=cumsum([mapSeg(:).dist]);

if nargin==2
    N=0.5;  %Largo de mapa local.
end;
dist(length(globalMap.ind),length(mapSeg))=0;

%para cada imagen
for I=1:length(mapSeg)
    I
    %tic
    if I==348
    end;
    %  -Construir mapa local de segmentacion.
    [ind pos]=max(indSeg(indSeg<=I));             %Indice de la descripcion del nodo topologico de la im I
    len=sum([mapSeg(ind:I).dist]);    %sum([mapSeg(ind:I).dist]);  %Largo del ultimo nodo hasta la imagen I
    localSeg=[];
    localSeg.ind=[];
    localSeg.len=[];
    localSeg.des=[];
    
    
    %ind_first=min(indSeg(indSeg>=find(mapSeg(I).dist-[mapSeg(:).dist] < N,1,'first')));  %Indice de la descripcion del nodo topologico a distancia N de I
    [ind_first]=min(indSeg(cumDistSeg(indSeg)>cumDistSeg(I)-N)); 
    pos_first=find(indSeg==ind_first,1,'first');
    for J=pos_first:pos
        localSeg.ind(end+1)=indSeg(J);
        if length(localSeg.des) == 0
            localSeg.des=descSeg(J);
        else
            localSeg.des(end+1)=descSeg(J);
        end;
        localSeg.len(end+1)=freqSeg(J);
    end;
    if len > N
        localSeg.len(1)=N-sum(localSeg.len(2:end));
    else
        localSeg.len(end)=len;
        localSeg.len(1)=max([0;N-sum(localSeg.len(2:end))]);
    end;
    %localSeg.des=mapSeg(localSeg.ind);
    %  -Comparar Mapa Local con un punto del mapa GT
    %toc
    for J=1:length(globalMap.ind)
        dist(J,I)=localMapDistance(localSeg,globalMap,globalMap.ind(J),N);
    end;
    %toc
    if rem(I,10)==0
        pause(0.1);
        imagesc(dist);
    end;
end;
%dist=dist;
end

function dist = localMapDistance( localMap , globalMap , pos,N)
%revisar en todo el mapa
dist=0;
%pos
%Comparar contra un nodo del mapa
%Encontrar el nodo topologico correspondiente
[mapPos,mapInd]=max(globalMap.ind(globalMap.ind<=pos));
resp=histBkgndDistance(globalMap.des(mapInd),localMap.des(end));

localI=0;
globalI=0;

localDist=0;
globalDist=0;
tempDist=0;
sumdiff(1)=0;

if localMap.len(end) <= globalMap.len(mapInd)   %Ultimo segmento? de Mapa local es mas corto que el global
    dist=localMap.len(end)*(resp);
    if length(localMap.ind)==1 %|| mapInd==1
        return;
    end;
    
    localI=length(localMap.ind)-1;
    if mapInd==1
        globalI=length(globalMap.ind);
    else
        globalI=mapInd-1;
    end;
    sumdiff(1)=localMap.len(end);
else
    dist=0;
    localI=length(localMap.ind);
    globalI=mapInd;
    sumdiff(1)=0;
end;
while true
    diffDist=0;
    if (localMap.len(localI)+localDist) < (globalMap.len(globalI)+globalDist)
        diffDist=localMap.len(localI)+localDist-tempDist;
        tempDist=localMap.len(localI)+localDist;
    else
        diffDist=globalMap.len(globalI)+globalDist-tempDist;
        tempDist=globalMap.len(globalI)+globalDist;
    end;
    %diffDist=abs((localMap.len(localI)+localDist)-(globalMap.len(globalI)+globalDist));
    if diffDist < 0
    end;
    resp=histBkgndDistance(localMap.des(localI) , globalMap.des(globalI));
    dist=dist+mean(diffDist*(resp));
    
    if (localMap.len(localI)+localDist) < (globalMap.len(globalI)+globalDist)
        localDist=localDist+localMap.len(localI);
        localI=localI-1;
    else
        globalDist=globalDist+globalMap.len(globalI);
        globalI=globalI-1;
    end;
    
    sumdiff(end+1)=diffDist;
    if localI==0
        %dist=(dist+N-localDist)/N;
        if dist < 0
            dist
        end;
        return;
    end;
    if globalI==0
        %dist=(dist+N-globalDist)/N;
        globalI=length(globalMap.ind);
        %if dist < 0
        %    display wtf
        %    dist
        %end;
        
        %return;
    end;
end;
ans=dist;


end