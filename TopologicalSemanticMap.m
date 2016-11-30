classdef TopologicalSemanticMap < handle
    %TOPOLOGICALSEMANTICMAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nodes;
        adjacency_list;
        current_node;
        frame_mapping;
        distance_mapping;
        threshold_mapping;
        frame_counter;
        similarity;
        bin_list;
    end
    
    methods
        function obj=TopologicalSemanticMap()
            obj.frame_mapping=0;
            obj.distance_mapping=0;
            obj.threshold_mapping=0;
            obj.nodes=TSMNode();
            obj.frame_counter=0;
            obj.adjacency_list=[];
            obj.current_node=1;
            obj.similarity=0.0;
            [ backgnd, flat, other ] = getCategoriesDefinition(  );
            temp=SemanticFeature();
            obj.bin_list=temp.h1==-1;
            obj.bin_list([backgnd other])=true;
        end;
        function obj=setFrameMapping(obj,n_frames)
            obj.frame_mapping=n_frames;
            obj.distance_mapping=0;
            obj.threshold_mapping=0;
        end;
        function obj=setDistanceMapping(obj,dist)
            obj.distance_mapping=dist;
            obj.frame_mapping=0;
            obj.threshold_mapping=0;
        end;
        function obj=setThresholdMapping(obj,threshold)
            obj.distance_mapping=0;
            obj.frame_mapping=0;
            obj.threshold_mapping=threshold;
        end;
        function obj=addAdjacency(obj,from_ind,to_ind)
            obj.adjacency_list(end+1,:)=[from_ind to_ind];
        end;
        function obj=addNode(obj,feature,prev_ind)
            obj.current_node=length(obj.nodes)+1;
            obj.nodes(obj.current_node)=TSMNode();
            obj.addAdjacency(prev_ind,obj.current_node);
            obj.nodes(obj.current_node).add(feature);
        end;
        function obj=addFrame(obj,feature)
            if obj.frame_mapping~=0      %%Frame Mapping
                if obj.frame_counter <= obj.frame_mapping
                    obj.nodes(obj.current_node).add(feature);
                    obj.frame_counter=obj.frame_counter+1;
                else
                    %Evaluar Close
                    obj.addNode(SemanticFeature(),obj.current_node);
                    obj.frame_counter=0;
                end;
                return;
            end;
            if obj.distance_mapping~=0   %%Distance Mapping
                if obj.nodes(obj.current_node).d + feature.d <= obj.distance_mapping
                    obj.nodes(obj.current_node).add(feature);
                else
                    temp_f=SemanticFeature();
                    temp_f.h1=feature.h1;
                    temp_f.h2=feature.h2;
                    temp_f.h3=feature.h3;
                    temp_f.d=feature.d;
                    temp_f.gps=feature.gps;
                    temp_dist=feature.d+obj.nodes(obj.current_node).d-obj.distance_mapping;
                    temp_f.d=obj.distance_mapping-obj.nodes(obj.current_node).d;
                    obj.nodes(obj.current_node).add(feature);
                    if ~isempty(obj.adjacency_list)
                        if sum(obj.adjacency_list(:,2)==obj.current_node,2)==1          % solo tiene un antecesor
                            ant=obj.adjacency_list(obj.adjacency_list(:,2)==obj.current_node,1);
                            if obj.current_node-ant ~=1
                                ant
                                obj.current_node
                            end;
                            if sum(obj.adjacency_list(:,1)==ant)==1                     % el antecesor solo tiene un sucesor
                                if obj.nodes(ant).compare(obj.nodes(obj.current_node),obj.bin_list) < obj.similarity
                                    obj.nodes(ant).compare(obj.nodes(obj.current_node),obj.bin_list)
                                    obj.mergeNodes(ant,obj.current_node);
                                    obj.current_node=ant;
                                end;
                            end;
                        end;
                    end;
                    temp_f.d=temp_dist;
                    obj.addNode(SemanticFeature(),obj.current_node);
                    obj.nodes(obj.current_node).add(temp_f);
                end;
                return;
            end;
            if obj.threshold_mapping ~= 0   %% Threshold Mapping
                if sum(obj.nodes(obj.current_node).h1) == 0
                    obj.nodes(obj.current_node).add(feature);
                    return;
                end;
                if obj.nodes(obj.current_node).compare(feature) <= obj.threshold_mapping
                    obj.nodes(obj.current_node).add(feature);
                else
                    obj.addNode(SemanticFeature(),obj.current_node);
                    %obj.adjacency_list(end+1,:)=[length(obj.nodes) length(obj.nodes)+1];
                    %obj.nodes(end+1)=SemanticFeature();
                    obj.nodes(obj.current_node).add(feature);
                end;
                return;
            end;
            error('No Mapping Method selected. Use setDistanceMapping or serFrameMapping.');
        end;   
        function obj=mergeNodes(obj,node_1,node_2)
            obj.nodes(node_1).add( obj.nodes(node_2) );
            obj.nodes(node_2)=[];
            for I=1:length(obj.adjacency_list(:,1))     %REMOVE CONNECTION
                if obj.adjacency_list(I,1) == node_1 && obj.adjacency_list(I,2) == node_2
                    obj.adjacency_list(I,:)=[];
                    break;
                end;
            end;
            for I=1:length(obj.adjacency_list(:,1))     %REARRANGE CONNECTION
                if obj.adjacency_list(I,1)==node_2
                    obj.adjacency_list(I,1)=node_1;
                end;
                if obj.adjacency_list(I,2)==node_2      %WARNING
                    obj.adjacency_list(I,2)=node_1;
                end;
            end;
            for I=1:length(obj.adjacency_list(:,1))     %UPDATE NODES ID
                if obj.adjacency_list(I,1) > node_2
                    obj.adjacency_list(I,1)=obj.adjacency_list(I,1)-1;
                end;
                if obj.adjacency_list(I,2) > node_2
                    obj.adjacency_list(I,2)=obj.adjacency_list(I,2)-1;
                end;
            end;
        end;
        function nid=nextNodes(obj,id)
            nid=obj.adjacency_list(obj.adjacency_list(:,1) == id , 2);
        end;
        function pid=prevNodes(obj,id)
            pid=obj.adjacency_list(obj.adjacency_list(:,2) == id , 1);
        end;
    end
    
end

