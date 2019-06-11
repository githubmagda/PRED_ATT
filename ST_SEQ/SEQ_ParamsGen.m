
function [p] = SEQ_ParamsGen(p)
% This file contains the pre PTB window-open experimental parameters
% Parameters related to PTB windows are set in SEQ_PARAMs_scr

% TRIAL SPECS
p.blockNumber = 0; % CHECK - do we need blocks?
p.seriesNumber = 0;
p.seriesPerBlock = 1;
p.seriesPerEdf = 1; % how often data is output to edf file; safer to output each series in case participant quits

% WINDOW DIMENSIONS 
p.scr.testDimensionX = 600; % in pixels
p.scr.testDimensionY = 600;
% p.scr.textScrRatioX = p.scr.testDimensionX ./ 1440;   % 1440 x 900 
% p.scr.textScrRatioY = p.scr.testDimensionY ./ 900;
%p.scr.testDimensionY = p.scr.testDimensionX .* .7379; %% xTest *.7379 uses actual screen ratio from preferences set in prefFunction below
p.scr.testDimensions = [0, 0, p.scr.testDimensionX, p.scr.testDimensionY];  %% xTest xTest*.7379 use actual screen ratio from preferences set in prefFunction below

% SOUND
p.snd.happy = MakeBeep(5000,.005);
p.snd.warn = MakeBeep(100,.005);
%p.audFs = sin(2000:3000);   % Auditory sampling frequency (Hz) for beep;
p.snd.globalVolume = 0.5;       % Global volume level
p.snd.beepDur = 0.1;
p.snd.beepDurDisplay = 0.005;

% TEXT  
p.scr.textType = 'Helvetica';
if p.debug
    p.scr.textSize = 14;
else p.scr.textSize = 18;
end

% KEYBOARD 
KbName('UnifyKeyNames'); % enables cross-platform key id's
p.escapeKey = KbName('escape');    
p.responseKey = KbName('space'); %% space bar = '44' 
% p.responseKeyList = [KbName('z'), KbName('x'), KbName('c'), KbName('1'), KbName('2'), KbName('3')];
p.calibKey = KbName('c');  % Key during breaks to call calibration
p.validKey = KbName('v');  % Key during breaks to call validation of calibration
p.quitKey = KbName('q');   % Key during breaks to stop eyetracking

% AUDIO
HappyWave = [sin(1:.6:400), sin(1:.8:400), sin(1:14:400)]; % [sin(1:.001:1.01)];% 
WarnWave = [sin(1:.1:400), sin(1:.3:400), sin(1:.5:400)]; 
p.snd.audioWarn = audioplayer(WarnWave, 22050);
p.snd.audioHappy = audioplayer(HappyWave, 22050);

% series parameters MOVED TO SEQ_ParamsScr

%% time variables  %% CHECK
p.waitText = 5.0; % in seconds
p.waitBlank = 0.3;
   
%% eyetracker parameters and question MOVED TO 'ASKEYELINK'
