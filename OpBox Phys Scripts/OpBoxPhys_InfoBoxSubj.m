% Load information about OpBox boxes and subjects
function [box_info, subj_info] = OpBoxPhys_InfoBoxSubj()

% Filenames
file_box = 'InfoBoxes.csv';
file_subj = 'InfoSubjects.csv';

if exist('readtable', 'file') % Started with R2013b: https://www.mathworks.com/help/matlab/ref/readtable.html
    % Box info
    tbl_box = readtable(file_box);
    % Convert variable names to match prior/specified names
    tbl_box.Properties.VariableNames = lower(tbl_box.Properties.VariableNames); % Lower case
    tbl_box.Properties.VariableNames{strcmp('box', tbl_box.Properties.VariableNames)} = 'name';
    tbl_box.Properties.VariableNames = regexprep(tbl_box.Properties.VariableNames, '^ch', 'ch_');
    tbl_box.Properties.VariableNames = regexprep(tbl_box.Properties.VariableNames, '^nidev', 'nidev_');
    tbl_box.Properties.VariableNames = regexprep(tbl_box.Properties.VariableNames, '^volt', 'volt_');
    tbl_box.Properties.VariableNames = regexprep(tbl_box.Properties.VariableNames, '^trigger', 'trigger_');
    tbl_box.Properties.VariableNames = regexprep(tbl_box.Properties.VariableNames, 'matlabcamera', 'cam');
    % Convert char/string to num/double
    ch_fields = {'ch_analog', 'ch_digital', 'ch_counter'};
    for i_field = 1:numel(ch_fields)
        if iscell(tbl_box.(ch_fields{i_field})) && ischar(tbl_box.(ch_fields{i_field}){1})
            tbl_box.(ch_fields{i_field}) = CellStrToCellNums(tbl_box.(ch_fields{i_field}));
        end
    end
    box_info = table2struct(tbl_box); % Prior versions used structs with specified field names
    % Missing data in tables are listed as NaN for double data value types
    % but previously empty arrays in struct in to match prior versions
    field_names = fieldnames(box_info);
    for i_box = 1:size(box_info)
        for i_field = 1:numel(field_names)
            if isnumeric(box_info(i_box).(field_names{i_field})) && sum(isnan(box_info(i_box).(field_names{i_field})))
                box_info(i_box).(field_names{i_field}) = [];
            end
        end
    end

    % Subject info
    tbl_subj = readtable(file_subj);
    % Convert variable names to match prior/specified names
    tbl_subj.Properties.VariableNames = lower(tbl_subj.Properties.VariableNames); % Lower case
    tbl_subj.Properties.VariableNames{strcmp('subject', tbl_subj.Properties.VariableNames)} = 'name';
    subj_info = table2struct(tbl_subj); % Prior versions used structs with specified field names
else % Use csv import function from https://www.mathworks.com/matlabcentral/fileexchange/23573-csvimport
    file_data = csvimport(file_box); % http://uk.mathworks.com/matlabcentral/fileexchange/23573-csvimport
    col_room = strcmp('Room', file_data(1,:));
    col_name = strcmp('Box', file_data(1,:));
    col_nidev_analog = strcmp('NIDevAnalog', file_data(1,:)); % Currently need to have 0's in unused cells to appropriately be interpreted as numbers rather than strings/chars
    col_ch_analog = strcmp('ChAnalog', file_data(1,:));
    col_volt_range = strcmp('VoltRange', file_data(1,:));
    col_nidev_digital = strcmp('NIDevDigital', file_data(1,:)); % Currently need to have 0's in unused cells to appropriately be interpreted as numbers rather than strings/chars
    col_ch_digital = strcmp('ChDigital', file_data(1,:));
    col_ch_trigger = strcmp('ChTrigger', file_data(1,:));
    col_trigger_thresh = strcmp('TriggerThresh', file_data(1,:));
    col_ch_offset = strcmp('ChOffset', file_data(1,:));
    col_nidev_counter = strcmp('NIDevCounter', file_data(1,:)); % Currently need to have 0's in unused cells to appropriately be interpreted as numbers rather than strings/chars
    col_ch_counter = strcmp('ChCounter', file_data(1,:));
    col_cam = strcmp('MatlabCamera', file_data(1,:));

    box_info = struct('room', file_data(2:end,col_room), 'name', file_data(2:end,col_name), ...
        'nidev_analog', file_data(2:end,col_nidev_analog), 'ch_analog', CellStrToCellNums(file_data(2:end,col_ch_analog)), 'volt_range', CellStrToCellNums(file_data(2:end,col_volt_range)), ...
        'nidev_digital', file_data(2:end,col_nidev_digital), 'ch_digital', CellStrToCellNums(file_data(2:end,col_ch_digital)), ...
        'ch_trigger', CellStrToCellNums(file_data(2:end,col_ch_trigger)), 'trigger_thresh', CellStrToCellNums(file_data(2:end,col_trigger_thresh)), 'ch_offset', CellStrToCellNums(file_data(2:end,col_ch_offset)), ...
        'nidev_counter', file_data(2:end,col_nidev_counter), 'ch_counter', CellStrToCellNums(file_data(2:end,col_ch_counter)), ...
        'cam', CellStrToCellNums(file_data(2:end,col_cam)));

    file_data = csvimport(file_subj); % http://uk.mathworks.com/matlabcentral/fileexchange/23573-csvimport
    col_subjname = strcmp('Subject', file_data(1,:));
    col_room = strcmp('Room', file_data(1,:));
    col_boxname = strcmp('Box', file_data(1,:));
    col_group = strcmp('Group', file_data(1,:));
    subj_info = struct('room', file_data(2:end,col_room), 'name', file_data(2:end,col_subjname), 'box', file_data(2:end,col_boxname), 'group', file_data(2:end,col_group));
end

% Convert subject or room "numbers" to chars
if isnumeric(box_info(1).room)
    for i = 1:numel(box_info)
        box_info(i).room = num2str(box_info(i).room);
    end
end
if isnumeric(subj_info(1).room)
    for i = 1:numel(subj_info)
        subj_info(i).room = num2str(subj_info(i).room);
    end
end
if isnumeric(subj_info(1).name)
    for i = 1:numel(subj_info)
        subj_info(i).name = num2str(subj_info(i).name);
    end
end
