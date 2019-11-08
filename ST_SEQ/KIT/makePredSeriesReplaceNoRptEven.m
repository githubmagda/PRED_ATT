function[result, trackerByElement, trackerByChunk] = makePredSeriesReplaceNoRptEven(p)
% makes a string including ordered/random chunks from a set of nElements 

% rename variables for ease of use within script (see test_makePredSeriesReplaceNoRptEven.m)
elements = p.series.seqBasicSet; % numbers to select from  % e.g. = 4
chunkLength = p.series.chunkLength;  % e.g. = 4
nRpt = p.series.chunkRpts; % how many times chunk will be repeated % e.g. = 5
numStim = p.series.stimPerSeries; % e.g. = 120

% get first elements
result = randperm(length(elements),2);
avoidEl = [result(end-1),result(end)]; % avoid repeating last 2 elements in substrings

% trackers - keeps track of # of elements / chunks in ordered sections
trackerByElement = zeros(1,numStim);
trackerByChunk = zeros(1,numStim);


% LOOP - build series from chunks inserting random chunk (size 1-2 chunks) between nRpts of ordered chunks;
while length(result) < numStim
       
    % start with random string of random length e.g. between 1 element to 2*chunk lengths
    lenRandomBit = randi( length( elements)*2, 1, 1 );
    randomBit = makeChunk( elements, lenRandomBit, avoidEl, 'random');  % makeChunk([elements, lengthChunk, );
    result = [result, randomBit];
    
    % next make ordered chunk and repeat nRpt times to create section
    avoidEl = [result(end-1),result(end)]; % avoid repeating last 2 elements in substrings
    nextChunk = makeChunk( elements, chunkLength, avoidEl, 'order');
    
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
    end % tracker loop to update tracker #chunks
    
    % add ORDERED chunk
    result = [result, nextSection];
end

% trim series
result = result( 1:numStim );           
trackerByElement = trackerByElement( 1:numStim );
trackerByChunk = trackerByChunk(  1:numStim );
end

function [thisChunk] = makeChunk(elements, len, avoidEl, type)
% make chunk: start off with one random number,  add till length='len'

% first part of chunk should not be same as last two elements of 'result' (avoidEl)  
selectFrom = elements;
selectFrom( avoidEl) = [];   
selectFrom = Shuffle( selectFrom);
thisChunk = selectFrom(1:2);       % starting 2 elements
elementCount = length(thisChunk);

firstEl = thisChunk( 1, 1); % store to ensure isn't same as last element in chunk for ordered sections

while elementCount < len
    
    avoidEl = thisChunk( end-1:end);
    selectFrom = elements;
    selectFrom( avoidEl) = [];
    selectFrom = Shuffle( selectFrom);
    nextElement = selectFrom(1);
    
    testChunk = [thisChunk, nextElement];
    lenTest = length(testChunk); % easier to name
    
    % ensure first and last element of chunk are not the same
    if strcmp( type, 'order') 
        
        % final test for possible repetitions of multiple elements e.g. 1-2-1-2 or 1-3-2-1-3-2
        if lenTest > 3 && mod( lenTest,2) == 0 % testChunk has even number of elements;
            
            if strcmp( num2str( testChunk( 1 : lenTest/2)), num2str( testChunk( lenTest/2+1 : lenTest)))
                %testElement = testChunk( 1,end);
                selectFrom( selectFrom == nextElement) = []; % remove problematic last element from set
                nextElement = selectFrom(1); % change nextElement
            end 
            
        end
        
        % ensure first and last elements of ordered chunk are not the same
        % (otherwise will result in repetitions)
        if ( lenTest - len) == 0 && ( firstEl == nextElement) % last element in ordered chunk and same first/last elements
            selectFrom( selectFrom == firstEl) = [];
            nextElement = selectFrom( 1); % change nextElement
        end
        
    end
    thisChunk = [thisChunk, nextElement];
    elementCount = elementCount +1;
end
end