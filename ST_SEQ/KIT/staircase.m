function [exp] = localizerNew( p, tex, exp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Staircase'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center','center',text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% run series
lr.series       = pseudoRandListNoRpt(p);
lr.numSeries    = 1;
lr.numTrial     = 0;
stayOn          = 0;            % Flip and 1 = stay on screen

thisWaitTime    = p.scr.stimDur;
reloop          = 0;            % in case eyes go out of bounds during series
startTime               = GetSecs;
lr.times.series(1,1)    = startTime;
angles                  = p.grat.angleSet;

repeat = 1;

while repeat
    
    % run localizer
    while lr.numTrial < p.series.stimPerSeries || reloop
        
        lr.numTrial          = lr.numTrial +1;
        lr.quads             = lr.series (lr.numTrial);
        angles               = mod( angles + p.grat.angleIncrement, 180);
        lr.angles            = angles;
        
        [ p, lr]                        = draw_grat( p, tex, lr, stayOn);
        lr.times.trials(lr.numTrial)    = GetSecs-startTime;
        
        if p.useEyelink
            
            %send message to edf file
            thisMessage = ['LR_series', num2str( lr.numSeries), '_trial', mum2str( lr.numTrial), 'START_TRIAL'];
            Eyelink('message',thisMessage);
            
            [outofBounds]   = monitorFixation( p, thisWaitTime);
            
            if outofBounds > p.scr.maxOutofBounds            % save series; re-record
                reloop = 1;
                break; % or return
            else
                reloop = 0;
            end
        else
            WaitSecs( thisWaitTime - ( 0.5*p.scr.flipInterval));
        end
    end
    
    lr.times.series(1,2) = GetSecs;
    
    % flip
    Screen('Flip',p.scr.window,[],0);       % clear screen
    
    % save series data to exp structure
    nameSeries          = sprintf('lr%d',lr.numSeries);
    exp.(nameSeries)    = lr;
    
    % ask about repeating??
    button = questdlg('Run the localizer again?','Repeat','Yes','No','No');
    
    switch button
        case 'Yes'
            repeat              = 1;
            lr.numSeries        = lr.numSeries +1;
        case 'No'
            repeat              = 0;
            break;
    end
end

% end staircase
end

