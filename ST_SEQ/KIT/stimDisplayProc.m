function[p, sr] = stimDisplayProc(p, sr, type)

if strcmp(type, 'regularSeries')
    regularSeries = 1;
    staircase = 0;
end
if strcmp(type, 'staircase')
    staircase = 1;
    regularSeries = 0;
end

% This script displays stimulus sequence for 'type', e.g. staircase or main
% experiment; the staircase determines 75% detection based on luminance? of the attentional dot;
% The predictive quadrant is always at same angle; other 3 gratings are
% randomly chosen from remaining options (1:6:180)
% Inputs include the predictive and attn series included in series
% structure

% GAUSSIANS

radiusSTD               = p.scr.dotRadius;
radiusDotSize           = 5.0 * p.scr.dotRadius;

radiusFix               = 0.3 * p.scr.pixPerDeg;
virtualSizeGauss        = radiusFix * 2;

scFix                   = 10;  % sd
scFixInner              = 7;
scDot                   = 15;

contrastFix             = 30;
contrastFixInner        = 25;

aspectRatio             = 1;
backgroundColorOffsetGAUSS   = [0,0,0,0];

% determining SCALES of gaussian displays
fixScale                    = 1.0;               % scale of  adjustment to gaussians in 'DrawTexture'
fixInnerScale               = 0.25;
dotScale                    = 1;

% FIXATION GAUSSIAN
% p.scr.fixGridRadius = 3.* p.scr.fixRadius; % the box is always 3 * 1 standard deviation of the gaussian
% szFix = p.scr.fixGridRadius;
[ dotX, dotY ] = meshgrid( -radiusDotSize:radiusDotSize, -radiusDotSize:radiusDotSize );    % CHECK - visual angle?
lenDot = radiusDotSize.*2 + 1;
% create gaussian
alph = exp(-( dotX.^2 / (2* (radiusSTD) .^2) ) - ( dotY.^2 / (2* (radiusSTD) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
color = 1;
gausFix = cat(3, color .* ones(lenDot,lenDot,3), alph);   % default: gaus = ones(101,101,1) creates white box

% make TEXTURE
[dotTex] = Screen('MakeTexture', p.scr.window, gausFix);
dotOnSet = Shuffle( repmat([ p.scr.flipInterval : p.scr.flipInterval : (p.scr.stimDur-p.scr.flipInterval)],1,2));
% Screen('DrawTexture', p.scr.window, dotTex, [], [0 0 90 90], [], 1, 1, [255,255,255]); %, [], kPsychDontDoRotation, [1,15,1,1]');

% Initial params for the SINE GRATING
backgroundColorOffsetGrat   = [0,0,0,0];
phaseGrat                   = 0;
freqGrat                    = 3.2 / p.scr.pixPerDeg;      % Landau& Fries, 2015 3.2    % see paper by Ayelet, Fries 2015 : 3.2 20; Martin Vinck - .11?
contrastGrat                = 1.0;

% radius of the disc edge
gratRadius              = p.scr.gratRadius;
% basic grating size
virtualSizeGrat         = p.scr.gratRadius *2;

% smoothing sigma in pixel
sigmaGrat               = 1;    % 'hull' / blur of gaussian
% use alpha channel for smoothing?
useAlpha                = true;     % ignored
% smoothing method: cosine (0) or smoothstep (1)
smoothMethod            = 1;          % ignored

% MAKE TEXTURES
[sineTex, sineTexRect] = CreateProceduralSquareWaveGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat,...
    backgroundColorOffsetGrat, gratRadius, 1);

% [dotTex, dotTexRect]    = CreateProceduralGaussBlob( p.scr.window , virtualSizeGauss*2, virtualSizeGauss*2,...
%     backgroundColorOffsetGAUSS, [],[]);

% other options
%    [gratTex, gratTexRect]      = CreateProceduralSineGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat, p.scr.backgroundColorOffsetGrat, p.scr.gratRadius, p.scr.contrastPreMultiplicatorGrat);
%    [sineTex, sineTexRect] = CreateProceduralSmoothedApertureSineGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat,...
%    backgroundColorOffset, gratRadius, [], sigmaGrat, useAlpha, smoothMethod);

