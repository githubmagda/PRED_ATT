function [p, str] = stimDisplayStaircase(p, str)

% This verison of stim Display is only used for staircase. It checks for dot size that is successfully discrimated by subjectscript displays the stimulus making and displaying the 4 quadrant gratings,
% Inputs include attn series

% PRESENT STIMULI
% main textures (basic=1 and flash-white-mask=2)
texGrat = p.textures.texGrat;
% texGratFlash = p.textures.texGratFlash; % texture with predictive element
gaus_attn_tex = p.textures.gaus_attn_tex; % attentional dot
gaus_fix_tex = p.textures.gaus_fix_tex; % fixation gaussian

% DRAW PRE-SERIES FIXATION GUASSIAN

% Draw gaussian
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % 

% Draw cue fixation cross with red arm pointing to attentional quadrant
Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);

% Draw smaller center dot
Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );
%Screen('FrameOval', p.scr.window, [255,0,0], [circleXPos-p.scr.gratPosPix/2, circleYPos-p.scr.gratPosPix/2, circleXPos+p.scr.gratPosPix/2, circleYPos+p.scr.gratPosPix/2], 2,[]);

% FLIP
Screen('Flip', p.scr.window);
% END DRAW PRE-SERIES FIXATION GUASSIAN

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation(p, str);
else
    WaitSecs(p.preSeriesFixTime); % just show cross to center gaze
end

% DISPLAY SEQUENCE CHECK-ERASE???
% initialize timing and response vectors
str.time.trialStart = nan( 1, p.series.stimPerSeries );
str.time.trialEnd = nan( 1, p.series.stimPerSeries );
str.dot.response = nan( 1, p.series.stimPerSeries );
str.dot.responseCorrect = nan( 1, p.series.stimPerSeries );
str.dot.responseMissed = nan( 1, p.series.stimPerSeries );
str.dot.responsekeyCode = nan( 1, p.series.stimPerSeries );
str.dot.RT = nan( 1, p.series.stimPerSeries ); % time for correct; NaN for incorrect
str.dot.posX = nan( 1, p.series.stimPerSeries );
str.dot.posY = nan( 1, p.series.stimPerSeries );
str.time.dotOnset = nan( 1, p.series.stimPerSeries );
str.time.dotOffset = nan( 1, p.series.stimPerSeries );

str.time.seriesStart = GetSecs;

% INITIALIZE STAIRCASE (see MinExpEntStairDemo in Testing or Psychtoolbox)
% stair input
probeset    = 1 : 1 : 20; % -15:0.5:15;         % set of possible probe values
meanset     = 1 : 1 : 20 ;% -10:0.2:10;         % sampling of pses, doesn't have to be the same as probe set
slopeset    = [.1:.1:5].^2;%[.5:.1:5].^2;       % set of slopes, quad scale
lapse       = 0.05;                             % lapse/mistake rate
guess       = 0.50;                             % guess rate / minimum correct response rate (for detection expt: 1/num_alternative, 0 for discrimination expt)

% STAIRCASE: general settings
ntrial  = length( str.dot.series( str.dot.series == 1));
str.thisProbe = nan( 1, ntrial);
str.probeOnset = nan( 1, ntrial);
str.probeDur = nan( 1, ntrial);

% STAIRCASE: Create staircase instance.
stair = MinExpEntStair('v2');

% STAIRCASE:stair.init.
stair.set_use_lookup_table(true);

% option: use logistic instead of default cumulative normal. best to call
% before stair.init
%stair('set_psychometric_func','logistic');

% STAIRCASE: init stair
stair.init( probeset, meanset, slopeset, lapse, guess);

% option: use a subset of all data for choosing the next probe
stair.toggle_use_resp_subset_prop( 5,.7); % STAIRCASE: %( 10,.9);

% STAIRCASE: set value for first probe based on probeset values
first_value = probeset( round( length( probeset) /2));   % STAIRCASE: MA set to mode of probeset
stair.set_first_value( first_value);  % STAIRCASE: stair.set_first_value(3);

ktrial = 0; % set counter for dot probes
sizeAdj = first_value; % initial setting
firstDotPos = find(str.dot.series,1);
[thisProbe, ~, ~]  = stair.get_next_probe();

% END INITIALIZE STAIRCASE

% SEND MESSAGE to EYETRACKER .edf file
if p.useEyelink
    messageText = strcat('STAIRCASE_START', num2str(str.number));
    Eyelink('message', messageText)
