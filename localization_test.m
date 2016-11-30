function [ err ] = localization_test( param , it)
%LOCALIZATION_TEST Summary of this function goes here
%   Return the error of the lecalization seted with parameters defined in
%   param: 
%   1- Mapping Threshold (0.4)
%   2- Particles Number, 1 for Forward Localization. (50)
%   3- Local Map Length, 0 for direct observation. (0.5)
%   4- Localization frequency as number of accumulated frames. (5)
%   err:
%   1-  error_frame_per: ratio of wrong located frames of the total frames
%   2-  error_dist_per: ratio of the mislocalized distance run of the exp.
%   3-  error_length_frames: mean number of wrong frames per event
%   4-  error_length_distance: mean distance of wrong localization events
%   5-  error_distance: average distance to GT when wrong

%% Mapping
%clear;
clc;display('Mapping');
load('fcfmclass2.mat')
err=[];
GTSM=TopologicalSemanticMap();

%GTSM.setDistanceMapping(0.1);
%GTSM.setFrameMapping(100);
GTSM.setThresholdMapping(param(1));%0.4                                     %param1: Mapping threshold (0.4)
feat_map=fcfm_2_features;
feat_map_index(length(feat_map))=0;
tmp_feat=SemanticFeature();
for I=1:length(feat_map)
    if feat_map(I).d < 0.00004
        feat_map(I).d=0;
    end;
    tmp_feat.add(feat_map(I));
    feat_map_index(I)=length(GTSM.nodes);
    if ~rem(I,param(4))    
        GTSM.addFrame(tmp_feat);
        tmp_feat=SemanticFeature();
        feat_map_index( (I-param(4)+1):I)=length(GTSM.nodes);
    end;
    
end;


%GTSM.addAdjacency(length(GTSM.nodes),1);

lon(length(GTSM.nodes))=0;
lat(length(GTSM.nodes))=0;
dists(length(GTSM.nodes))=0;
parfor I=1:length(GTSM.nodes)
    lon(I)=GTSM.nodes(I).gps(1);
    lat(I)=GTSM.nodes(I).gps(2);
    if I~=1
        dists(I)=GTSM.nodes(I).compare(GTSM.nodes(I-1));
    end;
end;

feats=fcfm_1_features;
init_prob=zeros(1,length(GTSM.nodes)); init_prob(:)=1/length(GTSM.nodes);%1)=1;%6%4%


%% GT definition
cc=0;
dist=0;
feat_GT(length(feats))=0;
parfor I=1:length(feats)
    min_dist=1000;
    min_ind=0;
    for J=1:length(feat_map)
        d=lldistkm(feats(I).gps,feat_map(J).gps);
        if d<min_dist
            min_dist=d;
            min_ind=feat_map_index(J);
        end;
    end;
    feat_GT(I)=min_ind;
end;


clf;
figure(1);
plot(lat,lon,'-ro')
plot_google_map
set(gca,'position',[0 0 1 1],'units','normalized')
%% Iterations
for T=1:it
    
    %% Localization
    clc;display('Localization');
    npart=param(2);  
    %param2: Particles number, 1 for Forward Loc. (100)
    if npart==1
        PF=ForwardLocalization(GTSM,init_prob);
    else
        PF=ParticleLocalization(npart, GTSM, init_prob);
    end;
   
    poses=zeros(1,length(feats)); conf=zeros(1,length(poses));
    DO=[];
    local_map_len=param(3);
    if local_map_len==0                                                         %param3: Local Map Length, 0 for direct obs (0.5)
        DO=DirectObservation(SemanticFeature());
    else
        DO=LocalMapObservation(local_map_len);%0.5
    end;
    
    
    
    
    %% Localization loop
    %load gong
    %sound(y,Fs)
    
    %v = VideoWriter('vid.avi');
    %v.FrameRate=10;
    %v.Quality=80;
    %open(v);
    
    
    
    h_part(npart)=0;
    
    hold on
    h_map=plot(lat,lon,'-ro');
    %plot_google_map
    h_pos=0;
    
    dist=0;
    init_point=1;%randi(round(length(feats)*3/4),1);
    for I=init_point:length(feats)
        clc;display('Localization');
        T
        if feats(I).d < 0.00004
            feats(I).d=0;
        end;
        DO.add(feats(I));
        dist=dist+feats(I).d;
        if ~rem(I,param(4))                                                            %param4: Localization frequency, each N frames (5)
            I
            if I==110
            end;
            cc;
            %tic;
            temp_pose=PF.update(DO,dist);
            %toc;
            dist=0;
            poses(I)=temp_pose.id;
            mean_len=temp_pose.length;
            conf(I)=DO.likelihood(GTSM,poses(I),mean_len);
            cc=conf(I);
            
            figure(1);
            PF.display();
            h_loc=plot(feats(I).gps(2),feats(I).gps(1),'-rx', 'MarkerSize', 12, 'LineWidth',2);
            
            %min_ind
            %h_locgt=plot(GTSM.nodes(feat_GT(I)).gps(2),GTSM.nodes(feat_GT(I)).gps(1),'-rx', 'MarkerSize', 15, 'LineWidth',2);
            %if PF.pose.id==length(GTSM.nodes)
            %    h_locgt=plot(GTSM.nodes(PF.pose.id).gps(2),...
            %                 GTSM.nodes(PF.pose.id).gps(1),...
            %             '-kx', 'MarkerSize', 15, 'LineWidth',2);
            %else
            %     h_locgt=plot(GTSM.nodes(PF.pose.id).gps(2)*((GTSM.nodes(PF.pose.id).d-PF.pose.length)/GTSM.nodes(PF.pose.id).d)+GTSM.nodes(PF.pose.id+1).gps(2)*(PF.pose.length)/GTSM.nodes(PF.pose.id).d,...
            %                  GTSM.nodes(PF.pose.id).gps(1)*((GTSM.nodes(PF.pose.id).d-PF.pose.length)/GTSM.nodes(PF.pose.id).d)+GTSM.nodes(PF.pose.id+1).gps(1)*(PF.pose.length)/GTSM.nodes(PF.pose.id).d,...
            %                  '-kx', 'MarkerSize', 15, 'LineWidth',2);
            %end
            %figure(2);
            %plot(PF.distribution);
