function [frame] = checkRT(p, sr, frame, displayTime) %%% CONTROL TIME BETWEEN EVENTS AND CHECK FOR RESPONSE during Stim Presentation
% called by stimDisplay.m



% diff = displayTime - GetSecs();
% diff
while GetSecs < displayTime

    [keyIsDown, secs, keyCode]= PsychHID('KbCheck'); % PsychHID('KbCheck', [], ptb_kbcheck_enabledKeys);
%   or  [keyIsDown, ResponseSecs, keyCode, deltaSecs] = KbCheck;   
%     if (keyCode(p.escapeKey) == 1)
%         break;
%     end
    
    if keyIsDown && frame.response == 0  % the subject has pressed a key but has not previously responded in this loop
        frame.response = 1;
        if sr.seriesDot(tr.number) == 1 || ( (tr.number > 1) && (sr.seriesDot(tr.number-1) == 1))
            play(p.snd.audioHappy,[1,10])      
        else
           play(p.snd.audioWarn,[1,100])
        end
        frame.RT = secs - frame.dotOnTime; % get time of response
        frame.RKey = KbName(find(keyCode, 1 ));
    end
    % if frame.response == 1; break; end % no point in continuing to loop if captured response
    %WaitSecs(p.scr.refreshRate * 0.001);  % fixes a glitch in the loop function - think this is no longer necessary    

end
FlushEvents('keyDown')  % FlushEvents(['mouseUp'],['mouseDown'],['keyDown'],['autoKey'],['update']
end


%while timePassed < RTWait
            
            %[keyIsDown, ResponseSecs, keyCode, ~] = PsychHID('KbCheck'); % PsychHID('KbCheck', [], ptb_kbcheck_enabledKeys);
            %[keyIsDown, ResponseSecs, keyCode, deltaSecs] = KbCheck;
            %     if (keyCode(p.escapeKey) == 1)
            %         break;
            %     end
            
            %                 if keyIsDown && tr.response == 0  % the subject has pressed a key but has not previously responded in this loop
            %                     %frame.response = 1;
            %                     tr.response = 1;
            %                     %                     if ~( sr.seriesDot(frame.number) == 1 || (frame.number >1) && (sr.seriesDot(frame.number-1) == 1))
            %                     %                         play(p.snd.audioWarn,[1,100])
            %                         break;
            %                     else
            %                         play(p.snd.audioHappy,[1,10]); break; end
            %                 end
            %
            %                     if sr.seriesDot(f) == 1 || (f>1 && sr.seriesDot(f-1)==1)
            %                         tr.RT = ResponseSecs - find(tr.dotOnTime>0,1);
            %                     %else
            %                     %    tr.RT = ResponseSecs - flip; % get time of response since first frame with dot
            %                     end
            %                     tr.RKey = KbName(find(keyCode, 1 ));
            %end
            %FlushEvents('keyDown')  % FlushEvents(['mouseUp'],['mouseDown'],['keyDown'],['autoKey'],['update']
            % timePassed = GetSecs - frameStart;
            %end % END INSERT

% for 4 sec wait time
% http://tech.groups.yahoo.com/group/psychtoolbox/message/9056
% % > answer = [];
% % > Screen('DrawTexture',whichscreen,wa2);
% % > tonset = Screen(whichscreen,'flip');
% % > FinP=tonset+(1/f)*round(4*f);
% % > while GetSecs<FinP
% % > if isempty(answer)
% % > [keyisdown,secs,keycode]= KbCheck;
% % > if keycode(Toucherep1) || keycode(Toucherep2)
% % > answer=KbName(min(find(keycode)));
% % > resptime = secs - tonset;
% % > end
% % > end
% % > end
% % >
% % > -> min(find... to disambiguate if subject
% % > manages to press multiple keys at the same time.
% % >
% % > -> Have a look at the timestamps returned and
% % > accepted by Screen('Flip') for more precise control
% % > of timing.
% % >
% % > -> secs from KbCheck is the best approximation
% % > to a response time you can get from the keyboard.
% % > Also interesting is help KbCheck for the optional
% % > 'deltaSecs' return argument.
% % >
% % > -> Keyboards are only good for coarse RT
% % > measurements, but we had this discussion
% % > already a couple of times on the forum...
% % >
