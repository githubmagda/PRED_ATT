function [exp] = staircase( p, tex, exper)
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here

text2show       = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Staircase'),p.text.language + 1)); % + 1 for correct column in texts.xlsx
draw_text(p,'center','center',text2show);

text2show       = cell2mat(p.text.texts(strcmp(p.text.texts(:,1),'Next/Previous'),p.text.language + 1));
draw_text(p,'center',0.95,text2show);

Screen('Flip',p.scr.window, 0);

% Get response
doKbCheck(p, 2);
Screen('Flip',p.scr.window, 0);

% setup
sr.numSeries    = 0;
repeat          = 1; % chosen at end of loop by participant
sr.dot =[];

while repeat
    
    % dot setup
    sr.dot.series                        = makeDotSeries(  p, p.dot.probStaircase);
    sr.dot.onset                         = zeros( 1,length(sr.dot.series));
    sr.dot.offset                        = zeros( 1,length(sr.dot.series));
    temp                                 = repmat( Shuffle( p.scr.flipInterval : p.scr.flipInterval : (p.scr.stimDur-p.scr.flipInterval)), 1, 10);
    sr.dot.onset( sr.dot.series == 1)    = temp( sr.dot.series == 1);
    sr.dot.offset( sr.dot.series == 1)   = sr.dot.onset( sr.dot.series == 1) + p.dot.dur;
    
    % check for dots that carry over to next stimulus
    ind = find(sr.dot.offset >= p.scr.stimDur +p.scr.flipInterval);
    sr.dot.onset(ind + 1) = p.scr.flipInterval; % dot on immediately for next stimulus
    sr.dot.offset(ind + 1) = sr.dot.offset(ind) - p.scr.stimDur; % offset remainder of dot duration
    
    % prediction setup (angle change)
    [result, trackElements, trackChunks] = makePredSeries(p);
    sr.pred.series              = result;
    sr.pred.seriesTrackElements = trackElements;
    sr.pred.seriesTrackChunks   = trackChunks;
    
    % setup
    sr.numSeries                = sr.numSeries +1;
    sr.numTrial                 = 0;
    angles                      = mod( p.grat.angleSet +  ( randi(180/p.grat.angleIncrement-1, 1) *p.grat.angleIncrement), 180);
    inBounds                    = 1;                % in case eyes go out of bounds during series
    thisWaitTime                = p.scr.stimDur;
    sr.cue( 1:p.series.stimPerSeries) = randi( 4,1);
    sr.grat.quads               = 1:4;
    
    [vbl] = draw_fix( p, tex);  % only draw once
        
    startTime                   = GetSecs;
    sr.times.series(1,1)        = startTime;
    
    % run loop
    while sr.numTrial < p.series.stimPerSeries
        
        sr.numTrial                             = sr.numTrial +1;       
        dot                                     = sr.dot.series( sr.numTrial);
        angles (  sr.pred.series( sr.numTrial)) = angles( sr.pred.series( sr.numTrial)) + p.grat.angleIncrement;
        sr.grat.angles(sr.numTrial,:)           = mod( angles, 180);

        %if sr.numTrial == 1 % draw all 4 quads
            
            % setup for first screen draw_grat

            %sr.grat.angles(sr.numTrial, :)       = mod(p.grat.angleSet +( randi(180/p.grat.angleIncrement,1)*p.grat.angleIncrement), 180);
            
            % draw
            
            [vbl] = draw_grat( p, tex, sr, 1);
            sr.times.trials(sr.numTrial)            = vbl;
            
            if sr.numTrial > 1 && sr.numTrial <= 5
            draw_circle( p, sr);
            end
            
       % else
            
            % reset predictive quad angle
            %sr.grat.quads(sr.numTrial, :)       = sr.pred.series( sr.numTrial);
      %  end
        
%         if sr.numTrial > 1 && sr.numTrial <= 5
%             % draw
%             %draw_fix( p, tex)
%             draw_grat( p, tex, sr, 1);
%             draw_circle( p, sr);
%         end
        
        if dot
            thisWaitTime = sr.dot.onset(sr.numTrial);
        end
        
%         [ p, sr, vbl]                           = draw_grat( p, tex, sr, 1);
%         %[ p, sr]                                = draw_dot( p, tex, sr);
%         sr.times.trials(sr.numTrial)            = vbl;
%         
        if p.useEyelink
            
            %send message to edf file
            thisMessage = ['SR_series', num2str( sr.numSeries), '_trial', mum2str( sr.numTrial), '_START_TRIAL'];
            Eyelink('message',thisMessage);
            
            [outofBounds]   = monitorFixation( p, thisWaitTime);
            
            if outofBounds > p.scr.maxOutofBounds            % save series; re-record
                inBounds = 0;
                break; % or return
                %             else
                %                 outofBounds = 0;
            end
        else
            WaitSecs( thisWaitTime - ( 0.9*p.scr.flipInterval));
        end
    end
end

sr.times.series(1,2) = GetSecs;

% flip
Screen('Flip',p.scr.window,[],0);       % clear screen

% save series data to exp structure
nameSeries          = sprintf('sr%d',sr.numSeries);
exp.(nameSeries)    = sr;

% ask about repeating??
button = questdlg('Run the localizer again?','Repeat','Yes','No','No');

switch button
    case 'Yes'
        repeat              = 1;
        sr.numSeries        = sr.numSeries +1;
    case 'No'
        repeat              = 0;
        return
end
% end staircase

