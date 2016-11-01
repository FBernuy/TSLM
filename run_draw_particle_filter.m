%% Mapping
clear;
load('fcfmclass.mat')

GTSM=TopologicalSemanticMap();

GTSM.setDistanceMapping(0.05);
%GTSM.setFrameMapping(100);
%GTSM.setThresholdMapping(0.15);

for I=1:length(fcfm_2_features)
    GTSM.addFrame(fcfm_2_features(I));
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
%% Localization

feats=fcfm_1_features;
init_prob=zeros(1,length(GTSM)); init_prob(4)=1;%6
npart=50;
PF=ParticleLocalization(npart, GTSM, init_prob);

poses=zeros(1,length(feats)); conf=zeros(1,length(poses));

DO=DirectObservation(SemanticFeature());
for I=1:length(feats)
    clc;
    I
    if feats(I).d < 0.0003
        feats(I).d=0;
    end;
    DO.add(feats(I));
    if rem(I,5)
       
        temp_pose=PF.update(DO);
        poses(I)=temp_pose.id;
        conf(I)=DO.likelihood(GTSM,poses(I));
        %figure(2);
        %clf;
        
        %figure(1);
        clf;
        hold on
        plot(lat,lon,'-ro')
        for J=1:npart
            if isempty(GTSM.nextNodes(PF.particles(J).id))
                plot(GTSM.nodes(PF.particles(J).id).gps(2),GTSM.nodes(PF.particles(J).id).gps(1),'-bx', 'MarkerSize', 8, 'LineWidth',1);
            else
                nid=GTSM.nextNodes(PF.particles(J).id);
                nid=nid(1);
                ratio=PF.particles(J).length/GTSM.nodes(PF.particles(J).id).d;
                temp_gps=GTSM.nodes(PF.particles(J).id).gps*(1-ratio)+GTSM.nodes(nid).gps*ratio;
                plot(temp_gps(2),temp_gps(1),'-bx', 'MarkerSize', 8, 'LineWidth',2);
            end;
            
            
        end;
        
        if isempty(GTSM.nextNodes(temp_pose.id))
            plot([GTSM.nodes(temp_pose.id).gps(2)],[GTSM.nodes(temp_pose.id).gps(1)],'-yo', 'MarkerSize', 12, 'LineWidth',2);
        else
            
            plot([GTSM.nodes(temp_pose.id).gps(2) GTSM.nodes(temp_pose.id+1).gps(2)],[GTSM.nodes(temp_pose.id).gps(1) GTSM.nodes(temp_pose.id+1).gps(1)],'-yo', 'MarkerSize', 12, 'LineWidth',2);
        end;
        plot(feats(I).gps(2),feats(I).gps(1),'-kx', 'MarkerSize', 12, 'LineWidth',2);
        
        drawnow
        %plot_google_map
        hold off
        
        DO=DirectObservation(SemanticFeature());
        
    end;
end;
