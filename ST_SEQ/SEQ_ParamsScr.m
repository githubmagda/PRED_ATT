function[p] = SEQ_ParamsScr(p)

% This file contains the post-PTB-window-open experimental parameters

% SCREEN COLOURS 
p.scr.white                 = WhiteIndex(p.scr.number);
p.scr.black                 = BlackIndex(p.scr.number);
p.scr.grey                  = p.scr.white ./2; %p.scr.grey = GreyIndex(p.scr.number);
p.scr.background            = p.scr.grey;

% SCREEN TEXT
p.scr.textType              = 'Helvetica';
p.scr.textColor             = p.scr.white;

% TRIAL SPECS
p.blockNumber               = 1; % CHECK - do we need blocks?
p.seriesNumber              = 2;
p.seriesPerBlock            = 1;
p.seriesPerEdf              = 1; % how often data is output to edf file; safer to output each series in case participant quits

% SERIES (predictive) sent to makePredSeriesReplace.m (or variant)
p.series.stimPerSeries      = 120;
p.series.seqBasicSet        = [1,2,3,4]; % get this seq from block{j}.seqSet
p.series.chunkRptsMin       = 4;
p.series.chunkRptsMax       = 10;
p.series.chunkLength        = 4;

% MONITOR SPECS in mm/cm
p.monitor.distance          = 57; % cm
p.monitor.struct            = Screen('Version');
[ p.monitor.mmX, p.monitor.mmY] = Screen('DisplaySize', p.scr.number);  % full display size: X and Y size in mm
p.monitor.cmX               = p.monitor.mmX ./10;
p.monitor.cmY               = p.monitor.mmY ./10;
p.monitor.maxLum            = Screen('ColorRange', p.scr.window);
monitorSpecs                = Screen('Resolution', p.scr.window); % Screen('Resolutions')
p.monitor.pixelX            = monitorSpecs.width;
p.monitor.pixelY            = monitorSpecs.height;

% WINDOW SPECS
p.scr.rectPixelX            = p.scr.windowRect(3); % number of pixels 
p.scr.rectPixelY            = p.scr.windowRect(4);
p.scr.basicSquare           = min( nonzeros( p.scr.windowRect )); % size of square inset where stimuli are shown
p.scr.quadDim               = p.scr.basicSquare ./2;
%p.scr.pixelsXY = mean (p.scr.pixelsX, p.scr.pixelsY); %
[p.scr.centerX, p.scr.centerY] = WindowCenter(p.scr.window);

% if p.debug % option for scaling to actual screen size
%     p.scr.cmX = p.scr.cmX .* p.scr.textScrRatioX ;
%     p.scr.cmY = p.scr.cmY .* p.scr.textScrRatioY ;
% end

%%% MEASUREMENT TRANSFORMS
% send back both unit measures: p.scr.pixPerDeg & p.scr.degPerPix 
% and number of pix or deg equivalents
[p, ~]          = deg2pix(p, 1); 
[p, ~]          = pix2deg(p, 1); 

%%% FLIP TIME / REFRESH RATE
[p.scr.flipInterval, p.scr.nrValidSamples, p.scr.stddev]= Screen('GetFlipInterval', p.scr.window);
p.scr.Hz        = FrameRate(p.scr.window);    %1/p.scr.flipInterval; 

% if ceil(p.scr.Hz) < 100 % CHECK for optimal HZ
      display(['Monitor running at ',num2str(p.scr.Hz)]) %,' Should be 100 Hz!!'])
% end

% STIM / MOVIE SPECS 
p.scr.stimDur               = round2flips(p, 0.5); %How long each stimulus/trial is on screen
p.scr.framesHz              = 60;
p.scr.framesPerMovie        = round(p.scr.stimDur * p.scr.framesHz); 
p.scr.frameDur              = (p.scr.Hz ./ p.scr.framesHz) * p.scr.flipInterval;

% TEXTURES GRATINGS (for QUADRANTS)
% calculate grating radius - based on degrees or on quadrant size 
p.scr.gratRadiusDeg         = 1.0;   % 3 (2*r = 6 (Hoogenboom, 2006?) )                          % p.scr.degPerPix .* round( p.scr.pixelsXY/8.2 ); % = 2; % grating radius (deg) 
p.scr.gratRadius            = p.scr.gratRadiusDeg .*p.scr.pixPerDeg; 
%p.scr.gratGrid              = 2 *p.scr.gratRadius +1;           % scaffolding for grating
%%%p.scr.angleSet           = [15,105];     % Possible angles for grating       

