function [] = cleanup(p)

Screen('CloseAll');
PsychPortAudio('Close');
KbQueueRelease();           
RestrictKeysForKbCheck([]);
ShowCursor;
Priority(0);
clear MEX;
if p.useEyelink
    Eyelink('Stoprecording');
    Eyelink('Closefile');
    Eyelink('Shutdown');
end  