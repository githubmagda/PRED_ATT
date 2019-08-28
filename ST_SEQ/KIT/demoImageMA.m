function[] = demoImageMA()

% Clear the workspace and the screen
sca;
close all;
clearvars;

% VARIABLES
imageDur            = 0.01;
fixDur              = 0.01;
fixCrossLength      = 12;

% use eyelink?
useEyelink          = 0;
dummymode           = 0;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max( Screen('Screens'));

% Define black, white and grey
white = WhiteIndex( screenNumber);
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
imageDim = 100;

% fix cross
fixCrossColor       = [0, 0, 0, 0];
fixCrossLineWidth   = 4;
fixCrossArmLength   = 12;
xCoords             = [ width/2-fixCrossArmLength, width/2+fixCrossArmLength , width/2, width/2];
yCoords             = [ width/2, width/2, width/2-fixCrossArmLength, width/2+fixCrossArmLength]; %[0, 0, 0, 0];
allCoords           = [xCoords; yCoords];

% images (example set)
dog         = imread( 'LOAD/dog1.jpg', 'jpg');
dog         = imresize( dog, 0.5);
dog         = imresize( dog, [ imageDim, imageDim]); 
dogTex      = Screen('MakeTexture', window, dog);
cat         = imread( 'LOAD/cat1.jpg', 'jpg');

cat         = imresize( cat, 0.5);
cat         = imresize( cat, [ imageDim, imageDim]);
catTex      = Screen('MakeTexture', window, cat);

% where will image appear (selected in trial)
offsetWidthSet  = [ -150, +150 ];
% which image will be shown
texSet          = [ dogTex, catTex];

% EYELINK
if useEyelink
    ete.fixPoliceX          = width/2;
    eye.fixPoliceY          = height/2;
    eye.fixPoliceRadius     = 30;
    eye.maxPoliceErrorTime  = .2;           % allow for blinks out of monitored area
    eye.policeEye           = 2;            % 1 = left, 2 = right;
    eye.fixPoliceOffset     = 100;
    eye.gazeRightBorder        = eye.fixPoliceX + eye.fixPoliceOffset;
    eye.gazeLeftBorder        = eye.fixPoliceX - eye.fixPoliceOffset;
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

for i = 1:20

    % trial options
    select              = randi(2,1);       
    thisTex             = texSet(select);           % random image choice
    select              = randi(2,1);      
    thisWidthOffset     = offsetWidthSet(select);   % randomly place on left or right 
    dstRect             = OffsetRect(windowRect, thisWidthOffset, 0); 
    
    startIm(i) = GetSecs; % time test
    Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor); 
    Screen('DrawTexture', window, thisTex, [], CenterRectOnPoint( [0, 0, imageDim, imageDim], (centerX +thisWidthOffset), centerY));
    endIm(i) = GetSecs;
    durIm(i) = endIm(i) -startIm(i);
    % Flip to the screen
    [ vblImage] = Screen('Flip', window);
    
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
    [ vblFix] = Screen('Flip', window);
    
    if useEyelink
        % police eyes
        leftRight = 1;         % monitor for left/right saccade
        monitorFixationMA(p, fixDur, leftRight);
    else
        WaitSecs( fixDur);
    end
    
end
durIm(i);
catch
    psychrethrow(psychlasterror);
    cleanup(useEyelink);    
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

