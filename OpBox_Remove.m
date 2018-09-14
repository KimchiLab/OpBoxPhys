% function OpBox_SubjectsRemove(lh)
% 
% global subjects; % Global for listener handle purposes

if isempty(subjects)
    fprintf('No subjects left to remove.\n');
elseif numel(subjects) == 1
    subj_names = {subjects.name};
else
    subj_names = OpBoxPhys_SubjectsNames(subjects);
end

if ~isempty(subj_names)
    lh.draw.Enabled = false;
    for i_subj = 1:numel(subj_names)
        subj_mask = strcmpi(subj_names{i_subj}, {subjects.name});
        subjects(subj_mask) = subjects(subj_mask).FileClose();
        if ~isempty(subjects(subj_mask).cam_id) && subjects(subj_mask).cam_id > 0 && ~isempty(subjects(subj_mask).cam)
            stop(subjects(subj_mask).cam);
            close(get(subjects(subj_mask).cam, 'DiskLogger')); % File gets shrunk/deleted if closed before video stopped
            delete(subjects(subj_mask).cam);
        end
        subjects = subjects(~subj_mask);
    end
    if numel(subjects) > 0
        subjects = OpBoxPhys_Graphs(subjects);
        lh.draw.Enabled = true;
    end
end

clearvars -except subjects s_in lh cams room; % Clear unnecessary variables, only keep those specified here
