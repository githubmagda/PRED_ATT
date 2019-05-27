function Stim = trialPlanner(Params, Block)
% Produces a Stim struct that outlines all the parameters for each trial.
% Recieves Params - gloabal experiment parameter struct, and Block - the
% outline sketch of the trial plan to build. Right now only audio only
% blocks support multitarget trials

% Set default values from Params
for ii = {'keepClear','trialDuration', 'keys', 'respMap'}
    if isfield(Block,ii)
        eval([ii{:} ' = Block.' ii{:} ';']);
    else
        eval([ii{:} ' = Params.' ii{:} ';']);
    end
end

% Round keepClear and trialDuration to updated ifi
keepClear = time2flips(Params,keepClear); %#ok<NODEF>
trialDuration = round2flips(Params,trialDuration); %#ok<NODEF>

% Create trial plan
if Block.isExp
    onsets1stim = time2flips(Params, Params.onsetRange1stStim(1)):Params.onsetRes:time2flips(Params, Params.onsetRange1stStim(2));
    onsets1stim = [ones(1,length(onsets1stim)); onsets1stim];
    onsets2stim = time2flips(Params, Params.onsetRange2ndStim(1)):Params.onsetRes:time2flips(Params, Params.onsetRange2ndStim(2));
    onsets2stim = [ones(1,length(onsets2stim))*2; onsets2stim];
    targOnsets = [onsets1stim onsets2stim];
    targOnsets = [[targOnsets; ones(1,length(targOnsets))] [targOnsets; zeros(1,length(targOnsets))]]; % Repeat for auditory and visual, third row indicates which is first (1 -visual, 0 - auditory)
    targOnsets = repmat(targOnsets, 1, Params.expRepPerBin);
    
    % Shuffle onsets
    shuffler = Shuffle(1:size(targOnsets,2));
    targOnsets = targOnsets(:,shuffler);
        
    secondStimOnset = Shuffle(time2flips(Params,Params.SecondStimulusOnsetRange(1)):...
        Params.onsetRes:time2flips(Params,Params.SecondStimulusOnsetRange(2)));
    
    % Preallocate for speed
    if Block.isAll
        NTrials = length(targOnsets);
    else
        NTrials = Block.NTrials;
    end
    
    NCatch = round(Block.catchRatio*NTrials/(1-Block.catchRatio)); % Calculate number of catch trials
    if isnan(NCatch); NCatch = 0; end;
    Stim(NTrials+NCatch).isAud = 1;
    
    % Create experimental trials
    for t = 1:NTrials
        Stim(t).isAud = 1;
        Stim(t).isVis = 1;
        
        if targOnsets(3,t)
            Stim(t).visStimOnsetFrames = 1;
            Stim(t).audStimOnsetFrames = secondStimOnset(mod(t,length(secondStimOnset))+1);
            
            if targOnsets(1,t) == 1
                Stim(t).relOnset = targOnsets(:,t);
                Stim(t).visTargOnsetFrames = targOnsets(2,t) + Stim(t).audStimOnsetFrames;
                Stim(t).visTargLevel = Block.visTargLevel;
                Stim(t).audTargOnsetFrames = [];
                Stim(t).audTargLevel = [];
                Stim(t).type = 1;
            else
                Stim(t).relOnset = targOnsets(:,t);
                Stim(t).visTargOnsetFrames = [];
                Stim(t).visTargLevel = [];
                Stim(t).audTargOnsetFrames = targOnsets(2,t) + Stim(t).audStimOnsetFrames;
                Stim(t).audTargLevel = Block.audTargLevel;
                Stim(t).type = 0;
            end
        else
            Stim(t).visStimOnsetFrames = secondStimOnset(mod(t,length(secondStimOnset))+1);
            Stim(t).audStimOnsetFrames = 1;
            
            if targOnsets(1,t) == 1
                Stim(t).relOnset = targOnsets(:,t);
                Stim(t).visTargOnsetFrames = [];
                Stim(t).visTargLevel = [];
                Stim(t).audTargOnsetFrames = targOnsets(2,t) + Stim(t).visStimOnsetFrames;
                Stim(t).audTargLevel = Block.audTargLevel;
                Stim(t).type = 0;
            else
                Stim(t).relOnset = targOnsets(:,t);
                Stim(t).visTargOnsetFrames = targOnsets(2,t)  + Stim(t).visStimOnsetFrames;
                Stim(t).visTargLevel = Block.visTargLevel;
                Stim(t).audTargOnsetFrames = [];
                Stim(t).audTargLevel = [];
                Stim(t).type = 1;
            end
        end
        
        Stim(t).trialDuration = trialDuration;
        Stim(t).ITI = rand()*(Params.ITIRange(2)-Params.ITIRange(1))+Params.ITIRange(1);
        
        if Stim(t).type == 1
            % Visual target location
            [Stim(t).visTargLoc, Stim(t).visTargEcc] = getVisTargLoc(Params); 
        end
        
        Stim(t).visStimOrientation = rand() * 180;
        
        % Add some data variables that are just computations over other
    % variables, for convenient reading of Logger
    Stim(t).visTargOnset = (Stim(t).visTargOnsetFrames -1) * ...
        Params.Display.flipInterval;
    Stim(t).audTargOnset = (Stim(t).audTargOnsetFrames -1) * ...
        Params.Display.flipInterval;
    Stim(t).audStimOnset = (Stim(t).audStimOnsetFrames) * ...
        Params.Display.flipInterval;                    % this is already calculated in mkAudStim
    Stim(t).visStimOnset = (Stim(t).visStimOnsetFrames -1) * ...
        Params.Display.flipInterval;
    end
    
    %Create catch trials
    
    if Block.catchRatio
        for ii=NTrials+1:NTrials+NCatch
            Stim(ii).isAud = 1;
            Stim(ii).isVis = 1;
            Stim(ii).audStimOnsetFrames = 0;
            Stim(ii).type = 2;
            Stim(ii).audTargLevel = 0;
            Stim(ii).audTargOnsetFrames = [];
            Stim(ii).trialDuration = trialDuration;
            Stim(ii).ITI = rand()*(Params.ITIRange(2)-Params.ITIRange(1))+Params.ITIRange(1);
            Stim(ii).visStimOnsetFrames = 0;
            Stim(ii).visTargLevel = 0;
            Stim(ii).visTargOnsetFrames = [];
            Stim(ii).visTargLoc = [];
            Stim(ii).visStimOrientation = rand() * 180;
        end
    end
