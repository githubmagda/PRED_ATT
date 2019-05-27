
function [p, pix] = deg2pix(p, deg)
% pix = deg2pix(p.scr, deg = sizeof angle in degrees)
% provides pix/cm and visual angles in degrees to pixels for windowRect
% Uses average of X and Y pixels

% PIX/CM 
p.scr.pixPerCmX = round( p.scr.pixelsX ./ p.scr.cmX );   % cm/pix for x-axis
p.scr.pixPerCmY = round( p.scr.pixelsY ./ p.scr.cmY );   % cm/pix for y-axis 
p.scr.pixPerCmXY = round( mean ([ p.scr.pixPerCmX, p.scr.pixPerCmY ]));

% PIX/DEG
p.scr.cmPerDeg = 2*p.scr.monitorDist * atan( (pi * 1) ./ 360 );  
p.scr.pixPerDeg = round( p.scr.cmPerDeg .* p.scr.pixPerCmXY ); % can't have fraction of pixels
pix = deg * p.scr.pixPerDeg;

end

% FORMULA (alpha is angle in degrees ; s is size in centimeters)
% deg2pix: s = 2d * atan( (pi*alpha)/360deg )
% pix2deg: alpha = 360deg/pi*tan(s/(2d))  <-> deg2pix: s = 2d*atan((pi*alpha)/360deg)
