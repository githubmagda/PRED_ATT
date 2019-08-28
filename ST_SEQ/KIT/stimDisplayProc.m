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

fixRadius = p.scr.fixRadius;
virtualSizeGauss = fixRadius *2;

% Initial stimulus params for the smooth sine grating:
virtualSizeGrat = p.scr.gratRadius *2;

backgroundColorOffset   = [.5 .5 .5 0];
phaseGrat               = 0;          % starting value
freqGrat                = .11;        % see paper by Martin Vinck
tiltGrat                = 45;       % set below in trial loop
contrastGrat            = 1.5;        % 0.5;  changes 'brightness'

% radius of the disc edge
radiusGrat              = virtualSizeGrat /2;
% smoothing sigma in pixel
sigmaGrat               = 55;
% use alpha channel for smoothing?
useAlpha                =   true;     % ignored
% smoothing method: cosine (0) or smoothstep (1)
smoothMethod            = 1;          % ignored          


% MAKE TEXTURES
[sineTex, sineTexRect] = CreateProceduralSmoothedApertureSineGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat,...
          backgroundColorOffset, radiusGrat, [], sigmaGrat, useAlpha, smoothMethod);
[gaussTex, gaussTexRect]    = CreateProceduralGaussBlob( p.scr.window , virtualSizeGauss, virtualSizeGauss,...
    backgroundColorOffset, [],[]);
%[gratTex, gratTexRect]      = CreateProceduralSineGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat, p.scr.backgroundColorOffsetGrat, p.scr.gratRadius, p.scr.contrastPreMultiplicatorGrat);

% determining scaling of displays 
fixScale                    = 1;               % scale of  adjustmentd to gaussians in 'DrawTexture'
fixInnerScale               = 0.25;

dstRectFix                  = OffsetRect(gaussTexRect*fixScale,      p.scr.centerX-(fixRadius*fixScale), p.scr.centerY-(fixRadius*fixScale));
dstRectFixInner             = OffsetRect(gaussTexRect*fixInnerScale, p.scr.centerX-(fixRadius*fixInnerScale), p.scr.centerY -(fixRadius*fixInnerScale));

% angles for staircase and regular series
angleSetRegular                            = 1:6:180;
predAngle                                   = 15;
angleSetPred = angleSetRegular;
angleSetPred(angleSetPred == any((predAngle-6:predAngle+6)))=[];   % remove predAngles +- 10 degrees;

% CALCULATE GRATING QUAD positions
left                = p.scr.centerX -sineTexRect(3)/2 -p.scr.gratPosSide ;
right               = p.scr.centerX -sineTexRect(3)/2 +p.scr.gratPosSide ;
top                 = p.scr.centerY -sineTexRect(4)/2 -p.scr.gratPosSide ;
bottom              = p.scr.centerY -sineTexRect(4)/2 +p.scr.gratPosSide ;
p.scr.offsetXSet    = [ left, right, right, left];
p.scr.offsetYSet    = [ top, top, bottom, bottom];

% END GRATING

% START QUESTION

if regularSeries
    % determine x/y positions for red circle for question re upcoming dot
    p.circleXPosLeft = p.scr.centerX - ceil( p.scr.rectGrating(3)/2);   % - p.scr.gratPosPix/2; % size of quad minus 1/2 grating box minus
    p.circleXPosRight = p.scr.centerX + ceil( p.scr.rectGrating(3)/2);  % - p.scr.gratPosPix/2; % size of quad minus 1/2 grating box minus
    p.circleYPosTop = p.scr.centerY - ceil( p.scr.rectGrating(4)/2);    % - p.scr.gratPosPix/2;
    p.circleYPosBottom = p.scr.centerY + ceil( p.scr.rectGrating(4)/2); % - p.scr.gratPosPix/2;
    
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
% END QUESTION

% DRAW PRE-SERIES FIXATION GUASSIAN w/ ATTENTION CUE

% FLIP
[vbl] = Screen('Flip', p.scr.window, 0);
thisWaitTime = p.preSeriesFixTime - (.9 *p.scr.flipInterval);

