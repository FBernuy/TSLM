function [ mapGT , mapSeg ] = getCityMap( db_folder, set_folder , city_folder)
%GETCITYMAP Summary of this function goes here
%   Detailed explanation goes here
    
    image_folder=[db_folder '/leftImg8bit/' set_folder '/' city_folder];
    gt_folder=[db_folder '/gtCoarse/' set_folder '/' city_folder];
    gt_dir=dir([gt_folder '*labelIds.png']);
    
    if ~length(gt_dir)
        gt_folder=[db_folder '/gtFine/' set_folder '/' city_folder];
        gt_dir=dir([gt_folder '*labelIds.png']);
    end;
    
    seg_folder=[db_folder '/segmented/' set_folder '/' city_folder];
    odom_folder=[db_folder '/vehicle/' set_folder '/' city_folder];
    im_dir=dir([ image_folder '/*leftImg8bit.png']);
    
    seg_dir=dir([seg_folder '/*leftImg8bit.png']);
    
    mapGT=[];
    mapSeg=[];
    odom=0;
    pose=[];
    
    if length(im_dir) ~= length(gt_dir) || length(im_dir) ~= length(seg_dir)
        disp 'Error: Folder content mismatch';
        return;
    end;
    
    labels=getCSDatabaseDefinition();
    color_labels=zeros(length(labels),3);
    for KK=1:length(labels)
        color_labels(KK,:)=labels(KK).color;
    end;
    for I=1:length(im_dir)
        if I==1
            aux=parse_json(fileread([odom_folder im_dir(I).name(1:end-15) 'vehicle.json']));
            pose=[aux{1}.gpsLatitude aux{1}.gpsLongitude];
        end;
        aux=parse_json(fileread([odom_folder im_dir(I).name(1:end-15) 'vehicle.json']));
        odom=odom+lldistkm(pose,[aux{1}.gpsLatitude aux{1}.gpsLongitude]);
        pose=[aux{1}.gpsLatitude aux{1}.gpsLongitude];
        
        im=imread([image_folder im_dir(I).name]);
        
        im_seg=imread([seg_folder seg_dir(I).name]);
        im_seg_label=rgb2ind(im_seg,color_labels/255);
        
        mapGT=[mapGT getDescription(im,imread([gt_folder gt_dir(I).name]),odom)];
        mapSeg=[mapSeg getDescription(im,im_seg_label,odom)];
    end
    
end

