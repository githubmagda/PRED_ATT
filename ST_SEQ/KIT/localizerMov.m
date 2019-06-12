function[p, lr] = localizer(p, lr)

% This script displays the localizer in the 4 quadrant gratings,

% PRESENT STIMULI
% uses only localizer texture 
texGrat = p.textures.texGratLocalizer;

% texGratFlash = p.textures.texGratFlash; % texture with predictive element
% gaus_attn_tex = p.textures.gaus_attn_tex; % attentional dot
gaus_fix_tex = p.textures.gaus_fix_tex; % fixation gaussian

% DRAW PRE-SERIES FIXATION GUASSIAN 
% Draw gaussian
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white) % [p.scr.fixColorChange]
% Draw cue fixation cross with red arm pointing to attentional quadrant
Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
% Draw smaller center dot
Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2*p.scr.fixRadiusInner  );

% FLIP
Screen('Flip', p.scr.window);

% START POLICING FIXATION
if p.useEyelink == 1
    monitorFixation(p, lr);
else
    WaitSecs(p.preSeriesFixTime); % just show cross 
end

% DISPLAY SEQUENCE 

% EYETRACKER SEND MESSAGE to .edf file
if p.useEyelink
    messageText = strcat('LOCALIZER_START_', num2str(lr.number) );
    Eyelink('message', messageText)
end
lr.time.seriesStart = GetSecs;

for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
    
    trialStart = GetSecs;
    tr.time.trialStart(f) = trialStart;
    thisQuad = lr.series(f);
    thisRotation = ( thisQuad-1 ) * 90; % rotation to put flash in correct quadrant

    % SEND MESSAGE to EYETRACKER .edf file
    if p.useEyelink
        messageText = strcat('LOCALIZER_', num2str(lr.number), 'TRIAL_START', num2str(f)); 
        Eyelink('Message', messageText);
    end
    
    for ff = 1 : p.scr.framesPerMovie
         
        frame.number = ff;
        frameStart = GetSecs;
        tr.time.frameStart(ff) = frameStart;
        
        % DRAW TEXTURE
        Screen('DrawTexture', p.scr.window, texGrat(ff), [], [], thisRotation); % Screen('DrawTextures', windowPointer, texturePointer(s) [, sourceRect(s)] [, destinationRect(s)] [, rotationAngle(s)] [, filterMode(s)] [, globalAlpha(s)] [, modulateColor(s)] [, textureShader] [, specialFlags] [, auxParameters]);
        
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat('Series_', num2str(lr.number) );
            Eyelink('message', messageText);
        end
        
        % DRAW fixation gaussian
        Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
        % Draw the cue fixation cross
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        % Draw smaller center dot
        Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
        %Screen('DrawTexture',p.scr.window, gaus_fix_texSmall,[],[],[],[],[],[p.scr.white]) % [p.scr.fixColorChange]
        
        % routine for if eyes wander away change center dot and attn pointer to red
        if p.useEyelink && fr.outOfBounds
            Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, attn, [ p.scr.centerX, p.scr.centerY ], 2);
            Screen('FillOval', p.scr.window, p.scr.fixColorChange, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
            % send message to .edf file
            messageText = ['gazeOutOfBounds_', 'Series',num2str( slr.number), 'thisQuad', thisQuad];
            Eyelink('message',messageText);
        end

        % FLIP
        [vbl, stim, flip, ~,~] = Screen('Flip', p.scr.window, 0, 0); % [] [displayTime] [don't clear]
   
        % SEND EYETRACKER MESSAGE
        if p.useEyelink
            messageText = strcat(['SERIES',num2str(lr.number), 'TRIAL',num2str(lr.number),'FRAME',num2str(frame.number),'Cue', thisCue, 'Pred', thisPred, 'dotTime',]);
            Eyelink('message',messageText);
        end
        
        % record times to trial level
        tr.time.frameEnd(ff) = GetSecs;
        tr.time.frameDur(ff) = tr.time.frameEnd(ff) - tr.time.frameStart(ff);        
        waitTime = p.scr.frameDur - tr.time.frameDur(ff) - .5*p.scr.flipInterval; %% CHECK
        WaitSecs(waitTime);
        
% %         % name/number frame and add to trial structure
% %         frName = sprintf('fr%d',ff);
% %         lr.(frName) = frame;
        
    end % end of frame ff-loop
    
    if p.useEyelink
        Eyelink('GetQueuedData?') % [samples, events, drained] = Eyelink('GetQueuedData'[, eye])
    end

    % SEND EYETRACKER MESSAGE
    if p.useEyelink
        messageText = strcat('LOCALIZER_', 'TRIALEND_%d', f);
        Eyelink('message', messageText)
    end
    
    % get trial timings and add to series structure
    tr.time.trialEnd(f) = GetSecs;
    tr.time.trialDur(f) = tr.time.trialEnd(f) - tr.time.trialStart(f);
    
    % name/number trial and add to series structure
    trName = sprintf('tr%d',f);
    lr.(trName) = tr;
    
end  % end of trial f-loop
lr.time.seriesEnd = GetSecs;
lr.time.seriesDur = lr.time.seriesEnd - lr.time.seriesStart;
lr;

% SEND EYETRACKER MESSAGE
if p.useEyelink
    messageText = strcat('LOCALIZER_','SeriesEND',lr.number);
    Eyelink('message', messageText)
end

% record series times
lr.time.seriesEnd = GetSecs;
lr.time.seriesDuration = lr.time.seriesEnd - lr.time.seriesStart;

