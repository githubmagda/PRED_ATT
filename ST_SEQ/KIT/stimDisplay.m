function[p, sr] = stimDisplay(p, sr, type)

if strcmp(type, 'regularSeries')
    regularSeries = 1;
    staircase = 0;
end
if strcmp(type, 'staircase')
    staircase = 1;
    regularSeries = 0;
end

% This script displays stimulus sequence for 'type', e.g. staircase or main
% experiment
% the predictive per-quadrant white-screen flashes and ocassional attentional dot
% Inputs include the predictive and attn series included in series
% structure

% TEXTURES
texGrat = p.textures.texGrat;               % main texture
texGratFlash = p.textures.texGratFlash;     % texture with predictive element
gaus_attn_tex = p.textures.gaus_attn_tex;   % attentional dot
gaus_fix_tex = p.textures.gaus_fix_tex;     % fixation gaussian

if regularSeries
    % determine x/y positions for red circle for question
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
            %         circleXPos = p.circleXPosLeft;  % position of red circle in quad
            %         circleYPos = p.circleYPosTop;
        case 2
            attn = p.scr.attn2;
            fixCoords = p.scr.fixCoords2;
            %         circleXPos = p.circleXPosRight;
            %         circleYPos = p.circleYPosTop;
        case 3
            attn = p.scr.attn3;
            fixCoords = p.scr.fixCoords3;
            %         circleXPos = p.circleXPosRight;
            %         circleYPos = p.circleYPosBottom;
        case 4
            attn = p.scr.attn4;
            fixCoords = p.scr.fixCoords4;
            %         circleXPos = p.circleXPosLeft;
            %         circleYPos = p.circleYPosBottom;
    end
else
    fixCoords = p.scr.fixCoords0;
    thisCue = randi(4,1);
end

% DRAW PRE-SERIES FIXATION GUASSIAN w/ ATTENTION CUE
% Draw gaussian
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]

% Draw cue fixation cross with red arm pointing to attentional quadrant
if staircase
    % Draw cue fixation cross (NO attentional pointer 'p.scr.attn0'
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
else
    % Draw cue fixation cross with attentional pointer 'attn' (set above)
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, attn, [ p.scr.centerX, p.scr.centerY ], 2);
end

% Draw smaller center dot
Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );

% FLIP
Screen('Flip', p.scr.window);
% END DRAW PRE-SERIES FIXATION GUASSIAN

% SEND MESSAGE to EYETRACKER .edf file
if p.useEyelink                                                                                                                                   117
    messageText = strcat( 'STAIRCASE_PRE-SERIES FIXATION', num2str(sr.number));
    Eyelink( 'Message', messageTest);
end

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation( p, sr);
else
    WaitSecs( p.preSeriesFixTime); % cue w/without attentional cross
end
% END POLICING FIXATION

% DISPLAY SEQUENCE
% initialize timing and response vectors
sr.time.trialStart      = nan( 1, p.series.stimPerSeries );
sr.time.trialEnd        = nan( 1, p.series.stimPerSeries);
sr.time.flashOn         = nan( 1, p.series.stimPerSeries);
sr.time.flashOff        = nan( 1, p.series.stimPerSeries);
sr.time.dotOn           = nan( 1, p.series.stimPerSeries);
sr.time.dotOff          = nan( 1, p.series.stimPerSeries);
sr.time.lastScreen      = nan( 1, p.series.stimPerSeries);

sr.dot.posX             = nan( 1, p.series.stimPerSeries );                % dot position and timing
sr.dot.posY             = nan( 1, p.series.stimPerSeries );

sr.dot.response         = nan( 1, p.series.stimPerSeries );             % dot response
sr.dot.responseCorrect  = nan( 1, p.series.stimPerSeries );
sr.dot.FA               = nan( 1, p.series.stimPerSeries );
sr.dot.responsekeyCode  = nan( 1, p.series.stimPerSeries );
sr.dot.RT               = nan( 1, p.series.stimPerSeries );
sr.dot.quad             = nan( 1, p.series.stimPerSeries );

