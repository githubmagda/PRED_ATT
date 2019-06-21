c
function[] = testEyetrackerKit2()

% basic settings
PsychDefaultSetup(2);
InitializePsychSound(0);

% SOUND DETAILS
aud.reqlatencyclass = 2; % query: PsychPortAudio('GetDevices', [], 0)
aud.deviceid = 0; % 0 = CoreAudio - low latency
aud.freq = 44100; % for OSX  % Must set this. 48 khz most likely to work, as mandated by HDA spec. Common rates: 96khz, 48khz, 44.1khz.
aud.handle = PsychPortAudio('Open', [], [], aud.reqlatencyclass, aud.freq, [], [] ); %[, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,
aud.volume = 0.5;

% Generate sounds: X Hz, 0.X secs, 50% amplitude:
aud.beepHappy(1,:) = aud.volume * MakeBeep(10000, 0.01, aud.freq); % make matrix with 2 'channels'
aud.beepHappy(2,:) = aud.beepHappy(1,:);

aud.beepWarn(1,:) = aud.volume * MakeBeep(1000, 0.01, aud.freq);
aud.beepWarn(2,:) = aud.beepWarn(1,:);

% warning: [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)]; % [sin(1:.001:1.01)];%

% Fill buffer with data for beep Happy:
PsychPortAudio('FillBuffer', aud.handle, aud.beepHappy);
PsychPortAudio('Start', aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', aud.handle, 1);

% beep Warn
PsychPortAudio('FillBuffer', aud.handle, aud.beepWarn);
PsychPortAudio('Start', aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', aud.handle, 1);

% Perform one warmup trial, to get the sound hardware fully up and running,
% performing whatever lazy initialization only happens at real first use.
% This "useless" warmup will allow for lower latency for start of playback
% during actual use of the audio driver in the real trials:
PsychPortAudio('Start', aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', aud.handle, 1);

% variables
dummymode=0;
testWindow = 1;

% WINDOW DIMENSIONS
testDimensionX = 600; % in pixels
testDimensionY = 600;
testDimensions = [0, 0, testDimensionX, testDimensionY];  %% xTest xTest*.7379 use actual screen ratio from preferences set in prefFunction below

% SOUND

% KEYBOARD
% specify key names of interest in the study N.B. PsychDefaultSetup(1+) already sets up KbName('UnifyKeyNames') using PsychDefaultSetup(1 or 2);
KbName('UnifyKeyNames');
activeKeys = [KbName('space'), KbName('Return'), KbName('C'),KbName('V'),KbName('O'),KbName('Escape')]; % CHECK
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck(activeKeys);

try
    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest display number is
    % a best guess about where you want the stimulus displayed.
    screenNumber=max(Screen('Screens'));
    
    if testWindow
        
        Screen('Preference', 'VisualDebugLevel', 3);
        Screen('Preference', 'SuppressAllWarnings', 1);
        Screen('Preference', 'SkipSyncTests', 2);
        Screen('Preference', 'Verbosity', 3); % e.g. 0 for faster processing, 2 or maybe 3 for debugging 
        
        % Open a TEST window.
        [w, wRect]=Screen('OpenWindow',screenNumber, 0.5, testDimensions);
        %HideCursor;
        
    else
        % Open a fullscreen window.
        [w, wRect]=Screen('OpenWindow',screenNumber);
        HideCursor;
    end
    
    % Set background color to gray.
    backgroundColor=GrayIndex(w); % returns as default the mean gray value of screen
    
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(w);
    
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    % Set background color to 'backgroundcolor' and do initial flip to show
    % blank screen:
    Screen('FillRect', w, backgroundColor, wRect);
    Screen('Flip', w);
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    % open file to record data to
    Eyelink('openfile', 'demo.edf');
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    
    WaitSecs(0.5);
    Eyelink('StartRecording');
    
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end
    
    WaitSecs(1);
    % stop eyelink
    Eyelink('StopRecording');
    
catch lasterror
    cleanup
    psychrethrow(lasterror);
end
cleanup
end


% Cleanup routine:
function cleanup

Eyelink('Shutdown'); % Shutdown Eyelink:
sca; % Close PTB window:
Priority(0);
commandwindow;
ShowCursor;
PsychPortAudio('Close');
%KbQueueFlush(); 
RestrictKeysForKbCheck([]);
end
