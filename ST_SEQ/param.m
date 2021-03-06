function p = param(p)

% prediction_attention_task parameters function

% This needs to be organized

p.testEdf           = 1; % eyelink will make file with this same name each tst run

p.intro             = 1;
p.localizer         = 1;
p.useStaircase      = 1;
p.useEyetracker     = 0;
p.useAudio          = 0;
p.english           = 1; % default castellano

% SCREEN COLOURS 
p.scr.white         = WhiteIndex(p.scr.number);
p.scr.black         = BlackIndex(p.scr.number);
p.scr.grey          = p.scr.white ./2; %p.scr.grey = GreyIndex(p.scr.number);
p.scr.background    = p.scr.grey;


% KEYBOARD
p.activeKeys        = [KbName('space'), KbName('Return'), KbName('C'),KbName('V'),KbName('O'), KbName('Escape'), KbName('q')]; % % specify key names of interest in the study N.B. PsychDefaultSetup(1+) already sets up KbName('UnifyKeyNames') using PsychDefaultSetup(1 or 2);
p.killKey           = KbName('Escape'); % Key to terminate the experiment at any time
p.calibKey          = KbName('c');  % Key during breaks to call calibration
p.validKey          = KbName('v');  % Key during breaks to call validation of calibration
p.quitKey           = KbName('q');   % Key during breaks to stop eyetracking

% TRIAL SPECS
p.blockNumber       = 1; % CHECK - do we need blocks?
p.seriesNumber      = 2;
p.seriesPerBlock    = 1;
p.seriesPerEdf      = 1; % how often data is output to edf file; safer to output each series in case participant quits

% SERIES (predictive) sent to makePredSeriesReplace.m (or variant)
p.series.stimPerSeries      = 20;  %120
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
p.scr.basicSquare           = round( min( nonzeros( p.scr.windowRect ))); % size of square inset where stimuli are shown
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

display(['Monitor running at ',num2str(p.scr.Hz)]) %,' Should be 100 Hz!!'])

% STIM / MOVIE SPECS 
p.scr.stimDur               = round2flips(p, 0.5); %How long each stimulus/trial is on screen
p.scr.framesHz              = 60;
p.scr.framesPerMovie        = round(p.scr.stimDur * p.scr.framesHz); 
p.scr.frameDur              = (p.scr.Hz ./ p.scr.framesHz) * p.scr.flipInterval;

% TEXTURES GRATINGS (for QUADRANTS)
% calculate grating radius - based on degrees or on quadrant size 
p.grat.radiusDeg         = 0.50;   % 3 (2*r = 6 (Hoogenboom, 2006?) )                          % p.scr.degPerPix .* round( p.scr.pixelsXY/8.2 ); % = 2; % grating radius (deg) 
p.grat.radius            = p.grat.radiusDeg .* p.scr.pixPerDeg; 

% calculate distance of grating center from screen center based on degrees or quadrant size 
p.grat.posDeg            = 1.0; % 4 (Hoogenboom, 2006?) p.scr.degPerPix .* round( p.scr.pixelsXY/4.1 ); % =6; % center position of grating from window center (deg)
p.grat.pos               = p.grat.posDeg .* p.scr.pixPerDeg; %  
p.grat.posSide           = round( sqrt( p.grat.pos^2 /2));
p.grat.posCenterX        = [ (p.scr.centerX-p.grat.posSide), (p.scr.centerX+p.grat.posSide), (p.scr.centerX+p.grat.posSide), (p.scr.centerX-p.grat.posSide)];
p.grat.posCenterY        = [ (p.scr.centerY-p.grat.posSide), (p.scr.centerY-p.grat.posSide), (p.scr.centerY+p.grat.posSide), (p.scr.centerY+p.grat.posSide)];
p.grat.angleSet          = Shuffle([15, 30, 45, 60] +7);  % Shuffle([7.5, 15, 22.5, 30]); %Shuffle([3.5, 7, 10.5, 15]);  %= datasample( 1:length( angleSet), 4, 'Replace', false);
p.grat.angleIncrement    = 20;

