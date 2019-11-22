
function[p] = makeTextures(p)

% GAUSSIAN DOT
dotGridRadius           = 3.0 * p.dot.radius;
[ dotX, dotY ]          = meshgrid( -dotGridRadius:dotGridRadius, -dotGridRadius:dotGridRadius );    % CHECK - visual angle?
p.scr.lenDot            = size(dotX,1);

% create gaussian
alph = exp(-( dotX.^2 / (2* (p.dot.radius) .^2) ) - ( dotY.^2 / (2* (p.dot.radius) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
color = 1;
gausFix = cat(3, color .* ones(p.scr.lenDot,p.scr.lenDot,3), alph);   % default: gaus = ones(101,101,1) creates white box

% make DOT TEXTURE & calculate onset times
[dotTex] = Screen('MakeTexture', p.scr.window, gausFix);
% save
p.scr.dotTex = dotTex;
% END GAUSSIAN DOT

% SQUARE WAVE GRATING
p.scr.backgroundColorOffsetGrat   = [0,0,0,1];
p.scr.phaseGrat                   = 0;
p.scr.freqGrat                    = 3.2 / p.scr.pixPerDeg;      % Landau & Fries, 2015 3.2    % see paper by Ayelet, Fries 2015 : 3.2 20; Martin Vinck - .11?
p.scr.contrastGrat                = 1.0;

% basic grating size
virtualSizeGrat             = p.scr.gratRadius *2;

% MAKE TEXTURES
[sineTex, sineTexRect]  = CreateProceduralSquareWaveGrating(p.scr.window, virtualSizeGrat, virtualSizeGrat,...
    p.scr.backgroundColorOffsetGrat, p.scr.gratRadius, 1);
% save
p.scr.sineTex          = sineTex;
p.scr.sineTexRect      = sineTexRect;

% DEFINE GRATING LOCATIONS
% CALCULATE GRATING QUAD POSITIONS (centered on point p.scr.gratPos from center)
p.scr.leftGrat          = p.scr.centerX -sineTexRect(3)/2 -p.scr.gratPosSide ;
p.scr.rightGrat         = p.scr.centerX -sineTexRect(3)/2 +p.scr.gratPosSide ;
p.scr.topGrat           = p.scr.centerY -sineTexRect(4)/2 -p.scr.gratPosSide ;
p.scr.bottomGrat        = p.scr.centerY -sineTexRect(4)/2 +p.scr.gratPosSide ;
p.scr.offsetXSet        = [ p.scr.leftGrat, p.scr.rightGrat, p.scr.rightGrat, p.scr.leftGrat];
p.scr.offsetYSet        = [ p.scr.topGrat, p.scr.topGrat, p.scr.bottomGrat, p.scr.bottomGrat];

% setup destination rects for gratings
% make destination rects for gratings
p.scr.dstRectGrats        = OffsetRect( sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet')';
p.scr.paramsGrats         = repmat([p.scr.phaseGrat, p.scr.freqGrat, p.scr.contrastGrat, 0], 4, 1)';
