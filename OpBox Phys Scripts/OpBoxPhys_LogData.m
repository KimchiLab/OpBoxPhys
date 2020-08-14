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
    % have to pull out data for just this subject for this file
    data = [event.TimeStamps, event.Data(:, subjects(i_subj).idx_chan)]';
    % check whether fid for this subject is valid yet?
    if subjects(i_subj).fid ~= -1
        % then write to the specified file stream
        count = fwrite(subjects(i_subj).fid, data, 'double');
        subjects(i_subj).bytes_written = subjects(i_subj).bytes_written + count;
        
        % If there is camera data, save the numbers of data timestamps and camera frames
        if ~isempty(subjects(i_subj).cam_id) && ~isempty(subjects(i_subj).cam) && (subjects(i_subj).fid_camsynch > -1)
            % Timestamp X corresponds to Camera Frame Y (pairs of doubles)
            fwrite(subjects(i_subj).fid_camsynch, [event.TimeStamps(end), subjects(i_subj).cam.FramesAcquired], 'double');
        end
            
        % if a data file size exceeds bytes cutoff (e.g. ~1GB), flushdata and start recording new files
        if subjects(i_subj).bytes_written > subjects(i_subj).bytes_cutoff
            % fprintf('New file at %d\n', subjects(i_subj).bytes_written);
            subjects(i_subj) = subjects(i_subj).FileClose();
            subjects(i_subj) = subjects(i_subj).FileName();
            subjects(i_subj) = subjects(i_subj).FilePrepPhys();
            
            % Camera related file restart
            if ~isempty(subjects(i_subj).cam_id) && ~isempty(subjects(i_subj).cam)
                stop(subjects(i_subj).cam);
                close(get(subjects(i_subj).cam, 'DiskLogger')); % File gets shrunk/deleted if closed before video stopped
                flushdata(subjects(i_subj).cam);
                delete(subjects(i_subj).cam);
                
                % Restart camera
                subjects(i_subj).cam = videoinput('winvideo', subjects(i_subj).cam_id, 'YUY2_320x240');  % Initialize camera & resolution
                set(subjects(i_subj).cam, 'FramesPerTrigger', inf);
                set(subjects(i_subj).cam, 'FramesAcquiredFcnCount', 30);  % Try to display roughly 1/sec. Can't guarantee frame rate?

                % Setup Logger
                set(subjects(i_subj).cam,'LoggingMode','disk');
                vid_writer = VideoWriter([subjects(i_subj).dir_save subjects(i_subj).filename], 'MPEG-4');
                % May have to match cam ID if not in order? But have to assume so?
                set(subjects(i_subj).cam, 'DiskLogger', vid_writer);
                start(subjects(i_subj).cam);
            end
        end
    end
end