% % calculate grating rect positions (centered on point p.scr.gratPos from center)
% %p.grat.sineTexRect      = [0, 0, 2 * p.grat.radius, 2 * p.grat.radius];
% p.grat.left             = p.scr.centerX  -p.grat.posSide -tex.sineRect(3)/2;
% p.grat.right            = p.scr.centerX  +p.grat.posSide -tex.sineRect(3)/2;
% p.grat.top              = p.scr.centerY  -p.grat.posSide -tex.sineRect(4)/2;
% p.grat.bottom           = p.scr.centerY  +p.grat.posSide -tex.sineRect(4)/2;
% p.grat.offsetXSet        = [ p.grat.left, p.grat.right, p.grat.right, p.grat.left];
% p.grat.offsetYSet        = [ p.grat.top, p.grat.top, p.grat.bottom, p.grat.bottom];
% 
% % make destination rects for gratings
% %p.grat.dstRects        = OffsetRect( tex.sineRect, p.grat.posCenterX-tex.sineRect(3), p.grat.posCenterY-tex.sineRect(4));
% p.grat.dstRects         = [ ( p.grat.posCenterX -( tex.sineRect(3)/2)); ( p.grat.posCenterY -( tex.sineRect(4)/2)); (p.grat.posCenterX +( tex.sineRect(3)/2)); (p.grat.posCenterY +( tex.sineRect(4)/2))];

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

% % masks %  older version
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
p.fix.radiusDeg                  = .02; %note a Guassian doesn't have a radius (Inf?), so the radius here is the std.
p.fix.radius                     = p.fix.radiusDeg * p.scr.pixPerDeg; % deg2pix(p, p.scr.fixRadiusDeg);
p.fix.color                      = p.scr.white;

% p.scr.fixSc                         = 15.0;  % sigma for gaussian (exponential 'hull')
% p.scr.fixContrast                   = 30; 
% p.scr.fixInnerContrast              = 50;
% p.scr.fixBackgroundColorOffset      = [.5, .5, .5, 0];
% p.scr.fixContrastPreMultiplicator   = 1; 
% p.scr.fixPhase                      = 0;
% p.scr.fixFreq                       = 24;
% p.scr.fixAspectRatio                = 1;

% % TEST
% Screen('DrawLines', p.scr.window, p.scr.fixCoords4, p.scr.fixCrossLineWidth, p.scr.attnWarning, [ p.scr.centerX, p.scr.centerY ], 2);
% Screen('Flip', p.scr.window);
% % end test



% POLICING 
p.policeEye             = 2; % 1 for left, 2 for right
p.EyelinkMouse          = 0; % not sure what this does
p.dummyMode             = 0; % 0 for record, 1 for dummy
p.preSeriesFixTime      = round2flips (p, 2.5); 
p.scr.fixPoliceX        = p.scr.centerX; 
p.scr.fixPoliceY        = p.scr.centerY;
p.scr.fixPoliceAng      = 4.0;
p.scr.fixPoliceRadius   = round( p.scr.fixPoliceAng * p.scr.pixPerDeg ); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
p.scr.maxOutofBounds    = round2flips (p, 0.01); % secs adjusted to refresh rates
% % p.maxMonitorErrorTimeMovie = round2flips (p, 0.005); % secs adjusted to refresh rates
 
% % % p.fixMonitorSize=angle2pix(p.Display,1.5); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
% % % p.fixTrialMonitorSize=angle2pix(p.Display,3); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO STOP THE TRIAL
% % % p.fixMonitorX= p.Display.width/2; %Xcenter
% % % p.fixMonitorY= p.Display.height/2; %Ycenter
% % % p.fixCircleRadius = angle2pix(p.Display, 1); % In Pixels, big circle of fixation point was 10 in the original kermit THIS VALUE SETS THE PURPLE SQUARE ON THE EYELINK COMPUTER.
 
