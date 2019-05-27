function Params = openAudioPort(Params)
% Prep audio
% Request latency mode 2, empirically tested and recommended by PTB
reqlatencyclass = 2;

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
Params.pahandle = PsychPortAudio('Open', deviceid, mode, reqlatencyclass, Params.audFs, 2, buffersize, suggestedLatencySecs);
PsychPortAudio('Start',Params.pahandle,0,0,1);               % start master audioport  
PsychPortAudio('Volume', Params.pahandle, Params.globalVolume);    % set volume for master audioport
Params.playSlave=PsychPortAudio('OpenSlave',Params.pahandle,1);       % Open slave audioport for stimulus playback
Params.AMSlave = PsychPortAudio('OpenSlave', Params.pahandle, 32);    % Open slave audioport for ramp-down amplitude modulation on subject keypress
PsychPortAudio('FillBuffer',Params.AMSlave,Params.audRamp);           % Fill AMSlave with ramp down

% Throat clear
ClearThroat=MakeBeep(500,0.3,Params.audFs);
PsychPortAudio('FillBuffer',Params.playSlave,[ClearThroat; ClearThroat]);
PsychPortAudio('Start', Params.playSlave,[],[],1);
WaitSecs(0.3);

end