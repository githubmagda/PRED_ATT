function [p] = monitorFixation(p, sr)

% Checks for fixation within specified area set by p.fixPoliceX +/- p.fixPoliceRadius
% If gaze strays outside of area, beep is given

%% Initialize
% Eyelink('Command', 'set_idle_mode');
% WaitSecs(0.05);

%% TO DELETE
% % % Eyelink('command', 'clear_screen 0'); %clear eyelink display
% % % Eyelink('command', 'draw_filled_box %d %d %d %d 5', ... % draw a box @ fixation on eyelink display
% % % p.Display.width/2-p.fixCircleRadius, p.Display.height/2-p.fixCircleRadius, p.Display.width/2+p.fixCircleRadius, p.Display.height/2+p.fixCircleRadius );

% % % EL_startRecord(sr)

%% TO DELETE
% Eyelink('StartRecording', 1, 1, 1, 1);
% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data
% WaitSecs(0.1);

message = strcat(['POLICE_FIXATION_SR', num2str(stair.number),'AttnQUAD', num2str(sr.thisCue)]);
Eyelink( 'Message', message);

% This supplies the title at the bottom of the eyetracker display CHECK
% % message = strcat(['record_status_message "SERIES"', num2str(sr.number)]);
% % Eyelink('command', message);

% variable for a new eyelink sample 1 = yes
thisFixTime = 0;
totalFixTime = 0; % 
thisErrorTime = 0; % error timer, 0= OFF, 1=ON 
timeStart = 0;
timePassed = 0;

while timePassed < p.preSeriesFixTime % checks for a new sample
    
    if Eyelink('newfloatsampleavailable') ~= 1 % checks if new (float) sample is available: returns -1 if none or error, 0 if old, 1 if 'yes' new sample
        WaitSecs(0.001); % if not a new sample, try again in 1 ms
        
    else
        currentSample = Eyelink('newestfloatsample');
        %disp('NEW SAMPLE!')
        %disp(currentSample); % CHECK - only for debugging
        
        % get values of the new sample
        currentX = currentSample.gx(p.policeEye); % gx= the gaze position for X; 1 is the left eye so we are accessing the left eye in the matlab array
        currentY = currentSample.gy(p.policeEye); % gy= gaze position for Y; same as above
        
        % test values to check if gaze is within policed fixation area
        if (currentX < (p.fixPoliceX + p.fixPoliceRadius)) &&  (currentX > (p.fixPoliceX - p.fixPoliceRadius)) ... % it is within X boundaries
                && (currentY < (p.fixPoliceY + p.fixPoliceRadius)) && (currentY > (p.fixPoliceY - p.fixPoliceRadius)) % it is within Y boundaries
            
            if thisFixTime == 0 % fixation counter has not yet started
                fixationStartTime = GetSecs(); % get the time
                Eyelink('message','fixStart');
                thisFixTime = GetSecs - fixationStartTime;
                
            else % if the fixation counter has already started
                currentTime = GetSecs(); % update currentTime and change whether  required fixPoliceTimeRequired was met
                %display('thisFixTime')
                thisFixTime = currentTime - fixationStartTime; % update timer               
            end
            
        else % gaze has strayed from fixation area
            
            totalFixTime = totalFixTime + thisFixTime; 
            thisFixTime = 0; % reset since gaze has left fixation

            if thisErrorTime == 0 %
                errorStartTime = GetSecs(); % get time
                thisErrorTime = GetSecs - errorStartTime;
            
            else  % if the error timing has already started
                
                thisErrorTime = GetSecs - errorStartTime;
                
                if thisErrorTime >= p.maxPoliceErrorTime % give participant a warning - duration = 'p.beepDur'set in SEQ_ParamsScr.m
                    Snd('Play', p.audFs); % ('Play',sin(7000:8000));%% CHECK
                    Snd('Quiet');            
                    %Beeper( p.audFs, p.globalVolume, p.beepDur ); %  Beeper(frequency, [fVolume], [durationSec]);
                end
                
            end
            
        end % fixation or error updates
        
        timePassed = GetSecs - timeStart;
        
    end % sample available / unavailable loop   

end % while timePassed < p.preSeriesFixTime loop

display(num2str(p.preSeriesFixTime), 'preSeriesFixTime')
display(num2str(totalFixTime), 'totalFixTime')

%% display(num2str(totalErrorTime), 'totalErrorTime')
end
