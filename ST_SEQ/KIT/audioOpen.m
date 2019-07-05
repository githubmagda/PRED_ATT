function [p ] = audioOpen(p)
% Set up audio parameters for low latency audio output
% Detailed explanation goes here
% see PsychPortAudioTimingTest and InitializePsychSound for details

% INITIALIZE
InitializePsychSound(1); % MUST Call. For low latency set to '1' or ([reallyneedlowlatency=0]) ??
aud = PsychPortAudio('GetDevices', [], 0); % get audio structure

p.audio.reqlatencyclass = 1; % 2 fastest but incompatible with other cards; 1=faster but compatible with other cards; 0=don't carequery: PsychPortAudio('GetDevices', [], 0)
%p.aud.deviceId = aud.DeviceIndex; % 0 = CoreAudio - low latency
p.audio.sampleRate = aud.DefaultSampleRate; % 44100; % for OSX  % Must set this. 48 khz most likely to work, as mandated by HDA spec. Common rates: 96khz, 48khz, 44.1khz.
p.audio.volume = 0.5;
p.audio.mode = 1;
p.audio.freq = 10000;
%p.aud.LowOutputLatency = aud.LowOutputLatency;

% OPEN
p.aud.handle = PsychPortAudio('Open', [], [], p.audio.reqlatencyclass, p.audio.freq, [], [] ); %[, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,

% MAKE SOUNDS
%beep = sin(2*pi*freq*(0:duration*samplingRate-1)/samplingRate);
% p.audio.beepHappy = p.audio.volume * repmat( sin(2*pi * p.audio.freq *(0:aud.LowOutputLatency *aud.sampleRate-1)/p.audio.sampleRate), 2,1);
% p.audio.beepWarn = p.audio.volume * repmat( sin(2*pi * p.aud.freq./4   *(0:aud.LowOutputLatency *aud.sampleRate-1)/p.audio.sampleRate), 2,1);
% % p.aud.beepWarn(1,:) = p.aud.volume * MakeBeep(1000, 0.01, 48);
% % p.aud.beepWarn(2,:) = p.aud.beepWarn(1,:);
% % p.aud.beepWarn = repmat([sin(1:.001:1.01)] ,2, 1); %[sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)]; % 

% % Fill BUFFER with data for beep Happy:
% PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);

% Perform one warmup trial, to get the sound hardware fully up and running,
% performing whatever lazy initialization only happens at real first use.
% This "useless" warmup will allow for lower latency for start of playback
% during actual use of the audio driver in the real trials:
% PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
% PsychPortAudio('Stop', p.aud.handle, 1);
p.audio.audStruct = aud;
end


% % pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,
% % suggestedLatency][, selectchannels][, specialFlags=0]);
% % 
% % call: devs = PsychPortAudio(''GetDevices''); and provide the device index\n');
% % fprintf('of a suitable device\n\n');