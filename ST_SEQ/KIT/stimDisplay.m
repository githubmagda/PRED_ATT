function[p, sr] = stimDisplay(p, sr)

% This script displays the stimulus making and displaying the 4 quadrant gratings,
% the predictive per-quadrant white-screen flashes and ocassional attentional dot
% Inputs include the predictive and attn series included in series
% structure

% TEXTURES 
texGrat = p.textures.texGrat;               % main texture
texGratFlash = p.textures.texGratFlash;     % texture with predictive element
gaus_attn_tex = p.textures.gaus_attn_tex;   % attentional dot
gaus_fix_tex = p.textures.gaus_fix_tex;     % fixation gaussian

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

% DRAW PRE-SERIES FIXATION GUASSIAN w/ ATTENTION CUE
% Draw gaussian
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]
% Draw cue fixation cross with red arm pointing to attentional quadrant
Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, attn, [ p.scr.centerX, p.scr.centerY ], 2);
% Draw smaller center dot
Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );

% FLIP
Screen('Flip', p.scr.window);

% END PRE-SERIES FIXATION

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation(p, sr);
else
    WaitSecs(p.preSeriesFixTime); % show attentional cross with cue
end
% END POLICING FIXATION

% DISPLAY SEQUENCE 
% initialize timing and response vectors
sr.time.trialStart      = nan( 1, p.series.stimPerSeries );
sr.time.trialEnd        = nan( 1, p.series.stimPerSeries);
sr.time.trialFlashOn    = nan( 1, p.series.stimPerSeries);
sr.time.trialFlashOff   = nan( 1, p.series.stimPerSeries);
sr.time.trialDotOn      = nan( 1, p.series.stimPerSeries);
sr.time.trialDotOff     = nan( 1, p.series.stimPerSeries);

str.dot.posX            = nan( 1, p.series.stimPerSeries );                % dot position and timing 
str.dot.posY            = nan( 1, p.series.stimPerSeries );
str.time.dotOnset       = nan( 1, p.series.stimPerSeries );
str.time.dotOffset      = nan( 1, p.series.stimPerSeries );

sr.dot.response         = nan( 1, p.series.stimPerSeries );             % dot response
sr.dot.responseCorrect  = nan( 1, p.series.stimPerSeries );
sr.dot.FA               = nan( 1, p.series.stimPerSeries );
sr.dot.responsekeyCode  = nan( 1, p.series.stimPerSeries );
sr.dot.RT               = nan( 1, p.series.stimPerSeries ); 
sr.dot.quad             = nan( 1, p.series.stimPerSeries );

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

% START KEYBOARD QUEUES
KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
KbQueueStart();   %% KbQueueStart([deviceIndex])

% SERIES START MESSAGES
% SEND MESSAGE to EYETRACKER .edf file
if p.useEyelink
    messageText = strcat('SERIES_START', num2str(sr.number),'AttnQUAD_%d', num2str(thisCue) );
    Eyelink('message', messageText)
