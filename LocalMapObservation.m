classdef LocalMapObservation < SemanticObservation
    %LOCALMAPOBSERVATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        map;
        len;
    end
    
    methods
        function obj=LocalMapObservation(len)
            obj.map=TopologicalSemanticMap();
            obj.map.setThresholdMapping(0.15);
            obj.len=len;
        end;
        function prob=likelihood(obj,map,ind,len)
            dist=0;
            
            % 1- Hacer una lista con TODOS los posibles paths de largo LEN.
            paths{1}=ind;
            lens{1}=len;
            ready=false;
            
            if len >= obj.len
                lens{1}=obj.len;
                ready=true;
            end;
            
            while ~ready
                ready=true;
                for I=length(paths):-1:1
                    if lens{I} >= obj.len
                        continue;
                    end;
                    prevs=map.prevNodes(paths{I}(1));
                    if ~isempty(prevs)
                        ready=false;
                        for J=2:length(prevs)
                            paths{end+1}=[prevs(J) paths{I}]
                            lens{end+1}=map.nodes(prevs(J)).d+lens{I};
                        end;
                        paths{I}=[prevs(1) paths{I}];
                        lens{I}=map.nodes(prevs(1)).d+lens{I};
                    end;
                end;
                for I=1:length(paths)
                     if lens{I} > obj.len
                        lens{I} = obj.len;
                    end;
                end;
            end;
            % 2- Comparar cada local path con el local map y elegir el
            % minimo
            for I=1:length(paths)
                dist=min(dist, compareToPath(obj,map,paths{I},len) );
            end;
            % 3- retornar 1-dist;
            prob=1-dist;
        end;
        
        function obj=add(obj,SF)
            obj.map.addFrame(SF);
            while sum([obj.map.nodes(:).d]) ~= obj.len
                obj.map.nodes(1).d= obj.map.nodes(1).d - (sum([obj.map.nodes(:).d])-obj.len);
                if obj.map.nodes(1).d <= 0
                    obj.map.adjacency_list(obj.map.adjacency_list(:,1)==1 , :)=[];
                    obj.map.adjacency_list(obj.map.adjacency_list(:,2)==1 , :)=[];
                    obj.map.nodes(1)=[];
                    obj.map.adjacency_list=obj.map.adjacency_list-1;
                end;
            end;
        end;
        
        function d=compareToPath(obj,map,path,path_last_len)
            d=0;
            
            l=0;
            
            ind_path = length(path);
            ind_loc = length(obj.map.nodes);
            
            l_map=path_last_len;
            l_loc=obj.map.nodes(end).d;
            
            while ind_loc > 0 && ind_path > 0
                if l_map == l_loc
                    l=l+l_map;
                    d= d + l_map * obj.map.nodes(ind_loc).compare( map.nodes(path(ind_path)) );
                    ind_loc = ind_loc-1;
                    l_loc = obj.map.nodes( ind_loc ).d;
                    ind_path = ind_path-1;
                    l_map = map.nodes(path(ind_path)).d;
                    continue;
                end;
                if l_map < l_loc
                    l=l+l_map;
                    d= d + l_map * obj.map.nodes(ind_loc).compare( map.nodes(path(ind_path)) );
                    l_loc=l_loc-l_map;
                    ind_path = ind_path-1;
                    if ind_path~=0
                        l_map = map.nodes(path(ind_path)).d;
                    end;
                    continue;
                end;
                if l_loc < l_map
                    l=l+l_loc;
                    d= d + l_loc * obj.map.nodes(ind_loc).compare( map.nodes(path(ind_path)) );
                    l_map=l_map-l_loc;
                    ind_loc = ind_loc-1;
                    if ind_loc~=0
                        l_loc = map.nodes(ind_loc).d;
                    end;
                    continue;
                end;
                
            end;
            d=d/l;
        end;
    end
    
end