% calculate distance of grating center from screen center based on degrees or quadrant size 
p.scr.gratPosDeg            = 2; % 4 (Hoogenboom, 2006?) p.scr.degPerPix .* round( p.scr.pixelsXY/4.1 ); % =6; % center position of grating from window center (deg)
p.scr.gratPos               = p.scr.gratPosDeg .* p.scr.pixPerDeg; %  
p.scr.gratPosSide           = round( sqrt( p.scr.gratPos^2 /2));
p.scr.gratPosCenterX        = [ (p.scr.centerX-p.scr.gratPosSide), (p.scr.centerX+p.scr.gratPosSide), (p.scr.centerX+p.scr.gratPosSide), (p.scr.centerX-p.scr.gratPosSide)];
p.scr.gratPosCenterY        = [ (p.scr.centerY-p.scr.gratPosSide), (p.scr.centerY-p.scr.gratPosSide), (p.scr.centerY+p.scr.gratPosSide), (p.scr.centerY+p.scr.gratPosSide)];

% % PARAMETERS FOR PROCEDURAL GRATING
% % p.scr.backgroundColorOffsetGrat             = [ 2, 2, 2, 0]; 
% % p.scr.contrastPreMultiplicatorGrat          = 1;
% % - Spatial Frequency (Cycles Per Pixel); One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
% % p.scr.numCyclesGrat                         = 8; 
% % p.scr.freqGrat                              = p.scr.numCyclesGrat / p.scr.gratGrid;           
% % p.scr.phaseGrat                             = 90;
% % p.scr.contrastGrat                          = 1;

% timing of predictive texture in ms  
%p.scr.flashDur          = round2flips( p, .05);    % duration of predictive flash in 

% ATTENTIONAL DOT & CUE ATTRIBUTES
% probability of dots in staircase procedure
p.dot.probStaircase         = .2;           % must be less than 1/3 because response allows for dot +2 screens
% main series dot specs
p.dot.prob                  = .05;           % DEFAULT .03 = percent of dots per series
p.dot.valid                 = .80;
p.dot.dur                   = round2flips(p, 0.10);
p.dot.payout                = .5;
p.dot.zeroPad               = 2; % minumum number of zeros between dots
%%p.scr.dotJitter             = round2flips(p, .01);  % is multiplied by  1-p.scr.stimDur:

% ATTENTION-DOT TEXTURE & MASKS (used by makeTextures.m)
p.dot.radiusDeg          = 0.10; 
p.dot.radius             = p.dot.radiusDeg * p.scr.pixPerDeg;  % angle2pix(p, p.scr.dotRad);
p.dot.thisProbe          = 1.0 ; % will be adjusted by staircase

numDot = 360;
dotAngles = linspace(0, 2*pi, numDot); 
dotRingRadius = p.scr.gratPos-25;
dotRingX = dotRingRadius * cos(dotAngles) + p.scr.centerX;  %+p.scr.dotRadius/2; 
dotRingY = fliplr( dotRingRadius * sin(dotAngles) + p.scr.centerY); % +p.scr.dotRadius/2);
p.dot.ringX = dotRingX;
p.dot.ringY = dotRingY;

