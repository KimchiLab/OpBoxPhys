% https://www.mathworks.com/help/parallel-computing/spmd.html
% spmd
%    spmdIndex
%    spmdSize
%    v = videoinput('winvideo', spmdIndex);
%    start(v);
%    % v = [spmdIndex, spmdSize]
% end

% str_cam = {'HD USB Camera 01', 'HD USB Camera 02'};
str_cam = {'HD USB Camera 01', 'HD USB Camera 02', 'HD USB Camera 03', 'HD USB Camera 04', 'HD USB Camera 05', 'HD USB Camera 06', 'HD USB Camera 07', 'HD USB Camera 08'};

% spmd(numel(str_cam))
if isempty(gcp("nocreate"))
    tic;
    pool = parpool('Processes');
    pool.IdleTimeout = minutes(hours(3));
    toc;
end
% delete(gcp("nocreate")); % delete at end
% delete(pool);

cell_cam = cell(numel(str_cam), 1);
for i_cam = 1:numel(str_cam)
    spmd(1)
       temp_cam = videoinput('winvideo', str_cam{i_cam});
       % z = videoinput('winvideo', 1);
       % z = videoinput('winvideo', idx);
       % z = videoinput('winvideo', spmdIndex);
    end
    cell_cam{i_cam} = temp_cam{1};
    preview(cell_cam{i_cam});
end

% a=1;
% spmd
%    v = videoinput('winvideo', a);
% %    start(z);
% end
% 
% 
% % Adjust IdleTimeout > 24 hours?
% 
% % https://www.mathworks.com/matlabcentral/answers/1949708-how-to-preview-videos-from-each-spmd-worker-in-parallel-computing-toolbox
% spmd(2)
%    spmdIndex
%    v = videoinput('winvideo', spmdIndex);
%    start(v);
% end
% % preview(v{1})
% % preview(v{2})
% 
% % spmd(8)
% %     v = videoinput('winvideo', spmdIndex);
% %     start(v);
% % end
% %
% % for i = 1:8
% %     preview(v{i})
% % end
% 
% % % % ticBytes(gcp);
% % % % pause(5);
% % % % tocBytes(gcp);
% %
% %
% % imaqreset
% % info = imaqhwinfo('winvideo');
% % global z
% % z = cell(1, numel(info.DeviceInfo));
% % v = cell(1, numel(info.DeviceInfo));
% % for i=1:numel(info.DeviceInfo)
% %     spmd(1)
% %         fprintf('spmdIndex = %d\n', spmdIndex);
% %         fprintf('i = %d\n', i);
% %         v{i} = videoinput('winvideo', i);
% %         v{i}
% %         z{i} = v{i};
% %         start(v{i});
% %     end
% % end
% % whos v
% % v
% % v{1}
% %
% % % preview(v{1}{i})
% % % preview(v{2})
% 
% %% https://www.mathworks.com/help/imaq/acquire-images-using-parallel-worker.html
% % delete(gcp('nocreate'));
% mkdir("c:\temp\data\")
% % parpool('local');
% clear f
% 
% objects = imaqfind;
% delete(objects);
% imaqreset;
% deviceInfo = imaqhwinfo('winvideo')
% 
% % f = parfeval(@captureVideo,0, 1)
% 
% tic;
% for i = 1
%     f(i) = parfeval(@captureVideo, 1, i)
%     %     f(i) = parfeval(@captureVideo, 1, i);
%     %     % f = parfeval(@captureVideo,0, 2)
%     %     % while ~strcmpi('finished', f(i).State)
%     %     %     % Wait until ready
%     %     % end
%     %     % v(i) = fetchOutputs(f(i));
% end
% 
% % f
% % wait(f);
% % pause(8);
% % clear v;
% % v(1) = fetchOutputs(f(1)); % can't get back while running, coming back as struct or invalid
% % wait(f);
% disp(f);
% toc
% % v
% % clear f
% % delete(gcp("nocreate"))
% 
% function v = captureVideo(idx)
% % fprintf('%d\n', idx); % Doesn't print internally
% 
% % Create videoinput object.
% v = videoinput('winvideo', idx);
% 
% % Specify a custom callback to save images.
% % v.FramesAcquiredFcn = @(x)saveImages(idx);
% v.FramesAcquiredFcn = @(src, evt) saveImages( src,evt,idx);
% 
% % Specify the number of frames to acquire before calling the callback.
% v.FramesAcquiredFcnCount = 20;
% 
% % % Specify the total number of frames to acquire.
% % % v.FramesPerTrigger = 20;
% % Specify the total number of frames to acquire.
% v.FramesPerTrigger = 300;
% 
% % Make sure loaded?
% v.Running
% 
% % Start recording.
% start(v);
% v.Running
% 
% % % Wait for the acquision to finish.
% % wait(v);
% end
% 
% function saveImages(src,obj,idx)
% % Calculate the total frame number for each frame,
% % in order to save the files in order.
% currframes = src.FramesAcquired - src.FramesAcquiredFcnCount;
% 
% % Read images from the videoinput buffer.
% imgs = getdata(src,src.FramesAvailable);
% 
% % Save each image to a file in order.
% for i = 1:src.FramesAcquiredFcnCount
%     imname = "c:\temp\data\cam" + idx + "_img_" + (currframes + i) + ".TIFF";
%     % imname = "c:\temp\data\cam_img_" + (currframes + i) + ".TIFF";
%     imwrite(imgs(:,:,:,i),imname);
% end
% end
% 
% %% https://www.mathworks.com/help/parallel-computing/perform-image-acquisition-from-webcam-and-parallel-image-processing.html
% 
% %% parfeval
% 
% 
% % 
% % 
% % %% Handles and parfeval
% % classdef example_class<handle
% %     properties
% %         A
% %     end
% %     methods
% %         function h=example_class()
% %             h.A=1;
% %         end
% %         function newA = multiply_A(h,data)
% %             % Returns new value, doesn't modify h
% %             newA = h.A;
% %             for m=1:10
% %                  newA = newA*data;
% %             end
% %         end
% %         function apply_A(h, newA)
% %             % Simply modifies h
% %             h.A = newA;
% %         end
% %     end
% % end
% % 
