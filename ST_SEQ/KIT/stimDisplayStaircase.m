function[p, stair] = stimDisplayStaircase(p, str)

% This verison of stim Display is only used for staircase. It checks for dot size that is successfully discrimated by subjectscript displays the stimulus making and displaying the 4 quadrant gratings,
% Inputs include attn series 

% PRESENT STIMULI
% main textures (basic=1 and flash-white-mask=2)
texGrat = p.textures.texGrat;
% texGratFlash = p.textures.texGratFlash; % texture with predictive element
gaus_attn_tex = p.textures.gaus_attn_tex; % attentional dot
gaus_fix_tex = p.textures.gaus_fix_tex; % fixation gaussian

% CUT 

% DRAW PRE-SERIES FIXATION GUASSIAN 
% Draw gaussian
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]
% Draw cue fixation cross with red arm pointing to attentional quadrant
Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
% Draw smaller center dot
Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );
%Screen('FrameOval', p.scr.window, [255,0,0], [circleXPos-p.scr.gratPosPix/2, circleYPos-p.scr.gratPosPix/2, circleXPos+p.scr.gratPosPix/2, circleYPos+p.scr.gratPosPix/2], 2,[]);

% FLIP
Screen('Flip', p.scr.window);

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation(p, str);
else
    WaitSecs(p.preSeriesFixTime); % just show cross to center gaze
end

% DISPLAY SEQUENCE CHECK-ERASE???
% initialize timing and response vectors
str.trialStart = zeros( 1, p.series.stimPerSeries );
str.trialEnd = zeros( 1, p.series.stimPerSeries );
str.dot.response = zeros( 1, p.series.stimPerSeries );
str.dot.responseCorrect = zeros( 1, p.series.stimPerSeries );
str.dot.responsekeyCode = zeros( 1, p.series.stimPerSeries );
str.dot.RT = zeros( 1, p.series.stimPerSeries ); % time for correct; NaN for incorrect
str.dot.posX = zeros( 1, p.series.stimPerSeries );
str.dot.posY = zeros( 1, p.series.stimPerSeries );
str.dot.frameOnset = zeros( 1, p.series.stimPerSeries );
str.dot.frameOffset = zeros( 1, p.series.stimPerSeries );
str.dot.time = zeros( 1, p.series.stimPerSeries );
str.time.seriesStart = GetSecs;

% INITIALIZE STAIRCASE (see MinExpEntStairDemo in Testing or Psychtoolbox)
% stair input
probeset    = -10 : .05 : 10; % -15:0.5:15;        % set of possible probe values
meanset     = -10 : .05 : 10 ;% -10:0.2:10;      % sampling of pses, doesn't have to be the same as probe set
slopeset    = [.1:.1:5].^2;%[.5:.1:5].^2;                 % set of slopes, quad scale
lapse       = 0.05;                         % lapse/mistake rate
guess       = 0.50;                         % guess rate / minimum correct response rate (for detection expt: 1/num_alternative, 0 for discrimination expt)

% % STAIRCASE: general settings 
ntrial  = length( str.dot.series); %40;
qpause  = false;    % pause after every iteration? (press any key to continue)
qplot   = false;    % plot information about each trial? (this pauses as well, regardless of whether you specified qpause as true)
qusemodel = false; 

% % STAIRCASE: Create staircase instance. 
stair = MinExpEntStair('v2'); 

% % STAIRCASE:stair.init.
stair.set_use_lookup_table(true);  

% option: use logistic instead of default cumulative normal. best to call
% before stair.init
% stair('set_psychometric_func','logistic'); %CHECK % STAIRCASE: 

% init stair
stair.init( probeset, meanset, slopeset, lapse, guess);

% option: use a subset of all data for choosing the next probe
stair.toggle_use_resp_subset_prop( 10,.9); % STAIRCASE: 

% set value for first probe based on probeset values
val = probeset( round( length( probeset) /2));   % STAIRCASE: MA set to mode of probeset
stair.set_first_value( val);  % STAIRCASE: stair.set_first_value(3);
%sizeAdj = val; % initial setting