end

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    % get times
    trialStart = GetSecs;
    str.time.trialStart(f) = trialStart;
    
    % SEND MESSAGE to EYETRACKER .edf file
    if p.useEyelink
        messageText = strcat( 'SERIES',num2str( str.number),'TRIAL_START', num2str(f));
        Eyelink( 'Message', messageText);
    end
    
    if str.dot.series(f)
        
        % DOT POSITION
        dotQuad = randi(4,1); % 1 in 10 probability
        str.dot.quad(f) = dotQuad;
        
        switch dotQuad %  x y coordinates for dot in specified quadrants 1:4
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
        % quadrant specified; then randomly choose pair of x,y coordinates for dot from rowDotSet/colDotSet
        pos = randi( length( rowDotSet), 1);
        str.dot.posX(f) = colDotSet( pos);
        str.dot.posY(f) = rowDotSet( pos);
        
        % DOT onset is in range [end of flash + 3: #Frames/2] ; dot offset set by p.dotFrameDur
        % %         str.dot.frameOnset(f) = randi([ p.scr.predScreenDur + 3, round(p.scr.framesPerMovie/2)], 1);
        % %         str.dot.frameOffset(f) = str.dot.frameOnset(f) + p.dotFrameDur; % must be less than numFrames./2
        
        % dimensions of dot CHANGES BASED ON STAIRCASE
        dotXStart = str.dot.posX(f) - round( p.scr.dotGridRadiusPix ); % set to size of gaussian grid
        dotXEnd = str.dot.posX(f) + round( p.scr.dotGridRadiusPix );
        dotYStart = str.dot.posY(f) - round( p.scr.dotGridRadiusPix );
        dotYEnd = str.dot.posY(f) + round( p.scr.dotGridRadiusPix );
    end
    
    % reset keyboard queues
    KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
    KbQueueStart();   %% KbQueueStart([deviceIndex])
    
    % % %     for ff = 1 : p.scr.framesPerMovie
    % % %
    % % %         frameNumber = ff;
    % % %         frameStart = GetSecs;
    % % %         str.time.frameStart(f, ff) = frameStart;
    % % %         % reset parameters tested in ff loop
    
    % DRAW TEXTURES PLAIN VANILLA
    Screen('DrawTexture', p.scr.window, texGrat(1), [], [], []); % flash off
    % Draw fixation gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center dot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
     
    % % %         % routine for if eyes wander away change center dot and attn pointer to red
    % % %         if p.useEyelink && fr.outOfBounds
    % % %
    % % %             Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % % %             Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    % % %             % send message to .edf file
    % % %             messageText = ['gazeOutOfBounds_', 'Series',num2str(str.number), 'Cue', thisCue, 'Pred', thisPred, 'dotTime?',str.seriesDot(f)];
    % % %             Eyelink('message',messageText);
    % % %         end
    
    % DRAW DOT
    if str.dot.series(f)        
               
        str.thisProbe(f) = thisProbe;

        % leave plain texture on screen until dot
        WaitSecs( p.scr.dotOnset - .5 * p.scr.flipInterval) 
        
        % DRAW TEXTURES DOT ON
        Screen('DrawTexture', p.scr.window, texGrat(1), [], [], []); % flash off
        % Draw fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center dot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        % Draw attention dot
        % adjust intensity
        Screen('DrawTexture', p.scr.window, gaus_attn_tex(thisProbe), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
        % adjust size - set sizeAdj to thisProbe
        %Screen('DrawTexture', p.scr.window, gaus_attn_tex(thisProbe), [], [ dotXStart-sizeAdj, dotYStart-sizeAdj, dotXEnd+sizeAdj, dotYEnd+sizeAdj ],[],[],[],p.scr.fixCrossColor); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot

        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
        if p.useEyelink
            messageText = strcat(['DotOn_PosX: ',dotXStart,'-',dotXEnd, '_PosY: ',dotYStart, '-', dotYEnd]);
            Eyelink('message',messageText);
        end    
        thisDotOnset = GetSecs;       
        WaitSecs( p.scr.dotOnset + ( p.scr.dotJitter * ( randi( 30,1) * .01)) - .5*p.scr.flipInterval);
        
        % DRAW TEXTURES DOT OFF
        Screen('DrawTexture', p.scr.window, texGrat(1), [], [], []); % flash off
        %% DRAW fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center dot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % time check
        timePassed = GetSecs - trialStart;  
        while ( timePassed < (p.scr.stimDur - .5*p.scr.flipInterval)) %wait p.scr.dotOnset seconds
            timePassed = GetSecs - trialStart ;
            WaitSecs(p.scr.flipInterval);
        end
        
    else % NO DOT - regular timing
        WaitSecs(p.scr.stimDur - .5*p.scr.flipInterval)
    end
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat(['SERIES',num2str(str.number), '_TRIAL',num2str(str.number),'_DotOff',]);
        Eyelink('message',messageText);
    end

    [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
    
    if  f >= 2 && ~isempty(event) % event.Pressed == 1
        
        KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
        KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
        
        str.dot.response(f) = 1;
        if str.dot.series(f)    % this trial had a dot
            str.dot.responseCorrect(f) = 1;
            str.RT(f) = event.Time - thisDotOnset;
        elseif str.dot.series(f-1)  % previous trial had a dot
            str.dot.responseCorrect(f-1) = 1;
            str.RT(f) = event.Time - thisDotOnset;
        end
    end
    
    if str.dot.responseCorrect(f) == 1 || (f>=2 && isnan(str.dot.responseCorrect(f)) && str.dot.responseCorrect(f-1) == 1)    %%f > 1 && ~tr.beep && ~( str.dot.series(f) == 1 || (f>1 && str.seriesDot(f-1) == 1))
        % play positive beep
        PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
        PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
        PsychPortAudio('Stop', p.aud.handle, 1);
        
    elseif f>=2 && str.dot.series( f-1) == 1 % participant has not responded until dot(f = 1)
        %play negative beep
        PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
        PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
        PsychPortAudio('Stop', p.aud.handle, 1);
    end
    
    % PROBE ADJUST check for response on etiher trial f-1 OR f-2
    if f >= firstDotPos && str.dot.series( f-1) == 1 % check for correct/no response on trial n-1
        
        ktrial = ktrial + 1; % update staircase probe counter
        
        if str.dot.responseCorrect( f-1) == 1
            r = 1;  % get response for staircase routine
        else
            r = 0; % reset default
        end
        
        stair.process_resp(r); % convert to logical type; process response
        
        % check timing of fetch next probe routine
        probeStart = GetSecs; % just to check time of calculation
        [thisProbe,entexp,ind]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
        sizeAdj = thisProbe;
        probeEnd = GetSecs;
        str.probeDur = probeEnd - probeStart;
        fprintf('response: %d\n',r);
        fprintf('%d, new sample point: %f\nexpect ent: %f\n', ...
            ktrial,thisProbe,entexp(ind));
    end % probe and response 'if clause'
    
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',str.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
    
    % get trial timings and add to series structure
    str.time.trialEnd(f) = GetSecs;
    str.time.trialDur(f) = str.time.trialEnd(f) - str.time.trialStart(f);
    
end  % end of trial f-loop
str;

% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('SeriesEND_%d',str.number);
    Eyelink('message', messageText)
end

% record series times
str.time.seriesEnd = GetSecs;
str.time.seriesDuration = str.time.seriesEnd - str.time.seriesStart;

% STAIRCASE: RESULTS
[PSEfinal,DLfinal,loglikfinal]  = stair.get_PSE_DL();
finalent                        = sum(-exp(loglikfinal(:)).*loglikfinal(:));
fprintf('final estimates:\nPSE: %f\nDL: %f\nent: %f\n',PSEfinal,DLfinal,finalent);

% % % % CALCULATE HITS, misses, FAs for report

% hit number/rate
str.dot.hit = numel(str.dot.responseCorrect(str.dot.responseCorrect ==1)); %int8( (v1 + v2) > 0 );
str.dot.totalNum = numel( str.dot.series( str.dot.series == 1 ) );
if str.dot.hit > 0
str.dot.hitRate = numel(str.dot.hit (str.dot.hit ==1)) / str.dot.totalNum;
else
str.dot.hitRate = 0;
end
% % % % calculate misses (response on dot or subsequent trial are hits)
% % % v3 = [v1(1),v2(1:end-1)];
% % % str.dot.falseAlarm = int8 ( and(str.dot.response == 1, int8(v1+v3) == 0) ); % this can't be counted as a hit CHECK
% % % str.dot.falseAlarmNum = numel( str.dot.falseAlarm( str.dot.falseAlarm == 1));
% % % str.dot.missedNum = str.dot.totalNum - length( str.dot.hit( str.dot.hit==1));

% % % calculate quesiton results
% % str.question.numCorrect = length(find( str.question.responseCorrect == 1));
% % str.question.ratioCorrect = str.question.numCorrect ./ numel(thisQuestionSet);


end