% possible angles for regular gratings to accomodate 'jumps' without ever
% being the same across quads
angleSet = Shuffle([15, 30, 45, 60] +7);% Shuffle([7.5, 15, 22.5, 30]); %Shuffle([3.5, 7, 10.5, 15]);  %= datasample( 1:length( angleSet), 4, 'Replace', false);
angleIncrement = 60; % degrees of predictive degrees-jump

% CALCULATE GRATING QUAD POSITIONS (centered on point p.scr.gratPos from center)
left                = p.scr.centerX -sineTexRect(3)/2 -p.scr.gratPosSide ;
right               = p.scr.centerX -sineTexRect(3)/2 +p.scr.gratPosSide ;
top                 = p.scr.centerY -sineTexRect(4)/2 -p.scr.gratPosSide ;
bottom              = p.scr.centerY -sineTexRect(4)/2 +p.scr.gratPosSide ;
p.scr.offsetXSet    = [ left, right, right, left];
p.scr.offsetYSet    = [ top, top, bottom, bottom];

% destinations Rects for gaussian fixations
% dstRectFix          = OffsetRect(gaussTexRect*fixScale,      p.scr.centerX-(radiusFix*2*fixScale), p.scr.centerY-(radiusFix*2*fixScale));
% dstRectFixInner     = OffsetRect(gaussTexRect*fixInnerScale, p.scr.centerX-(radiusFix*2*fixInnerScale), p.scr.centerY -(radiusFix*2*fixInnerScale));

% make destination rects for gratings
dstRectGrats        = OffsetRect( sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet')';
paramsGrats         = repmat([phaseGrat, freqGrat, contrastGrat, 0], 4, 1)';

paramsGauss  = [contrastFix, scFix, aspectRatio, 1;...
    contrastFixInner, scFixInner, aspectRatio, 1];

% END PROCEDURALS

% REGULAR SERIES
if regularSeries
    % Question paramaters: determine x/y positions for red circle for question re upcoming dot
    p.circleXPosLeft =left; %= p.scr.centerX - ceil( p.scr.rectGrating(3)/2);   % - p.scr.gratPosPix/2; % size of quad minus 1/2 grating box minus
    p.circleXPosRight= right; % = p.scr.centerX + ceil( p.scr.rectGrating(3)/2);  % - p.scr.gratPosPix/2; % size of quad minus 1/2 grating box minus
    p.circleYPosTop = top; %p.scr.centerY - ceil( p.scr.rectGrating(4)/2);    % - p.scr.gratPosPix/2;
    p.circleYPosBottom = bottom; %p.scr.centerY + ceil( p.scr.rectGrating(4)/2); % - p.scr.gratPosPix/2;
    
    % Before animation loop show attentional-fixation cross indicates attn quadrant
    % thisCue determines attentional pointer and probabilistic placement of attentional dot
    pos = randi( length( p.series.seqBasicSet));        %
    thisCue = p.series.seqBasicSet( pos);               % choose attn quadrant / cue
    sr.thisCue = thisCue;  % save to series level
    
    % used to calculate dot position below
    setOther = p.series.seqBasicSet; % set of possible cue and dot quadrants
    setOther( setOther==thisCue) = [];  % remaining options when cue is invalid
    
    % initialize question - where will next flash appear?
    sr.question.numCorrect = 0;
    
    switch thisCue
        case 1
            attn = p.scr.attn1;             % selects the fixation cue (arm of cross)
            fixCoords = p.scr.fixCoords1;   % quad and length of fixation cue arms
        case 2
            attn = p.scr.attn2;
            fixCoords = p.scr.fixCoords2;
        case 3
            attn = p.scr.attn3;
            fixCoords = p.scr.fixCoords3;
        case 4
            attn = p.scr.attn4;
            fixCoords = p.scr.fixCoords4;
    end
else
    fixCoords = p.scr.fixCoords0;
    thisCue = randi(4,1);
end
% END REGULAR

% DRAW PRE-SERIES FIXATION GUASSIAN w or w/out ATTENTION CUE

% Draw plain or w/cue (red arm pointing to attentional quadrant) fixation cross with r
if staircase
    % Draw  fixation cross without cue : dark cross two nested white gaussians
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    %     Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, paramsGauss');
else
    % Draw cue fixation cross with attentional pointer 'attn' (set above)
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, attn, [ p.scr.centerX, p.scr.centerY ], 2);
    %     Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, [contrastFix, scFix, aspectRatio, 1; contrastFixInner, scFixInner, aspectRatio, 1]');
