% function OpBox_SubjectsRemove(lh)
% 
% global subjects; % Global for listener handle purposes

if isempty(subjects)
    fprintf('No subjects left to remove.\n');
elseif numel(subjects) == 1
    subj_names = {subjects.name};
else
    subj_names = OpBox_SubjectsNames(subjects);
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
        subjects = OpBox_Graphs(subjects);
        lh.draw.Enabled = true;
    end
end

clearvars -except subjects s_in lh cams room; % Clear unnecessary variables, only keep those specified here

%     subj_names = {subjects.name};
%     subj_group = {subjects.group};
%     fprintf('Subjects: ');
%     for i_subj = 1:numel(subj_names)
%         fprintf('%d: %s   ', i_subj, subj_names{i_subj});
%     end
%     fprintf('\n');
%     str = input('Select subject to remove: (A for All) ', 's');
%     if lower(str) == 'a'
%         % Are you sure?
%         lh(2).Enabled = false;
%         for i_subj = 1:numel(subjects)
%             subjects(i_subj).FileClose();
%         end
%         subjects = [];
%         fprintf('All subjects stopped.\n');
%     else
%         idx = str2double(str);
%         if ~isnan(idx) && idx > 0 && idx <= numel(subjects)
%             lh(2).Enabled = false;
%             subjects(idx) = subjects(idx).FileClose();
%             subjects = subjects([1:idx-1, idx+1:end]);
%             if numel(subjects) > 0
%                 subjects = OpBox_GraphsFlex(subjects);
%                 lh(2).Enabled = true;
%             end
%         end
%     end


%     vid_writer = get(vid,'DiskLogger');
%     close(vid_writer);
%     
% %     delete(vid);
% %     clear vid;
