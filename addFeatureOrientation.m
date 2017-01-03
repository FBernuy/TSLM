function [ resp ] = addFeatureOrientation( feat )
%ADDFEATUREORIENTATION Summary of this function goes here
%   Detailed explanation goes here
    resp(length(feat))=OrientedSemanticFeature();
    for I=2:length(feat)
       resp(I).copySemanticFeature(feat(I));
       
       if feat(I).d < 0.0005 && I~=2
           resp(I).orientation=resp(I-1).orientation;
           continue;
       end;
       dx=lldistkm( feat(I).gps.*[1,0] , feat(I-1).gps.*[1,0] );
       if feat(I).gps(1) > feat(I-1).gps(1)
           dx=-dx;
       end;
       dy=lldistkm( feat(I).gps.*[0,1] , feat(I-1).gps.*[0,1] );
       if feat(I).gps(2) > feat(I-1).gps(2)
           dy=-dy;
       end;
       resp(I).orientation=atan2(dy,dx);
    end;
    
    resp(1).orientation=resp(2).orientation;

end