end
sr.time.seriesStart = GetSecs;

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    % get trial times
    trialStart = GetSecs;
    sr.time.trialStart(f) = trialStart;
    
    % SEND MESSAGE to EYETRACKER .edf file
    if p.useEyelink
        messageText = strcat('SERIES',num2str(series.number),'TRIAL_START',fnum2str(f),'PredQUAD', num2str(thisPred), 'AttnQUAD', num2str(thisCue) );
        Eyelink('Message', messageText);
    end
    
    % predictive FLASH
    thisPred = sr.pred.series(f);           %  quadrant where flash will appear
    thisRotation = ( thisPred-1 ) * 90;     % rotation factor to put flash in correct quadrant
    
    if sr.dot.series(f) == 1
        
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
        
        % dot onset is in range [end of flash + 3: #Frames/2] ; dot offset set by p.dotFrameDur
        sr.dot.frameOnset(f) = randi([ p.scr.predScreenDur + 3, round(p.scr.framesPerMovie/2)], 1);
        sr.dot.frameOffset(f) = sr.dot.frameOnset(f) + p.dotFrameDur; % must be less than numFrames./2
        
        % dimensions of dot
        dotXStart = sr.dot.posX(f) - round( p.scr.dotGridRadiusPix ); % set to size of gaussian grid
        dotXEnd = sr.dot.posX(f) + round( p.scr.dotGridRadiusPix );
        dotYStart = sr.dot.posY(f) - round( p.scr.dotGridRadiusPix );
        dotYEnd = sr.dot.posY(f) + round( p.scr.dotGridRadiusPix );        
    end
    
    
    % DRAW TEXTURES % FLASH ON
    Screen('DrawTexture', p.scr.window, texGratFlash(1), [], [], thisRotation); % flash on  [rotate] = angle in degrees
    
    % DRAW fixation gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center dot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    %Screen('DrawTexture',p.scr.window, gaus_fix_texSmall,[],[],[],[],[],[p.scr.white]) % [p.scr.fixColorChange]
    
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
    p.time.trialFlashOn(f) = flip;
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat(['SERIES',num2str(sr.number), 'TRIAL',num2str(f),'Cue', thisCue, 'FlashQuadON', thisPred]);      
        Eyelink('message', messageText);
    end
    
    timePassed = WaitSecs - trialStart;
    WaitSecs( p.scr.predScreenDur - timePassed - .5*p.scr.flipInterval);
    
    % routine for if eyes wander away change center dot and attn pointer to red
    if p.useEyelink && fr.outOfBounds
        Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, attn, [ p.scr.centerX, p.scr.centerY ], 2);
        Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        % send message to .edf file
        messageText = ['gazeOutOfBounds_', 'Series',num2str(sr.number), 'Cue', thisCue, 'Pred', thisPred, 'dotTime?',sr.seriesDot(f)];
        Eyelink('message',messageText);
    end
    
    % DRAW TEXTURES % FLASH OFF
    Screen('DrawTexture', p.scr.window, texGrat(1), [], [], thisRotation); % flash on  [rotate] = angle in degrees
    %% DRAW fixation gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center dot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
    p.time.trialFlashOff(f)
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
       messageText = strcat(['SERIES',num2str(sr.number), 'TRIAL',num2str(f),'Cue', thisCue, 'FlashQuadOFF', thisPred]);
        Eyelink('message', messageText);
    end
    timePassed = WaitSecs - p.scr.trialFlashOn(f);
    WaitSecs( p.scr.predScreenDur + p.scr.postFlashTime - timePassed - .5*p.scr.flipInterval);
    
    % DRAW TEXTURES % DOT ON
    Screen('DrawTexture', p.scr.window, texGrat(1), [], [], thisRotation); % flash on  [rotate] = angle in degrees
    %% DRAW fixation gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center spot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    % attention DOT
    Screen('DrawTexture', p.scr.window, gaus_attn_tex(thisProbe), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
    
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
    p.time.dotOn(f) = flip;
    
    if p.useEyelink
        messageText = strcat(['DotOn_PosX: ',dotXStart,'-',dotXEnd, '_PosY: ',dotYStart, '-', dotYEnd]);
        Eyelink('message',messageText);
    end
    
    timePassed = WaitSecs - p.scr.trialFlashOn(f);
    WaitSecs( p.scr.dotDur + ( p.scr.dotJitter*( randi( 30,1) * .01)) - - timePassed - .5*p.scr.flipInterval);
     
    % DRAW TEXTURES % DOT OFF
    Screen('DrawTexture', p.scr.window, texGrat(1), [], [], thisRotation); % flash on  [rotate] = angle in degrees
    %% DRAW fixation gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, fixCoords, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center spot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    % attention DOT
    Screen('DrawTexture', p.scr.window, gaus_attn_tex(thisProbe), [], [ dotXStart, dotYStart, dotXEnd, dotYEnd ],[],[],[],p.scr.fixCrossColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
   
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 );
    p.time.DotOff(f) = flip;
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('Series_',num2str(sr.number), 'FlashQuadOFF', num2str(thisPred) );
        Eyelink('message', messageText);
    end
    timePassed = GetSecs - trialStart;
    WaitSecs( p.scr.stimDur - timePassed - .5*p.scr.flipInterval);
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat(['SERIES',num2str(sr.number), 'TRIAL',num2str(f),'Cue', thisCue, 'Pred', thisPred, 'dotTime',]);
        Eyelink('message',messageText);
    end

    WaitSecs(waitTime);
        
    end % end of frame ff-loop
    
    if p.useEyelink %CHECK
        Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
    end
    
    KbQueueStop(); %%     KbQueueStop([deviceIndex])
    [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
    
    if  ~isempty(event) % event.Pressed == 1
        sr.dot.response(f) = 1;
        if sr.dot.series(f) == 1
            sr.RT(f) = event.Time - sr.dot.time(f);
            sr.dot.responseCorrect(f) = 1;
        elseif f>1 && sr.dot.series(f-1) == 1            
            sr.dot.RT(f) = event.Time - sr.dot.time(f-1);
            sr.dot.responseCorrect(f) = 1;
        else
            sr.dot.RT(f) = NaN;
        end
        sr.dot.responsekeyCode(f) = event.Keycode;
        KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
        KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
    end
    
    if sr.dot.response(f) % CORRECT RESPONSE? PLAY APPROP SOUND
        if sr.dot.series(f) == 1  || (f>1 && sr.dot.series(f-1) == 1)    %%f > 1 && ~tr.beep && ~( sr.dot.series(f) == 1 || (f>1 && sr.seriesDot(f-1) == 1))
            % play positive beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
        else
            %play negative beep
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
        end
    end
    
    % call question routine
    if uint8( any( thisQuestionSet == f)) % Question re 'next screen': uses Colored Ring       
        [sr] = askQuestion( p, sr, f, 0);  % (p, sr, f, useText=1)        
        WaitSecs(1.0);
    end % end question routine
    
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',sr.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
          
    % get trial timings and add to series structure
    sr.time.trialEnd(f) = GetSecs;
    sr.time.trialDur(f) = sr.time.trialEnd(f) - sr.time.trialStart(f);
    
% % %     % name/number trial and add to series structure
% % %     trName = sprintf('tr%d',f);
% % %     sr.(trName) = tr;
       
end  % end of trial f-loop

% record series times
sr.time.seriesEnd = GetSecs;
sr.time.seriesDuration = sr.time.seriesEnd - sr.time.seriesStart;

% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('SeriesEND_%d',sr.number);
    Eyelink('message', messageText)
end

% CALCULATE HITS and FAs for report
v1 = int8( and( sr.dot.series == 1, sr.dot.response == 1));
v2 = [int8( and( sr.dot.series(1:end-1) == 1, sr.dot.response(2:end) == 1)), 0]; % participant got dot on following frame

% hit rate
sr.dot.hit = int8( (v1 + v2) > 0 );
sr.dot.hitNum = numel(sr.dot.hit (sr.dot.hit == 1));
sr.dot.totalNum = numel( sr.dot.series( sr.dot.series == 1 ) );
if numel(sr.dot.hit (sr.dot.hit ==1)) > 0
    sr.dot.hitRate = numel(sr.dot.hit (sr.dot.hit ==1)) / sr.dot.totalNum;
else
    sr.dot.hitRate = 0;
end
% calculate misses (response on dot or subsequent trial are hits)
v3 = [v1(1),v2(1:end-1)];
sr.dot.falseAlarm = int8 ( and(sr.dot.response == 1, int8(v1+v3) == 0) ); % this can't be counted as a hit CHECK
sr.dot.falseAlarmNum = numel( sr.dot.falseAlarm( sr.dot.falseAlarm == 1));
sr.dot.missedNum = sr.dot.totalNum - length( sr.dot.hit( sr.dot.hit==1));

% calculate quesiton results
sr.question.numCorrect = length(find( sr.question.responseCorrect == 1));
sr.question.ratioCorrect = sr.question.numCorrect ./ numel(thisQuestionSet);
sr;

end