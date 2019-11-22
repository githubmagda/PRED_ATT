
function [result, trackerByElement, trackerByChunk] = makePredSeriesReplace(p)
% makes a string of numbers from a set of elements using nElements without
% replacement

%%% rename for ease of use (see test3.m)
elements = p.series.seqBasicSet; % numbers to select from  % = 4
lenElements = length( elements);

chunkLength = p.series.chunkLength;  % = 3
nRpt = p.series.chunkRpts; % how many times chunk will be repeated % = 5
lengthInStim = p.series.lengthInStim;

%%%% LOOP
% build series from chunks inserting random chunk of size 1-2 chunks between nRpts of ordered chunks;
pos = randi( length( elements), 1, 1 );
selectEl = elements(pos);
result = [selectEl];

% trackers - keeps track of # of elements / chunks in ordered sections
trackerByElement = zeros(1,40); %zeros(1,p.series.lengthInStim);
trackerByChunk = zeros(1,40); %zeros(1,p.series.lengthInStim);

while length(result) < lengthInStim
    
    avoidEl = result(end); % avoid repeating last element in result string
    
    % add random string of random length e.g. 1-2 chunk lengths
    lenRandomBit = randi( length( elements)*2, 1, 1 );
    randomBit = makeChunk( elements, lenRandomBit, avoidEl);  % makeChunk([elements, lengthChunk, );
    result = [result, randomBit];
    avoidEl = result(end); % avoid repeating last element in result string
    
    % next add new  section and repeat nRpt times to create ordered section
    nextChunk = makeChunk(elements, chunkLength, avoidEl);
    nextSection = repmat( nextChunk, 1, nRpt );
    
    % tracker loop to update ordered section by #elements
    lenResult = length(result); % just easier to read!
    trackerByElement( ( lenResult + 1) : ( lenResult+( nRpt*chunkLength))) = 1:( nRpt*chunkLength);
    
    % tracker loop to update ordered section by #chunks
    counter = 1;
    for i = 1: nRpt
        chunkPos = lenResult + ( chunkLength*counter);
        trackerByChunk( chunkPos) = counter;
        counter = counter + 1;
    end
    % end tracker loop to update tracker #chunks
    
    % add chunk
    result = [result, nextSection];
end   
result = result( 1:lengthInStim );
trackerByElement = trackerByElement( 1:lengthInStim );
trackerByChunk = trackerByChunk(  1:lengthInStim );
end

function [nextChunk] = makeChunk(elements, len, avoidEl)
% make chunk: start off with one random number,  add till length='len'

% Get first element (~avoidEl)
selectFrom = Shuffle( find( elements ~= avoidEl ) );
nextChunk = selectFrom(1,1);
elementCount = 1;

while elementCount < len
    lastElement = nextChunk(1,end);
    selectFrom = Shuffle( find( elements ~= lastElement ) );
    nextElement = selectFrom(1,1);
    nextChunk = [nextChunk, nextElement];
    elementCount = elementCount +1;
end
end