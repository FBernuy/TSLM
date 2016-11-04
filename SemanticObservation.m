classdef (Abstract) SemanticObservation
    %SEMANTICOBSERVATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
    end
    
    methods (Abstract)
        prob=likelihood(map,ind,len)
    end
    
end

