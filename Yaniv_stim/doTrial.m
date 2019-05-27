function trialData = doTrial(Params, Trial,nTrial)
% This function handles the running of a single trial. It recieves
% parameters in two structs - Params for parameters that are constant
% across experiments, Trial for parameters that vary with each trial.

% auxParam  = zeros(4, 1);

% if Trial.isAud && Trial.isVis ---- removed option of no window trial type
% to simplify 20160717. Consider deleting

try
    if isempty(Trial.audStimOnsetFrames) || Trial.audStimOnsetFrames < 2   % if aud stim is first
        audWaitForStart = 1;    % Wait for start to allow sync
    else                        % will have enough time to sync anyway
        audWaitForStart = 0;
    end
    
    srcRect = [0 0 Trial.visStim.visiblesize Trial.visStim.visiblesize];
    vbl = -ones(1,time2flips(Params,Trial.trialDuration));
    RT=-1;                                             % Missing value
    response=0;
    fixationViolations = 0;
    
    targFrames = Trial.visTargOnsetFrames:(Trial.visTargOnsetFrames +...
        time2flips(Params,Params.visTargDuration) - 1);
    visStimFrames = Trial.visStimOnsetFrames:...
        (time2flips(Params, Trial.trialDuration) -1);
    thisFrame = 0;      % Frame counter
    
    %Start ET
    if Params.EyeLink
        Eyelink('StartRecording', 1, 1, 1, 1);
    end
    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data
    WaitSecs(0.1);
    if Params.EyeLink
        Eyelink('Message', 'TRIALID %d', nTrial);
    end
    
    % Get vbl-synchronized time for audio playback
    drawFixation(Params);
    vbl(1) = Screen('Flip', Params.w); % -1 on flip timeline
    
    audWhen = vbl(1) + ...
        (Params.Display.flipInterval + ...
        Trial.audStimOnsetFrames*Params.Display.flipInterval)/1000; % When should auditory stimulus start
    
    PsychPortAudio('Start', Params.playSlave, [], audWhen, ...
        audWaitForStart);   % Start playback
    
    endTime = vbl(1) + (Params.Display.flipInterval + round2flips(Params, Trial.trialDuration))/1000;
    
    if Params.EyeLink && Trial.isAud
        if audWaitForStart
            Eyelink('message', 'audStimStart'); %send datafile message that aud stim started
        else
            disp(sprintf('audStimStart_%d', round((audWhen - GetSecs)*1000)));
            Eyelink('message', 'audStimStart_%d', round((audWhen - GetSecs)*1000)); %send datafile message when aud stim will start in ms
        end
    end
    
    targSent = 0;
    visStimSent = 0;
    while vbl(end) < endTime
        thisFrame = thisFrame +1;
        
        
        % Draw everything
        if Trial.type==1 && sum(thisFrame == targFrames)
            % Draw with target
            Screen('FillRect', Params.w , Params.trgColor, Params.diodeRect)
            Screen('DrawTexture', Params.w, Trial.visStim.gratingTex,  ...
                srcRect, Trial.visStim.dstRect, Trial.visStimOrientation);
            Screen('DrawTexture', Params.w, Trial.visStim.targetTex, ...
                srcRect, Trial.visStim.dstRect, Trial.visStimOrientation);
            
            if Params.EyeLink && ~targSent
                Eyelink('message', 'VisualTarget'); %send datafile message that trial starts
                targSent = 1;
            end
        elseif sum(thisFrame == visStimFrames)
            % Draw w/o target
            Screen('FillRect', Params.w , Params.stimColor, Params.diodeRect)
            Screen('DrawTexture', Params.w, Trial.visStim.gratingTex,  ...
                srcRect, Trial.visStim.dstRect, Trial.visStimOrientation);
            
            if Params.EyeLink && ~visStimSent
                Eyelink('message', 'visStimStart', audWhen - GetSecs); %send datafile message that trial starts
                visStimSent = 1;
            end
        end
        
        drawFixation(Params); % Draw fixation
        Screen('DrawingFinished',Params.w); % For efficacy
        vbl(thisFrame+1) = Screen('Flip', Params.w);
        
        
        % Check fixation
        if Params.EyeLink
            evt = Eyelink('newestfloatsample');
            currentX= evt.gx(Params.policeEye); % gx= the gaze position for X; 1 is the left eye so we are accessing the left eye in the matlab array
            currentY= evt.gy(Params.policeEye); % gy= gaze position for Y; same as above
            
            if currentX~=Params.el.MISSING_DATA && currentY~=Params.el.MISSING_DATA && evt.pa(1)>0         % do we have valid data and is the pupil visible?
                if ~((currentX < (Params.fixPoliceX + Params.fixTrialPoliceSize)) &&  (currentX > (Params.fixPoliceX - Params.fixTrialPoliceSize)) ... % is it near X center
                        && (currentY < (Params.fixPoliceY + Params.fixTrialPoliceSize)) && (currentY > (Params.fixPoliceY - Params.fixTrialPoliceSize))) % is it near Y center
                    fixationViolations = fixationViolations + 1;
                else
                    fixationViolations = 0;
                end
            end
        end
        
        if fixationViolations >= Params.fixViolNum
            response=-1; %marks fixation broken
            startITI = GetSecs();
            PsychPortAudio('Start',Params.AMSlave); % Turn audio off
            sound(Params.errorBeep, 44100); % Obnoxious sound
            WaitSecs(Params.waitAfterPolice / 1000);
            break
        else                                    % OK to get response
            % Get response
            [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
            if key_is_down
                if sum(key_code(Trial.keys))
                    response= Trial.respMap(key_code==1);
                    RT=GetSecs()-vbl(2);
                    startITI = GetSecs();
                    PsychPortAudio('Start',Params.AMSlave); % Turn audio off
                    break
                elseif key_code(Params.KeyEsc)
                    sca;
                    PsychPortAudio('Close',Params.pahandle);
                    break;
                end
            end
        end
    end
    
    % Remove stimuli
    drawFixation(Params);
    Screen('DrawingFinished',Params.w); % For efficacy
    vblEnd = Screen('Flip', Params.w);
    
    % Stop eyelink
    if Params.EyeLink
        Eyelink('message', 'TrialEnd');
        Eyelink('stoprecording'); %stop recording to end this trial (important for trial parsing w/ data viewer)
    end
    
    % Stop play back entirely
    WaitSecs(Params.rampOffDuration/1000);
    PsychPortAudio('Stop',Params.playSlave);      % Stop playback
    PsychPortAudio('Stop',Params.AMSlave);        % Stop AM
    
    % Wait ITI with chance for response
    if response == 0
        startITI = GetSecs;
        while GetSecs()-vbl(2) < (Trial.trialDuration + Trial.ITI - Params.ITILoadTime)/1000
            WaitSecs(0.01);     % Prevent CPU overload
            [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
            if key_is_down
                if sum(key_code(Trial.keys))
                    response=Trial.respMap((key_code==1));
                    RT=GetSecs()-vbl(2);
                    break
                elseif key_code(Params.KeyEsc)
                    sca;
                    break;
                end
            end
        end
    end
    % Wait for release of all keys on keyboard:
    KbReleaseWait;                          % Wait to prevent "stuck keys subjects"
    
    WaitSecs((Trial.ITI - Params.ITILoadTime)/1000 - (GetSecs()-startITI)); % wait ITI
    
    trialData = Trial;
    trialData.subject = Params.SubjectNumber;
    trialData.response = response;
    trialData.RT = RT*1000;     % Output in ms
    trialData.visTrialEnd = (vblEnd - vbl(2))*1000;
    
    if Trial.type==1
        trialData.visTrueOnset = (vbl(targFrames(1)+1) - vbl(2))*1000;
        trialData.visTargDuration = (vbl(targFrames(end)+2) - vbl(2))*1000 - trialData.visTrueOnset;
    end
    
    trialData.vbl = vbl;
    
catch
    return
end
end

