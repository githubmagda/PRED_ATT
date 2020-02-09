function localizerNew( p, tex)

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Localizer'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center','center',text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

Screen('Flip',p.scr.window,[],1);               

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% run series
lr.series       = pseudoRandListNoRpt(p);
lr.numSeries    = 1;
lr.numTrial     = 1;
lr.numGrat      = 1;
thisOutofBound  = 0;        

% run localizer
while lr.numTrial < p.series.stimPerSeries 
    lr.numTrial     = lr.numTrial +1;
    lr.quad         = lr.series (lr.numTrial);
    lr.angleSet = mod(p.grat.angleSet(lr.numTrial) + p.grat.angleIncrement, 180);  % set grating angle
    
    [ p, thisOutofBounds] = draw_grat( p, tex, lr); 
    
    if thisOutofBound > p.scr.maxOutofBound
       nameSeries = sprintf('LR%d',lr.numSeries);                   % save series; repeat
       exp.(nameSeries) = sr;
       lr.numSeries = lr.numSeries +1;
    end 
end
% end localizer






