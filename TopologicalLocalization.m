classdef (Abstract) TopologicalLocalization < handle
    %TOPOLOGICALLOCALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
        map
        pose
    end
    
    methods (Abstract)
        pose=update(obj,SO,dist)
        display(obj)
    end
    
end