classdef ForwardLocalization < TopologicalLocalization
    %FORWARDLOCALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        map;
        distribution;
        h_pos;
        pose;
    end
    
    methods
        function obj=ForwardLocalization(map, initial_distribution)
            obj.map=map;
            obj.distribution=initial_distribution*1000+1;
            obj.distribution=obj.distribution/sum(obj.distribution);
            obj.h_pos = 0;
        end;
        function pose=update(obj,SO,dist)
            dist=dist*1.5;
            obsp(length(obj.map.nodes))=0;
            for I=1:length(obj.map.nodes)
                obsp(I)=0;
                if isa(SO,'DirectObservation')
                    obsp(I)= SO.likelihood(obj.map,I,0);
                else
                    for J=0.2:0.2:1
                        obsp(I)=max( obsp(I) , SO.likelihood(obj.map,I,obj.map.nodes(I).d*J) ); %innecesario en DO.
                    end;
                end;
            end;
            obsp=softmax(obsp')';%
            %obsp/sum(obsp);
            prob=obj.distribution;
            for I=1:length(obj.map.nodes)
                trans=0;
                if isempty(obj.map.prevNodes(I))
                    trans=obj.distribution(I);
                else
                    trans=(obj.map.nodes(I).d/(obj.map.nodes(I).d+dist))*obj.distribution(I)+...
                          (dist/(obj.map.nodes(I).d+dist))*mean(obj.distribution(obj.map.prevNodes(I)));
                end;
                prob(I)=trans*obsp(I);
            end;
            prob=prob/sum(prob);
            obj.distribution=prob;
            
            [~,pose.id]=max(obj.distribution);
            pose.length=obj.map.nodes(pose.id).d/2;
            obj.pose=pose;
        end;
        function obj=display(obj)
            
            [~,pose]=max(obj.distribution);
            
            if obj.h_pos ~= 0
                delete(obj.h_pos)
            end;
            obj.h_pos=obj.map.nodes(pose).display;
            set(obj.h_pos,'LineWidth',4)
            set(obj.h_pos,'Color','y')
            return;
            if isempty(obj.map.nextNodes(pose))
                obj.h_pos=plot([obj.map.nodes(pose).gps(2)],[obj.map.nodes(pose).gps(1)],'-yo', 'MarkerSize', 12, 'LineWidth',2);
            else
                obj.h_pos=plot([obj.map.nodes(pose).gps(2) obj.map.nodes(pose+1).gps(2)],[obj.map.nodes(pose).gps(1) obj.map.nodes(pose+1).gps(1)],'-yo', 'MarkerSize', 12, 'LineWidth',2);
            end;
        end;
    end
    
end

