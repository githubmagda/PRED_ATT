function[p, lr] = localizerProc(p, lr)
% This script displays the localizer in the 4 quadrant gratings

% SQUARE WAVE GRATING
backgroundColorOffsetGrat   = [0,0,0,1];
phaseGrat                   = 0;
freqGrat                    = 3.2 / p.scr.pixPerDeg;      % Landau & Fries, 2015 3.2    % see paper by Ayelet, Fries 2015 : 3.2 20; Martin Vinck - .11?
contrastGrat                = 1.0;

% radius of the disc edge
gratRadius              = p.scr.gratRadius;
% basic grating size
virtualSizeGrat         = p.scr.gratRadius *2;

% MAKE TEXTURES
[sineTex, sineTexRect]  = CreateProceduralSquareWaveGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat,...
    backgroundColorOffsetGrat, gratRadius, 1);
angleSet                = 1:6:180;

% CALCULATE GRATING QUAD POSITIONS (centered on point p.scr.gratPos from center)
left                = p.scr.centerX -sineTexRect(3)/2 -p.scr.gratPosSide ;
right               = p.scr.centerX -sineTexRect(3)/2 +p.scr.gratPosSide ;
top                 = p.scr.centerY -sineTexRect(4)/2 -p.scr.gratPosSide ;
bottom              = p.scr.centerY -sineTexRect(4)/2 +p.scr.gratPosSide ;
p.scr.offsetXSet    = [ left, right, right, left];
p.scr.offsetYSet    = [ top, top, bottom, bottom];

% make destination rects for gratings
dstRectGrats        = OffsetRect( sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet')';
paramsGrats         = repmat([phaseGrat, freqGrat, contrastGrat, 0], 4, 1)';

% END GRATINGS

runFix = 1;

while runFix % until localizer has been successfully completed without eyes moving out of policed area
    
% INITIALIZE
lr.monitor.totalFixTime         = zeros( 1, p.series.stimPerSeries);
lr.monitor.totalErrorTime       = zeros( 1, p.series.stimPerSeries);
lr.gratAngle                    = zeros( 1, p.series.stimPerSeries);
lr.gratQuad                     = zeros( 2, p.series.stimPerSeries);

% DRAW PRE-SERIES FIXATION GUASSIAN

% Draw cue fixation cross : dark cross two nested white gaussians
Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, paramsGauss');

% FLIP
[vbl]           = Screen('Flip', p.scr.window, 0, 1);  % [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', windowPtr [, when] [, dontclear]
thisWaitTime    = p.preSeriesFixTime - (.9 *p.scr.flipInterval);

% EYETRACKER SEND MESSAGE and MONITOR
if p.useEyelink
    messageText = strcat('LOCALIZER_PRESERIES_FIXATION_', num2str(lr.number) );
    Eyelink('message', messageText);
    
    % START POLICING FIXATION
    [ thisErrorTime, totalErrorTime, totalFixTime]      = monitorFixation(p, thisWaitTime);
    lr.monitor.preSeriesTotalErrorTime                  = totalErrorTime;
    lr.monitor.preSeriesTotalFixTime                    = totalFixTime;
    
    if thisErrorTime > p.scr.maxPoliceErrorTime
        %disp('ERROR');
        PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);
        PsychPortAudio('Start', p.audio.handle, 1, 0, 1);     % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
        PsychPortAudio('Stop', p.audio.handle, 1);
        PsychPortAudio('Close', p.audio.handle);
        break;
    end
else
    WaitSecs(thisWaitTime); % just show cross
end


% DISPLAY SEQUENCE
trialStart = zeros(1, p.series.stimPerSeries);
lr.time.seriesStart = GetSecs;

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    thisQuad                = lr.series( f);
    %thisRotation            = ( thisQuad-1 ) * 90; % rotation to put flash in correct quadrant
    
    % SEND MESSAGE to EYETRACKER .edf file
    if p.useEyelink
        messageText = strcat('LOCALIZER_', num2str(lr.number), 'TRIAL_START', num2str(f));
        Eyelink('Message', messageText);
    end
    
    % SET OPTIONS for GRATING TEXTURE
    
    % angle of grating
    select              = randi([1,length(angleSet)],1);  % choose 4 random angles from set   
    tiltGrat            = angleSet(select);
    lr.gratAngle(f)     = tiltGrat;                            % save to lr structure
    
    % grating position
    thisXOffset         = p.scr.gratPosCenterX( thisQuad); % p.scr.offsetXSet( thisQuad);
    thisYOffset         = p.scr.gratPosCenterY( thisQuad); % p.scr.offsetYSet( thisQuad);
    lr.gratQuad(:,f)    = [thisXOffset, thisYOffset];
    dstRectSine         = OffsetRect( sineTexRect, thisXOffset -sineTexRect(3)/2, thisYOffset -sineTexRect(4)/2); %thisXOffset, thisYOffset);

    % Draw the gratings
    Screen('DrawTexture', p.scr.window, sineTex, sineTexRect, dstRectSine, tiltGrat, [], [], [], [], [], [phaseGrat, freqGrat, contrastGrat, 0]);
    %Screen('DrawTexture', p.scr.window, gratTex, gratTexRect, dstRectGrat, thisAngle, [], [], ...
    %    [], [], [], [p.scr.phaseGrat+180, p.scr.freqGrat, p.scr.contrastGrat, 0]);
    
    % DRAW FIXATION gaussian 
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, paramsGauss');

    % FLIP 
    thisWaitTime =  p.scr.stimDur -(0.9 *p.scr.flipInterval);
    [vbl] = Screen('Flip', p.scr.window, vbl+thisWaitTime); % next flip
     
    trialStart(f) = vbl;

    % EYETRACKER
    if p.useEyelink
        % SEND MESSAGE
        messageText = strcat('LOCALIZER_', num2str(lr.number), 'TRIAL_START', num2str(f));
        Eyelink('message', messageText);
        
        % MONITOR
        [thisErrorTime, totalErrorTime, totalFixTime] = monitorFixation(p, thisWaitTime);
        lr.monitor.totalErrorTime(f) = totalErrorTime;
        lr.monitor.totalFixTime( f)  = totalFixTime;
        if thisErrorTime > p.scr.maxPoliceErrorTime
            disp('ERROR');
%             PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);
%             PsychPortAudio('Start', p.audio.handle, 1, 0, 1);     % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
%             PsychPortAudio('Stop', p.audio.handle, 1);
%             PsychPortAudio('Close', p.audio.handle);
            % SEND EYETRACKER MESSAGE
            messageText = strcat('LOCALIZER_PREFIXATION_FAILED');
            Eyelink('message', messageText)
            break;
            runFix = 1;
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

    if f == p.series.stimPerSeries
        runFix = 0;
    end
end  % end of trial f-loop
lr.trialStart = trialStart;
lr.trialDur = trialStart(2:end) - trialStart(1:( end-1));

lr.time.seriesEnd = GetSecs;
lr.time.seriesDur = lr.time.seriesEnd - lr.time.seriesStart; 

lr;
% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('LOCALIZER_','SeriesEND',lr.number);
    Eyelink('message', messageText)
end

end % while loop

end % end function
