%%
close all
clear all

[X,Y] = meshgrid(-5:0.01:5,-5:0.01:5);
s = 2.5
b = 0
% f = exp( -(((X.^2)+(Y.^2)) ./ (2* s^2)) );
% f = cos(3.*sqrt(X.^2 + Y.^2));
% f = exp(-(s.*(X.^2)-(2.*b.*((X.^2).*(Y.^2))) + s.*(Y.^2)));
t = -pi:(2.*pi/48):(pi-(2.*pi/24));

pos_x = round((rand(1,4)-0.5).*2.*size(X,1)/2);
pos_y = round((rand(1,4)-0.5).*2.*size(Y,1)/2);

pos_x = repmat(pos_x,[1 3]);
pos_y = repmat(pos_y,[1 3]);

grd = 1:(((size(pos_x,2))/size(t,2))/3):size(pos_x,2)-((size(pos_x,2))/size(t,2));
pos_x = interp1(1:size(pos_x,2)-1,pos_x(1:end-1),grd,'spline');
pos_y = interp1(1:size(pos_y,2)-1,pos_y(1:end-1),grd,'spline');

pos_x = pos_x((length(t)+1):(2*length(t)));
pos_y = pos_y((length(t)+1):(2*length(t)));

fig = figure('Position',[0 0 1000 500],'Renderer','zbuffer')
% hold on

fr(length(t)) = struct('cdata',[],'colormap',[]);

% f = cos((1.5.*2*pi.*sqrt(X.^2 + Y.^2)) - t(1)) .* exp( -(((X.^2)+(Y.^2)) ./ (2* s^2)) );
f = cos((1.5.*2*pi.*sqrt(X.^2 + Y.^2)) - t(1));

f = PinchSpherize(f,5,150,pos_x(1),pos_y(1));
subplot(1,2,1)
imagesc(f);
axis equal
axis tight
axis off
hold on
colormap('gray');
set(gca,'NextPlot','replaceChildren');

subplot(1,2,2)
imagesc(f);
axis equal
axis tight
axis off
hold on
colormap('gray');
set(gca,'NextPlot','replaceChildren');

fr(1) = getframe(fig);
for ii=2:length(t)
f = cos((1.5.*2*pi.*sqrt(X.^2 + Y.^2)) - t(ii)) .* exp( -(((X.^2)+(Y.^2)) ./ (2* s^2)) );
f = PinchSpherize(f,25,150,pos_x(ii),pos_y(ii));
subplot(1,2,1)
imagesc(f);
subplot(1,2,2)
imagesc(f);
% cl = gray(64);
fr(ii) = getframe(fig);
pause(0.016)
end
% surf(X,Y,f,'edgecolor','none');
% cl = gray(1024);
% colormap(cl)

close all
[h, w, p] = size(fr(1).cdata);
hf = figure; 
set(hf,'Position', [150 150 w h]);
axis off
movie(hf,fr,100,36,[0 0 0 0])
