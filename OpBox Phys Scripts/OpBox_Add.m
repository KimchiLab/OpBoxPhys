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

lh.draw.Enabled = false; % Turn off graphing listener handle during update

% Process each new subject
for i_subj = 1:numel(subj_names)
    new_subject = OpBox_Subject(subj_names{i_subj}, room);
    new_subject = new_subject.BoxInfo(box_info, subj_info);
    
    if ~isempty(subjects) && sum(new_subject.box == [subjects.box])
        fprintf('Subject %s not added, Box %d in Room %d already in use.\n', new_subject.name, new_subject.box, new_subject.room);
    elseif isnan(new_subject.box)
        fprintf('Subject %s not added, box not defined for Room %d.\n', new_subject.name, new_subject.room);
    else
        new_subject = new_subject.ChanMatch(s_in);
%         ch_fields = {'analog', 'digital', 'counter'};
%         for i_field = 1:numel(ch_fields)
%         end
        if new_subject.num_analog ~= numel(new_subject.idx_analog)
            fprintf('Subject %s not added, analog channels not found on current machine with current settings.\n\n', new_subject.name);
        elseif new_subject.num_digital ~= numel(new_subject.idx_digital)
            fprintf('Subject %s not added, digital channels not found on current machine with current settings,\ncheck that the selected DAQ supports this channel type.\n\n', new_subject.name);
        elseif new_subject.num_counter ~= numel(new_subject.idx_counter)
            fprintf('Subject %s not added, counter channels not found on current machine with current settings,\ncheck that the selected DAQ supports this channel type.\n\n', new_subject.name);
        else
            % Subject valid: Setup Filename
            new_subject = new_subject.FileName;
            % First set up camera if needed: Will take a little time before ready to save
            if ~isempty(new_subject.cam_id) && (1 <= new_subject.cam_id)
                % Image Acquisition Toolbox must be installed
                % new_subject.cam = videoinput('winvideo', new_subject.cam_id, 'MJPG_320x240');  % Initialize camera & resolution
                new_subject.cam = videoinput('winvideo', new_subject.cam_id, 'YUY2_320x240');  % Initialize camera & resolution
                set(new_subject.cam, 'FramesPerTrigger', inf);
                set(new_subject.cam, 'FramesAcquiredFcnCount', 30);  % Try to display roughly 1/sec. Can't guarantee frame rate?
                
                % Setup Video Logger
                set(new_subject.cam,'LoggingMode','disk');
                vid_writer = VideoWriter([new_subject.dir_save new_subject.filename], 'MPEG-4');
                % May have to match cam ID if not in order? But have to assume so here, should be changed in csv file
                set(new_subject.cam, 'DiskLogger', vid_writer);
                start(new_subject.cam);
            end
            
            % Physiology file starts writing as soon as there is an available fid
            new_subject = new_subject.FilePrepPhys;
            subjects = [subjects; new_subject];
            
        end
    end
end

% Resort subjects and redraw graphs
if ~isempty(subjects)
    [~, sort_idx] = sort([subjects.box]);
    subjects = subjects(sort_idx);
    subjects = OpBox_Graphs(subjects);
end

%% Clear data & Change graphs/zoom (back) to default settings
clearvars -except subjects s_in lh room; % Clear unnecessary variables, only keep those specified here
% OpBox_Axis_Time([0 5], [-0.5 0.5]); % Back to default axes (can't define as part of s_in)
lh.draw.Enabled = true; % Turn on graphing listener handle after update
