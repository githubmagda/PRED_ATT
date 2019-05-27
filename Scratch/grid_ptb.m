function grid_ptb

try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox.
    
    %     AssertOpenGL;
    
    % Sets up things like OpenGL, and standardizes color range to 0-1
    PsychDefaultSetup(2);
    
    
    % This is just for debigging, remove when code is deployed
    
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
    
    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);
    
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end
    
    % Not sure which call to open window is the best yet
    [w, rect] = PsychImaging('OpenWindow', screenNumber, white, [0 0 600 600]);
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', w);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = 15;
    
    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    % Keep in mind that the lines are diagonal so longer than the edges, so
    % define in the methods the size of the square whos conners they
    % connect (Note: y-axis seems to be flipped, seems to eb openGL thing)
    
    xCoords = [0 -fixCrossDimPix 0 fixCrossDimPix 0 fixCrossDimPix 0 -fixCrossDimPix];
    yCoords = [0 -fixCrossDimPix 0 -fixCrossDimPix 0 fixCrossDimPix 0 fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    
    % Set the colors for the 4 attention conditions
    % use 1 for white, or 0.5 for gray (use white if using an inner mask)
    col = 1;
    att1 = [col 1 col col col col col col; col 0 col col col col col col; col 0 col col col col col col]; % upper-left
    att2 = [col col col 1 col col col col; col col col 0 col col col col; col col col 0 col col col col]; % upper-right
    att3 = [col col col col col 1 col col; col col col col col 0 col col; col col col col col 0 col col]; % lower-right
    att4 = [col col col col col col col 1; col col col col col col col 0; col col col col col col col 0]; % lower left
    cond = att4;
    
    % Set the line width for our fixation cross
    lineWidthPix = 4;
    
    % Retreive the maximum priority number
    topPriorityLevel = MaxPriority(w);
    
    % Get the size of the on screen window in pixels
    [screenXpixels, screenYpixels] = Screen('WindowSize', w);
    
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(rect);
    
    % Compute each frame of the movie and convert the those frames, stored in
    % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
    numFrames=60; % temporal period, in frames, of the drifting grating
    steps = [0:(numFrames/2)-1 (numFrames/2)-1:-1:0];
    steps = (steps./max(steps)).*35; % use negative (90 is max) for a pinch instead of pull
    for ii=1:numFrames
        phase=(ii/numFrames)*2*pi;
        % grating
        [x,y]=meshgrid(-300:300,-300:300);
        f = 15/length(x); % cycles/pixel
        %         m=exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
        m = cos(f*2*pi*sqrt(x.^2 + y.^2)+phase);
        [m,~,~] = PinchSpherize(m,steps(ii),150,-150,-150);
        tex(ii)=Screen('MakeTexture', w, (m+1)/2);
    end
    
    % Make a base Rect of 100 by 100 pixels
    baseRect = [0 0 100 100];
    
    % For Ovals we set a miximum diameter up to which it is perfect for
    maxDiameter = max(baseRect) * 1.01;
    
    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    
    % Set the color of the rect to grey
    rectColor = [.5 .5 .5];
    
    % make alphaed gray Gaussian texture
    [x,y] = meshgrid(-50:50, -50:50);
    % set opacity and intensity
    int = 1; % 0 to 1;
    alph = exp(-((x / 25).^2) - ((y / 25).^2)).*int;
    gaus = cat(3,0.5.*ones(101,101,3),alph);
%     gaus = ones(101,101,1);

    gaus_tex=Screen('MakeTexture', w, gaus);

    % Run the movie animation for a fixed period.
    movieDurationSecs=15;
    frameRate=Screen('FrameRate',screenNumber);
    
    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if frameRate == 0
        frameRate=60;
    end
    
    % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    
    % Use realtime priority for better timing precision:
    Priority(topPriorityLevel);
    
    % waitframes
    waitframes = 1;
    
    % Animation loop:
    vbl = Screen('Flip', w);
    for i=1:movieDurationFrames
        % Draw image:
        Screen('DrawTexture', w, tex(movieFrameIndices(i)));
        Screen('DrawTexture', w, gaus_tex,[0 0 101 101], [50 50 151 151]);
        % Draw fixation circle
        Screen('FillOval', w, rectColor, centeredRect, maxDiameter);
        % Draw the fixation cross in white, set it to the center of our screen and
         % set good quality antialiasing
        Screen('DrawLines', w, allCoords,...
        lineWidthPix, cond, [xCenter yCenter], 2);
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    end
    
    Priority(0);
    
    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclosed textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll') and we
    % have 12 textues here:
    Screen('Close');
    
    % Close window:
    sca;
    
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    Screen('Preference', 'SkipSyncTests', oldSkipSyncTests);
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..
