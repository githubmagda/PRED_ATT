function stimLevel = stimLevelRange (points, NLevels)
%% Generates a stimLevel range from four points
stimLevel=[];
for i=1:size(points,1)
    stimLevel = [stimLevel; logspace(log10(points(i,1)),log10(points(i,2)),NLevels)];
end
end