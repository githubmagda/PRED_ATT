
function [p] = openWindowKit(p)
% Prep visual dispay by opening window

p.scr.number = max(Screen('Screens'));
% determine whether to use test (small window-size) and priority to presentation screen)

if p.debug == 1 % set to additional screen or partial screen size for debugging
    
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'Verbosity', 3); % e.g. 0 for faster processing, 2 or maybe 3 for debugging 
    
    % open window
    if p.scr.number == 1  % send to extra full-size test screen 
       [p.scr.window, p.scr.windowRect] = Screen('OpenWindow',p.scr.number, 0.5, p.scr.testDimensions);
    else
        [p.scr.window, p.scr.windowRect] = Screen('OpenWindow', p.scr.number, 0.5, p.scr.testDimensions);
    end 
    
    % HideCursor;
    
else % normal experimental mode with full window size; ensures sync tests are run
    
    Screen('Preference', 'SkipSyncTests', 0); % should be 0
    Screen('Preference', 'VisualDebuglevel', 3); % 
    Screen('Preference', 'Verbosity', 0); % e.g. 0 for faster processing, 2 or maybe 3 for debugging 
    
    % open window
    [p.scr.window, p.scr.windowRect] = PsychImaging('OpenWindow', p.scr.number, 0.5, []);
    
    % Retreive the maximum priority number and set priority
    %Priority(MaxPriority(p.scr.window));
    p.scr.number = 1;

    HideCursor;  
end

Screen('Blendfunction', p.scr.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%%% NOTE: NEED TO CHECK ABOUT GAMMA CORRECTION %%%%

% if strcmp(Params.location, 'lab')
%     caliFile = 'calibration_09-May-2016_BENQsubj.mat';
%     eval(['load C:\Users\Display\Documents\Experiments\Calibration\' caliFile ]);
%     Params.calibration = calibration;
%     Screen('LoadNormalizedGammaTable', Params.w, Params.calibration.monitorGamInv ,0); %calibration.monitorGamInv is the LUT
% end

