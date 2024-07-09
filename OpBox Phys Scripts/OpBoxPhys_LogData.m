function OpBoxPhys_LogData(src, event)
% Adapted from Matlab Log Data example 
% http://www.mathworks.com/help/daq/examples/log-analog-input-data-to-a-file-using-ni-devices.html
% Log time stamp and data values to data (write to data stream). 
% To write data "sequentially", transpose the matrix.
%
% Changes from original example code
% 1. Stream from multiple subjects/files "simultaneously" (loop over subjects)
% 2. Later mod (2015/04/09): Some flexibility in fid checking 
% allows for Start/Stop saves at different times for different subjects
% 3. Asynchronous subjects
% Main issue is that all channels needed to be started/stopped simultaneously, 
% even though subjects are started asynchronously 
% and files are sometimes unnecessarily big or subjects are added later
% FIDs can not be modified on the fly except by using a global variable
% Therefore will only check/process data from active subjects
% 
% 2018/06/28: Added support for counter/rotary encoder channels
% File version now marked as version 3 in PhysFilePrep
% Consider changing to single rather than double since wasted precision?
% But lost some time precision when converted prior timestamps from double to single
% Timestamps are helpful with multiple subjects--aligning across single NI session
%
% 2020/08/05: Added software "synchronization" for camera and NI data
% Save timestamp of data chunks acquired with corresponding # frames acquired

global subjects

for i_subj = 1:numel(subjects)
    % pull out data assigned to just this subject
    data = [event.TimeStamps, event.Data(:, subjects(i_subj).idx_chan)]';
    % check whether fid for this subject is valid yet?
    if subjects(i_subj).flag_file_ready
        % then write to the specified file stream
        count = fwrite(subjects(i_subj).fid, data, 'double');
        subjects(i_subj).num_ts_written = subjects(i_subj).num_ts_written + count/subjects(i_subj).num_ch; % Really count of numbers written, not bytes, across all channels
        
        % If there is camera data, save the numbers of data timestamps and camera frames
        if ~isempty(subjects(i_subj).cam_id) && ~isempty(subjects(i_subj).cam) && (subjects(i_subj).fid_camsynch > -1)
            % Timestamp X corresponds to Camera Frame Y (pairs of doubles)
            fwrite(subjects(i_subj).fid_camsynch, [event.TimeStamps(end), subjects(i_subj).cam.FramesAcquired], 'double');
        end
            
        % if a data file size exceeds ts cutoff (e.g. ~1GB), flushdata and start recording new files
        if subjects(i_subj).num_ts_written >= subjects(i_subj).num_ts_cutoff
            lh.draw.Enabled = false; % Turn off graphing listener handle during update
            lh.log.Enabled = false;

            % Generate new/next filename
            subjects(i_subj) = subjects(i_subj).FileName();
            % fprintf('%d %s\n', subjects(i_subj).num_ts_written, subjects(i_subj).filename);

            % Close files phys files
            subjects(i_subj) = subjects(i_subj).FileClose();

            % Close & Reopen cam files
            if numel(subjects(i_subj).cam_id)
            %    stop(subjects(i_subj).cam);
            %    flushdata(subjects(i_subj).cam);
                % subjects(i_subj).cam.DiskLogger
                % close(subjects(i_subj).cam.DiskLogger); % File gets shrunk/deleted if closed before video stopped
                % Camera related file restart
            %    vid_writer = VideoWriter(subjects(i_subj).filename, 'MPEG-4'); % Point video writer to new file
            %    set(subjects(i_subj).cam, 'DiskLogger', vid_writer); % Point DiskLogger to new video writer
            %    start(subjects(i_subj).cam);
            end

            if min(src.NumScansAvailablePerChannel) <= 0
                % fprintf('MinNumScans = %d\n', min(src.NumScansAvailablePerChannel));
                fprintf('%d ', src.NumScansAvailablePerChannel);
                fprintf('\n');
                fprintf('%d ', find(src.NumScansAvailablePerChannel <= 0));
                fprintf('\n');
            end

            % Physiology file starts writing as soon as there is an available fid, set up after camera
            subjects(i_subj) = subjects(i_subj).FilePrepPhys();

            lh.draw.Enabled = true; % Turn on graphing listener handle after update
            lh.log.Enabled = true;
        end
        
    end
end

