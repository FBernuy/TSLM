function [ out ] = histCompare( feat1,feat2 )
%HISTCOMPARE Summary of this function goes here
%   Detailed explanation goes here

    [ backgnd, flat, other ] = getCategoriesDefinition();
    
    out=[...
        partialHistCompare3(feat1.h1(backgnd),feat2.h1(backgnd)) ...
        partialHistCompare3(feat1.h2(backgnd),feat2.h2(backgnd)) ...
        partialHistCompare3(feat1.h3(backgnd),feat2.h3(backgnd))];
    
    return;
    out=out+[...
        partialHistCompare2(feat1.h1(flat),feat2.h1(flat)) ...
        partialHistCompare2(feat1.h2(flat),feat2.h2(flat)) ...
        partialHistCompare2(feat1.h3(flat),feat2.h3(flat))];
    
end

function resp=partialHistCompare1(hist1,hist2)
    
    [~,ind1]=sort(hist1);
    [~,ind2]=sort(hist2);
    
    if(ismember(ind1(end),ind2(end-1:end)) || ismember(ind2(end),ind1(end-1:end)))
        resp=1;
        return
    end;
    resp=0;
end

function resp=partialHistCompare2(hist1,hist2)  %estricto
    
    [~,ind1]=sort(hist1);
    [~,ind2]=sort(hist2);
    
    if( (ind1(end)==ind2(end)))
        resp=1;
        return
    end;
    resp=0;
end

function resp=partialHistCompare3(hist1,hist2)  %estricto
    
    
    if( histDistance(hist1,hist2)>0.2)
        resp=1;
        return
    end;
    resp=0;
end
