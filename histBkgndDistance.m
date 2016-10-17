function [ out ] = histBkgndDistance( feat1,feat2 )
%HISTBKGNDDISTANCE Summary of this function goes here
%   Detailed explanation goes here
[ backgnd, flat, other ] = getCategoriesDefinition();

out=mean([...
        histDistance(feat1.h1(backgnd),feat2.h1(backgnd)) ...
        histDistance(feat1.h2(backgnd),feat2.h2(backgnd)) ...
        histDistance(feat1.h3(backgnd),feat2.h3(backgnd))]);

end

