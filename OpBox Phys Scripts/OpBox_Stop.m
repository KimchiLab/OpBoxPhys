% function OpBox_Stop(s_in, lh);

% if ~exist('s_in', 'var')
%     fprintf('NI device not initialized... Please setup first.\n');
% elseif ~s_in.IsRunning
% if ~s_in.IsRunning
if ~s_in.Running
    fprintf('Recording not ongoing... Please start first.\n');
else
    % Stop collecting data, delete listener handles, close files
    % lh.draw.Enabled = false;
    % lh.log.Enabled = false;
    
    % Stop recordings, files, and cameras
    for i_subj = 1:numel(subjects)
        subjects(i_subj) = subjects(i_subj).FileClose();
        
        if numel(subjects(i_subj).cam_str) && numel(subjects(i_subj).cam)
            try
                stop(subjects(i_subj).cam);
                close(get(subjects(i_subj).cam, 'DiskLogger'));
            catch
                fprintf('Could not stop camera for subject %d, likely already stopped\n', i_subj);
            end
            delete(subjects(i_subj).cam);
        end

    end
    
    s_in.stop;
    fprintf('Stopped recording\n\n');
end
clear i_*
