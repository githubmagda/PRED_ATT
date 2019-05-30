% template for an example experiment
% clc;clear;close all; 

%% NOTES see Shen et al. 2015
% weibull: p = gamma + (1-gamma-lambda) * ( 1 + exp( -1* (x/alpha)^ beta ) )
% alpha = threshold parameter; 
% beta = slope/spread; 
% gamma = proportion correct at chance, e.g. 0.5 in 2afc experiments
% lambda ('lapse rate') - upper bound of psychometric function

% step 1, configure experiment parameters, e.g., 
par = staircase_exp_config();

% step 2, create a track object
uml = staircase_UML(par);

% step 3, create an experimental loop (one trial per loop), and update
% signal level using the update method.
% ntrials = p.series.lengthInStim;
ntrials = 50;

% p.catchTrialProbStaircase = .5 % to calculate percentage of catch trials

for i = 1:ntrials
    
    % present the stimulus and collect the observer's response r in in
    % terms of correct (1) or incorrect (0).
    
    %------------------------------------------------
    % your own function here, e.g., 
    % r = User_Function(uml.xnext);    
    % where x is the signal strength and r is the response in terms of
    % correctness.

    %------------------------------------------------
    
    % for simulated responses
    uml.setPhi0([80 1 0.1 0.05]);    %([5 2 0.5 0.05]);
    r = uml.simulateResponse(uml.xnext);
    % update the signal level
    uml.update(r);
end

% step 4, collect and save the results
% The easiest way to save the data from this track is simply save the 
% entire "uml" object.

% the parameter estimates are stored in
uml.phi;
% the signal strengths are stored in
uml.x;
% the responses (in terms of correctness) are stored in
uml.r;
% the sweet points are stored in
uml.swpts;
% the posterior parameter distribution (log probability) is stored in
uml.p;
% to visulize the posterior distribution, use
figure;
uml.plotP();
% to get the confidence limits (credible limits) for the parameter 
% estimates, use, e.g., 
uml.getConf([0.25 .5 .75])

% eof