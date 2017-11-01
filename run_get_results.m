r1=cell(0);
th=0.0:0.1:1.0;
for I=th
    figure(1);
    if I==0
        resp=localization_test([0.00001,1,0,3],1);
    else
        resp=localization_test([I,1,0,3],1);
    end;
    mm1=0*resp{1};
    for J=1:length(resp)
        mm1=mm1+resp{J}/length(resp);
    end;
    r1{end+1}=mm1;
    figure(2);
    for J=1:length(r1)
        OPR(J)=r1{J}(1);
        DPR(J)=r1{J}(2);
        rOPR(J)=r1{J}(6);
        rDPR(J)=r1{J}(7);
    end;
    plot(th(1:length(OPR)),1-OPR,...
            th(1:length(OPR)),1-DPR,...
            th(1:length(OPR)),1-rOPR,...
            th(1:length(OPR)),1-rDPR);
    drawnow;
        
end;

for I=1:10
    r2{I}=localization_test([0.4,100,0.3,3]);
end;

for I=1:1
    r3{I}=localization_test([0.4,1,0,3]);
end;

for I=1:1
    r4{I}=localization_test([0.4,1,0.3,3]);
end;

for I=1:20
    r5{I}=localization_test([0.4,50,0.4,3]);
end;

for I=1:20
    r6{I}=localization_test([0.4,50,0.5,3]);
end;

for I=1:20
    r7{I}=localization_test([0.4,100,0,3]);
end;

for I=1:10
    r8{I}=localization_test([0.4,100,0,3]);
end;

for I=1:10
    r9{I}=localization_test([0.4,100,0.3,3]);
end;

mm1=0*r1{1};
for I=1:length(r1)
mm1=mm1+r1{I}/length(r1);
end;

mm2=0*r2{1};
for I=1:length(r2)
mm2=mm2+r2{I}/length(r2);
end;

mm3=0*r3{1};
for I=1:length(r3)
mm3=mm3+r3{I}/length(r3);
end;

mm4=0*r4{1};
for I=1:length(r4)
mm4=mm4+r4{I}/length(r4);
end;

mm5=0*r5{1};
for I=1:length(r5)
mm5=mm5+r5{I}/length(r5);
end;

mm6=0*r6{1};
for I=1:length(r6)
mm6=mm6+r6{I}/length(r6);
end;

mm7=0*r7{1};
for I=1:length(r7)
mm7=mm7+r7{I}/length(r7);
end;

mm8=0*r8{1};
for I=1:length(r8)
mm8=mm8+r8{I}/length(r8);
end;

mm9=0*r9{1};
for I=1:length(r9)
mm9=mm9+r9{I}/length(r9);
end;
