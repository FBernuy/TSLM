function [ out ] = getMapTransition( map )
%GETMAPTRANSITION Summary of this function goes here
%   Detailed explanation goes here

pre=cell(3);
current=cell(3);

[ind,freq]=getMapSeparatedStates(map);

out=cell(3);

out{1,1}=zeros(length(freq{1,1}));
out{1,2}=zeros(length(freq{1,2}));
%out{1,3}=zeros(length(freq{1,3}));

out{2,1}=zeros(length(freq{2,1}));
out{2,2}=zeros(length(freq{2,2}));
%out{2,3}=zeros(length(freq{2,3}));

out{3,1}=zeros(length(freq{3,1}));
out{3,2}=zeros(length(freq{3,2}));
%out{3,3}=zeros(length(freq{3,3}));

current=descriptionToMatrix(map(1));

for I=2:length(map)

    pre=current;
    current=descriptionToMatrix(map(2));
    
    cmp=strcmp(pre,current);
    
    for subI=1:3
        for subJ=1:2
            if ~cmp(subI,subJ)
                pI=find(not(cellfun('isempty', strfind(ind{subI,subJ} ,pre{subI,subJ}))));
                pJ=find(not(cellfun('isempty', strfind(ind{subI,subJ} ,current{subI,subJ}))));
                if isempty(pI)
                    pI=1;
                end;
                 if isempty(pJ)
                    pJ=1;
                end;
                
                out{subI,subJ}(pI,pJ)=out{subI,subJ}(pI,pJ)+1;
                
            end;
        end
    end
    

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

function out = descriptionToMatrix(description)

out=cell(3);
if isempty(description.left.flat);
    out{1,1}='';
else
    out{1,1}=description.left.flat{1};
end;
if isempty(description.left.build);
    out{1,2}='';
else
    out{1,2}=description.left.build{1};
end;
if isempty(description.left.object);
    out{1,3}='';
else
    out{1,3}=description.left.object{1};
end;

if isempty(description.center.flat);
    out{2,1}='';
else
    out{2,1}=description.center.flat{1};
end;
if isempty(description.center.build);
    out{2,2}='';
else
    out{2,2}=description.center.build{1};
end;
if isempty(description.center.object);
    out{2,3}='';
else
    out{2,3}=description.center.object{1};
end;

if isempty(description.right.flat);
    out{3,1}='';
else
    out{3,1}=description.right.flat{1};
end;
if isempty(description.right.build);
    out{3,2}='';
else
    out{3,2}=description.right.build{1};
end;
if isempty(description.right.object);
    out{3,3}='';
else
    out{3,3}=description.right.object{1};
end;

end
