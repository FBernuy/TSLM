function [ output_args ] = displayDescription( desc )
%DISPLAYDESCRIPTION Summary of this function goes here
%   Detailed explanation goes here

    
    display('--------------------')
    display([desc.left.build(1)  desc.center.build(1)  desc.right.build(1)])
    display([desc.left.flat(1)  desc.center.flat(1)  desc.right.flat(1)])
    display('--------------------')
end

