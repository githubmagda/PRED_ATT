function performancePlot(Params, Logger, stimLevel)
[~, CountCorrect, OutOf, CatchProp]=computePFVectors(Params, Logger, stimLevel);
disp(CatchProp);

plot(stimLevel, CountCorrect./OutOf, '-x');
title('performance');
end