% Clear the workspace and the screen
sca;
close all;
clearvars;

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

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 600 600], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

%--------------------
% Grating information
%--------------------

% Dimension of the region where will draw the grating in pixels
width   = windowRect(3) ;
height  = windowRect(4);

% Obvious Parameters
backgroundColorOffset       = [ 0 0 0 0];
radius                      = 25;             % creates mask
contrastPreMultiplicator    = 1.0;
phase                       = 0;

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles                   = 24;
freq                        = numCycles / width; %round( width/numCycles); %
phase                       = 75;
[gratingtex, gratingRect]  = CreateProceduralSineGrating(window, width, height, backgroundColorOffset, radius, contrastPreMultiplicator);

thisAngle   = 30;
addAngle    = 15; % increment to change angle
contrast    = 1;

offsetWidthSet = [ -(width/4), (width/4) ];

%------------------------------------------
%    Draw stuff - button press to exit
%------------------------------------------

for i = 1:10
    
    % change options
    thisAngle = thisAngle + addAngle;                   % rotate grating
    select = randi(2,1);
    thisWidthOffset = offsetWidthSet(select);
    
    dstRect     = OffsetRect(windowRect, thisWidthOffset, 0); 
    
    % Draw the grating into dstRect
    
    timeStart = GetSecs;
    
    Screen('DrawTexture', window, gratingtex, [], dstRect, thisAngle, [], [], ...
        [], [], [], [phase+180, freq, contrast, 0]);
    
    timeEnd = GetSecs;
    timeDur(i) = timeEnd - timeStart;
    
    % Flip to the screen
    Screen('Flip', window);
    WaitSecs(.5);
    
    % Blank screen
    Screen('Flip', window);
    
    WaitSecs(.5);
end
% Wait for a button press to exit
timeDur
KbWait;

% Clear screen
sca;

%Published with MATLAB® R2015b