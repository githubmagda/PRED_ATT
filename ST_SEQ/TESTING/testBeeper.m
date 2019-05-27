InitializePsychSound(1)

startTime = GetSecs;
timePassed = 0;
counter = 0;
while timePassed < 1
    Snd('Play',sin(18000:19000));
    Snd('Quiet');
    counter = counter+1;
    timePassed = GetSecs - startTime;
end
counter