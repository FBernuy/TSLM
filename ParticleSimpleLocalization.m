classdef ParticleSimpleLocalization < ParticleLocalization
    %PARTICLESIMPLELOCALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=ParticleSimpleLocalization(npart,GTSM,init_prob)
            obj = obj@ParticleLocalization(npart,GTSM,init_prob);
            %obj=ParticleLocalization(npart,GTSM,init_prob);
        end;
        function obj=transition(obj,dist)
            sample_values=rand(length(obj.particles),1);
            for I=1:length(obj.particles)
                if sample_values(I) < dist/(obj.map.nodes(obj.particles(I).id).d + dist)
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
            for I=1:length(obj.particles)
                obj.particles(I).length=obj.map.nodes(obj.particles(I).id).d*0.5;
            end;
            
        end;
        
    end
    
end

