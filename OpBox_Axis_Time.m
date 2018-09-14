% function OpBox_Axis_Time(x_lim, y_lim)
% OpBox_Axis_Time: Adjusts axes for time plots within global subjects variable
% If either x_lim or y_lim are empty or NaN, will leave that axis as is
% Currently assumes all axes for all subjects have same limits
% Will not be able to adjust by channel given current plot setup
% 2016/04/07

function OpBox_Axis_Time(x_lim, y_lim)

global subjects  % OpBox Global variable

if nargin < 2
    fprintf('Specify axis limit arguments as ([x1 x2], [y1 y2])\n');
    return
end

% Some quick error checking
if isempty(x_lim) || sum(isnan(x_lim))
%     x_lim = [-inf inf];
    x_lim = get(subjects(1).axis_time, 'XLim');
end
if isempty(y_lim) || sum(isnan(y_lim))
%     y_lim = [-inf inf];
    y_lim = get(subjects(1).axis_time, 'YLim');
end

for i_subj = 1:numel(subjects)
    axis(subjects(i_subj).axis_time, [sort(x_lim(:)'), sort(y_lim(:)')]);
end
