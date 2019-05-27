%%
close all
clear all

[X1,Y1] = meshgrid(-5:0.01:5,-5:0.01:5);
[X2,Y2,Z2] = meshgrid(-5:0.01:5,-5:0.01:5,-15:0.1:15);

s = 2.75

A = randn(6,6,16);
Aint = interp3(-5:2:5,-5:2:5,-15:2:15,A,X2,Y2,Z2,'spline');

fig = figure('Position',[0 0 1000 500],'Renderer','zbuffer')

% v = VideoWriter('stim.avi');
% open(v);

for ii=1:size(Aint,3)
    ii
%     f = cos((1.5.*2*pi.*sqrt(X1.^2 + Y1.^2)) - (2.*pi/36*ii)) .* exp( -(((X1.^2)+(Y1.^2)) ./ (2* s^2)) );
    f = cos((1.5.*2*pi.*sqrt(X1.^2 + Y1.^2)) + (2.*pi/36*ii));
%     f2 = movepixels(f,15.*Aint(:,:,ii),15.*Aint(:,:,ii));
    [px,py] = gradient(Aint(:,:,ii),.01,.01);
    f2 = movepixels(f,25.*py,25.*py);

    subplot(1,2,1)
    imagesc(py);
    axis equal
    axis tight
    axis off
    subplot(1,2,2)
    imagesc(f2);
    axis equal
    axis tight
    axis off
    colormap('gray');
    fr(ii) = getframe(fig);
%     writeVideo(v,fr(ii));
pause(0.016)
end

close(v);

close all
[h, w, p] = size(fr(1).cdata);
hf = figure;
set(hf,'Position', [150 150 w h]);
axis off
movie(hf,fr,1,64,[0 0 0 0])