% % % Screen('DrawTexture', p.scr.window, gaussFixTex, [], [], [], [], [], [], [], 2, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
% % % %Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]

% Draw plain or cue fixation cross with red arm pointing to attentional quadrant
if staircase
    
    % Draw  fixation cross without cue : dark cross two nested white gaussians
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1; p.scr.fixInnerContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]');

else
    % Draw cue fixation cross with attentional pointer 'attn' (set above)
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1; p.scr.fixInnerContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]');
end

Screen('DrawingFinished', p.scr.window);

% FLIP
Screen('Flip', p.scr.window);
% END DRAW PRE-SERIES FIXATION GUASSIAN

% SEND MESSAGE to EYETRACKER .edf file
if p.useEyelink                                                                                                                                   117
    messageText = strcat( 'STAIRCASE_PRE-SERIES FIXATION', num2str(sr.number));
    Eyelink( 'Message', messageText);
end

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation( p, sr, p.preSeriesFixTime);
else
    WaitSecs( p.preSeriesFixTime); % cue w/without attentional cross
end
% END POLICING FIXATION

% DISPLAY SEQUENCE
% initialize timing and response vectors
sr.time.trialSetup      = nan( 1, p.series.stimPerSeries);
sr.time.trialStart      = nan( 1, p.series.stimPerSeries);
sr.time.trialEnd        = nan( 1, p.series.stimPerSeries);
sr.time.flashOn         = nan( 1, p.series.stimPerSeries);
sr.time.flashOff        = nan( 1, p.series.stimPerSeries);
sr.time.dotOn           = nan( 1, p.series.stimPerSeries);
sr.time.dotOff          = nan( 1, p.series.stimPerSeries);
sr.time.lastScreen      = nan( 1, p.series.stimPerSeries);
sr.time.dotJitter       = nan( 1, p.series.stimPerSeries);
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
    % INITIALIZE STAIRCASE (see MinExpEntStairDemo in Testing or Psychtoolbox)
    % stair input
    probeset    = 1 : 1 : 20; % -15:0.5:15;         % set of possible probe values
    meanset     = 1 : 1 : 20 ;% -10:0.2:10;         % sampling of pses, doesn't have to be the same as probe set
    slopeset    = [.1:.1:5].^2;%[.5:.1:5].^2;       % set of slopes, quad scale
    lapse       = 0.05;                             % lapse/mistake rate
    guess       = 0.50;                             % guess rate / minimum correct response rate (for detection expt: 1/num_alternative, 0 for discrimination expt)
    
    % STAIRCASE: general settings
    ntrial  = length( sr.dot.series( sr.dot.series == 1));
    sr.time.probeStart = nan( 1, ntrial);
    sr.time.probeEnd = nan( 1, ntrial);
    sr.time.probeDur = nan( 1, ntrial);
    
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
    stair.toggle_use_resp_subset_prop( 5,.7); % STAIRCASE: %( 10,.9);
    
    % STAIRCASE: set value for first probe based on probeset values
    first_value = probeset( round( length( probeset) /2));   % STAIRCASE: MA set to mode of probeset
    stair.set_first_value( first_value);  % STAIRCASE: stair.set_first_value(3);
    
    ktrial = 1; % set counter for dot probes
    [thisProbe, ~, ~]  = stair.get_next_probe();
    
end % STAIRCASE END

% START KEYBOARD QUEUE - reset below in trial loop
KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
KbQueueStart();   %% KbQueueStart([deviceIndex])

% SERIES START MESSAGE
sr.time.seriesStart = GetSecs;

% send message to EYETRACKER .edf file
if p.useEyelink
    messageText = strcat('SERIES_START', num2str(sr.number));
    Eyelink('message', messageText)
