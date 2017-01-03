vid_filename='E:\fcfm\M3\iGV_20161207113721.mov';
folder='e:/fcfm/M3/'
im_dir=dir([folder '/labels/*.png']);

vw = VideoWriter('vid.avi');
vw.FrameRate=10;
vw.Quality=80;
open(vw);

v = VideoReader(vid_filename)
video = v.read(1);
[h,w,~]=size(video);
%J=1;
for J=1:length(im_dir)
%for I=1:v.numberOfFrames
%    video = v.read(I);
%    if rem(I,4)==1
        im_label=imread([folder 'labels/' im_dir(J).name]);
        %[h,w,~]=size(video);
        im_label_r=imresize(CSLabel2Image(im_label),[h,w]);
        %mean_img=video/2+im_label_r/2;
        writeVideo(vw,im_label_r);
        %imshow(mean_img);
        %drawnow;
        %J=J+1;
%    end;
    
end