% Setup listener handles for recordings and display
% This is usually run from the room-specific script
% After data acquisition device setup: OpBoxPhys_Setup
% Usually before subjects have been added: OpBox_Add

function OpBoxPhys_Start(s_in)

global subjects; % defined globally so that listener handles can access updated info on the fly

if isempty(s_in)
    fprintf('No NI devices initialized to start listener handles.\n');
elseif s_in.Running
    fprintf('Recording ongoing... Please stop first.\n');
else
    % Set up listener handles: Access subjects as global var
    s_in.ScansAvailableFcn = @(src, event) OpBoxPhys_LogData(src, event);
    
    % If try to set up listener handle with subjects as variable to pass in,
    % Then only passes in subjects as they are at the time this is initialized
    % Does not track updates to subjects
    % Can subclass the event Data class?? https://www.mathworks.com/help/matlab/matlab_oop/learning-to-use-events-and-listeners.html

    % Start recording
    start(s_in, "Continuous");
    fprintf('Started streaming\n');
end
