function h = PlotSpecGram(t, f, p, ax)

if ~exist('ax', 'var') || isempty(ax)
    ax = gca;
end

if ~isMATLABReleaseOlderThan("R2023b")
    h = imagesc(ax, t, f, p); % Doesn't support date times in older versions, but faster
else
    if isdatetime(t)
        %     https://www.mathworks.com/matlabcentral/answers/1634620-imagesc-or-equivalent-with-datetime-as-x-axis?s_tid=srchtitle#answer_1151350
        % This command will configure the axes for use with datetime
        % Then delete the line created by the plot command.
        delete(plot(ax, t(1), p(1)));
        % Now hold is required, because otherwise the axes will be reset by the image command.
        hold(ax, 'on');
        % Now you can convert from datetime to numerics using ruler2num
        x = ruler2num(t, ax.XAxis);
        % Now pass the double data to imagesc.
        h = imagesc(ax, x,f,p);
        % Finally, because hold was on, you need to manually set the limits (which
        % is normally done for you by imagesc) and turn on the box. I ommited
        % flipping the YDir becuse you seem to want that set to 'normal' anyway.
        axis(ax, 'tight');
        box(ax, 'on');
        hold(ax, 'off');
    else
        h = imagesc(ax, t, f, p); % Doesn't support date times, but faster
    %     h = surf(t, f, zeros(size(p)),p, 'EdgeColor', 'none'); % Likely slow, but necessary for nonuniform/discontinuous data?
    %     view([0 90]); % Check this words
    %     h = surf(t, f, p, 'EdgeColor','none'); % Very slow?
    end
end

% h = surf(t, f, p, 'EdgeColor','none'); % Very slow: e.g. 0.45 sec imagesc, 6.6 sec surf
% axis xy; 
% view(0,90);

set(ax, 'YDir', 'normal');
ylabel(ax, 'Freq (Hz)');
xlabel(ax, 'Time (sec)');
% ColormapParula;
