classdef ForwardLocalization < TopologicalLocalization
    %FORWARDLOCALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        map;
        distribution;
        h_pos;
        pose;
        pose_p;
    end
    
    methods
        function obj=ForwardLocalization(map, initial_distribution)
            obj.map=map;
            obj.distribution=initial_distribution*1000+1;
            obj.distribution=obj.distribution/sum(obj.distribution);
            obj.h_pos = 0;
        end;
        function pose=update(obj,SO,dist)
            dist=dist*1.0;%5;
            obsp(length(obj.map.nodes))=0;
            parfor I=1:length(obj.map.nodes)
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
            trans_prob=dist./([(obj.map.nodes(:).d)]);
            trans_prob(isnan(trans_prob))=0.9999;
            trans_prob(trans_prob>=1)=0.9999;
            trans_prob(trans_prob<=0.000001)=0.000001;
            for I=1:length(obj.map.nodes)
                trans=0;
                if isempty(obj.map.prevNodes(I))
                    trans=obj.distribution(I);
                else
                    if obj.map.nodes(I).d == 0
                        trans=max(obj.distribution(obj.map.prevNodes(I)));
                    else
                        %trans=(obj.map.nodes(I).d/(obj.map.nodes(I).d+dist))*obj.distribution(I)+...
                        %        (dist/(obj.map.nodes(I).d+dist))*max(obj.distribution(obj.map.prevNodes(I)));
                        trans=(1-trans_prob(I))*obj.distribution(I)+max(trans_prob(obj.map.prevNodes(I)).*obj.distribution(obj.map.prevNodes(I)));
                    end;
                end;
                 prob(I)=trans*obsp(I);
            end;
            prob=prob/sum(prob);
            if any(isnan(prob))
            end;
            obj.distribution=prob;
            
            [~,pose.id]=max(obj.distribution);
            pose.length=obj.map.nodes(pose.id).d/2;
            obj.pose=pose;
            obj.pose_p=obj.distribution(obj.pose.id);
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

