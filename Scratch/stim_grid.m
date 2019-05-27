clear all 
close all

% create grating

[X,Y] = meshgrid(-5:0.01:5,-5:0.01:5); % 1001 pixels

f = cos((1.*2*pi*sqrt(X.^2 + Y.^2)));

% find warp centers (3 x 3 grid)

cntrs = round(size(X,1)/3)/2:round(size(X,1)/3):size(X,1);
sz = 0.90 .* round(size(X,1)/3).*2; % 90% of maximum size

% Divide gamma so that one sweep (no warp to full to none) occurs in X frames

frms = 10; % Number of frames
steps = [0:(frms/2)-1 (frms/2)-1:-1:0];
steps = (steps./max(steps)).*60; % use negative 90 for a pinch instead of pull

fig = figure('Position',[0 0 1000 500],'Renderer','zbuffer');

for ii=1:frms % let's say these are frames for now
    [J,Tx,Ty] = PinchSpherize(f,steps(ii),250,-250,-250);
    imagesc(J)
    axis equal
    axis tight
%     axis off
    colormap('gray');
    fr(ii) = getframe(fig);
end

[h, w, p] = size(fr(1).cdata);
hf = figure;
set(hf,'Position', [150 150 w h]);
axis off
tic
movie(hf,fr,10,10,[0 0 0 0])
toc
