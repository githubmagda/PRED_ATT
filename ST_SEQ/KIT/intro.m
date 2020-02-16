function intro(p)

% Draw text

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Welcome'),p.text.language + 1));
draw_text(p,'center','center',text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% Get response

doKbCheck(p, 2);

Screen('Flip',p.scr.window, 0);




