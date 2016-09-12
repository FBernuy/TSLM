function [ label_image ] = colorToLabel( image )
%COLORTOLABEL Summary of this function goes here
%   Detailed explanation goes here
    labels=getCSDatabaseDefinition();
    
    label_image=0*image(:,:,1);
    [h,w,~]=size(image);
    
    image1=image(:,:,1);
    image2=image(:,:,2);
    image3=image(:,:,3);
    
    for K=1:length(labels)
        temp1=0*label_image;
        temp2=0*label_image;
        temp3=0*label_image;
        temp1(find(image1==labels(K).color(1)))=1;
        temp2(find(image2==labels(K).color(2)))=1;
        temp3(find(image3==labels(K).color(3)))=1;
        label_image(find(temp1 & temp2 & temp3))=labels(K).id;
    end;
end