% % % p.fixViolNum = 3;      % How many frames of violated fixation should we tolerate before breaking trial?
% % % p.waitAfterMonitor = 500;   % Extra ITI after policing stops trial, to cool down
  
% % %% STAIRCASE VARIABLES

% TEXTURE PARAMETERS

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

numDot              = 360;
dotAngles           = linspace(0, 2*pi, numDot); 
dotRingRadius       = p.grat.pos-25;
p.dot.ringX         = dotRingRadius * cos(dotAngles) + p.scr.centerX;  %+p.scr.dotRadius/2; 
p.dot.ringY         = fliplr( dotRingRadius * sin(dotAngles) + p.scr.centerY); % +p.scr.dotRadius/2);

% get locations for dots in quads in x/y cols for 4 quads (very confusing cause x/y grids are
% different for dotRing and Psychotoolbox)
thisMargin          = 30;            % distance within edge of grid
p.dot.set           = NaN(numDot,2,4);
set2                = [ p.dot.ringX( thisMargin : numDot/4-thisMargin)', p.dot.ringY( thisMargin : numDot/4-thisMargin)'];
set1                = [ p.dot.ringX( numDot/4+thisMargin :numDot/2-thisMargin)', p.dot.ringY( numDot/4+thisMargin :numDot/2-thisMargin)'];
set4                = [ p.dot.ringX( numDot/2+thisMargin :numDot-(numDot/4)-thisMargin)', p.dot.ringY( numDot/2+thisMargin :numDot-(numDot/4)-thisMargin)'];
set3                = [ p.dot.ringX( numDot-(numDot/4)+thisMargin :numDot-thisMargin)', p.dot.ringY( numDot-(numDot/4)+thisMargin :numDot-thisMargin)'];
p.dot.set( 1:size(set2,1), 1:size(set2,2), 2)    = set2;
p.dot.set( 1:size(set1,1), 1:size(set1,2), 1)    = set1;
p.dot.set( 1:size(set4,1), 1:size(set4,2), 4)    = set4;
p.dot.set( 1:size(set3,1), 1:size(set3,2), 3)    = set3;

% % % p.dot.set(:,:,2)    = p.dot.ringX( thisMargin : numDot/4-thisMargin)';
% % % p.dot.set(:,2,2)    = p.dot.ringY( thisMargin : numDot/4-thisMargin)';
% % % p.dot.set(:,1,1)    = p.dot.ringX( numDot/4+thisMargin :numDot/2-thisMargin)';
% % % p.dot.set(:,2,1)    = p.dot.ringY( numDot/4+thisMargin :numDot/2-thisMargin)';
% % % p.dot.set(:,1,4)    = p.dot.ringX( numDot/2+thisMargin :numDot-(numDot/4)-thisMargin);
% % % p.dot.set(:,2,4)    = p.dot.ringY( numDot/2+thisMargin :numDot-(numDot/4)-thisMargin);
% % % p.dot.set(:,1,3)    = p.dot.ringX( numDot-(numDot/4)+thisMargin :numDot-thisMargin);
% % % p.dot.set(:,2,3)    = p.dot.ringY( numDot-(numDot/4)+thisMargin :numDot-thisMargin);

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
extColor    = 1.0; % adjustt stretch on colored arm
xCoords     = [ 0, -p.scr.fixCrossX, 0, p.scr.fixCrossX, 0, p.scr.fixCrossX, 0, -p.scr.fixCrossX];
yCoords     = [ 0, -p.scr.fixCrossY, 0, -p.scr.fixCrossY, 0, p.scr.fixCrossY, 0, p.scr.fixCrossY];

