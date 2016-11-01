classdef (Abstract) TopologicalLocalization < handle
    %TOPOLOGICALLOCALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
    end
    
    methods (Abstract)
        pose=update(obj,SO)
    end
    
end