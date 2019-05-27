function [ thisDotSeries ] = makeDotSeries( p, dotProb)

% Generates a simple series of length p.series.stimPerSeries and sets catch trials using random selection
% from distribution using range set in p.catchTrialNumSet % based on
% dotProb of staircase or main exp series

p.series.dotNumAv = floor( p.series.stimPerSeries * dotProb);
p.series.dotZeroPadding = 5;
% variation around catchTrialNum allowed
p.series.dotNumRange = [ p.series.dotNumAv-1 : p.series.dotNumAv+1 ]; % range of possible catch trials per series ( selected in makeCatchSeries.m )
% probability of dots in staircase procedure

dotSeries = zeros( 1, p.series.stimPerSeries - p.series.dotZeroPadding*2); % first and last elements added in last step
% use random selection from set of possible numbers of catch trials
pos = randi( length( p.series.dotNumRange));
numDots = p.series.dotNumRange( pos);
% use only even elements in order to avoid repetitions
dotTrials = 2 : 2 : length( dotSeries); % ensure catch trials are even numbers only to avoid consecutive catches
dotTrials = Shuffle( dotTrials); 
dotTrials = dotTrials( 1:numDots); % trim to numCatch
dotSeries( dotTrials) = 1; % add set elements to be the catch trials 
thisDotSeries = [ repmat(0,1,p.series.dotZeroPadding) , dotSeries, repmat(0,1,p.series.dotZeroPadding)];

   
    
end

