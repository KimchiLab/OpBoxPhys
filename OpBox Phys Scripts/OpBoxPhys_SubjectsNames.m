function subj_names = OpBoxPhys_SubjectsNames(subj_info)

if isfield(subj_info, 'group')
    groups = {subj_info.group};
else
	groups = repmat({''}, size(subj_info));  % Groups not a field for any subjects, create blank groups
end
name_groups = unique(groups);

fprintf('\nPossible subjects for room %s:\n', subj_info(1).room);
if sum(~strcmpi(groups, ''))
    fprintf('Groups:\n');
    for i_group = 1:numel(name_groups)
        if ~isempty(name_groups{i_group})
            fprintf('%s: ', name_groups{i_group});
            fprintf('%s, ', subj_info(strcmpi(groups, name_groups{i_group})).name);
            fprintf('\n');
        end
    end
end
if sum(strcmpi(groups, ''))
    fprintf('Ungrouped: ');
    fprintf('%s ', subj_info(strcmpi(groups, '')).name);
    fprintf('\n');
end

% Get group or subject names
subj_str = input('\nEnter group name, subject name, or boxes (sep by spaces): ', 's');
subj_str(subj_str == ',') = ' ';
subj_list = regexp(subj_str, '\s+', 'split');
subj_names = {};

for i_subj = 1:numel(subj_list)
    if ~isempty(subj_list{i_subj})
        if sum(strcmpi(subj_list{i_subj}, name_groups))
            subj_names = [subj_names subj_info(strcmpi(groups, subj_list{i_subj})).name];
        elseif sum(strcmpi(subj_list{i_subj}, {subj_info.name}))
            subj_names = [subj_names subj_list{i_subj}];
        elseif strcmpi(subj_list{i_subj}, 'all')
            fprintf('Processing all subjects.\n');
            subj_names = {subj_info.name};
            break;
        else
            % Consider adding and allowing user to specify box
%             fprintf('Subject %s not recognized, would you like to add for current session?adding for current recording to default box.\n', subj_list{i_subj});
            fprintf('Subject %s not recognized, will try to add.\n', subj_list{i_subj});
            subj_names = [subj_names subj_list{i_subj}];
        end
    end
end

% Only keep unique names
[val, idx] = unique(lower(subj_names));
subj_names = subj_names(idx);

