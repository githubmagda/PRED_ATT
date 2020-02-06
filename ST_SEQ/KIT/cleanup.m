function cleanup(p)

Screen('CloseAll');
PsychPortAudio('Close');
KbQueueRelease(); 
ListenChar(2);
RestrictKeysForKbCheck([]);
ShowCursor;
Priority(0);
clear MEX;
cd(p.main_path);
if p.useEyelink
    Eyelink('Stoprecording');
    Eyelink('Closefile');
    Eyelink('Shutdown');
end  