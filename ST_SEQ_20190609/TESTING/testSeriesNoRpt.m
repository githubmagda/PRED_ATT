% TEST
elements = [1,2,3,4];
nElements = length(elements);
nRepeats = 30;
result = Shuffle(elements);

for k = 1:nRepeats-1
    %m = k * nElements;
    r = Shuffle(elements);
    if( r(1) == result(1,m) )
        r = fliplr(r);
    end
    result = [result, r];
end
result