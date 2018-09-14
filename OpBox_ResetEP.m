function OpBox_ResetEP

global subjects

for i_subj = numel(subjects)
    set(subjects(i_subj).h_n_peri, 'String', '0');
end
