function [ ind , freq ] = getTopologicalMap( map )
%GETTOPOLOGICALMAP Summary of this function goes here
%   Detailed explanation goes here

    ind=[];
    freq=[];
    
    ind(1)=1;
    freq(1)=map(1).dist;
    
    for I=2:length(map)
        is_repeated=false;
        if compareDescriptions(map(I),map(ind(end)))
            is_repeated=true;
            %freq(end)=freq(end)+map(I).dist;
        end;
       
        
        if ~is_repeated
            freq(end)=map(I).dist-freq(end);
            ind(end+1)=I;
            freq(end+1)=map(I).dist;
        end;
        
    end;
    freq(end)=map(length(map)).dist-freq(end);


end

