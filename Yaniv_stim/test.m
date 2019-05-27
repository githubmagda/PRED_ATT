function x = test()
x = 1;
try
    for i = 1:1000
        x = x+1;
        WaitSecs(1);
        
        if i == 5
            error('error');
        end
    end
catch
    return
end
end