% get locations for dots in quads (very confusing cause x/y grids are
% different for dotRing and Psychotoolbox
thisMargin = 30;
p.dot.setX2 = dotRingX( thisMargin : numDot/4-thisMargin);
p.dot.setY2 = dotRingY( thisMargin : numDot/4-thisMargin);
p.dot.setX1 = dotRingX( numDot/4+thisMargin :numDot/2-thisMargin);
p.dot.setY1 = dotRingY( numDot/4+thisMargin :numDot/2-thisMargin);
p.dot.setX4 = dotRingX( numDot/2+thisMargin :numDot-(numDot/4)-thisMargin);
p.dot.setY4 = dotRingY( numDot/2+thisMargin :numDot-(numDot/4)-thisMargin);
p.dot.setX3 = dotRingX( numDot-(numDot/4)+thisMargin :numDot-thisMargin);
p.dot.setY3 = dotRingY( numDot-(numDot/4)+thisMargin :numDot-thisMargin);

% % masks % for older version
% p.scr.maskBorder            = 15;                               % so as to make the gradient mask for dot presentation smaller than gradient 
% p.scr.outerDotMaskRadius    = p.scr.gratPos - p.scr.maskBorder;     % hypot( p.scr.quadDim/2-10, p.scr.quadDimY/2-10 ); % CHECK - base on visual angle?
% p.scr.innerDotMaskRadius    = p.scr.gratPos - p.scr.gratRadius + p.scr.maskBorder;   % hypot( p.scr.quadDim/2 - p.scr.quadGratRad, p.scr.quadDim/2 - p.scr.quadGratRad);

% % p.series.dotNumAv = floor( p.series.stimPerSeries * p.series.dotProb);
% % p.series.dotZeroPadding = 5;
% % % variation around catchTrialNum allowed
% % p.series.dotNumRange = [ p.series.dotNumAv-1 : p.series.dotNumAv+1 ]; % range of possible catch trials per series ( selected in makeCatchSeries.m )

% SERIES QUESTION
p.question.prob               = .01;
p.question.num                = ceil( p.series.stimPerSeries * p.question.prob);

% FIXATION GAUSSIAN
% p.scr.fixRadiusDeg                  = .6;                   % Thaler, 2013 recommend radius : .6 or 1.5 degrees
% p.scr.fixRadius                     = p.scr.fixRadiusDeg * p.scr.pixPerDeg; % deg2pix(p, p.scr.fixRadiusDeg);
% %p.scr.fixGrid                       = 3 .* p.scr.fixRadius + 1;
% p.scr.fixRadiusInnerDeg             = .025;                  %  inner inset fixation dot
% p.scr.fixRadiusInner                = p.scr.fixRadiusInnerDeg * p.scr.pixPerDeg;    % deg2pix(p, p.scr.fixRadiusInnerDeg);
% %p.scr.fixInnerGrid                  = 3 .* p.scr.fixRadiusInner + 1;

% p.scr.fixSc                         = 15.0;  % sigma for gaussian (exponential 'hull')
% p.scr.fixContrast                   = 30; 
% p.scr.fixInnerContrast              = 50;
% p.scr.fixBackgroundColorOffset      = [.5, .5, .5, 0];
% p.scr.fixContrastPreMultiplicator   = 1; 
% p.scr.fixPhase                      = 0;
% p.scr.fixFreq                       = 24;
% p.scr.fixAspectRatio                = 1;

% FIXATION CROSS
p.scr.fixCrossX             = 20; %round( p.scr.fixRadius ./ sqrt(2) ); 
p.scr.fixCrossY             = p.scr.fixCrossX; % equal size
p.scr.fixCrossDiagonal      = 1; % if you want fixation cross to be an 'x' rather than a '+'
p.scr.fixCrossLineWidth     = 5; % range (0.125000 to 7.000000)
p.scr.fixCrossColor         = p.scr.background;
p.scr.fixCrossColorRed      = [255, 0, 0]; % for e.g. red warning signal, check DrawTexture commands
p.scr.fixCrossColorYellow    = [0, 255, 255]; % for e.g. 

% length of 4 arms used for  cross
ext         = 1.0; % stretches arms (to compensate for Gaussian dispersion)
extColor    = 1.0; % less stretch on colored arm
xCoords     = [ 0, -p.scr.fixCrossX, 0, p.scr.fixCrossX, 0, p.scr.fixCrossX, 0, -p.scr.fixCrossX];
yCoords     = [ 0, -p.scr.fixCrossY, 0, -p.scr.fixCrossY, 0, p.scr.fixCrossY, 0, p.scr.fixCrossY];

% fixation cross - dimensions 
p.scr.fixCoords0    = [xCoords .* ext; yCoords .* ext]; % no attentional cue
% dimensions with attentional cue (shorter due to color contrast)
p.scr.fixCoords1    = p.scr.fixCoords0 .* [ext,extColor,ext,ext,ext,ext,ext,ext; ext,extColor,ext,ext,ext,ext,ext,ext];
p.scr.fixCoords2    = p.scr.fixCoords0 .* [ext,ext,ext,extColor,ext,ext,ext,ext; ext,ext,ext,extColor,ext,ext,ext,ext];
p.scr.fixCoords3    = p.scr.fixCoords0 .* [ext,ext,ext,ext,ext,extColor,ext,ext; ext,ext,ext,ext,ext,extColor,ext,ext];
p.scr.fixCoords4    = p.scr.fixCoords0 .* [ext,ext,ext,ext,ext,ext,ext,extColor; ext,ext,ext,ext,ext,ext,ext,extColor];
 
% IF only 2 arms are used for cross
% %     xCoords = [p.scr.fixDimX -p.scr.fixDimX -p.scr.fixDimX p.scr.fixDimX];
% %     yCoords = [p.scr.fixDimY -p.scr.fixDimY p.scr.fixDimY -p.scr.fixDimY];
% %     allCoords = [xCoords; yCoords];

%%% fixation cross: cue color
w = p.scr.white; % 1.0; % p.scr.white; % off white?
bEnd = p.scr.background;
hilite = 1.0; 
% % % remove = 0.0;
% % % alphO = 0.0; alphT = 1.0; % transparency O=opaque, T=transparent  - not currently set

% BLENDED RGB color specs for 4 attention cross - colored arm points to quadrants clockwise from top-left
% no highlight - basic cross
p.scr.attn0 = [ w bEnd w bEnd w bEnd w bEnd ; w bEnd w bEnd w bEnd w bEnd ; w bEnd w bEnd w bEnd w bEnd]; % no highlighted arm
% attentional cue highlight
p.scr.attn1 = [ w bEnd w bEnd w bEnd w bEnd; w hilite w bEnd w bEnd w bEnd; w hilite w bEnd w bEnd w bEnd];% alphT alphO alphT alphT]; % upper-left
p.scr.attn2 = [ w bEnd w bEnd w bEnd w bEnd; w bEnd w hilite w bEnd w bEnd; w bEnd w hilite w bEnd w bEnd];% alphT alphT alphT alphO]; % upper-right
p.scr.attn3 = [ w bEnd w bEnd w bEnd w bEnd; w bEnd w bEnd w hilite w bEnd; w bEnd w bEnd w hilite w bEnd];% alphO alphT alphT alphT]; % lower-right
p.scr.attn4 = [ w bEnd w bEnd w bEnd w bEnd; w bEnd w bEnd w bEnd w hilite; w bEnd w bEnd w bEnd w hilite];% alphT alphT alphO alphT];
p.scr.attnWarning = [ hilite bEnd hilite bEnd hilite bEnd hilite bEnd; 0 bEnd 0 bEnd 0 bEnd 0 bEnd; 0 bEnd 0 bEnd 0 bEnd 0 bEnd];% alphT alphT alphO alphT];

