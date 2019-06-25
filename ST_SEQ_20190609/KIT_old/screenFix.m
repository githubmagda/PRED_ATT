function[] = screenFixMA(Params)

%% This function creates a fixation cross using the 'DrawLines' function to make 2 crossed lines
%% input details: line size, colors, orientation

    % set the size of the arms of our fixation cross
    fixCrossDimPix = Params.scr.fixCrossDimPix;  % e.g. = 15
    % set the line width for our fixation cross
    fixCrossLineWidthPix = Params.scr.fixCrossLineWidthPix;  % e.g. = 4
    
    % set up cross coordinates - could specify diagonal vs. default cross
    if Params.scr.fixCrossDiagonal   
        xCoords = [fixCrossDimPix -fixCrossDimPix -fixCrossDimPix fixCrossDimPix];
        yCoords = [fixCrossDimPix -fixCrossDimPix fixCrossDimPix -fixCrossDimPix];
    else 
        xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
        yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    end
    % x/y coordinates in matrix
    allCoords = [xCoords; yCoords];
    
    % color codes
    highlight = 0; %% CMYK system: red = yellow + magenta    
    c = Params.scr.fixCrossColor;
      
    % rgb specs for fixation coordinates clockwise from top-left
    quadAll = [c c c c; c c c c; c c c c; 1 1 1 1;]; % all legs are color c
    
    quad1 = [c, c, c, c; c, highlight, c, c ; c, 0, c, c; 0, 1, 0, 0]; % upper-left
    quad2 = [c, c, c, c; c, c, c, highlight ; c, c, c, 0; 0, 0, 0, 1]; % upper-right
    quad3 = [c, c, c, c; highlight, c, c, c; c, c, c, c; 1, 0, 0, 0]; % lower-right
    quad4 = [c, c, c, c; c, c, highlight, c; c, c, c, c; 0, 0, 1, 0]; % lower-left
    
    % choice of fix cross colors - leg of attentional cue
    attQuad = quad1; %%CHECK - SEND IN FROM runSeriesMA
    
    Screen('DrawLines', Params.scr.window, allCoords, fixCrossLineWidthPix, quadAll, [Params.scr.centerX,Params.scr.centerY], 2);    
    
    if nargin > 1 % optional variable specifies which leg of cross is colored
        Screen('DrawLines', Params.scr.window, allCoords, fixCrossLineWidthPix, attQuad, [Params.scr.centerX,Params.scr.centerY], 2);    
    end
end