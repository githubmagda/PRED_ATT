function[p] = SEQ_ParamsScr(p)

% This file contains the post-PTB-window-open experimental parameters

%%% MONITOR SPECS in mm/cm
p.scr.monitorDist = 57; % cm
p.scr.struct = Screen('Version');
[p.scr.mmX, p.scr.mmY] = Screen('DisplaySize', p.scr.number);  % X and Y size in cm
p.scr.cmX = p.scr.mmX ./10;
p.scr.cmY = p.scr.mmY ./10;

% WINDOW SPECS
p.scr.pixelsX = p.scr.windowRect(3); % X and Y in pixels
p.scr.pixelsY = p.scr.windowRect(4);
p.scr.basicSquare = min(p.scr.pixelsX, p.scr.pixelsY);
%p.scr.pixelsXY = mean (p.scr.pixelsX, p.scr.pixelsY); %
[p.scr.centerX, p.scr.centerY] = WindowCenter(p.scr.window);

% % if p.debug % option for scaling to actual screen size
% %     p.scr.cmX = p.scr.cmX .* p.scr.textScrRatioX ;
% %     p.scr.cmY = p.scr.cmY .* p.scr.textScrRatioY ;
% % end

%%% MEASUREMENT TRANSFORMS
% send back both unit measures: p.scr.pixPerDeg & p.scr.degPrPix 
% and number of pix or deg equivalents
[p, ~] = deg2pix(p, 1); 
[p, ~] = pix2deg(p, 1); 

%%% FLIP TIME / REFRESH RATE
[p.scr.flipInterval, p.scr.nrValidSamples, p.scr.stddev]= Screen('GetFlipInterval', p.scr.window);
p.scr.Hz = 1/p.scr.flipInterval; 

if ceil(p.scr.Hz) < 100 % CHECK for optimal HZ
     display(['Monitor running at ',num2str(p.scr.Hz)]) %,' Should be 100 Hz!!'])
end

%%% SCREEN COLOURS 
p.scr.white = WhiteIndex(p.scr.number);
p.scr.black = BlackIndex(p.scr.number);
p.scr.grey = mean([ p.scr.white, p.scr.black ]); %p.scr.grey = GreyIndex(p.scr.number);
p.scr.background = p.scr.grey;

%%% SCREEN TEXT
p.scr.textType = 'Helvetica';
p.scr.textColor = p.scr.white;

%%% SERIES (predictive) sent to makePredSeriesReplace.m (or variant)
p.series.stimPerSeries = 120;
p.series.seqBasicSet = [1,2,3,4]; % get this seq from block{j}.seqSet
p.series.chunkRpts = 10;
p.series.chunkLength = 3;

% STIM / MOVIE SPECS 
p.scr.stimDur = round2flips(p, .5); %How long each stimulus/trial is on screen
p.scr.framesHz = 60;
p.scr.framesPerMovie = round(p.scr.stimDur * p.scr.framesHz); 
p.scr.frameDur = (p.scr.Hz ./ p.scr.framesHz) * p.scr.flipInterval;

% TEXTURES GRATINGS (for QUADRANTS)
% calculate grating radius - based on degrees or on quadrant size 
p.scr.gratRadiusDeg = 3; % p.scr.degPerPix .* round( p.scr.pixelsXY/8.2 ); % = 2; % grating radius (deg) 
p.scr.gratRadiusPix = round( p.scr.gratRadiusDeg * p.scr.pixPerDeg ); 

% timing of predictive texture in ms  
p.scr.flashDur = round2flips(p, .05);    % duration of predictive flash in 

% calculate distance of grating center from screen center based on degrees or quadrant size 
p.scr.gratPosDeg = 7; % p.scr.degPerPix .* round( p.scr.pixelsXY/4.1 ); % =6; % center position of grating from window center (deg)
p.scr.gratPosPix = round( p.scr.gratPosDeg * p.scr.pixPerDeg ); % deg2pix(p, p.scr.quadGratPosDeg); 
p.scr.gratSidePix = sqrt(p.scr.gratPosPix^2/2);

% ATTENTIONAL DOT & CUE ATTRIBUTES
% probability of dots in staircase procedure
p.series.dotProbStaircase = .3;  
% main series dot specs
p.scr.cueValidPerc = .80;
p.series.dotProb = .02;                         % DEFAULT .03 = percent of dots per series
p.scr.postFlashDur = round2flips(p, .05);       % from start of trial
p.scr.dotDur = round2flips(p, .10);
p.scr.dotJitter = round2flips(p, .01);         % is multiplied by factor of 1:

