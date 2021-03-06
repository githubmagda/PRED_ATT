function[exper] = presentQuad() % (could ask for inputs, e.g. debug, useEyelink)

% DESCRIPTION
% Main script for Predictive Attention presentations - presents localizer.m, then stimDisplay.m (first staircase, then regularSeries)
 
% Clear the workspace and the screen
sca;
close all;  
clearvars;          
      
rng('shuffle') % ensure random generator does not repeat on startup VERY IMPORTANT

% Force GetSecs and WaitSecs into memory to avoid latency later on:
GetSecs;
WaitSecs(0.1);

% SET  DEBUG, INCLUDE STAIRCASE / PRACTICE
p.debug         = 1; % run with smaller window in debug mode                       
p.testEdf       = 1; % eyelink will make file with this same name each tst run
p.localizer     = 0; 
p.useStaircase  = 1;

% SET PATHS - PSYCHTOOLBOX AND KIT (subscripts)
p.main_path = pwd; % get current path
    
if IsOSX
    addpath(genpath([p.main_path, '/KIT/']));   % add functions folder
else
    addpath([p.main_path, '\KIT\']);            % add functions folder PC style
end

PsychDefaultSetup(2);    % set to: (0) calls AssertOpenGL (1) also calls KbName('UnifyKeyNames') (2) also calls Screen('ColorRange', window, 1, [], 1); immediately after and whenever PsychImaging('OpenWindow',...) is called

% KEYBOARD 
KbName('UnifyKeyNames');
% specify key names of interest in the study N.B. PsychDefaultSetup(1+) already sets up KbName('UnifyKeyNames') using PsychDefaultSetup(1 or 2);
p.activeKeys = [KbName('space'), KbName('Return'), KbName('C'),KbName('V'),KbName('O'), KbName('Escape')]; % CHECK
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck([p.activeKeys]);
p.quitKey = KbName('Escape');
p.calibKey = KbName('c');  % Key during breaks to call calibration
p.validKey = KbName('v');  % Key during breaks to call validation of calibration
p.quitKey = KbName('q');   % Key during breaks to stop eyetracking

% INITIATE AUDIO
p = audioOpen(p);    %openAudioPort(p);  

% GET EYELINK DETAILS
[p] = askEyelink(p); % determine whether eyetracker is used, which eye is 'policed' and whether 'dummy' mode is used %% SUB-SCRIPT

% CHECK THESE VARIABLES BEFORE STARTING!!!
% WINDOW DIMENSIONS 
p.scr.testDimensionX = 600; % in pixels
p.scr.testDimensionY = 600;
p.scr.testDimensions = [0, 0, p.scr.testDimensionX, p.scr.testDimensionY];  %% xTest xTest*.7379 use actual screen ratio from preferences set in prefFunction below

% TEXT  
if p.debug
    p.scr.textSize = 14;
else p.scr.textSize = 18;
end
% waitText variables  
p.waitText =  5.0; 
p.waitBlank = 0.3;

%  DON'T DELETE if commented out !!!!
 
% TRY - CATCH LOOP (error catch)
try
    
    % DEFINE PTB screen, screen pointer, window and specs
    [p] = openWindowKit(p);         % gets window number and sets wRect
    [p] = SEQ_ParamsScr(p);         % load window-based parameters
    
    %% EYELINK SETUP (includes STEPS 2, 3) - CHECK
    if p.useEyelink               % check if optional use of Eyelink has been specified
        [p] = EL_setup(p);          % script to do setup routine
    end
    
    % MAIN EXPERIMENT BLOCK LOOP
    %  experiment level structure (to include all other variables); save to subject folder
     exper = [];
% %     cd(p.directoryName);
% %     cd(p.subjectFolder);
% %     save('exper', 'exper');
% %     cd ..
% %     cd ..
    
% %     % make TEXTURES for sti                             mDisplay
% %     %[p] =   makeTextures(p);
% %     sr = []; % initialize structure for series
% %     
% %     % RUN LOCALIZER
% %     if p.localizer
% %         lr = []; % structure to save data
% %         lr.number = 1;
% %         
% % % %         % get string specifying quadrants for localizer
% % % %         lr.series = pseudoRandListNoRpt(p); %% SUB-SCRIPT
% % % %         
% % % %         % show the localizer text
% % % %         makeTexts(exper, p, 'localizer', 0);  
% % % %         [quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT
% %         
% %         if quitNow
% %         end
% %         
% %         % EYETRACKING
% %         if p.useEyelink == 1
% %             % if a EL file is still open from previous recording, close it
% %             if p.statusFile == 0
% %                 p.statusFile = EL_closeFile();
% %             end
% %             % open .edf file for new series
% %             thisFileName = strcat( 'Lr', num2str( lr.number));
% %             EL_openFile(p, thisFileName, lr.number); % open and name file for this series
% %             
% %             % do calibration, save .edf file, (re)start eyetracker
% %             if lr.number == 1 % choose text to show 'first' or 'subsequent'
% %                 calText = 'first';
% %             else    
% %                 calText = 'subsequent';
% %             end
% %             p = EL_calibration(p, calText);
% %             % Do last check of eye position (driftcorrect does NOT recalibrate)
% %             % EyelinkDoDriftCorrection(p.el);
% %             p.statusRecord = EL_startRecord(lr.number); % CHECK
% %         end
% %         
% %         % RUN LOCALIZER
% %         [p, lr] = localizerProc( p, lr); 
% %         
% %         % add to main structre
% %         exper.lr = lr;
% %         
% %         % if  EYETRACKING previous series, stop now, save and move file to subject folder
% %         if p.useEyelink
% %             if p.statusRecord == 0
% %                 p = EL_stopRecord(p, lr);
% %                 p = EL_closeFile( p, lr);
% %             end
% %         end
% %         screenBlank(p);
% %     end
% %     % END LOCALIZER 
% %     
% %     % START STAIRCASE
% %     if p.useStaircase  
% % %         makeTexts(exper, p, 'useStaircase', 0);  
% % %         [quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT
% %         for str_i = 1: p.staircaseSeriesNum
% %             str  = [];
% %             str.number = str_i;
% %             [ seriesDot] = makeDotSeries( p, p.series.dotP robStaircase); %% SUB-SCRIPT
% %              str.dot.series = seriesDot;
% %              [ p, str] = stimDisplayProc( p, str, 'useStaircase');
% %             % name/number series and add to exp structure
% %             strName = sprintf('str%d',str_i);
% %             exper.(strName) = str;
% %             dotIntFactor(str_i) = str.PSEfinal;
% %         end
% %         % name/number series and add to exp structure
% %         strName = sprintf('str%d',str_i);
% %         exper.(strName) = str;
% %         p.scr.thisProbe = round(mean(dotIntFactor)*100)/100;       
% %         
% %     end
% %     %  DON'T DELETE if commented out !!!!
% %     
% %     %% show the introductory text screen
% %     sr = []; %  variable
% %     makeTexts(exper, p, 'intro', sr);   %% SUB-SCRIPT (exp, p, textName, sr) calls makeTexts.m
% %     doKbCheck(p, 2)                        %% SUB-SCRIPT % get participant to move forward using TWO keystrokes
    
    % BLOCK setup
    if p.localizer 
        localizerDone = 0;
        p.blockNumber = p.blockNumber + 1; % main blocks plus localizer block
    end
    if p.useStaircase 
        staircaseDone = 0;
        p.blockNumber = p.blockNumber + 1; % main blocks plus staircase block
    end
     
    % BLOCK LEVEL
    for bl_i = 1 : p.blockNumber
        
        if p.localizer && ~localizerDone
            blName = sprintf('LR%d',bl_i);
            numSeries = 1;
        elseif p.useStaircase && ~staircaseDone
             blName = sprintf('STR%d',bl_i); 
             numSeries = 3;
        else blName = sprintf('sr%d',bl_i); 
            numSeries = p.seriesNumber;
        end
        
        % SERIES LEVEL
        for sr_i = 1 : numSeries
            numSeries
            % initialize new series structure
            sr = [];
            sr.number = sr_i;
            
            if p.localizer && ~localizerDone
                
                % make series specifying quadrants for localizer
                sr.type = 'LR';
                sr.series = pseudoRandListNoRpt(p); %% SUB-SCRIPT               
                if sr_i >= numSeries
                    localizerDone = 1;
                end
                % TEXT
                makeTexts(exper, p, sr.type, sr);
                [quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT
                
                if quitNow
                    break; 
                end
                
            else % stairCase or main
                                
                [seriesPred, trackerByElement, trackerByChunk] = makePredSeriesReplaceNoRptEven(p); %% SUB-SCRIPT
                sr.pred.series = seriesPred;
                sr.pred.trackerByElement  = trackerByElement;
                sr.pred.trackerByChunk  = trackerByChunk;
                
                if  p.useStaircase && ~staircaseDone
                    sr.type = 'STR';
                    % specify series 
                    [ seriesDot] = makeDotSeries( p, p.series.dotProbStaircase); %% SUB-SCRIPT
                    sr.dot.series = seriesDot;
                     
                    if sr_i >= numSeries
                        staircaseDone = 1;
                    end
                    
                    % TEXTS
                    makeTexts(exper, p, sr.type, sr);   
                    [quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT
                    if quitNow
                    break; end
                
                else
                    sr.type = 'sr';
                    [seriesDot] = makeDotSeries(p, p.series.dotProb); % SUB-SCRIPT
                    sr.dot.series = seriesDot;
                  
                    if sr_i == 1
                        % show the Main experiment text
                        makeTexts(exper, p, sr.type, sr);
                        [quitNow] = doKbCheck( p, 2);  % SUB-SCRIPT
                        if quitNow
                        break; end 
                    else
                        % show continuation-of-block presentation text
                        makeTexts(exper, p, sr.type, sr);
                        [quitNow] = doKbCheck( p, 2);  % SUB-SCRIPT
                        if quitNow
                         break; end  %% SUB-SCRIPT
                    end
                end
            end

            % EYETRACKING
            if p.useEyelink == 1
                
                % if a file is still open from previous recording, close it
                if p.el.statusFile == 0
                    p.el.statusFile = EL_closeFile();
                end
                % open .edf file for new series
                thisFileName = strcat( sr.type, num2str( sr.number));
                EL_openFile(p, thisFileName, sr.number) % open and name file for this series
                
                % do calibration, save .edf file, (re)start eyetracker
                if sr.number == 1 % choose text to show 'first' or 'subsequent'
                    calText = 'first';
                else
                    calText = 'subsequent';
                end
                p = EL_calibration(p, calText);   %% CHECK 'main' vs. 'practice' or 'staircase'
                % Do last check of eye position (does NOT recalibrate)
                EyelinkDoDriftCorrection(p.el);
                p.statusRecord = EL_startRecord(sr.number);
            end
            
            % RUN NEXT SERIES
            [p, sr] = stimDisplayProc( p, sr);
                        
            % if already eyetracking last series stop, save and move file to subject folder
            if p.useEyelink
                if p.statusRecord == 0
                    p = EL_stopRecord(p, sr);
                    p = EL_closeFile(p, sr);
                end
            end
            screenBlank(p);  
             
            % name/number series and add to exp structure
            srName = sprintf('sr%d',sr_i);
            exper.(blName).(srName) = sr;
            
            if strcmp(sr.type, 'STR')
                p.scr.probeEstimate(sr.number) = p.scr.thisProbe;
            end
            
            % give task feedback
            if strcmp(sr.type, 'sr') % && sr_i < p.seriesNumber
                 taskFeedback(p, sr);
            end 
            
        end  % END OF SERIES LOOP
        
    end % END OF BLOCK LOOP
    exper.params = p;
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
    [exper, ~] = makeTexts(exper, p, 'endExperiment', sr);
    %%DrawFormattedText(p.scr.window, text2show, 'center','center', p.scr.textColor); %%, p.scr.textType);
    WaitSecs(2); % CHECK for real experiment
    
catch
    psychrethrow(psychlasterror);
    cleanup(p);
end
 
cleanup(p);
end

function [] = cleanup(p)
Screen('CloseAll');
PsychPortAudio('Close');
KbQueueRelease();           
RestrictKeysForKbCheck([]);
ShowCursor;
Priority(0);
clear MEX;
if p.useEyelink
    Eyelink('Stoprecording');
    Eyelink('Closefile');
    Eyelink('Shutdown');
end              
end



