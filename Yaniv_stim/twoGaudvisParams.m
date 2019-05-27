%% This file contains all the parameters for the experiment
%% General Parameters
Params.location = 'lab'; %'lab'    % Where are we - set for display parameters

button = questdlg('Use eyetracking?','Eyetracking','Yes','No','Yes');

switch button
    case 'Yes'
        Params.EyeLink = 1;
    case 'No'
        Params.EyeLink = 0;
end
Params.EyeLinkMouse = 0;

if Params.EyeLink
    button = questdlg('Use which eye for policing?','Eyetracking',...
        'Left','Right','Left');
    switch button
        case 'Left'
            Params.policeEye = 1;
        case 'Right'
            Params.policeEye = 2;
    end
end

Params.Display = mkDisplay(Params);  % This is where display parameters are saved

% Get colours
Params.white = WhiteIndex(Params.Display.screenNumber);
Params.black = BlackIndex(Params.Display.screenNumber);
Params.grey = round(mean([Params.black, Params.white]));

Params.trialDuration = 4000;    % Overall trial duration (ms) for exp block
Params.threshTrialDuration = 2000; % trial duration for thresholding
Params.keepClear = [500 500];   % How long to keep clear of targets from beginnig and end of trial (ms) (will be rounded to frame flips)
Params.onsetRes = 2;        % Target onset resolution (frames).
Params.expRepPerBin = 2;    % How many trials per bin

Params.rtDefault ={'150' '1000'};   % Default for RT hist text box

Params.ITIRange = [750 1200];  % Range for jittered ITI (ms)
Params.ITILoadTime = 500;       % How much of ITI to allocate for loading next stimulus into buffer (ms)

Params.catchRatio = .1;         % General catch trial ratio for experiment

Params.defaultRTCutoff = [150 1000];    % Default RT range to consider as hit

Params.thresholdPoint = .5;     % Proportion to regard as threshold

Params.KeyEsc = KbName('escape');
Params.KeyRight = KbName('/?');
Params.KeyLeft = KbName('z');
Params.rightIs = 1;     % mapping in Logger for right and left response
Params.leftIs = 2;

if mod(Params.SubjectNumber, 2)
    Params.audIs = Params.rightIs;    % Assignment of keys to modality for discrimination task.
    Params.visIs = Params.leftIs;
else
    Params.audIs = Params.leftIs;
    Params.visIs = Params.rightIs;
end
Params.keys = [Params.KeyRight Params.KeyLeft];
Params.respMap(Params.KeyRight) = Params.rightIs;
Params.respMap(Params.KeyLeft) = Params.leftIs;
Params.respMap(256) = 0;


Params.breakEvery = 80;         % Insert break every x trials

Params.onsetRange1stStim = [-500 1000]; % Target onset range, locked to 2nd stim onset (ms)
Params.onsetRange2ndStim = [50 1000]; % Target onset range, locked to 2nd stim onset (ms)
Params.SecondStimulusOnsetRange = [600 2800]; % Second stim onset range, locked to 1st target onset (ms)


%% Visual parameters
Params.visTargType = 'central';    % 'peripheral'
Params.gratingSize = 5/2;     % Grating radius (deg)
Params.gratingSF = 3.2;     % Grating spatial frequency (cycle/deg)
Params.gratingContrast = 1;

Params.visTargDuration = 20;   % Visual target duration (ms)
Params.visTargSize = 1/4;        % Visual target size (deg/sd)
Params.visTargEdge = 1;       % Keep target center away from grating edge on annulus (factor of target size) 

switch Params.visTargType
    case 'peripheral'
        Params.gratingEcc = 4;   % Grating eccentricity (deg) (for peripheral case only)
        Params.visTargEccRange = [3.5 4.5];    % Visual target eccentricity range
    case 'central'
        Params.gratingEcc = 0;   % Grating eccentricity (deg) (for peripheral case only)
        Params.visTargEccRange = [1.5 2];    % Visual target eccentricity range
end


Params.fixationSize = 1/8;                % Fixation size (deg)

Params.visTrainBlockLevel = [.9 .8 .7]; % Target magnitude for training block
Params.visRoughRunLevel = logspace(log10(.1),log10(.9),15); % Target magnitude for rough run

Params.visThreshRepetitions = [10 10 20 20 20 20 20 20 10 10]; % Number of repetitoins for each stim level in method of constant stimuli, lenght determines the number of levels

% Square for diode params
Params.diodeRect = [0 0 0 0];   % Display rect bounds for diode
Params.stimColor = Params.black;
Params.trgColor = Params.white;
%% Auditory parameters
Params.audTargDuration = 20;            % Auditory target duration (ms)
Params.audFs = 44100;                   % Auditory sampling frequency (Hz)
Params.globalVolume = .5;               % Global volume level

% Threshold block
Params.audThreshold.exampleTargLevel = .9;  % stimLevel for example blocks (1-r)

Params.audThreshold.MultiTargetNTargets = 6;    % Number of targets per multi target trial
Params.audThreshold.MultiTargetNTrials = 6;     % Number of multi target trials
Params.audThreshold.MultiTargetISI = 2000;      % Duration of each segment of multi target trials (ms)

Params.audTrainBlockLevel = [.9 .6 .3];            % Target magnitude for half and half training block

Params.audRoughRunLevel = logspace(log10(.02),log10(.7),15);   % Target magnitude for rough run

Params.rampOffDuration = 50;                % Duration of ramp off for subject induced stimulus stop (ms)

Params.audThreshRepetitions = [10 10 20 20 20 20 20 20 10 10];  % Number of repetitoins for each stim level in method of constant stimuli, lenght determines the number of levels

Params.audDefaultLevels = stimLevelRange([.07, .7], length(Params.audThreshRepetitions));
Params.visDefaultLevels = stimLevelRange([.07, .7], length(Params.audThreshRepetitions));

%% Eyetracking
Params.fixPoliceTimeRequired= 0.5; % change this to how long you want to fixate for (in s)
Params.fixPoliceSize=angle2pix(Params.Display,1.5); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO START THE TRIAL
Params.fixTrialPoliceSize=angle2pix(Params.Display,3); % fixation center +/- # (in pixels) THE ACTUAL POLICING VALUES THAT ARE USED TO STOP THE TRIAL
Params.fixPoliceX= Params.Display.width/2; %Xcenter
Params.fixPoliceY= Params.Display.height/2; %Ycenter
Params.fixCircleRadius = angle2pix(Params.Display,1); % In Pixels, big circle of fixation point was 10 in the original kermit THIS VALUE SETS THE PURPLE SQUARE ON THE EYELINK COMPUTER.
Params.fixDotRadius = 2; % In Pixels, small circle of fixation point THIS VALUE DOESN'T SEEM TO BE USED
Params.calibKey = KbName('c');  % Key during breaks to call calibration
Params.quitKey = KbName('q');   % Key during breaks to stop eyetracking
Params.fixViolNum = 3;      % How many frames of violated fixation should we tolerate before breaking trial?
Params.waitAfterPolice = 500;   % Extra ITI after policing stops trial, to cool down
%% Compute stuff
% Create ramp down for subject induced stimulus stop
ramp=linspace(0,1,round(Params.rampOffDuration/1000*Params.audFs));                  
ramp=6*ramp.^5-15*ramp.^4+10*ramp.^3; 
ramp=ramp(end:-1:1);
ramp=[ramp zeros(1,round(Params.trialDuration/1000*Params.audFs))];
Params.audRamp=[ramp;ramp];