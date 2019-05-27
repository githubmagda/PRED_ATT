function[list] = pseudoRandListNoRpt(p)

elements = p.series.seqBasicSet; % 4
nElements = length(elements);
nRepeats = round(p.series.stimPerSeries / nElements); %  

list = Shuffle(elements);

for k = 1:nRepeats
    r = Shuffle(elements);
    if( r(1) == list(end) )
        r = fliplr(r);
    end
    list = [list, r];
end
list = list(1:p.series.stimPerSeries); % chop to size

%% TEST
% elements = [1,2,3,4];
% nElements = length(elements);
% nRepeats = 30;
% result = Shuffle(elements);
% 
% for k = 1:nRepeats-1
%     r = Shuffle(elements);
%     if( r(1) == result(end) )
%         r = fliplr(r);
%     end
%     result = [result, r];
% end