% % % p.scr.attn1 = [ b hilite b bEnd b bEnd b bEnd; b remove b b b b b b; b remove b b b b b b];% alphT alphO alphT alphT]; % upper-left
% % % p.scr.attn2 = [ b bEnd b hilite b bEnd b bEnd; b bEnd b remove b b b b; b b b remove b b b b];% alphT alphT alphT alphO]; % upper-right
% % % p.scr.attn3 = [ b b b b b hilite b b; b b b b b remove b b; b b b b b remove b b];% alphO alphT alphT alphT]; % lower-right
% % % p.scr.attn4 = [ b b b b b b b hilite; b b b b b b b remove; b b b b b b b remove];% alphT alphT alphO alphT];

% % TEST
% Screen('DrawLines', p.scr.window, p.scr.fixCoords4, p.scr.fixCrossLineWidth, p.scr.attnWarning, [ p.scr.centerX, p.scr.centerY ], 2);
% Screen('Flip', p.scr.window);
% % end test

% TEXT TIMING using frameRate
p.scr.waitText = round(p.waitText ./p.scr.flipInterval) * p.scr.flipInterval; %% time for instruction delay
p.scr.waitBlank = round(p.waitBlank ./ p.scr.flipInterval) * p.scr.flipInterval; %% time for blank screen intervals

% POLICING 
p.preSeriesFixTime      = round2flips (p, 2.5); 
p.scr.fixPoliceX       = p.scr.centerX; 
p.scr.fixPoliceY       = p.scr.centerY;
p.scr.fixPoliceAng     = 4.0;
p.scr.fixPoliceRadius  = round( p.scr.fixPoliceAng * p.scr.pixPerDeg ); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
p.scr.maxPoliceErrorTime = round2flips (p, 0.01); % secs adjusted to refresh rates
% % p.maxMonitorErrorTimeMovie = round2flips (p, 0.005); % secs adjusted to refresh rates
 
% % % p.fixMonitorSize=angle2pix(p.Display,1.5); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
% % % p.fixTrialMonitorSize=angle2pix(p.Display,3); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO STOP THE TRIAL
% % % p.fixMonitorX= p.Display.width/2; %Xcenter
% % % p.fixMonitorY= p.Display.height/2; %Ycenter
% % % p.fixCircleRadius = angle2pix(p.Display, 1); % In Pixels, big circle of fixation point was 10 in the original kermit THIS VALUE SETS THE PURPLE SQUARE ON THE EYELINK COMPUTER.
 
% % % p.fixViolNum = 3;      % How many frames of violated fixation should we tolerate before breaking trial?
% % % p.waitAfterMonitor = 500;   % Extra ITI after policing stops trial, to cool down
  
% % %% STAIRCASE VARIABLES
