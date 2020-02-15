stfunction [exp] = staircase( p, tex, exp)
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Staircase'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center','center',text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% dot  - calculated in screen refresh times
sr.dot.series   = makeDotSeries(  p, p.dot.probStaircase);
temp            = Shuffle( 0 : p.scr.flipInterval : (p.scr.stimDur-p.scr.flipInterval));
sr.dot.onset     = temp( 1: p.series.stimPerSeries);
sr.dot.offset    = sr.dot.onset + p.dot.dur;

% run series
sr.pred.series       = pseudoRandListNoRpt(p);
sr.numSeries    = 1;
sr.numTrial     = 0;
stayOn          = 1;            % Flip and 1 = stay on screen

thisWaitTime    = p.scr.stimDur;
reloop          = 0;            % in case eyes go out of bounds during series
startTime               = GetSecs;
sr.times.series(1,1)    = startTime;
angles                  = p.grat.angleSet;

repeat = 1;

while repeat
    
    % run localizer
    while sr.numTrial < p.series.stimPerSeries || reloop
        
        sr.numTrial          = sr.numTrial +1;
        sr.quads             = sr.series (sr.numTrial);
        angles               = mod( angles + p.grat.angleIncrement, 180);
        sr.angles            = angles;
        
        [ p, sr]                        = draw_grat( p, tex, sr, stayOn);
        sr.times.trials(sr.numTrial)    = GetSecs-startTime;
        
        if p.useEyelink
            
            %send message to edf file
            thisMessage = ['LR_series', num2str( sr.numSeries), '_trial', mum2str( sr.numTrial), 'START_TRIAL'];
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
    
    sr.times.series(1,2) = GetSecs;
    
    % flip
    Screen('Flip',p.scr.window,[],0);       % clear screen
    
    % save series data to exp structure
    nameSeries          = sprintf('lr%d',sr.numSeries);
    exp.(nameSeries)    = sr;
    
    % ask about repeating??
    button = questdlg('Run the localizer again?','Repeat','Yes','No','No');
    
    switch button
        case 'Yes'
            repeat              = 1;
            sr.numSeries        = sr.numSeries +1;
        case 'No'
            repeat              = 0;
            break;
    end
end

% end staircase

