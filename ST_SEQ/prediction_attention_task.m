%% DESCRIPTION : Experimental procedure for an investigation of visual covert
% spatial attention and procesing of predictive spatial sequences

% Made with love and frustration 2018-2020 by Magda Altman, BCBL
      
% CHANGELOG


% PREAMBLE

p = [];
% set debug state
p.debug                 = 1; % run with smaller window in debug mode
% Note if running in debug mode, this is a helpful way to run: eval('prediction_attention_task','clear screen;error(''prediction_attention_task'')')
% use eyelink
debug_screen_x          = 600;
p.scr.testDimensions    = [0, 0, round(debug_screen_x), debug_screen_x/1.33];  %% 1024 x 768 ratio
p.useEyelink            = 0; % 1 or 0 to track right eye or not to track

% setup paths

p.main_path = pwd; % get current path

if IsOSX || IsLinux
    addpath(genpath([p.main_path, '/KIT/']));   % add functions folder
    disp(['Configuring for Linux...']);
else
    addpath([p.main_path, '\KIT\']);            % add functions folder PC style
    warning(['Ubuntu recommended for best functionality']);
end

Screen('CloseAll');  %% CHECK - can all this be done with a call to cleanup.m?
PsychPortAudio('Close'); 
%KbQueueRelease();
RestrictKeysForKbCheck([]); 
%ShowCursor;
Priority(0);
clear MEX;
sca;
close all;

rng('shuffle') % ensure random generator does not repeat on startup VERY IMPORTANT
p.randstate = rng; % allows for recreation of sequence 

PsychDefaultSetup(2);    % set to: (0) calls AssertOpenGL (1) also calls KbName('UnifyKeyNames') (2) also calls Screen('ColorRange', window, 1, [], 1); immediately after and whenever PsychImaging('OpenWindow',...) is called

% Open a window and load parameters
try
    p = openWindow(p); % gets window number and sets wRect
    p = param(p);
catch
    psychrethrow(psychlasterror);
    cleanup(p);
end

% input settings
KbName('UnifyKeyNames');
if ~p.debug
    ListenChar(2); % suppress input to command window
end
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck([p.activeKeys]);

% initialize audio
if p.useAudio
    p = audioOpen(p);    % openAudioPort(p);
end

% setup eyelink
if p.useEyelink               % check if optional use of Eyelink has been specified
    p = EL_setup(p);          % script to do setup routine
end

% Setup the textures
[p, tex] = makeTextures(p);     % textures for gratings (also display coordinates) , fixation and attention dots

%  experiment level structure (to include all other variables); save to subject folder
exper = [];
% %     cd(p.directoryName);
% %     cd(p.subjectFolder);
% %     save('exper', 'exper');
% %     cd ..
% %     cd ..

% MAIN EXPERIMENT SEQUENCE

% intro
    
intro(p);

% fixation and grating training

intro_fix_and_grat(p, tex);

% eyetracker training
% intro_eyetracker(p);

% intro and run localizer
exper = localizerNew( p, tex, exper);

%% staircase
exper = staircase( p, tex, exper);


% % staircase
% 
% str.angleSet = mod(p.grat.angleSet(thisPred) + p.grat.angleIncrement, 180);
% 





% BLOCK setup
if p.localizer
    localizerDone = 0;
    p.blockNumber = p.blockNumber + 1; % main blocks plus localizer block
end
if p.useStaircase
    staircaseDone = 0;
    p.blockNumber = p.blockNumber + 1; % main blocks plus staircase block
end

% intro
makeTexts(exper, p, 'welcome', 0);              % hello

% fixation
makeTexts(exper, p, 'cross_Intro', 0);          % show cross - fixate
makeTexts(exper, p, 'cross_Intro_2', 0);        % explain gratings - fixate
makeTexts(exper, p, 'cross_Intro_ex', 0);       % show cross + gratings

% calibration
makeTexts(exper, p, 'calibration_Intro', 0);  	% intro eyetracker
if p.useEyelink                                 % calibration
    [p, result] = eyetrackerRoutine(p);
    makeTexts(exper, p, 'calibration_result', 0, result);
end

% police
makeTexts(exper, p, 'police_Intro', 0);      % intro policing
makeTexts(exper, p, 'police_Intro_ex', 0);     %  policing
makeTexts(exper, p, 'police_reminder', 0);      % reminder don't move

%     if ~p.localizer % practice version of localizer for Introduction
%         makeTexts(exper, p, 'LR_Intro', 0);
%         makeTexts(exper, p, 'LR_Intro_ex', 0);
%     end

%     % staircase
%     if ~ p.staircase
%         makeTexts(exper, p, 'staircase_Intro', 0);
%         makeTexts(exper, p, 'staircase_Intro_ex', 0);
%     end
%
%     % question
%     makeTexts(exper, p, 'question_Intro', 0);
%     makeTexts(exper, p, 'question_Intro_ex', 0);


% BLOCK LEVEL
for bl_i = 1 : p.blockNumber
    
    if p.localizer && ~localizerDone
        blName = sprintf('LR%d',bl_i);
        numSeries = 1;
        
    elseif p.useStaircase && ~staircaseDone
        blName = sprintf('STR%d',bl_i);
        numSeries = 1;
        
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
            
            % TEXTS
            if sr_i ==1  % localizer intro - show only once
                makeTexts(exper, p, 'LR_Intro', 0);
                makeTexts(exper, p, 'LR_Intro_ex', 0);
            end
            makeTexts(exper, p, sr.type, sr);
            
            quitNow = 0;
            [quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT
            if quitNow
                break;
            end
            
        else % stairCase or main
            [seriesPred, trackerByElement, trackerByChunk] = makePredSeries(p); %% SUB-SCRIPT
            %%[seriesPred, trackerByElement, trackerByChunk] = makePredSeriesReplaceNoRptEven(p); %% SUB-SCRIPT
            sr.pred.series = seriesPred;
            sr.pred.trackerByElement  = trackerByElement;
            sr.pred.trackerByChunk  = trackerByChunk;
            
            if  p.useStaircase && ~staircaseDone
                
                sr.type = 'STR';
                % specify series
                [ seriesDot] = makeDotSeries( p, p.dot.probStaircase); %% SUB-SCRIPT
                sr.dot.series = seriesDot;
                
                if sr_i ==1 % show intro and example only first time
                    makeTexts(exper, p, 'staircase_Intro', 0);
                    makeTexts(exper, p, 'staircase_Intro_ex', 0);
                    makeTexts(exper, p, 'staircase_Intro2', 0);
                    makeTexts(exper, p, 'staircase_Intro2_ex', 0);
                    makeTexts(exper, p, 'question_Intro', 0);
                    makeTexts(exper, p, 'question_Intro_ex', 0);
                end
                
                makeTexts(exper, p, sr.type, sr);      % staircase
                [quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT
                if quitNow
                    break;
                end
                if sr_i >= numSeries
                    staircaseDone = 1;
                end
            else
                sr.type = 'sr';
                [seriesDot] = makeDotSeries(p, p.dot.prob); % SUB-SCRIPT
                sr.dot.series = seriesDot;
                
                if sr_i == 1
                    % show the Main experiment text
                    makeTexts(exper, p, sr.type, sr);
                    [quitNow] = doKbCheck( p, 2);  % SUB-SCRIPT
                    if quitNow
                        break;
                    end
                else
                    % show continuation-of-block presentation text
                    makeTexts(exper, p, sr.type, sr);
                    % % %                         [quitNow] = doKbCheck( p, 2);  % SUB-SCRIPT
                    % % %                         if quitNow
                    % % %                          break; end  %% SUB-SCRIPT
                end
            end
        end
        
        % EYETRACKING
        if p.useEyelink == 1
            
            eyetrackerRoutine(p,sr);
            
            %                 % if a file is still open from previous recording, close it
            %                 if p.el.statusFile == 0
            %                     p.el.statusFile = EL_closeFile();
            %                 end
            %                 % open .edf file for new series
            %                 thisFileName = strcat( sr.type, num2str( sr.number));
            %                 EL_openFile(p, thisFileName, sr.number) % open and name file for this series
            %
            %                 % do calibration, save .edf file, (re)start eyetracker
            %                 if sr.number == 1 % choose text to show 'first' or 'subsequent'
            %                     calText = 'first';
            %                 else
            %                     calText = 'subsequent';
            %                 end
            %                 p = EL_calibration(p, calText);   %% CHECK 'main' vs. 'practice' or 'staircase'
            %                 % Do last check of eye position (does NOT recalibrate)
            %                 EyelinkDoDriftCorrection(p.el);
            %                 p.statusRecord = EL_startRecord(sr.number);
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

% DISPLAY end of experiment
Screen('TextSize', p.scr.window, p.scr.textSize);
[exper, ~] = makeTexts(exper, p, 'endExperiment', sr);
%%DrawFormattedText(p.scr.window, text2show, 'center','center', p.scr.textColor); %%, p.scr.textType);
WaitSecs(2); % CHECK for real experiment

cleanup(p);






