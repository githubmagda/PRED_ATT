function [ thisRandomSeries ] = makeRandomSeries( p )

% Generates a simple series of length p.series.lengthInStim and sets
% question trials according to p.series.questionNum ensuring that first X
% and last X trials are not questions

randomSeries = zeros( 1, p.series.lengthInStim - (p.series.seqBasicSetSize*4) ); % first and last elements added in last step
% use random selection for question trials p.series.questionNum
randElements = randi( length( randomSeries ) , 1, p.series.questionNum );
randomSeries(randElements) = 1; % add set elements to be the catch trials 
thisRandomSeries = [zeros(1, p.series.seqBasicSetSize*2) , randomSeries, zeros(1, p.series.seqBasicSetSize*2)];

end

% % TESTING
% % randomSeries = zeros( 1, 40 - (5*4) ); % first and last elements added in last step
% % randElements = randi( length( randomSeries ) , 1, 3 );
% % randomSeries(randElements) = 1; % add set elements to be the catch trials 
% % thisRandomSeries = [zeros(1, 5*2) , randomSeries, zeros(1, 5*2)];


