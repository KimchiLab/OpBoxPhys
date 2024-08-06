% OpBox_Add subjects script
% Depends on global variables in prior fuctions
if isempty(s_in)
    fprintf('No NI devices, can not add subjects.\n');
    return;
end

[box_info, subj_info] = OpBoxPhys_InfoBoxSubj;
% Only look at data from prespecified room
box_info = box_info(strcmp({box_info.room}, room));
subj_info = subj_info(strcmp({subj_info.room}, room));
if isempty(subj_info)
    fprintf('No subjects found for room %s.\n', room);
    return;
end

subj_names = OpBox_SubjectsNames(subj_info);

% lh.draw.Enabled = false; % Turn off graphing listener handle during update

% Process each new subject
for i_subj = 1:numel(subj_names)
    new_subject = OpBox_Subject(subj_names{i_subj}, room);
    new_subject = new_subject.BoxInfo(box_info, subj_info);

    if numel(subjects) && sum(new_subject.box == [subjects.box])
        fprintf('Subject %s not added, Box %d in Room %s already in use.\n', new_subject.name, new_subject.box, new_subject.room);
    elseif isnan(new_subject.box)
        fprintf('Subject %s not added, box not defined for Room %s.\n', new_subject.name, new_subject.room);
    else
        new_subject = new_subject.ChanMatch(s_in);
        if new_subject.num_analog ~= numel(new_subject.idx_analog)
            fprintf('Subject %s not added, analog channels not found using current settings.\n', new_subject.name);
            fprintf('Check that the correct DAQ is assigned to this subject/box,\nand that the selected DAQ supports this channel type.\n\n');
        elseif new_subject.num_digital ~= numel(new_subject.idx_digital)
            fprintf('Subject %s not added, digital channels not found on current machine with current settings.\n', new_subject.name);
            fprintf('Check that the correct DAQ is assigned to this subject/box,\nand that the selected DAQ supports this channel type.\n\n');
        elseif new_subject.num_counter ~= numel(new_subject.idx_counter)
            fprintf('Subject %s not added, counter channels not found on current machine with current settings.\n', new_subject.name);
            fprintf('Check that the correct DAQ is assigned to this subject/box,\nand that the selected DAQ supports this channel type.\n\n');
        else
            % Subject valid: Setup Filename
            new_subject = new_subject.FileName();

            % First set up camera if needed: Will take a little time before ready to save
            if numel(new_subject.cam_str)
                %%% Everything local:
                % % Preview: works
                % % Synching: works
                % % Stopping: works
                % % Fast enough? Nope, slowing acq/update >=6 cameras
                % new_subject.cam = OpBoxPhys_CameraPrep(new_subject.cam_str, new_subject.filename);

                %%% Using parallel computing toolbox
                if isempty(gcp("nocreate"))
                    pool = parpool('Processes');
                    pool.IdleTimeout = minutes(hours(3));
                end

                % %%% parfeval: talk back via fetchOutputs?
                % % doesn't work, since fetchOutputs is analogous to saving and reloading vars
                % % and can't save/reload videoinput class vars

                % %%% parfeval: make camera within parfeval: talk back via dataqueue
                % % Preview: trying to get most recent frame, can't peekdata if logging to disk?!
                % % Synching: Can share frames acquired via dataqueue: done
                % % Stopping: How to find exact right camera to stop?! videos not viewable currently. can't fetch after waiting leads to error: Warning: An error occurred when running a class's loadobj method. The object that was loaded from the
                %     % MAT-file was a copy of the object before the loadobj method was run. The rest of the variables were also
                %     % loaded from the MAT-file.
                %     % The encountered error was:
                %     % Error using videoinput
                %     % ADAPTORNAME must be specified as a character vector or string.
                % % Fast enough? Yes, distributed and updating screen
                % new_subject.dataqueue = parallel.pool.DataQueue;
                % new_subject.lh_dataqueue = afterEach(new_subject.dataqueue, @DataQueueUpdate);
                % % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrepQueue, 0, new_subject.cam_str, new_subject.filename,new_subject.dataqueue);
                % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrepQueue, 1, new_subject.cam_str, new_subject.filename,new_subject.dataqueue);
                % new_subject.num_frame = 0;

                % %%% parfeval: make camera wrapper constant within parfeval with wrapper to improve stopping?
                % % Doesn't work if make cam inside: % vidwrapper.Value = cam; % Unable to set the 'Value' property of class 'Constant' because it is read-only.
                % % Doesn't work consistently if make cam outside
                % new_subject.dataqueue = parallel.pool.DataQueue;
                % new_subject.lh_dataqueue = afterEach(new_subject.dataqueue, @DataQueueUpdate);
                % str_target_format = 'MJPG_1024x768';
                % new_subject.vidWrapper = parallel.pool.Constant(@() videoinput('winvideo', new_subject.cam_str, str_target_format));
                % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrepWrapper, 1, new_subject.cam_str, new_subject.filename,new_subject.dataqueue, new_subject.vidWrapper);

                % %% SPMD based approach: one at a time? end up running on 1 spmd processor
                % % Preview: Can not use preview within spmd, can not start preview outside of spmd if logging is ongoing
                % % Synching problem: How to get # frames at each time point
                % % Stopping problem: How to find exact right camera to stop
                % % Fast enough? Unclear
                %
                % % Spin camera into a separate process
                % str_target_format = 'MJPG_1024x768';
                % % spmd does NOT work meaningfully, only superficially but then can't access object externally once started:
                % % cont to access internally? but can't do image preview, whether start before or after spmd start
                % % But can at least start and stop later
                %
                % spmd(1) % all runs on 1 worker?! doesn't keep creating new ones
                %     spmd_struct.name = new_subject.cam_str;
                %     spmd_struct.cam = videoinput('winvideo', new_subject.cam_str, str_target_format);
                %     set(spmd_struct.cam, 'FramesPerTrigger', inf); % Collect continuously once started, triggers error outside of spmd, can't pass back if started?
                %     % set(cam, 'FramesAcquiredFcnCount', 30);  % Execute FramesAcquiredFcn every n frames, but doesn't help logging/preview. Also for version that notes timestamps for each frame, currently not used
                %
                %     % Set image acquisition settings
                %     set(spmd_struct.cam.Source, 'Exposure', -8);
                %     % cam.ReturnedColorspace = "grayscale"; % Does not work with saving grayscale, despite setting configuration
                %
                %     % Setup Video Logger: save frames to disk with compression
                %     set(spmd_struct.cam, 'LoggingMode', 'disk');
                %     vid_writer = VideoWriter(new_subject.filename, 'MPEG-4');  % Make sure this matches OpBoxPhys_LogData & OpBox_Add
                %     set(vid_writer, 'Quality', 50); % 0-100: lower quality/smaller file size, default 75
                %     % vid_writer = VideoWriter(filename, 'Grayscale AVI');
                %     % Does not work with saving grayscale, despite
                %     % setting configuration: The specified VideoWriter object
                %     % is using a profile that requires grayscale data.
                %     % Still doesn't work if using "ReturnedColorSpace", "grayscale" in videoinput
                %     set(spmd_struct.cam, 'DiskLogger', vid_writer); % Point DiskLogger to new video writer
                %
                %     % Start camera
                %     start(spmd_struct.cam);
                % end
                % new_subject.cam = spmd_struct; % Returned as composite object, pull using cell notation: get warning error, but ok?
                %
                % % spmd(1)
                % %     % How to ensure stopping right camera? can get if only one camera in same function, but how about once exit?
                % %     stop(spmd_struct.cam)
                % % end
                % % new_subject.cam = spmd_struct.cam{1}; % Returned as composite object, pull using cell notation: get warning error, but ok?

                %% SPMD based approach: Preemptive pool
                % Preview: WORKING ON GETTING LAST FRAME: %%% !!! %%% Can not use preview within spmd, can not start preview outside of spmd if logging is ongoing
                % Synching problem: Can assign by going through all
                % Stopping problem: Can use spmdIndex and camera list to find camera
                % Fast enough? yes, distributed across multiple processes/workers

                % Update single camera settings
                new_subject.cam_idx = find(strcmpi(new_subject.cam_str, {wincam_info.DeviceInfo.DeviceName}));
                spmd(numel(cam_global))
                    if spmdIndex == new_subject.cam_idx
                        % Set image acquisition settings
                        set(cam_global.cam.Source, 'Exposure', -8);

                        % Setup Video Writer: save frames to disk with compression
                        cam_global.vid_writer = VideoWriter(new_subject.filename, 'MPEG-4');  % Make sure this matches OpBoxPhys_LogData & OpBox_Add
                        set(cam_global.vid_writer, 'Quality', 50); % 0-100: lower quality/smaller file size, default 75

                        % Setup Video Logger
                        % No: if do this, can't peek or otherwise see data easily without also logging to memory
                        % cam_global.cam.LoggingMode = 'disk&memory';
                        cam_global.cam.LoggingMode = 'disk';
                        set(cam_global.cam, 'DiskLogger', cam_global.vid_writer); % Point DiskLogger to new video writer

                        % % Log by collecting frames, allowing for "preview" within spmd: 
                        % % No: stops after each new camera added?!
                        % % The problem is that you're trying to send a VideoWriter object to the workers, and that's not allowed. https://www.mathworks.com/matlabcentral/answers/1655195-parfor-for-movie-writevideo
                        % cam_global.cam.LoggingMode = 'memory';
                        % open(cam_global.vid_writer); % Need to open before writing
                        % cam_global.cam.ReturnedColorspace = "grayscale"; % Does not work with saving grayscale with DiskLogging, despite setting configuration unless modifying images
                        % cam_global.cam.FramesAcquiredFcnCount = 30; % Number of frames that must be acquired before frames acquired event is generated 3 = ~100ms
                        % cam_global.cam.FramesAcquiredFcn = {@OpBoxPhys_LogVideo, cam_global.vid_writer};

                        start(cam_global.cam);
                    end
                end
                % new_subject.curr_frame = cam_global{new_subject.cam_idx}.frame;

                %%% parfeval: just use parfeval to write/save frames? via ordered dataqueue?

                % % Spin camera into a separate process
                % str_target_format = 'MJPG_1024x768';
                % % str_target_format = 'MJPG_640x480';
                %
                % % https://www.mathworks.com/help/imaq/acquire-images-using-parallel-worker.html
                % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrep, 0, new_subject.cam_str, new_subject.filename);
                % % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrep, 2, new_subject.cam_str, new_subject.filename);
                % % need to be able to stop based on external event/input
                %
                % % https://www.mathworks.com/help/matlab/ref/parfeval.html
                % new_subject.vidWrapper = parallel.pool.Constant(@() videoinput());
                % new_subject.vidWrapper = parallel.pool.Constant(@() videoinput('winvideo', new_subject.cam_str, str_target_format));
                % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrepWrapper, 0, new_subject.vidWrapper.Value, new_subject.filename);
                %
                %
                % % https://www.mathworks.com/matlabcentral/answers/269625-how-to-use-properly-parfor
                %
                %
                % new_subject.cam = new_subject.vidWrapper.Value;
                % new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrep, 0, new_subject.cam_str, new_subject.filename);
                % new_subject.parallelf.State;
                % while ~strcmpi(new_subject.parallelf.State, 'finished')
                %     % Wait for camera to be initialized
                % end
                % new_subject.parallelf.State
                % pause(10);
                % [cam, cell_cam] = fetchOutputs(new_subject.parallelf)
                % 1;
                % temp_cell = new_subject.parallelf.OutputArguments;
                % [cam, cell_cam] = temp_cell{1}; % Invalid Image Acquisition object. This object is not associated with any hardware and should be removed from your workspace using CLEAR.
                % [~, new_subject.cam] = fetchNext(new_subject.parallelf);
                % new_subject.cam = fetchOutputs(new_subject.parallelf);
                % [cam, cell_cam] = fetchOutputs(new_subject.parallelf);

            end

            % Physiology file starts writing as soon as there is an available fid, set up after camera
            new_subject = new_subject.FilePrepPhys();

            subjects = [subjects; new_subject]; % Append new subject, sort after
        end
    end
end

% Resort subjects and redraw graphs
if numel(subjects)
    [~, sort_idx] = sort([subjects.box]);
    subjects = subjects(sort_idx);
    subjects = OpBox_Graphs(subjects);
end

%% Clear data & Change graphs/zoom (back) to default settings
clearvars -except subjects s_in room cam_global wincam_info; % Clear unnecessary variables, only keep those specified here
% OpBox_Axis_Time([0 5], [-0.5 0.5]); % Back to default axes (can't define as part of s_in)
% lh.draw.Enabled = true; % Turn on graphing listener handle after update


% %% DataQueue function
% function DataQueueUpdate(cell_data) % name_cam, num_frame
% global subjects;
% 
% mask = strcmp(cell_data{1}, {subjects.cam_str});
% if sum(mask)
%     num_frame = cell_data{2};
%     % curr_frame = cell_data{3};
%     subjects(mask).num_frame = num_frame;
% end
% end
