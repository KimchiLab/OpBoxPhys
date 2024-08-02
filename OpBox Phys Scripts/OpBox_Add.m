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
        fprintf('Subject %s not added, Box %d in Room %d already in use.\n', new_subject.name, new_subject.box, new_subject.room);
    elseif isnan(new_subject.box)
        fprintf('Subject %s not added, box not defined for Room %d.\n', new_subject.name, new_subject.room);
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
            if numel(new_subject.cam_id)
                % new_subject.cam = OpBoxPhys_CameraPrep(new_subject.cam_id, new_subject.filename);

                % Spin camera into a separate process
                % https://www.mathworks.com/help/matlab/ref/parfeval.html
                new_subject.parallelf = parfeval(@OpBoxPhys_CameraPrep, 2, new_subject.cam_id, new_subject.filename);
                new_subject.parallelf.State
                while ~strcmpi(new_subject.parallelf.State, 'finished')
                    % Wait for camera to be initialized
                end
                new_subject.parallelf.State
                pause(10);
                [cam, cell_cam] = fetchOutputs(new_subject.parallelf)
                1;
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
clearvars -except subjects s_in room; % Clear unnecessary variables, only keep those specified here
% OpBox_Axis_Time([0 5], [-0.5 0.5]); % Back to default axes (can't define as part of s_in)
% lh.draw.Enabled = true; % Turn on graphing listener handle after update
