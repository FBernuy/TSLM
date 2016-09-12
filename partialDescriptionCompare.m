function [ out ] = partialDescriptionCompare( part1,part2 )
%PARTIALDESCRIPTIONCOMPARE Summary of this function goes here
%   Detailed explanation goes here
    
    if isempty(part1) && isempty(part2)
        out = true;
        return;
    end;
    if isempty(part1) || isempty(part2)
        out = false;
        return;
    end;
    
    out=strcmp(part1{1},part2{1});
    
end

