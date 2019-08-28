function[p, lr] = localizerSmoothSine(p, lr)
% This script displays the localizer in the 4 quadrant gratings

% Define prototypical gabor patch of 65 x 65 pixels default size: si is
% half the wanted size. Later on, the 'DrawTextures' command will simply
% scale this patch up and down to draw individual patches of the different
% wanted sizes:
si = 32;

% Size of support in pixels, derived from si:
tx = 3*si+1;
ty = 3*si+1;

% Initial stimulus params for the smooth sine grating:
virtualSize = p.scr.gratRadius *2;
phase = 0;
freq = .11; % .04
tilt = 225;
contrast = 1.5; %0.5;
% radius of the disc edge
radius = virtualSize /2;
% smoothing sigma in pixel
sigma = 55;
% use alpha channel for smoothing?
useAlpha =   true;
% smoothing method: cosine (0) or smoothstep (1)
smoothMethod = 1;


% MAKE TEXTURES
[sineTex, sineTexRect] = CreateProceduralSmoothedApertureSineGrating(p.scr.window, virtualSize, virtualSize,...
          [.5 .5 .5 0], radius, [], sigma, useAlpha, smoothMethod);
[gaussTex, gaussTexRect]    = CreateProceduralGaussBlob( p.scr.window , tx*2, ty*2, p.scr.fixBackgroundColorOffset, 0, 1);
%[gratTex, gratTexRect]      = CreateProceduralSineGrating(p.scr.window, tx*2, ty*2, p.scr.backgroundColorOffsetGrat, p.scr.gratRadius, p.scr.contrastPreMultiplicatorGrat);

fixScale                    = 1;               % scale of gaussian adjustment in 'DrawTexture'
fixInnerScale               = 0.25;

dstRectFix                  = OffsetRect(gaussTexRect*fixScale,      p.scr.centerX -(tx*fixScale), p.scr.centerY -(ty*fixScale));
dstRectFixInner             = OffsetRect(gaussTexRect*fixInnerScale, p.scr.centerX -(tx*fixInnerScale), p.scr.centerY -(ty*fixInnerScale));

% END TEXTURES 

runFix = 1;

while runFix % until localizer has been successfully completed without eyes moving out of policed area
    
% INITIALIZE
lr.monitor.totalFixTime         = zeros( 1, p.series.stimPerSeries);
lr.monitor.totalErrorTime       = zeros( 1, p.series.stimPerSeries);
lr.gratAngle                    = zeros( 1, p.series.stimPerSeries);
lr.gratQuad                     = zeros( 2, p.series.stimPerSeries);

% DRAW PRE-SERIES FIXATION GUASSIAN

% Draw cue fixation cross with red arm pointing to attentional quadrant
Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1; p.scr.fixInnerContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]');
%Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]

% Draw smaller center dot
%Screen('DrawTexture', p.scr.window, gaussTex, gaussTexRect, dstRectFixInner, [], [], [], [], [], kPsychDontDoRotation, [p.scr.fixInnerContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
%Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );
Screen('DrawingFinished', p.scr.window);

% FLIP
[vbl] = Screen('Flip', p.scr.window, 0);
thisWaitTime = p.preSeriesFixTime - (.9 *p.scr.flipInterval);

% EYETRACKER SEND MESSAGE and MONITOR
if p.useEyelink
    messageText = strcat('LOCALIZER_PRESERIES_FIXATION_', num2str(lr.number) );
    Eyelink('message', messageText);
    
    % START POLICING FIXATION
    [ thisErrorTime, totalErrorTime, totalFixTime]     = monitorFixation(p, thisWaitTime);
    lr.monitor.preSeriesTotalErrorTime              = totalErrorTime;
    lr.monitor.preSeriesTotalFixTime                = totalFixTime;
    
    if thisErrorTime > p.scr.maxPoliceErrorTime
        disp('ERROR');
%         audioOpen(p)
%         PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);
%         PsychPortAudio('Start', p.audio.handle, 1, 0, 1);     % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
%         PsychPortAudio('Stop', p.audio.handle, 1);
%         PsychPortAudio('Close', p.audio.handle);
        break;
    end
