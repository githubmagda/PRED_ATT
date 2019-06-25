%% EYELINK COMMANDS START
function[p] = EL_setup(p)

    %% STEP 2
    % get defaults (a LOT of settings)
    p.el = EyelinkInitDefaults(p.scr.window);  
    
    % initialize the eyetracker (check if dummyMode)
%     if p.dummyMode == 0
%         p.status = Eyelink('Initialize', 'PsychEyelinkDispatchCallback'); % Returns: 0 if OK, -1 if error
%     else
%         p.status = Eyelink('InitializeDummy', 'PsychEyelinkDispatchCallback');    
%     end
    
    %% 'STEP 3' first part   
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(p.dummyMode, 1) % [result dummy]=EyelinkInit([dummy=0][enableCallbacks=1]); Returns result=1 when succesful, 0 otherwise; Returns dummy=1 when initialized in dummy mode, 0 otherwise.
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [v vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    p.eyelinkVersion = vs;
    
    %% FILE SETTINGs FOR MAIN EXPERIMENT
    p.createFile = 1; %% means DO create a file... sensibly
    p.edfFileNameList = {}; % initialize cell array to save .edf file names by series
   
    p.statusFile = 1;                   % file not yet open
    p.dummyMode = 0;
%     %% UPDATE defaults CHECK - HOW TO CHANGE LOCATION OF CALIBRATION DOTS?
%     p.el.backgroundcolour = p.scr.background;
%     EyelinkUpdateDefaults(p.el);
%     
    %% make sure that we get gaze data from the Eyelink
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA'); % CHECK
%     Eyelink('command', 'link_event_data = GAZE, GAZERES, HREF, AREA, VELOCITY');
%     Eyelink('command', 'link_event_filter = LEFT , RIGHT, FIXATION, BLINK, SACCADE, BUTTON');  
%     screenBlank(p)
end  