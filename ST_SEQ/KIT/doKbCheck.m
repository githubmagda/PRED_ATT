function[quitNow] = doKbCheck(p, numPress)

quitNow = 0;

% START KEYBOARD QUEUE 
KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
KbQueueStart();   %% KbQueueStart([deviceIndex])

press = 0; 

while press < numPress
   
    WaitSecs(0.01);
    %[~, keyCode, ~] = KbPressWait();  % [ keyIsDown,secs,keyCode]=PsychHID('KbCheck');  % 
    [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])            
    
    if  ~isempty(event)  && event.Pressed ==1
        
        key = event.Keycode;
        
        switch key
            case KbName('space') 
                press = press +1;
%             case p.quitKey
%                 quitNow = 1;
%                 return;
            case p.killKey
                cleanup(p)
                msg = 'Experiment aborted by operator';
                error(msg)
        end
        KbQueueRelease();   %KbQueueFlush([],3); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
        event = [];
    end    
end

WaitSecs(p.scr.waitBlank);
end

% % NOTES ON KBWAIT
% %   KbWait uses the PsychHID function, a general purpose function for
% %   reading from the Human Interface Device (HID) class of USB devices.
% %  
% %   KbWait tests the first USB-HID keyboard device by default. Optionally
% %   you can pass in a 'deviceNumber' to test a different keyboard if multiple
% %   keyboards are connected to your machine.  If deviceNumber is -1, all
% %   keyboard devices will be checked.  If deviceNumber is -2, all keypad
% %   devices (if any) will be checked. If deviceNumber is -3, all keyboard and
% %   keypad devices will be checked. The device numbers to be checked are
% %   determined only on the first call to the function.  If these numbers
% %   change, the function can be reset using "clear KbWait".
% %  
% %   As a little bonus, KbWait can also query other HID human input devices
% %   which have keys or buttons as if they were keyboards. If you pass in the
% %   deviceIndex of a mouse (GetMouseIndices will provide with them), it will
% %   treat mouse button state as keyboard state. Similar behaviour usually
% %   works with Joysticks, Gamepads and other input controllers.