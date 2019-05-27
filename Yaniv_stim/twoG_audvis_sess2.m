%% Main experiment file - session 2 - experimental session
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
%PsychDebugWindowConfiguration

addpath('../Libraries/palamedes1_8_1/Palamedes/');  %add palamedes to path

s = RandStream.create('mt19937ar','seed',sum(100*clock));       %Set randomization to not start over on every system startup
RandStream.setGlobalStream(s);

%Load params from last session
ok = 0;
while ~ok
    [FileName,PathName,FilterIndex] = uigetfile('paramsForNextSession.mat', 'Select parameter file from previous session');
    load([PathName FileName]);
    
    disp(['Threshold values takan on ' Params.experimentStart ':']);
    disp(['Auditory: ' num2str(Params.audThresholdValue) ' (1-r)']);
    disp(['Visual: ' num2str(Params.visThresholdValue) ' (contrast)']);
    
    ok = input('Are these the right data? ');
end

% Get threshold point
ok = 0;
Params.thresholdPoint = 0.5;
while ~ok
    
    disp(['Will present stimuli for ' num2str(Params.thresholdPoint) ...
        ' proportion correct.']);
    
    Params.audThresholdValue = 10.^(PAL_CumulativeNormal(Params.audPFParams,Params.thresholdPoint,'Inverse'));
    Params.visThresholdValue = 10.^(PAL_CumulativeNormal(Params.visPFParams,Params.thresholdPoint,'Inverse'));
    
    disp('Will use the following intensities:');
    disp(['Auditory: ' num2str(Params.audThresholdValue) ' (1-r)']);
    disp(['Visual: ' num2str(Params.visThresholdValue) ' (contrast)']);
    ok = input('Is this correct? (1 - yes, 0 - no): ');
    
    if ~ok
        Params.thresholdPoint = input('What level of performance should I take for session? (0 to 1 proportion) ');
    end
end

% Error sound for eyetracking
load('errorBeep');
Params.errorBeep = errorBeep;

twoGaudvisParams;       % Update params if changes have been made

% Make folder and intiate shell logging
diary(['./data/' Params.SubjectFolder '/Log_' date() '_' num2str(now()) '.txt']);

Params.experimentStart = datestr(now,'yymmddHHMMSS'); % Time start of experiment for filenames
thisFile = ['E' Params.subjID];

% Assisting variables
leftright = {'right', 'left'};
Params.rtDefault = {};
for i = 1:2
    Params.rtDefault{i} = num2str(Params.defaultRTCutoff(i));
end

listString = {'Easy training','Threshold training','Experimental'};
Params.blockSelect = listdlg('ListString',listString, 'InitialValue',...
        1:3, 'Name', 'Threshold blocks', 'PromptString',...
        'What threshold blocks to run? (default all)');

