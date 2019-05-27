function [paramsValues, SD, plotHandle] = plotPF (stimLevels, CountCorrect, OutOf, lambda, NewFigure, sd)
SD = NaN;
if NewFigure
    figure;
else
    hold all;
end

searchGrid.alpha = log10(0:.001:1); %1:.001:1.95; 0.05:0.001:0.1;
searchGrid.beta = 10.^[-1:.01:2]; %logspace(1,3,100);
searchGrid.gamma = 0;  %0.5 scalar here (since fixed) but may be vector / stands for guessing
searchGrid.lambda = lambda;  %ditto, lapse

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter

%Fit a Logistic function
PF = @PAL_CumulativeNormal ;

%Optional:
options = PAL_minimize('options');   %type PAL_minimize('options','help') for help
options.TolFun = 1e-09;     %increase required precision on LL
options.MaxIter = 100;
options.Display = 'off';    %suppress fminsearch messages
lapseLimits = [0 1];        %limit range for lambda
%(will be ignored here since lambda is not a
%free parameter)

[paramsValues, LL, exitflag, output] = PAL_PFML_Fit(log10(stimLevels),CountCorrect, ...
    OutOf,searchGrid,paramsFree,PF,'searchOptions',options)

ProportionCorrectObserved=CountCorrect./OutOf;
StimLevelsFineGrain=[min(stimLevels):max(stimLevels)./1000:max(stimLevels)];
ProportionCorrectModel = PF(paramsValues,log10(StimLevelsFineGrain));

ObservedPlot = plot(stimLevels,ProportionCorrectObserved,'o');
lineColor = get(ObservedPlot, 'Color');
hold all;
set(gca, 'fontsize',12);
%set(gca, 'Xtick',stimLevels);
%axis([min(stimLevels) max(stimLevels) 0 1]);
plot(StimLevelsFineGrain,ProportionCorrectModel,['.-'] ,'linewidth',3, 'color',lineColor );

xlabel('target 1 - \rho');
ylabel('response: proportion detected ');

plotHandle = ObservedPlot;
if exist('sd','var') && sd
    B=400;
    SD = PAL_PFML_BootstrapNonParametric(...
    log10(stimLevels), CountCorrect, OutOf, [], paramsFree, B, PF,...
    'searchGrid',searchGrid);
end
end
