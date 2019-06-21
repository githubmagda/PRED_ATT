function [frame] = checkRTPolice(p, frame, displayTime)

%startTime = GetSecs;

thisErrorTime = 0;

 while GetSecs < displayTime   % time2Go > (GetSecs-startTime)
    
    [keyIsDown, secs, keyCode]= PsychHID('KbCheck'); % PsychHID('KbCheck', [], ptb_kbcheck_enabledKeys);    
    
    if (keyCode(p.escapeKey) == 1)
        break;
    end
    
    if keyIsDown  % the subject has pressed a key but has not previously responded in this loop
        frame.response = 1;
        frame.RT = secs - frame.dotOnTime; % get time of response
        frame.RKey = KbName(find(keyCode, 1 ));
    end
    
    % if frame.response == 1; break; end % no point in continuing to loop if captured response
    % WaitSecs(p.scr.refreshRate * 0.01);  % fixes a glitch in the loop function    

    %% POLICING
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
                errorStartTime = GetSecs(); % get time
                thisErrorTime = GetSecs - errorStartTime;
            
            else  % if the error timing has already started, e.g. thisErrorTime  NOT = 0
                
                thisErrorTime = GetSecs - errorStartTime;
                
                if thisErrorTime >= p.maxPoliceErrorTimeMovie % give participant a warning - duration = 'p.beepDur'set in SEQ_ParamsScr.m
                    frame.outOfBounds = 1;
                    %Snd('Play', p.audFs); % ('Play',sin(7000:8000));%% CHECK
                    %Snd('Quiet'); 
                    %Beeper( p.audFs, p.globalVolume, p.beepDur ); %  Beeper(frequency, [fVolume], [durationSec]);
                end    
            end  % gaze in boundary loop          
        end         
    end % sample_available loop   
end

%FlushEvents('keyDown')  % FlushEvents(['mouseUp'],['mouseDown'],['keyDown'],['autoKey'],['update']
end
