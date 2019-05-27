try
    %% Auditory threshlod blocks
    thisFile = ['aT' Params.subjID];
    
    Params.RTCutoff = Params.defaultRTCutoff;
    Params = openWindow(Params);
    Params = openAudioPort(Params);
    
    % Send parameters to ET
    % STEP 1
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    [Params.el, Params.edfFile, Params.v, Params.vs] = setEyeLink(Params, [thisFile(1:end-2)]);
    
    %% Rough run
    % Prepare
    roughRun = [];
    roughRun.catchRatio = Params.catchRatio;
    roughRun.isAud = 1;
    roughRun.isVis = 1;
    roughRun.audTargLevel = Params.audRoughRunLevel;
    roughRun.repetitions = 1;
    roughRun.trialDuration = Params.threshTrialDuration;
    roughRun.isExp = 0;
    
    roughRun = trialPlanner(Params, roughRun);
    
    roughRun = stimuliGenerator(Params, roughRun);
    
    roughRun(1).instructions.text = ['Auditory target - 1st run \nrespond with '...
        leftright{Params.audIs}];
    roughRun(1).instructions.rtl = 0;
    roughRun(1).instructions.contKey = 32;
    
    % Run
    disp('Auditory rough run block');
    ok = 0;
    while ~ok
        Logger = runBlock(Params,roughRun);
        % Make performance plot
        figure('Visible','off');
        performancePlot(Params, Logger, Params.audRoughRunLevel);
        hold on;
        stem(Params.audDefaultLevels(1), .9)
        stem(Params.audDefaultLevels(end), .9)
        saveas(gcf,['./data/',Params.SubjectFolder '/audRoughRun' datestr(now,'yymmddHHMMSS')],'fig');
        
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
    
    %% Run threshold
    % Prepare
    audThresh = [];
    audThresh.catchRatio = Params.catchRatio;
    audThresh.isAud = 1;
    audThresh.isVis = 1;
    audThresh.repetitions = Params.audThreshRepetitions;
    audThresh.trialDuration = Params.threshTrialDuration;
    audThresh.isExp = 0;
    
    % Set levels
    ins.text = ['Stim levels are:\n' ...
        sprintf(' %.3f',Params.audDefaultLevels) '\n (1 - good, 0 - change) :'];
    ins.rtl = 0;
    ins.contKey = [KbName('0') KbName('1') KbName('1!') KbName('0)')];
    resp = doInstructions(Params,ins);
    if resp == KbName('1') || resp == KbName('1!')
        ok = 1;
    else
        ok = 0;
    end
    
    if ok
        Params.audTargLevel = Params.audDefaultLevels;
    end
    
    while ~ok
        correct = 0;
        while ~correct
            try
                reply=Ask(Params.w,'Input stimLevel vector: ',[],Params.grey,'GetChar','center','center');
                Params.audTargLevel = stimLevelRange(eval(reply),length(Params.audThreshRepetitions));
                correct = 1;
            catch
                correct = 0;
            end
        end
        ins.text = ['Stim levels are:\n' ...
            sprintf(' %.3f',Params.audTargLevel) '\n (1 - good, 0 - change) :'];
        ins.rtl = 0;
        ins.contKey = [KbName('0') KbName('1') KbName('1!') KbName('0)')];
        resp = doInstructions(Params,ins);
        if resp == KbName('1') || resp == KbName('1!')
            ok = 1;
        else
            ok = 0;
        end
    end
    
    audThresh.audTargLevel = Params.audTargLevel;
    
    audThresh = trialPlanner(Params, audThresh);
    
    audThresh = stimuliGenerator(Params, audThresh);
    audThresh = insertBreaks(Params, audThresh,Params.breakEvery);
    save(['./data/' Params.SubjectFolder '/' thisFile '_stim_' Params.experimentStart '.mat'],'audThresh');
    
    audThresh(1).instructions.text = 'Threshold';
    audThresh(1).instructions.rtl = 0;
    audThresh(1).instructions.contKey = 32;
    
    % Run
    Logger = runBlock(Params,audThresh);
    save(['./data/' Params.SubjectFolder '/' thisFile '_' Params.experimentStart '.mat'],'Params','Logger');
    
    ins.text = 'Please call experimenter';
    ins.rtl = 0;
    ins.contKey = [KbName('1') KbName('1!')];
    doInstructions(Params,ins);
    %% Close audio and window
    PsychPortAudio('Close',Params.pahandle);
    sca;
    closeEyeLink(Params, thisFile);
    %% Plot psychophysics and get threshold
    % Plot RT histogram in order to set Params.RTCutoff
    RTHistogram(Params, Logger);
    saveas(gcf,['./data/',Params.SubjectFolder '/aRTHistThreshold' datestr(now,'yymmddHHMMSS')],'fig');
    Params.RTCutoff = inputdlg({'Lower bound','Upper bound'},'Input RT cutoff range',1,Params.rtDefault);
    Params.RTCutoff = [str2double(Params.RTCutoff{1}) str2double(Params.RTCutoff{2})];
    
    % Extract PF vectors from data logger
    [Logger, CountCorrect, OutOf, CatchProp]=computePFVectors(Params, Logger, Params.audTargLevel);
    
    % Plot the plot
    ok=0;
    lambda = .01;
    while ~ok
        figure;
        [Params.audPFParams] = plotPF(Params.audTargLevel ,CountCorrect(1,:),OutOf(1,:),.01,0);
        
        
        % Find stimCorr value at wanted performance
        Params.audThresholdValue = 10.^(PAL_CumulativeNormal(Params.audPFParams,Params.thresholdPoint,'Inverse'));
        disp([num2str(Params.thresholdPoint*100) '% performance at: ' num2str(Params.audThresholdValue) ' level']);
        
        title([Params.subjID 'Bi-modal auditory block PF: \lambda = ' ...
            num2str(lambda) ' \alpha = ' num2str(Params.audThresholdValue)]);
        xlabel('stimLevel (1-r)'); ylabel('Proportion correct');
        
        ok = input('Do the plots look fine? Continue or replot? (1=continue, 0=replot)\n');
        
        if ~ok
            lambda = input('Input lambda value for mean (deault is .01):\n');
        else
            saveas(gcf,['./data/',Params.SubjectFolder '/aThreshold' datestr(now,'yymmddHHMMSS')],'fig');
        end
    end
catch
    sca;
    PsychPortAudio('Close',Params.pahandle);
    Priority(0);
    psychrethrow(psychlasterror);
end