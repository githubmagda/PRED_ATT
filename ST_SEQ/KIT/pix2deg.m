function [p, deg] = pix2deg(p, pix)

% deg = pix2deg(p.scr, pix)
% converts monitor pixels into degrees of visual angle
% Uses average of X and Y pixels

% CM/PIX 
p.monitor.cmPerPix = p.monitor.cmX ./p.monitor.pixelX ;   % cm/pix for x-axis
p.monitor.cmPerPix = p.monitor.cmY ./ p.monitor.pixelY ;

% DEG/PIX
p.monitor.degPerCm = 360 /pi *tan( 1 /( 2 .*p.monitor.distance));
p.scr.degPerPix = p.monitor.cmPerPix .*p.monitor.degPerCm; 
deg = pix .* p.scr.degPerPix;

end

% FORMULA (alpha is angle in degrees ; s is size in centimeters; d is distance)
% pix2deg: alpha = 360deg/pi*tan(s/(2d))  <-> deg2pix: s = 2d*atan((pi*alpha)/360deg)
