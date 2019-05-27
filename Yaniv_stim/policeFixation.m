function policeFixation(Params, nTrial)
% This function waits for subject to meet fixation parameters

%% Initialize
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('command', 'clear_screen 0'); %clear eyelink display
Eyelink('command', 'draw_filled_box %d %d %d %d 5', ... %draw an area @ fixation on eyelink display
    Params.Display.width/2-Params.fixCircleRadius, Params.Display.height/2-Params.fixCircleRadius, Params.Display.width/2+Params.fixCircleRadius, Params.Display.height/2+Params.fixCircleRadius );

Eyelink('StartRecording', 1, 1, 1, 1);
% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data
WaitSecs(0.1);

% STEP 7.1
% Sending a 'TRIALID' message to mark the start of a trial in Data
% Viewer.  This is different than the start of recording message
% START that is logged when the trial recording begins. The viewer
% will not parse any messages, events, or samples, that exist in
% the data file prior to this message.
Eyelink('Message', 'POLICETRIALID %d', nTrial);

% This supplies the title at the bottom of the eyetracker display
Eyelink('command', 'record_status_message "TRIAL %d"', nTrial); 
Eyelink('message','fixStart');

% Police
newSample=1; %variable for a new eyelink sample 1=yes
fixationTimer= 0; % variable to start counting down fixation or not, 0= OFF, 1=ON

while newSample == 1 % checks for a new sample
    if Eyelink('newfloatsampleavailable') ~= 1 % checks if new (float) sample is available: returns -1 if none or error, 0 if old, 1 if new
        WaitSecs(0.001); % if not a new sample, try again in 1 ms
    else
        currentSample= Eyelink('newestfloatsample');
%         disp(currentSample);
        % get values of the new sample
        currentX = currentSample.gazeX(Params.policeEye); % gx= the gaze position for X; 1 is the left eye so we are accessing the left eye in the matlab array
        currentY= currentSample.gazeY(Params.policeEye); % gy= gaze position for Y; same as above
        % test values against the fixation police
        if (currentX < (Params.fixPoliceX + Params.fixPoliceSize)) &&  (currentX > (Params.fixPoliceX - Params.fixPoliceSize)) ... % is it near X center
                && (currentY < (Params.fixPoliceY + Params.fixPoliceSize)) && (currentY > (Params.fixPoliceY - Params.fixPoliceSize)) % is it near Y center
            if fixationTimer==0 %if the fix timer is not started
                fixationStartTime=GetSecs(); %get the time
                fixationTimer=1; %start fix timer
            else %if the fixation timer is started
                currentTime=GetSecs(); %update currtTime and chage whether  required fixPoliceTimeRequired was met
                if currentTime - fixationStartTime  > Params.fixPoliceTimeRequired
                    newSample=0; %stop poling fixation
                end
            end
        end
    end
end
end