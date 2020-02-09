function [thisOutofBounds, totalFixTime, totalOutofBounds] = monitorFixation(p, thisWaitTime)

% Checks for fixation within specified area set by p.fixMonitorX +/- p.fixMonitorRadius
% If gaze strays outside of area, beep or visual warning is given

thisFixTime = 0;
totalFixTime = 0; %
thisOutofBounds = 0;
totalOutofBounds = 0;
timePassed = 0;

startTime = GetSecs;

while timePassed < thisWaitTime
    % checks for a new sample
    
    %[samples, events, drained] = Eyelink('GetQueuedData', p.MonitorEye)
    New = Eyelink('newfloatsampleavailable');
    
    if ~New                                                         % checks if new (float) sample is available: returns -1 if none or error, 0 if old, 1 if 'yes' new sample
        WaitSecs(0.001);                                                % if not a new sample, try again in 1 ms        
    else
        currentSample = Eyelink('newestfloatsample');
%         disp('NEW SAMPLE!')                                             % - CHECK only for debugging
%         disp(currentSample);                                            %  - CHECK only for debugging
        
        % get values of the new sample
        currentX = currentSample.gx(p.policeEye);                       % gx= the gaze position for X; 1 is the left eye so we are accessing the left eye in the matlab array
        currentY = currentSample.gy(p.policeEye);                       % gy= gaze position for Y; same as above
        
        % test values to check if gaze is within policed fixation area
        if (currentX < (p.scr.fixPoliceX + p.scr.fixPoliceRadius)) &&  (currentX > (p.scr.fixPoliceX - p.scr.fixPoliceRadius)) ... % it is within X boundaries
                && (currentY < (p.scr.fixPoliceY + p.scr.fixPoliceRadius)) && (currentY > (p.scr.fixPoliceY - p.scr.fixPoliceRadius)) % it is within Y boundaries
            
            if thisFixTime == 0                                         % if fixation counter has not yet started
                thisOutofBounds = 0;                                      % reset
                fixationStartTime = GetSecs(); % get the time
                Eyelink('message','fixStart');
                thisFixTime = GetSecs - fixationStartTime;
                totalFixTime = totalFixTime + thisFixTime;                
            else                                                        % if fixation counter has already started
                thisFixTime = GetSecs - fixationStartTime;              % update thisFixTime
                totalFixTime = totalFixTime + thisFixTime;
            end
            
        else % gaze has strayed from fixation area
            
            thisFixTime = 0;                                            % reset since gaze has left fixation
            
            if thisOutofBounds == 0
                errorStartTime = GetSecs; % get time
                thisOutofBounds = GetSecs - errorStartTime;               % small but less than zero
                totalOutofBounds = totalOutofBounds + thisOutofBounds;         % add to total
            else                                                        % if the error timing has already started
                thisOutofBounds = GetSecs - errorStartTime;
                totalOutofBounds = totalOutofBounds + thisOutofBounds;
                
                if thisOutofBounds >= p.scr.maxPoliceErrorTime                % give participant a warning - duration = 'p.beepDur'set in SEQ_ParamsScr.m
                    % check quad
                    [samples, events, drained] = Eyelink('command', 'GetQueuedData');
                    break;
                end                
            end            
        end % fixation or error updates
        timePassed = GetSecs - startTime;        
    end % sample available / unavailable loop    
end %

% display(num2str(totalErrorTime), 'totalErrorTime')
end
