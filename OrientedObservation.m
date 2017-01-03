classdef OrientedObservation < SemanticObservation
    %ORIENTEDOBSERVATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SF;
        bin_list;
    end
    
    methods
        function obj=OrientedObservation(SF)
            obj.SF=OrientedSemanticFeature();
            if isa(SF,'OrientedSemanticFeature')
                for I=1:length(SF)
                    obj.SF.add(SF(I));
                end;
            end;
            [ backgnd, flat, other ] = getCategoriesDefinition(  );
            temp=OrientedSemanticFeature();
            obj.bin_list=temp.h1==-1;
            obj.bin_list([backgnd other])=true;
            
        end;
        
        function prob=likelihood(obj,map,ind,len)
            %prob=1-obj.SF.compare(map.nodes(ind),obj.bin_list);
            prob=exp(-obj.SF.compare(map.nodes(ind),obj.bin_list)+0.25*abs(-cos(obj.SF.orientation-map.nodes(ind).orientation)));
        end
        function obj=add(obj,SF)
            obj.SF.add(SF);
        end;
    end
    
end

