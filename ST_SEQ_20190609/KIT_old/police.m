function [outOfBounds] = police(p)

% POLICING
thisErrorTime = 0;

if Eyelink('newfloatsampleavailable') ~= 1 % checks if new (float) sample is available: returns -1 if none or error, 0 if old, 1 if 'yes' new sample
    WaitSecs(0.001); % if not a new sample, try again in 1 ms
else
    currentSample = Eyelink('newestfloatsample');
    %disp('NEW SAMPLE!')
    
    % get values of the new sample
    currentX = currentSample.gx(p.policeEye); % gx= the gaze position for X; 1 is the left eye so we are accessing the left eye in the matlab array
    currentY = currentSample.gy(p.policeEye); % gy= gaze position for Y; same as above
    
    % test values to check if gaze is OUTSIDE OF policed fixation area
    if ~( (currentX < (p.fixPoliceX + p.fixPoliceRadius)) &&  (currentX > (p.fixPoliceX - p.fixPoliceRadius)) ... % it is within X boundaries
            && (currentY < (p.fixPoliceY + p.fixPoliceRadius)) && (currentY > (p.fixPoliceY - p.fixPoliceRadius))) % it is within Y boundaries
        
        if thisErrorTime == 0
            errorStartTime = GetSecs; % get time
            thisErrorTime = GetSecs - errorStartTime;
            
        else  % if the error timing has already started, e.g. thisErrorTime  NOT = 0
            
            thisErrorTime = GetSecs - errorStartTime;
            
            if thisErrorTime >= p.maxPoliceErrorTimeMovie % give participant a warning - duration = 'p.beepDur'set in SEQ_ParamsScr.m
                outOfBounds = 1;                
            end
        end  % gaze in boundary loop
    end
end % sample_available loop