% fixation cross - dimensions 
p.scr.fixCoords0    = [xCoords .* ext; yCoords .* ext]; % no attentional cue
% dimensions with attentional cue (shorter due to color contrast)
p.scr.fixCoords1    = p.scr.fixCoords0 .* [ext,extColor,ext,ext,ext,ext,ext,ext; ext,extColor,ext,ext,ext,ext,ext,ext];
p.scr.fixCoords2    = p.scr.fixCoords0 .* [ext,ext,ext,extColor,ext,ext,ext,ext; ext,ext,ext,extColor,ext,ext,ext,ext];
p.scr.fixCoords3    = p.scr.fixCoords0 .* [ext,ext,ext,ext,ext,extColor,ext,ext; ext,ext,ext,ext,ext,extColor,ext,ext];
p.scr.fixCoords4    = p.scr.fixCoords0 .* [ext,ext,ext,ext,ext,ext,ext,extColor; ext,ext,ext,ext,ext,ext,ext,extColor];
 
% fixation coloring
w = p.scr.white; 
bEnd = p.scr.background;
hilite = 1.0; 

% BLENDED RGB color specs for 4 attention cross - colored arm points to quadrants clockwise from top-left
% no highlight - basic cross
p.scr.attn0 = [ w bEnd w bEnd w bEnd w bEnd ; w bEnd w bEnd w bEnd w bEnd ; w bEnd w bEnd w bEnd w bEnd]; % no highlighted arm
% attentional cue highlight
p.scr.attn1 = [ w bEnd w bEnd w bEnd w bEnd; w hilite w bEnd w bEnd w bEnd; w hilite w bEnd w bEnd w bEnd];% alphT alphO alphT alphT]; % upper-left
p.scr.attn2 = [ w bEnd w bEnd w bEnd w bEnd; w bEnd w hilite w bEnd w bEnd; w bEnd w hilite w bEnd w bEnd];% alphT alphT alphT alphO]; % upper-right
p.scr.attn3 = [ w bEnd w bEnd w bEnd w bEnd; w bEnd w bEnd w hilite w bEnd; w bEnd w bEnd w hilite w bEnd];% alphO alphT alphT alphT]; % lower-right
p.scr.attn4 = [ w bEnd w bEnd w bEnd w bEnd; w bEnd w bEnd w bEnd w hilite; w bEnd w bEnd w bEnd w hilite];% alphT alphT alphO alphT];
p.scr.attnWarning = [ hilite bEnd hilite bEnd hilite bEnd hilite bEnd; 0 bEnd 0 bEnd 0 bEnd 0 bEnd; 0 bEnd 0 bEnd 0 bEnd 0 bEnd];% alphT alphT alphO alphT];

% SQUARE WAVE GRATING
p.grat.backgroundColorOffsetGrat    = [0,0,0,1];
p.grat.phase                        = 0;
p.grat.freq                         = 3.2 / p.scr.pixPerDeg;      % Landau & Fries, 2015 3.2    % see paper by Ayelet, Fries 2015 : 3.2 20; Martin Vinck - .11; Hoogenboom, 2006 3 cycles per degree)?
p.grat.contrast                     = 1.0;

% TEXT PARAMETERS

[~,p.text.texts,~]      = xlsread('texts.xlsx');
p.text.language         = 1; % 1 for English, 2 for Spanish
p.text.waitText         =  5.0;
p.text.waitBlank        = 0.3;
p.text.waitText         = round(p.text.waitText ./p.scr.flipInterval) * p.scr.flipInterval; %% time for instruction delay
p.text.waitBlank        = round(p.text.waitBlank ./ p.scr.flipInterval) * p.scr.flipInterval; %% time for blank screen intervals
p.text.font             = 'Helvetica';
p.text.style            = [];
p.text.lineSpace        = 1.5;
p.text.textColor        = p.scr.white;
p.text.wrap             = 75; % number of charachters before wrap to next line
if p.debug
    p.text.textSize     = 16;
else
    p.text.textSize     = 18;
end