function [box_info, subj_info] = OpBoxPhys_InfoBoxSubj()

dir_orig = pwd;

% if exist('cdOpBox', 'file')
%     cdOpBox;
% end

filename = 'InfoBoxes.csv';
file_data = csvimport(filename); % http://uk.mathworks.com/matlabcentral/fileexchange/23573-csvimport
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

filename = 'InfoSubjects.csv';
file_data = csvimport(filename); % http://uk.mathworks.com/matlabcentral/fileexchange/23573-csvimport
col_subjname = strcmp('Subject', file_data(1,:));
col_room = strcmp('Room', file_data(1,:));
col_boxname = strcmp('Box', file_data(1,:));
col_group = strcmp('Group', file_data(1,:));
subj_info = struct('room', file_data(2:end,col_room), 'name', file_data(2:end,col_subjname), 'box', file_data(2:end,col_boxname), 'group', file_data(2:end,col_group));

% Convert room "numbers" to names
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

cd(dir_orig);
