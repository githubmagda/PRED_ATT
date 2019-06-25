function Display = makeDisplay(Params)
% Computes parameters for angle to pixel conversions

switch Params.location
    case 'dev'
        Display.screenNumber=max(Screen('screens'));
        
        Display.frameRate= Screen('FrameRate',Display.screenNumber); % MA NOT SET here but in openWindow
        
        %Display.flipInterval = 1 / Display.frameRate * 1000;   %MA - doesn't calulate here. could use ?? function % Time of frame (ms). Will change when window opens to accurate ifi
        
        [Display.width, Display.height] = Screen('WindowSize', Display.screenNumber); % get the screen dimensions
        
        if strcmp(Params.debug,'on') % creates a non-fullscreen window to facilitate debugging
            Display.w_size = [0 0 Display.width/3 Display.height/3]; % size of the display window
        else
            Display.w_size = [0 0 Display.width Display.height]; % size of the display window
        end
        Display.dimensions = [28.6 17.8];       % (cm) Input actual screen size to calculate cm2pixel relation?
        
        Display.pixelSize = mean(Display.dimensions./[Display.width, Display.height]);
        
        Display.distance = 57;              % was 45 MA changed Viewing distance (cm)
        
    case 'meg'
        %         Display.screenNumber=max(Screen('screens'));                 % Screen number
        %
        %         Display.frameRate=Screen('FrameRate',Display.screenNumber);   % Get screen refresh rate
        %
        %         if Display.frameRate ~= 100
        %             error('Screen refresh rate is not 100Hz. Fix before running');
        %         end
        %
        %         Display.flipInterval = 1 / Display.frameRate * 1000;   % Time of frame (ms). Will change when window opens to accurate ifi
        %
        %         [Display.width, Display.height] = Screen('WindowSize', Display.screenNumber); % get the screen dimensions
        %
        %         Display.dimensions = [53.1 29.8];       % (cm)
        %
        %         Display.pixelSize = mean(Display.dimensions./[Display.width, Display.height]);
        %
        %         Display.distance = 95;              % Viewing distance (cm)
        %
        %         Display.eyelinkDistance = [950 1010]; % distance from top and bottom of screen to chin rest in mm for eyelink
end
