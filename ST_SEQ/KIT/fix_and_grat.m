function intro_fix_and_grat(p,tex)

% Draw text

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Intro Fix'),p.text.language + 1)); % + 1 for correct column in texts.xlsx

draw_text(p,'center',0.15,text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));

draw_text(p,'center',0.95,text2show);

% Draw fixation point

Screen('DrawTexture', p.scr.window, tex.fix); 
Screen('Flip',p.scr.window,[],1);               % set to '1' for don't clear, but why?

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% introduce gratings

text2show       = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Intro Gratings'),p.text.language + 1));
draw_text(p,'center',0.10,text2show);

text2show       = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% setup for draw_grat
sr.quads        = [ 1:4];
sr.angles       = p.grat.angleSet ;

draw_grat( p, tex, sr); %, 0, 0);

% Get response

doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);
