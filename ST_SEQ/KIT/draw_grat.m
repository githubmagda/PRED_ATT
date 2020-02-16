function[p, sr, vbl] = draw_grat(p, tex, sr) %, dot, cue)

% Draws quadrant gratings, dot, fixation

% gratings
Screen('DrawTextures', p.scr.window, tex.sine, [], p.grat.rects( sr.quads,:)', sr.angles( sr.quads), [], 0, ...
    [0,0,0,1], [], [], p.grat.params( :, sr.quads));

% % dot
% if dot
% 
%     randSelect = randi([ 1, size(sr.dot.set)], 1, 1);    
%     dotPos = sr.dot.set(randSelect,:, cue);
%     
%     p.dot.rects    = CenterRectOnPointd(tex.sineRect, dotPos(1), dotPos(2));
%     
%     Screen('DrawTexture', p.scr.window, tex.dot, tex.dotRect, p.dot.rect)
%     
% end
% 
% % fixation
% Screen('DrawTexture', p.scr.window, tex.fix); 
% 
% % cue
% if cue
%     crossPos = sprintf( 'p.scr.fixCoords%d', cue);
%     crossColor = sprintf( 'p.scr.attn%d', cue);
%     Screen('DrawLines', p.scr.window, crossPos, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
%     
% end

% flip
[vbl] = Screen('Flip',p.scr.window,[],0);

