function[] = test_kbchecking()


r=1;
while r <   4
    r = r+1;
    KbQueueCreate();
    KbQueueStart();
    display('hit ANY key');
    WaitSecs(2) 
    %     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
    %     keyIsDown;
    [event]= KbEventGet();

    event.Keycode
 end

end