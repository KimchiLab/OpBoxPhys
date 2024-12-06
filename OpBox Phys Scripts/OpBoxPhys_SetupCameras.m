% Set up National Instrument data acquisition devices
% Using Mathworks Data Acquisition Toolbox
function [cam_composite, wincam_info, dataqueue] = OpBoxPhys_SetupCameras()

%% Using parallel computing toolbox
if isempty(gcp("nocreate"))
    pool = parpool('Processes');
    pool.IdleTimeout = minutes(hours(3));
end

% Make data queue for sending info back to client from workers
if ~exist('dataqueue', 'var')
    dataqueue = parallel.pool.DataQueue;
    afterEach(dataqueue, @OpBoxPhys_ProcessDataQueue);
end

%% Try to set up cameras
if ~exist('imaqhwinfo', 'file')
    fprintf('Image Acquisition Toolbox not found\n');
else
    %     adaptor_info = imaqhwinfo;
    %     fprintf('%d adaptor(s) found using imaqhwinfo from Image Acquisition Toolbox\n', numel(adaptor_info.InstalledAdaptors));
    wincam_info = imaqhwinfo('winvideo');
    fprintf('%d Windows camera device(s) found using imaqhwinfo from Image Acquisition Toolbox\n', numel(wincam_info.DeviceInfo));
    for i_cam = 1:numel(wincam_info.DeviceInfo)
        fprintf('%3d: %s\n', wincam_info.DeviceInfo(i_cam).DeviceID, wincam_info.DeviceInfo(i_cam).DeviceName);
    end
end

%% Setup Cameras as spmd pool
num_cam = numel(wincam_info.DeviceIDs);
num_row = 768; % Based on prior checks of selected cameras
num_col = 1024;
str_target_format = sprintf('MJPG_%dx%d', num_col, num_row);
warning('off', 'MATLAB:loadobj');

% Initialize camera & general capture info
spmd(num_cam)
    cam_composite.name = wincam_info.DeviceInfo(spmdIndex).DeviceName;
    cam_composite.id = wincam_info.DeviceInfo(spmdIndex).DeviceID;
    cam_composite.idx = spmdIndex;
    cam_composite.frame = uint8(zeros(num_row, num_col));
    if ~sum(strcmpi(str_target_format, wincam_info.DeviceInfo(spmdIndex).SupportedFormats))
        temp_format = wincam_info.DeviceInfo(spmdIndex).SupportedFormats{1};
        fprintf('Format %s not supported by %s, using %s', str_target_format, wincam_info.DeviceInfo(spmdIndex).DeviceName, temp_format);
        str_target_format = temp_format;
    end
    cam_composite.cam = videoinput('winvideo', cam_composite.name, str_target_format);

    % Update camera settings
    cam_composite.cam.FramesPerTrigger = inf; % Collect continuously once started, triggers error outside of spmd, can't pass back if started?

    % % Setup Video Logger: save frames to disk with compression
    % % cam_composite.cam.LoggingMode = 'disk';
    % cam_composite.cam.LoggingMode = 'memory';
end
