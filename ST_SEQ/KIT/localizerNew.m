function [exp] = localizerNew( p, tex)

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Fix & Gratings'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center','center',text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

%Screen('Flip',p.scr.window,[],1);               

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% run series
lr.series       = pseudoRandListNoRpt(p);
lr.numSeries    = 1;
lr.numTrial     = 0;
stayOn          = 0;

thisWaitTime    = p.scr.stimDur;   
reloop          = 0;
startTime       = GetSecs;
lr.times.series(1,1) = startTime;
lr.angles       = p.grat.angleSet;

% run localizer
while lr.numTrial < p.series.stimPerSeries || reloop
        
    lr.numTrial                 = lr.numTrial +1;
    lr.timesTrial(lr.numTrial)  = GetSecs-startTime;
    lr.quads                    = lr.series (lr.numTrial);
    lr.angles                   = lr.angles + p.grat.angleIncrement;
    %lr.angles                   = mod(p.grat.angleSet(lr.quads) + p.grat.angleIncrement, 180);  % set grating angle
    
    [ p, lr]                    = draw_grat( p, tex, lr, stayOn);
    
    if p.useEyelink
        
        [outofBounds]   = monitorFixation( p, thisWaitTime);
        
        if outofBounds > p.scr.maxOutofBounds            % save series; re-record
            reLoop = 1;
            break; % or return
        else
            reloop = 0;
        end
    else
        WaitSecs( thisWaitTime - ( 0.5*p.scr.flipInterval));
    end
end

lr.times.series(1,2) = GetSecs;
% save series data to exp structure
nameSeries          = sprintf('LR%d',lr.numSeries);
exp.(nameSeries)    = lr;

% ask about repeating?
lr.numSeries        = lr.numSeries +1;

% end localizer






