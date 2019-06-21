function[result, trackerByElement, trackerByChunk] = makePredSeriesReplaceNoRptEven(p)
% makes a string of numbers from a set of elements using nElements without
% replacement % this version checks to ensure even strings do not have repeating substrings, e.g. 1-2-1-2

%%% rename variables for ease of use within script (see test_makePredSeriesReplaceNoRptEven.m)
elements = p.series.seqBasicSet; % numbers to select from  % e.g. = 4
chunkLength = p.series.chunkLength;  % e.g. = 4
nRpt = p.series.chunkRpts; % how many times chunk will be repeated % e.g. = 5
lengthInStim = p.series.stimPerSeries; % e.g. = 120

%%%% LOOP - build series from chunks inserting random chunk (size 1-2 chunks) between nRpts of ordered chunks;

% get first element
pos = randi( length( elements), 1, 1 );
selectEl = elements(pos);
result = [selectEl];

% trackers - keeps track of # of elements / chunks in ordered sections
trackerByElement = zeros(1,40); %zeros(1,p.series.lengthInStim);
trackerByChunk = zeros(1,40); %zeros(1,p.series.lengthInStim);

while length(result) < lengthInStim
    
    avoidEl = result(end); % avoid repeating last element in substrings
    
    % start with random string of random length e.g. between 1 element -2 chunk lengths
    lenRandomBit = randi( length( elements)*2, 1, 1 );
    randomBit = makeChunk( elements, lenRandomBit, avoidEl, 'random');  % makeChunk([elements, lengthChunk, );
    result = [result, randomBit];
    
    % next make ordered chunk and repeat nRpt times to create section
    avoidEl = result(end); % avoid repeating last element in result string    
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
result = result( 1:lengthInStim );
trackerByElement = trackerByElement( 1:lengthInStim );
trackerByChunk = trackerByChunk(  1:lengthInStim );
end


function [thisChunk] = makeChunk(elements, len, avoidEl, type)
% make chunk: start off with one random number,  add till length='len'

% first element in chunk should not be same as last element of 'result' (avoidEl)  
selectFrom = Shuffle( elements( elements ~= avoidEl));
thisChunk = selectFrom(1, 1);
elementCount = 1;

firstEl = thisChunk( 1, 1); % store to ensure isn't same as last element in chunk for ordered sections

while elementCount < len
    
    avoidEl = thisChunk( 1, end);
    selectFrom = Shuffle( elements( elements ~= avoidEl));
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
        
        % ensure first and last elements of ordered chunck are not the same
        % (otherwise will result in repitions)
        if ( lenTest - len) == 0 && ( firstEl == nextElement) % last element in ordered chunk and same first/last elements
            selectFrom( selectFrom == firstEl) = [];
            nextElement = selectFrom( 1); % change nextElement
        end
        
    end
    thisChunk = [thisChunk, nextElement];
    elementCount = elementCount +1;
end
end