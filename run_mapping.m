im_folder='e:/fcfm/bag3seg/';
im_dir=dir([im_folder '*.png']);

features=struct([]);
features(length(im_dir)).dist=0;


[a,b]=textread([im_folder 'gps.txt'],'%s %f');
lat_base=b(1:2:end);
lon_base=b(2:2:end);

gps_estimated=zeros(length(im_dir),2);

gps_estimated(:,1)=interp1(lat_base,1:(length(lat_base)-1)/(length(im_dir)-1):length(lat_base));
gps_estimated(:,2)=interp1(lon_base,1:(length(lon_base)-1)/(length(im_dir)-1):length(lon_base));

%plot(gps_estimated(:,1),gps_estimated(:,2));
fcfm_3_features(length(im_dir))=SemanticFeature();

parfor I=1:length(im_dir)
    I;
    im_base=imread([im_folder im_dir(I).name]);
    im=im_base(65:end,373:(372+1280),:);
    %imshow(im);
    im_label=colorToLabel(im);
    dist=0;
    if I~=1
        dist=lldistkm(gps_estimated(I-1,:),gps_estimated(I,:));
    end;
    fcfm_3_features(I)=SemanticFeature(im_label,dist,gps_estimated(I,:));
end;

%% Mapping

GTSM=TopologicalSemanticMap();

GTSM.setDistanceMapping(0.025);
%GTSM.setFrameMapping(100);
%GTSM.setThresholdMapping(0.2);

for I=1:length(fcfm_2_features)
    GTSM.addFrame(fcfm_2_features(I));
end;

%% Localization

init_prob=zeros(1,length(GTSM));
init_prob(6)=1;%6

PF=ParticleLocalization(20, GTSM, init_prob);

poses=zeros(1,length(fcfm_1_features));
conf=zeros(1,length(poses));

for I=1:length(fcfm_1_features)
    clc;
    I
    DO=DirectObservation(fcfm_1_features(I));
    temp_pose=PF.update(DO);
    poses(I)=temp_pose.id;
    conf(I)=DO.likelihood(GTSM,poses(I));
end;
