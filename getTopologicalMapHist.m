function [  ind , freq ] = getTopologicalMapHist( feat )
%GETTOPOLOGICALMAPHIST Summary of this function goes here
%   Detailed explanation goes here

    MIN_SEG_LEN=0.020;

    ind=[];
    freq=[];
     
    %ind(1)=1;
    %freq(1)=feat(1).dist;
    is_repeated=false;
    
    buff_len=feat(1).dist;
    buff_ind=1;
    
    for I=2:length(feat)
        is_repeated=false;
        if ~histCompare(feat(I),feat(buff_ind)) %distancia es 0
            is_repeated=true;
            buff_len=buff_len+feat(I).dist;
        end;
               
        if ~is_repeated
            if buff_len > MIN_SEG_LEN
                ind(end+1)=buff_ind;
                freq(end+1)=buff_len;
                
            else
                if length(freq)==0
                    freq(1)=buff_len;
                    ind(1)=1;
                else
                    freq(end)=freq(end)+buff_len;
                end;
            end
            buff_len=feat(I).dist;
            buff_ind=I;
        end;
    end;
    
    if is_repeated
        freq(end)=freq(end)+buff_len;
    else
        if buff_len > MIN_SEG_LEN
            ind(end+1)=buff_ind;
            freq(end+1)=buff_len;
        else
            freq(end)=freq(end)+buff_len;
        end;
    end;
end