end

Screen('DrawingFinished', p.scr.window);

% FLIP
[vbl] = Screen('Flip', p.scr.window, 0);
thisWaitTime = p.preSeriesFixTime - (.5 *p.scr.flipInterval);

% END DRAW PRE-SERIES FIXATION GUASSIAN

% SEND MESSAGE to EYETRACKER .edf file
if p.useEyelink
    messageText = strcat( 'STAIRCASE_PRE-SERIES FIXATION', num2str(sr.number));
    Eyelink( 'Message', messageText);
end

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation( p, sr, thisWaitTime);
else
    WaitSecs( thisWaitTime); % cue w/without attentional cross
end
% END POLICING FIXATION

% DISPLAY SEQUENCE
% initialize timing and response vectors
sr.series.angleSet     = nan(p.series.stimPerSeries, 4);
sr.time.trialEvents    = nan(p.series.stimPerSeries, 4);

%p.scr.dotComplete       = 1;   % flag for dotDur having completed within one trial
sr.time.dotOn           = nan( 1, p.series.stimPerSeries ); %% randi(p.scr.stimDur*1000, 1, p.series.stimPerSeries) ./ 1000;
sr.time.dotOff          = nan( 1, p.series.stimPerSeries );  %%sr.time.dotOn + p.scr.dotDur;

sr.dot.posX             = nan( 1, p.series.stimPerSeries );                % dot position and timing
sr.dot.posY             = nan( 1, p.series.stimPerSeries );

sr.dot.response         = nan( 1, p.series.stimPerSeries );             % dot response
sr.dot.responseCorrect  = nan( 1, p.series.stimPerSeries );
sr.dot.FA               = nan( 1, p.series.stimPerSeries );
sr.dot.missed           = nan( 1, p.series.stimPerSeries );
sr.dot.responsekeyCode  = nan( 1, p.series.stimPerSeries );
sr.dot.RT               = nan( 1, p.series.stimPerSeries );
sr.dot.quad             = nan( 1, p.series.stimPerSeries );
checked                 = zeros( 1, p.series.stimPerSeries );            % check = 1 if no need to check for response on this trial
loopCounterTrack = NaN(p.series.stimPerSeries,4);

if regularSeries
    sr.question.responseQuad = nan( 1, p.series.stimPerSeries );
    sr.question.responseCorrect = nan( 1, p.series.stimPerSeries );
    sr.question.RT = nan( 1, p.series.stimPerSeries );
    sr.question.chunkNum = nan( 1, p.series.stimPerSeries );
    sr.question.elementNum = nan( 1, p.series.stimPerSeries );
    
    % SELECT QUESTION TRIALS % N.B. not trial with dot or subsequent trial
    dot = find( sr.dot.series == 1);                                    % ensure last trial not included: find( sr.dot.series( 1:( length(sr.dot.series)-1)) == 1);
    questionSet = find( sr.pred.trackerByChunk > 1);                    % number of elements in sequence already viewed
    questionSet = Shuffle( setdiff( questionSet,dot));
    thisQuestionSet = questionSet( 1:p.series.questionNum);
    thisQuestionSet(length(sr.dot.series)) = 0;                         % ensure no question on last trial
    sr.question.trialNumbers = thisQuestionSet;                         % record subSet
end

