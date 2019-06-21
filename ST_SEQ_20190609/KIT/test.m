nOptions = 4; % numbers to select from 
nElements = 3;
nRpt = 5; % how many times chunk will be repeated
nChunks = 40; % number of chunks per string

%initialize
result = [];

% start off with random chunk 
startChunk = randperm(nOptions);
startChunk = startChunk(1:nElements);
result(1,1:nElements) = startChunk;

chunkCount = 1;

while chunkCount < nChunks
   
    % make next chunk
    nextChunk = randperm(nOptions); % make new chunk
    nextChunk = nextChunk(1:nElements);
    if( nextChunk(1) == result(1,end) ) % ensure the first element in chunk doesn't repeat last element in previous chunk
        nextChunk = fliplr( nextChunk );
    end
    
    % add EITHER new section or new random chunk
    if mod(chunkCount, (nRpt + 1) )  == 1 % time to insert another Section
        nextSection = repmat( nextChunk, 1, nRpt );
        result = [ result,nextSection ]; % add new Section of rptLength size
        chunkCount = chunkCount + nRpt;
    else
        result = [ result,nextChunk ]; % just add a random chunk
        chunkCount = chunkCount + 1;
    end      
end

%result

% % % for k = 1:nChunks-1
% % %     m = k * nQuads;
% % %     r = randperm(nOptions);
% % %     r = r(1:chunkLength);
% % %     if( r(1) == result(1,m) )
% % %         r = fliplr(r);
% % %     end
% % %     result(1,m+1:m+nOptions) = r;
% % % end
% % % result
