% for testing
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);

PsychDefaultSetup(2);
% Get the list of screens and choose the one with the highest screen number.
screens=Screen('Screens');
screenNumber=max(screens);

white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);

% Round gray to integral number, to avoid roundoff artifacts with some
% graphics cards:
gray=round((white+black)/2);

% Not sure which call to open window is the best yet
[w, wRect] = PsychImaging('OpenWindow', screenNumber, .5, [0 0 250 250]);  % [command, w, color, dimensions]
%[Params.scr.window, Params.scr.windowRect] = Screen('OpenWindow',Params.scr.Display, 128, Params.scr.testScreenDimensions);            

% Query the frame duration
ifi = Screen('GetFlipInterval', w);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 15;
% Set the line width for our fixation cross
lineWidthPix = 4;

xCoords = [fixCrossDimPix -fixCrossDimPix -fixCrossDimPix fixCrossDimPix];
yCoords = [fixCrossDimPix -fixCrossDimPix fixCrossDimPix -fixCrossDimPix];

%xCoords = [0 -fixCrossDimPix 0 fixCrossDimPix 0 fixCrossDimPix 0 -fixCrossDimPix];
%yCoords = [0 -fixCrossDimPix 0 -fixCrossDimPix 0 fixCrossDimPix 0 fixCrossDimPix];
allCoords = [xCoords;yCoords];
    
	remove = 0.0;
    base = 1.0;
    hilite = 1.0;
    alphO = 1.0;
    alphT = 0.0
    
    % rgb specs for fixation coordinates clockwise from top-left
    quad1 = [base hilite base base ; base remove base base ; base remove base base; alphT alphT alphO alphT]; % upper-left
    quad2 = [base base base hilite ; base base base remove ; base base base remove; alphT alphT alphT alphO]; % upper-right
    quad3 = [hilite base base base ; remove base base base; remove base base base; alphO alphT alphT alphT]; % lower-right
    quad4 = [base base hilite base ; base base remove base ; base base remove base; alphT alphT alphO alphT];
    quad0 = [base base base base ; base base base base ; base base base base; alphO alphO alphO alphO]; 
    cond = quad2;
    
% [minSmoothLineWidth, maxSmoothLineWidth, minAliasedLineWidth, maxAliasedLineWidth] = Screen('DrawLines', windowPtr, xy [,width] [,colors] [,center] [,smooth][,lenient]);
%[min, max, minA, maxA] = Screen('DrawLines', windowPtr, xy [,width] [,colors] [,center] [,smooth] [,lenient]);
Screen('DrawLines', w, allCoords, lineWidthPix, quad0, [125 125], 2)
Screen('DrawLines', w, allCoords, lineWidthPix, cond, [125 125], 2);    
Screen('Flip', w) %% , vbl + (waitframes - 0.5) * ifi);
% function newRect = CenterRectOnPoint(rect,x,y)

     

