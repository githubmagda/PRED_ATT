function [p, sr] = makePredSeries(p, sr)
% creates a stimulus series of length, Params.series.lengthInStim, based on number of sequence repeats, Params.series.seqRepeats, 
%  based on a set of sequences in seqSet 
% Params.series.seqBasicSet with random strings inserted every 

%% create series
thisSeries = []; % intialize series to be built

% average random chunk size & pseudo-random jitter (average random chunk is
% set by randomStimTotal
p.series.randomStimTotalEl = p.series.chunkSize; %% use one chunks-worth for random elements
p.series.randomStimChunkNum = p.series.chunksPerSeries - 1;
p.series.randomChunkSize = p.series.randomStimTotalEl ./ p.series.seqRepeats;

% initialize using max possible randomChunkSize
%trial.series.randChunkList = zeros(Params.series.chunksPerSeries-1, Params.series.randomStimChunkNum * (Params.series.randomChunkSize + Params.series.randomChunkJitter +1));
sr.seqUsed = zeros(p.series.chunksPerSeries, size(sr.seqSet,2));

for ch_i = 1 : p.series.chunksPerSeries
    
    thisSeq = sr.seqSet( ch_i,:);
    sr.seqUsed( ch_i,: ) = thisSeq; % save seq details to block or series level (basic sequences used to make series)
    nextSeq = sr.seqSet( ch_i+1, : ); %used to ensure final random element insertion does not use first element of following chunk
    repSeq = repmat( thisSeq,1, p.series.seqRepeats ); % repeat basic seq 
    thisSeries = cat( 2,thisSeries,repSeq ); % build up series
    
    % prepare to add random chunks to n-1 chunks, adjusted by selection from randomChunkJitterSet    
    if ch_i <= (p.series.randomStimChunkNum)
        % set of jitters to be added to random chunks across series mean=0
        ser.randomChunkJitterSet = Shuffle( - p.series.randomChunkJitter : p.series.randomChunkJitter);
        randomJitter = ser.randomChunkJitterSet(ch_i);
        numRandEl = p.series.randomChunkSize + randomJitter;  % to be subtracted from previous string in series
        
        thisSeries = thisSeries(1 : ((length(thisSeries) - numRandEl)));
        
        % create random elements ensuring no repetitions
        randChunk = []; %initialize for randChunk
        % create set from which to draw random elements 
        tempSet = thisSeries(end-3:end-1); % exclude last element in series to avoid repetition in selection of first random element
        lengthV = 1; %initialize count of random elements
        
        while length(randChunk) < (numRandEl-1) % last element checked separately to not repeat; % will not add random segment to final sequences
            
            pos = randi(length(tempSet));
            selectEl = tempSet(pos);
            randChunk = cat(2,randChunk, selectEl);
            
            % create next element pool without repetition
            tempSet = p.series.seqBasicSet;
            tempSet = tempSet(tempSet ~= selectEl);
        end
        
        nextEl = nextSeq(1,1);
        tempSet = tempSet(tempSet ~= nextEl);
        pos = randi(length(tempSet));
        selectEl = tempSet(pos);
        randChunk = cat(2,randChunk, selectEl);
        
        % add random chunk to end of series 
        thisSeries  = cat(2,thisSeries,randChunk); % add randChunk to series
    end         
end
sr.predSeries = thisSeries;
sr.seqUsed
end
