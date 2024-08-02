%% https://www.mathworks.com/help/parallel-computing/spmd.html
% spmd
%    spmdIndex
%    spmdSize
%    % v = videoinput('winvideo', spmdIndex);
%    % start(v);
%    v = [spmdIndex, spmdSize]
% end

%% https://www.mathworks.com/matlabcentral/answers/1949708-how-to-preview-videos-from-each-spmd-worker-in-parallel-computing-toolbox
% % spmd(2)
% %    spmdIndex
% %    v = videoinput('winvideo', spmdIndex);
% %    start(v);
% % end
% %
% %
% % preview(v{1})
% % preview(v{2})
% %
% % % ticBytes(gcp);
% % % pause(5);
% % % tocBytes(gcp);
% 
% 
% imaqreset
% info = imaqhwinfo('winvideo');
% global z
% z = cell(1, numel(info.DeviceInfo));
% v = cell(1, numel(info.DeviceInfo));
% for i=1:numel(info.DeviceInfo)
%     spmd(1)
%         fprintf('spmdIndex = %d\n', spmdIndex);
%         fprintf('i = %d\n', i);
%         v{i} = videoinput('winvideo', i);
%         v{i}
%         z{i} = v{i};
%         start(v{i});
%     end
% end
% whos v
% v
% v{1}
% 
% % preview(v{1}{i})
% % preview(v{2})

%% https://www.mathworks.com/help/imaq/acquire-images-using-parallel-worker.html
% delete(gcp('nocreate'));
% mkdir("c:\temp\data\")
% parpool('local',2);
% f = parfeval(@captureVideo,0, 1)
% f = parfeval(@captureVideo,0, 2)
% wait(f);
% disp(f);
% clear f
% delete(gcp("nocreate"))
% 
% function captureVideo(idx)
%     % fprintf('%d\n', idx); % Doesn't print internally
% 
%     % Create videoinput object.
%     v = videoinput('winvideo', idx);
% 
%     % Specify a custom callback to save images.
%     % v.FramesAcquiredFcn = @(x)saveImages(idx);
%     v.FramesAcquiredFcn = @(src, evt) saveImages( src,evt,idx);
% 
%     % Specify the number of frames to acquire before calling the callback.
%     v.FramesAcquiredFcnCount = 10;
% 
%     % Specify the total number of frames to acquire.
%     v.FramesPerTrigger = 20;
% 
%     % Start recording.
%     start(v);
% 
%     % Wait for the acquision to finish.
%     wait(v);
% end
% 
% function saveImages(src,obj,idx)
%     % Calculate the total frame number for each frame, 
%     % in order to save the files in order.
%     currframes = src.FramesAcquired - src.FramesAcquiredFcnCount;
% 
%     % Read images from the videoinput buffer.
%     imgs = getdata(src,src.FramesAvailable);
% 
%     % Save each image to a file in order.
%     for i = 1:src.FramesAcquiredFcnCount
%         imname = "c:\temp\data\cam" + idx + "_img_" + (currframes + i) + ".TIFF";
%         % imname = "c:\temp\data\cam_img_" + (currframes + i) + ".TIFF";
%         imwrite(imgs(:,:,:,i),imname);
%     end
% end

%% https://www.mathworks.com/help/parallel-computing/perform-image-acquisition-from-webcam-and-parallel-image-processing.html

%% parfeval
