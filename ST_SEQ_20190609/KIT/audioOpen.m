function [p ] = audioOpen(p)
% Set up audio parameters for low latency audio output
% Detailed explanation goes here
% see PsychPortAudioTimingTest and InitializePsychSound for details

InitializePsychSound(0); % MUST Call. For low latency set to '1' or ([reallyneedlowlatency=0]) ??

p.aud.reqlatencyclass = 2; % query: PsychPortAudio('GetDevices', [], 0)
p.aud.deviceid = 0; % 0 = CoreAudio - low latency
p.aud.freq = 44100; % for OSX  % Must set this. 48 khz most likely to work, as mandated by HDA spec. Common rates: 96khz, 48khz, 44.1khz.
p.aud.handle = PsychPortAudio('Open', [], [], p.aud.reqlatencyclass, p.aud.freq, [], [] ); %[, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,
p.aud.volume = 0.5;

% Generate sounds: X Hz, 0.X secs, 50% amplitude:
p.aud.beepHappy(1,:) = p.aud.volume * MakeBeep(10000, 0.01, p.aud.freq); % make matrix with 2 'channels'
p.aud.beepHappy(2,:) = p.aud.beepHappy(1,:);

p.aud.beepWarn(1,:) = p.aud.volume * MakeBeep(1000, 0.01, p.aud.freq);
p.aud.beepWarn(2,:) = p.aud.beepWarn(1,:);

% warning: [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)]; % [sin(1:.001:1.01)];%

% Fill buffer with data for beep Happy:
PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepHappy);
PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', p.aud.handle, 1);

% beep Warn
PsychPortAudio('FillBuffer', p.aud.handle, p.aud.beepWarn);
PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', p.aud.handle, 1);

% Perform one warmup trial, to get the sound hardware fully up and running,
% performing whatever lazy initialization only happens at real first use.
% This "useless" warmup will allow for lower latency for start of playback
% during actual use of the audio driver in the real trials:
PsychPortAudio('Start', p.aud.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
PsychPortAudio('Stop', p.aud.handle, 1);

end




% % pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][,
% % suggestedLatency][, selectchannels][, specialFlags=0]);
% % 
% % call: devs = PsychPortAudio(''GetDevices''); and provide the device index\n');
% % fprintf('of a suitable device\n\n');