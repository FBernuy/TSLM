function [ output_args ] = drawCity( odom_folder )
%DRAWCITY Summary of this function goes here
%   Detailed explanation goes here
    odom_dir=dir([odom_folder '*.json']);
    
    lats=zeros(1,length(odom_dir));
    lons=zeros(1,length(odom_dir));
    
    for I=1:length(odom_dir)
        aux=parse_json(fileread([odom_folder odom_dir(I).name]));
        lats(I)=aux{1}.gpsLatitude;
        lons(I)=aux{1}.gpsLongitude;
    end;
    lineColors=jet(length(odom_dir));
    for I=2:length(odom_dir)
        line(lons(I-1:I),lats(I-1:I),'LineWidth',1+3*I/length(odom_dir),'Color',lineColors(I,:));%2.5
    end;
    %plot(lons,lats,'-','MarkerSize',10,'LineWidth',2.5); 
    plot_google_map('maptype','satellite');
    
end

