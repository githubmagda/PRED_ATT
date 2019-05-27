function stimulus = mkVisGratingStim(Params,Stim)
% Builds a grating stimulus w/ contrast decrement target, recieves
% experiment paramters (Params)

% Allow global and local specification of target type
if isfield(Stim, 'visTargType')
    targType = Stim.visTargType;
else
    targType = Params.visTargType;
end

orien = deg2rad(-Stim.visStimOrientation);

SF = Params.gratingSF / angle2pix(Params.Display,1);    % Spatial frequency of grating in cycle per pixel units
angSF = 2*pi*SF;                   % SF in angular freq units, input to square()

if Stim.type == 1 && (strcmp(targType,'peripheral') || strcmp(targType,'central'))
    targLocPixGrat = angle2pix(Params.Display,Stim.visTargLoc - [0 Params.gratingEcc]); % Convert to pixels from grating center
    rotMat = [cos(orien) -sin(orien); sin(orien) cos(orien)]; % Counter rotation matrix
    targD = round(rotMat*targLocPixGrat');
end

stimulus.visiblesize = 2*angle2pix(Params.Display, Params.gratingSize)+1; % the square in which the stim appears
[x,y]=meshgrid(-1*angle2pix(Params.Display,Params.gratingSize):1*angle2pix(Params.Display,Params.gratingSize),-1*angle2pix(Params.Display,Params.gratingSize):1*angle2pix(Params.Display,Params.gratingSize));

inc=Params.white-Params.grey;
tsd = angle2pix(Params.Display,Params.visTargSize);

% Make grating
grating = Params.grey + inc*square(angSF*x)*Params.gratingContrast;
%grating = Gaussconvol2D(1, 5, grating);
grating(:, :, 2)=Params.white * ((x.^2 + y.^2 <= angle2pix(Params.Display,Params.gratingSize)^2));
stimulus.gratingTex = Screen('MakeTexture', Params.w, grating);

% Make target
if Stim.type==1
    cdTRGT = Params.grey + inc*square(angSF*x)*(1-Stim.visTargLevel); % Contrast decrement square wave
    if strcmp(targType,'peripheral')|| strcmp(targType,'central')
        cdTRGT(:, :, 2)=round(exp(-(((x-targD(1))/tsd).^2)-(((y-targD(2))/tsd).^2))*Params.white); % Gaussian mask
    elseif strcmp(targType, 'whole')
        cdTRGT(:, :, 2)=Params.white * ((x.^2 + y.^2 <= angle2pix(Params.Display,Params.gratingSize)^2)); % Just a circle
    end
    stimulus.targetTex=Screen('MakeTexture', Params.w, cdTRGT);
end

% Definition of the drawn rectangle on the screen:
stimulus.dstRect=[0 0 stimulus.visiblesize stimulus.visiblesize];
stimulus.dstRect=CenterRect(stimulus.dstRect, Params.screenRect); %screenRect is an output of Screen Window
stimulus.dstRect=OffsetRect(stimulus.dstRect, 0, angle2pix(Params.Display,Params.gratingEcc));

end