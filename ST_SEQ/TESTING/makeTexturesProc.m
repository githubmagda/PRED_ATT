function [p] = makeTexturesProc(p)

% This script makes the textures to be used in stimDisplay.m.
% Textures include the main textures for the four quadrant gratings a
% and gaussians for attentional dot guassian and  fixation gaussian.

% PROCEDURAL GRATING
if procedural %faster drawing of gratings/gaussians
    
    
end

% 2X2 GRATINGS
p.scr.rectGrating = RectOfMatrix(m); % identify m as Rect and center grating on [a,a]
% put grating into screen quadrant
mQuad = zeros( p.scr.basicSquare./2, p.scr.basicSquare./2 );
p.scr.mQuadDim = size(mQuad,1);
mQuad( p.scr.mQuadDim+1 - p.scr.rectGrating(3) : p.scr.mQuadDim, p.scr.mQuadDim+1 - p.scr.rectGrating(4) : p.scr.mQuadDim )= m;

% construct 2x2 grating using flip.m
m2 = [mQuad, flip(mQuad,2)]; %  top elements
m2x2 = [m2; flip(m2,1)]; % all elements

% construct 2x2 grating with only 1 out of 4 gratings for LOCALIZER
mQuadBlank = zeros( p.scr.basicSquare./2, p.scr.basicSquare./2); % CHECK zeros(p.scr.pixelsX./2, p.scr.pixelsY./2);
m2x2Localizer = [ mQuad, mQuadBlank ; mQuadBlank, mQuadBlank]; %  one quad element

% adapt for 2x2 grating with flash
m2x2Flash = m2x2;
m2x2Flash( size(mQuad)+1 - p.scr.rectGrating(3) : size(mQuad), size(mQuad)+1 - p.scr.rectGrating(4) : size(mQuad) ) = mFlash;

% MAKE TEXTURES - adjust m2x2 values for 0:1 (black:white) scale  
texGrat(1) = Screen( 'MakeTexture', p.scr.window, (m2x2+1)/2 ); % set all numbers to 0:1 range
texGratFlash(1) = Screen( 'MakeTexture', p.scr.window, (m2x2Flash+1)/2 );
texGratLocalizer(1) = Screen( 'MakeTexture', p.scr.window, (m2x2Localizer+1)/2 );
%%end

% SAVE TEXTURES 2x2 gratings
p.textures.texGrat = texGrat;
p.textures.texGratFlash = texGratFlash;
p.textures.texGratLocalizer = texGratLocalizer;

%% TEST GRATING
rotation = 1;
% for cc = 1:1 % movie : p.scr.framesPerMovie
%     if mod(cc,2) == 0
%         Screen( 'DrawTexture',p.scr.window, texGrat(cc) )
          Screen( 'DrawTexture',p.scr.window, texGrat(1),[],[],(rotation-1)*90 )
%Screen('DrawTexture', window, gratingTex, [], dstRect, thisAngle, [], [], ...
%        [], [], [], [phase+180, freq, contrast, 0]);
%     else
%         rotation = randi(4,1);
%         Screen( 'DrawTexture',p.scr.window, texGratFlash(cc),[],[],(rotation-1)*90 )
%         %Screen( 'DrawTexture',p.scr.window, texGratLocalizer(cc),[],[],(rotation-1)*90  )
%     end
     Screen('Flip', p.scr.window);
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
p.scr.intDot = .05; % TO BE SET BY STAIRCASE
color = 1.0;  % 1 equals white; p.scr.fixColorChange (set in SEQ_ParamsScr = [1 0 0] = red;

for i = 1:20
% create gaussian
alph = exp(-( dotX.^2 / (2* (p.scr.dotRadiusPix) .^2) ) - ( dotY.^2 / (2* (p.scr.dotRadiusPix) .^2 ))) .* ( p.scr.intDot*i); % CHECK was dotX / Z sets dot size
gaus = cat(3, color .* ones(lenDot,lenDot,3), alph);   % default: gaus = ones(101,101,1) creates white box

% make TEXTURE
gaus_attn_tex(i) = Screen('MakeTexture', p.scr.window, gaus);
p.textures.gaus_attn_tex = gaus_attn_tex;

% TEST
%Screen('DrawTexture',p.scr.window, gaus_attn_tex(i));
%%color version
%Screen('DrawTexture',p.scr.window, gaus_attn_tex,[],[],[],[],[],p.scr.fixColorChange)
%Screen('Flip', p.scr.window);
% end test
end

% % % % ATTENTION-DOT MASKS
% Calculate masks for dot allocation (sum of three circular masks)
maskDotOuter = createCirclesMask( [ p.scr.basicSquare, p.scr.basicSquare ], [ p.scr.basicSquare./2, p.scr.basicSquare./2 ], p.scr.outerDotMaskRadius, 'inner');
%%% CHECK maskDotOuter = createCirclesMask( [ p.scr.pixelsX, p.scr.pixelsY ], [ p.scr.centerX, p.scr.centerY ], p.scr.outerDotMaskRadius, 'inner');
maskDotInner = createCirclesMask( [ p.scr.basicSquare, p.scr.basicSquare ], [ p.scr.basicSquare./2, p.scr.basicSquare./2 ], p.scr.innerDotMaskRadius, 'outer');
%%% CHECK maskDotInner = createCirclesMask( [ p.scr.pixelsX, p.scr.pixelsY ], [ p.scr.centerX, p.scr.centerY ], p.scr.innerDotMaskRadius, 'outer');
maskAnnulus = (maskDotOuter + maskDotInner) - 1; % sets annulus to 1 all else to zero

% make 3rd  mask for grating (slightly smaller than so dot won't appear on border)
maskGratRadius = p.scr.GratRadius - p.scr.maskBorder;
%maskDotGrat = zeros(p.scr.gratPixSide, p.scr.gratPixSide);
maskDotGrat = createCirclesMask(gridX, [ p.scr.gratPixSide+1 , p.scr.gratPixSide+1 ], maskGratRadius, 'inner' );

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
scrSizeDiff = p.scr.pixelX - p.scr.basicSquare;
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

