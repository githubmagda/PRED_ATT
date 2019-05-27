function stimulus = mkEmptyVisStim(Params)
stimulus.visiblesize = 0;

nograting = Params.grey;
stimulus.gratingTex = Screen('MakeTexture', Params.w, nograting);
stimulus.dstRect=[0 0 1 1];

end