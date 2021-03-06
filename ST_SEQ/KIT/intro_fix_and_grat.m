function fix_and_grat(p,tex)

% Draw text

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Intro Fix'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center',0.15,text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% Draw fixation point
draw_fix(p, tex);
% Screen('DrawTexture', p.scr.window, tex.fix); 
% Screen('Flip',p.scr.window,[],1);               % set to '1' for don't clear, but why?

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% introduce gratings

text2show                       = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Intro Gratings'),p.text.language + 1));
draw_text(p,'center',0.10,text2show);

text2show                       = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% setup for draw_grat
sr.numTrial                          = 1;   % only one
sr.grat.quads(sr.numTrial, :)        = 1:4;
sr.grat.angles(sr.numTrial, :)       = p.grat.angleSet;

draw_fix( p, tex);
draw_grat( p, tex, sr, 1); 

% Get response

doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);
