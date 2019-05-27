function stimulus = mkAudNoiseStim(Params,Stim)
% Builds a noise stimulus with a decorrelation target
% {
% close all
% %parameters for testing as script
% pedestalFrequency=300; % carrier frequency
% corrChange=0.4; % modulation in frequency (Hz)
% sf=44100;
% EffectDuration=33;
% JitterRange=[-250 250];
% ISI=2000;
% }

%% Translate Stim struct parameters into variable this function likes
if isfield(Stim, 'audPedestalFreq')         % optional tone mixed in
    pedestalFrequency = Stim.audPedestalFreq;
    NoiseToneRSqr = Stim.audNoiseToneRSqr;
else
    pedestalFrequency = [];
    NoiseToneRSqr = 0;
end

EffectDuration = Params.audTargDuration;

corrChange = Stim.audTargLevel;

sf = Params.audFs;


% back compatability with time based onsets/ISIs
if isfield(Stim,'audStimOnsetFrames') && ~isempty(Stim.audStimOnsetFrames)
    ISI = Stim.trialDuration - Stim.audStimOnsetFrames * Params.Display.flipInterval;   % Stimulus length
    Onset = (Stim.audTargOnsetFrames - Stim.audStimOnsetFrames) * Params.Display.flipInterval;  % Target onset
else
    ISI = Stim.trialDuration - Stim.audStimOnset;   % Stimulus length
    Onset = Stim.audTargOnset - Stim.audStimOnset;  % Target onset
end

 %%
 if Stim.type == 0
     ISI = ISI / length(corrChange);

     
     corrChange = 1-corrChange;     % change into rho units
     
     if pedestalFrequency
         NEff = round(EffectDuration/1000*sf);
     else
         NEff = EffectDuration/1000*sf;
     end
     
     stimulus = [];
     for targ = 1:length(corrChange)
         v1 = 0.5*randn(1,NEff);
         v2 = 0.5*randn(1,NEff);
         nr = v1;
         nl = corrChange(targ)*v1+sqrt(1-corrChange(targ)^2)*v2;
         
         %% Build the rest of the trial around the modulation
         %% Preceeding sound variables
         
         NOnset = round((Onset(targ) - ISI*(targ-1)) / 1000 * sf);
         preNoise = 0.5*randn(1,NOnset);
         
         %% Post event noise
         remain = ISI*targ - Onset(targ) - EffectDuration;
         Nremain = round(remain / 1000 *sf);
         postNoise = 0.5*randn(1,Nremain);
         
         
         Noise_r = [preNoise nr postNoise];
         Noise_l = [preNoise nl postNoise];
         
         if pedestalFrequency
             tone = sin(2*pi*pedestalFrequency*(1:length(Noise_r))/sf);
             stimulus = [stimulus [NoiseToneRSqr*tone+sqrt(1-NoiseToneRSqr^2)*Noise_l; NoiseToneRSqr*tone+sqrt(1-NoiseToneRSqr^2)*Noise_r]];
         else
             stimulus = [stimulus [Noise_l; Noise_r]];
         end
         
     end
 else
     NISI = round(ISI/1000*sf);
     stimulus = repmat(0.5*randn(1,NISI),2,1);
 end
stimulus(stimulus>1) = 1;
stimulus(stimulus<-1) = -1;

% Avoid onset clicks
click=20;        %Duration of ramp to avoid click (ms)
%Ramp amplitude on and off to avoid clicks
Nclick=click/1000*sf;
RampOn=linspace(0,1,Nclick);
RampOn=6*RampOn.^5-15*RampOn.^4+10*RampOn.^3;              %apply smootherstep function
RampOff=RampOn(end:-1:1);

for i=1:2
stimulus(i,1:Nclick)=stimulus(i,1:Nclick).*RampOn;
stimulus(i,length(stimulus(1,:))-Nclick+1:end)=stimulus(i,length(stimulus(1,:))-Nclick+1:end).*RampOff;
end

end
