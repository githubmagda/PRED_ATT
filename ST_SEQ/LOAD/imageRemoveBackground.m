function [] = imageRemoveBackground( in, out) 

% name the input and output files
im_src = 'alphagoldStar.png';
im_out = 'goldStarUse.png';

% read in the source image (this gives an m * n * 3 array)
RGB_in = imread( im_src );
[m, n] = size( RGB_in(:,:,1) );

% locate the pixels whose RGB values are all 255 (white points ? --to be verified)
idx1 = ones(m, n);
idx2 = ones(m, n);
idx3 = ones(m, n);
idx1( RGB_in(:,:,1) == 1 ) = 0;
idx2( RGB_in(:,:,2) == 1 ) = 0;
idx3( RGB_in(:,:,3) == 1 ) = 0;

% write to a PNG file, 'Alpha' indicates the transparent parts
trans_val = idx1 .* idx2 .* idx3;
imwrite( RGB_in, im_out, 'png', 'Alpha', trans_val );

I = imread(im_out);




in                      = 'goldStar.png';

[RGBarray,map,alpha]    = imread(in); % if alpha channel is empty the next 2 lines add it

% create alpha channel
newName = strcat('alpha',in);
imwrite(RGBarray, newName, 'png', 'Alpha', ones(size(RGBarray,1),size(RGBarray,2)) )
[I,map,alpha]           = imread(newName);

ISmall = imresize(I, [150,NaN]);
alphaSmall = imresize(alpha,[150,NaN]);

% I2 = imcrop(I,[284.5 208.5 634 403]);
% alpha = imcrop(alpha,[284.5 208.5 634 403]);

newName = strcat('small',newName);
alphaSmall( all( ISmall==1, 3 ) ) = 128; 
imwrite(ISmall,newName,'alpha',alphaSmall);

A = imread(newName);
D = zeros( size(A(:,:,1)) );
D( all( A==1, 3 ) ) = 128; 
imwrite(A,'A11.png','alpha',D);

end


