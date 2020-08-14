% function OpBox_Offset(offset)
% OpBox_Offset: Adjusts offset between voltage traces in time domain
% Currently assumes all axes for all subjects have same limits
% 2016/05/09

function OpBox_Offset(offset)

global subjects  % OpBox Global variable

if nargin < 1
    offset = 0;
end

for i_subj = 1:numel(subjects)
    subjects(i_subj).ch_offset = offset;
    x_lim = get(subjects(i_subj).axis_time, 'XLim');
    num_ch = subjects(i_subj).num_analog + subjects(i_subj).num_digital;
    volt_range = subjects(i_subj).volt_range;
    volt_range = [volt_range(1), abs(volt_range(1)) + offset * (num_ch-1)];
    axis(subjects(i_subj).axis_time, [x_lim(:)', volt_range]);
end
