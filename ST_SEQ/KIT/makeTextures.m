function [p] = makeTextures(p)

% This script makes the textures to be used in stimDisplay.m.
% Textures include the main textures for the four quadrant gratings (inward spiraling in makeTexturesMov.m)
% and gratings for the flash,  attentional dot guassian and  fixation gaussian.

% %% for cc = 1:p.scr.framesPerMovie
% %% phase = ( cc/p.scr.framesPerMovie )*2*pi;

% grating
m =[]; % reset

p.scr.quadDim = min( nonzeros( p.scr.windowRect )) ./2; % determine quadrant size
[gridX, gridY] = meshgrid( -p.scr.gratRadius : p.scr.gratRadius , -p.scr.gratRadius : p.scr.gratRadius );
%[gridX, gridY] = meshgrid( -p.scr.gratPosSide : p.scr.gratPosSide , -p.scr.gratPosSide : p.scr.gratPosSide );

% GRATING
f = 15/length(gridX); % 30/length(gridX);
phase = 180;

% CIRCULAR GRATING
% m = cos( f*2*pi* sqrt( gridX.^2 + gridY.^2 ) + phase );

% LINEAR GRATING
m = cos( f*2*pi* gridX + phase);    % m = 1+ cos(f*2*pi* gridX); m = 1 +square( 2 *pi *f *gridX)???

%  background mask
mask = createCirclesMask(gridX, [size(m)/2 , size(m)/2] , p.scr.gratRadius, 'outer' ); %p.scr.quadGratRadiusDeg, 'outer');
%mask = createCirclesMask(gridX, [ p.scr.gratRadius , p.scr.gratRadius ], p.scr.gratRadius, 'outer' ); %p.scr.quadGratRadiusDeg, 'outer');
%mask = createCirclesMask(gridX, [ p.scr.gratPosSide , p.scr.gratPosSide ], p.scr.gratRadius, 'outer' ); %p.scr.quadGratRadiusDeg, 'outer');

m(mask) = 0;
%
% transparent mask for grating area (flash element)
mFlash = sum(cat(3, .3 .* m, .7 .* ~mask),3);

% 2X2 GRATINGS
rectGrating = RectOfMatrix(m); %
% put grating into screen quadrant
mQuad = zeros( p.scr.quadDim, p.scr.quadDim ); %p.scr.quadDim
rectGratingPos = floor( CenterRectOnPointd(rectGrating, p.scr.gratPosCenterX(1), p.scr.gratPosCenterY(1))) ; % identify m as Rect and center grating on [a,a]
mQuad( rectGratingPos(1)+1:rectGratingPos(3), rectGratingPos(2)+1:rectGratingPos(4) ) = m;

% construct 2x2 grating using flip.m
m2 = [mQuad, flip(mQuad,2)]; %  top elements
m2x2 = [m2; flip(m2,1)]; % all elements

% construct 2x2 grating with only 1 out of 4 gratings for LOCALIZER
mQuadBlank = zeros( p.scr.quadDim, p.scr.quadDim ); 
m2x2Localizer = [ mQuad, mQuadBlank ; mQuadBlank, mQuadBlank]; %  one quad element

% adapt for 2x2 grating with flash
m2x2Flash = m2x2;
rectGratingPos =  floor( CenterRectOnPointd( rectGrating, p.scr.gratPosCenterX(1), p.scr.gratPosCenterY(1))) ; % identify m as Rect and center grating on [a,a]
m2x2Flash( rectGratingPos(1)+1:rectGratingPos(3), rectGratingPos(2)+1:rectGratingPos(4) ) = mFlash;

% MAKE TEXTURES - adjust m2x2 values for 0:1 (black:white) scale  
texGrat             = Screen( 'MakeTexture', p.scr.window, (m2x2+1)/2 ); % set all numbers to 0:1 range
texGratFlash        = Screen( 'MakeTexture', p.scr.window, (m2x2Flash+1)/2 );
texGratLocalizer    = Screen( 'MakeTexture', p.scr.window, (m2x2Localizer+1)/2 );
%%end

% SAVE TEXTURES 2x2 gratings
p.textures.texGrat          = texGrat;
p.textures.texGratFlash     = texGratFlash;
p.textures.texGratLocalizer = texGratLocalizer;

% TEST GRATING
rotation = randi(4,1);
for cc = 1:1 % movie : p.scr.framesPerMovie
    if mod(cc,2) == 0
        %         Screen( 'DrawTexture',p.scr.window, texGrat(cc) )
        Screen( 'DrawTexture',p.scr.window, texGrat,[],[],(rotation-1)*90 )
    else
        rotation = randi(4,1);
        Screen( 'DrawTexture',p.scr.window, texGratFlash,[],[],(rotation-1)*90 )
        %Screen( 'DrawTexture',p.scr.window, texGratLocalizer(cc),[],[],(rotation-1)*90  )
    end
    Screen('Flip', p.scr.window);
    WaitSecs(0.1);
