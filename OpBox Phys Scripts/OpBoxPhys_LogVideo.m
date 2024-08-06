function OpBoxPhys_LogVideo(src, obj, vid_writer)

% global cam_global

% Read images from the videoinput buffer.
imgs = getdata(src, src.FramesAvailable);
writeVideo(vid_writer, imgs);

% cam_global{spdmIndex}.frame = mean(imgs(:, :, :, end));