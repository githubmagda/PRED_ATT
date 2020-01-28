function tex = makeTextures(p)

% make attention gaussian
[dotX, dotY]            = meshgrid(-p.dot.radius:p.dot.radius,-p.dot.radius:p.dot.radius);    
alph = exp(-( dotX.^2 / (2* (p.dot.radius) .^2) ) - ( dotY.^2 / (2* (p.dot.radius) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
color = 0.5;
gausFix = cat(3, color .* ones( (2 * p.dot.radius)+1, (2 * p.dot.radius)+1, 3), alph);   % default: gaus = ones(101,101,1) creates white box
tex.dot = Screen('MakeTexture', p.scr.window, gausFix);

% make grating texture
[tex.sineTex, ~]          = CreateProceduralSquareWaveGrating(p.scr.window, p.grat.Radius *2, p.grat.Radius *2,...
    p.grat.backgroundColorOffsetGrat, p.grat.Radius, 1);
 
    
% make fixation gaussian
[dotX, dotY]            = meshgrid(-5*p.fix.Radius:5*p.fix.Radius,-5*p.fix.Radius:5*p.fix.Radius);    
alph = exp(-( dotX.^2 / ((2*p.fix.Radius) .^2) ) - ( dotY.^2 / ((2*p.fix.Radius) .^2 )));% .* ( p.scr.intDot); % CHECK was dotX / Z sets dot size
color = p.fix.color;
gausFix = cat(3, color .* ones( 5*(2 * p.fix.Radius)+1, 5*(2 * p.fix.Radius)+1, 3), alph);   % default: gaus = ones(101,101,1) creates white box
tex.fix = Screen('MakeTexture', p.scr.window, gausFix);
