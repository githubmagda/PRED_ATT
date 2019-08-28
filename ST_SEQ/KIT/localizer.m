function[p, lr] = localizer(p, lr)

% This script displays the localizer in the 4 quadrant gratings,

% PRESENT STIMULI
texGrat = p.textures.texGratLocalizer;
gaus_fix_tex = p.textures.gaus_fix_tex; % fixation gaussian

runFix = 1;

while runFix 
%INITIALIZE
lr.monitor.totalFixTime         = zeros( 1, p.series.stimPerSeries);
lr.monitor.totalErrorTime       = zeros( 1, p.series.stimPerSeries);

% DRAW PRE-SERIES FIXATION GUASSIAN
% Draw gaussian
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]
% Draw cue fixation cross with red arm pointing to attentional quadrant
Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
% Draw smaller center dot
Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );

% FLIP
Screen('Flip', p.scr.window);

thisWaitTime = p.preSeriesFixTime;

% EYETRACKER SEND MESSAGE and MONITOR
if p.useEyelink
    messageText = strcat('LOCALIZER_PRESERIES_FIXATION_', num2str(lr.number) );
    Eyelink('message', messageText);
    
    % START POLICING FIXATION
    [ thisErrorTime, totalErrorTime, totalFixTime]     = monitorFixation(p, lr, thisWaitTime);
    lr.monitor.preSeriesTotalErrorTime  = totalErrorTime;
    lr.monitor.preSeriesTotalFixTime    = totalFixTime;
    
    if thisErrorTime > p.scr.maxPoliceErrorTime
        disp('ERROR');
%         audioOpen(p)
%         PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);
%         PsychPortAudio('Start', p.audio.handle, 1, 0, 1);     % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
%         PsychPortAudio('Stop', p.audio.handle, 1);
%         PsychPortAudio('Close', p.audio.handle);
        runFix = 1;
        break;
    else runFix = 0;
    end
else
    WaitSecs(thisWaitTime); % just show cross
end

% DISPLAY SEQUENCE
lr.time.seriesStart = GetSecs;

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    trialSetup              = GetSecs;
    lr.time.trialSetup( f)  = trialSetup;
    thisQuad                = lr.series( f);
    thisRotation            = ( thisQuad-1 ) * 90; % rotation to put flash in correct quadrant
    
    % SEND MESSAGE to EYETRACKER .edf file
    if p.useEyelink
        messageText = strcat('LOCALIZER_', num2str(lr.number), 'TRIAL_START', num2str(f));
        Eyelink('Message', messageText);
    end
    
    % DRAW GRATING TEXTURE
    Screen('DrawTexture', p.scr.window, texGrat(1), [], [], thisRotation); % Screen('DrawTextures', windowPointer, texturePointer(s) [, sourceRect(s)] [, destinationRect(s)] [, rotationAngle(s)] [, filterMode(s)] [, globalAlpha(s)] [, modulateColor(s)] [, textureShader] [, specialFlags] [, auxParameters]);
    % DRAW FIXATION gaussian
    Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center dot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    %Screen('DrawTexture',p.scr.window, gaus_fix_texSmall,[],[],[],[],[],[p.scr.white]) % [p.scr.fixColorChange]
    
    % FLIP
    [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0);
    
    lr.time.trialStart = vbl;
    timePassed = GetSecs - trialSetup;          % account for time since trial started to keep overall trial time consistent
    thisWaitTime = (p.scr.stimDur -timePassed -0.5*p.scr.flipInterval);
    
    % EYETRACKER
    if p.useEyelink
        % SEND MESSAGE
        messageText = strcat('LOCALIZER_', num2str(lr.number), 'TRIAL_START', num2str(f));
        Eyelink('message', messageText);
        
        % MONITOR
        [thisErrorTime, totalErrorTime, totalFixTime] = monitorFixation(p, lr, thisWaitTime);
        lr.monitor.totalErrorTime(f) = totalErrorTime;
        lr.monitor.totalFixTime( f)  = totalFixTime;
        if thisErrorTime > p.scr.maxPoliceErrorTime
            disp('ERROR');
            audioOpen(p)
            PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
            PsychPortAudio('Start', p.aud.handle, 1, 0, 1);     % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            PsychPortAudio('Stop', p.aud.handle, 1);
            PsychPortAudio('Close', p.aud.handle);
            % SEND EYETRACKER MESSAGE
            messageText = strcat('LOCALIZER_PREFIXATION_FAILED');
            Eyelink('message', messageText)
            break;
        end
        
         % SEND EYETRACKER MESSAGE  
        messageText = strcat('LOCALIZER_PREFIXATION_END' );
        Eyelink('message', messageText)
    else
        WaitSecs(thisWaitTime);                 % just show cross
    end
        % %     % routine for if eyes wander away change center dot and attn pointer to red
        % %     if p.useEyelink
        % %         timePassed =
        % %         thisWaitTime = p.scr.stimDur -
        % %         monitorFixation(p, lr, thisWaitTime)
        % %         Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % %         Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        % %         % send message to .edf file
        % %         messageText = ['gazeOutOfBounds_', 'Series',num2str( slr.number), 'thisQuad', thisQuad];
        % %         Eyelink('message',messageText);
        % %     end
        
        
        
        % %     if p.useEyelink
        % %         Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
        % %     end
        % %     time check
        % %     timePassed = GetSecs - trialSetup;
        % %     WaitSecs(p.scr.stimDur -timePassed -0.5*p.scr.flipInterval);
        % %     while ( timePassed < (p.scr.stimDur - timePassed - .5*p.scr.flipInterval)) %wait p.scr.dotOnset seconds
        % %         timePassed = GetSecs - trialStart ;
        % %         WaitSecs(p.scr.flipInterval);
        % %     end
        

    
    lr.time.trialEnd(f) = GetSecs;
    lr.time.trialDur(f) = lr.time.trialEnd(f) - lr.time.trialSetup(f);
    
end  % end of trial f-loop

lr.time.seriesEnd = GetSecs;
lr.time.seriesDur = lr.time.seriesEnd - lr.time.seriesStart;
lr;

% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('LOCALIZER_','SeriesEND',lr.number);
    Eyelink('message', messageText)
end

end % end function
