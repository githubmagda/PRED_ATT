                                                 
function[exper] = presentPredAttStair % (could ask for inputs, e.g. debug, useEyelink)

% cd /Users/magdaaltman/Documents/0_MEG/PRED_ATT/ST_SEQ
% DESCRIPTION
% Main script for presentation that gathers paramaters and calls on other scripts to run
% stimulus series   %matlabrc -  nojvm
     
% Clear the workspace and the screen
close all;
clearvars;

rng('shuffle') % ensure random generator does not repeat on startup VERY IMPORTANT

% Force GetSecs and WaitSecs into memory to avoid latency later on:
GetSecs;         
WaitSecs(0.1);                                           

% SET PATHS - PSYCHTOOLBOX AND KIT (subscripts)
p.main_path = pwd; % get current path

if IsOSX
    addpath(genpath([p.main_path, '/KIT/']));   % add functions folder
else
    addpath([p.main_path, '\KIT\']);            % add functions folder PC style
end
                   
PsychDefaultSetup(2);   % set to: (0) calls AssertOpenGL (1) also calls KbName('UnifyKeyNames') (2) also calls Screen('ColorRange', window, 1, [], 1); immediately after and whenever PsychImaging('OpenWindow',...) is called
[p] = audioOpen(p);     % set audio preferences %Snd('Open'); % open the sound channel
                            
KbName('UnifyKeyNames');
% specify key names of interest in the study N.B. PsychDefaultSetup(1+) already sets up KbName('UnifyKeyNames') using PsychDefaultSetup(1 or 2);
p.activeKeys = [KbName('space'), KbName('Return'), KbName('C'),KbName('V'),KbName('O'), KbName('Escape'),]; % CHECK
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck([p.activeKeys]);

% SET  DEBUG, INCLUDE STAIRCASE / PRACTICE
p.debug = 1;
p.localizer = 1;                                           ;
p.staircase = 1; % these could be staircase and/or localizers (or could be separate programs)

% GET EYELINK DETAILS
[p] = askEyelink(p); % determine whether eyetracker is used, which eye is 'policed' and whether 'dummy' mode is used

%% CHECK THESE VARIABLES BEFORE STARTING!!!
p = SEQ_ParamsGen(p); % set general pre-screen opening parameters;  %% SUB-SCRIPT
% N.B. SEQ_ParamsScr is called after openWindow since it requires
% window parameters to have been established

% % % % % % %  DON'T DELETE if commented out !!!!
% % % % % % % Make directory for this subject's data
% % % % % % p.date = date;
% % % % % % p.experimentStart = datestr(now,'yymmddHHMMSS');
% % % % % % 
% % % % % % if p.debug
% % % % % %     p.directoryName = 'DATATEST';
% % % % % %     [p] = makeDirectory(p);  %% SUB-SCRIPT
% % % % % %     if IsOSX
% % % % % %         p.subjectPathStr = [p.directoryName,'/', p.subjectFolder];        
% % % % % %     else
% % % % % %         p.subjectPathStr = [p.directoryName,'\', p.subjectFolder];
% % % % % %     end
% % % % % % else
% % % % % %     p.directoryName = 'DATA';
% % % % % %     [p] = makeDirectory(p); %% SUB-SCRIPT
% % % % % %     if IsOSX
% % % % % %         p.subjectPathStr = [p.directoryName,'/', p.subjectFolder];
% % % % % %     else
% % % % % %         p.subjectPathStr = [p.directoryName,'\', p.subjectFolder];
% % % % % %     end
% % % % % % end
% % % % % % p.subjectFolder

% intiate shell logging
% % diary([p.main_path, '/', p.subjectPathStr, '_', 'log_', p.experimentStart, '.txt']); % note - a date scaler number is used after the date, it can be converted to date and time by entering it in datestr(...)

% TRY - CATCH LOOP (error catch)
try
    
    % DEFINE PTB screen, screen pointer, window and specs
    [p] = openWindowKit(p); % gets window number and sets wRect
    [p] = SEQ_ParamsScr(p); % load window-based parameters
    
    %% EYELINK SETUP (includes STEPS 2, 3) - CHECK
    if p.useEyelink    % check if optional use of Eyelink has been specified
        [p] = EL_setup(p); % script to do setup routine
    end
    
    % MAIN EXPERIMENT BLOCK LOOP
% % % % % %     %  experiment level structure (to include all other variables); save to subject folder
     exper = [];
% % % % % %     cd(p.directoryName);
% % % % % %     cd(p.subjectFolder);
% % % % % %     save('exper', 'exper');
% % % % % %     cd ..
% % % % % %     cd ..
                
    % make TEXTURES for stimDisplay
    [p] =   makeTextures(p);
    sr = []; % initialize structure for series
    
    % RUN LOCALIZER
    if p.localizer
        lr = []; % structure to save data
        lr.number = 1;
        
        % get string specifying quadrants for localizer
        lr.series = pseudoRandListNoRpt(p); %% SUB-SCRIPT
        
        % show the Main experiment text
        makeTexts(exper, p, 'localizer', 0);  % makeTexts(exper, p, 'localizer', 0);
        doKbCheck(p)  %% SUB-SCRIPT
        
        % EYETRACKING
        if p.useEyelink == 1
            % if a EL file is still open from previous recording, close it
            if p.statusFile == 0
                p.statusFile = EL_closeFile();
            end
            % open .edf file for new series
            thisFileName = strcat( 'Lr', num2str( lr.number));
            EL_openFile(p, thisFileName, lr.number); % open and name file for this series 
           
            % do calibration, save .edf file, (re)start eyetracker
            if lr.number == 1 % choose text to show 'first' or 'subsequent'
                calText = 'first';
            else
                calText = 'subsequent';
            end
            p = EL_calibration(p, calText);   
            % Do last check of eye position (driftcorrect does NOT recalibrate)
            EyelinkDoDriftCorrection(p.el);
            statusRecord = EL_startRecord(lr.number); % CHECK
        end
        
        % RUN LOCALIZER
        [p, lr] = localizer(p, lr);
        exper.lr = lr;
        
        % if  EYETRACKING previous series, stop now, save and move file to subject folder
        if p.useEyelink
            if statusRecord == 0
                p = EL_stopRecord(p, sr);
                p = EL_closeFile(p, sr);                               
            end
        end
        screenBlank(p);            
    end
    %% end LOCALIZER
    
    if p.staircase
        str = [];
        dotProb = p.series.dotProbStaircase;
        [seriesDot] = makeDotSeries(p, dotProb); %% SUB-SCRIPT        
        str.dot.series = seriesDot;
        stimDisplayStaircase(p, str); 
    end
    
    %  DON'T DELETE if commented out !!!!
    
    %% show the introductory text screen
    sr = []; %  variable
    makeTexts(exper, p, 'intro', sr);   %% SUB-SCRIPT (exp, p, textName, sr) calls makeTexts.m
    doKbCheck(p)   %% SUB-SCRIPT % get participant to move forward using TWO keystrokes
      
    %% BLOCK LEVEL
    bl = [];
    
    for bl_i = 1:p.blockNumber
        display('block')
        bl_i
        %% SERIES LEVEL
        for sr_i = 1 : p.seriesNumber
            display('series')
            sr_i
            % initialize new
            sr = [];
            sr.number = sr_i;
            
            % make predictive series           
            [seriesPred, trackerByElement, trackerByChunk] = makePredSeriesReplaceNoRptEven(p); %% SUB-SCRIPT
            sr.pred.series = seriesPred;
            sr.pred.trackerByElement  = trackerByElement;
            sr.pred.trackerByChunk  = trackerByChunk;
           
            % attentional dot
            dotProb = p.series.dotProb;
            [seriesDot] = makeDotSeries(p, dotProb); %% SUB-SCRIPT        
            sr.dot.series = seriesDot;
            
            %%% DON'T DELETE
            if sr_i == 1
                
                %% show the Main experiment text
                makeTexts(exper, p, 'main', sr);
                doKbCheck(p)  %% SUB-SCRIPT
            else
                %% show continuation-of-block presentation text
                makeTexts(exper, p, 'nextSeries', sr);
                doKbCheck(p);  %% SUB-SCRIPT
            end
            
            %% EYETRACKING
            if p.useEyelink == 1
                % if a file is still open from previous recording, close it
                if p.el.statusFile == 0
                    p.el.statusFile = EL_closeFile();
                end
                % open .edf file for new series
                thisFileName = strcat( 'sr', num2str( sr.number));
                EL_openFile(p, thisFileName, sr.number) % open and name file for this series
                
                % do calibration, save .edf file, (re)start eyetracker
                if sr.number == 1 % choose text to show 'first' or 'subsequent'
                    calText = 'first';
                else
                    calText = 'subsequent';
                end
                p = EL_calibration(p, 'main');   %% CHECK 'main' vs. 'practice' or 'staircase'
                % Do last check of eye position (does NOT recalibrate)
                EyelinkDoDriftCorrection(p.el);
                EL_startRecord()
            end
            
            %% RUN NEXT SERIES
            [p, sr] = stimDisplay(p, sr);
            
            %% name/number series and add to exp structure
            srName = sprintf('sr%d',sr_i);
            exper.(srName) = sr;
            
            %% if already eyetracking last series stop, save and move file to subject folder
            if p.useEyelink
                if statusRecord == 0
                    p = EL_stopRecord(p, sr);
                    p = EL_closeFile(p, sr);
                end
            end
            screenBlank(p);
            
            %% give task feedback
            if sr_i < p.seriesNumber 
                taskFeedback(p, sr);
            end
            
            %% ADD FIELDS TO TEMPORARY EXPERIMENT STRUCTURE (updated after
            %% each series in case participant quits
        end  % END OF SERIES LOOP
    end % END OF BLOCK LOOP
    
    if p.useEyelink == 1 %%% STOP RECORDING               
        Eyelink('Stoprecording');
        Eyelink('Closefile');
        Eyelink('message','STOP_RECORDING');
        display('STOP_RECORDING');
        Eyelink('message','ENDEXPERIMENT');
        display('ENDEXPERIMENT');
    end
    
    %% DISPLAY end of experiment
    Screen('TextSize', p.scr.window, p.scr.textSize);
    [exper, text2show] = makeTexts(exper, p, 'endExperiment', sr);
    %%DrawFormattedText(p.scr.window, text2show, 'center','center', p.scr.textColor); %%, p.scr.textType);
    WaitSecs(2); % CHECK for real experiment
    
 catch
    psychrethrow(psychlasterror);
    cleanup;
    
% % % % %     Screen('CloseAll');
% % % % %     
% % % % %     PsychPortAudio('Close');
% % % % %     KbQueueFlush(); 
% % % % %    KbQueueRelease([deviceIndex])
% % % % %     RestrictKeysForKbCheck([]);
% % % % %     ShowCursor;
% % % % %     Priority(0);
% % % % %         if p.useEyelink
% % % % %         Eyelink('Closefile');
% % % % %         Eyelink('Shutdown');
% % % % %     end
    
end
cleanup;
% % % % % Screen('CloseAll');
% % % % % 
% % % % % if p.useEyelink
% % % % %     Eyelink('Closefile');
% % % % %     Eyelink('Shutdown');
% % % % % end
% % % % % 
% % % % % PsychPortAudio('Close');
% % % % % KbQueueFlush();
% % % % %    KbQueueRelease([deviceIndex])         
% % % % % RestrictKeysForKbCheck([]);
% % % % % ShowCursor;
% % % % % Priority(0);
end

function [] = cleanup
PsychPortAudio('Close');
KbQueueFlush();
           
ShowCursor;
Priority(0);
if p.useEyelink
    Eyelink('Closefile');
    Eyelink('Shutdown');
end
end



