function [  out , loc  ] = getParticleLocalization( mapGT , mapSeg , len )
%GETPARTICLELOCALIZATION Summary of this function goes here
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
prob(13)=0.9;
prob=prob/sum(prob);

out=0*comp2;
loc=0*comp2;

%%Inicializo Particulas
N_part=20;
particles(N_part)=struct;   %resize

accum_w=0;
for I=1:N_part
    particles(I).id=find(rand <= cumsum(prob),1);
    particles(I).length=rand * freqGT(particles(I).id);
    
    %calcular pesos.
    particles(I).weight=prob(particles(I).id);
    accum_w=accum_w+particles(I).weight;
end;

%Normalizar los pesos de las particulas.
for I=1:N_part
    particles(I).weight=particles(I).weight/accum_w;
end;

%% Particle Filter
x_N=0.1; % Error proporcional de traslacion
a_P=0.9; % Particle weight memory

for I=80:length(mapSeg)
    
    %Traslacion de particulas
    accum_w=0;
    for J=1:N_part
        particles(J).length= particles(J).length + (mapSeg(I).dist-mapSeg(I-1).dist)*(1 + x_N*randn);
        if particles(J).length > globalMap.len(particles(J).id)
            particles(J).length = particles(J).length-globalMap.len(particles(J).id);
            particles(J).id=particles(J).id+1;
            if particles(J).id > length(globalMap.ind) 
                particles(J).id=particles(J).id-length(globalMap.ind)
            end;
        end;
        
        particles(J).weight= a_P * particles(J).weight + (1-a_P) * comp2(particles(J).id,I);
        accum_w=accum_w+particles(J).weight;
    end;
    for J=1:N_part
        particles(J).weight=particles(J).weight/accum_w;
    end;
    
    % Resampleamos
    %tmp(N_part)=struct;
    for J = 1 : N_part
        tmp(J) = particles(find(rand <= cumsum(cell2mat({particles.weight})),1));
    end;
    
    particles=tmp;
    
    for J = 1 : N_part
        out(particles(J).id,I)=out(particles(J).id,I)+(1.0/N_part);
        
    end;
    [~,argmax]=max(out(:,I));
    loc(argmax,I)=1;
    %obsp=1-comp2(:,I);
    %obsp=obsp/sum(obsp);
    %trans=transMat*prob;
    %prob=trans.*obsp;
    %prob=prob/sum(prob);
    %out(:,I)=prob;
    %[~,argmax]=max(prob);
    %loc(argmax,I)=1;
end;
%imagesc(out)


end




