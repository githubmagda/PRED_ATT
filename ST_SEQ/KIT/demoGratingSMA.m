function[] = demoGratingSMA()

% Clear the workspace and the screen
sca;
close all;
clearvars;

% VARIABLES & TIMING
nTrials             = 4;
imageDur            = 1.5;
fixDur              = 1.0;
nGratings           = 4;
nBlobs              = 2;

% use eyelink?
useEyelink          = 0;
dummymode           = 0;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);

% Setup defaults and unit color range:
PsychDefaultSetup(2);


try
    
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    
    % Open the screen
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 600 600]);
    % Dimension of the region where will draw the grating in pixels
    winWidth   = windowRect(3);
    winHeight  = windowRect(4);
    
    % Enable alpha-blending, set it to a blend equation useable for linear
    % additive superposition. This allows to linearly
    % superimpose gabor patches in the mathematically correct manner, should
    % they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
    % the 'DrawTextures' can be used to modulate the intensity of each pixel of
    % the drawn patch before it is superimposed to the framebuffer image, ie.,
    % it allows to specify a global per-patch contrast value:
    Screen('BlendFunction', window, GL_ONE, GL_ONE); %MA
    %Screen('Blendfunction', window, GL_ONE, GL_ONE_MINUS_SRC_ALPHA); 

    %--------------------
    % Grating information
    %--------------------
    
    size = 64;
    % Size of support in pixels, derived from size:
    tw = 2*size+1;
    th = 2*size+1;
    
    % grating
    backgroundColorOffsetGrat       = [0, 0, 0, 0];
    contrastPreMultiplicatorGrat    = 1;
    
    % round mask
    radius = 50;
    
    % Phase of underlying sine grating in degrees:
    phase = 90;
    % Spatial constant of the exponential "hull"
    sc = 20;
    % Frequency of sine grating:
    freq = .1;
    % Contrast of grating:
    contrast = 1.0;
    % Aspect ratio width vs. height:
    aspectratio = 1.0;
    % Angles 
    angleSet = [20, 20, 115, 20]';
    
    left            = -100;
    right           = +100;
    up              = -100;
    down            = +100;
    
    paramsGratings      = repmat([phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]', 1, nGratings);
    paramsBlobs         = repmat([contrast, sc, aspectratio, 0]', 1, nBlobs);
    
    % Build a procedural gabor texture for a gabor with a support of tw x th
    % pixels IF You set []=4 to '1' it means 'nonsymetric' flag set to 1 == Gabor shall allow runtime
    % change of aspect-ratio:
    [gaborTex, gaborRect]       = CreateProceduralGabor(window, winWidth/2, winHeight/2);
    [gratingTex, gratingRect]   = CreateProceduralSineGrating(window, winWidth/2, winHeight/2, backgroundColorOffsetGrat, radius, contrastPreMultiplicatorGrat);
    
    % Ditto for some gaussian blobs, just for variety. Need a bigger mathematical
    % support here to avoid cutoff artifacts (tw * 2, th * 2):
    [blobTex, blobRect]         = CreateProceduralGaussBlob(window, winWidth/2, winHeight/2);
   
    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
    Screen('DrawTextures', window, gratingTex, [], [], [], [], [], ...
        [], [], [], repmat([phase+180, freq, contrast, 0], 2, 1)');
    %Screen('DrawTexture', window, gratingTex, [], gratingRect, [], [], [], [], [], kPsychDontDoRotation, [contrast, sc, aspectratio, 0]);
    Screen('Flip', window);
            %Screen('DrawTextures', window, blobTex, [], dstBlobRects(:,2), [], 1, [], [], [], kPsychDontDoRotation, paramsBlobs(:,2));

    Screen('DrawTexture', window, blobTex, [], blobRect, [], [], [255,0,0,0], [], [], kPsychDontDoRotation, [contrast, sc, aspectratio, 0]);
    Screen('Flip', window);
    Screen('DrawTexture', window, gaborTex, [], gaborRect, [], [], [], [], [], kPsychDontDoRotation, [contrast, sc, aspectratio, 0]);
    Screen('Flip', window);
    Screen('DrawingFinished', window);
    
    Screen('Flip', window);
    WaitSecs(0.1);
    
    %--------------------
    % fix cross
    %--------------------
    fixCrossColor       = [ 0, 0, 0, 1];
    fixCrossLineWidth   = 3;
    fixCrossArmLength   = 15;
    xCoords             = [ winWidth/2-fixCrossArmLength, winWidth/2+fixCrossArmLength , winWidth/2, winWidth/2];
    yCoords             = [ winWidth/2, winWidth/2, winWidth/2-fixCrossArmLength, winWidth/2+fixCrossArmLength]; %[0, 0, 0, 0];
    allCoords           = [xCoords; yCoords];
    
    
    % Preallocate array with destination rectangles:
    % This also defines initial gabor patch orientations, scales and location
    % for the very first drawn stimulus frame:
    scaleGratings           = ones(1, nGratings);
    scaleBlobs              = [100, 50];

    gratingRectSet          = repmat(gratingRect, nGratings, 1);
    blobRectSet             = repmat(blobRect,  nGratings, 1);
    
    gratingX                = [ winWidth/2-100, winWidth/2+100, winWidth/2+100, winWidth/2-100];
    gratingY                = [ winHeight/2-100, winHeight/2-100, winHeight/2+100, winHeight/2+100];
    blobX                   = [ winWidth/2, winWidth/2, winWidth/2, winWidth/2 ];
    blobY                   = [ winHeight/2, winHeight/2, winHeight/2, winHeight/2 ];
    
    dstGratingsRects        = zeros(4, nGratings);
    dstBlobRects            = zeros(4, nBlobs);
    
    for j = 1:nBlobs
        dstBlobRects(:,j)    = CenterRectOnPointd(blobRectSet(j,:), blobX(j), blobY(j))';
    end
    
    for k =1 :nGratings
        dstGratingsRects(:,k) = CenterRectOnPointd(gratingRectSet(k,:) , gratingX(k), gratingY(k))';
    end

    for i = 1: nTrials
        
        % Preallocate array with rotation angles:
        rotAngles = [115, 25, 25, 25];
        
        % EYELINK
        if useEyelink
            eye.fixPoliceX          = winWidth/2;
            eye.fixPoliceY          = winHeight/2;
            eye.fixPoliceRadius     = 30;
            eye.maxPoliceErrorTime  = .2;           % allow for blinks out of monitored area
            eye.policeEye           = 2;            % 1 = left, 2 = right;
            eye.fixPoliceOffset     = 100;
            eye.gazeRightBorder     = eye.fixPoliceX + eye.fixPoliceOffset;
            eye.gazeLeftBorder      = eye.fixPoliceX - eye.fixPoliceOffset;
            
            % name .edf file for this series
            edfFileName = strcat( 'Test.edf', num2str(1));
            
            % set Eyelink defaults
            el=EyelinkInitDefaults(window);
            
            % Initialization of the connection with the Eyelink Gazetracker.
            % exit program if this fails.
            if ~EyelinkInit(dummymode)
                fprintf('Eyelink Init aborted.\n');
                cleanup;  % cleanup function
                return;
            end
            
            % set specs for output in edf file
            Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
            Eyelink('command', 'link_event_data = ');
            
            statusFile = Eyelink('Openfile', edfFileName);
            % send message to edf file
            Eyelink('Message', 'File_created: ', edfFileName);
            
            % STEP 4
            % Calibrate the eye tracker
            EyelinkDoTrackerSetup(el);
            
            % do a preseries check of calibration using drift correction
            EyelinkDoDriftCorrection(el);
            
            WaitSecs(0.5);
            Eyelink('StartRecording');
            WaitSecs(0.1);
        end
        
        trialStart = GetSecs; % start timer for first trial
        
        %for k = 1:4
        
        %     trial l
        %     select              = randi( 2,1);
        %     thisAngle           = angleSet( select);
        %     select              = randi(2,1);
        %     thisWidthOffset     = offsetWidthSet(select);   % randomly place on left or right
        % Draw gratings with  angles to dstRects
        for k = 1: nGratings
            Screen('DrawTextures', window, gratingTex, [], dstGratingsRects(:,k), rotAngles(k), [], [], [], [], [], paramsGratings(:,1))
        end
        % Flip to the screen
        [ vblImage] = Screen('Flip', window);
        WaitSecs(0.5);
        % Draw main fixation gaussian blobs:
        
        Screen('DrawTextures', window, blobTex, [], dstBlobRects(:,1), 0, [], 1, [255,0,0,0], [], kPsychDontDoRotation, paramsBlobs(:,1));
        % Flip to the screen
        [ vblImage] = Screen('Flip', window);
        WaitSecs(0.5);
        
        % Draw fixation cross
        Screen('DrawLines', window, allCoords, fixCrossLineWidth, [ 1,1,1,1]);
        Screen('DrawTextures', window, blobTex, [], dstBlobRects(:,2), 0, [], [], [], [], kPsychDontDoRotation, paramsBlobs(:,2));
        
        % Flip to the screen
        [ vblImage] = Screen('Flip', window);
        
        if useEyelink
            % police eyes
            leftRight = 0; % monitor for central fixation, not saccade
            sanjeevMonitorFixation( p, imageDur, leftRight);
        else
            WaitSecs( imageDur);
        end
        
        % just fixation cross
        Screen('DrawLines', window, allCoords, fixCrossLineWidth, fixCrossColor);
        
        % Flip to the screen
        [ vblFix] = Screen('Flip', window);
        
        if useEyelink
            % police eyes
            leftRight = 1;         % monitor for left/right saccade
            sanjeevMonitorFixation(p, fixDur, leftRight);
        else
            WaitSecs( fixDur);
        end
        
    end
    
catch
    psychrethrow( psychlasterror);
    cleanup( useEyelink);
end

% Wait for a button press to exit
KbCheck;

% Clear screen
cleanup(useEyelink)
end


function[] = cleanup(useEyelink)
sca;
ShowCursor;
if useEyelink
    Eyelink('Closefile');
    Eyelink('StopRecording');
    Eyelink('Shutdown');
end
end


%Published with MATLAB® R2015b