function[] = draw_circle(p, sr)

% Draws circle (e.g. around grating)
Screen('FrameOval', p.scr.window, [255,0,0], p.grat.rects (sr.cue( sr.numTrial),:)'+[-1.8;-1.8;1.8;1.8], 1.8, []);
 
% flip
[vbl] = Screen('Flip',p.scr.window,[],1);
    
