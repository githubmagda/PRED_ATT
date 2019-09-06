function [p ] = audioOpen(p)
% Set up audio parameters for low latency audio output
% Detailed explanation goes here
% see PsychPortAudioTimingTest and InitializePsychSound for details

% INITIALIZE
InitializePsychSound(1); % MUST Call. For low latency set to '1' or ([reallyneedlowlatency=0]) ??
aud = PsychPortAudio('GetDevices', [], 1); % get audio structure [deviceType], [deviceIndex]
reqlatencyclass = 1; % 2 fastest but incompatible with other cards; 1=faster but compatible with other cards; 0=don't carequery: PsychPortAudio('GetDevices', [], 0)

freq = 10000;
volume = 1.0;

% OPEN
p.audio.handle = PsychPortAudio('Open', aud.DeviceIndex, [], reqlatencyclass, freq, [], [] ); %[, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,

% MAKE SOUNDS
%beep = sin(2*pi*freq*(0:duration*samplingRate-1)/samplingRate);
p.audio.beepHappy   = volume * repmat( sin(2*pi * freq *(0:.05*aud.DefaultSampleRate-1)/aud.DefaultSampleRate), 2,1);
p.audio.beepWarn    = volume * repmat( sin(2*pi * freq./2 *(0:.015*aud.DefaultSampleRate-1)/aud.DefaultSampleRate), 2,1);
% p.aud.beepWarn(1,:) = p.aud.volume * MakeBeep(1000, 0.01, 48);
% p.aud.beepWarn(2,:) = p.aud.beepWarn(1,:);
% p.audio.beepWarn = repmat([sin(1:.001:1.01)] ,2, 1); %[sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)]; %

% % Fill BUFFER with data for beep Happy:
PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepHappy);
PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);

% Perform one warmup trial, to get the sound hardware fully up and running,
% performing whatever lazy initialization only happens at real first use.
% This "useless" warmup will allow for lower latency for start of playback
% during actual use of the audio driver in the real trials:
PsychPortAudio('Start', p.audio.handle, 1, 0);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', p.audio.handle, 1);
p.audio.audStruct = aud;
end


% % pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,
% % suggestedLatency][, selectchannels][, specialFlags=0]);

% % call: devs = PsychPortAudio(''GetDevices''); and provide the device index\n');
% % fprintf('of a suitable device\n\n');