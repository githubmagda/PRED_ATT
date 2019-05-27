%% Training block - this runs the short training blocks for each modality
try
    thisFile = ['train' Params.subjID];
    
    Params.RTCutoff = Params.defaultRTCutoff;
    Params = openWindow(Params);
    Params = openAudioPort(Params);
    
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    [Params.el, Params.edfFile, Params.v, Params.vs] = setEyeLink(Params, [thisFile(1:end-2)]);
    
    doNext = '1';
    while doNext ~= KbName('6');
        % Allow flexible block order
        next.text = ['What block to run now?\n'...
            '1 - Eye tracking example\n'...
            '2 - Visual training\n'...
            '3 - Auditory two-example multitarget\n'...
            '4 - Auditory two-exmaple\n'...
            '5 - Auditory half and half\n'...
            '6 - Finish training'];
        next.rtl = 0;
        next.contKey = [KbName('1') KbName('2') KbName('3') KbName('4')...
            KbName('5') KbName('6')];
        doNext = doInstructions(Params,next);
        
        %% Eye tracking training
        if doNext == KbName('1');
            eyeTrain = [];
            eyeTrain(1).isAud = 1;
            eyeTrain(1).isVis = 1;
            eyeTrain(1).audStimOnset = 0;
            eyeTrain(1).audTargOnset = [];
            eyeTrain(1).audTargLevel = 0;
            eyeTrain(1).type = 2;
            eyeTrain(1).trialDuration = Params.trialDuration;
            eyeTrain(1).ITI = 1500;
            eyeTrain(1).visStimOrientation = rand() * 180;
            eyeTrain(1).visTargOnsetFrames = [];
            eyeTrain(1).visTargLevel = [];
            eyeTrain(1).visStimOnsetFrames = 1;
            eyeTrain(1).visTargOnset = [];
            eyeTrain(1).visStimOnset = 0;
            eyeTrain(1).audStimOnsetFrames = 1;
            eyeTrain(1).audTargOnsetFrames = time2flips(Params,eyeTrain(1).audTargOnset);
            eyeTrain(1).trialDuration = Params.threshTrialDuration;
            eyeTrain(1).keys = Params.keys;
            eyeTrain(1).respMap = Params.respMap;
            
            eyeTrain = stimuliGenerator(Params, eyeTrain);
            
            eyeTrainFirst = eyeTrain;
            eyeTrainFirst(1).instructions.text = 'Eyetracking example';
            eyeTrainFirst(1).instructions.rtl = 0;
            eyeTrainFirst(1).instructions.contKey = 32;
            
            %Run
            runBlock(Params,eyeTrainFirst);
            
            ok = 0;
            while ~ok
                eyeLog = runBlock(Params,eyeTrain);
                
                if eyeLog(1).RT > 0
                    ok = 1;
                end
            end
            
            doNext = doInstructions(Params,next);
        end
        
        %% Training block
        if doNext == KbName('2')
            % Prepare
            visTrainBlock =[];
            visTrainBlock.catchRatio = Params.catchRatio;
            visTrainBlock.isExp = 0;   % This is threshold, not experimental
            visTrainBlock.isAud = 0;
            visTrainBlock.isVis = 1;
            visTrainBlock.visTargLevel = Params.visTrainBlockLevel;
            visTrainBlock.repetitions = 2;
            visTrainBlock.trialDuration = Params.threshTrialDuration;
            
            visTrainBlock = trialPlanner(Params, visTrainBlock);
            
            visTrainBlock = stimuliGenerator(Params, visTrainBlock);
            
            visTrainBlock(1).instructions.text = ['Visual training block \nrespond with '...
                leftright{Params.visIs}];
            visTrainBlock(1).instructions.rtl = 0;
            visTrainBlock(1).instructions.contKey = 32;
            
            % Run
            disp('Visual threshold training block');
            ok=0;
            while ~ok
                Logger = runBlock(Params, visTrainBlock);
                [~, CountCorrect, OutOf, CatchProp]=computePFVectors(Params, Logger, Params.visTrainBlockLevel);
                
                feedback.text = ['Hits:\n' num2str(Params.visTrainBlockLevel) '\n'...
                    num2str(CountCorrect) '\n CatchProp: ' num2str(CatchProp) ...
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
            
            doNext = doInstructions(Params,next);
        end
        %% Two examples multi target
        if doNext == KbName('3')
            % Prepare
            twoExp = [];
            twoExp(1).isAud = 1;
            twoExp(1).isVis = 0;
            twoExp(1).audStimOnset = 0;
            twoExp(1).audTargOnset = [];
            twoExp(1).audTargLevel = 0;
            twoExp(1).type = 2;
            twoExp(1).trialDuration = Params.trialDuration;
            twoExp(1).ITI = 1500;
            twoExp(1).visStimOrientation = rand() * 180;
            twoExp(1).visTargOnsetFrames = [];
            twoExp(1).visTargLevel = [];
            twoExp(1).visStimOnsetFrames = 1;
            twoExp(1).visTargOnset = [];
            twoExp(1).visStimOnset = 0;
            twoExp(1).audStimOnsetFrames = 1;
            twoExp(1).audTargOnsetFrames = time2flips(Params,twoExp(1).audTargOnset);
            twoExp(1).trialDuration = Params.threshTrialDuration;
            twoExp(1).keys = Params.keys;
            twoExp(1).respMap = Params.respMap;
            
            twoExp(2).isAud = 1;
            twoExp(2).isVis = 0;
            twoExp(2).audStimOnset = 0;
            twoExp(2).audTargOnset = 1000:1500:10000;
            twoExp(2).audTargLevel = repmat(Params.audThreshold.exampleTargLevel,1,5);
            twoExp(2).type = 0;
            twoExp(2).trialDuration = 10000;
            twoExp(2).ITI = 1500;
            twoExp(2).visStimOrientation = rand() * 180;
            twoExp(2).visTargLevel = [];
            twoExp(2).visStimOnsetFrames = 1;
            twoExp(2).visTargOnset = [];
            twoExp(2).visStimOnset = 0;
            twoExp(2).audStimOnsetFrames = 1;
            twoExp(2).audTargOnsetFrames = time2flips(Params,twoExp(2).audTargOnset);
            twoExp(2).keys = Params.keys;
            twoExp(2).respMap = Params.respMap;
            
            twoExp = stimuliGenerator(Params, twoExp);
            
            twoExp(1).instructions.text = [...
                'Auditory two examples, multi-target \nrespond with '...
                leftright{Params.audIs}];
            twoExp(1).instructions.rtl = 0;
            twoExp(1).instructions.contKey = 32;
            
            %Run
            ok = 0;
            while ~ok
                runBlock(Params,twoExp);
                
                proceed.text = 'Proceed to next block? (1 - yes, 0 - rerun training block)';
                proceed.rtl = 0;
                proceed.contKey = [KbName('0') KbName('1')];
                
                resp = doInstructions(Params,proceed);
                
                if resp == KbName('1')
                    ok = 1;
                else
                    ok = 0;
                end
            end
            
            doNext = doInstructions(Params,next);
        end
        %% Two examples
        if doNext == KbName('4')
            % Prepare
            twoExp = [];
            twoExp(1).isAud = 1;
            twoExp(1).isVis = 0;
            twoExp(1).audStimOnset = 0;
            twoExp(1).audTargOnset = [];
            twoExp(1).audTargLevel = 0;
            twoExp(1).type = 2;
            twoExp(1).trialDuration = Params.trialDuration;
            twoExp(1).ITI = 1500;
            twoExp(1).visStimOrientation = rand() * 180;
            twoExp(1).visTargOnsetFrames = [];
            twoExp(1).visTargLevel = [];
            twoExp(1).visStimOnsetFrames = 1;
            twoExp(1).visTargOnset = [];
            twoExp(1).visStimOnset = 0;
            twoExp(1).audStimOnsetFrames = 1;
            twoExp(1).audTargOnsetFrames = time2flips(Params,twoExp(1).audTargOnset);
            twoExp(1).trialDuration = Params.threshTrialDuration;
            twoExp(1).keys = Params.keys;
            twoExp(1).respMap = Params.respMap;
            
            twoExp(2).isAud = 1;
            twoExp(2).isVis = 0;
            twoExp(2).audStimOnset = 0;
            twoExp(2).audTargOnset = rand()*(Params.threshTrialDuration - sum(Params.keepClear)) + Params.keepClear(1);
            twoExp(2).audTargLevel = Params.audThreshold.exampleTargLevel;
            twoExp(2).type = 0;
            twoExp(2).trialDuration = Params.trialDuration;
            twoExp(2).ITI = 1500;
            twoExp(2).visStimOrientation = rand() * 180;
            twoExp(2).visTargLevel = [];
            twoExp(2).visStimOnsetFrames = 1;
            twoExp(2).visTargOnset = [];
            twoExp(2).visStimOnset = 0;
            twoExp(2).audStimOnsetFrames = 1;
            twoExp(2).audTargOnsetFrames = time2flips(Params,twoExp(2).audTargOnset);
            twoExp(2).trialDuration = Params.threshTrialDuration;
            twoExp(2).keys = Params.keys;
            twoExp(2).respMap = Params.respMap;
            
            twoExp = stimuliGenerator(Params, twoExp);
            
            twoExp(1).instructions.text = ['Auditory two examples \nrespond with '...
                leftright{Params.audIs}];
            twoExp(1).instructions.rtl = 0;
            twoExp(1).instructions.contKey = 32;
            
            %Run
            ok = 0;
            while ~ok
                runBlock(Params,twoExp);
                
                proceed.text = 'Proceed to next block? (1 - yes, 0 - rerun training block)';
                proceed.rtl = 0;
                proceed.contKey = [KbName('0') KbName('1')];
                
                resp = doInstructions(Params,proceed);
                
                if resp == KbName('1')
                    ok = 1;
                else
                    ok = 0;
                end
            end
            doNext = doInstructions(Params,next);
        end
        
        %% Half and half training block
        if doNext == KbName('5')
            % Prepare
            trainBlock = [];
            trainBlock.catchRatio = 0.5;
            trainBlock.isAud = 1;
            trainBlock.isVis = 0;
            trainBlock.audTargLevel = Params.audTrainBlockLevel;
            trainBlock.repetitions = 2;
            trainBlock.trialDuration = Params.threshTrialDuration;
            trainBlock.isExp = 0;
            
            trainBlock = trialPlanner(Params, trainBlock);
            
            trainBlock = stimuliGenerator(Params, trainBlock);
            
            trainBlock(1).instructions.text = ['Auditory training block \nrespond with '...
                leftright{Params.audIs}];
            trainBlock(1).instructions.rtl = 0;
            trainBlock(1).instructions.contKey = 32;
            
            % Run
            ok=0;
            while ~ok
                Logger = runBlock(Params, trainBlock);
                [Logger, CountCorrect, OutOf, CatchProp]=computePFVectors(Params, Logger, Params.audTrainBlockLevel);
                
                feedback.text = ['Hits:\n' num2str(Params.visTrainBlockLevel) '\n'...
                    num2str(CountCorrect) '\n CatchProp: ' num2str(CatchProp) ...
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
            doNext = doInstructions(Params,next);
        end
        
        
    end
    %% Close all
    sca;
    PsychPortAudio('Close',Params.pahandle);
    if Params.EyeLink; closeEyeLink(Params,thisFile); end;
    
catch
    Screen('CloseAll');
    Priority(0);
    PsychPortAudio('Close',Params.pahandle);
    ShowCursor;
    psychrethrow(psychlasterror);
end