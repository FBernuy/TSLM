function [ output ] = getDescription( color_image , label_image , odom, varargin )
%GETDESCRIPTION Summary of this function goes here
%   Detailed explanation goes here

display=false;

labels=getCSDatabaseDefinition();
figure(1);
subplot(1,3,1);   imshow(color_image(:,1:round(end/3),:));
subplot(1,3,2);   imshow(color_image(:,round(end/3):round(2*end/3),:));
subplot(1,3,3);   imshow(color_image(:,round(2*end/3):end,:));

left_label_image=label_image(:,1:round(end/3));
center_label_image=label_image(:,round(end/3):round(2*end/3));
right_label_image=label_image(:,round(2*end/3):end);

[left_flat_im,left_flat_ind,left_flat_rat]=sortFlatLabels(left_label_image,labels);
[right_flat_im,right_flat_ind,right_flat_rat]=sortFlatLabels(right_label_image,labels);
[center_flat_im,center_flat_ind,center_flat_rat]=sortFlatLabels(center_label_image,labels);
if(display)
    figure(2);
    subplot(1,3,1);   drawLabels(left_flat_im,labels);
    subplot(1,3,2);   drawLabels(center_flat_im,labels);
    subplot(1,3,3);   drawLabels(right_flat_im,labels);
end;
[left_build_im,left_build_ind,left_build_rat]=sortBuildingLabels(left_label_image,labels);
[right_build_im,right_build_ind,right_build_rat]=sortBuildingLabels(right_label_image,labels);
[center_build_im,center_build_ind,center_build_rat]=sortBuildingLabels(center_label_image,labels);
if(display)
    figure(3);
    subplot(1,3,1);   drawLabels(left_build_im,labels);
    subplot(1,3,2);   drawLabels(center_build_im,labels);
    subplot(1,3,3);   drawLabels(right_build_im,labels);
end;

[left_object_im,left_object_ind,left_object_rat]=sortObjectLabels(left_label_image,labels);
[right_object_im,right_object_ind,right_object_rat]=sortObjectLabels(right_label_image,labels);
[center_object_im,center_object_ind,center_object_rat]=sortObjectLabels(center_label_image,labels);
if(display)
    figure(4);
    subplot(1,3,1);   drawLabels(left_object_im,labels);
    subplot(1,3,2);   drawLabels(center_object_im,labels);
    subplot(1,3,3);   drawLabels(right_object_im,labels);
end;

output=struct;

output.left=struct;
output.center=struct;
output.right=struct;

output.left.flat={labels(left_flat_ind).name};
output.left.build={labels(left_build_ind).name};
%output.left.object={labels(left_object_ind).name};

output.center.flat={labels(center_flat_ind).name};
output.center.build={labels(center_build_ind).name};
%output.center.object={labels(center_object_ind).name};

output.right.flat={labels(right_flat_ind).name};
output.right.build={labels(right_build_ind).name};
%output.right.object={labels(right_object_ind).name};

output.dist=odom;

if isempty(output.left.flat)
    output.left.flat{1}='none';
end;
if isempty(output.left.build)
    output.left.build{1}='none';
end;
%if isempty(output.left.object)
%    output.left.object{1}='none';
%end;

if isempty(output.center.flat)
    output.center.flat{1}='none';
end;
if isempty(output.center.build)
    output.center.build{1}='none';
end;
%if isempty(output.center.object)
%    output.center.object{1}='none';
%end;

if isempty(output.right.flat)
    output.right.flat{1}='none';
end;
if isempty(output.right.build)
    output.right.build{1}='none';
end;
%if isempty(output.right.object)
%    output.right.object{1}='none';
%end;


end

function [im_out,ind_out,ratios_out] = sortFlatLabels(label_image , labels)

flat_IDs=[];
flat_image=label_image*0;
for I=1:size(labels,1)
    if(strcmp(labels(I).category,'flat') || strcmp(labels(I).name,'terrain'))
        flat_image=flat_image+uint8(label_image==labels(I).id);
        flat_IDs=[flat_IDs I-1];
    end;
end;

total_flat_pixels=nnz(flat_image);
partial_flat_pixels=zeros(1,size(labels,1));
for I=1:size(labels,1)
    if ~labels(I).id
        continue;
    end;
    partial_flat_pixels(I)=nnz((flat_image.*label_image)==labels(I).id);
end;
ratios=partial_flat_pixels/total_flat_pixels;
[~,ind]=sort(partial_flat_pixels/total_flat_pixels,'descend');
ind_out=ind(find(ratios(ind)>0.1));
ratios_out=ratios(ind(find(ratios(ind)>0.1)));
im_out=flat_image.*label_image;
end

function [im_out,ind_out,ratios_out] = sortBuildingLabels(label_image , labels)

flat_IDs=[];
flat_image=label_image*0;
for I=1:size(labels,1)
    if(strcmp(labels(I).category,'construction') || strcmp(labels(I).name,'vegetation'))
        flat_image=flat_image+uint8(label_image==labels(I).id);
        flat_IDs=[flat_IDs I-1];
    end;
end;

total_flat_pixels=nnz(flat_image);
partial_flat_pixels=zeros(1,size(labels,1));
for I=1:size(labels,1)
    if ~labels(I).id
        continue;
    end;
    partial_flat_pixels(I)=nnz((flat_image.*label_image)==labels(I).id);
end;
ratios=partial_flat_pixels/total_flat_pixels;
[~,ind]=sort(partial_flat_pixels/total_flat_pixels,'descend');
ind_out=ind(find(ratios(ind)>0.1));
ratios_out=ratios(ind(find(ratios(ind)>0.1)));
im_out=flat_image.*label_image;
end

function [im_out,ind_out,ratios_out] = sortObjectLabels(label_image , labels)

flat_IDs=[];
flat_image=label_image*0;
for I=1:size(labels,1)
    if(strcmp(labels(I).category,'object') )%|| strcmp(labels(I).name,'vegetation'))
        flat_image=flat_image+uint8(label_image==labels(I).id);
        flat_IDs=[flat_IDs I-1];
    end;
end;

total_flat_pixels=nnz(flat_image);
partial_flat_pixels=zeros(1,size(labels,1));
for I=1:size(labels,1)
    if ~labels(I).id
        continue;
    end;
    if strcmp(labels(I).name,'polegroup')       % Change polegroup for pole.
        partial_flat_pixels(I-1)=nnz((flat_image.*label_image)==labels(I).id);
    else
        partial_flat_pixels(I)=nnz((flat_image.*label_image)==labels(I).id);
    end;
end;
ratios=partial_flat_pixels/total_flat_pixels;
[~,ind]=sort(partial_flat_pixels/total_flat_pixels,'descend');
ind_out=ind(find(ratios(ind)>0.1));
ratios_out=ratios(ind(find(ratios(ind)>0.01)));
im_out=flat_image.*label_image;
end