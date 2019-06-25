
function [result, tracker] = makePredSeriesNoReplace(p)
% makes a string of numbers from a set of elements using nElements without
% replacement
elements = p.series.seqBasicSet; % numbers to select from  % = 4
chunkLength = p.series.chunkLength;  % = 3
nRpt = p.series.chunkRpts; % how many times chunk will be repeated % = 5
nChunks = ceil(p.series.lengthInStim / chunkLength); % number of chunks per string, e.g. % 40

% tracker - keeps track of chunk repeats
tracker = zeros(1,p.series.lengthInStim);

% start off with random chunk 
startChunk = Shuffle( elements);
result = startChunk( 1:chunkLength);

chunkCount = 1;

while chunkCount < nChunks
   
    % make next chunk
    nextChunk = Shuffle( elements); % make new chunk
    nextChunk = nextChunk( 1:chunkLength);
    if( nextChunk(1) == result(end) ) % ensure the first element in chunk doesn't repeat last element in previous chunk
        nextChunk = fliplr( nextChunk );
    end
    
    % add new section or new random chunk
    if mod(chunkCount, (nRpt + 1) )  == 1 % time to insert another Section
        
        nextSection = repmat( nextChunk, 1, nRpt );
        
        % tracker loop to update tracker (for Question display after
        % #chunks
        thisTrial = length(result)+chunkLength;
        counter = 1;
        for i = 1: nRpt           
            tracker(thisTrial) = counter;
            counter = counter + 1;
            thisTrial = thisTrial + chunkLength;
        end
        % end update tracker
        
        result = [ result,nextSection ]; % add new Section of rptLength size
        chunkCount = chunkCount + nRpt;
               
    else
        result = [ result,nextChunk ]; % just add a random chunk
        chunkCount = chunkCount + 1;
    end  
end
result = result( 1:p.series.lengthInStim);
tracker = tracker( 1:p.series.lengthInStim);
end

% % TEST VERSION
% % nOptions = 4; % numbers to select from 
% % nElements = 3;
% % nRpt = 5; % how many times chunk will be repeated
% % nChunks = 40; % number of chunks per string
% % 
% % %initialize
% % result = [];
% % 
% % % start off with random chunk 
% % startChunk = randperm(nOptions);
% % startChunk = startChunk(1:nElements);
% % result(1,1:nElements) = startChunk;
% % 
% % chunkCount = 1;
% % 
% % while chunkCount < nChunks
% %    
% %     % make next chunk
% %     nextChunk = randperm(nOptions); % make new chunk
% %     nextChunk = nextChunk(1:nElements);
% %     if( nextChunk(1) == result(1,end) ) % ensure the first element in chunk doesn't repeat last element in previous chunk
% %         nextChunk = fliplr( nextChunk );
% %     end
% %     
% %     % add EITHER new section or new random chunk
% %     if mod(chunkCount, (nRpt + 1) )  == 1 % time to insert another Section
% %         nextSection = repmat( nextChunk, 1, nRpt );
% %         result = [ result,nextSection ]; % add new Section of rptLength size
% %         chunkCount = chunkCount + nRpt;
% %     else
% %         result = [ result,nextChunk ]; % just add a random chunk
% %         chunkCount = chunkCount + 1;
% %     end      
% % end


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