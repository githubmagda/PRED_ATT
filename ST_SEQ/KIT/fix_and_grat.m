function fix_and_grat(p,tex)

% Draw text

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Intro Fix'),p.text.language + 1));

draw_text(p,'center',0.05,text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));

draw_text(p,'center',0.95,text2show);

% Draw fixation point

Screen('DrawTexture', p.scr.window, tex.fix); 
Screen('Flip',p.scr.window,[],1);

% Get response

doKbCheck(p, 2);

Screen('Flip',p.scr.window);

% introduce gratings

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Intro Gratings'),p.text.language + 1));

draw_text(p,'center',0.05,text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));

draw_text(p,'center',0.95,text2show);

Screen('DrawTexture', p.scr.window, tex.fix); 
Screen('Flip',p.scr.window,[],1);

% Get response

doKbCheck(p, 2);

