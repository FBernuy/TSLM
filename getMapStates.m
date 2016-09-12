function [ ind , freq ] = getMapStates( map )
%GETMAPSTATES Summary of this function goes here
%   Detailed explanation goes here

    ind=[];
    freq=[];
    
    ind(1)=1;
    freq(1)=0;
    
    for I=2:length(map)
        is_repeated=false;
        for J=1:length(ind)
            if compareDescriptions(map(I),map(ind(J)))
                is_repeated=true;
                freq(J)=freq(J)+map(I).dist;
            end;
        end;
        
        if ~is_repeated
            ind(end+1)=I;
            freq(end+1)=0;
        end;
        
    end;
end