try
    %% Prep    
    % Initialize driver, request low-latency preinit:
    InitializePsychSound(1);
    
    % Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs; WaitSecs(0.1);
        
    %% Experimental blocks
    Params = openAudioPort(Params);
    Params = openWindow(Params);
    Params.RTCutoff = Params.defaultRTCutoff;
    
    % Send parameters to ET
    % STEP 1
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    [Params.el, Params.edfFile, Params.v, Params.vs] = setEyeLink(Params, [thisFile(1:end-2)]);

    %% Training - easy stimLevel
    if sum(1 == Params.blockSelect)
        % Prepare
        trainBlock = [];
        trainBlock.isExp = 1;   % is this a threshold block, or an experimental
        trainBlock.isAll = 0;   %determine trial number manually, not by onset range
        trainBlock.NTrials = 10;     % How many experimental trials
        trainBlock.isVis = 1;
        trainBlock.isAud = 1;
        trainBlock.audTargLevel = 0.7;
        trainBlock.visTargLevel = 0.7;
        trainBlock.catchRatio = Params.catchRatio;
        trainBlock.keys = [Params.KeyRight Params.KeyLeft];
        trainBlock.respMap(Params.KeyRight) = Params.rightIs;
        trainBlock.respMap(Params.KeyLeft) = Params.leftIs;
        
        trainBlock = trialPlanner(Params, trainBlock);
        
        trainBlock = stimuliGenerator(Params, trainBlock);
        
        trainBlock(1).instructions.text = ['Training block:\nIf the target is auditory press '...
            leftright{Params.audIs} '\nIf the target is visual press ' ...
            leftright{mod(Params.audIs,2)+1}];
        trainBlock(1).instructions.rtl = 0;
        trainBlock(1).instructions.contKey = 32;
        
        % Run
        disp('Experimental training block');
        ok=0;
        while ~ok
            Logger = runBlock(Params, trainBlock);
            levels.aud = .7;
            levels.vis = .7;
            [~, CountCorrect, OutOf, CatchProp, wrongKey]=computePFVectors(Params, Logger, levels);
            
            feedback = [];
            feedback.text = ['Hits:\n Aud: ' num2str(levels.aud) '\n'...
                num2str(CountCorrect.aud) '/' num2str(OutOf.aud)...
                '\n Vis: ' num2str(levels.vis) '\n'...
                num2str(CountCorrect.vis) '/' num2str(OutOf.vis)...
                '\n CatchProp: ' num2str(CatchProp) ...
                '\n # wrong key preses: ' num2str(wrongKey) ...
                '\n Proceed to next block? (1 - yes, 0 - rerun training block)'];
            feedback.rtl = 0;
            feedback.contKey = [KbName('0') KbName('1')];
            
            resp = doInstructions(Params,feedback);
            
            if resp == KbName('1')
                ok = 1;
            else
                ok = 0;
            end
        end
    end
    %% Training - real stimLevel
    % Prepare
    if sum(2 == Params.blockSelect)
        trainBlock = [];
        trainBlock.isExp = 1;   % is this a threshold block, or an experimental
        trainBlock.isAll = 0;   %determine trial number manually, not by onset range
        trainBlock.NTrials = 10;     % How many experimental trials
        trainBlock.isVis = 1;
        trainBlock.isAud = 1;
        trainBlock.audTargLevel = Params.audThresholdValue;
        trainBlock.visTargLevel = Params.visThresholdValue;
        trainBlock.catchRatio = Params.catchRatio;
        trainBlock.keys = [Params.KeyRight Params.KeyLeft];
        trainBlock.respMap(Params.KeyRight) = Params.rightIs;
        trainBlock.respMap(Params.KeyLeft) = Params.leftIs;
        
        trainBlock = trialPlanner(Params, trainBlock);
        
        trainBlock = stimuliGenerator(Params, trainBlock);
        
        trainBlock(1).instructions.text = ['Training block:\nIf the target is auditory press '...
            leftright{Params.audIs} '\nIf the target is visual press ' ...
            leftright{mod(Params.audIs,2)+1}];
        trainBlock(1).instructions.rtl = 0;
        trainBlock(1).instructions.contKey = 32;
        
        % Run
        disp('Experimental training block');
        ok=0;
        while ~ok
            Logger = runBlock(Params, trainBlock);
            levels.aud = Params.audThresholdValue;
            levels.vis = Params.visThresholdValue;
            [~, CountCorrect, OutOf, CatchProp, wrongKey]=computePFVectors(Params, Logger, levels);
            
            feedback = [];
            feedback.text = ['Hits:\n Aud: ' num2str(levels.aud) '\n'...
                num2str(CountCorrect.aud) '/' num2str(OutOf.aud)...
                '\n Vis: ' num2str(levels.vis) '\n'...
                num2str(CountCorrect.vis) '/' num2str(OutOf.vis)...
                '\n CatchProp: ' num2str(CatchProp) ...
                '\n # wrong key preses: ' num2str(wrongKey) ...
                '\n Proceed to next block? (1 - yes, 0 - rerun training block)'];
            feedback.rtl = 0;
            feedback.contKey = [KbName('0') KbName('1')];
            
            resp = doInstructions(Params,feedback);
            
            if resp == KbName('1')
                ok = 1;
            else
                ok = 0;
            end
        end
    end
    %% Experimental block
    if sum(3 == Params.blockSelect)
        % Prepare
        expBlock = [];
        expBlock.isExp = 1;   % is this a threshold block, or an experimental
        expBlock.isAll = 1;
        expBlock.isVis = 1;
        expBlock.isAud = 1;
        expBlock.audTargLevel = Params.audThresholdValue;
        expBlock.visTargLevel = Params.visThresholdValue;
        expBlock.catchRatio = Params.catchRatio;
        expBlock.keys = [Params.KeyRight Params.KeyLeft];
        expBlock.respMap(Params.KeyRight) = Params.rightIs;
        expBlock.respMap(Params.KeyLeft) = Params.leftIs;
        
        expBlock = trialPlanner(Params, expBlock);
        
        expBlock = stimuliGenerator(Params, expBlock);
        
        expBlock(1).instructions.text = 'Exp';
        expBlock(1).instructions.rtl = 0;
        expBlock(1).instructions.contKey = 32;
        
        expBlock = insertBreaks(Params, expBlock,Params.breakEvery);
        save(['.\data\' Params.SubjectFolder '\' thisFile '_stim_' Params.experimentStart '.mat'],'expBlock');
        
        Logger = runBlock(Params, expBlock);
        save(['.\data\' Params.SubjectFolder '\' thisFile '_' Params.experimentStart '.mat'],'Params','Logger');
        
        ins.text = 'Please call experimenter';
        ins.rtl = 0;
        ins.contKey = KbName('1');
        doInstructions(Params,ins);
    end
    %% Close and end
    sca;
    PsychPortAudio('Close',Params.pahandle);
    if Params.EyeLink
        closeEyeLink(Params, thisFile);
    end

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    Priority(0);
    PsychPortAudio('Close',Params.pahandle);
    ShowCursor;
end