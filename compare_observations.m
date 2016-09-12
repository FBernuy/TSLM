function [ result ] = compare_observations( groundtruth_sequence, classifier_sequence )
%compare_observations: compare observations against the ground truth sequence

%Inputs
%   groundtruth_sequence  = cada una de los elementos extraídos de las
%   imágenes que forman la base de las mediciones
%   classifier_sequence  = cada una de los elementos extraídos de las imágenes

%Outputs
%   result  = porcentaje de acierto para las observaciones
%-----------------------------------------------

    
    frames = numel(classifier_sequence);
    section_names = fieldnames( classifier_sequence(1) );
    element_names = fieldnames( classifier_sequence(1).(section_names{1}) );
    
    hits = zeros( numel(section_names),numel(element_names) );
    %for each section and element use corresponding parameters of hmm
    for sn = 1:numel(section_names)
        for en = 1:numel(element_names)
            
            
            %filter images in each frame using a window for estimation of
            %window_size frames
            
            for f = 1:frames
                if numel( groundtruth_sequence(f).(section_names{sn}).(element_names{en}) )>0
                    groundtruth_observation = groundtruth_sequence(f).(section_names{sn}).(element_names{en}){1};
                else
                    groundtruth_observation=[];
                end
                
                if numel( classifier_sequence(f).(section_names{sn}).(element_names{en}) )>0
                    classifier_observation = classifier_sequence(f).(section_names{sn}).(element_names{en}){1};
                else
                    classifier_observation=[];
                end
                
                if isempty(groundtruth_observation) && isempty(classifier_observation)
                    hits(sn,en) = hits(sn,en) + 1;
                end
                if ( ~isempty(groundtruth_observation) ) && ( ~isempty(classifier_observation) )
                    if strcmp(groundtruth_observation,classifier_observation)
                        hits(sn,en) = hits(sn,en) + 1;
                    end
                end
            end
        end
    end
    result = hits / frames;
end