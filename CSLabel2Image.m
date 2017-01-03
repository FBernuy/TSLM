function [ im_out ] = CSLabel2Image( label_image )
%DISPLAYLABELIMAGE Summary of this function goes here
%   Detailed explanation goes here
    
    CSDD=getCSDatabaseDefinition();
    color_map=zeros(256,3);
    for I=0:18
        for J=1:length(CSDD)
            if I==CSDD(J).trainId 
                color_map(I+1,:)=CSDD(J).color/255;
            end;
        end;
    end;
    im_out=label2rgb(label_image,color_map(2:end,:),color_map(1,:));
end

