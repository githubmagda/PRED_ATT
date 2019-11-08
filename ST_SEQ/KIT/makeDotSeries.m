function [ dotSeries ] = makeDotSeries( p, dotProb)

% Generates a simple series of length p.series.stimPerSeries and sets catch trials using random selection
% from distribution based on dotProb of staircase or main exp series

%dotSeries = zeros( 1, p.series.stimPerSeries);

p.series.dotNumAv = floor( p.series.stimPerSeries * dotProb);

% small variation dotNumAv allowed
if p.series.dotNumAv > 3
    p.series.dotNumRange = [ p.series.dotNumAv-1 : p.series.dotNumAv+1 ]; % range of possible catch trials per series ( selected in makeCatchSeries.m )    
    % use random selection from set of possible numbers of catch trials
    pos = randi( length( p.series.dotNumRange));
    numDots = p.series.dotNumRange( pos);
else
    numDots = p.series.dotNumAv;
end

dotTrials =[];
n = dotProb*100;

% dot loop
while length(dotTrials) < p.series.stimPerSeries    
    select = randi(100,1,1);
    if select > n
        dotTrials = [dotTrials,[1,0,0]];
    else
        dotTrials = [dotTrials,0];
    end
end
end

% alternative spacing method
% % spread out to avoid repetitions within response time
% dotTrials = ( p.series.dotZeroPadding +1) : p.series.dotMinDist : (length( dotSeries) -(p.series.dotZeroPadding+1)) ; % ensure catch trials are not near neighbors
% dotTrials = Shuffle( dotTrials);        % to ensure spread across series
% dotTrials = dotTrials( 1:numDots);      % trim to numCatch
%dotSeries( dotTrials) = 1;              % add set elements to be the catch trials 
