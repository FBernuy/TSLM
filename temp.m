ff= features_2 ;
[  ind , freq  ] = getTopologicalMapHistFix(ff);

descr=features_1(ind); %OJO dist son del feature, no del segmento

for I=1:length(descr)
    descr(I).dist=freq(I);
    
    descr(I).h1=features_1(ind(I)).h1*0;
    descr(I).h2=features_1(ind(I)).h2*0;
    descr(I).h3=features_1(ind(I)).h3*0;
    
    K=1;
    if I == length(ind)
        K=length(features_1);
    else
        K=(ind(I+1)-1);
    end;
    
    for J=ind(I):K
        descr(I).h1=descr(I).h1+features_1(J).h1/length(ind);
        descr(I).h2=descr(I).h2+features_1(J).h2/length(ind);
        descr(I).h3=descr(I).h3+features_1(J).h3/length(ind);
    end;
end;

[ backgnd, flat, other ]=getCategoriesDefinition();

dh=zeros(length(ff),length(descr));

for I=1:length(ff)
    parfor J=1:length(descr)
        dh(I,J)=sum([histDistance(ff(I).h1(backgnd),descr(J).h1(backgnd)) ...
                     histDistance(ff(I).h2(backgnd),descr(J).h2(backgnd)) ...
                     histDistance(ff(I).h3(backgnd),descr(J).h3(backgnd))]);
        %dh(I,J)=sum(histCompare(ff(I),descr(J)));
        
    end;
    imagesc(dh);
    pause(0.01);
    I
end;

dhgt=dh*0;

for I=1:length(ff)
    
    dhgt(I,find(ind<=I,1,'last'))=1;
    
end;

f12distim=zeros(length(ff),length(features_2));

for I=1:length(ff)
    parfor J=1:length(features_2)
        f12distim(I,J)=sum([histDistance(ff(I).h1(backgnd),features_2(J).h1(backgnd)) ...
                            histDistance(ff(I).h2(backgnd),features_2(J).h2(backgnd)) ...
                            histDistance(ff(I).h3(backgnd),features_2(J).h3(backgnd))]);
    end;
end;



%% PLOTEAR EL GPS

ff=features_1;
lat1=[];
lon1=[];
for I=1:length(ff)
    lat1(I)=ff(I).gps(1);
    lon1(I)=ff(I).gps(2);
end;

ff=features_2;
lat2=[];
lon2=[];
for I=1:length(ff)
    lat2(I)=ff(I).gps(1);
    lon2(I)=ff(I).gps(2);
end;

ff=features_3;
lat3=[];
lon3=[];
for I=1:length(ff)
    lat3(I)=ff(I).gps(1);
    lon3(I)=ff(I).gps(2);
end;

plot(lon1,lat1,...
    '-g',...
    lon2,lat2,...
    '-r',...
    lon3,lat3,...
    '-b',...
    'LineWidth',4);
plot_google_map