end

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    sr.time.trialSetup(f) = GetSecs;
    sr.dot.jitter(f) = p.scr.dotJitter * (randi(20, 1)); % in case dot is shown, estalbish jitter for this trial (used to calculate screen times)
    
    % if REGULAR SERIES: predictive FLASH
    if regularSeries
        thisPred = sr.pred.series(f);           %  quadrant where flash will appear
        %thisRotation = ( thisPred-1 ) * 90;     % rotation factor to put flash in correct quadrant
    end
    
    if sr.dot.series(f) == 1 % PREPARE DOT
        
        if regularSeries % dot placement determined by attentional cue and cue validity
            
            % DOT POSITION - is  dot in attentional quad 'VALID'?
            selEl = randi(10,1);                    % 1 in 10 probability
            if selEl <= ( p.scr.cueValidPerc*10)    % e.g. xx% likelihood
                sr.dot.valid(f) = 1;
                dotQuad = thisCue;
            else
                sr.dot.Valid(f) = 0;
                ShuffleSet = Shuffle(setOther);     % select next random position (not including cued position)
                dotQuad = ShuffleSet(1);            % random allocation to any other quad
            end
        else
            dotQuad = randi(4,1);           % random quad selection
        end
        
        sr.dot.quad(f) = dotQuad;
        
        switch dotQuad                          % xy coordinates for dot in specified quadrants 1:4
            case 1
                rowDotSet = p.scr.rowDotSet1;
                colDotSet = p.scr.colDotSet1; % defines set of possible dot locations
            case 2
                rowDotSet = p.scr.rowDotSet2;
                colDotSet = p.scr.colDotSet2;
            case 3
                rowDotSet = p.scr.rowDotSet3;
                colDotSet = p.scr.colDotSet3;
            case 4
                rowDotSet = p.scr.rowDotSet4;
                colDotSet = p.scr.colDotSet4;
        end
        
        % get location of occasional dot using random selection wihtin
        % specified quadrant;then randomly choose pair of x,y coordinates for dot from rowDotSet/colDotSet
        pos = randi( length( rowDotSet), 1);
        sr.dot.posX(f) = colDotSet( pos);
        sr.dot.posY(f) = rowDotSet( pos);
        
        % dimensions of dot
        dotXStart = sr.dot.posX(f) - round( p.scr.dotGridRadiusPix ); % set to size of gaussian grid
        dotXEnd = sr.dot.posX(f) + round( p.scr.dotGridRadiusPix );
        dotYStart = sr.dot.posY(f) - round( p.scr.dotGridRadiusPix );
        dotYEnd = sr.dot.posY(f) + round( p.scr.dotGridRadiusPix );
    end
    
    % DRAW TEXTURES % IF REGULAR SERIES: Change angle
    dstRectGrats    = OffsetRect( sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet'); 
    Params          = repmat([phaseGrat+180, freqGrat, contrastGrat, 0], 4, 1)';
    Angles          = repmat(angleSetPred, 4, 1);

    if regularSeries
        
        Angles(thisPred) = p.scr.angleSet(2);        
        %timePrep(f) = GetSecs;
        
        % Draw the gratings
        Screen('DrawTextures', p.scr.window, gratTex, [], dstRectGrats', Angles, [], [], ...
            [], [], [], Params);
        %Screen('DrawTexture', p.scr.window, texGratFlash, [], [], thisRotation); % PREDICTIVE flash ON  [rotate] = angle in degrees
    else % staircase
        Screen('DrawTextures', p.scr.window, gratTex, [], dstRectGrats', Angles, [], [], ...
            [], [], [], Params);
        %Screen('DrawTexture', p.scr.window, texGrat, [], [], []); % no flash
    end
    
% % %     % DRAW fixation gaussian
% % %     Screen('DrawTexture', p.scr.window, gaussFixTex, [], [], [], [], [], [], [], 2, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
% % %     %Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
% % %     % Draw the cue fixation cross
% % %     Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
% % %     % Draw smaller center dot
% % %     Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
% % %     % Screen('DrawTexture',p.scr.window, gaus_fix_texSmall,[],[],[],[],[],[p.scr.white]) % [p.scr.fixColorChange]
% % %     
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
    
    % get trial times
    sr.time.trialStart(f) = vbl;
    if regularSeries
        sr.time.flashOn(f) = vbl;
    end
    
    % SEND MESSAGE to EYETRACKER .edf file
    if p.useEyelink
        if regularSeries
            messageText = strcat('SERIES_',num2str( sr.number),'_TRIAL_START',num2str(f),'_FlashON_PredQUAD_', num2str(thisPred), '_AttnQUAD_', num2str(thisCue) );
        else
            messageText = strcat( 'SERIES',num2str( sr.number),'TRIAL_START', num2str(f));
        end
        Eyelink('Message', messageText);
    end
    
    % WAIT
    timePassed = GetSecs - vbl;
    
    if regularSeries
        WaitSecs( p.scr.flashDur -timePassed -0.5*p.scr.flipInterval);
    else % this is staircase without flash
        WaitSecs( p.scr.flashDur + p.scr.postFlashDur  +sr.dot.jitter(f) -timePassed -0.5*p.scr.flipInterval);
    end
    
    % % %     % routine for if eyes wander away change center dot and attn pointer to red
    % % %     if p.useEyelink %&& fr.outOfBounds
    % % %         Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, attn, [ p.scr.centerX, p.scr.centerY ], 2);
    % % %         Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    % % %         % send message to .edf file
    % % %         messageText = ['gazeOutOfBounds_', 'SERIES_',num2str(sr.number),'_TRIAL_START',num2str(f), '_PredQUAD_', num2str(thisPred), '_AttnQUAD_', num2str(thisCue)];
    % % %         Eyelink('message',messageText);
    % % %     end
    
    if regularSeries
        % DRAW TEXTURES PRED OFF
        Screen('DrawTexture', p.scr.window, texGrat);
        %%%Screen('DrawTexture', p.scr.window, texGrat, [], [], thisRotation); % flash on  [rotate] = angle in degrees
        % DRAW fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center dot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        sr.time.flashOff(f) = vbl;
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat(['SERIES',num2str(sr.number), 'TRIAL',num2str(f),'_FlashOFF_PredQUAD_', num2str(thisPred), '_AttnQUAD_', num2str(thisCue) ]);
            Eyelink('message', messageText);
        end
        
        % WAIT
        timePassed = GetSecs - vbl;
        if sr.dot.series(f) == 1                       % wait until dot appears
            WaitSecs( p.scr.postFlashDur + sr.dot.jitter(f) -timePassed -0.5*p.scr.flipInterval);
        else
            % wait until end of trial
            WaitSecs( p.scr.stimDur  -timePassed -0.5*p.scr.flipInterval)
        end
    end
    
    % DRAW TEXTURES DOT ON
    if sr.dot.series(f) == 1
       
        Screen('DrawTextures', p.scr.window, gratTex, [], dstRectGrats', Angles, [], [], ...
            [], [], [], Params);        
        %Screen('DrawTexture', p.scr.window, texGrat, [], [], []); % flash off
        
        %% DRAW fixation gaussian
        Screen('DrawTexture', p.scr.window, gaussFixTex, [], [], [], [], [], [], [], 2, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
        %Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center spot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % attention DOT
        if regularSeries
            Screen('DrawTexture', p.scr.window, gaussFixTex, [], [], [], [], [], [], [], 2, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
           % Screen('DrawTexture', p.scr.window, gaus_attn_tex(p.scr.dotIntFactor), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
        elseif staircase
            sr.thisProbe(f) = thisProbe;
            Screen('DrawTexture', p.scr.window, gaussFixTex, [], [], [], [], [], [], [], 2, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
            %Screen('DrawTexture', p.scr.window, gaus_attn_tex(thisProbe), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
        end
        
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        sr.time.dotOn(f) = vbl;
        
        if p.useEyelink
            messageText = strcat(['SERIES_',num2str(sr.number), 'TRIAL_',num2str(f),'DotON_PosX: ',dotXStart,'-',dotXEnd, '_PosY: ',dotYStart, '-', dotYEnd]);
            Eyelink('message',messageText);
        end
        
        timePassed = GetSecs - vbl;
        WaitSecs( p.scr.dotDur -timePassed -0.5*p.scr.flipInterval);
        
        % DRAW TEXTURES % DOT OFF
        Screen('DrawTextures', p.scr.window, gratTex, [], dstRectGrats', Angles, [], [], ...
            [], [], [], Params);
        %Screen('DrawTexture', p.scr.window, texGrat, [], [], []); % flash on  [rotate] = angle in degrees
        % Draw fixation gaussian
        Screen('DrawTexture', p.scr.window, gaussFixTex, [], [], [], [], [], [], [], 2, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
        %Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center spot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        sr.time.dotOff(f) = vbl;
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat('Series_',num2str(sr.number), '_TRIAL_',num2str(f),'DotOFF_PosX: ',dotXStart,'-',dotXEnd, '_PosY: ',dotYStart, '-', dotYEnd);
            Eyelink('message', messageText);
        end
    end
    
    if p.useEyelink %CHECK
        Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
    end
    
    [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
    sr.dot.missed(f) = 1;  % default
    
    
    if  f>2 && ~isempty(event)  && ( event.Keycode == KbName('space')) && ~checked(f) %f >= 2 && ~isempty(event) % event.Pressed == 1
        
        sr.dot.response(f) = 1;
        
        if sr.dot.series(f)    % this trial had a dot
            sr.dot.responseCorrect(f) = 1;
            sr.dot.missed(f) = 0;
            sr.RT(f) = event.Time - sr.time.dotOn(f);
            checked(f:f+2) = 1;
            
            % play positive beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
            
        elseif sr.dot.series(f-1)  % previous trial had a dot
            sr.dot.responseCorrect(f-1) = 1;
            sr.dot.missed(f-1) = 0;
            sr.RT(f-1) = event.Time - sr.time.dotOn(f-1);
            checked( f: f+1) = 1;
            
            % play positive beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
            
        elseif sr.dot.series(f-2)  % previous trial had a dot
            sr.dot.responseCorrect(f-2) = 1;
            sr.dot.missed(f-2) = 0;
            sr.RT(f-2) = event.Time - sr.time.dotOn(f-2);
            checked(f) = 1;
            
            % play positive beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
        else
            sr.dot.FA(f-2) = 1;
            % play negative beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
            
        end
        
        % clear old queue and start next one
        KbQueueRelease();   %KbQueueFlush([],3); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
        event = [];
        KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
        KbQueueStart();   %% KbQueueStart([deviceIndex])
    end
    
    % PROBE ADJUST check for response on trial f-1
    if staircase
        
        if f > 2 && sr.dot.series( f-2) == 1 % check if correct/no response on trial n-1
            
            ktrial = ktrial + 1; % update staircase probe counter
            r = 0; % reset default response to zero
            if sr.dot.responseCorrect( f-2) == 1
                r = 1;  % get response for staircase routine
            end
            
            stair.process_resp(r); % convert to logical type; process response
            
            % check timing of  next probe routine
            sr.time.probeStart(f) = GetSecs; % just to check time of calculation
            [thisProbe,entexp,ind]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
            %sizeAdj = thisProbe;
            sr.time.probeEnd(f) = GetSecs;
            sr.time.probeDur(f) = sr.time.probeEnd(f) - sr.time.probeStart(f);
            fprintf('response: %d\n',r);
            fprintf('%d, new sample point: %f\nexpect ent: %f\n', ...
                ktrial,thisProbe,entexp(ind));
            
        end
    end
    
    
    % call question routine
    if regularSeries
        if uint8( any( thisQuestionSet == f)) % Question re 'next screen': uses Colored Ring
            [sr] = askQuestion( p, sr, f, 0);  % (p, sr, f, useText=1)
            WaitSecs(1.0);
        end % end question routine
    end
    
    timePassed = GetSecs - sr.time.trialSetup(f);
    %display(['timePassed: ',num2str(timePassed)])
    WaitSecs( p.scr.stimDur - timePassed - .5*p.scr.flipInterval);
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',sr.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
    
    % final trial times
    sr.time.trialEnd(f) = GetSecs;
    sr.time.trialDur(f) = sr.time.trialEnd(f) - sr.time.trialStart(f);
    
end  % end of trial f-loop

% record series times
sr.time.seriesEnd = GetSecs;
sr.time.seriesDur = sr.time.seriesEnd - sr.time.seriesStart;

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

