function [ map1, map2 ] = separateMap( mapSeg )
%SEPARATEMAP Summary of this function goes here
%   Detailed explanation goes here

map1= mapSeg(1:2:end);
map2= mapSeg(2:2:end);
end

