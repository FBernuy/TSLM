folder='e:/fcfm/M3/'

im_dir=dir([folder '/labels/*.png']);
kml_dir=dir([folder '/*.kml']);
kml_s=kml2struct([folder '/' kml_dir(1).name]);

features(length(im_dir))=SemanticFeature();

gps_estimated=zeros(length(im_dir),2);

gps_estimated(:,1)=interp1([kml_s(2:end).Lat],1:(length(kml_s)-2)/(length(im_dir)-1):length(kml_s)-1);
gps_estimated(:,2)=interp1([kml_s(2:end).Lon],1:(length(kml_s)-2)/(length(im_dir)-1):length(kml_s)-1);

tr=[8 9 12 13 14 18 20 21 22 23 24 25 26 27 28 29 32 33 34];


parfor I=1:length(im_dir)
    im_label=imread([folder 'labels/' im_dir(I).name]);
    
    gps_ind=floor(I/10)+2;
    
    [~,w]=size(im_label);
    
    zz=zeros(1,35);
    zz=zz*0;
    zz(tr)=hist(reshape(double(im_label(:,1:floor(w/3))),[],1),0:18);
    features(I).h1=zz;
    zz=zz*0;
    zz(tr)=hist(reshape(double(im_label(:,ceil(w/3):floor(2*w/3))),[],1),0:18);
    features(I).h2=zz;
    zz=zz*0;
    zz(tr)=hist(reshape(double(im_label(:,ceil(2*w/3):end)),[],1),0:18);
    features(I).h3=zz;
    
    features(I).gps=gps_estimated(I,:);
    
    if I==1
        features(I).d=0;
    else
        [features(I).d,~]=lldistkm(gps_estimated(I-1,:),gps_estimated(I,:));
    end;
    %imshow(CSLabel2Image(im_label));
    %drawnow;
    I
end;