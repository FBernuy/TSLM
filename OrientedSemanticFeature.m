classdef OrientedSemanticFeature < SemanticFeature
    %ORIENTEDSEMANTICFEATURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        orientation;
    end
    
    methods
        function obj=OrientedSemanticFeature()
            obj.orientation = 0;
        end;
        function copySemanticFeature(obj, SF)
            obj.h1  =SF.h1;
            obj.h2  =SF.h2;
            obj.h3  =SF.h3;
            obj.d   =SF.d;
            obj.gps =SF.gps;
            obj.orientation = 0;
        end;
        function obj=add(obj,SF)
            obj.add@SemanticFeature(SF);
            if SF.d == 0
                return;
            end;
            
            obj.orientation=atan2(obj.d*sin(obj.orientation)+SF.d*sin(SF.orientation),...
                                  obj.d*cos(obj.orientation)+SF.d*cos(SF.orientation));
            %obj.orientation=(obj.orientation*obj.d+SF.orientation*SF.d)/(obj.d+SF.d); %TODO: Icnluir no linealidad
            
        end;
    end
    
end

