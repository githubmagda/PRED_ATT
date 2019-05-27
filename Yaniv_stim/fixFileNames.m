a = ls();

for i = 3:size(a,1)
    if findstr('.m.txt', a(i,:))
        movefile(a(i,:),strrep(a(i,:),'.txt',''));
    end
end