% function OpBox_Stop(s_in, lh);

if ~exist('s_in', 'var')
    fprintf('NI device not initialized... Please setup first.\n');
elseif ~s_in.IsRunning
    fprintf('Recording not ongoing... Please start first.\n');
else
    % Stop collecting data, delete listener handles, close files
    s_in.stop;
    for i_subj = 1:numel(subjects)
        subjects(i_subj) = subjects(i_subj).FileClose();
        
        if ~isempty(subjects(i_subj).cam_id) && subjects(i_subj).cam_id > 0 && ~isempty(subjects(i_subj).cam)
            close(get(subjects(i_subj).cam, 'DiskLogger'));
            delete(subjects(i_subj).cam);
        end
    end
    
    delete(lh.draw);
    delete(lh.log);
    
    fprintf('Stopped recording\n\n');
end
clear i_*
