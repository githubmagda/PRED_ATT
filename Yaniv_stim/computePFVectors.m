function [Logger, CountCorrect, OutOf, CatchProp, wrongKey]=computePFVectors(Params, Logger, StimLevels)
% Compute psychofit vectors from Logger, and add accuracy to Logger. Input
% - experiment parameters, block logger, and vector contatining stimLevel

%% Adapt variables to new structs
EffectDuration = Params.audTargDuration;
CutOffRange = Params.RTCutoff;

%% Calculate accuracy and save it to Logger
for i=1:length(Logger)
    if Logger(i).type==2   % If this a catch trial
        Logger(i).acc=(Logger(i).response==0);  % Correct is no response, response is FA
    else                %If this isn't a catch trial
        if Logger(i).type == 0
            onset = Logger(i).audTargOnset;
        else
            onset = Logger(i).visTargOnset;
        end
        if ~Logger(i).response || Logger(i).response == -1         % If there is no response
            Logger(i).acc=0;     % Miss
        elseif isfield(Logger,'keys') && length(Logger(i).keys) == 2 && ...
                ((Logger(i).type == 0 && Logger(i).response ~= Params.audIs) || ...
                (Logger(i).type == 1 && Logger(i).response ~= mod(Params.audIs,2) + 1))
            Logger(i).acc = 4;  % wrong key
        elseif Logger(i).RT<onset+CutOffRange(2)+EffectDuration && Logger(i).RT>onset+CutOffRange(1);    %if RT was within time and not too soon
            Logger(i).acc=1;     % Hit
        elseif Logger(i).RT>onset+CutOffRange(2)+EffectDuration %If too late
            Logger(i).acc=2;     % Too late
        else                    % Too soon
            Logger(i).acc=3;     % Too soon
        end
    end
end

%% Save accuracy to Palamedes friendly variables
% Backwards compatability to one type blocks:
if ~isstruct(StimLevels)
    oldStim = StimLevels;
    StimLevels = [];
    StimLevels.vis = oldStim;
    StimLevels.aud = oldStim;
end


CountCorrect.vis=zeros(1,length(StimLevels.vis));
CountCorrect.aud=zeros(1,length(StimLevels.aud));
OutOf=CountCorrect;
Catch=0;
CatchOutOf=0;

%Sum correct responses and repetitions
%Do this without trials aborted b/c of eyetracking
realLogger = Logger([Logger.response] ~= -1);

for i=1:length(realLogger)
    switch realLogger(i).type
        case 0
            for j=1:length(StimLevels.aud)
                if realLogger(i).audTargLevel == StimLevels.aud(j)
                    CountCorrect.aud(j)=CountCorrect.aud(j)+(realLogger(i).acc==1);
                    OutOf.aud(j)=OutOf.aud(j)+1;
                end
            end
        case 1
            for j=1:length(StimLevels.vis)
                if realLogger(i).visTargLevel == StimLevels.vis(j)
                    CountCorrect.vis(j)=CountCorrect.vis(j)+(realLogger(i).acc==1);
                    OutOf.vis(j)=OutOf.vis(j)+1;
                end
            end
        case 2
            CatchOutOf=CatchOutOf+1;
            Catch=Catch+realLogger(i).acc;
    end
end
CatchProp=Catch/CatchOutOf;
wrongKey = sum([Logger.acc] == 4);

% Again for backwards compatability
if sum(OutOf.vis) == 0  %There were no trials
    CountCorrect = CountCorrect.aud;
    OutOf = OutOf.aud;
elseif sum(OutOf.aud) == 0  %There were no trials
    CountCorrect = CountCorrect.vis;
    OutOf = OutOf.vis;
end
end
