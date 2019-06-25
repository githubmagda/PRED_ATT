function[] = testEyetracker()

% basic settings
PsychDefaultSetup(2);
InitializePsychSound();
KbName('UnifyKeyNames');
dummymode=0;

% WINDOW DIMENSIONS
testDimensionX = 500; % in pixels
testDimensionY = 500;
testDimensions = [0, 0, testDimensionX, testDimensionY];  %% xTest xTest*.7379 use actual screen ratio from preferences set in prefFunction below

% Get the list of screens and choose the one with the highest screen number.
% Screen 0 is, by definition, the display with the menu bar. Often when
% two monitors are connected the one without the menu bar is used as
% the stimulus display.  Chosing the display with the highest display number is
% a best guess about where you want the stimulus displayed.
screenNumber=max(Screen('Screens'));

% Open a fullscreen window.
%%%[w, wRect]=Screen('OpenWindow',screenNumber);

% Open a TEST window.
[w, wRect]=Screen('OpenWindow',screenNumber, 0.5, testDimensions);

% Set background color to gray.
backgroundcolor=GrayIndex(w); % returns as default the mean gray value of screen

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(w);

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end

% Set background color to 'backgroundcolor' and do initial flip to show
% blank screen:
Screen('FillRect', w, backgroundcolor);
Screen('Flip', w);

% make sure that we get gaze data from the Eyelink
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
Eyelink('openfile', 'demo.edf');

% STEP 4
% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% do a final check of calibration using driftcorrection
EyelinkDoDriftCorrection(el);

WaitSecs(0.1);
Eyelink('StartRecording');

eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

% stop eyelinkc
Eyelink('StopRecording');

end
