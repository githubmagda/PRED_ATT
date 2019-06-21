function[sr] = runSeries(Params, bl, sr) % window, windowRect, useEyelink, seq, image,  type)  
%% 
    
    t0 = GetSecs;     
    RA = 0; %% reset for response correct/not-correct
    RT = 0; %% resent for response time;
    cueOnset = 0; %% will be reset after cue appears  
    
    %% Show fixation cross and sound beeper, to alert participant series is about to start
    screenFix(Params);  %
    Screen('Flip', Params.scr.window);
    WaitSecs(Params.scr.waitBlank); %% just a short screen
    Beeper(Params.audFs,Params.globalVolume,.3);  % Beeper(frequency, [fVolume], [durationSec]); 

    screenFix(Params);
    Screen('Flip', Params.scr.window);
    WaitSecs(Params.scr.waitBlank);  %% just a short screen post beeper
        
    if Params.EyeLink
        eyelinkOutputText = strcat('SERIESSTART','_Bl',num2str(bl),'_Tr', num2str(trI));  % send series number to eyetracker
        Eyelink('message', eyelinkOutputText)
    end

    %% SETUP STIM 
%    [Params, trial] = stimdisplayMA1(Params, trial); %% needs to be divided into earlier call and later display
     [Params, sr] = stimDisplayMA2(Params, sr);  
 %s    [Params, trial] = stimDisplayMA(Params, trial); 
    
% % %     %% SETUP STIM 
% % %     [Params, trial] = stimDisplayMA(Params, j, trial ); %% needs to be divided into earlier call and later display
% % %     

        %% FINALLY !! FLIP IMAGE
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window); 
        timeStimOnset = GetSecs; 
        
        if sr.thisUD == 1
            cueOnset = timeStimOnset;
        end
        t0 = FlipTimestamp;
        sr.startClock(1,:) = clock;

        %% SEND OUT MESSAGE TO EYELINK
        if useEyelink
            eyelinkOutputText=strcat('TRIALSTART','_TTr_',num2str(sr.numInExp),'_cond_',num2str(sr.condition)); 
            Eyelink('message',eyelinkOutputText); %send a message to mark beginning of trial      
        end      

        %% RESET defaults for response 
        sr.udR=0; 
        sr.udRT=0;

        %% PREPARE BLANK_1 
        Screen('FillRect',window,p.scr.background); 
        [sr] = checkRT(p, t0, cueOnset, sr, p.waitStim); %%% calls function to CONTROL TIME BETWEEN EVENTS AND CHECK FOR RESPONSE during Stim Presentation 

        %% FLIP BLANK_1     
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window); 
        times(1) = FlipTimestamp - t0;  
        t0= FlipTimestamp; 
        if useEyelink                  
            eyelinkOutputText=strcat('BLANK1','_cond_',num2str(sr.condition),'_TTr_',num2str(sr.numInExp)); 
            Eyelink('message',eyelinkOutputText); %send a message to mark beginning of second blank
        end
  
        %% PREPARE FIXATION 
        fixScreen(p, window);
% % % %         Screen('TextSize',window, p.scr.crossTextSize);  % set text size for cross = p.scr.crossTextSize
% % % %         [normBoundsRect1]= Screen('TextBounds', window, p.scr.crossText); 
% % % %         
% % % %         textRectX1 = p.scr.xCenterPix-(normBoundsRect1(3)/2);
% % % %         textRectY1 = p.scr.yCenterPix-(normBoundsRect1(4)/2);
% % % %         Screen('DrawText', window, p.scr.crossText,textRectX1,textRectY1, p.scr.crossTextColor);
% % % %         
        %% CONTROL TIME BETWEEN EVENTS AND CHECK FOR RESPONSE
        [sr] = checkRT(p, t0, cueOnset, sr, p.waitBlank); 

        %% FLIP FIXATION 
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window);
        times(2) = FlipTimestamp-t0; %FlipTimestamp-t0;
        t0 = FlipTimestamp; %FlipTimestamp; 

        if useEyelink
            eyelinkOutputText=strcat('FIXCROSS','_cond_',num2str(sr.condition),'_TTr_',num2str(sr.numInExp)); 
            Eyelink('message',eyelinkOutputText); %send a message to mark beginning of sequence
        end

        %%% CONTROL TIME BETWEEN EVENTS AND CHECK FOR RESPONSE 
        [sr] = checkRT(p, t0, cueOnset, sr, p.waitCross); 

        %% FLIP BLANK 2 
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window); %, t0+waitDuration);
        times(3) = FlipTimestamp - t0; %FlipTimestamp-t0;
        t0=FlipTimestamp; %FlipTimestamp; 

        if useEyelink
           eyelinkOutputText=strcat('BLANK2','_cond_',num2str(sr.condition),'_TTr_',num2str(sr.numInExp)); 
           Eyelink('message',eyelinkOutputText); %send a message to mark beginning of sequence
        end 

        [sr] = checkRT(p, t0, cueOnset, sr, p.waitBlank); %%% calls function to CONTROL TIME BETWEEN EVENTS AND CHECK FOR RESPONSE during Stim Presentation 
        times(4) = GetSecs - t0 + (p.durRefresh * .5); % adds estimated (and allocated) time for preparing next trial
        if useEyelink
            eyelinkOutputText = strcat('TRIALEND','_TTr_',num2str(sr.numInExp - 1),'_cond_',num2str(sr.condition));
            Eyelink('message',eyelinkOutputText);                
        end
        sr.endClock = clock;
        sr.timings = times;
        
        %% name this trial and add to sequence
        trialName = sprintf('tr%d',ser); 
        ser.(trialName) = sr;
        
    
    %trial.endClock = clock;
    %% send out end of sequence message AND stop recording
    if Params.eyelink
        eyelinkOutputText = strcat('SEQEND',num2str(j));
        Eyelink('message', eyelinkOutputText);   
    end
    
    %% PREPARE FIXATION  
    fixScreen(p, window);
    Screen('Flip', window);
    WaitSecs(p.waitCross);    
end