end
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

% % % TEST
Screen('DrawTexture',p.scr.window, gaus_fix_tex,[],[],[],[],[],p.scr.white)
Screen('Flip', p.scr.window);
% end test

% save texture
p.textures.gaus_fix_tex = gaus_fix_tex;
% END FIXATION GAUSSIAN

% MAKE ATTENTION-DOT GAUSSIAN
% make alphaed Gaussian texture
p.scr.dotGridRadiusPix = 3 .* p.scr.dotRadius;  % radius of grid is  3*sd of gaussian
szDot = p.scr.dotGridRadiusPix; % shorthand
[dotX,dotY] = meshgrid(-szDot:szDot, -szDot:szDot);
lenDot = length(-szDot:szDot);

% set opacity and intensity of attentional dot
p.scr.intDot = .05; % TO BE SET BY STAIRCASE
color = 1.0;  % 1 equals white; p.scr.fixCrossColorChange (set in SEQ_ParamsScr = [1 0 0] = red;

% create gaussian
alph = exp(-( dotX.^2 / (2* (p.scr.dotRadius) .^2) ) - ( dotY.^2 / (2* (p.scr.dotRadius) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
gaus = cat(3, color .* ones(lenDot,lenDot,3), alph);   % default: gaus = ones(101,101,1) creates white box

% make TEXTURE
gaus_attn_tex = Screen('MakeTexture', p.scr.window, gaus);
p.textures.gaus_attn_tex = gaus_attn_tex;

% TEST
Screen('DrawTexture',p.scr.window, gaus_attn_tex);
%color version
%Screen('DrawTexture',p.scr.window, gaus_attn_tex,[],[],[],[],[],p.scr.fixCrossColorChange)
Screen('Flip', p.scr.window);
% end test


% % % % ATTENTION-DOT MASKS
% Calculate masks for dot allocation (sum of three circular masks)
maskDotOuter = createCirclesMask( [ p.scr.basicSquare, p.scr.basicSquare ], [ p.scr.basicSquare./2, p.scr.basicSquare./2 ], p.scr.outerDotMaskRadius, 'inner');
%%% CHECK maskDotOuter = createCirclesMask( [ p.scr.pixelsX, p.scr.pixelsY ], [ p.scr.centerX, p.scr.centerY ], p.scr.outerDotMaskRadius, 'inner');
maskDotInner = createCirclesMask( [ p.scr.basicSquare, p.scr.basicSquare ], [ p.scr.basicSquare./2, p.scr.basicSquare./2 ], p.scr.innerDotMaskRadius, 'outer');
%%% CHECK maskDotInner = createCirclesMask( [ p.scr.pixelsX, p.scr.pixelsY ], [ p.scr.centerX, p.scr.centerY ], p.scr.innerDotMaskRadius, 'outer');
maskAnnulus = (maskDotOuter + maskDotInner) - 1; % sets annulus to 1 all else to zero

% make 3rd  mask for grating (slightly smaller than so dot won't appear on border)
maskgratRadius = p.scr.gratRadius - p.scr.maskBorder;
%maskDotGrat = zeros(p.scr.gratPixSide, p.scr.gratSide);
maskDotGrat = createCirclesMask(gridX, [ p.scr.gratRadius+1 , p.scr.gratRadius+1 ], maskgratRadius, 'inner' );

% put dot mask into screen
maskDotScr = zeros(p.scr.basicSquare);
%maskDotScr( p.scr.quadDim+1-rectGrating(3): p.scr.quadDim, p.scr.quadDim+1-rectGrating(4) : p.scr.quadDim )= maskDotGrat;
maskDotScr( ( p.scr.gratPosCenterX(1) -p.scr.gratRadius) : ( p.scr.gratPosCenterX(1) +p.scr.gratRadius), ( p.scr.gratPosCenterY(1) -p.scr.gratRadius): (p.scr.gratPosCenterY(1) +p.scr.gratRadius))= maskDotGrat;

% make combined mask for quad 1 (left-top) and rotate for other quads
maskDotQuad_1 = (maskDotScr + maskAnnulus)-1;
maskDotQuad_2 = fliplr(maskDotQuad_1);
maskDotQuad_3 = flipud(maskDotQuad_2);
maskDotQuad_4 = flipud(maskDotQuad_1);

% % TEST
texMaskA = Screen('MakeTexture', p.scr.window, maskAnnulus);
texMaskB = Screen('MakeTexture', p.scr.window, maskDotScr);
texMaskC = Screen('MakeTexture', p.scr.window, maskDotQuad_2);
Screen('DrawTexture',p.scr.window, texMaskA);
Screen('DrawTexture',p.scr.window, texMaskB);
Screen('DrawTexture',p.scr.window, texMaskC);
Screen('Flip', p.scr.window);
% end test

% Calculate possible dot x/y coordinates for each quad
scrSizeDiff = p.monitor.pixelX - p.scr.basicSquare;
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

