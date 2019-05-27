function Display = mkDisplay(Params)
% Computes parameters for angle to pixel conversions

switch Params.location
    case 'yaniv'
        Display.screenNumber=max(Screen('screens'));
        
        Display.frameRate=Screen('FrameRate',Display.screenNumber);   % Get screen refresh rate
        
        Display.flipInterval = 1 / Display.frameRate * 1000;   % Time of frame (ms). Will change when window opens to accurate ifi
        
        [Display.width, Display.height] = Screen('WindowSize', Display.screenNumber); % get the screen dimensions
        
        Display.dimensions = [31.5 17.5];       % (cm)
        
        Display.pixelSize = mean(Display.dimensions./[Display.width, Display.height]);
        
        Display.distance = 45;              % Viewing distance (cm)
    case 'lab'
        Display.screenNumber=max(Screen('screens'));                 % Screen number
        
        Display.frameRate=Screen('FrameRate',Display.screenNumber);   % Get screen refresh rate
        
        if Display.frameRate ~= 100
            error('Screen refresh rate is not 100Hz. Fix before running');
        end
        
        Display.flipInterval = 1 / Display.frameRate * 1000;   % Time of frame (ms). Will change when window opens to accurate ifi
        
        [Display.width, Display.height] = Screen('WindowSize', Display.screenNumber); % get the screen dimensions
        
        Display.dimensions = [53.1 29.8];       % (cm)
        
        Display.pixelSize = mean(Display.dimensions./[Display.width, Display.height]);
        
        Display.distance = 95;              % Viewing distance (cm)
        
        Display.eyelinkDistance = [950 1010]; % distance from top and bottom of screen to chin rest in mm for eyelink
end

end