% STAIRCASE START
if staircase
    % INITIALIZE STAIRCASE (see MinExpEntStairDemo from Psychtoolbox)
    % stair input
    probeset    = .05 : .05 :1; % -15:0.5:15;         % set of possible probe values
    meanset     = .05 : .05 :1; % -10:0.2:10;         % sampling of pses, doesn't have to be the same as probe set
    slopeset    = [.1:.1:5].^2;%[.5:.1:5].^2;       % set of slopes, quad scale
    lapse       = 0.05;                             % lapse/mistake rate
    guess       = 0.50;                             % guess rate / minimum correct response rate (for detection expt: 1/num_alternative, 0 for discrimination expt)
    
    % STAIRCASE: general settings
    ntrial              = length( sr.dot.series( sr.dot.series == 1));
    sr.time.probeStart  = nan( 1, ntrial);
    sr.time.probeEnd    = nan( 1, ntrial);
    sr.time.probeDur    = nan( 1, ntrial);
    
    % STAIRCASE: Create staircase instance.
    stair = MinExpEntStair('v2');
    
    % STAIRCASE:stair.init.
    stair.set_use_lookup_table(true);
    
    % option: use logistic instead of default cumulative normal. best to call
    % before stair.init
    %stair('set_psychometric_func','logistic');
    
    % STAIRCASE: initialize
    stair.init( probeset, meanset, slopeset, lapse, guess);
    
    % option: use a subset of all data for choosing the next probe
    stair.toggle_use_resp_subset_prop( 5,.7);               % STAIRCASE: %( 10,.9);
    
    % STAIRCASE: set value for first probe based on probeset values
    first_value = probeset( ( round( length( probeset) /2)*100)/100);   % STAIRCASE: MA set to mode of probeset
    stair.set_first_value( first_value);  % STAIRCASE: stair.set_first_value(3);
    
    ktrial = 1; % set counter for dot probes
    [thisProbe, ~, ~]  = stair.get_next_probe();            % thisProbe is the value that changes along the staircase
    
end % STAIRCASE END

% START KEYBOARD QUEUE - reset below in trial loop
KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
KbQueueStart();   %% KbQueueStart([deviceIndex])

dotContinues = 0;   % continue dot on next screen; gets reset below

% SERIES START MESSAGES
if p.useEyelink
    messageText = strcat('SERIES_START', num2str(sr.number));
    Eyelink('message', messageText)
end