elseif Block.isAud && isfield(Block, 'audTargLevel')
    % Allow for scalar repetitions
    if length(Block.repetitions) == 1
        Block.repetitions = repmat(Block.repetitions,1,size(Block.audTargLevel,2));
    end
    
    % Preallocate for speed
    NTrials = sum(Block.repetitions);
    NCatch = round(Block.catchRatio*NTrials/(1-Block.catchRatio)); % Calculate number of catch trials
    if isnan(NCatch); NCatch = 0; end;
    Stim(NTrials+NCatch).isAud = 1;
    
    % Possible target onsets
    onsets = Shuffle(keepClear(1):Params.onsetRes:...
        (time2flips(Params,trialDuration) - keepClear(2))) * Params.Display.flipInterval;
    
    % Create experimental trials
    counter = 1;
    onsetCounter = 1;
    for l = 1:size(Block.audTargLevel,2)
        for r = 1:Block.repetitions(l)
            Stim(counter).isAud = 1;
            Stim(counter).isVis = Block.isVis;
            Stim(counter).audStimOnset = 0;
            Stim(counter).audTargLevel = Block.audTargLevel(:,l);
            Stim(counter).type = 0;
            Stim(counter).trialDuration = trialDuration;
            Stim(counter).ITI = rand()*(Params.ITIRange(2)-Params.ITIRange(1))+Params.ITIRange(1);

            if Block.isVis  % if we want ongoing vis stim with auditory
                Stim(counter).visTargOnsetFrames = [];
                Stim(counter).visTargLevel = [];
                Stim(counter).visStimOnsetFrames = 1;
                Stim(counter).visTargOnset = [];
                Stim(counter).visStimOnset = 0;
                Stim(counter).visStimOrientation = rand() * 180;
                Stim(counter).audStimOnsetFrames = 1;
            end
            
            if size(Block.audTargLevel,1) == 1
                Stim(counter).audTargOnset = onsets(mod(onsetCounter,length(onsets))+1);
                Stim(counter).audTargOnsetFrames = time2flips(Params,Stim(counter).audTargOnset);
                onsetCounter = onsetCounter + 1;
            else
                for ii = 1:size(Block.audTargLevel,1)
                    Stim(counter).audTargOnset(ii) = onsets(mod(onsetCounter,length(onsets))+1) + Stim(counter).trialDuration * (ii-1);
                    Stim(counter).audTargOnsetFrames = time2flips(Params,Stim(counter).audTargOnset);
                    onsetCounter = onsetCounter + 1;
                end
            end
            counter = counter + 1;
            if ~mod(onsetCounter, length(onsets))
                onsets = Shuffle(onsets);   %Shuffle after every run through possible onset times
            end
        end
    end
    
    %Create catch trials
    if Block.catchRatio
        for ii=1:NCatch
            Stim(counter).isAud = 1;
            Stim(counter).isVis = Block.isVis;
            Stim(counter).audStimOnset =  0;
            Stim(counter).type = 2;
            Stim(counter).audTargLevel = 0;
            Stim(counter).audTargOnset = [];
            Stim(counter).trialDuration = trialDuration;
            Stim(counter).ITI = rand()*(Params.ITIRange(2)-Params.ITIRange(1))+Params.ITIRange(1);
            Stim(counter).visTargOnsetFrames = [];
            Stim(counter).visTargLevel = [];
            Stim(counter).visStimOnsetFrames = 1;
            Stim(counter).visTargOnset = [];
            Stim(counter).visStimOnset = 0;
            Stim(counter).visStimOrientation = rand() * 180;
            Stim(counter).audStimOnsetFrames = 1;

            counter=counter+1;
        end
    end
