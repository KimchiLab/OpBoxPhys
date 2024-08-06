function OpBoxPhys_LogVideo(src, obj, vid_writer)

% % Read images from the videoinput buffer.
% % https://www.mathworks.com/matlabcentral/answers/290312-how-can-we-use-spmd-for-videoreader
% while src.FramesAvailable
%     img = readFrame(src);
%     writeVideo(vid_writer, img);
% end

% Read images from the videoinput buffer.
imgs = getdata(src, src.FramesAvailable);
% writeVideo(vid_writer, imgs);
src.UserData = squeeze(mean(imgs(:, :, :, end), 3));

% assignin('base','temp','temp');

% Peek data for most recent frames? Unfortunately get warning if no frames available
% if isrunning(cam_global.cam)
% disp(src);
% disp(spdmIndex);
% disp(spmd_idx);
% composite_frame = peekdata(cam_global.cam, 1);
% end

% cam_global{spmdIndex}.frame = squeeze(mean(imgs(:, :, :, end)));
% cam_global{spmd_idx}.frame = squeeze(mean(imgs(:, :, :, end)));


% % Can not pass in global via spmd 
% % (this function is embedded as a listener handle within spmd loop)
% global cam_global
% global subjects
% subjects([subjects.cam_idx] == spmd_idx).curr_frame = squeeze(mean(imgs(:, :, :, end)));
