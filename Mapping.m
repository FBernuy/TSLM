classdef Mapping
    %MAPPING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        GTSM;
        feat_map_index;
        inters;
        inter_index;
        ign;
    end
    
    methods
        function obj=Mapping(feat_map, ignore_list, intersections, th, Nf,is_oriented)
            obj.GTSM=TopologicalSemanticMap(is_oriented);
            obj.GTSM.setThresholdMapping(th);%0.4                                     %param1: Mapping threshold (0.4)
            obj.inters=intersections;
            obj.inter_index=(intersections*0);
            obj.ign=ignore_list;
            obj.feat_map_index(length(feat_map))=0;
            if ~is_oriented
                tmp_feat=SemanticFeature();
            else
                tmp_feat=OrientedSemanticFeature();
            end;
            for I=1:length(feat_map)
                % if esta en ignore list, continue
                if any((I>=obj.ign(:,1)) & (I<=obj.ign(:,2)))
                    continue;
                end;
                
                if any(I-1==obj.ign(:,2))
                    obj.GTSM.current_node=[];
                end;
                tmp_feat.add(feat_map(I));
                obj.feat_map_index(I)=length(obj.GTSM.nodes);
                
                % if es intersection receptor
                %     agrego indice junto en el mapa
                ind=find(I==obj.inters(:,2),1);
                if ~isempty(ind)
                    obj.GTSM.addNode(tmp_feat,obj.GTSM.current_node);
                    obj.inter_index(ind,2)=obj.GTSM.current_node;
                    if ~is_oriented
                        tmp_feat=SemanticFeature();
                    else
                        tmp_feat=OrientedSemanticFeature();
                    end;
                    obj.feat_map_index( (I-Nf+1):I)=length(obj.GTSM.nodes);
                    continue;
                end;
                
                % if es interseccion entrante
                ind=find(I==obj.inters(:,1),1);
                if ~isempty(ind)
                    obj.GTSM.addNode(tmp_feat,obj.GTSM.current_node);
                    obj.inter_index(ind,1)=obj.GTSM.current_node;
                    if ~is_oriented
                        tmp_feat=SemanticFeature();
                    else
                        tmp_feat=OrientedSemanticFeature();
                    end;
                    obj.feat_map_index( (I-Nf+1):I)=length(obj.GTSM.current_node);
                    continue;
                end;
                %NO DEBERIA LLEGAR HASTA AQUI!
                if any(I-1==obj.ign(:,2))
                    obj.GTSM.addNode([],[]);
                end;
                if ~rem(I,Nf)
                    
                    
                    obj.GTSM.addFrame(tmp_feat);
                    
                    if ~is_oriented
                        tmp_feat=SemanticFeature();
                    else
                        tmp_feat=OrientedSemanticFeature();
                    end;
                    obj.feat_map_index( (I-Nf+1):I)=length(obj.GTSM.nodes);
                    
                    %clf;
                    %obj.GTSM.display();
                    %drawnow;
                    
                end;
                
            end;
            
            for I=1:length(obj.inter_index(:,1))
                prev_list1=obj.GTSM.prevNodes(obj.inter_index(I,1));
                prev_list2=obj.GTSM.prevNodes(obj.inter_index(I,2));
                for J=1:length(prev_list1)
                    obj.GTSM.addAdjacency(prev_list1(J),obj.inter_index(I,2));
                end;
                for J=1:length(prev_list2)
                    obj.GTSM.addAdjacency(prev_list2(J),obj.inter_index(I,1));
                end;
            end;
        end;
        function resp = checkIntersection(obj, SF)
            resp(1)=0.01;
            resp(2:5)=0;
            
            for I=1:length(obj.GTSM.nodes)
                if I==obj.GTSM.current_node
                    continue;
                end;
                for J=1:length(obj.GTSM.nodes(I).gps_list)
                    d=lldistkm( obj.GTSM.nodes(I).gps_list(J,:) , SF.gps);
                    if d < resp(1)
                        resp(1)= min(resp(1),d);
                        resp(2)=I;
                        resp(3)=J;
                        resp(4:5)=SF.gps;
                    end;
                end;
            end;
        end;
    end
    
end

