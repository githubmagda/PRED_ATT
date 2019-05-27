function Params = openWindow(Params)
% Prep visual dispay

if strcmp(Params.debug,'off')
    % Ensures the sync tests are run
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'VisualDebuglevel', 3);
    Screen('Preference', 'Verbosity', 2);
end

HideCursor;

[Params.w, Params.screenRect]=Screen('OpenWindow', Params.Display.screenNumber, Params.grey);
[Params.Display.flipInterval, Params.Display.nrValidSamples, Params.Display.stddev]= Screen('GetFlipInterval', Params.w);
Params.Display.flipInterval = Params.Display.flipInterval*1000;
[x,y] = WindowCenter(Params.w);
Params.wCenter = [x y];

%%% NOTE: NEED TO CHECK ABOUT GAMMA CORRECTION %%%%

% if strcmp(Params.location, 'lab')
%     caliFile = 'calibration_09-May-2016_BENQsubj.mat';
%     eval(['load C:\Users\Display\Documents\Experiments\Calibration\' caliFile ]);
%     Params.calibration = calibration;
%     Screen('LoadNormalizedGammaTable', Params.w, Params.calibration.monitorGamInv ,0); %calibration.monitorGamInv is the LUT
% end

Screen('Blendfunction', Params.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);