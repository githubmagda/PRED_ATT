function [ thisDotSeries ] = makeDotSeries( p )

% Generates a simple series of length p.series.stimPerSeries and sets catch trials using random selection
% from distribution using range set in p.catchTrialNumSet 

dotSeries = zeros( 1, p.series.stimPerSeries - 10 ); % first and last elements added in last step
% use random selection from set of possible numbers of catch trials
pos = randi( length( p.series.dotNumRange));
numDots = p.series.dotNumRange( pos);
% use only even elements in order to avoid repetitions
dotTrials = 2:2:length( dotSeries); % ensure catch trials are even numbers only to avoid consecutive catches
dotTrials = Shuffle( dotTrials); 
dotTrials = dotTrials( 1:numDots); % trim to numCatch
dotSeries( dotTrials) = 1; % add set elements to be the catch trials 
thisDotSeries = [ repmat(0,1,p.series.dotZeroPadding) , dotSeries, repmat(0,1,p.series.dotZeroPadding)];

   
    
end

