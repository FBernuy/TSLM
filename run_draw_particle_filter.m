%% Mapping
clear;
load('fcfmclass.mat')

GTSM=TopologicalSemanticMap();

%GTSM.setDistanceMapping(0.1);
%GTSM.setFrameMapping(100);
GTSM.setThresholdMapping(0.4);
feat_map=fcfm_2_features;
feat_map_index(length(feat_map))=0;
for I=1:length(feat_map)
    if feat_map(I).d < 0.0003
        feat_map(I).d=0;
    end;
    GTSM.addFrame(feat_map(I));
    feat_map_index(I)=length(GTSM.nodes);
end;


lon(length(GTSM.nodes))=0;
lat(length(GTSM.nodes))=0;
dists(length(GTSM.nodes))=0;
for I=1:length(GTSM.nodes)
    lon(I)=GTSM.nodes(I).gps(1);
    lat(I)=GTSM.nodes(I).gps(2);
    if I~=1
        dists(I)=GTSM.nodes(I).compare(GTSM.nodes(I-1));
    end;
end;

plot(lat,lon,'-ro')
plot_google_map
set(gca,'position',[0 0 1 1],'units','normalized')
%% Localization

v = VideoWriter('vid.avi');
v.FrameRate=10;
v.Quality=80;
open(v);

feats=fcfm_1_features;
init_prob=zeros(1,length(GTSM.nodes)); init_prob(3)=1;%6%4
npart=100;
PF=ParticleLocalization(npart, GTSM, init_prob);
%PF=ForwardLocalization(GTSM,init_prob);
poses=zeros(1,length(feats)); conf=zeros(1,length(poses));

DO=DirectObservation(SemanticFeature());
%DO=LocalMapObservation(0.5);
h_part(npart)=0;

%clf;
hold on
h_map=plot(lat,lon,'-ro');
%plot_google_map
h_pos=0;

cc=0;
dist=0;
feat_GT(length(feats))=0;
parfor I=1:length(feats)
     %% Buscar pose GT: Buscar imagen mas cercana y tomar su nodo como GT
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

for I=1:length(feats)
    clc;
    
    if feats(I).d < 0.0003
        feats(I).d=0;
    end;
    DO.add(feats(I));
    dist=dist+feats(I).d;
    if ~rem(I,5)
        I
        cc
        temp_pose=PF.update(DO,dist);
        dist=0;
        poses(I)=temp_pose.id;
        mean_len=temp_pose.length;
        conf(I)=DO.likelihood(GTSM,poses(I),mean_len);
        cc=conf(I);
        PF.display();
        h_loc=plot(feats(I).gps(2),feats(I).gps(1),'-kx', 'MarkerSize', 12, 'LineWidth',2);
        
       
        
        %min_ind
        h_locgt=plot(GTSM.nodes(feat_GT(I)).gps(2),GTSM.nodes(feat_GT(I)).gps(1),'-rx', 'MarkerSize', 15, 'LineWidth',2);
        drawnow
        
        delete(h_loc);
        delete(h_locgt);
        
        DO=DirectObservation(SemanticFeature());
    end;
end;
hold off
close(v);

error_frame_per=mean([poses(5:5:end) - feat_GT(5:5:end)] ~=0);

error_distance(length(poses(5:5:end)))=0;
for I=1:length(poses(5:5:end))
    if poses(5*I) == feat_GT(5*I)
        error_distance(I)=0;
    else
        if feat_GT(5*I) == length(GTSM.nodes)
            error_distance(I)=lldistkm(feats(5*I).gps,GTSM.nodes(feat_GT(5*I)).gps);
        else
            error_distance(I)=min(lldistkm(feats(5*I).gps,GTSM.nodes(feat_GT(5*I)).gps),...
                                  lldistkm(feats(5*I).gps,GTSM.nodes(feat_GT(5*I)+1).gps));
        end;
    end;
end;
error_distance=mean(error_distance(error_distance~=0));

a=[false, [poses(5:5:end) - feat_GT(5:5:end)] ~=0 , false];
ib=strfind(a,[0,1]);
ie=strfind(a,[1,0])-1;
error_length_frames=mean([ie-ib]');

error_dist_per=sum([feats([poses(5:5:end) - feat_GT(5:5:end)] ~=0).d])/sum([feats(:).d]);
sum([feats([poses(5:5:end) - feat_GT(5:5:end)] ~=0).d]);

error_length_distance=0;
for I=1:length(ib)
    error_length_distance=error_length_distance+ sum([feats(ib(I):ie(I)).d]);
end;
error_length_distance=error_length_distance/length(ib);
