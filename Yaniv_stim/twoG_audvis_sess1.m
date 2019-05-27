%% Main experiment file - session 1 - thresholding session
% Stim.type = 0 - target in auditory modality, 1 - target in visual
% modality, 2 - catch trial
% -----------------------------------------------------------------------

%% Prep files
clear
close all

% Close audio device if open
try
    PsychPortAudio('Close',0);
catch
end

KbName('UnifyKeyNames');
% PsychDebugWindowConfiguration

addpath('../Libraries/palamedes1_8_1/Palamedes/');  %add palamedes to path

Params.SubjectNumber=input('subject number?\n');
Params.SubjectInitials = input('Initials?\n', 's');


twoGaudvisParams;       % Load params

% Error sound for eyetracking
load('errorBeep');
Params.errorBeep = errorBeep;

Params.experimentStart = datestr(now,'yymmddHHMMSS'); % Time start of experiment for filenames

s = RandStream.create('mt19937ar','seed',sum(100*clock));       %Set randomization to not start over on every system startup
RandStream.setGlobalStream(s);

leftright = {'right', 'left'}; % Assisting variable

% Make folder and intiate shell logging
Params.subjID = ['S' num2str(Params.SubjectNumber, '%02d') Params.SubjectInitials];
Params.SubjectFolder = Params.subjID;
mkdir('./data',Params.SubjectFolder);
diary(['./data/' Params.SubjectFolder '/Log_' date() '_' num2str(now()) '.txt']);

try
    %% Prep    
    % Initialize driver, request low-latency preinit:
    InitializePsychSound(1);
    
    % Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs; WaitSecs(0.1);
        
    %% Run Threshold blocks
    % Counterbalance the blocks
    blocks = perms({{'Vis', 'Uni'}, {'Vis', 'Bi'}, {'Aud', 'Uni'}, {'Aud', 'Bi'}});
    Params.blockOrder = blocks(mod(Params.SubjectNumber, 24), :);
    
    % Allow selection of blocks to run
    listString = {'Learning'};
    for bl = 1:length(Params.blockOrder)
        listString{bl+1} = [Params.blockOrder{bl}{1} ' ' ...
            Params.blockOrder{bl}{2} 'modal'];
    end
    
    Params.blockSelect = listdlg('ListString',listString, 'InitialValue',...
        1:5, 'Name', 'Threshold blocks', 'PromptString',...
        'What threshold blocks to run? (default all)');
    
    %% Run training
    if sum(Params.blockSelect == 1)
        runTraining;
    end
    %% Run the blocks
    for bl = Params.blockSelect(Params.blockSelect ~= 1) - 1
        disp(['Running ' Params.blockOrder{bl}{1} Params.blockOrder{bl}{2} ' threshold block']);
        proceed = input('Proceed to next block? (1 - Yes, 0 - Stop experiment) ');
        
        if ~proceed
            break
        end
        
        disp('Press any key to start block');
        KbWait;
        eval(['runThresh' Params.blockOrder{bl}{1} Params.blockOrder{bl}{2}]);
    end   

    %% Save for next time
    paramFile = ['./data/' Params.SubjectFolder '/paramsForNextSession.mat'];
    
    % Merge previous run of session
    if exist(paramFile,'file')
        oldParams = load(paramFile);
        
        if isfield(oldParams.Params, 'visPFParams') && ~isfield(Params, 'visPFParams')
            Params.visPFParams = oldParams.Params.visPFParams;
            Params.visThresholdValue = oldParams.Params.visThresholdValue;
        end
        if isfield(oldParams.Params, 'audPFParams') && ~isfield(Params, 'audPFParams')
            Params.audPFParams = oldParams.Params.audPFParams;
            Params.audThresholdValue = oldParams.Params.audThresholdValue;
        end
    end
    save(paramFile,'Params');
    %% Close and end
    Screen('CloseAll');
    Priority(0);
    ShowCursor;

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    Priority(0);
    PsychPortAudio('Close',Params.pahandle);
    ShowCursor;
end