function [p, tex] = makeTextures(p)

% make attention gaussian
[dotX, dotY]    = meshgrid(-p.dot.radius:p.dot.radius,-p.dot.radius:p.dot.radius);    
alph            = exp(-( dotX.^2 / (2* (p.dot.radius) .^2) ) - ( dotY.^2 / (2* (p.dot.radius) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
color           = 0.5; 
gausFix         = cat(3, color .* ones( (2 * p.dot.radius)+1, (2 * p.dot.radius)+1, 3), alph);   % default: gaus = ones(101,101,1) creates white box
tex.dot         = Screen('MakeTexture', p.scr.window, gausFix);

% make grating texture
% [tex.sine, ~] = CreateProceduralSquareWaveGrating(p.scr.window, p.grat.Radius *2, p.grat.Radius *2,...
%     p.grat.backgroundColorOffsetGrat, p.grat.Radius, 1);
 
[tex.sine, tex.sineRect] = CreateProceduralSquareWaveGrating(p.scr.window, p.grat.radius *2, p.grat.radius *2,...
    p.grat.backgroundColorOffsetGrat, p.grat.radius, 1);

% calculate grating rect positions (centered on point p.scr.gratPos from center)
%p.grat.sineTexRect      = [0, 0, 2 * p.grat.radius, 2 * p.grat.radius];
p.grat.left             = p.scr.centerX  -p.grat.posSide*2 -tex.sineRect(3); %/2;
p.grat.right            = p.scr.centerX  +p.grat.posSide*2 -tex.sineRect(3); %/2;
p.grat.top              = p.scr.centerY  -p.grat.posSide*2 -tex.sineRect(4); %/2;
p.grat.bottom           = p.scr.centerY  +p.grat.posSide*2 -tex.sineRect(4); %/2;
p.grat.offsetXSet        = [ p.grat.left, p.grat.right, p.grat.right, p.grat.left];
p.grat.offsetYSet        = [ p.grat.top, p.grat.top, p.grat.bottom, p.grat.bottom];

% make destination rects for gratings
p.grat.dstRects        = OffsetRect( 2 * tex.sineRect, p.grat.offsetXSet', p.grat.offsetYSet')';
p.grat.params         = repmat([p.grat.phase, p.grat.freq, p.grat.contrast, 0], 4, 1)';
    
% make fixation gaussian
[dotX, dotY]    = meshgrid(-5*p.fix.radius:5*p.fix.radius,-5*p.fix.radius:5*p.fix.radius);    
alph            = exp(-( dotX.^2 / ((2*p.fix.radius) .^2) ) - ( dotY.^2 / ((2*p.fix.radius) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
color           = p.fix.color;
gausFix         = cat(3, color .* ones( 5*(2 * p.fix.radius)+1, 5*(2 * p.fix.radius)+1, 3), alph);   % default: gaus = ones(101,101,1) creates white box
tex.fix         = Screen('MakeTexture', p.scr.window, gausFix);
