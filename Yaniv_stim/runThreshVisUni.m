%% Visual threshlod blocks
try
    thisFile = ['vUT' Params.subjID];
    
    Params.RTCutoff = Params.defaultRTCutoff;
    Params = openWindow(Params);
    Params = openAudioPort(Params);
    
    % Send parameters to ET
    % STEP 1
    
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    [Params.el, Params.edfFile, Params.v, Params.vs] = setEyeLink(Params, [thisFile(1:end-2)]);
    
    
    %% Rough block
    % Prepare
    roughRun = [];
    roughRun.catchRatio = Params.catchRatio;
    roughRun.isExp = 0;   % This is threshold, not experimental
    roughRun.isAud = 0;
    roughRun.isVis = 1;
    roughRun.visTargLevel = Params.visRoughRunLevel;
    roughRun.repetitions = 1;
    roughRun.trialDuration = Params.threshTrialDuration;
    
    roughRun = trialPlanner(Params, roughRun);
    
    roughRun = stimuliGenerator(Params, roughRun);
    
    roughRun(1).instructions.text = ['Visual target - 1st run\nrespond with '...
        leftright{Params.visIs}];
    roughRun(1).instructions.rtl = 0;
    roughRun(1).instructions.contKey = KbName('space');
    
    % Run
    disp('Visual rough run block');
    ok=0;
    while ~ok
        Logger = runBlock(Params, roughRun);
        
        % Make performance plot
        figure('Visible','off');
        performancePlot(Params, Logger, Params.visRoughRunLevel);
        hold on;
        stem(Params.visDefaultLevels(1), .9)
        stem(Params.visDefaultLevels(end), .9)
        saveas(gcf,['./data/',Params.SubjectFolder '/visUniRoughRun' datestr(now,'yymmddHHMMSS')],'fig');
        
        % Display it in window
        h = getframe(gcf);
        roughPlot = Screen('MakeTexture',Params.w, h.cdata);
        Screen('DrawTexture',Params.w,roughPlot);
        Screen('Flip',Params.w);
        KbStrokeWait;
        
        ins.text = '1 - continue, 0 - rerun: ';
        ins.rtl = 0;
        ins.contKey = [KbName('0') KbName('1') KbName('1!') KbName('0)')];
        resp = doInstructions(Params,ins);
        
        if resp == KbName('1') || resp == KbName('1!')
            ok = 1;
        else
            ok = 0;
        end
    end
    
    %% Threshold block
    % Prepare
    visThresh = [];
    % Set levels
    ins.text = ['Stim levels are:\n' ...
        sprintf(' %.3f',Params.visDefaultLevels) '\n (1 - good, 0 - change) :'];
    ins.rtl = 0;
    ins.contKey = [KbName('0') KbName('1') KbName('1!') KbName('0)')];
    resp = doInstructions(Params,ins);
    if resp == KbName('1') || resp == KbName('1!')
        ok = 1;
    else
        ok = 0;
    end
    
    if ok
        Params.visTargLevel = Params.visDefaultLevels;
    end
    
    while ~ok
        correct = 0;
        while ~correct
            try
                reply=Ask(Params.w,'Input stimLevel vector: ',[],Params.grey,'GetChar','center','center');
                Params.visTargLevel = stimLevelRange(eval(reply),length(Params.visThreshRepetitions));
                correct = 1;
            catch
                correct = 0;
            end
        end
        ins.text = ['Stim levels are:\n' ...
            sprintf(' %.3f',Params.visTargLevel) '\n (1 - good, 0 - change) :'];
        ins.rtl = 0;
        ins.contKey = [KbName('0') KbName('1') KbName('1!') KbName('0)')];
        resp = doInstructions(Params,ins);
        if resp == KbName('1') || resp == KbName('1!')
            ok = 1;
        else
            ok = 0;
        end
    end
    
    visThresh.catchRatio = Params.catchRatio;
    visThresh.isExp = 0;    %threshold, not experimental
    visThresh.isAud = 0;
    visThresh.isVis = 1;
    visThresh.visTargLevel = Params.visTargLevel;
    visThresh.repetitions = Params.visThreshRepetitions;
    visThresh.trialDuration = Params.threshTrialDuration;
    
    visThresh = trialPlanner(Params, visThresh);
    
    visThresh = stimuliGenerator(Params, visThresh);
    
    visThresh(1).instructions.text = 'Threshold';
    visThresh(1).instructions.rtl = 0;
    visThresh(1).instructions.contKey = KbName('space');
    
    visThresh = insertBreaks(Params, visThresh,Params.breakEvery);
    save(['./data/' Params.SubjectFolder '/' thisFile '_stim_' Params.experimentStart],'visThresh');
    
    Logger = runBlock(Params, visThresh);
    save(['./data/' Params.SubjectFolder '/' thisFile '_' Params.experimentStart '.mat'],'Params','Logger');
    
    ins.text = 'Please call experimenter';
    ins.rtl = 0;
    ins.contKey = [KbName('1') KbName('1!')];
    doInstructions(Params,ins);
    
    %% Close window and sound
    sca;
    PsychPortAudio('Close',Params.pahandle);
    closeEyeLink(Params, thisFile);
    
    %% Plot psychophysics and get threshold
    % Plot RT histogram in order to set Params.CutOffRange
    RTHistogram(Params, Logger);
    saveas(gcf,['./data/',Params.SubjectFolder '/vUniRTHistThreshold' datestr(now,'yymmddHHMMSS')],'fig');
    Params.RTCutoff = inputdlg({'Lower bound','Upper bound'},'Input RT cutoff range',1,Params.rtDefault);
    Params.RTCutoff = [str2double(Params.RTCutoff{1}) str2double(Params.RTCutoff{2})];
    
    % Extract PF vectors from data logger
    [Logger, CountCorrect, OutOf, CatchProp]=computePFVectors(Params, Logger, Params.visTargLevel);
    
    % Plot the plot
    ok=0;
    lambda = .01;
    while ~ok
        figure;
        Params.visUniPFParams = plotPF(Params.visTargLevel ,CountCorrect(1,:),OutOf(1,:),.01,0);
        
        % Find stimCorr value at wanted performance
        Params.visUniThresholdValue = 10.^(PAL_CumulativeNormal(Params.visUniPFParams,Params.thresholdPoint,'Inverse'));
        disp([num2str(Params.thresholdPoint*100) '% performance at: ' num2str(Params.visUniThresholdValue) ' level']);
        
        title([Params.subjID 'Uni-modal visual block PF: \lambda = ' ...
            num2str(lambda) ' \alpha = ' num2str(Params.visUniThresholdValue)]);
        xlabel('stimLevel (contrast)'); ylabel('Proportion correct');
        
        ok = input('Do the plots look fine? Continue or replot? (1=continue, 0=replot)\n');
        
        if ~ok
            lambda = input('Input lambda value for mean (deault is .01):\n');
        else
            saveas(gcf,['./data/',Params.SubjectFolder '/vUniThreshold' datestr(now,'yymmddHHMMSS')],'fig');
        end
    end
catch
    sca;
    PsychPortAudio('Close',Params.pahandle);
    Priority(0);
    psychrethrow(psychlasterror);
end