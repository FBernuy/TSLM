classdef OTSMNode < OrientedSemanticFeature
    %OTSMNODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gps_list;
    end
    
    methods
        function obj=OTSMNode()
            obj.gps_list=[];
        end;
        function obj=add(obj,feature)
            pred=obj.d;
            obj.add@OrientedSemanticFeature(feature);
            posd=obj.d;
            if isempty(feature.gps)
                return;
            end;
            if isempty(obj.gps_list)
                obj.gps_list(1,:)=feature.gps;
                obj.gps_list(2,:)=feature.gps;
            end;
            if floor(pred/0.010) == floor(posd/0.010)
                obj.gps_list(end,:)=feature.gps;
            else
                %obj.gps_list(end+1,:)=obj.gps_list(end,:)+(feature.gps-obj.gps_list(end,:))/(posd-pred)*floor(posd/0.020)*0.020;
                obj.gps_list(end+1,:)=feature.gps;
            end;
            
        end;
        function h=display(obj)
            h=plot(obj.gps_list(:,2),obj.gps_list(:,1));
        end;
    end
    
end

