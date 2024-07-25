classdef OpBox_Subject
    
    properties
        % Subject/Box properties
        name
        room
        box
        group
        % Data acquisition device specific properties
        volt_range
        nidev_analog
        ch_analog
        num_analog
        idx_analog
        nidev_digital
        ch_digital
        num_digital
        idx_digital
        idx_chan
        ch_trigger
        trigger_thresh
        ch_offset
        nidev_counter
        ch_counter
        num_counter
        idx_counter
        Fs
        num_ch
        % File specific properties
        filename
        fid
        dir_save
        num_ts_written
        num_ts_cutoff
        % bytes_written
        % bytes_cutoff
        fid_camsynch
        % Graph specific properties
        axis_time
        h_time_text
        h_plot_time
        h_plot_counter
        axis_freq
        h_plot_freq
        axis_ep
        h_plot_ep
        h_n_peri   
        num_peri
        ts_start
        % Camera Specific Properties
        cam_id
        cam
        axis_cam
        h_cam
    end

    
    methods
        function obj = OpBox_Subject(subj_name, room)
            if nargin < 2
                % Get room number
                % room = input('\nEnter Room #: ');
                room = '110';
                if nargin < 1
                    % Get subject names and planned boxes (Can store putative boxes for each subject elsewhere)
                    % subj_str = input('\nEnter subject names (sep by spaces): ', 's');
                    subj_name = 'Test';
                end
            end
            obj.room = room;
            obj.name = subj_name;
            obj.ts_start = -1;
        end
        
        function obj = BoxInfo(obj, box_info, subj_info)
            % restrict box & subj info to specified room
            % box_info = box_info([box_info.room]==obj.room);  % When room was numeric
            % subj_info = subj_info([subj_info.room]==obj.room);  % When room was numeric
            box_info = box_info(strcmp({box_info.room}, obj.room));
            subj_info = subj_info(strcmp({subj_info.room}, obj.room));
            idx_subj = find(strcmpi(obj.name, {subj_info.name}));
            % Find box number for this subject
            if ~isempty(idx_subj)
                obj.name = subj_info(idx_subj).name;
                obj.box = subj_info(idx_subj).box;
                obj.group = subj_info(idx_subj).group;
