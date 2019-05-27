function grid_ptbMA

try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox.
    
    %     AssertOpenGL;
    
    % Sets up things like OpenGL, and standardizes color range to 0-1
    PsychDefaultSetup(2);
    
    % This is just for debugging, remove when code is deployed
    
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
    
    sizeMain = 400;
    
    % Not sure which call to open window is the best yet % size of main
    % window
    [w, rect] = PsychImaging('OpenWindow', screenNumber, white, [0 0 sizeMain sizeMain]); % [0 0 300 300]
    
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
    
    xCoords = [fixCrossDimPix -fixCrossDimPix -fixCrossDimPix fixCrossDimPix];
    yCoords = [fixCrossDimPix -fixCrossDimPix fixCrossDimPix -fixCrossDimPix];
    %xCoords = [0 -fixCrossDimPix 0 fixCrossDimPix 0 fixCrossDimPix 0 -fixCrossDimPix];
    %yCoords = [0 -fixCrossDimPix 0 -fixCrossDimPix 0 fixCrossDimPix 0 fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    
    % Set the colors for the 4 attention conditions (red leg of fixation
    % top-left, t-r, b-r, b-l in clockwise direction; attnAll is all legs
    % white
    
    % use 1 for white, or 0.5 for gray (use white if using an inner mask);
    % 0 for black (RGB)
    remove = 0.0;
    base = 1.0;
    hilite = 1.0;
    alphO = 0.0;
    alphT = 1.0;
    
    % rgb specs for fixation coordinates clockwise from top-left
    attn1 = [base hilite base base ; base remove base base ; base remove base base]; % ; alphT alphO alphT alphT]; % upper-left
    attn2 = [base base base hilite ; base base base remove ; base base base remove]; %; alphT alphT alphT alphO]; % upper-right
    attn3 = [hilite base base base ; remove base base base; remove base base base]; %; alphO alphT alphT alphT]; % lower-right
    attn4 = [base base hilite base ; base base remove base ; base base remove base]; % ; alphT alphT alphO alphT];
    
    attn0 = [base base base base ; base base base base ; base base base base]; %; alphO alphO alphO alphO];
    
    % Set the line width for our fixation cross
    lineWidthPix = 4;
    
    % Retreive the maximum priority number
    topPriorityLevel = MaxPriority(w);
    
    % Get the size of the on screen window in pixels
    [screenXpixels, screenYpixels] = Screen('WindowSize', w);
    
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(rect);
    
    %% quad rects
    sizeQuadX = sizeMain/2;
    sizeQuadY = sizeMain/2;
    
    % Make 4 base Rect for quadrants
    quadRect = [0 0 sizeQuadX sizeQuadY];
    quadPos1 = [0, 0, sizeQuadX, sizeQuadY];   % xStartPoint yStartPoint
    quadPos2 = [sizeQuadX, 0, sizeMain, sizeQuadY,];
    quadPos3 = [sizeQuadX, sizeQuadY, sizeMain, sizeMain];
    quadPos4 = [0, sizeQuadY, sizeQuadX, sizeMain];
    
    %% Radius of circles / masks
    radiusQuadCircle = 75; % size of inner unmasked circle in quad
    
    %% DOT ATTRIBUTES    
    %dotUnitX = sizeQuadX/3; dotUnitY = sizeQuadY/3; % location with respect to main screen
    dotSize = 31; dotSizeHalf = dotSize/2;
    
    outerHypot = hypot(sizeQuadX/2-10, sizeQuadY/2-10);
    innerHypot = hypot(sizeQuadX/2 - radiusQuadCircle, sizeQuadY/2 - radiusQuadCircle);
    maskDotOuter = createCirclesMaskMA( [ sizeMain+1, sizeMain+1 ], [ xCenter, yCenter ], outerHypot, 'outer');
    maskDotInner = createCirclesMaskMA( [ sizeMain+1, sizeMain+1 ], [ xCenter, yCenter ], innerHypot, 'outer');
    
    maskDotQuadMask = createCirclesMaskMA([sizeQuadX+1, sizeQuadX+1],[(sizeQuadX+1)/2, (sizeQuadX+1)/2], radiusQuadCircle - 15, 'inner');
    maskDotQuadMask(maskDotQuadMask == 1) = 2;
    lenMask = length(maskDotQuadMask);
        
    maskMainDiff = maskDotOuter + maskDotInner; % overlay rings to give 1s for annulus
    maskMainDiff(maskMainDiff == 2) = 4;
    
    %% Calculate mask overlaps for each quad
    maskMainDiff1 = maskMainDiff( 1:lenMask, 1:lenMask);
    maskDotDiffQuad1 = maskMainDiff1 + maskDotQuadMask;
    [rowDotSet1, colDotSet1] =  find(maskDotDiffQuad1 == 2);
    
    maskMainDiff2 = maskMainDiff( lenMask-1:sizeMain, 1:lenMask);
    maskDotDiffQuad2 = maskMainDiff2 + maskDotQuadMask;
    [rowDotSet2, colDotSet2] =  find(maskDotDiffQuad2 == 2);
    
    maskMainDiff3 = maskMainDiff( lenMask-1:sizeMain, lenMask-1:sizeMain);
    maskDotDiffQuad3 = maskMainDiff3 + maskDotQuadMask;
    [rowDotSet3, colDotSet3] =  find(maskDotDiffQuad3 == 2);
    
    maskMainDiff4 = maskMainDiff( 1:lenMask, lenMask-1:sizeMain);
    maskDotDiffQuad4 = maskMainDiff4 + maskDotQuadMask;
    [rowDotSet4, colDotSet4] =  find(maskDotDiffQuad4 == 2);

    %% fixation circle
    % Make a base Rect for grey background circle for fixation of 100 by 100 pixels (or ratio to fixation cross?)
    dotRect = [0 0 round(sizeMain/6) round(sizeMain/6)];  % [0 0 100 100]; %
    % For Ovals we set a miximum diameter up to which it is perfect for
    maxDiameter = max(dotRect) * 1.01;
    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(dotRect, xCenter, yCenter);
    % Set the color of the rect to grey
    rectColor = [.5 .5 .5];
    
    %% gaussian dot
    % make alphaed gray Gaussian texture
    [x,y] = meshgrid(-30:30, -30:30);    %(-50:50, -50:50);
    % set opacity and intensity of attentional dot
    int = 1; % 0 to 1;
    color = 1.0;  % 0:1
    alph = exp(-((x / 15).^2) - ((y / 15).^2)) .* int;  %% gaussian alpha mask
    gaus = cat(3, color.* ones(61,61,1), alph);   % gaus = cat(3,0.5.*ones(61,61,1),alph); ones(101,101,1) creates white box
    
    % attentional dot
    gaus_tex=Screen('MakeTexture', w, gaus);
    
    % %     % possible dot position (select from an arc)
    % %     [pointsSep] = makeArcMA( (sizeQuadX+1), (sizeQuadY+1)/2 , (sizeQuadX+1)/2, (sizeQuadY+1), sizeMain, 2,'right')
    % %
    % Run the movie animation for a fixed period.
    movieDurationSecs = 1;
    frameRate=Screen('FrameRate',screenNumber);
    
    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if frameRate == 0
        frameRate=60;
    end
    
    numFrames = 60; % 30, 60
    % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    
    % Use realtime priority for better timing precision:
    Priority(topPriorityLevel);
    
    % waitframes
    waitframes = 1;
    
    seriesPred = repmat([1,2,3,4],1,10); %% MA added
    seriesAttn = repmat([1,1,1,1],1,10); %zeros(1,stim2Present);
    
    % %     pinchSize = 35; % in or out movement of pred wobble - change below on every other cycle
    % %     posX = -150; posY = -150;
    
    stim2Present = 2; % number of textures created
    
    %initialize
    texM = zeros(stim2Present, numFrames);
    
    for c = 1 : stim2Present
        
        % Compute each frame of the movie and convert the those frames, stored in
        % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
        %numFrames = 60; % temporal period, in frames, of the drifting grating
        %steps = [0:(numFrames)-1 (numFrames)-1:-1:0];
        %steps = (steps./max(steps)).* pinchSize; % use negative (90 is max) for a pinch instead of pull ; larger is a tighter 'pinch'
        tex= zeros(1,60);
        
        for cc=1:numFrames % e.g. 60
            
            phase=(cc/numFrames)*2*pi;
            % grating
            [x,y] = meshgrid(-sizeQuadX/2:sizeQuadX/2,-sizeQuadY/2:sizeQuadY/2); % mesh for main screen % influences number of concentric circles
            f = 30/length(x); % e.g. 15 cycles/pixel
            % m=exp(-((x/90).^2)-((y/90).^2)).*sin(a*x+b*y+phase);
            m = cos(f*2*pi*sqrt(x.^2 + y.^2) + phase);  % *1 reverses color alternation
            % [m,~,~] = PinchSpherizeMA(m,steps(cc),sizeMain/3.5,posX,posY);   % 150,-150,-150 pinchStrength, xPos, yPos
            mask1 = createCirclesMaskMA([sizeQuadX+1, sizeQuadX+1],[(sizeQuadX+1)/2, (sizeQuadX+1)/2], radiusQuadCircle, 'outer');
            m(mask1) = 0;
            if c == 2 % make another mask for the central area (predictive element)
                %mask2 = createCirclesMaskMA([length(m), length(m)],[length(m)/2, length(m)/2], radiusQuadCircle); % ([xDim, yDim],[xCenter, yCenter],radius, peri)
                m(~mask1) = 1;
            end
            tex(cc) = Screen('MakeTexture', w, (m+1)/2);
        end
        texM(c,:) = tex;
    end
    
    %% Before animation loop show cue
    
    % get next position of dot and attentional leg on fix cross
    thisCue = seriesAttn(1);
    % save to trial structure
    trial.thisCue = thisCue;  % save to trial level
       
    if thisCue == 1
        randChoose = randi([1,4],1); % randomally allocate attentional cue
        switch randChoose          
            case 1
                attn = attn1; % selects the fixation cue
                rowDotSet = rowDotSet1; 
                colDotSet = colDotSet1; % defines set of possible dot locations
            case 2
                attn = attn2;
                rowDotSet = rowDotSet2  + sizeQuadX; 
                colDotSet = colDotSet2;                 
            case 3
                attn = attn3;
                rowDotSet = rowDotSet3  + sizeQuadX; 
                colDotSet = colDotSet3  + sizeQuadY; 
            case 4
                attn = attn4;
                rowDotSet = rowDotSet4; 
                colDotSet = colDotSet4  + sizeQuadY;        
        end
    end
    
    % Draw the cue fixation cross
    Screen('FillRect', w, rectColor);
    Screen('DrawLines', w, allCoords, lineWidthPix, attn, [xCenter yCenter], 2);
    vbl = Screen('Flip', w);
    WaitSecs(60*ifi);
    
    for f = 1:30
        texBasic = texM(1,:); % alternative choice from matrix
        texPred = texM(2,:);
        % get next quadrant from prediction series controlling position of
        % wobble
        tex1 = texBasic; tex2 = texBasic; tex3 = texBasic; tex4 = texBasic;
        thisPred = seriesPred(f);
        
        switch thisPred
            case 1
                tex1 = texPred;
            case 2
                tex2 = texPred;
            case 3
                tex3 = texPred;
            case 4
                tex4 = texPred;
        end
        
        randSelect = randi(length(rowDotSet), 1);
        dotPosX = rowDotSet(randSelect);
        dotPosY = colDotSet(randSelect);
        
        predOffset = 7; % duration of predictive flash
        dotOnset = randi([predOffset, movieDurationFrames/1.2], 1);
        
        dotXStart = dotPosX - dotSizeHalf; dotXEnd = dotPosX + dotSizeHalf;
        dotYStart = dotPosY - dotSizeHalf; dotYEnd = dotPosY + dotSizeHalf;
        
        for ff=1:movieDurationFrames
            
            if ff <= predOffset
                % Draw main and wobble textures:
                %Screen('DrawTexture', w, tex(movieFrameIndices(ff)),[],[],rotate); % main concentric grids
                Screen('DrawTexture', w, tex1(movieFrameIndices(ff)),quadRect, quadPos1, []); % main concentric grids  [rotate] put angle in degrees
                Screen('DrawTexture', w, tex2(movieFrameIndices(ff)),quadRect, quadPos2, []); % main concentric grids  [rotate] put angle in degrees
                Screen('DrawTexture', w, tex3(movieFrameIndices(ff)),quadRect, quadPos3, []); % main concentric grids  [rotate] put angle in degrees
                Screen('DrawTexture', w, tex4(movieFrameIndices(ff)),quadRect, quadPos4, []); % main concentric grids  [rotate] put angle in degrees
            else
                Screen('DrawTexture', w, texBasic(movieFrameIndices(ff)),quadRect, quadPos1, []); % main concentric grids  [rotate] put angle in degrees
                Screen('DrawTexture', w, texBasic(movieFrameIndices(ff)),quadRect, quadPos2, []); % main concentric grids  [rotate] put angle in degrees
                Screen('DrawTexture', w, texBasic(movieFrameIndices(ff)),quadRect, quadPos3, []); % main concentric grids  [rotate] put angle in degrees
                Screen('DrawTexture', w, texBasic(movieFrameIndices(ff)),quadRect, quadPos4, []); % main concentric grids  [rotate] put angle in degrees
                
                % Draw dot
                if ff >= dotOnset
                    Screen('DrawTexture', w, gaus_tex, [0, 0, 61, 61], [dotXStart,dotYStart,dotXEnd,dotYEnd]); %  [0,0,101,101] or sizeMain/2  % attentional dot % [0 0 101 101], position of rect in large w [50 50 151 151] % dimensions of dot
                end
            end
            
            % Draw fixation circle
            Screen('FillOval', w, rectColor, centeredRect, maxDiameter);
            
            % Draw the fixation cross in white, set it to the center of our screen and
            Screen('DrawLines', w, allCoords, lineWidthPix, attn0, [xCenter yCenter], 2);
            
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
            
        end
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


