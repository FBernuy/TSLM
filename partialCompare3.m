function out = partialCompare3(part1,part2)

    
    if isempty(part1) && isempty(part2)
        out = true;
        return;
    end;
    if isempty(part1) || isempty(part2)
        out = false;
        return;
    end;
    
    
    out=strcmp(part1{1},part2{1});
    if length(part1)>1
        out=out || strcmp(part1{2},part2{1});
    end;
    if length(part2)>1
        out=out || strcmp(part1{1},part2{2});
    end;
    
end