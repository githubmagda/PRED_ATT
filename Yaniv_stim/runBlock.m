function Logger = runBlock(Params, Stim, nTrial)
% This script runs a block of trials w/ insturctions, and updates the
% Logger structure.

try
    
    % Preallocate for speed
    NTrials = length(Stim);
    
    % Set up Logger and preallocate for speed
    Logger = struct('subject',[],'trial',[],'isAud',[],'isVis',[],'type',[],...
        'trialDuration',[],'ITI',[], 'relOnset', [], 'audStimOnsetFrames',[],'audStimOnset',...
        [],'audTargOnsetFrames',[],'audTargOnset',[],'audTargLevel',[],...
        'audStim',[],'audTrialEnd',[],'visStimOnsetFrames',[],'visStimOnset',...
        [],'visStimOrientation',[],'visTargOnsetFrames',[],'visTargOnset',[],'visTrueOnset', [],...
        'visTargDuration', [], 'visTargLevel', [], 'visTargLoc', [],...
        'visTargEcc', [], 'visStim',[],'visTrialEnd',[],'response',[],'RT',[], ...
        'keys',[], 'respMap', []);
    Logger(NTrials).trial = NTrials;
    
    % Up the priority
    Priority(1);
    
    % Trial and insturctions loop
    counter = 1;
    t = 1;
    
    while t <= length(Stim)
        
        % Insert instructions before trial if needed, and ITI before 1st trial
        if isfield(Stim,'instructions')&& ~isempty(Stim(t).instructions)
            response = doInstructions(Params, Stim(t).instructions);
            % Check for eyetracking user events
            while 1
                switch response
                    case Params.calibKey
                        if Params.EyeLink
                            EyelinkDoTrackerSetup(Params.el);
                            break
                        else
                            response = doInstructions(Params, Stim(t).instructions);
                        end
                    case Params.quitKey
                        if Params.EyeLink
                            doQuit = Ask(Params.w,'Quit eyetracking? (1 - yes, 0 - no): ',[],Params.grey,'GetChar','center','center');
                            if doQuit
                                closeEyeLink();
                                Params.EyeLink = 0;
                                break
                            else
                                response = doInstructions(Params, Stim(t).instructions);
                            end
                        else
                            response = doInstructions(Params, Stim(t).instructions);
                        end
                    otherwise
                        break
                end
            end
            
            
            WaitSecs((rand()*(Params.ITIRange(2)-Params.ITIRange(1))+ ...
                Params.ITIRange(1))/1000);
        elseif t == 1
            WaitSecs((rand()*(Params.ITIRange(2)-Params.ITIRange(1))+ ...
                Params.ITIRange(1))/1000);
        end
        
        % Load stimuli and wait the load time
        PsychPortAudio('FillBuffer', Params.playSlave, Stim(t).audStim);         % load stimulus to playback slave sound buffer
        
        if Stim(t).isVis
            drawFixation(Params);
            Screen('Flip', Params.w);
        end
        disp(Stim(t));  % Print trial params to shell
        
        if Params.EyeLink
            policeFixation(Params,counter); % Wait for fixation creiteria
        end
        
        if t>1
            WaitSecs(Params.ITILoadTime/1000 - (GetSecs() - loadTimeStart));
        end
        
        % Do the trial
        data = doTrial(Params, Stim(t),counter);
        
        loadTimeStart = GetSecs();
        % Add trial data to general Logger
        for jj = transpose(fieldnames(data))
            Logger = setfield(Logger,{counter},jj{:},getfield(data,jj{:}));
        end
        Logger(counter).trial = counter;
        
        t = t + 1;
        
        % Check for fixation violated trial and re-insert
        if Logger(counter).response == -1
            t = t - 1; % roll that back
            Stim = [Stim(1:(t-1)) Stim(t+1:end) Stim(t)]; % Re insert trial
            Stim(end).instructions = [];
        end
        
        counter = counter+1;
    end
    
    % Return priority
    Priority(0);
    
    % Remove auditory stimuli from Logger to lighten memory load
    Logger = rmfield(Logger,'audStim');
catch
    Priority(0);
    return
end
end