else
    % Allow for scalar repetitions
    if length(Block.repetitions) == 1
        Block.repetitions = repmat(Block.repetitions,1,size(Block.visTargLevel,2));
    end 
    
    % Preallocate for speed
    NTrials = sum(Block.repetitions);
    NCatch = round(Block.catchRatio*NTrials/(1-Block.catchRatio)); % Calculate number of catch trials
    if isnan(NCatch); NCatch = 0; end;
    Stim(NTrials+NCatch).isVis = 1;
    
    % Possible target onsets
    onsets = Shuffle(keepClear(1):Params.onsetRes:...
        (time2flips(Params,trialDuration) - keepClear(2)));
    
    % Create experimental trials
    counter = 1;
    onsetCounter = 1;
    for l = 1:size(Block.visTargLevel,2)
        for r = 1:Block.repetitions(l)
            Stim(counter).isAud = Block.isAud;
            Stim(counter).isVis = 1;
            Stim(counter).visStimOnsetFrames = Block.isAud;
            Stim(counter).visStimOnset = 0;
            Stim(counter).visTargLevel = Block.visTargLevel(:,l);
            Stim(counter).type = 1;
            Stim(counter).trialDuration = trialDuration;
            Stim(counter).ITI = rand()*(Params.ITIRange(2)-Params.ITIRange(1))+Params.ITIRange(1);
            Stim(counter).audStimOnsetFrames = 1;
            Stim(counter).audStimOnset = 0;
            Stim(counter).audTargOnsetFrames = [];
            Stim(counter).audTargLevel = [];

            % Target location
            [Stim(counter).visTargLoc, Stim(counter).visTargEcc] = getVisTargLoc(Params);
            
            Stim(counter).visStimOrientation = rand() * 180;
            
            if size(Block.visTargLevel,1) == 1
                Stim(counter).visTargOnsetFrames = onsets(mod(onsetCounter,length(onsets))+1);
                Stim(counter).visTargOnset = (Stim(counter).visTargOnsetFrames - 1) * Params.Display.flipInterval;
                onsetCounter = onsetCounter + 1;
            else
                for ii = 1:size(Block.visTargLevel,1)
                    Stim(counter).visTargOnsetFrames(ii) = onsets(mod(onsetCounter,length(onsets))+1) + Stim(counter).trialDuration * (ii-1);
                    Stim(counter).visTargOnset = (Stim(counter).visTargOnsetFrames - 1) * Params.Display.flipInterval;
                    onsetCounter = onsetCounter + 1;
                end
            end
            counter = counter + 1;
            if ~mod(onsetCounter, length(onsets))
                onsets = Shuffle(onsets);   %Shuffle after every run through possible onset times
            end
        end
    end
    
    %Create catch trials
    if Block.catchRatio
        for ii=1:NCatch
            Stim(counter).isAud = Block.isAud;
            Stim(counter).isVis = 1;
            Stim(counter).visStimOnsetFrames = Block.isAud;
            Stim(counter).visStimOnset = 0;
            Stim(counter).type = 2;
            Stim(counter).visTargLevel = 0;
            Stim(counter).visTargOnset = [];
            Stim(counter).trialDuration = trialDuration;
            Stim(counter).ITI = rand()*(Params.ITIRange(2)-Params.ITIRange(1))+Params.ITIRange(1);
            Stim(counter).visTargLoc = [];
            Stim(counter).visStimOrientation = rand() * 180;

            if Block.isAud  % if we want ongoing vis stim with auditory
                Stim(counter).audTargOnsetFrames = [];
                Stim(counter).audTargLevel = [];
                Stim(counter).audStimOnsetFrames = 1;
                Stim(counter).audStimOnset = 0;
            end

            counter=counter+1;
        end
    end
    
end
Stim=Shuffle(Stim);   %Shuffle trial plan

for t = 1:length(Stim)
    Stim(t).keys = keys;
    Stim(t).respMap = respMap;
end
end