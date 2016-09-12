function [ out ] = compareDescriptions( descr1 , descr2 )
%COMPAREDESCRIPTIONS Summary of this function goes here
%   Detailed explanation goes here
out=false(3,1);

%out(1,1)=partialCompare2(descr1.left.flat,descr2.left.flat);
out(1,1)=partialCompare3(descr1.left.build,descr2.left.build);
%out(1,3)=partialCompare2(descr1.left.object,descr2.left.object);
%out(2,1)=partialCompare2(descr1.center.flat,descr2.center.flat);
out(2,1)=partialCompare3(descr1.center.build,descr2.center.build);
%out(2,3)=partialCompare2(descr1.center.object,descr2.center.object);
%out(3,1)=partialCompare2(descr1.right.flat,descr2.right.flat);
out(3,1)=partialCompare3(descr1.right.build,descr2.right.build);
%out(3,3)=partialCompare2(descr1.right.object,descr2.right.object);

% if partialCompare2(descr1.left.flat,descr2.left.flat)
%     if partialCompare2(descr1.left.build,descr2.left.build)
%         if partialCompare2(descr1.left.object,descr2.left.object)
%             if partialCompare2(descr1.center.flat,descr2.center.flat)
%                 if partialCompare2(descr1.center.build,descr2.center.build)
%                     if partialCompare2(descr1.center.object,descr2.center.object)
%                         if partialCompare2(descr1.right.flat,descr2.right.flat)
%                             if partialCompare2(descr1.right.build,descr2.right.build)
%                                 if partialCompare2(descr1.right.object,descr2.right.object)
%                                     out=true;
%                                 end;
%                             end;
%                         end;
%                     end;
%                 end;
%             end;
%         end;
%     end;
% end;

end

function out = partialCompare(part1,part2)

    
    if isempty(part1) && isempty(part2)
        out = true;
        return;
    end;
    if length(part1) ~= length(part2)
        out = false;
        return;
    end;
    
    out=strcmp(part1,part2);
    
end

function out = partialCompare2(part1,part2)

    
    if isempty(part1) && isempty(part2)
        out = true;
        return;
    end;
    if isempty(part1) || isempty(part2)
        out = false;
        return;
    end;
    
    out=strcmp(part1{1},part2{1});
end