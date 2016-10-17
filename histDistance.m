function [ out ] = histDistance( h1,h2 )
%HISTDISTANCE Summary of this function goes here
%   Detailed explanation goes here
    %out=sum(abs(h1-h2)); %Diferencia de histogramas
    
    out=1-sum(h1.*h2)/(rssq(h1)*rssq(h2)); %Distancia Coseno
end

