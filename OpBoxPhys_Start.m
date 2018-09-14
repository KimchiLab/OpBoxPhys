function lh = OpBoxPhys_Start(s_in)

global subjects; % defined globally so that listener handles can access updated info on the fly

if isempty(s_in)
    fprintf('No NI devices initialized. Please run/check OpBox_Setup and/or OpBoxPhys_DaqSetup\n');
    lh = [];
elseif s_in.IsRunning
    fprintf('Recording ongoing... Please stop first with OpBox_Stop.\n');
    lh = [];
else
    % If subjects are available, then see if files are already open
    % If files are not open (fid == -1) then prep new files for them,
    % but should always be prepped in OpBox_Subject
    for i_subj = 1:numel(subjects)
       if subjects(i_subj).fid == -1
            subjects(i_subj) = OpBoxPhys_FilePrep(subjects(i_subj));
       end
    end
    
    % Set up listener handles: Access subjects as global var
    lh.log = addlistener(s_in, 'DataAvailable', @(src, event)OpBoxPhys_LogData(src, event));
    lh.draw = addlistener(s_in, 'DataAvailable', @(src, event)OpBoxPhys_DrawData(src, event));
    
    % If you try to set up listener handle with subjects as variable to pass in,
    % Then it only passes in subjects as they are at the time this is initialized
    % i.e., it does not does not track updates to subjects variable
    % Can subclass the event Data class?? https://www.mathworks.com/help/matlab/matlab_oop/learning-to-use-events-and-listeners.html

    % Start recording
    s_in.startBackground();
    fprintf('Started new recording for %d sec\n', s_in.DurationInSeconds);
    
end
