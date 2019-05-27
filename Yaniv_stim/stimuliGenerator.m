function Stim = stimuliGenerator(Params, Stim)
% This function takes the trial plan and poplulates it with stimuli

% Show please wait message
DrawFormattedText(Params.w, 'Preparing stimuli, please wait', 'center',...
    'center',[],[],[],[],2,0);
Screen('Flip',Params.w);
    
% Preallocate for speed
if sum([Stim.isAud])
    Stim(end).audStim = 0;
end
if sum([Stim.isVis])
    Stim(end).visStim = 0;
end

% Call the stimuli functions
for ii = 1:length(Stim)
    %disp(ii)
    if Stim(ii).isAud
        Stim(ii).audStim = mkAudNoiseStim(Params, Stim(ii));
    else
        Stim(ii).audStim = zeros(2,round(Stim(ii).trialDuration/1000*Params.audFs));    % Quiet for no stimulus
    end
    
    if Stim(ii).isVis
        Stim(ii).visStim = mkVisGratingStim(Params, Stim(ii));
    else
        Stim(ii).visStim = mkEmptyVisStim(Params);  % Empty stimulus for unimodal
    end
%     DrawFormattedText(Params.w, num2str(ii), 'center',...
%     'center',[],[],[],[],2,0);
% Screen('Flip',Params.w);
end
end