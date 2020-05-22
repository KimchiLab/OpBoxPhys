% function OpBox_Stop(s_in, lh);

% if ~exist('s_in', 'var')
%     fprintf('NI device not initialized... Please setup first.\n');
% elseif ~s_in.IsRunning
if ~s_in.IsRunning
    fprintf('Recording not ongoing... Please start first.\n');
else
    % Stop collecting data, delete listener handles, close files
    lh.draw.Enabled = false;
    lh.log.Enabled = false;
    
    % Stop cameras
    for i_subj = 1:numel(subjects)
        subjects(i_subj) = subjects(i_subj).FileClose();
        
        if ~isempty(subjects(i_subj).cam_id) && subjects(i_subj).cam_id > 0 && ~isempty(subjects(i_subj).cam)
            stop(subjects(i_subj).cam);
            close(get(subjects(i_subj).cam, 'DiskLogger'));
            delete(subjects(i_subj).cam);
        end

%         fclose(subjects(i_subj).fid);
%         subjects(i_subj).fid = -1;
    end
    
%     for i_lh = 1:numel(lh);
%         delete(lh(i_lh));
%     end
    delete(lh.draw);
    delete(lh.log);
    s_in.stop;
    fprintf('Stopped recording\n\n');
end
clear i_*
