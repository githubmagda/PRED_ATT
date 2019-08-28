function[] = demoGaussianMA()

% Clear the workspace and the screen
sca;
close all;
clearvars;

% use eyelink?
useEyelink          = 0;
dummymode           = 0;

% VARIABLES
imageDur            = 1.0;
fixDur              = 0.5;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

try
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 500 500], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

%Screen('BlendFunction', window, GL_ONE, GL_ONE);
%Screen('BlendFunction', window, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Dimension of the region where will draw the gaussian in pixels
width       = windowRect(3); 
centerX     = width/2;
height      = windowRect(4); 
centerY     = height/2;

% fix cross
fixCrossColor       = [0.5, 0.5, 0.5];
fixCrossLineWidth   = 4;
fixCrossArmLength   = 15;
xCoords             = [ centerX-fixCrossArmLength, centerX+fixCrossArmLength , centerX, centerX];
yCoords             = [ centerY, centerY, centerY-fixCrossArmLength, centerY+fixCrossArmLength]; %[0, 0, 0, 0];
allCoords           = [xCoords; yCoords];

%--------------------
% GABOR information
%--------------------

% Define prototypical gabor patch of 65 x 65 pixels default size: si is
% half the wanted size. Later on, the 'DrawTextures' command will simply
% scale this patch up and down to draw individual patches of the different
% wanted sizes:
si = 32;

% Size of support in pixels, derived from si:
tw = 2*si+1;
th = 2*si+1;


backgroundColorOffset = [.5,.5,.5, 0];

[gaussTex, gaussTexRect] = CreateProceduralGaussBlob(window , tw * 2, th * 2, backgroundColorOffset, 0, 1);
fixScale = 1;
dotScale = .25;
dstRectFix = OffsetRect(gaussTexRect*fixScale, centerX-tw*fixScale, centerY-th*fixScale);
dstRectDot = OffsetRect(gaussTexRect*dotScale, centerX-tw*dotScale, centerY-th*dotScale);

% Spatial constant of the exponential "hull"
sc = 15;          % sigma; regulates size of gaussian blur;
% Contrast (brightness):
contrast = 25.0;     % 
% Aspect ratio i.e.width vs. height:
aspectratio = 1;

%% END GAUSIAN PREP

% where will image appear (selected in trial)
offsetWidthSet = [ -centerX/2, centerX/2 ];

% EYELINK
if useEyelink
    eye.fixPoliceX          = width/2;
    eye.fixPoliceY          = height/2;
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
waitTime = GetSecs +imageDur -0.015;

for i = 1:3
    
    % trial options
    select              = randi(2,1);
    thisWidthOffset     = offsetWidthSet(select);   % randomly place on left or right 
    
    % Draw the GAUSSIAN 
    %Screen('DrawTexture', window, gaussFixTex, [], [], [], [], [], [], [], kPsychDontDoRotation, [contrast, sc, aspectratio, 1]);
    Screen('DrawTextures', window, gaussTex, gaussTexRect, [dstRectFix;dstRectDot]', [], [], [], [], [], kPsychDontDoRotation, repmat([contrast, sc, aspectratio, 1],2,1)');

    Screen('DrawLines', window, allCoords, fixCrossLineWidth, [.5 .5 .5  1]); 
    Screen('DrawTexture', window, gaussTex, gaussTexRect, dstRectDot, [], [], [], [], [], kPsychDontDoRotation, [contrast, sc, aspectratio, 1]);

    % Flip to the screen
    [ vbl] = Screen('Flip', window, waitTime);
    waitTime = vbl +imageDur - 0.015;
    GetSecs
    
    if useEyelink
    % police eyes
        leftRight = 0; % monitor for central fixation, not saccade
        monitorFixationMA( p, imageDur, leftRight);
    else
        WaitSecs( imageDur);
    end
    
    % just fixation cross
    Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor);  
    
    % Flip to the screen
    [ vbl] = Screen('Flip', window, waitTime);
    waitTime = vbl +fixDur - 0.015;
    if useEyelink
        % police eyes
        leftRight = 1;         % monitor for left/right saccade
        monitorFixationMA(p, waitTime, leftRight);
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