if regularSeries
    sr.question.responseQuad = nan( 1, p.series.stimPerSeries );
    sr.question.responseCorrect = nan( 1, p.series.stimPerSeries );
    sr.question.RT = nan( 1, p.series.stimPerSeries );
    sr.question.chunkNum = nan( 1, p.series.stimPerSeries );
    sr.question.elementNum = nan( 1, p.series.stimPerSeries );
    
    % SELECT QUESTION TRIALS % N.B. not trial with dot or subsequent trial
    dot = find( sr.dot.series == 1);
    questionSet = find( sr.pred.trackerByElement > 0);  % number of elements in sequence already viewed
    questionSet = Shuffle( setdiff(questionSet,dot));
    thisQuestionSet = questionSet( 1:p.series.questionNum);
    sr.question.trialNumbers = thisQuestionSet;         % record subSet
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
    
    ktrial = 0; % set counter for dot probes
    %%%firstDotPos = find(sr.dot.series,1);
    [thisProbe, ~, ~]  = stair.get_next_probe();
    
end % STAIRCASE END

% START KEYBOARD QUEUES - reset below in trial loop
KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
KbQueueStart();   %% KbQueueStart([deviceIndex])

% SERIES START MESSAGES
sr.time.seriesStart = GetSecs;

% send message to EYETRACKER .edf file
if p.useEyelink
    messageText = strcat('SERIES_START', num2str(sr.number));
    Eyelink('message', messageText)
