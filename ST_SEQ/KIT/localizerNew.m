function [exper] = localizerNew( p, tex, exper)

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Fix & Gratings'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center','center',text2show);

text2show = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

repeat          = 1;
lr.numSeries    = 0;

while repeat   % chosen by user

    lr.numSeries            = lr.numSeries +1;
    % run series
    lr.series               = pseudoRandListNoRpt(p);    
    lr.numTrial             = 0;
    inBounds                = 1;
    
    thisWaitTime            = p.scr.stimDur;
    angles                  = mod( p.grat.angleSet +  ( randi(180/p.grat.angleIncrement-1, 1) *p.grat.angleIncrement), 180);
          
    draw_fix( p, tex);
    
    startTime               = GetSecs;
    lr.times.series(1,1)    = startTime;
    
    % run localizer
    while lr.numTrial < p.series.stimPerSeries && inBounds
        
        lr.numTrial                             = lr.numTrial +1;
        lr.grat.quads (lr.numTrial,:)           = lr.series (lr.numTrial);
        angles                                  = mod( angles + ( randi(180/p.grat.angleIncrement-1, 1) *p.grat.angleIncrement), 180);
        lr.grat.angles(lr.numTrial,:)           = angles;
        
        % draw
        draw_fix(p, tex);
        
        [ p, lr, vbl]                   = draw_grat( p, tex, lr, 0); % (p, tex, sr, dot, cue)
        lr.times.trials(lr.numTrial)    = vbl - startTime;
        
        if p.useEyelink
            
            %send message to edf file
            thisMessage = ['LR_series', num2str( lr.numSeries), '_trial', mum2str( lr.numTrial), 'START_TRIAL'];
            Eyelink('message',thisMessage);
            
            [outofBounds]   = monitorFixation( p, thisWaitTime);
            
            if outofBounds > p.scr.maxOutofBounds            % save series; re-record
                lr.outofBounds(lr.numTrial) = 1;
                inBounds = 0;
                break; % or return
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
    exper.(nameSeries)    = lr;
    
    % ask about repeating??
    button = questdlg('Run the localizer again?','Repeat','Yes','No','No');
    
    switch button
        case 'Yes'
            repeat              = 1;
        case 'No'
            repeat              = 0;
            break;
    end
end

% end localizer






