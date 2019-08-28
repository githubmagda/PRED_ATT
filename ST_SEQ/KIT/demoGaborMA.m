function[] = demoGaborMA()

% Clear the workspace and the screen
sca;
close all;
clearvars;

% VARIABLES
imageDur            = 0.5;
fixDur              = 0.5;
fixCrossLength      = 12;

% use eyelink?
useEyelink          = 0;
dummymode           = 0;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

try
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 600 600], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

%--------------------
% Grating information
%--------------------

% Dimension of the region where will draw the grating in pixels
width   = windowRect(3); 
centerX = width/2;
height  = windowRect(4); 
centerY = height/2;
% imageDim = 100;
% imageRect = [imageDim, imageDim];

% fix cross
fixCrossColor       = [0, 0, 0, 0];
fixCrossLineWidth   = 4;
fixCrossArmLength   = 12;
xCoords             = [ width/2-fixCrossArmLength, width/2+fixCrossArmLength , width/2, width/2];
yCoords             = [ width/2, width/2, width/2-fixCrossArmLength, width/2+fixCrossArmLength]; %[0, 0, 0, 0];
allCoords           = [xCoords; yCoords];

% IMAGES (alternative)
% dog         = imread( 'LOAD/dog1.jpg', 'jpg');
% dog         = imresize( dog, 0.5);
% dog         = imresize( dog, [ imageDim, imageDim]); 
% dogTex      = Screen('MakeTexture', window, dog);

%%% GABOR
%%%[gaborid, gaborrect] = CreateProceduralGabor(windowPtr, width, height [, nonSymmetric=0][, backgroundColorOffset =(0,0,0,0)][, disableNorm=0][, contrastPreMultiplicator=1][, validModulationRange=[-2,2]])
[gaborid, gaborrect] = CreateProceduralGabor(window, 50, 50, 1, [1 1 1 0]);

% where will IMAGE appear (selected in trial)
%offsetWidthSet = [ -imageDim, imageDim ];

% EYELINK
if useEyelink
    eye.fixPoliceX              = width/2;
    eye.fixPoliceY              = height/2;
    eye.fixPoliceRadius         = 30;
    eye.maxPoliceErrorTime      = .2;           % allow for blinks out of monitored area
    eye.policeEye               = 2;            % 1 = left, 2 = right;
    eye.fixPoliceOffset         = 100;
    eye.gazeRightBorder         = eye.fixPoliceX + eye.fixPoliceOffset;
    eye.gazeLeftBorder          = eye.fixPoliceX - eye.fixPoliceOffset;
    % name .edf file for this series
    edfFileName = strcat( 'Test.edf', num2str(1));
    
    % set Eyelink defaults
    el=EyelinkInitDefaults(window);

    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    % set specs for output in edf file
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'link_event_data = ');
    
    statusFile = Eyelink('Openfile', edfFileName);
    % send message to edf file
    Eyelink('Message', 'File_created: ', edfFileName);
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    % do a preseries check of calibration using drift correction
    EyelinkDoDriftCorrection(el);
    
    WaitSecs(0.5);
    Eyelink('StartRecording');
    WaitSecs(0.1);
end   

% %  options - set at trial level?
phase           = 0;
freq            = 0.1;
contrast        = 1;
aspectratio     = 1;
thisAngle       = 0; %angleSet( select);        % random selection of grating angle
sc              = 1;
    
trialStart = GetSecs; % start timer for first trial

for i = 1:4


% %     select              = randi(2,1);
% %     thisWidthOffset     = offsetWidthSet(select);   % randomly place on left or right 
dstRect = OffsetRect(gaborrect, width/2-gaborrect(3)/2, width/2-gaborrect(4)/2); 
% dstRect = OffsetRect(gaborrect, width/2-gaborrect(3)/2-1, width/2-gaborrect(4)/2-1); 
%   
% Draw the gabor with new angle to dstRect
%Screen('DrawTexture', win, gabortex, [], [], 90+tilt, [], [], [], [], kPsychDontDoRotation,...
%[phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('DrawTexture', window, gaborid, [], [], thisAngle, [], [], [], [], kPsychDontDoRotation,...
[phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor); 

    % Flip to the screen
    [ vblImage] = Screen('Flip', window);
    
    if useEyelink
    % police eyes
        leftRight = 0; % monitor for central fixation, not saccade
        sanjeevMonitorFixation( p, imageDur, leftRight);
    else
        WaitSecs( imageDur);
    end
    
    % just fixation cross
    Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor);  
    
    % Flip to the screen
    [ vblFix] = Screen('Flip', window);
    
    if useEyelink
        % police eyes
        leftRight = 1;         % monitor for left/right saccade
        sanjeevMonitorFixation(p, fixDur, leftRight);
    else
        WaitSecs( fixDur);
    end
    
end

catch
    psychrethrow( psychlasterror);
    cleanup( useEyelink);    
end

% Wait for a button press to exit
KbCheck;

% Clear screen
cleanup(useEyelink)
end


function[] = cleanup(useEyelink)
sca;
ShowCursor;
if useEyelink
    Eyelink('Closefile');
    Eyelink('StopRecording');
    Eyelink('Shutdown');
end
end


%Published with MATLAB® R2015b