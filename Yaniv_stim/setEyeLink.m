function [el, edfFile, v, vs] = setEyeLink(Params, edfFile)
% 
% % FUNCTION [el params edfFile v vs] = setEyeLink(params)
% % function originally written for experiment twoG by ANL Dec 2010
% % initialized many of the eye link requirements
% % Adapted for twoG_audvis1 by YA JUN 2016
% 
%     if Params.EyeLink==1
%         if Eyelink('initialize') ~= 0
%             fprintf('error in connecting to the eye tracker')
%             return
%         end
%     else
%         Eyelink('initializedummy')
%     end
%     % STEP 2
%     % Added a dialog box to set your own EDF file name before opening 
%     % experiment graphics. Make sure the entered EDF file name is 1 to 8 
%     % characters in length and only numbers or letters are allowed.
%        
%     % STEP 4
%     % Provide Eyelink with details about the graphics environment
%     % and perform some initializations. The information is returned
%     % in a structure that also contains useful defaults
%     % and control codes (e.g. tracker state bit and Eyelink key values).
%     el=EyelinkInitDefaults(Params.w);
% 
%     [v, vs]=Eyelink('GetTrackerVersion');
%     fprintf('Running experiment on a ''%s'' tracker.\n', vs )
% 
%     % open file to record data to
%     i = Eyelink('Openfile', edfFile);
%     if i~=0
%         printf('Cannot create EDF file ''%s'' ', edffilename)
%         Eyelink( 'Shutdown')
%         Screen('CloseAll');
%         return
%     end
% 
%     Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''') %PERHAPS CHANGE TO THE EXPERIMENTS NAME
%     % STEP 5    
%     % SET UP TRACKER CONFIGURATION - things that over write the physical.ini
%     % Setting the proper recording resolution, proper calibration type, 
%     % as well as the data file content
% %     these are the params ran in the psychophysics setup
% %     Eyelink('command','screen_phys_coords = %ld %ld %ld %ld', -237, 147.5, 237, -147.4) %in cm --this is for the psychphysics lcd screen. introduce if MEG for that setup
% %     Eyelink('command', 'screen_distance = 510 600') % in the psychphysics room -- measure for meg
% 
% % this is for MEG
%     %Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
%     Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, Params.Display.width-1, Params.Display.height-1)
%     %Eyelink('command', 'screen_distance = 540 520') % in the psychphysics room -- measure for meg
%     Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, Params.Display.width-1, Params.Display.height-1)  
%     
%     %getting the binocular sampling going
%     %Eyelink('command','binocular_enabled = YES')
% %     Eyelink('command','elcl_select_configuration BTABLER')
%     
%     % set calibration type.
%     Eyelink('command', 'calibration_type = HV9') %should be HV9
%     %Eyelink('command', 'calibration_area_proportion = 0.5 0.5') %we don't need the entire screen
%     %Eyelink('command', 'validation_area_proportion = 0.5 0.5')
%     % set parser (conservative saccade thresholds)
%     %Eyelink('command', 'saccade_velocity_threshold = 35')
%     %Eyelink('command', 'saccade_acceleration_threshold = 9500')
%     % set EDF file contents
%     Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON')
%     Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS')
%     % set link data (used for gaze cursor)
%     Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON')
%     Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS')
%     % allow to use the big button on the eyelink gamepad to accept the 
%     % calibration/drift correction target
%     Eyelink('command', 'button_function 5 "accept_target_fixation"')
%     %Eyelink('command', 'select_parser_configuration 1')
%     Eyelink('command','aux_mouse_simulation yes') %  YES / NO
%     %Eyelink('command','analog_out_data_type = GAZE') %  YES / NO
%     % make sure we're still connected.
%     if Eyelink('IsConnected')~=1 && Params.EyeLink
%         fprintf('not connected, clean up\n');
%         Eyelink( 'Shutdown');
%         Screen('CloseAll');
%         return;
%     end
%     
%      % STEP 6
%     % Calibrate the eye tracker  
%     % setup the proper calibration foreground and background colors
% 
% %     CHANGED FOR MEG SO THAT ITS BLACK BACKGROUND
% 
%     el.backgroundcolour = [128 128 128]; %dark gray = 128 for middle gray
%     el.foregroundcolour = [0 0 0];
% 
% % parameters are in frequency, volume, and duration
%     % set the second value in each line to 0 to turn off the sound
%     el.cal_target_beep=[600 0.5 0.05];
%     el.drift_correction_target_beep=[600 0.5 0.05];
%     el.calibration_failed_beep=[400 0.5 0.25];
%     el.calibration_success_beep=[800 0.5 0.25];
%     el.drift_correction_failed_beep=[400 0.5 0.25];
%     el.drift_correction_success_beep=[800 0.5 0.25];
%     % you must call this function to apply the changes from above
%     EyelinkUpdateDefaults(el);  
%     
%     % Hide the mouse cursor
%     Screen('HideCursorHelper', Params.w)
%     EyelinkDoTrackerSetup(el)

if ~Params.EyeLink
    fprintf('Eyelink Init aborted.\n');
    el = [];
    v =[];
    vs = [];
    return;
end
dummymode = ~Params.EyeLink

% STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(Params.w);

    % STEP 4
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        return;
    end

    % the following code is used to check the version of the eye tracker
    % and version of the host software
    sw_version = 0;

    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % open file to record data to
    i = Eyelink('Openfile', edfFile);
    if i~=0
        fprintf('Cannot create EDF file ''%s'' ', edfFile);
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end

    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
    [width, height]=Screen('WindowSize', 0);


    % STEP 5    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type, 
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);                
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'calibration_area_proportion = 0.5 0.5') %we don't need the entire screen
    Eyelink('command', 'validation_area_proportion = 0.5 0.5')
    
    Eyelink('command', 'screen_distance = %ld %ld', Params.Display.eyelinkDistance(1), Params.Display.eyelinkDistance(2))
    % set parser (conservative saccade thresholds)

    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

    % check the software version
    % add "HTARGET" to record possible target data for EyeLink Remote
    if sw_version >=4
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end

    % allow to use the big button on the eyelink gamepad to accept the 
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
   
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && dummymode == 0
        fprintf('not connected, clean up\n');
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end



    % STEP 6
    % Calibrate the eye tracker
    % setup the proper calibration foreground and background colors
    el.backgroundcolour = [128 128 128];
    el.calibrationtargetcolour = [0 0 0];

    % parameters are in frequency, volume, and duration
    % set the second value in each line to 0 to turn off the sound
    el.cal_target_beep=[600 0.5 0.05];
    el.drift_correction_target_beep=[600 0.5 0.05];
    el.calibration_failed_beep=[400 0.5 0.25];
    el.calibration_success_beep=[800 0.5 0.25];
    el.drift_correction_failed_beep=[400 0.5 0.25];
    el.drift_correction_success_beep=[800 0.5 0.25];
    
    if Params.EyeLinkMouse
        Eyelink('command','aux_mouse_simulation yes') %  YES / NO
    else
        Eyelink('command','aux_mouse_simulation no')
    end

    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(el);

    % Hide the mouse cursor;
    %Screen('HideCursorHelper', Params.w);
    EyelinkDoTrackerSetup(el);

end