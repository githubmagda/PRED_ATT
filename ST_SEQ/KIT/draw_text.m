function draw_text(p,x,y,text2show)

% draws text on screen x and y measured in percentage of screen from
% top-left, or as special string

if ~ischar(x) % e.g. not 'center'
    x = round(x * p.scr.rectPixelX);
end

if ~ischar(y)
    y = round(y * p.scr.rectPixelY);
end
    
Screen('TextSize',p.scr.window, p.text.textSize);
Screen('TextFont', p.scr.window ,p.text.font,p.text.style);
DrawFormattedText( p.scr.window, text2show , x, y, p.text.textColor, p.text.wrap, [], [], 1.5);
Screen('Flip',p.scr.window,[],1);

