function[vbl] = draw_fix(p, tex)

% Draw fixation gaussian
Screen('DrawTexture', p.scr.window, tex.fix); 

% flip - leave on screen
[vbl] = Screen('Flip',p.scr.window,[],1);
    
end