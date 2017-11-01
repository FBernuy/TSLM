clear
load('fcfm_M2.mat')
load('fcfm_M3.mat')
param=[0.3,1500,0,5];

param1=[0.00001,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8];
REC_VID=true;
GET_ERR=true;
N_ITER=1;
DISPLAY_FREQ=1;
USE_ORIENTED=true;

performance=[];
feats=addFeatureOrientation(fcfm_M3);
%parfor
for it=1:N_ITER
%% Mapping
clc;display('Mapping');
%param(1)=param1(it);
%mm=Mapping([fcfm_M2_1 fcfm_M2_2],fcfm_M2_ignore,fcfm_M2_intersections,param1(it),param(4),USE_ORIENTED);
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
 plot_google_map('MapType', 'roadmap','ShowLabels',0)
set(gca,'position',[0 0 1 1],'units','normalized');
h_pos=0;
hold on



%% Localization
%cummulated_conf
%parfor it=1:N_ITER
    clc;display('Localization');
    npart=param(2);
    init_prob=zeros(1,length(GTSM.nodes)); init_prob(1)=1;%6%4%:)=1/length(GTSM.nodes);%
    %param2: Particles number, 1 for Forward Loc. (100)
    if npart==1
        PF=ForwardLocalization(GTSM,init_prob);
    else
        PF=ParticleLocalization(npart, GTSM, init_prob);
    end;
    
    poses=zeros(1,length(feats)); conf=zeros(1,length(poses));
    metric_poses=zeros(2,length(feats));
    DO=[];
    local_map_len=param(3);
    if local_map_len==0                                                         %param3: Local Map Length, 0 for direct obs (0.5)
        if ~USE_ORIENTED
            DO=DirectObservation(SemanticFeature());
        else
            DO=OrientedObservation(OrientedSemanticFeature());
        end;
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
    init_point=1;%randi(round(length(feats)*3/4),1);
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
            metric_poses(:,I)=PF.metric_pose;
            conf(I)=PF.pose_p;%DO.likelihood(GTSM,poses(I),mean_len);
            cc=conf(I);
            if I>30*param(4)
                if mean(conf(I-29*param(4):param(4):I))<0.5
            %        PF.particlesReset();
                end;
            end;
            
            if ~rem(I,param(4)*DISPLAY_FREQ)
                figure(1);
                PF.display();
                h_loc=plot(feats(I).gps(2),feats(I).gps(1),'-rx', 'MarkerSize', 12, 'LineWidth',2);
                
                drawnow
                
                if REC_VID
                    frame = getframe;
                    writeVideo(v,frame);
                end;
                delete(h_loc);
                %        delete(h_locgt);
            end;
            
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
    
    if GET_ERR
        tmp_DPR=0;
        tmp_OPR=0;
        tmp_rDPR=0;
        tmp_rOPR=0;
        total_O=0;
        total_D=0;
        frame_distance=0*poses(init_point:param(4):length(feats));
        frame_result=frame_distance;
        %frame_node_distance=[];
        transition_result=frame_distance;
        dist=0;
        N=0;
        %frame_result=poses*0;
        for I=init_point:length(feats)
            dist=dist+feats(I).d;
            if ~rem(I,param(4))
                N=N+1;
                total_O=total_O+1;
                total_D=total_D+dist;
                
                tmp_list=GTSM.nodes(poses(I)).gps_list;
                tmp_dists=tmp_list(:,1)*0;
                for J=1:length(tmp_list(:,1))
                    tmp_dists(J)=lldistkm(tmp_list(J,:),feats(I).gps);
                end;
                frame_distance(N)=min(tmp_dists);
                if any(tmp_dists < 0.020)
                    tmp_OPR=tmp_OPR+1;
                    tmp_DPR=tmp_DPR+dist;
                    frame_result(N)=1;
                end;
                if any(tmp_dists < 0.050)
                    tmp_rOPR=tmp_rOPR+1;
                    tmp_rDPR=tmp_rDPR+dist;
                    %frame_result(length(frame_distance))=1;
                end;
                
                if I>init_point+param(4)
                    if poses(I)~=poses(I-param(4))
                        if frame_result(N)
                            transition_result(N)=1;
                        else
                            transition_result(N)=-1;
                        end;
                    end;
                end;
                
                %EVALUACION POR RUTA MAS CORTA
%                 frame_node_distance(end+1)=-1;
%                 tmp_node_list(length(GTSM.nodes))=0;
%                 tmp_node_list=tmp_node_list*0;
%                 tmp_node_list(poses(I))=1;
%                 flag_stop=false;
%                 while ~ flag_stop
%                     frame_node_distance(end)=frame_node_distance(end)+1;
%                     check_list=find(tmp_node_list==1);
%                     
%                     if isempty(check_list)
%                         flag_stop=true;
%                         break;
%                     end;
%                     tmp_node_list(check_list)=2;
%                     for J=1:length(check_list)
%                         for K=1:length(GTSM.nodes(check_list(J)).gps_list)
%                             if lldistkm(GTSM.nodes(check_list(J)).gps_list(K,:),feats(I).gps) < 0.015
%                                 flag_stop=true;
%                             end;
%                         end;
%                         if ~isempty(GTSM.prevNodes(check_list(J)))
%                             tmp_node_list([GTSM.prevNodes(check_list(J))])=tmp_node_list([GTSM.prevNodes(check_list(J))])+1;
%                         end;
%                         tmp_node_list([GTSM.nextNodes(check_list(J))])=tmp_node_list([ GTSM.nextNodes(check_list(J))])+1;
%                     end;
%                     
%                 end;
                
                dist=0;
            end;
        end;
        OPR(it)=tmp_OPR/total_O;
        DPR(it)=tmp_DPR/total_D;
        rOPR(it)=tmp_rOPR/total_O;
        rDPR(it)=tmp_rDPR/total_D;
        performance(:,it)=[tmp_OPR/total_O;;...
            tmp_DPR/total_D;...
            tmp_rOPR/total_O;...
            tmp_rDPR/total_D;...
            mean(frame_distance);...
            mean(frame_distance(frame_result==0));...
            sum(transition_result(transition_result==1))/length(transition_result(transition_result~=0));...
            sum(frame_result)];
        
    end;
end;

save('pf_fcfm_gps.mat',metric_poses)


%% Visualizacion metrica
figure(2)
hold on
load('../orient-fcfm-gps.mat')
plot(metric_poses(2,5:5:end),metric_poses(1,5:5:end),'-g', 'LineWidth',2);
load('lost_fcfm.mat')
plot(lost_gps_out(:,2),lost_gps_out(:,1), '-b','LineWidth',2)
load('pf_fcfm_gps.mat')
plot(metric_poses(2,5:5:end),metric_poses(1,5:5:end),'-r', 'LineWidth',2);
hold on
mygps=[];
for KK=5:5:length(feats)
    mygps=[mygps feats(KK).gps'];
end;
plot(mygps(2,:),mygps(1,:), '-k','LineWidth',2)
plot_google_map('MapType', 'roadmap','ShowLabels',0)
set(gca,'position',[0 0 1 1],'units','normalized');
hold off
for JJ=5:5:length(metric_poses)
    metric_dist(JJ)=lldistkm(metric_poses(:,JJ),feats(JJ).gps);
end;
figure(3);
plot(metric_dist(5:5:end))
mean(metric_dist(5:5:end))
mean(metric_dist(5:5:end)>0.02)
mean(metric_dist(5:5:end)>0.025)
mean(metric_dist(5:5:end)>0.03)