else
    WaitSecs(thisWaitTime); % just show cross
end

Screen('DrawTexture', p.scr.window, sineTex, [], [], tilt, [], [], [], [], [], [phase, freq, contrast, 0]);
[vbl] = Screen('Flip', p.scr.window);

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
    select              = randi(2,1);    
    thisAngle           = p.scr.angleSet(select);           % random selection
    lr.gratAngle(f)     = thisAngle;                        % save to lr structure
    
    % grating position
    thisXOffset         = p.scr.gratPosCenterX( thisQuad); % p.scr.offsetXSet( thisQuad);
    thisYOffset         = p.scr.gratPosCenterY( thisQuad); % p.scr.offsetYSet( thisQuad);
    lr.gratQuad(:,f)    = [thisXOffset, thisYOffset];
    %dstRectGrat         = OffsetRect( gratTexRect, thisXOffset -gratTexRect(3)/2, thisYOffset -gratTexRect(4)/2); %thisXOffset, thisYOffset);
    dstRectSine         = OffsetRect( sineTexRect, thisXOffset -sineTexRect(3)/2, thisYOffset -sineTexRect(4)/2); %thisXOffset, thisYOffset);

    % Draw the gratings
    Screen('DrawTexture', p.scr.window, sineTex, sineTexRect, dstRectSine, tilt, [], [], [], [], [], [phase, freq, contrast, 0]);
    %Screen('DrawTexture', p.scr.window, gratTex, gratTexRect, dstRectGrat, thisAngle, [], [], ...
    %    [], [], [], [p.scr.phaseGrat+180, p.scr.freqGrat, p.scr.contrastGrat, 0]);
    %Screen('DrawTexture', p.scr.window, texGrat(1), [], [], thisRotation); % Screen('DrawTextures', windowPointer, texturePointer(s) [, sourceRect(s)] [, destinationRect(s)] [, rotationAngle(s)] [, filterMode(s)] [, globalAlpha(s)] [, modulateColor(s)] [, textureShader] [, specialFlags] [, auxParameters]);
    
    % DRAW FIXATION gaussian 
    %Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw cue fixation cross with red arm pointing to attentional quadrant
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    Screen('DrawTextures', p.scr.window, gaussTex, gaussTexRect, [dstRectFix;dstRectFixInner]', [], [], [], [], [], kPsychDontDoRotation, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1; p.scr.fixInnerContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]');

    % Draw smaller center dot
    %Screen('DrawTexture', p.scr.window, gaussTex, gaussTexRect, dstRectFixInner, [], [], [], [], [], kPsychDontDoRotation, [p.scr.fixContrast, p.scr.fixSc, p.scr.fixAspectRatio, 1]);
    %Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    %Screen('DrawTexture',p.scr.window, gaus_fix_texSmall,[],[],[],[],[],[p.scr.white]) % [p.scr.fixColorChange]
    
    % FLIP 
    thisWaitTime =  p.scr.stimDur -(0.9 *p.scr.flipInterval);
    [vbl] = Screen('Flip', p.scr.window, vbl+thisWaitTime); % next flip
     
    trialStart(f) = vbl;
%     lr.time.trialStart = vbl;
%     timePassed = GetSecs - trialSetup;          % account for time since trial started to keep overall trial time consistent
     
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
%             audioOpen(p)
%             PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
%             PsychPortAudio('Start', p.aud.handle, 1, 0, 1);     % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
%             PsychPortAudio('Stop', p.aud.handle, 1);
%             PsychPortAudio('Close', p.aud.handle);
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

%     lr.time.trialEnd(f) = GetSecs;
%     lr.time.trialDur(f) = lr.time.trialEnd(f) - lr.time.trialSetup(f);
    if f == p.series.stimPerSeries
        runFix = 0;
    end
end  % end of trial f-loop
lr.trialStart = trialStart;
lr.trialDur = trialStart(2:end) - trialStart(1:( end-1));

lr.time.seriesEnd = GetSecs;
lr.time.seriesDur = lr.time.seriesEnd - lr.time.seriesStart; 

% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('LOCALIZER_','SeriesEND',lr.number);
    Eyelink('message', messageText)
end

end % while loop

end % end function
