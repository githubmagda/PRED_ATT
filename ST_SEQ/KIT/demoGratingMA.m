function[] = demoGratingMA()

% Clear the workspace and the screen
sca;
close all;
clearvars;

% VARIABLES
imageDur            = 0.5;
fixDur              = 1.0;
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

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 600 600]);
ifi = Screen('GetFlipInterval', window);

% Dimension of the region where will draw the grating in pixels
winWidth   = windowRect(3); 
winHeight  = windowRect(4);

% Enable alpha-blending, set it to a blend equation useable for linear
% additive superposition. This allows to linearly
% superimpose gabor patches in the mathematically correct manner, should
% they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
% the 'DrawTextures' can be used to modulate the intensity of each pixel of
% the drawn patch before it is superimposed to the framebuffer image, ie.,
% it allows to specify a global per-patch contrast value:
%Screen('BlendFunction', window, GL_ONE, GL_ONE);
Screen('BlendFunction', window, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
%Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%-------------------- 
% fix cross
%--------------------
fixCrossColor       = [0, 0, 0, 1];
fixCrossLineWidth   = 4;
fixCrossArmLength   = 12;
xCoords             = [ winWidth/2-fixCrossArmLength, winWidth/2+fixCrossArmLength , winWidth/2, winWidth/2];
yCoords             = [ winWidth/2, winWidth/2, winWidth/2-fixCrossArmLength, winWidth/2+fixCrossArmLength]; %[0, 0, 0, 0];
allCoords           = [xCoords; yCoords];

%--------------------
% Grating information
%--------------------

size = 10;
% Size of support in pixels, derived from si:
tw = 2*size+1;
th = 2*size+1;
    
% Obvious Parameters
backgroundColorOffset       = [ 0 0 0 0];
radius                      = 50;                        % in pixels; creates circular mask 
contrastPreMultiplicator    = 1.0;

%%% GRATING 
% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles                   = 60;
freq                        = numCycles / winWidth;           
phase                       = 70;

[gratingtex, gratingRect]   = CreateProceduralSineGrating(window, winWidth, winHeight, backgroundColorOffset, radius, contrastPreMultiplicator);

angleSet           = [20, 110];         % Inital angle of grating
contrast            = 1;

%% END GRATING PREP

% where will image appear (selected in trial)
offsetWidthSet = [ -size *10, size *10 ];
offsetHeightSet = [ -size *10, size *10 ];

% EYELINK
if useEyelink
    eye.fixPoliceX          = winWidth/2;
    eye.fixPoliceY          = winHeight/2;
    eye.fixPoliceRadius     = 30;
    eye.maxPoliceErrorTime  = .2;           % allow for blinks out of monitored area
    eye.policeEye           = 2;            % 1 = left, 2 = right;
    eye.fixPoliceOffset     = 100;
    eye.gazeRightBorder     = eye.fixPoliceX + eye.fixPoliceOffset;
    eye.gazeLeftBorder      = eye.fixPoliceX - eye.fixPoliceOffset;
    
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
    
trialStart = GetSecs; % start timer for first trial
vbl = GetSecs;

for i = 1:5

    % trial options
    select              = randi( 2,1);
    thisAngle           = angleSet( select);
    
    select              = randi(2,1);
    thisWidthOffset     = offsetWidthSet(select);   % randomly place on left or right 
    
%     dstRect(:,1)             = OffsetRect(windowRect, offsetWidthSet(1), offsetHeightSet(1)); 
%     dstRect(:,2)             = OffsetRect(windowRect, offsetWidthSet, offsetHeightSet(2)); 
    dstRects             = OffsetRect(windowRect, offsetWidthSet', offsetHeightSet')'; 


    % DRAW cross
    Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor); 

    timeStart(i) = GetSecs;
    
    % DRAW the grating with new angle to dstRect
    Screen('DrawTextures', window, gratingtex, [], dstRects, angleSet, [], [], ...
        [], [], [], repmat([phase+180, freq, contrast, 0], 2, 1)');

    Screen('DrawingFinished', window);
    
    % Flip to the screen

    [ vbl] = Screen('Flip', window, 0);
    
    timeEnd(i) = GetSecs; 
    timeDur(i) = timeEnd(i) -timeStart(i);

    if useEyelink
    % police eyes
        leftRight = 0; % monitor for central fixation, not saccade
        monitorFixationMA( p, imageDur, leftRight);
    else
        WaitSecs( imageDur -(0.9 *ifi));
    end
    
    % just fixation cross
    Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor);  
    
    % Flip to the screen
    [ vblFix] = Screen('Flip', window, 0);
    
    if useEyelink
        % police eyes
        leftRight = 1;         % monitor for left/right saccade
        monitorFixationMA( p, fixDur, leftRight);
    else
        WaitSecs( fixDur - (0.9 *ifi));
    end    
end
timeDur;

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