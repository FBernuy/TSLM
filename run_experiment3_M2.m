clear
load('fcfm_M2.mat')
load('fcfm_M3.mat')
param=[0.2,1,0,5];

err=[];

param1=[0.00001,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8];
REC_VID=false;
GET_ERR=true;
N_ITER=1;
DISPLAY_FREQ=10;
USE_ORIENTED=true;

feats=addFeatureOrientation(fcfm_M3);

%parfor it=1:N_ITER
%% Mapping
clc;display('Mapping');
%param(1)=param1(it);
if ~USE_ORIENTED
    mm=Mapping([fcfm_M2_1 fcfm_M2_2],fcfm_M2_ignore,fcfm_M2_intersections,param(1),param(4),USE_ORIENTED);
    %mm=Mapping([fcfm_M2_1 fcfm_M2_2],fcfm_M2_ignore,fcfm_M2_intersections,param1(it),param(4),USE_ORIENTED);
else
    mm=Mapping(addFeatureOrientation([fcfm_M2_1 fcfm_M2_2]),fcfm_M2_ignore,fcfm_M2_intersections,param(1),param(4),USE_ORIENTED);
    %mm=Mapping(addFeatureOrientation([fcfm_M2_1 fcfm_M2_2]),fcfm_M2_ignore,fcfm_M2_intersections,param1(it),param(4),USE_ORIENTED);
end;

GTSM=mm.GTSM;
clf;

hold on
h_map=GTSM.display();
%plot_google_map
set(gca,'position',[0 0 1 1],'units','normalized');
h_pos=0;
hold on



%% Localization
%cummulated_conf
parfor it=1:N_ITER
    clc;display('Localization');
    npart=param(2);
    init_prob=zeros(1,length(GTSM.nodes)); init_prob(:)=1/length(GTSM.nodes);%1)=1;%6%4%:)=
    %param2: Particles number, 1 for Forward Loc. (100)
    if npart==1
        PF=ForwardLocalization(GTSM,init_prob);
    else
        PF=ParticleLocalization(npart, GTSM, init_prob);
        
        %distribuir particulas:
        cumulative=cumsum([PF.map.nodes(:).d]);
        for I=1:length(PF.particles)
            r=cumulative(end)*I/length(PF.particles);
            nid=find( r >= cumulative,1,'last');
            if isempty(nid)
                nid=1;
            end;
            PF.particles(I).id=nid;
            PF.particles(I).length=r-cumulative(nid);
            PF.particles(I).weight=1/length(PF.particles);
        end;
        
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
    
    if REC_VID
        v = VideoWriter('vid.avi');
        v.FrameRate=30;
        v.Quality=80;
        open(v);
    end;
    %h_part(npart)=0;
    
    tmp_time=0;
    dist=0;
    cc=0;
    kk=0;
    init_point=randi(round(length(feats)*3/4),1);
    for I=init_point:length(feats)
        clc;display('Localization');
        %T
        if feats(I).d < 0.00004
            %    feats(I).d=0;
        end;
        DO.add(feats(I));
        dist=dist+feats(I).d;
        if ~rem(I,param(4))                                                            %param4: Localization frequency, each N frames (5)
            I
            kk
            if I==110
            end;
            %cc;
            tic;
            temp_pose=PF.update(DO,dist);
            tmp_time=(tmp_time*((I/param(4))-1)+toc)*param(4)/I;
            tmp_time
            dist=0;
            poses(I)=temp_pose.id;
            mean_len=temp_pose.length;
            conf(I)=DO.likelihood(GTSM,poses(I),mean_len);
            cc=conf(I);
            if isa(PF,'ParticleLocalization')
            if I>30*param(4)
                if mean(conf(I-29*param(4):param(4):I))<0.5
                    %PF.particlesReset();
                end;
            end;
            end;
            
            if isa(PF,'ForwardLocalization')
                kk=PF.distribution(PF.pose.id)
            else
                kk=sum([PF.particles([PF.particles(:).id]==PF.pose.id).weight])
            end;
            %CAAMBIOOO
            
            
           % if kk > 0.3 %&& sum([feats(init_point:I).d])>0.1
                tmp_list=GTSM.nodes(poses(I)).gps_list;
                tmp_dists=tmp_list(:,1)*0;
                for J=1:length(tmp_list(:,1))
                    tmp_dists(J)=lldistkm(tmp_list(J,:),feats(I).gps);
                end;
                if any(tmp_dists < 0.05)
                %if any([PF.map.prevNodes(PF.pose.id)  PF.pose.id PF.map.nextNodes(PF.pose.id) ] == feat_GT(I))
                    err(it)=[I-init_point];
                    derr(it)=sum([feats(init_point:I).d]);
                    derr2(it)=min(tmp_dists);
                    break;
           %     else
                end;
                if I-init_point>3000
                    err(it)=[NaN];
                    derr(it)=sum([feats(init_point:I).d]);
                    derr2(it)=min(tmp_dists);
                    break;
                end;
           % end;
            
            if local_map_len==0                                                         %param3: Local Map Length, 0 for direct obs (0.5)
                if ~USE_ORIENTED
                    DO=DirectObservation(SemanticFeature());
                else
                    DO=OrientedObservation(OrientedSemanticFeature());
                end;
            else
                %DO=LocalMapObservation(local_map_len);%0.5
            end;
        end;
    end;
    %continue;
    
    hold off
    if REC_VID
        close(v);
    end;
end;