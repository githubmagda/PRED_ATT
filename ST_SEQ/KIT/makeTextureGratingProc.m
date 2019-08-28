function [p] = makeTexturesProc(p)

% This script uses the faster procedural functions to maketextures for stimDisplay.m.
% Textures include the main textures for the four quadrant gratings a
% and gaussians for attentional dot guassian and  fixation gaussian.

% PROCEDURAL GRATING
[gratingTex, gratingRect]   = CreateProceduralSineGrating( p.scr.window, p.scr.gratGridPix, p.scr.gratGridPix, p.scr.backgroundColorOffsetGrat, p.scr.gratRadiusPix, p.scr.contrastPreMultiplicatorGrat );


end