% ATTENTION-DOT TEXTURE & MASKS (used by makeTextures.m)
p.scr.dotRadiusDeg = .15; 
p.scr.dotRadiusPix = p.scr.dotRadiusDeg * p.scr.pixPerDeg;  % angle2pix(p, p.scr.dotRad);
% masks
p.scr.maskBorder = 20;                  % so as to make the gradient mask for dot presentation smaller than gradient 
p.scr.outerDotMaskRadius = p.scr.gratPosPix - p.scr.maskBorder;     % hypot( p.scr.quadDim/2-10, p.scr.quadDimY/2-10 ); % CHECK - base on visual angle?
p.scr.innerDotMaskRadius = p.scr.gratPosPix - p.scr.gratRadiusPix + p.scr.maskBorder;   % hypot( p.scr.quadDim/2 - p.scr.quadGratRad, p.scr.quadDim/2 - p.scr.quadGratRad);

% % p.series.dotNumAv = floor( p.series.stimPerSeries * p.series.dotProb);
% % p.series.dotZeroPadding = 5;
% % % variation around catchTrialNum allowed
% % p.series.dotNumRange = [ p.series.dotNumAv-1 : p.series.dotNumAv+1 ]; % range of possible catch trials per series ( selected in makeCatchSeries.m )

% SERIES QUESTION
p.series.questionProb = .02;
p.series.questionNum = floor( p.series.stimPerSeries * p.series.questionProb);

% FIXATION GAUSSIAN
p.scr.fixRadiusDeg = 0.3; % Thaler, 2013 recommend radius : .6 or 1.5 degrees
p.scr.fixRadius = round( p.scr.fixRadiusDeg * p.scr.pixPerDeg ); % deg2pix(p, p.scr.fixRadiusDeg);
p.scr.fixGridRadius = 3 .* p.scr.fixRadius;
p.scr.fixRadiusInnerDeg = .08; % ror inner fixation dot
p.scr.fixRadiusInner =  round( p.scr.fixRadiusInnerDeg * p.scr.pixPerDeg );    % deg2pix(p, p.scr.fixRadiusInnerDeg);

%%% FIXATION CROSS
p.scr.fixCrossX = round( p.scr.fixRadius ./ sqrt(2) ); 
p.scr.fixCrossY = p.scr.fixCrossX; % equal size
p.scr.fixCrossDiagonal = 1; % if you want fixation cross to be an 'x' rather than a '+'
p.scr.fixCrossLineWidthPix = 7; % range (0.125000 to 7.000000)
p.scr.fixCrossColor = p.scr.white;
p.scr.fixCrossColorChange = [255, 0, 0]; % for e.g. red warning signal, check DrawTexture commands

%%% length of 4 arms used for  cross
ext = 2.0; % stretches arms (to compensate for Gaussian dispersion)
extColor = 1.2; % less stretch on colored arm
xCoords = [0, -p.scr.fixCrossX, 0, p.scr.fixCrossX, 0, p.scr.fixCrossX, 0, -p.scr.fixCrossX];
yCoords = [0, -p.scr.fixCrossY, 0, -p.scr.fixCrossY, 0, p.scr.fixCrossY, 0, p.scr.fixCrossY];

% fixation cross - dimensions 
p.scr.fixCoords0 = [xCoords .* ext; yCoords .* ext]; % no attentional cue
% dimensions with attentional cue (shorter due to color contrast)
p.scr.fixCoords1 = p.scr.fixCoords0 .* [ext,extColor,ext,ext,ext,ext,ext,ext; ext,extColor,ext,ext,ext,ext,ext,ext];
p.scr.fixCoords2 = p.scr.fixCoords0 .* [ext,ext,ext,extColor,ext,ext,ext,ext; ext,ext,ext,extColor,ext,ext,ext,ext];
p.scr.fixCoords3 = p.scr.fixCoords0 .* [ext,ext,ext,ext,ext,extColor,ext,ext; ext,ext,ext,ext,ext,extColor,ext,ext];
p.scr.fixCoords4 = p.scr.fixCoords0 .* [ext,ext,ext,ext,ext,ext,ext,extColor; ext,ext,ext,ext,ext,ext,ext,extColor];
 
% IF only 2 arms are used for cross
% %     xCoords = [p.scr.fixDimX -p.scr.fixDimX -p.scr.fixDimX p.scr.fixDimX];
% %     yCoords = [p.scr.fixDimY -p.scr.fixDimY p.scr.fixDimY -p.scr.fixDimY];
% %     allCoords = [xCoords; yCoords];

