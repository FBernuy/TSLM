classdef DirectObservation < SemanticObservation
    %DIRECTOBSERVATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SF;
        bin_list;
    end
    
    methods
        function obj=DirectObservation(SF)
            obj.SF=SemanticFeature();
             if isa(SF,'SemanticFeature')
                for I=1:length(SF)
                    obj.SF.add(SF(I));
                end;
            end;
            [ backgnd, flat, other ] = getCategoriesDefinition(  );
            temp=SemanticFeature();
            obj.bin_list=temp.h1==-1;
            obj.bin_list([backgnd other])=true;
           
        end;
        function prob=likelihood(obj,map,ind)
            prob=1-obj.SF.compare(map.nodes(ind),obj.bin_list);
        end
        function obj=add(obj,SF)
            obj.SF.add(SF);
        end;
    end
    
end

