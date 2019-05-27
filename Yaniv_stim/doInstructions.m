function response = doInstructions(Params, Trial)
% This function displays instructions and waits for keypress.
% Alternitively, if the field 'isAud' is present and set to 1, it just
% chimes and displays the message, waiting for keypress.

% Display message
if isfield('Trial','isAud') && Trial.isAud
    isVis = 0;
    load('breakChime.mat');
    WaitSecs(0.5);
    PsychPortAudio('FillBuffer',PlaySlave,TakeABreak');
    PsychPortAudio('Start', PlaySlave,[],[],1);                                           %Signal break
    disp(Trial.text);                           % for experimenter
else
    isVis = 1;
    Screen('Blendfunction', Params.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    DrawFormattedText(Params.w, Trial.text, 'center', 'center',[],[],[],[],2,...
        Trial.rtl);
    Screen('Flip',Params.w);
end

% Collect response
exitFlag = 0;
while exitFlag == 0
    WaitSecs(0.1);     % Prevent CPU overload
    [key_is_down,~,key_code,~] = KbCheck();                 %check for subject keypress
    if key_is_down
        if sum(key_code(Trial.contKey))
            response = find(key_code);
            break
        elseif key_code(Params.KeyEsc)
            sca;
            PsychPortAudio('Close',Params.pahandle);
            break;
        end
    end
end

KbReleaseWait;

% Draw fixation if visual
if isVis
    drawFixation(Params);
    Screen('Flip', Params.w);
end
end