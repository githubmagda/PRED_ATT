%% Plot the PF function of the four blocks and do model comparison
clear
close all
addpath('..\Code'); % gain access to exp. code scripts
addpath('..\palamedes1_8_1\Palamedes\');  %add palamedes to path

% Load files
blocks = [];
bl = 1;

while bl < 3
    [FileName,PathName,FilterIndex] = uigetfile('../Code/data/*.mat', 'Select parameter file from previous session');
    load([PathName FileName]);
    
    blocks(bl).name = input('Block name? ','s');
    blocks(bl).Logger = Logger;
    blocks(bl).Params = Params;
    blocks(bl).type = input('Is this a 1 - visual block, 0 - auditory block? ');
    
    bl = bl+1;
end

figure(1); hold all;
for bl = 1:length(blocks)
    switch blocks(bl).type
        case 0
            blocks(bl).stimLevels = blocks(bl).Params.audTargLevel;
            blocks(bl).units = '1 - \rho';
        case 1
            blocks(bl).stimLevels = blocks(bl).Params.visTargLevel;
            blocks(bl).units = 'contrast';
    end
    
    % Plot RT histogram in order to set Params.CutOffRange
    RTHistogram(Params, Logger);
    blocks(bl).Params.RTCutoff = inputdlg({'Lower bound','Upper bound'},...
        ['Input RT cutoff range for' blocks(bl).name],1);
     blocks(bl).Params.RTCutoff = [str2double(blocks(bl).Params.RTCutoff{1})...
         str2double(blocks(bl).Params.RTCutoff{2})];
     
     % Extract PF vectors from data logger
    [blocks(bl).Logger, blocks(bl).CountCorrect, blocks(bl).OutOf, blocks(bl).CatchProp]=computePFVectors(blocks(bl).Params, blocks(bl).Logger, blocks(bl).stimLevels);
    
    % Plot
    figure(1);
    [blocks(bl).PFparams, blocks(bl).SD, blocks(bl).plotHandle] = ...
        plotPF(blocks(bl).stimLevels, blocks(bl).CountCorrect(1,:), ...
        blocks(bl).OutOf(1,:), .01,0,1);
end
title([blocks(1).Params.subjID, ' PF functions for ', blocks(1).name, ' and ', blocks(2).name]);
xlabel(['Stimulus level (' blocks(1).units ')']);
ylabel('Proportion correct');
legend(blocks(1).name, '', blocks(2).name, '')

% Plot error bars
axes('Position',[.6 .2 .2 .25])
box on; hold all;
for bl = 1:2
    lineColor = get(blocks(bl).plotHandle, 'Color');
    errorbar(bl ,blocks(bl).PFparams(1), blocks(bl).SD(1),'d', 'color', lineColor);
end
ylabel('Thresholds (logscale)');
set(gca, 'XTickLabel','');

% Perform model comparison
StimLevels = log10([blocks(1).stimLevels; blocks(2).stimLevels]);
NumPos = [blocks(1).CountCorrect(1,:); blocks(2).CountCorrect(1,:)];
OutOfNum = [blocks(1).OutOf(1,:); blocks(2).OutOf(1,:)];
B = 1000;
PF = @PAL_CumulativeNormal;
params = [blocks(1).PFparams; blocks(2).PFparams];

[TLR, pTLR, paramsL, paramsF] =  PAL_PFLR_ModelComparison (StimLevels, NumPos, ... 
    OutOfNum, params, B, PF, 'lesserSlopes', 'unconstrained'); 
title(['TLR = ' num2str(TLR,'%0.2f') '; p = ' num2str(pTLR,'%0.3f')]);