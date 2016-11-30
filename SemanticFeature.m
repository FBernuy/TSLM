classdef SemanticFeature<handle
    %SEMANTICFEATURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        h1;
        h2;
        h3;
        d;
        gps;
    end
    
    methods
        function obj = SemanticFeature(image, odometry, gps_input)
            if nargin==0
                obj.h1=zeros(1,length(getCSDatabaseDefinition()));
                obj.h2=obj.h1;
                obj.h3=obj.h1;
                obj.d=0;
                return;
            end;
            [h,w]=size(image);
            obj.h1=hist(reshape(double(image(:,1:floor(w/3))),[],1),0:34);
            obj.h2=hist(reshape(double(image(:,ceil(w/3):floor(2*w/3))),[],1),0:34);
            obj.h3=hist(reshape(double(image(:,ceil(2*w/3):end)),[],1),0:34);
            obj.d=odometry;
            obj.gps=gps_input;
        end
        function obj=add(obj,SF)
            if isa(SF,'SemanticFeature')
                if isempty(obj.gps)
                    obj.gps=SF.gps;
                end;
                if obj.d == 0
                    obj.h1=SF.h1;
                    obj.h2=SF.h2;
                    obj.h3=SF.h3;
                    obj.d=obj.d+SF.d;
                    return;
                end;
                if SF.d == 0
                    return;
                end;
                obj.h1=(obj.h1*obj.d+SF.h1*SF.d)/(obj.d+SF.d);
                obj.h2=(obj.h2*obj.d+SF.h2*SF.d)/(obj.d+SF.d);
                obj.h3=(obj.h3*obj.d+SF.h3*SF.d)/(obj.d+SF.d);
                obj.d=obj.d+SF.d;
                
            end;
        end;
        function dist=compare(obj,SF,bin_list)
            if ~isa(SF,'SemanticFeature')
                error('Invalid Comparisson Type');
            end;
            if nargin == 2
                bin_list=1:length(obj.h1);        %%deafault bin_list
            end;
            %dist=(pdist([obj.h1(bin_list);SF.h1(bin_list)],'cosine')...
            %     +pdist([obj.h2(bin_list);SF.h2(bin_list)],'cosine')...
            %     +pdist([obj.h3(bin_list);SF.h3(bin_list)],'cosine'))/3.0;
            dist=max([pdist([obj.h1(bin_list);SF.h1(bin_list)],'cosine')...
                 ,pdist([obj.h2(bin_list);SF.h2(bin_list)],'cosine')...
                 ,pdist([obj.h3(bin_list);SF.h3(bin_list)],'cosine')]);
        end;
    end
    
end

