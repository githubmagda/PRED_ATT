function [p] = openWindowKit(p)
% Prep visual dispay by opening window

% Open a double buffered fullscreen window.
p.scr.number = max(Screen('Screens')); 

% Enable 32bpc
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

% DEFINE screen, screen pointer
% determine whether to use test (small window-size) and priority to presentation screen)

if p.debug == 1 % set to additional screen or to partial screen size for debugging
    
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'Verbosity', 3); % e.g. 0 for faster processing, 2 or maybe 3 for debugging 
    
    % open window
    if p.scr.number == 1  % send to extra full-size test screen         
        [p.scr.window, p.scr.windowRect] = PsychImaging('OpenWindow', p.scr.number, 0.5);
    else
        [p.scr.window, p.scr.windowRect] = PsychImaging('OpenWindow', p.scr.number, 0.5, p.scr.testDimensions, 32, 2,...
             [], [],  kPsychNeed32BPCFloat);
    end
       
else % normal experimental mode with full window size; ensures sync tests are run
    
    Screen('Preference', 'SkipSyncTests', 0); % should be 0
    Screen('Preference', 'VisualDebuglevel', 3); % 
    Screen('Preference', 'Verbosity', 0); % e.g. 0 for faster processing, 2 or maybe 3 for debugging 
    
    % open window
    [p.scr.window, p.scr.windowRect] = PsychImaging('OpenWindow', p.scr.number, 0.5);
    
    % set window parameters   
    Priority(MaxPriority(p.scr.window));
    
    % HideCursor; % CHECK 
end

% Enable alpha-blending, set it to a blend equation useable for linear
% additive superposition. This allows to linearly
% superimpose gabor patches in the mathematically correct manner, should
% they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
% the 'DrawTextures' can be used to modulate the intensity of each pixel of
% the drawn patch before it is superimposed to the framebuffer image, ie.,
% it allows to specify a global per-patch contrast value:
%Screen('BlendFunction', p.scr.window, GL_ONE, GL_ZERO);
%Screen('BlendFunction', p.scr.window, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
%Screen('BlendFunction', p.scr.window, GL_ONE, GL_ONE);
%Screen('Blendfunction', p.scr.window, GL_SRC_ALPHA, GL_ONE);
%Screen('BlendFunction', p.scr.window, GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
%Screen('Blendfunction', p.scr.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_COLOR);
Screen('Blendfunction', p.scr.window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

end