%                 fprintf('Subject %s found: Room %d, Box %d\n', obj.name, obj.room, obj.box);
%             else
%         %         fprintf('Subject %s: Could not find info\n', subj_names{i_subj});
%         %         subj_rooms(i_subj) = input(sprintf('Subject %s: Enter room #: ', subj_names{i_subj}));
%                 subj_rooms(i_subj) = room;
%                 fprintf('Subject %s: Could not find info, assuming room %d\n', subj_names{i_subj}, subj_rooms(i_subj));
%                 fprintf('Valid boxes: ');
%                 fprintf('%d ', sort([box_info.name]));
%                 fprintf('\n');
%                 subj_boxes(i_subj) = input(sprintf('Subject %s: Enter box #: ', subj_names{i_subj}));
%                 mask_valid(i_subj) = true;
            elseif isempty(obj.box)
                fprintf('Subject %s does not have a box for room %s.\n', obj.name, obj.room);
                if 1 == numel(box_info)
                    fprintf('Only one box available: %d, assigning subject to this box.\n', box_info.name);
                    obj.box = box_info.name;
                else
                    obj.box = box_info(1).name;  % Default box
                    fprintf('Type desired box #. Possible = ');
                    fprintf('%d ', [box_info.name]);
                    str = input(sprintf('. (Default = %d): ', obj.box), 's');
                    if ~isempty(str)
                        obj.box = str2double(str);
                    end
                end
            end
            % Find box info for this box number for this subject
            % [val, idx_a, idx_b] = intersect(obj.box, [box_info.name]); % identify the box index
            [~, ~, idx_b] = intersect(obj.box, [box_info.name]); % identify the box index
            if ~isempty(idx_b)
                obj.nidev_analog = box_info(idx_b).nidev_analog;
                obj.ch_analog = box_info(idx_b).ch_analog;
                obj.volt_range = box_info(idx_b).volt_range;
                obj.nidev_digital = box_info(idx_b).nidev_digital;
                obj.ch_digital = box_info(idx_b).ch_digital;
                obj.ch_trigger = box_info(idx_b).ch_trigger;
                obj.trigger_thresh = box_info(idx_b).trigger_thresh;
                obj.ch_offset = box_info(idx_b).ch_offset;
                obj.nidev_counter = box_info(idx_b).nidev_counter;
                obj.ch_counter = box_info(idx_b).ch_counter;
                obj.cam_id = box_info(idx_b).cam;
                if numel(obj.nidev_counter)
                    if obj.nidev_digital ~= obj.nidev_analog || obj.nidev_counter ~= obj.nidev_analog || obj.nidev_digital ~= obj.nidev_counter
                        fprintf('WARNING: NI device numbers differ for data streams: Analog=%d, Digital=%d, Counter=%d\n', obj.nidev_analog, obj.nidev_digital, obj.nidev_counter);
                    end
                else
                    if obj.nidev_digital ~= obj.nidev_analog
                        fprintf('WARNING: NI device numbers differ for data streams: Analog=%d, Digital=%d\n', obj.nidev_analog, obj.nidev_digital);
                    end
                end
            else
                fprintf('Subject %s: Could not find Box %d info, set to NaN\n', obj.name, obj.box);
                obj.box = NaN;
            end
        end
        
        function obj = ChanMatch(obj, s_in)
            % Get channel names
            chans = get(s_in, 'Channels');
            chan_idx = CellStrToNums({chans.ID})'; % needs to be same orientation as chan_analog for operations below. Easiest to read if row vector
            chan_devs = nan(size(chans));

            % Get device names for rearrangements of devices
            temp_devs = {chans.Device};
            for i_ch = 1:numel(temp_devs)
                chan_devs(i_ch) = str2double(temp_devs{i_ch}.ID(end));
            end

            % Find channels for each subject, taking into account device
            chan_analog = strncmp('ai', {chans.ID}, 2);
            obj.num_analog = sum(~isnan(obj.ch_analog));
            if obj.num_analog > 0
                temp_ch_idx = nan(size(chan_idx));
                temp_ch_idx(chan_analog) = chan_idx(chan_analog);
                temp_ch_idx(chan_devs ~= obj.nidev_analog) = NaN;
                [~,idx_source] = intersect(temp_ch_idx, obj.ch_analog);
                obj.idx_analog = idx_source(:)'; % for some reason intersect changes row vector inputs into a column vector. convert back for readability
                obj.idx_chan = obj.idx_analog;
            end
            
            % Counter/Rotary Encoder Channels
            chan_counter = strncmp('ctr', {chans.ID}, 3);
            obj.num_counter = sum(~isnan(obj.ch_counter));
            if obj.num_counter > 0
                temp_ch_idx = nan(size(chan_idx));
                temp_ch_idx(chan_counter) = chan_idx(chan_counter);
                temp_ch_idx(chan_devs ~= obj.nidev_counter) = NaN;
                [~,idx_source] = intersect(temp_ch_idx, obj.ch_counter);
                obj.idx_counter = idx_source(:)'; % for some reason intersect changes row vector inputs into a column vector. convert back for readability
                obj.idx_chan = [obj.idx_chan, obj.idx_counter];
            end

            % Digital Channels
            obj.num_digital = sum(~isnan(obj.ch_digital));
            if obj.num_digital > 0
                temp_ch_idx = nan(size(chan_idx));
                temp_ch_idx(~chan_analog) = chan_idx(~chan_analog);
                temp_ch_idx(chan_devs ~= obj.nidev_digital) = NaN;
                [~,idx_source] = intersect(temp_ch_idx, obj.ch_digital);
                obj.idx_digital = idx_source(:)'; % for some reason intersect changes row vector inputs into a column vector. convert back for readability
                obj.idx_chan = [obj.idx_chan, obj.idx_digital];
            end

            % Total channels
            obj.num_ch = obj.num_analog + obj.num_counter + obj.num_digital + 1; % +1 for timestamp column/"channel"
            
            % If trigger not already defined, set to first digital channel
            if isempty(obj.ch_trigger) && obj.num_digital > 0
                obj.ch_trigger = obj.num_analog + 1;
            end
            % If there is a trigger, set threshold as half of max range
            if ~isempty(obj.ch_trigger)
                if obj.ch_trigger <= obj.num_analog
                    if obj.trigger_thresh == 0
                        temp_range = get(s_in.Channels(1).Range);
                        obj.trigger_thresh = 0.5 * temp_range.Max;
                    end
                else % Digital channel
                    obj.trigger_thresh = 1;
                end
            end
            
            % If offset empty, set to 0. Clarify what is offset
            if isempty(obj.ch_offset)
                obj.ch_offset = 0;
            end
            
            obj.Fs = s_in.Rate;
            % Same volt range across all channels when initiated before subjects defined
            volt_text = s_in.Channels(1).Range;
            obj.volt_range = [get(volt_text, 'Min'), get(volt_text, 'Max')];
        end
        
        function obj = FileName(obj)
            obj.dir_save = fullfile(pwd, sprintf('Data_%s', obj.room));
            if ~exist(obj.dir_save, 'dir')
                mkdir(obj.dir_save);
            end
            obj.filename = fullfile(obj.dir_save, sprintf('%s-%s', obj.name, char(datetime("now", 'Format', 'yyyyMMdd-HHmmss'))));
        end
        
        function obj = FilePrepPhys(obj)
            % Prep Binary Files for saving
            obj.fid = fopen([obj.filename '.bin'], 'w'); % Can get the following Error if not running Matlab as administrator: Invalid file identifier.  Use fopen to generate a valid file identifier. http://stackoverflow.com/questions/10606373/what-causes-an-invalid-file-identifier-in-matlab

            % Iniitialize bytes to 0
            obj.num_ts_written = 0;
            obj.num_ts_cutoff = obj.Fs * seconds(hours(1));
            % obj.num_ts_cutoff = obj.Fs * seconds(seconds(10)); % Rapid change for debugging

            % File Version Number: Version 3 as of 2018/06/28: Added counter data. Version 4 = save numbers as single precision rather than double?
            fwrite(obj.fid, 3, 'int');
            % File format: Rate as int, then num chans as int
            fwrite(obj.fid, obj.Fs, 'int');
            % fwrite(obj.fid, obj.volt_range(end),'double'); % specified in text file? different for every channel potentially?
            fwrite(obj.fid, obj.num_analog,'int');
            fwrite(obj.fid, obj.num_counter,'int');
            fwrite(obj.fid, obj.num_digital,'int');
            
            % Software synchronization of NI data and camera frames: .OpboxCamSymch = .ocs
            if numel(obj.cam_id) && numel(obj.cam)
                obj.fid_camsynch = fopen([obj.filename '.ocs'], 'w'); % Can get the following Error if not running Matlab as administrator: Invalid file identifier.  Use fopen to generate a valid file identifier. http://stackoverflow.com/questions/10606373/what-causes-an-invalid-file-identifier-in-matlab
                fwrite(obj.fid_camsynch, 1, 'int'); % File Version Number: Version 1 as of 2020/08/12
                % File is just a paired list of numbers: NI timestamps acquired and Camera frames acquired, collected each time data from NI is collected
            end
        end

        function obj = FileClose(obj)
            if obj.fid ~= -1
                fclose(obj.fid); % Close main data file, does not reset fid to -1
                obj.fid = -1;
            end
            % [file_path,file_name,file_ext] = fileparts(obj.filename);
            [~, file_name] = fileparts(obj.filename);
            fprintf('Closed OpBox files %s (%.1f sec phys data)\n', file_name, obj.num_ts_written/obj.Fs);
            % Close OpboxCameraSynch file if there is one
            if ~isempty(obj.cam_id) && ~isempty(obj.cam) && (obj.fid_camsynch ~= -1)
                fclose(obj.fid_camsynch);
                obj.fid_camsynch = -1;
            end
        end
        
    end
end
