function [ dist ] = compareMaps( mapGT , mapSeg , N)
%COMPAREMAPS Summary of this function goes here
%   Detailed explanation goes here

[indGT,freqGT]=getTopologicalMap(mapGT);
[indSeg,freqSeg]=getTopologicalMap(mapSeg);
globalMap.ind=indGT;
globalMap.len=freqGT;                       %revisar!1
globalMap.des=mapGT(indGT);
cumDistSeg=cumsum([mapSeg(:).dist]);

if nargin==2
    N=0.5;  %Largo de mapa local.
end;
dist(length(globalMap.ind),length(mapSeg))=0;

%para cada imagen
for I=1:length(mapGT)
    I
    if I==348
    end;
    %  -Construir mapa local de segmentacion.
    ind=max(indSeg(indSeg<=I));             %Indice de la descripcion del nodo topologico de la im I
    len=mapSeg(I).dist-mapSeg(ind).dist;    %sum([mapSeg(ind:I).dist]);  %Largo del ultimo nodo hasta la imagen I
    localSeg=[];
    localSeg.ind(1)=ind;
    localSeg.len(1)=len;
    
    ind_first=max(indSeg(indSeg<=find(mapSeg(I).dist-[mapSeg(:).dist] < N,1,'first')));  %Indice de la descripcion del nodo topologico a distancia N de I
    localSeg.ind=indSeg(find(indSeg==ind_first,1,'first'):find(indSeg==ind,1,'first'));
    localSeg.len=freqSeg(find(indSeg==ind_first,1,'first'):find(indSeg==ind,1,'first'));
    if len > N
        localSeg.len(end)=N;
    else
        localSeg.len(end)=len;
        localSeg.len(1)=max([0;N-sum(localSeg.len(2:end))]);
    end;
    localSeg.des=mapSeg(localSeg.ind);
    %  -Comparar Mapa Local con un punto del mapa GT
    parfor J=1:length(globalMap.ind)
        dist(J,I)=localMapDistance(localSeg,globalMap,globalMap.ind(J),N);
    end;
    localSeg;
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

resp=compareDescriptions(globalMap.des(mapInd),localMap.des(end));

localI=0;
globalI=0;

localDist=0;
globalDist=0;
tempDist=0;
sumdiff(1)=0;

if localMap.len(end) <= globalMap.len(mapInd)
    dist=mean(localMap.len(end)*(1-resp));
    if length(localMap.ind)==1 || mapInd==1
        return;
    end;
    
    localI=length(localMap.ind)-1;
    globalI=mapInd-1;
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
    resp=compareDescriptions(localMap.des(localI) , globalMap.des(globalI));
    dist=dist+mean(diffDist*(1-resp));
    
    if (localMap.len(localI)+localDist) < (globalMap.len(globalI)+globalDist)
        localDist=localDist+localMap.len(localI);
        localI=localI-1;
    else
        globalDist=globalDist+globalMap.len(globalI);
        globalI=globalI-1;
    end;
    
    sumdiff(end+1)=diffDist;
    if localI==0
        dist=(dist+N-sum(localMap.len))/N;
        return;
    end;
    if globalI==0
        dist=(dist+N-globalDist)/N;
        return;
    end;
end;
ans=dist;


end