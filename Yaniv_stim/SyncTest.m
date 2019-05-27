%% Main experiment file
% Stim.type = 0 - target in auditory modality, 1 - target in visual
% modality, 2 - catch trial
% -----------------------------------------------------------------------
% TO DO:
% # Fix damn annulus


%% Prep files
clear
KbName('UnifyKeyNames');
twoGaudvisParams;       % Load params

Params.experimentStart = datestr(now,'yymmddHHMMSS');

addpath('..\Libraries\palamedes1_8_1\Palamedes\');  %add palamedes to path
addpath('..\Libraries\sharedScripts\');  %add shared scripts to path

s = RandStream.create('mt19937ar','seed',sum(100*clock));       %Set randomization to not start over on every system startup
RandStream.setGlobalStream(s);

Params.SubjectNumber=99;

Params.SubjectInitials = 'YA';
Params.SubjectFolder = ['S' num2str(Params.SubjectNumber, '%02d') '_' Params.SubjectInitials];
mkdir('.\data',Params.SubjectFolder);
diary(['.\data\' Params.SubjectFolder '\Log_' date() '_' num2str(now()) '.txt']);

try
    %% Prep
    % Switch to realtime scheduling at maximum allowable Priority: - test this
    Priority(1);
    
    % Initialize driver, request low-latency preinit:
    InitializePsychSound(1);
    
    % Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs; WaitSecs(0.1);
    
    %% Experimental blocks
    Params = openAudioPort(Params);
    Params = openWindow(Params);
    Params.RTCutoff = Params.defaultRTCutoff;
    
    %% Training
    % Prepare
    clear syncBlock
    syncBlock.isAud = 1;
    syncBlock.isVis = 1;
    syncBlock.visStimOnsetFrames = 1;
    syncBlock.audStimOnsetFrames = 30;
    syncBlock.visTargOnsetFrames =  [];
    syncBlock.audTargOnsetFrames =  [];
    syncBlock.visTargLevel = [];
    syncBlock.audTargLevel = [];
    syncBlock.type = 2;
    syncBlock.trialDuration = 3000;
    syncBlock.ITI = 1.5639*1000;
    syncBlock.visTargLoc = [];
    syncBlock.visStimOrientation = [];
    
    syncBlock(2) = syncBlock(1);
    syncBlock([3 4]) = syncBlock([1 2]);
    syncBlock(5:8) = syncBlock(1:4);
    syncBlock(9:16) = syncBlock(1:8);
    syncBlock(17:32) = syncBlock(1:16);
    
    syncBlock = stimuliGenerator(Params, syncBlock);
    
    syncBlock(1).instructions.text = 'Sync Test';
    syncBlock(1).instructions.rtl = 0;
    syncBlock(1).instructions.contKey = 32;
    
    % Run
    disp('Sync Test');
    ok=0;
    while ~ok
        Logger = runBlock(Params, syncBlock);
        
        feedback.text = ['Proceed to next block? (1 - yes, 0 - rerun training block)'];
        feedback.rtl = 0;
        feedback.contKey = [KbName('0') KbName('1')];
        
        resp = doInstructions(Params,feedback);
        
        if resp == KbName('1')
            ok = 1;
        else
            ok = 0;
        end
    end
    
    
    %% Close and end
    Screen('CloseAll');
    Priority(0);
    PsychPortAudio('Close',Params.pahandle);
    ShowCursor;

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    Priority(0);
    PsychPortAudio('Close',Params.pahandle);
    ShowCursor;
end