[thisProbe, ~, ~]  = stair.get_next_probe(); % ge
sizeAdj = thisProbe

% END INITIALIZE STAIRCASE 

% SEND MESSAGE to EYETRACKER .edf file
if p.useEyelink
    messageText = strcat('SERIES_START', num2str(str.number));
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
   
    str.time.dotOn = GetSecs; 
    %%%%%responseProbe = 0; % set default for staircase = no response
    
    if str.dot.series(f) == 1
        
% % % %         %getProbeStart = GetSecs;
% % % %         [thisProbe, ~, ~]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
% % % % 
% % % %         %getProbeEnd = GetSecs;
% % % %         %getProbeDur = getProbeEnd - getProbeStart;
% % % %         %sprintf('getProbeDur %d', getProbeDur)
% % % %         sizeAdj = thisProbe;
% % % %          % default - gets reset below if postive response
        
        % DOT POSITION 
        dotQuad = randi(4,1); % 1 in 10 probability
        % CUT
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
        
        % dot onset is in range [end of flash + 3: #Frames/2] ; dot offset set by p.dotFrameDur
        str.dot.frameOnset(f) = randi([ p.scr.predScreenDur + 3, round(p.scr.framesPerMovie/2)], 1);
        str.dot.frameOffset(f) = str.dot.frameOnset(f) + p.dotFrameDur; % must be less than numFrames./2
        
        % dimensions of dot CHANGES BASED ON STAIRCASE
        dotXStart = str.dot.posX(f) - round( p.scr.dotGridRadiusPix ); % set to size of gaussian grid
        dotXEnd = str.dot.posX(f) + round( p.scr.dotGridRadiusPix );
        dotYStart = str.dot.posY(f) - round( p.scr.dotGridRadiusPix );
        dotYEnd = str.dot.posY(f) + round( p.scr.dotGridRadiusPix );      
    end
    
    % KB CHECK initialize queues
    KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
    KbQueueStart();   %% KbQueueStart([deviceIndex])
       
    for ff = 1 : p.scr.framesPerMovie
        
        frameNumber = ff;
        frameStart = GetSecs;
        str.time.frameStart(f, ff) = frameStart;
        % reset parameters tested in ff loop
        Screen('DrawTexture', p.scr.window, texGrat(ff), [], [], []); % flash off
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat('Series_',num2str(str.number), 'Frame_', num2str(ff));
            Eyelink('message', messageText);
        end

        %% DRAW fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center dot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        
        % routine for if eyes wander away change center dot and attn pointer to red
        if p.useEyelink && fr.outOfBounds
            
            Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
            Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
            % send message to .edf file
            messageText = ['gazeOutOfBounds_', 'Series',num2str(str.number), 'Cue', thisCue, 'Pred', thisPred, 'dotTime?',str.seriesDot(f)];
            Eyelink('message',messageText);
        end
        
        % DRAW DOT
        if str.dot.series(f)
            
            if frameNumber >= str.dot.frameOnset(f) && frameNumber <= str.dot.frameOffset(f)
                Screen('DrawTexture', p.scr.window, gaus_attn_tex, [], [ dotXStart-sizeAdj, dotYStart-sizeAdj, dotXEnd+sizeAdj, dotYEnd+sizeAdj ],[],[],[],p.scr.fixColorChange); %  61 61 [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
                
                if p.useEyelink
                    messageText = strcat(['FRAME',num2str(frameNumber),'dotPos',dotXStart, dotYStart, dotXEnd, dotYEnd]);
                    Eyelink('message',messageText);
                end  
            end
        end
        
        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0 ); 
        if frameNumber == str.dot.frameOnset(f)
            str.dot.time(f) = flip;
        end
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat(['SERIES',num2str(str.number), 'TRIAL',num2str(str.number),'FRAME',num2str(frameNumber),'Cue', thisCue, 'Pred', thisPred, 'dotTime',]);
            Eyelink('message',messageText);
        end
        
        % record frame times to trial level
        str.time.frameEnd(f, ff) = GetSecs;
        str.time.frameDur(f, ff) = str.time.frameEnd(f, ff) - str.time.frameStart(f, ff);
        waitTime = p.scr.frameDur - str.time.frameDur(f, ff) - .9*p.scr.flipInterval; %% CHECK        
        WaitSecs(waitTime);
  
        
    end % end of frame ff-loop

    if p.useEyelink %CHECK
        Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
    end
    
    KbQueueStop(); %%     KbQueueStop([deviceIndex])
    [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
    
    KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
    KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
    
    if  ~isempty(event) % event.Pressed == 1
       
        str.dot.response(f) = 1;
        if str.dot.series(f) == 1
            str.RT(f) = event.Time - str.dot.time(f);
            str.dot.responseCorrect(f) = 1;
            
        elseif f>1 && str.dot.series(f) == 0 && str.dot.series(f-1) == 1            
            str.dot.RT(f) = event.Time - str.dot.time( f-1);
            str.dot.responseCorrect(f) = 1;
        end
                
        if str.dot.responseCorrect(f)    %%f > 1 && ~tr.beep && ~( str.dot.series(f) == 1 || (f>1 && str.seriesDot(f-1) == 1))
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
    
    if str.dot.series(f)
        responseProbe = 0; % reset default
        if str.dot.responseCorrect(f)
            responseProbe = 1;
        end
        stair.process_resp(responseProbe);
        %getProbeStart = GetSecs;
        [thisProbe, ~, ~]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
        thisProbe
        sizeAdj = thisProbe;
        %getProbeEnd = GetSecs;
        %getProbeDur = getProbeEnd - getProbeStart;
        %sprintf('getProbeDur %d', getProbeDur)      
    end
        
% % %     % call question routine
% % %     if uint8( any( thisQuestionSet == f)) % Question re 'next screen': uses Colored Ring       
% % %         [str] = askQuestion( p, str, f, 0);  % (p, str, f, useText=1)        
% % %         WaitSecs(1.0);
% % %     end % end question routine
% % %     
    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('SERIES_%d',str.number, 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
          
    % get trial timings and add to series structure
    str.time.trialEnd(f) = GetSecs;
    str.time.trialDur(f) = str.time.trialEnd(f) - str.time.trialStart(f);
    
% %     % name/number trial and add to series structure
% %     strName = sprintf('str%d',f);
% %     str.(strName) = str;
       
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

% CALCULATE HITS and FAs for report
v1 = int8( and( str.dot.series == 1, str.dot.response == 1));
v2 = [int8( and( str.dot.series(1:end-1) == 1, str.dot.response(2:end) == 1)), 0]; % participant got dot on following frame

% hit rate
str.dot.hit = int8( (v1 + v2) > 0 );
str.dot.hitNum = numel( str.dot.hit (str.dot.hit == 1));
str.dot.totalNum = numel( str.dot.series( str.dot.series == 1 ) );
if numel( str.dot.hit (str.dot.hit ==1)) > 0
    str.dot.hitRate = numel(str.dot.hit (str.dot.hit ==1)) / str.dot.totalNum;
else
    str.dot.hitRate = 0;
end
% calculate misses (response on dot or subsequent trial are hits)
v3 = [v1(1),v2(1:end-1)];
str.dot.falseAlarm = int8 ( and(str.dot.response == 1, int8(v1+v3) == 0) ); % this can't be counted as a hit CHECK
str.dot.falseAlarmNum = numel( str.dot.falseAlarm( str.dot.falseAlarm == 1));
str.dot.missedNum = str.dot.totalNum - length( str.dot.hit( str.dot.hit==1));

% % % calculate quesiton results
% % str.question.numCorrect = length(find( str.question.responseCorrect == 1));
% % str.question.ratioCorrect = str.question.numCorrect ./ numel(thisQuestionSet);
str;

end