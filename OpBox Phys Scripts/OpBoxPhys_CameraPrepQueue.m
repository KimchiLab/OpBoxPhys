function cam = OpBoxPhys_CameraPrepQueue(cam_id, cam_filename, dataqueue)

% Image Acquisition Toolbox must be installed & winvideo add-on
% Check available resolutions/formats:
% info = imaqhwinfo('winvideo');
% info.DeviceInfo.SupportedFormats'
% 320/240=1.333
% 640/480=1.333
% 800/600=1.333
% 1024/768=1.333
% 1280/720=1.777
% 1280/1024=1.23
% 1920/1080=1.777
str_target_format = 'MJPG_1024x768';
% str_target_format = 'MJPG_640x480';

% May have to match cam ID if not in order? But have to assume so here, should be changed in csv file
cam = videoinput('winvideo', cam_id, str_target_format);
% cam.Name = cam_id; % Overwrite internal less informative name, have not yet figured out where to get this, as it must be stored based on disp(cam)
cam.Tag = cam_id; % Overwrite internal less informative name, have not yet figured out where to get this, as it must be stored based on disp(cam)

cam.FramesPerTrigger = inf; % Collect continuously once started
% set(cam, 'FramesAcquiredFcnCount', 30);  % Execute FramesAcquiredFcn every n frames, but doesn't help logging/preview. Also for version that notes timestamps for each frame, currently not used

% Set image acquisition settings
set(cam.Source, 'Exposure', -8);
% cam.ReturnedColorspace = "grayscale"; % Does not work with saving grayscale, despite setting configuration

% Setup Video Logger: save frames to disk with compression
cam.LoggingMode = 'disk';

vid_writer = VideoWriter(cam_filename, 'MPEG-4');  % Make sure this matches OpBoxPhys_LogData & OpBox_Add
set(vid_writer, 'Quality', 50); % 0-100: lower quality/smaller file size, default 75
% vid_writer = VideoWriter(filename, 'Grayscale AVI');
% Does not work with saving grayscale, despite
% setting configuration: The specified VideoWriter object
% is using a profile that requires grayscale data. Still an
% error if using "ReturnedColorSpace", "grayscale in videoinput

cam.DiskLogger = vid_writer; % Point DiskLogger to new video writer

% Set FramesAcquiredFcn to queue frame counts
cam.FramesAcquiredFcnCount = 3; % Number of frames that must be acquired before frames acquired event is generated 3 = ~100ms
cam.FramesAcquiredFcn = {@UpdateQueue, dataqueue};

% Start camera
start(cam);

% cell_cam = {cam}; % wrap it to protect it on return from parfeval?

end


% Helper function to send counts to queue
function UpdateQueue(src, obj, dataqueue)
    send(dataqueue, {src.Tag, src.FramesAcquired});
    % send(dataqueue, [src.DeviceID, src.FramesAcquired]);
    % send(dataqueue, src.FramesAcquired);
end
