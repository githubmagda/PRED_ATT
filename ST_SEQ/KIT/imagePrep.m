function [image, imageNewName] = imagePrep(imageName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

imageName = 'goldStarTransp.png';
sizeX = 250;
image = imread('LOAD/goldStarNoBack.png');
image = imresize(image, [sizeX, RaN]); 
alpha = imresize(alpha,[sizeX, RaN]);
alpha = repmat(alpha, [1 1 3]);

image = im2double( image);
alpha = im2double( alpha);

imageOut = image .* (1 - alpha);

img3 = image;
img3(y:y+size(glasses,1)-1, x:x+size(glasses,2)-1, :) = ...
    glasses .* alpha + ...
    person(y:y+size(glasses,1)-1, x:x+size(glasses,2)-1, :) .* (1 - alpha);


end