sr.time.seriesStart = GetSecs;

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown

    %%sr.time.trialSetup(f) = GetSecs;
    % if REGULAR SERIES: set predictive gratings
    if regularSeries
        thisPred = sr.pred.series(f);           %  quadrant where flash will appear
    end
    
    loopOn = 1;         % gets reset for dot display
    loopCounter = 1;    % counter for dot display
    
    if sr.dot.series(f) == 1 % PREPARE DOT
        display('dot')
        if ~dotContinues
            sr.time.dotOn(f) = dotOnSet(f);
            sr.time.dotOff(f) = sr.time.dotOn(f) + p.scr.dotDur;
            
            if regularSeries % dot placement determined by attentional cue and cue validity
                
                % DOT POSITION - is  dot in attentional quad 'VALID'?
                selEl = randi(10,1);                    % 1 in 10 probability
                if selEl <= ( p.series.cueValidPerc*10) % e.g. xx% likelihood
                    sr.dot.valid(f) = 1;
                    dotQuad = thisCue;
                else
                    sr.dot.Valid(f) = 0;
                    ShuffleSet = Shuffle(setOther);     % select next random position (not including cued position)
                    dotQuad = ShuffleSet(1);            % random allocation to any other quad
                end
            else
                dotQuad = randi(4,1);                   % random quad selection
            end
            
            
            switch dotQuad                              % xy coordinates for dot in specified quadrants 1:4
                case 1
                    dotSetX = p.scr.dotSetX1;
                    dotSetY = p.scr.dotSetY1;           % defines set of possible dot locations
                case 2
                    dotSetX = p.scr.dotSetX2;
                    dotSetY = p.scr.dotSetY2;
                case 3
                    dotSetX = p.scr.dotSetX3;
                    dotSetY = p.scr.dotSetY3;
                case 4
                    dotSetX = p.scr.dotSetX4;
                    dotSetY = p.scr.dotSetY4;
            end
            sr.dot.quad(f) = dotQuad;
            
            
            % DOT SPECS
            % get location of occasional dot using random selection wihtin
            % specified quadrant;then randomly choose pair of x,y coordinates
            % for dot from dotSets X,Y
            pos = randi( length(dotSetX), 1);
            thisDotX = round( dotSetX( pos));
            thisDotY = round( dotSetY( pos));
            sr.dot.posX(f) = thisDotX;
            sr.dot.posY(f) = thisDotY;
            
            % make dstRect and update params for dot and grats
            dstRectDot                  = OffsetRect([0,0,radiusDotSize,radiusDotSize], thisDotX-radiusDotSize/2, thisDotY-radiusDotSize/2);
            sr.dot.dstRectDot(f,:)      = dstRectDot;
            
        end
    end
    %thisWaitTime = p.scr.stimDur -(0.5 *p.scr.flipInterval);
    
    while loopOn
        
        % DRAW TEXTURES % if REGULAR SERIES:
        % for ff = 1:30
        %     phaseIncrement = 0;
        %     phaseGrat       = phaseGrat + phaseIncrement; %mod( phaseGrat+1, 180);
        %     paramsGrats     = repmat([phaseGrat, freqGrat, contrastGrat, 0], 4, 1)';
        
        if regularSeries
            % Draw  gratings, inserting predictive grating
            %paramsGrats( 1, thisPred)      = phaseGrat-phaseIncrement*2;
            angleSet(thisPred) = angleSet(thisPred) + angleIncrement; % anglePredSet(f);        % predictive grating gets pred angle
            angleSet = mod(angleSet, 180);
            sr.series.angleSet(f,:) = angleSet;
            Screen('DrawTextures', p.scr.window, sineTex, [], dstRectGrats, angleSet, [], [], ...
                [], [], [], paramsGrats);
        else % staircase
            if loopCounter == 1
                f
                angleSet = angleSet +1;
                sr.series.angleSet(f,:) = angleSet;
            end
            Screen('DrawTextures', p.scr.window, sineTex, sineTexRect, dstRectGrats, angleSet, [], 0, ...
                [0,0,0,1], [], [], paramsGrats);
        end
        
        % Draw  fixation cross without cue : dark cross two nested white gaussians
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        %         Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, paramsGauss');
        
        if sr.dot.series(f) == 1
            
            if dotContinues % continuing dot should start on first screen
                loopCounter = 2;
                dotContinues = 0;
            end
            
            switch loopCounter
                
                case 1
                    thisWaitTime = sr.time.dotOn(f) -(0.5 *p.scr.flipInterval);
                    loopCounterTrack(f,1) = thisWaitTime;
                    loopCounter = loopCounter +1;
                    
                case 2
                    % draw dot
                    Screen('DrawTexture', p.scr.window, dotTex, [], sr.dot.dstRectDot(f,:), [], 1, 0.5, [1,0,0, thisProbe]); %, [], kPsychDontDoRotation, [1,15,1,1]');
                    loopCounter = loopCounter +1;
                    %Screen('DrawTextures', p.scr.window, dotTex, [], dstRectDots', [], 1, 0.5, []); %, [], kPsychDontDoRotation, [1,15,1,1]');
                    
                    diff = sr.time.dotOff(f) - p.scr.stimDur;
 
                    if  diff > p.scr.flipInterval % dot finishes on this trial                 
                        % dot continues on next trial (set up values)
                        dotContinues = 1;
                        sr.dot.series(f+1) = 1;
                        sr.time.dotOn(f+1) = 0.5* p.scr.flipInterval;
                        sr.time.dotOff(f+1) = diff;
                        sr.dot.dstRectDot(f+1,:) = sr.dot.dstRectDot(f,:);
                        
                        thisWaitTime = p.scr.dotDur - diff -(0.5 *p.scr.flipInterval);
                        loopCounterTrack(f,2) = thisWaitTime;
                        loopOn = 0; % go to next trial
                    else
                        % dot duration within trial
                        dotContinues = 0;
                        thisWaitTime = sr.time.dotOff(f)-sr.time.dotOn(f) -(0.5 *p.scr.flipInterval);
                        loopCounterTrack(f,2) = thisWaitTime;
                    end
                    
                case 3
                    thisWaitTime = p.scr.stimDur -sr.time.dotOff(f) -(0.5 *p.scr.flipInterval);
                    loopCounter = loopCounter +1;
                    loopOn = 0;
                    loopCounterTrack(f,3) = thisWaitTime;
            end
        else
            loopCounterTrack(f,1) = thisWaitTime;
            loopOn = 0;
            thisWaitTime = p.scr.stimDur - (.5 *p.scr.flipInterval);
        end
        
        Screen('DrawingFinished', p.scr.window);
        % WaitSecs(thisWaitTime);
        
        % FLIP
        [vbl] = Screen('Flip', p.scr.window, vbl+thisWaitTime);
        sr.time.trialEvents(f, loopCounter) = vbl - sr.time.seriesStart;
        
        % %         % get trial start time
        % %         if ff ==1
        % %             sr.time.trialStart(ff) = vbl;
        % %         end
        
        % START POLICING FIXATION
        if p.useEyelink == 1
            
            % SEND MESSAGE to EYETRACKER .edf file
            if regularSeries
                messageText = strcat('SERIES_',num2str( sr.number),'_TRIAL_START',num2str(f),'_FlashON_PredQUAD_', num2str(thisPred), '_AttnQUAD_', num2str(thisCue) );
            else
                messageText = strcat( 'SERIES',num2str( sr.number),'TRIAL_START', num2str(f));
            end
            Eyelink('Message', messageText);
            monitorFixation( p, sr, thisWaitTime);
            %         else
            %             WaitSecs( thisWaitTime);
        end

        %     if p.useEyelink %CHECK
        %         Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
        %     end
        %end
        [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
        sr.dot.missed(f) = 1;  % default
        
        if  f>2 && ~isempty(event)  && ( event.Keycode == KbName('space')) && ~checked(f) %f >= 2 && ~isempty(event) % event.Pressed == 1
            
            sr.dot.response(f) = 1;
            
            if sr.dot.series(f)    % this trial had a dot
                sr.dot.responseCorrect(f) = 1;
                sr.dot.missed(f) = 0;
                sr.RT(f) = event.Time - sr.time.trialEvents(f,1);%sr.time.dotOn(f);
                checked(f:f+2) = 1;
                
                % play positive beep
                PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepHappy);
                PsychPortAudio('Start', p.audio.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
                PsychPortAudio('Stop', p.audio.handle, 1);
                
            elseif sr.dot.series(f-1)  % previous trial had a dot
                sr.dot.responseCorrect(f-1) = 1;
                sr.dot.missed(f-1) = 0;
                sr.RT(f-1) = event.Time - sr.time.trialEvents(f,1); %sr.time.dotOn(f-1);
                checked( f: f+1) = 1;
                
                % play positive beep
                PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepHappy);
                PsychPortAudio('Start', p.audio.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
                PsychPortAudio('Stop', p.audio.handle, 1);
                
            elseif sr.dot.series(f-2)  % previous trial had a dot
                sr.dot.responseCorrect(f-2) = 1;
                sr.dot.missed(f-2) = 0;
                sr.RT(f-2) = event.Time - sr.time.trialEvents(f,1); %sr.time.dotOn(f-2);
                checked(f) = 1;
                
                % play positive beep
                PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepHappy);
                PsychPortAudio('Start', p.audio.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
                PsychPortAudio('Stop', p.audio.handle, 1);
            else
                sr.dot.FA(f-2) = 1;
                % play negative beep
                PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);
                PsychPortAudio('Start', p.audio.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
                PsychPortAudio('Stop', p.audio.handle, 1);
                
            end
            
            % clear old queue and start next one
            KbQueueRelease();   %KbQueueFlush([],3); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
            event = [];
            KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
            KbQueueStart();   %% KbQueueStart([deviceIndex])
        end
    end
    % PROBE ADJUST check for response on trial f-1
    if staircase
        tic
        if f > 2 && sr.dot.series( f-2) == 1 % check if correct/no response on trial n-1
            
            ktrial = ktrial + 1; % update staircase probe counter
            r = 0; % reset default response to zero
            if sr.dot.responseCorrect( f-2) == 1
                r = 1;  % get response for staircase routine
            end
            
            stair.process_resp(r); % convert to logical type; process response
            
            % check timing of  next probe routine
            sr.time.probeStart(f) = GetSecs; % just to check time of calculation
            [thisProbe,entexp,rot_i]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
            sr.time.probeEnd(f) = GetSecs;
            sr.time.probeDur(f) = sr.time.probeEnd(f) - sr.time.probeStart(f);
            %                 fprintf('response: %d\n',r);
            %                 fprintf('%d, new sample point: %f\nexpect ent: %f\n', ...
            %                     ktrial,thisProbe,entexp(rot_i));
            %
        end
        toc
    end
    
    % call question routine
    if regularSeries
        if uint8( any( thisQuestionSet == f)) % Question re 'next screen': uses Colored Ring
            %%%[sr] = askQuestion( p, sr, f, 0);  % (p, sr, f, useText=1)
            
            %% INSERT QUESTION
            
            % possible next-screens
            rotationSet = 0:3;
            % initialize
            found = 0;
            rot_i = 0; % index for rotation
            
            % stop to signal upcoming question
            WaitSecs(0.7);
            
            while ~found
                
                circleTime = GetSecs;
                
                KbQueueCreate();
                KbQueueStart();
                
                % Draw  fixation cross without cue and Gratings
                %Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
                Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, paramsGauss');
                Screen('DrawTextures', p.scr.window, sineTex, [], dstRectGrats, angleSet, [], [], ...
                    [], [], [], paramsGrats);
                
                % which quad circle appears in and adjust thisRect
                thisQuad = mod( rot_i, length( rotationSet))+1;  % mod rotates but have to add +1 to avoid index of zero
                thisRect = dstRectGrats(:,thisQuad)';
                Screen('FrameOval', p.scr.window, [255,0,0], thisRect, 1.8,[]);
                
                Screen('Flip', p.scr.window);
                WaitSecs(0.3)   % IFF movie doesn't keep running
                %end % movie keeps running
                
                [event, ~] = KbEventGet( [], 0.001); % CHECK how to suppress output ([device], [wait time])
                if  ~isempty(event) && event.Pressed == 1 && found == 0 % there was a keyPress and this is the downPress
                    
                    if strcmp( KbName(event.Keycode), 'Return')
                        question.responseQuad(f) = thisQuad;
                        question.responseCorrect(f) = ( thisQuad == sr.pred.series(f-(p.series.chunkLength-1)) );
                        if question.responseCorrect(f) == 1
                            %display('Correct');
                        else
                            % display('Not correct, Should be:');
                            sr.pred.series(f-(p.series.chunkLength-1))
                        end
                        
                        question.RT(f) = event.Time - circleTime; % minus stim onset
                        question.chunkNum(f) = sr.pred.trackerByChunk(f);
                        question.elementNum(f) = sr.pred.trackerByElement (f);
                        found = 1; % get out of loop
                        
                    elseif strcmp( KbName(event.Keycode), 'space')
                        rot_i = rot_i+1;
                    end
                    
                    KbQueueStop();  % KbQueueStop([deviceIndex])   %[secs, keyCode, deltaSecs] = KbPressWait; % [secs, keyCode, deltaSecs] = KbPressWait([deviceNumber][, untilTime=inf][, more optional args for KbWait]);   % event = KbEventGet();
                    KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
                    KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
                end
            end
        end
        %% END QUESTION
        WaitSecs(1.0);
    end % end question routine
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',sr.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
end % end of trial f-loop

loopCounterTrack(:,4) = nansum( loopCounterTrack(:,1:3),2);
loopCounterTrack;

sr.time.trialStart = sr.time.trialEvents(:,1);
sr.time.trialDur= sr.time.trialStart(2:end) - sr.time.trialStart(1:end-1);

% record series times
sr.time.seriesEnd = GetSecs;
sr.time.seriesDur = sr.time.seriesEnd - sr.time.seriesStart;

% save probe for regular series
p.scr.thisProbe = thisProbe;

% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('SeriesEND_%d',sr.number);
    Eyelink('message', messageText)
end

% STAIRCASE: RESULTS
if staircase
    [sr.PSEfinal, sr.DLfinal, loglikfinal]  = stair.get_PSE_DL();
    finalent                        = sum(-exp(loglikfinal(:)).*loglikfinal(:));
    fprintf('final estimates:\nPSE: %f\nDL: %f\nent: %f\n',sr.PSEfinal, sr.DLfinal, finalent);
    sr.dot.intFactor = sr.PSEfinal; % scales dot intensity in main experiment
end

% CALCULATE HITS, misses, FAs for report
sr.dot.totalNum = numel( sr.dot.series( sr.dot.series==1));
sr.dot.hitNum = numel(sr.dot.responseCorrect(sr.dot.responseCorrect ==1)); %int8( (v1 + v2) > 0 );
sr.dot.FANum = numel(sr.dot.FA(sr.dot.FA ==1));
sr.dot.missedNum = sr.dot.totalNum - sr.dot.hitNum;

if sr.dot.hitNum > 0
    sr.dot.hitRate = sr.dot.hitNum / sr.dot.totalNum;
else
    sr.dot.hitRate = 0;
end

if regularSeries
    % calculate question results
    sr.question.numCorrect = length(find( sr.question.responseCorrect == 1));
    sr.question.ratioCorrect = sr.question.numCorrect ./ numel(thisQuestionSet);
end

end