%             if isa(PF,'ForwardLocalization')
%                 kk=PF.distribution(PF.pose.id)
%             else
%                 kk=sum([PF.particles([PF.particles(:).id]==PF.pose.id).weight])
%             end;
%             if kk > 0.5
%                 if any([PF.map.prevNodes(PF.pose.id)  PF.pose.id PF.map.nextNodes(PF.pose.id) ] == feat_GT(I))
%                     err=[err I-init_point];
%                     break;
%                 else
%                     err=[err NaN];
%                     
%                     break;
%                 end;
%             end;
            
            drawnow
            %frame = getframe;
            %writeVideo(v,frame);
            delete(h_loc);
            %        delete(h_locgt);
            
            if local_map_len==0                                                         %param3: Local Map Length, 0 for direct obs (0.5)
                DO=DirectObservation(SemanticFeature());
            else
                %DO=LocalMapObservation(local_map_len);%0.5
            end;
        end;
    end;
    %continue;
    
    hold off
    %close(v);
    
    %% Error calculation
    clc;display('Error calculation');
    
    a=[false, [poses(param(4):param(4):end) - feat_GT(param(4):param(4):end)] ~=0 , false];
    ib=strfind(a,[0,1]);
    ie=strfind(a,[1,0])-1;
    
    error_frame_per=mean([poses(param(4):param(4):end) - feat_GT(param(4):param(4):end)] ~=0);
    
    error_dist_per=0;
    for I=1:length(ib)
        error_dist_per=error_dist_per+ sum([feats(param(4)*(ib(I)-1)+1:param(4)*ie(I)).d]);
    end;
    error_dist_per=error_dist_per/sum([feats(:).d]);
    
    error_distance(length(poses(param(4):param(4):end)))=0;
    for I=1:length(poses(param(4):param(4):end))
        if poses(param(4)*I) == feat_GT(param(4)*I)
            error_distance(I)=0;
        else
            if feat_GT(param(4)*I) == length(GTSM.nodes)
                error_distance(I)=lldistkm(feats(param(4)*I).gps,GTSM.nodes(feat_GT(param(4)*I)).gps);
            else
                error_distance(I)=min(lldistkm(feats(param(4)*I).gps,GTSM.nodes(feat_GT(param(4)*I)).gps),...
                    lldistkm(feats(param(4)*I).gps,GTSM.nodes(feat_GT(param(4)*I)+1).gps));
            end;
        end;
    end;
    error_distance=mean(error_distance(error_distance~=0));
    
    
    error_length_frames=mean([ie-ib]');
    
    
    sum([feats([poses(param(4):param(4):end) - feat_GT(param(4):param(4):end)] ~=0).d]);
    
    error_length_distance=0;
    for I=1:length(ib)
        error_length_distance=error_length_distance+ sum([feats(param(4)*(ib(I)):param(4)*ie(I)).d]);
    end;
    error_length_distance=error_length_distance/length(ib);
    
    
    error_frame_per2=mean(abs([poses(param(4):param(4):end) - feat_GT(param(4):param(4):end)]) > 1);
    
    a2=[false, abs([poses(param(4):param(4):end) - feat_GT(param(4):param(4):end)]) > 1 , false];
    ib2=strfind(a,[0,1]);
    ie2=strfind(a,[1,0])-1;
    
    error_dist_per2=0;
    for I=1:length(ib2)
        error_dist_per2=error_dist_per2+ sum([feats(param(4)*(ib2(I)-1)+1:param(4)*ie2(I)).d]);
    end;
    error_dist_per2=error_dist_per/sum([feats(:).d]);
    
    
    err{T}=[error_frame_per error_dist_per error_length_frames error_length_distance error_distance error_frame_per2 error_dist_per2 ];
    
    
end;
end



