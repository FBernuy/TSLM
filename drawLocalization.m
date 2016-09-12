function [ output_args ] = drawLocalization( mapGT , mapSeg , odom_folder, len )
%DRAWLOCALIZATION Summary of this function goes here
%   Detailed explanation goes here
    [indGT,freqGT]=getTopologicalMap(mapGT);
    [prob,loc]=getLocalizationProb(mapGT,mapSeg,len);
    odom_dir=dir([odom_folder '*.json']);
    
    lats=zeros(1,length(odom_dir));
    lons=zeros(1,length(odom_dir));
    
    for I=1:length(odom_dir)
        aux=parse_json(fileread([odom_folder odom_dir(I).name]));
        lats(I)=aux{1}.gpsLatitude;
        lons(I)=aux{1}.gpsLongitude;
    end;
    lineColors=jet(length(indGT));
    %loops = length(80:length(odom_dir));
    %F(loops) = struct('cdata',[],'colormap',[]);
    v=VideoWriter('test.avi');
    open(v);
    for K=80:length(odom_dir)
        clf;
        hold on;
        for I=2:length(odom_dir)
            [~,ind]=max(indGT(indGT<=I));
            
            %hline=line(lons(I-1:I),lats(I-1:I),'LineWidth',0.01+7*prob(ind,K)/max(prob(:,K)),'Color',lineColors(ind,:));
            plot(lons(I-1:I),lats(I-1:I),'LineWidth',0.01+7*prob(ind,K)/max(prob(:,K)),'Color',[0 0 0]);%lineColors(ind,:));
            %set(hline
            if loc(ind,K)
                line(lons(I-1:I),lats(I-1:I),'LineWidth',0.00+7*loc(ind,K),'Color','r');%2.5 %1+3*prob(ind,K)
            end;
        end;
        hold on;
        plot(lons(K),lats(K),'wo','MarkerSize',8,'MarkerFaceColor','w','MarkerEdgeColor','k')
        hold off;
        %plot(lons,lats,'-','MarkerSize',10,'LineWidth',2.5);
        plot_google_map('maptype','satellite');
        K
        %F(K-79)=getframe;
        F=getframe;
        writeVideo(v,F.cdata);
        pause(0.1);
    end;
    
    %for I=1:length(F)
    %    writeVideo(v,F(I).cdata);
    %end;
    close(v);
end