end

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    % predictive FLASH
    if regularSeries
        thisPred = sr.pred.series(f);           %  quadrant where flash will appear
        thisRotation = ( thisPred-1 ) * 90;     % rotation factor to put flash in correct quadrant
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
        
        % get location of occasional dot using random selection from
        % quadrant specified;then randomly choose pair of x,y coordinates for dot from rowDotSet/colDotSet
        pos = randi( length( rowDotSet), 1);
        sr.dot.posX(f) = colDotSet( pos);
        sr.dot.posY(f) = rowDotSet( pos);
        
        % dimensions of dot
        dotXStart = sr.dot.posX(f) - round( p.scr.dotGridRadiusPix ); % set to size of gaussian grid
        dotXEnd = sr.dot.posX(f) + round( p.scr.dotGridRadiusPix );
        dotYStart = sr.dot.posY(f) - round( p.scr.dotGridRadiusPix );
        dotYEnd = sr.dot.posY(f) + round( p.scr.dotGridRadiusPix );
    end
    
    % DRAW TEXTURES % IF REGULAR SERIES PUT FLASH ON
    if regularSeries
        Screen('DrawTexture', p.scr.window, texGratFlash(1), [], [], thisRotation); % PREDICTIVE flash ON  [rotate] = angle in degrees        
    else
        Screen('DrawTexture', p.scr.window, texGrat(1), [], [], []); % no flash 
    end
    
    % DRAW fixation gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center dot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    %Screen('DrawTexture',p.scr.window, gaus_fix_texSmall,[],[],[],[],[],[p.scr.white]) % [p.scr.fixColorChange]
    
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
    
    % get trial times
    trialStart = flip;
    sr.time.trialStart(f) = trialStart;
    if regularSeries
        sr.time.flashOn(f) = trialStart;
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
    
    if f > 1
        timePassed = GetSecs - sr.time.lastScreen(f);
    else 
        timePassed = GetSecs - trialStart;
    end
    
    if regularSeries
        WaitSecs( p.scr.flashDur );% -timePassed -0.5*p.scr.flipInterval);
    else 
        WaitSecs( p.scr.flashDur +p.scr.postFlashDur  +p.scr.dotJitter*( randi( 20,1))); % -timePassed -0.5*p.scr.flipInterval);
    end
    
    % routine for if eyes wander away change center dot and attn pointer to red
    if p.useEyelink && fr.outOfBounds
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, attn, [ p.scr.centerX, p.scr.centerY ], 2);
        Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        % send message to .edf file
        messageText = ['gazeOutOfBounds_', 'SERIES_',num2str(sr.number),'_TRIAL_START',num2str(f), '_PredQUAD_', num2str(thisPred), '_AttnQUAD_', num2str(thisCue)];
        Eyelink('message',messageText);
    end
    
    if regularSeries
        % DRAW TEXTURES FLASH OFF
        Screen('DrawTexture', p.scr.window, texGrat(1));  
        %%%Screen('DrawTexture', p.scr.window, texGrat(1), [], [], thisRotation); % flash on  [rotate] = angle in degrees
        % DRAW fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center dot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        sr.time.flashOff(f)
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat(['SERIES',num2str(sr.number), 'TRIAL',num2str(f),'_FlashOFF_PredQUAD_', num2str(thisPred), '_AttnQUAD_', num2str(thisCue) ]);
            Eyelink('message', messageText);
        end
        
        % time on screen
        timePassed = GetSecs -sr.time.flashOn(f);
        
        if sr.dot.series == 1                       % only wait only dot appears
            WaitSecs( p.scr.postFlashDur +p.scr.dotJitter*( randi( 30,1) * .01)); % -timePassed -0.5*p.scr.flipInterval);
        else                                        % wait until end of trial 
            WaitSecs( p.scr.stimDur -timePassed -0.5*p.scr.flipInterval)
        end       
    end
    
    % DRAW TEXTURES DOT ON
    if sr.dot.series(f) == 1
       
        Screen('DrawTexture', p.scr.window, texGrat(1), [], [], []); % flash off
     
        %% DRAW fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center spot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % attention DOT
        if regularSeries
            Screen('DrawTexture', p.scr.window, gaus_attn_tex(p.scr.dotIntFactor), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
        elseif staircase 
            sr.thisProbe(f) = thisProbe;
            Screen('DrawTexture', p.scr.window, gaus_attn_tex(thisProbe), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
        end
        
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        sr.time.dotOn(f) = flip;
        
        if p.useEyelink
            messageText = strcat(['SERIES_',num2str(sr.number), 'TRIAL_',num2str(f),'DotON_PosX: ',dotXStart,'-',dotXEnd, '_PosY: ',dotYStart, '-', dotYEnd]);
            Eyelink('message',messageText);
        end
        
        timePassed = GetSecs - sr.time.dotOn(f);
        WaitSecs( p.scr.dotDur); % -timePassed -0.5*p.scr.flipInterval);
        
        % DRAW TEXTURES % DOT OFF
        Screen('DrawTexture', p.scr.window, texGrat(1), [], [], []); % flash on  [rotate] = angle in degrees
        % Draw fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center spot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
         
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        sr.time.dotOff(f) = flip;
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat('Series_',num2str(sr.number), '_TRIAL_',num2str(f),'DotOFF_PosX: ',dotXStart,'-',dotXEnd, '_PosY: ',dotYStart, '-', dotYEnd);
            Eyelink('message', messageText);
        end
        timePassed = GetSecs - trialStart;
        WaitSecs( p.scr.stimDur); % - timePassed - .5*p.scr.flipInterval);
        
    end
    sr.time.lastScreen(f) = GetSecs; % just to capture timing without trial final calculations
    
    if p.useEyelink %CHECK
        Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
    end
    
    [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
      
    if  f>1 && ~isempty(event) && event.Keycode == KbName('space') %f >= 2 && ~isempty(event) % event.Pressed == 1
        
        sr.dot.response(f) = 1;
        
        if sr.dot.series(f)    % this trial had a dot
            sr.dot.responseCorrect(f) = 1;
            sr.RT(f) = event.Time - sr.time.dotOn(f);
            % play positive beep           
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
            
        elseif sr.dot.series(f-1)  % previous trial had a dot
            sr.dot.responseCorrect(f-1) = 1;
            sr.RT(f) = event.Time - sr.time.dotOn(f-1);
            
            else
            sr.dot.FA(f) = 1;
        end
            
        if sr.dot.responseCorrect(f) ==1 || sr.dot.responseCorrect(f-1)==1
            % play positive beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
            
        elseif sr.dot.FA(f)
            % play negative beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
        end
        
        
%       % clear old queue and start next one
        KbQueueRelease();   %KbQueueFlush([],3); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
        event = [];
        KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
        KbQueueStart();   %% KbQueueStart([deviceIndex])

    end
    
    % PROBE ADJUST check for response on etiher trial f-1 OR f-2
    
    if f > 1 && sr.dot.series( f-1) == 1 % check for correct/no response on trial n-1
        
        if staircase
            
            ktrial = ktrial + 1; % update staircase probe counter
            
            if sr.dot.responseCorrect( f-1) == 1
                r = 1;  % get response for staircase routine
            else
                r = 0; % reset default
            end
            
            stair.process_resp(r); % convert to logical type; process response
            
            % check timing of fetch next probe routine
            sr.time.probeStart(f) = GetSecs; % just to check time of calculation
            [thisProbe,entexp,ind]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
            %sizeAdj = thisProbe;
            sr.time.probeEnd(f) = GetSecs;
            sr.time.probeDur(f) = sr.time.probeEnd(f) - sr.time.probeStart(f);
            fprintf('response: %d\n',r);
            fprintf('%d, new sample point: %f\nexpect ent: %f\n', ...
                ktrial,thisProbe,entexp(ind));
        end % probe and response 'if clause'
        beepSounded = 0; % reset for next dot
    end
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',sr.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
    
    
    % % % end  % end of trial f-loop
    % % % sr;
    
    % % % KbQueueStop(); %%     KbQueueStop([deviceIndex])
    % % % [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
    % % %
    % % % if  ~isempty(event)             % event.Pressed == 1
    % % %     sr.dot.response(f) = 1;
    % % %     if sr.dot.series(f) == 1
    % % %         sr.RT(f) = event.Time - sr.dot.time(f);
    % % %         sr.dot.responseCorrect(f) = 1;
    % % %     elseif f>1 && sr.dot.series(f-1) == 1
    % % %         sr.dot.RT(f) = event.Time - sr.dot.time(f-1);
    % % %         sr.dot.responseCorrect(f) = 1;
    % % %     else
    % % %         sr.dot.RT(f) = NaN;
    % % %     end
    % % %     sr.dot.responsekeyCode(f) = event.Keycode;
    % % %     KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
    % % %     KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
    % % % end
    % % %
    % % % if sr.dot.response(f) % CORRECT RESPONSE? PLAY APPROP SOUND
    % % %     if sr.dot.series(f) == 1  || (f>1 && sr.dot.series(f-1) == 1)    %%f > 1 && ~tr.beep && ~( sr.dot.series(f) == 1 || (f>1 && sr.seriesDot(f-1) == 1))
    % % %         % play positive beep
    % % %         PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
    % % %         PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    % % %         PsychPortAudio('Stop', p.aud.handle, 1);
    % % %     else
    % % %         %play negative beep
    % % %         PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
    % % %         PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    % % %         PsychPortAudio('Stop', p.aud.handle, 1);
    % % %     end
    % % % end
    
    % call question routine
    if regularSeries
        if uint8( any( thisQuestionSet == f)) % Question re 'next screen': uses Colored Ring
            [sr] = askQuestion( p, sr, f, 0);  % (p, sr, f, useText=1)
            WaitSecs(1.0);
        end % end question routine
    end
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',sr.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
    
    % get trial timings and add to series structure
    sr.time.trialEnd(f) = GetSecs;
    sr.time.trialDur(f) = sr.time.trialEnd(f) - sr.time.trialStart(f);
end  % end of trial f-loop

% record series times
sr.time.seriesEnd = GetSecs;
sr.time.seriesDuration = sr.time.seriesEnd - sr.time.seriesStart;

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
    p.scr.dotIntFactor = sr.PSEfinal;
end

% CALCULATE HITS, misses, FAs for report
sr.dot.totalNum = numel( sr.dot.series( sr.dot.series==1));
sr.dot.hitNum = numel(sr.dot.responseCorrect(sr.dot.responseCorrect ==1)); %int8( (v1 + v2) > 0 );
sr.dot.FANum = numel(sr.dot.FA(sr.dot.FA ==1));
sr.dot.missedNum2 = sr.dot.totalNum - sr.dot.hitNum;

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