%%% fixation cross: cue color
b = p.scr.background; % 1.0; % p.scr.white; % off white?
hilite = 1.0; remove = 0.0;
alphO = 0.0; alphT = 1.0; % transparency O=opaque, T=transparent  - not currently set

%%% BLENDED RGB color specs for 4 attention cross - colored arm points to quadrants clockwise from top-left
% no highlight - basic cross
p.scr.attn0 = [ b b b b b b b b ; b b b b b b b b ; b b b b b b b b]; % no highlighted arm
% attentional cue highlight
p.scr.attn1 = [ b hilite b b b b b b; b remove b b b b b b; b remove b b b b b b];% alphT alphO alphT alphT]; % upper-left
p.scr.attn2 = [ b b b hilite b b b b; b b b remove b b b b; b b b remove b b b b];% alphT alphT alphT alphO]; % upper-right
p.scr.attn3 = [ b b b b b hilite b b; b b b b b remove b b; b b b b b remove b b];% alphO alphT alphT alphT]; % lower-right
p.scr.attn4 = [ b b b b b b b hilite; b b b b b b b remove; b b b b b b b remove];% alphT alphT alphO alphT];

%%% TEST
% Screen('DrawLines', p.scr.window, p.scr.fixCoords4, p.scr.fixCrossLineWidthPix, p.scr.attn4, [ p.scr.centerX, p.scr.centerY ], 2);
% Screen('Flip', p.scr.window);
% % end test

%%% ALTERNATIVE solid leg color specs
% % rgb specs for 4 attention conditions with colored leg pointing to quadrants clockwise from top-left
% p.scr.attn1 = [ hilite hilite b b b b b b ; b remove b b b b b b ; b remove b b b b b b];% alphT alphO alphT alphT]; % upper-left
% p.scr.attn2 = [ b b hilite hilite b b b b ; b b b remove b b b b ; b b b remove b b b b ];% alphT alphT alphT alphO]; % upper-right
% p.scr.attn3 = [ b b b b hilite hilite b b; b b b b b remove b b; b b b b b remove b b];% alphO alphT alphT alphT]; % lower-right
% p.scr.attn4 = [ b b b b b b hilite hilite ; b b b b b b b remove; b b b b b b b remove];% alphT alphT alphO alphT];

% ALTERNATIVE CROSS WITH 2 LEGS ONLY
%     % rgb specs for 4 attention conditions with 2 legs pointing to quadrants clockwise from top-left
% p.scr.attn1 = [base hilite base base ; base remove base base ; base remove base base];% alphT alphO alphT alphT]; % upper-left
% p.scr.attn2 = [base base base hilite ; base base base remove ; base base base remove];% alphT alphT alphT alphO]; % upper-right
% p.scr.attn3 = [hilite base base base ; remove base base base; remove base base base];% alphO alphT alphT alphT]; % lower-right
% p.scr.attn4 = [base base hilite base ; base base remove base ; base base remove base];% alphT alphT alphO alphT];

% TEXT TIMING using frameRate
p.scr.waitText = round(p.waitText ./p.scr.flipInterval) * p.scr.flipInterval; %% time for instruction delay
p.scr.waitBlank = round(p.waitBlank ./ p.scr.flipInterval) * p.scr.flipInterval; %% time for blank screen intervals

% POLICING 
p.preSeriesFixTime = round2flips (p, 5.0); 
p.scr.fixPoliceX = p.scr.centerX; 
p.scr.fixPoliceY = p.scr.centerY;
p.scr.fixPoliceAng = 4.0;
p.scr.fixPoliceRadius = round( p.scr.fixPoliceAng * p.scr.pixPerDeg ); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
p.maxPoliceErrorTime = round2flips (p, 0.01); % secs adjusted to refresh rates
% % p.maxPoliceErrorTimeMovie = round2flips (p, 0.005); % secs adjusted to refresh rates
 
% % % p.fixPoliceSize=angle2pix(p.Display,1.5); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
% % % p.fixTrialPoliceSize=angle2pix(p.Display,3); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO STOP THE TRIAL
% % % p.fixPoliceX= p.Display.width/2; %Xcenter
% % % p.fixPoliceY= p.Display.height/2; %Ycenter
% % % p.fixCircleRadius = angle2pix(p.Display, 1); % In Pixels, big circle of fixation point was 10 in the original kermit THIS VALUE SETS THE PURPLE SQUARE ON THE EYELINK COMPUTER.
 
% % % p.fixViolNum = 3;      % How many frames of violated fixation should we tolerate before breaking trial?
% % % p.waitAfterPolice = 500;   % Extra ITI after policing stops trial, to cool down
  
% % %% STAIRCASE VARIABLES
