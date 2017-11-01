classdef ParticleLocalization < TopologicalLocalization
    %PARTICLELOCALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        particles; %.id / .length / .weight
        pose;
        pose_p;
        map;
        noise;
        h_part;
        h_map;
        h_pos=0;
        h_mp;
        metric_pose;
    end
    
    methods
        function obj=ParticleLocalization(n_particles, map, initial_distribution)
            obj.noise=1.0;
            obj.map=map;
            obj.particles(n_particles).id=0;
            obj.particles(n_particles).length=0;
            obj.h_part(n_particles)=0;
            obj.h_map=0;
            obj.h_pos=0;
            obj.metric_pose=[];
            h_mp=0;
            for I=1:n_particles
                obj.particles(I).id=find(rand <= cumsum(initial_distribution),1);
                obj.particles(I).length=rand * map.nodes(obj.particles(I).id).d;
                obj.particles(I).weight=initial_distribution(obj.particles(I).id);
                obj.h_part(I)=0;
            end;
            obj.normalize_weights();
            
            obj.resample();
            obj.pose.id=obj.particles(1).id;
            obj.pose.length=obj.particles(1).length;
        end;
            
        function pose=update(obj,SO,dist)
            
            obj.transition(dist);
            %obj.forcedTransition(dist,SO);
            if isa(SO,'DirectObservation') || isa(SO,'OrientedObservation')
                temp_w=0*[obj.particles(:).weight];
                tmp_uni=unique([obj.particles(:).id]);
                tmp_like=0*tmp_uni;
                for I=1:length(tmp_uni)
                    tmp_find=find([obj.particles(:).id]==tmp_uni(I));
                    temp_w(tmp_find)=[obj.particles(tmp_find).weight].*SO.likelihood(obj.map,tmp_uni(I),0);%Length doesnt matter in DO
                end;
            else
                temp_w=[obj.particles(:).weight];
                parfor I=1:length(obj.particles)
                    temp_w(I)=obj.particles(I).weight*SO.likelihood(obj.map,obj.particles(I).id,obj.particles(I).length);
                end;
            end;
            
            for I=1:length(obj.particles)
                obj.particles(I).weight=temp_w(I);
            end;
            obj.normalize_weights();
            if dist ~= 0 && obj.effectiveSampleSize() < length(obj.particles)*0.75
                display('resampling')
                display(obj.effectiveSampleSize())
                obj.resample();
            end
            
            [ux,ia,ic] = unique([obj.particles(:).id]);
            counts=ux*0;
            if length(ux) == 1, counts = length(obj.particles);
            else
                for I=1:length(ux)
                    counts(I) = sum([obj.particles(ic==I).weight]);
                end;
            end
            [a,b]=max(counts);
            pose.id=ux(b);
            %pose.id=mode([obj.particles(:).id]);
            pose.length=mean( [obj.particles( [obj.particles(:).id] == pose.id ).length] );
            obj.pose=pose;
            obj.pose_p=a;
            obj.calcMetricPose();
        end;
        
        function obj=resample(obj)
            sampled_ids=zeros(1,length(obj.particles));
            sampled_len=zeros(1,length(obj.particles));
            sampled_weight=1/length(obj.particles);
            cumulative_weights=cumsum([obj.particles(:).weight]);
            for I=1:length(obj.particles)
                part=obj.particles(find(rand <= cumulative_weights,1));
                sampled_ids(I)=part.id;
                sampled_len(I)=part.length;%obj.particles(find(rand <= cumulative_weights,1)).length;
            end;
            for I=1:length(obj.particles)
                obj.particles(I).id=sampled_ids(I);
                obj.particles(I).length=sampled_len(I);
                obj.particles(I).weight=sampled_weight;
            end;
        end;
        
        function obj=transition(obj,dist)
            
            for I=1:length(obj.particles)
                obj.particles(I).length = obj.particles(I).length + (dist) * normrnd(1.0,obj.noise*obj.noise);  %added noise!!!!
                if obj.particles(I).length < 0
                    prev_ids=obj.map.prevNodes(obj.particles(I).id);
                    if isempty(prev_ids)
                        obj.particles(I).length=0;
                        continue;
                    end;
                    if length(prev_ids)==1
                        obj.particles(I).id=prev_ids;
                    else
                        obj.particles(I).id=randsample(prev_ids,1);   %random prev node
                    end;
                    obj.particles(I).length=obj.map.nodes(obj.particles(I).id).d+obj.particles(I).length;
                    continue;
                end;
                
                while obj.particles(I).length > obj.map.nodes(obj.particles(I).id).d
                    obj.particles(I).length=obj.particles(I).length-obj.map.nodes(obj.particles(I).id).d;
                    next_ids=obj.map.nextNodes(obj.particles(I).id);%obj.map.adjacency_list(obj.map.adjacency_list(:,1)==obj.particles(I).id,2);
                    if isempty(next_ids)
                        obj.particles(I).length=obj.map.nodes(obj.particles(I).id).d;
                        continue;
                    end;
                    if length(next_ids)==1
                        obj.particles(I).id=next_ids;
                        continue;
                    end;
                    obj.particles(I).id=randsample(next_ids,1);   %random next node
                end;
            end;
        end;
        
        function obj=forcedTransition(obj,dist,SO)
            
            for I=1:length(obj.particles)
                obj.particles(I).length = obj.particles(I).length + (dist) * normrnd(1.0,obj.noise*obj.noise);  %added noise!!!!
                if obj.particles(I).length < 0
                    prev_ids=obj.map.prevNodes(obj.particles(I).id);
                    if isempty(prev_ids)
                        obj.particles(I).length=0;
                        continue;
                    end;
                    if length(prev_ids)==1
                        obj.particles(I).id=prev_ids;
                    else
                        tmp_like=0;
                        for J=1:length(prev_ids)
                            tmp_like_2=SO.likelihood(obj.map,prev_ids(J),0);%Da lo mismo el largo!
                            if tmp_like< tmp_like_2
                                tmp_like = tmp_like_2;
                                obj.particles(I).id=prev_ids(J);
                            end;
                        end;
                    end;
                    obj.particles(I).length=obj.map.nodes(obj.particles(I).id).d+obj.particles(I).length; %TODO: wut?
                    continue;
                end;
                while obj.particles(I).length > obj.map.nodes(obj.particles(I).id).d
                    obj.particles(I).length=obj.particles(I).length-obj.map.nodes(obj.particles(I).id).d;
                    next_ids=obj.map.nextNodes(obj.particles(I).id);%obj.map.adjacency_list(obj.map.adjacency_list(:,1)==obj.particles(I).id,2);
                    if isempty(next_ids)
                        obj.particles(I).length=obj.map.nodes(obj.particles(I).id).d;
                        continue;
                    end;
                    if length(next_ids)==1
                        obj.particles(I).id=next_ids;
                        continue;
                    end;
                    tmp_like=0;
                    for J=1:length(next_ids)
                        tmp_like_2=SO.likelihood(obj.map,next_ids(J),0);%Da lo mismo el largo!
                        if tmp_like< tmp_like_2
                            tmp_like = tmp_like_2;
                            obj.particles(I).id=next_ids(J);
                        end;
                    end;
                end;
            end;
        end;
        
        function obj=normalize_weights(obj)
            weight_sum=sum([obj.particles(:).weight]);
            if weight_sum ==0
                for I=1:length(obj.particles)
                    obj.particles(I).weight=1/length(obj.particles);
                end;
            else
                for I=1:length(obj.particles)
                    obj.particles(I).weight=obj.particles(I).weight/weight_sum;
                end;
            end;
        end;
        function ess=effectiveSampleSize(obj)
            ess=1/(sum([obj.particles(:).weight].^2));
        end;
        function obj=display(obj)
            for J=1:length(obj.particles)
                if obj.h_part(J) ~= 0
                    delete(obj.h_part(J));
                end;
                if isempty(obj.map.nextNodes(obj.particles(J).id))
                    obj.h_part(J)=plot(obj.map.nodes(obj.particles(J).id).gps(2),obj.map.nodes(obj.particles(J).id).gps(1),'-gx', 'MarkerSize', 8, 'LineWidth',1);
                else
                    nid=obj.map.nextNodes(obj.particles(J).id);
                    nid=nid(1);
                    ratio=obj.particles(J).length/obj.map.nodes(obj.particles(J).id).d;
                    if  nid <= 0 || obj.particles(J).id <=0
                    end;
                    temp_gps=obj.map.nodes(obj.particles(J).id).gps*(1-ratio)+obj.map.nodes(nid).gps*ratio;
                    obj.h_part(J)=plot(temp_gps(2),temp_gps(1),'-gx', 'MarkerSize', 8, 'LineWidth',2);
                end;
                
            end;
            if obj.h_mp ~= 0
                delete(obj.h_mp);
            end;
            obj.h_mp=plot(obj.metric_pose(2),obj.metric_pose(1),'-kx', 'MarkerSize', 12, 'LineWidth',2);
            
            if obj.h_pos ~= 0
                delete(obj.h_pos)
            end;
            if isempty(obj.map.nextNodes(obj.pose.id))
                obj.h_pos=plot([obj.map.nodes(obj.pose.id).gps(2)],[obj.map.nodes(obj.pose.id).gps(1)],'-yo', 'MarkerSize', 12, 'LineWidth',2);
            else
                obj.h_pos=plot([obj.map.nodes(obj.pose.id).gps(2) obj.map.nodes(obj.pose.id+1).gps(2)],[obj.map.nodes(obj.pose.id).gps(1) obj.map.nodes(obj.pose.id+1).gps(1)],'-yo', 'MarkerSize', 12, 'LineWidth',2);
            end;
            
        end;
        function calcMetricPose(obj)
            obj.metric_pose=obj.map.nodes(obj.particles(1).id).gps*0;
            tmpw=0;
            for J=1:length(obj.particles)
                if isempty(obj.map.nextNodes(obj.particles(J).id))
                    %if obj.particles(J).id == obj.pose.id
                    temp_gps=obj.map.nodes(obj.particles(J).id).gps;
                    obj.metric_pose = obj.metric_pose + temp_gps*obj.particles(J).weight;
                    tmpw=tmpw+obj.particles(J).weight;
                    %end
                else
                    nid=obj.map.nextNodes(obj.particles(J).id);
                    nid=nid(1);
                    if obj.map.nodes(obj.particles(J).id).d == 0
                        ratio=0;
                    else
                        ratio=obj.particles(J).length/obj.map.nodes(obj.particles(J).id).d;
                    end;
                    temp_gps=obj.map.nodes(obj.particles(J).id).gps*(1-ratio)+obj.map.nodes(nid).gps*ratio;
                    %if obj.particles(J).id == obj.pose.id
                        obj.metric_pose = obj.metric_pose + temp_gps*obj.particles(J).weight;
                        tmpw=tmpw+obj.particles(J).weight;
                    %end
                end;
            end;
            obj.metric_pose=obj.metric_pose/tmpw;
            %return;
            tmp_p=obj.map.nodes(obj.particles(1).id).gps;
            tmp_d=lldistkm(tmp_p,obj.metric_pose);
            tmpw=0;
            tmpp=tmp_p*0;
            for J=2:length(obj.particles)
                if isempty(obj.map.nextNodes(obj.particles(J).id))
                    temp_gps=obj.map.nodes(obj.particles(J).id).gps;
                else
                    nid=obj.map.nextNodes(obj.particles(J).id);
                    nid=nid(1);
                    if obj.map.nodes(obj.particles(J).id).d == 0
                        ratio=0;
                    else
                        ratio=obj.particles(J).length/obj.map.nodes(obj.particles(J).id).d;
                    end;
                    temp_gps=obj.map.nodes(obj.particles(J).id).gps*(1-ratio)+obj.map.nodes(nid).gps*ratio;
                end;
                if  obj.particles(J).id ~= obj.pose.id
                %    continue;
                end;
                current_p=temp_gps;
                current_d=lldistkm(current_p,obj.metric_pose);
                if current_d<0.03
                    tmpw=tmpw+obj.particles(J).weight;
                    tmpp = tmpp + temp_gps*obj.particles(J).weight;
                end;
                if tmp_d > current_d
                    tmp_d=current_d;
                    tmp_p=obj.map.nodes(obj.particles(J).id).gps;
                end;
            end;
            obj.metric_pose=tmp_p;
            obj.metric_pose=tmpp/tmpw;
        end;
        function obj=particlesReset(obj)
            cumulative=cumsum([obj.map.nodes(:).d]);
            for I=1:length(obj.particles)
                r=cumulative(end)*I/length(obj.particles);
                nid=find( r >= cumulative,1,'last');
                if isempty(nid)
                    nid=1;
                end;
                obj.particles(I).id=nid;
                obj.particles(I).length=r-cumulative(nid);
                obj.particles(I).weight=1/length(obj.particles);
            end;
        end;
    end
    
end

