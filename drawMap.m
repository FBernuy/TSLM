function [ output_args ] = drawMap( odom_folder , indMap )
%DRAWMAP Summary of this function goes here
%   Detailed explanation goes here

    odom_dir=dir([odom_folder '*.json']);
    
    lats=zeros(1,length(odom_dir));
    lons=zeros(1,length(odom_dir));
    
    for I=1:length(odom_dir)
        aux=parse_json(fileread([odom_folder odom_dir(I).name]));
        lats(I)=aux{1}.gpsLatitude;
        lons(I)=aux{1}.gpsLongitude;
    end;
    
    
    
    map_lats=zeros(1,length(indMap));
    map_lons=zeros(1,length(indMap));
    for I=1:length(indMap)
        aux=parse_json(fileread([odom_folder odom_dir(indMap(I)).name]));
        map_lats(I)=aux{1}.gpsLatitude;
        map_lons(I)=aux{1}.gpsLongitude;
        
    end;
    
    plot(lons,lats,'r-','MarkerSize',10,'LineWidth',2.5)
    hold on;
    %plot(map_lons,map_lats,'bo','MarkerSize',10,'LineWidth',2.5)
    for I=1:length(indMap)
        text(map_lons(I),map_lats(I),num2str(I),'HorizontalAlignment','center','BackgroundColor',[.9 .9 .9]);
    end;
    hold off;
    plot_google_map('maptype','satellite');
    
end