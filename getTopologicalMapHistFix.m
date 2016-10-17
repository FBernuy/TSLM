function [ ind , freq , desc ] = getTopologicalMapHistFix( feat )
%GETTOPOLOGICALMAPHISTFIX Summary of this function goes here
%   Detailed explanation goes here

    SEG_LENGTH=0.025;
    
    ind=[];
    freq=[];
    desc=struct([]);
     
    %ind(1)=1;
    %freq(1)=feat(1).dist;
    is_repeated=false;
    
    buff_len=0;
    buff_ind=1;
    buff_count=0;
    buff_feat=feat(1);
    new_node=true;
    
    for I=1:length(feat)
        if new_node
            buff_len=0;
            buff_ind=I;
            buff_count=0;
            buff_feat.h1=feat(1).h1*0;
            buff_feat.h2=feat(1).h2*0;
            buff_feat.h3=feat(1).h3*0;
            new_node=false;
        end;
        buff_len=buff_len+feat(I).dist;
        buff_feat.h1=buff_feat.h1+feat(I).h1;
        buff_feat.h2=buff_feat.h2+feat(I).h2;
        buff_feat.h3=buff_feat.h3+feat(I).h3;
        buff_count=buff_count+1;
        if buff_len > SEG_LENGTH %distancia es 0
            ind(end+1)=buff_ind;
            freq(end+1)=buff_len;
            if length(desc) == 0
                desc=buff_feat;
            else
                desc(end+1)=buff_feat;
            end;
            
            desc(end).h1=desc(end).h1/buff_count;
            desc(end).h2=desc(end).h2/buff_count;
            desc(end).h3=desc(end).h3/buff_count;
            new_node=true;
        end;
    end;
    
    if ~new_node
        ind(end+1)=buff_ind;
        freq(end+1)=buff_len;
        desc(end+1)=buff_feat;
        desc(end).h1=desc(end).h1/buff_count;
        desc(end).h2=desc(end).h2/buff_count;
        desc(end).h3=desc(end).h3/buff_count;
    end;
        
    
end

