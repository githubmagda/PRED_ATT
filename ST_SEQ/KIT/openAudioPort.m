
function p = openAudioPort(p)
% Prep audio
% Request latency mode 2, empirically tested and recommended by PTB
reqlatencyclass = 2;

p.audio.globalVolume = 0.5;
p.audio.Fs = 44100;
p.audio.audRamp = 50;

% Other recommended PsychPortAudio settings
buffersize = 4096;
suggestedLatencySecs = [];
deviceid=[];
mode=1+8;

% Hack to accomodate bad Windows systems or sound cards. By default,
% the more aggressive default setting of something like 5 msecs can
% cause sound artifacts on cheaper / less pro sound cards. Check
% display comp's performance!! Maybe we can do without.
%suggestedLatencySecs = 0.015  %#ok<NOPRT>

% Open audio device for low-latency output:
p.audio.pahandle = PsychPortAudio('Open', deviceid, mode, reqlatencyclass, p.audio.Fs, 2, buffersize, suggestedLatencySecs);
PsychPortAudio('Start', p.audio.pahandle,0,0,1);               % start master audioport  
PsychPortAudio('Volume', p.audio.pahandle, p.audio.globalVolume);    % set volume for master audioport
p.audio.playSlave=PsychPortAudio('OpenSlave', p.audio.pahandle,1);           % Open slave audioport for stimulus playback
% p.audio.AMSlave = PsychPortAudio('OpenSlave', p.audio.pahandle, 32);    % Open slave audioport for ramp-down amplitude modulation on subject keypress
% PsychPortAudio('FillBuffer', p.audio.AMSlave, p.audio.audRamp);           % Fill AMSlave with ramp down

% Throat clear
ClearThroat=MakeBeep(500,0.3,p.audio.Fs);
PsychPortAudio('FillBuffer',p.audio.playSlave,[ClearThroat; ClearThroat]);
PsychPortAudio('Start', p.audio.playSlave,[],[],1);
WaitSecs(0.3);


end


