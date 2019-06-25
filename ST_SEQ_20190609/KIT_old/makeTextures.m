function [p] = makeTextures(p)
% This script makes the textures to be used in stimDisplay.m.
% Textures include the main textures for the four quadrant gratings (inward spiraling) 
% and gratings with flash, the attentional dot and the fixation gaussian.

% GRATING MOVIE 
% p.framePerMovie is temporal period, in frames, of the drifting grating;
% fastest possible is p.scrHz (see SEQ_ParamsScr for basic settings 
% Compute each frame of the movie and convert the  frames, stored in
% MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';

% MOVIE LOOP
% calculate distance x,y from center using Pythag: c=p.scr.gratPosPix : a= sqrt( p.scr.gratPosPix / 2 )
p.scr.gratPixSide = round( sqrt( p.scr.gratPosPix^2 / 2) );

for cc = 1:p.scr.framesPerMovie
    
    phase = ( cc/p.scr.framesPerMovie )*2*pi;
    
    % grating
    m =[]; % reset
    % p.scr.quadDim = min( nonzeros( p.scr.windowRect )) ./2; % determine quadrant size
    [gridX, gridY] = meshgrid( -p.scr.gratPixSide : p.scr.gratPixSide , -p.scr.gratPixSide : p.scr.gratPixSide ); 
    f = 15/length(gridX); % 30/length(gridX); 
    m = cos( f*2*pi* sqrt( gridX.^2 + gridY.^2 ) + phase );
    
    % background mask
    mask = createCirclesMask(gridX, [ p.scr.gratPixSide+1 , p.scr.gratPixSide+1 ], p.scr.gratRadiusPix, 'outer' ); %p.scr.quadGratRadiusDeg, 'outer');
    m(mask) = 0;
    
    % transparent mask for grating area (flash element)
    mFlash = sum(cat(3, .3 .* m, .7 .* ~mask),3);
    
    % 2X2 GRATINGS  
    p.scr.rectGrating = RectOfMatrix(m); % identify m as Rect and center grating on [a,a] 
    % put grating into screen quadrant    
    mQuad = zeros( p.scr.basicSquare./2, p.scr.basicSquare./2 ); 
    p.scr.mQuadDim = size(mQuad,1);
    mQuad( p.scr.mQuadDim+1 - p.scr.rectGrating(3) : p.scr.mQuadDim, p.scr.mQuadDim+1 - p.scr.rectGrating(4) : p.scr.mQuadDim )= m;
     
    % construct 2x2 grating using flip.m
    m2 = [mQuad,flip(mQuad,2)]; %  top elements
    m2x2 = [m2;flip(m2,1)]; % all elements
    
    % construct 2x2 grating with only one grating for LOCALIZER
    mQuadBlank = zeros(p.scr.basicSquare./2, p.scr.basicSquare./2); % CHECK zeros(p.scr.pixelsX./2, p.scr.pixelsY./2);
    m2x2Localizer = [mQuad,mQuadBlank;mQuadBlank,mQuadBlank]; %  one quad element
    
    % adapt for 2x2 grating with flash
    m2x2Flash = m2x2;
    m2x2Flash( size(mQuad)+1 - p.scr.rectGrating(3) : size(mQuad), size(mQuad)+1 - p.scr.rectGrating(4) : size(mQuad) ) = mFlash;
     
    % TEXTURES - adjust m2x2 values for 0:1 (black:white) scale
    texGrat(cc) = Screen( 'MakeTexture', p.scr.window, (m2x2+1)/2 ); % set all numbers to 0:1 range
    texGratFlash(cc) = Screen( 'MakeTexture', p.scr.window, (m2x2Flash+1)/2 );
    texGratLocalizer(cc) = Screen( 'MakeTexture', p.scr.window, (m2x2Localizer+1)/2 );
end

% save 2x2 gratings
p.textures.texGrat = texGrat;
p.textures.texGratFlash = texGratFlash;
p.textures.texGratLocalizer = texGratLocalizer;

%% TEST GRATING
% for cc = 1:p.scr.framesPerMovie
%     if mod(cc,2) == 0
%         Screen( 'DrawTexture',p.scr.window, texGrat(cc) )        
%     else
%         rotation = randi(4,1);
%         Screen( 'DrawTexture',p.scr.window, texGratFlash(cc),[],[],(rotation-1)*90 )
%         %Screen( 'DrawTexture',p.scr.window, texGratLocalizer(cc),[],[],(rotation-1)*90  )
%     end
%     Screen('Flip', p.scr.window);
%     WaitSecs(0.1);
% end
%% end test

% END GRATING TEXTURE

% MAKE FIXATION GAUSSIAN
p.scr.fixGridRadius = 3.* p.scr.fixRadius; % the box is always 3 * 1 standard deviation of the gaussian
szFix = p.scr.fixGridRadius; 
[ fixX, fixY ] = meshgrid( -szFix:szFix, -szFix:szFix );    % CHECK - visual angle?
lenFix = length(-szFix:szFix);

% set opacity and color of fixation circle
int = 1.0; % 0:1 scale ;
color = p.scr.white; 

% fixation gaussian - main fixation dot
alph = exp(-( fixX.^2 / (2*(p.scr.fixRadius).^2 ) ) - ( fixY.^2 / (2* (p.scr.fixRadius).^2 ))) .* int; % CHECK was dotX / Z sets dot size
gaus_fix = cat(3, color .* ones(lenFix,lenFix,3), alph);

