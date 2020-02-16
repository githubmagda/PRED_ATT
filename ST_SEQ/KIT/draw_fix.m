function[vbl] = draw_fix(p, tex)

% Draws fixation

Screen('DrawTexture', p.scr.window, tex.fix); 

% flip - leave on screen
[vbl] = Screen('Flip',p.scr.window,[],1);
    
end