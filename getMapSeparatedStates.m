function [ ind , freq  ] = getMapSeparatedStates( map )
%GETMAPSEPARATEDSTATES Summary of this function goes here
%   Detailed explanation goes here

ind=cell(3);
freq=cell(3);

for I=1:9
    ind{I}{1}='';
    freq{I}{1}=0;
end;

for I=1:length(map)
    I
    observation={map(I).left.flat   map(I).left.build   ;...%map(I).left.object;...
                 map(I).center.flat map(I).center.build ;...%map(I).center.object;...
                 map(I).right.flat  map(I).right.build  };%map(I).right.object};
    
     for desI=1:3
         for desJ=1:2
             is_repeated=false;
             for J=1:length(ind{desI,desJ})
                 if localDescriptionCompare(observation{desI,desJ},ind{desI,desJ}{J})
                     freq{desI,desJ}{J}=freq{desI,desJ}{J}+1;
                     is_repeated=true;
                     break;
                 end;
             end;
             if ~is_repeated
                 ind{desI,desJ}{end+1}=observation{desI,desJ}{1};
                 freq{desI,desJ}{end+1}=1;
             end;
         end;
     end;
end;

end

function [ out ] = localDescriptionCompare( part1,part2 )
%PARTIALDESCRIPTIONCOMPARE Summary of this function goes here
%   Detailed explanation goes here
    if isempty(part1)
        part1='';
    end;
    if isempty(part2)
        part2='';
    end;
    if iscell(part1)
        if iscell(part2)
            out=strcmp(part1{1},part2{1});
        else
            out=strcmp(part1{1},part2);
        end;
    else
        if iscell(part2)
            out=strcmp(part1,part2{1});
        else
            out=strcmp(part1,part2);
        end;
    end;
    
    
end