% make texture
gaus_fix_tex = Screen( 'MakeTexture', p.scr.window, gaus_fix );

% % TEST
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
Screen('Flip', p.scr.window);
% end test

% save texture
p.textures.gaus_fix_tex = gaus_fix_tex;
% END FIXATION GAUSSIAN

% MAKE ATTENTION-DOT GAUSSIAN 
% make alphaed Gaussian texture
p.scr.dotGridRadiusPix = 3 .* p.scr.dotRadiusPix;  % radius of grid is  3*sd of gaussian
szDot = p.scr.dotGridRadiusPix; % shorthand
[dotX,dotY] = meshgrid(-szDot:szDot, -szDot:szDot);  
lenDot = length(-szDot:szDot);

% set opacity and intensity of attentional dot
p.scr.intDot = 1.0; % 0 to 1; %% CHECK - should be set by staircase
color = 1.0;  %

% create gaussian
alph = exp(-( dotX.^2 / (2* (p.scr.dotRadiusPix) .^2) ) - ( dotY.^2 / (2* (p.scr.dotRadiusPix) .^2 ))) .* p.scr.intDot; % CHECK was dotX / Z sets dot size
gaus = cat(3, color .* ones(lenDot,lenDot,3), alph);   % default: gaus = ones(101,101,1) creates white box

% make TEXTURE
gaus_attn_tex = Screen('MakeTexture', p.scr.window, gaus);
p.textures.gaus_attn_tex = gaus_attn_tex;

% % TEST
% Screen('DrawTexture',p.scr.window, gaus_attn_tex);
% %Screen('DrawTexture',p.scr.window, gaus_attn_tex,[],[],[],[],[],p.scr.fixColorChange)
% Screen('Flip', p.scr.window);
% % end test

% % % % ATTENTION-DOT MASKS
% Calculate masks for dot allocation (sum of three circular masks)
maskDotOuter = createCirclesMask( [ p.scr.basicSquare, p.scr.basicSquare ], [ p.scr.basicSquare./2, p.scr.basicSquare./2 ], p.scr.outerDotMaskRadius, 'inner');
%%% CHECK maskDotOuter = createCirclesMask( [ p.scr.pixelsX, p.scr.pixelsY ], [ p.scr.centerX, p.scr.centerY ], p.scr.outerDotMaskRadius, 'inner');
maskDotInner = createCirclesMask( [ p.scr.basicSquare, p.scr.basicSquare ], [ p.scr.basicSquare./2, p.scr.basicSquare./2 ], p.scr.innerDotMaskRadius, 'outer');
%%% CHECK maskDotInner = createCirclesMask( [ p.scr.pixelsX, p.scr.pixelsY ], [ p.scr.centerX, p.scr.centerY ], p.scr.innerDotMaskRadius, 'outer');
maskAnnulus = (maskDotOuter + maskDotInner) - 1; % sets annulus to 1 all else to zero

% make 3rd  mask for grating (slightly smaller than so dot won't appear on border) 
maskGratRadiusPix = p.scr.gratRadiusPix - p.scr.maskBorder;
%maskDotGrat = zeros(p.scr.gratPixSide, p.scr.gratPixSide);
maskDotGrat = createCirclesMask(gridX, [ p.scr.gratPixSide+1 , p.scr.gratPixSide+1 ], maskGratRadiusPix, 'inner' ); 

% put dot mask into screen     
maskDotScr = zeros(p.scr.basicSquare); 
maskDotScr( p.scr.mQuadDim+1-p.scr.rectGrating(3): p.scr.mQuadDim, p.scr.mQuadDim+1-p.scr.rectGrating(4) : p.scr.mQuadDim )= maskDotGrat;

% make combined mask for quad 1 (left-top) and rotate for other quads 
maskDotQuad_1 = (maskDotScr + maskAnnulus)-1;
maskDotQuad_2 = fliplr(maskDotQuad_1);
maskDotQuad_3 = flipud(maskDotQuad_2);
maskDotQuad_4 = flipud(maskDotQuad_1);

% % % TEST
% texMaskA = Screen('MakeTexture', p.scr.window, maskAnnulus);
% texMaskB = Screen('MakeTexture', p.scr.window, maskDotScr);
% texMaskC = Screen('MakeTexture', p.scr.window, maskDotQuad_4);
% Screen('DrawTexture',p.scr.window, texMaskA);
% Screen('DrawTexture',p.scr.window, texMaskB);
% Screen('DrawTexture',p.scr.window, texMaskC);
% Screen('Flip', p.scr.window);
% % end test
                    
% Calculate possible dot x/y coordinates for each quad
scrSizeDiff = p.scr.pixelsX - p.scr.basicSquare;
adjustScrPosX = scrSizeDiff/2;
[row1, col1] =  find( maskDotQuad_1 == 1 );
[row2, col2] =  find( maskDotQuad_2 == 1 );
[row3, col3] =  find( maskDotQuad_3 == 1 );
[row4, col4] =  find( maskDotQuad_4 == 1 );

p.scr.rowDotSet1 = row1;
p.scr.colDotSet1 =  col1  + adjustScrPosX;

p.scr.rowDotSet2 = row2;
p.scr.colDotSet2 =  col2 + adjustScrPosX;

p.scr.rowDotSet3 = row3;
p.scr.colDotSet3 =  col3  + adjustScrPosX;

p.scr.rowDotSet4 = row4;
p.scr.colDotSet4 =  col4 + adjustScrPosX;

% END ATTENTION 


end

