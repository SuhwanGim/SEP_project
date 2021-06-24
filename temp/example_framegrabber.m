vid = videoinput('winvideo');
preview(vid);


%%

out = imaqhwinfo
%%
info = imaqhwinfo('winvideo');
%%
vid = videoinput('winvideo', 2);
imaq.VideoDevice('winvideo', 2);
%%
info
%%
imaqreset;
info=imaqhwinfo;

vid = videoinput(info.InstalledAdaptors{1}, 1,'NTSC_M:RGB24 (640x480)' );

%%
frame = getsnapshot(vid);

image(frame) 