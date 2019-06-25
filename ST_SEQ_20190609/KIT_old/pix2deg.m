function [p, deg] = pix2deg(p, pix)

% deg = pix2deg(p.scr, pix)
% converts monitor pixels into degrees of visual angle
% Uses average of X and Y pixels

% CM/PIX 
p.scr.cmPerPixX = p.scr.cmX ./ p.scr.pixelsX ;   % cm/pix for x-axis
p.scr.cmPerPixY = p.scr.cmY ./ p.scr.pixelsY ;   % cm/pix for y-axis 
p.scr.cmPerPixXY =  mean([ p.scr.cmPerPixX, p.scr.cmPerPixY ]);

% DEG/PIX
p.scr.degPerCm = 360/pi * tan( 1 / ( 2*p.scr.monitorDist ));
p.scr.degPerPix = p.scr.cmPerPixXY .* p.scr.degPerCm; 
deg = pix .* p.scr.degPerPix;

end

% FORMULA (alpha is angle in degrees ; s is size in centimeters)
% pix2deg: alpha = 360deg/pi*tan(s/(2d))
% pix2deg: alpha = 360deg/pi*tan(s/(2d))  <-> deg2pix: s = 2d*atan((pi*alpha)/360deg)
