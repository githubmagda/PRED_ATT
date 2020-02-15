function [ dotSeries ] = makeDotSeries( p, dotProb)

% Generates a simple series of length p.series.stimPerSeries and sets catch trials using random selection
% from distribution based on dotProb of staircase or main exp series

x                   = round(100./(p.dot.zeroPad+1)); % compensate for minimum zeros between dots
n                   = dotProb * 100; 
zeroPad             = zeros(1,p.dot.zeroPad);
dotSeries           = [zeroPad]; 

% dot loop
while length(dotSeries) < p.series.stimPerSeries    
    select          = randi( x,1,1);
    if select       <= n
        dotSeries   = [dotSeries,[1,0,0]];
    else
        dotSeries   = [dotSeries,0];
    end
end
% trim series
dotSeries           = dotSeries(1:p.series.stimPerSeries);
end

