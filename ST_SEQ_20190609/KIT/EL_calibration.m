function[p] = EL_calibration(p, calibText) 
   
% present instructions
% if strcmp(calibText, 'first')
%     text=['Now we''ll do the first calibration:','\n\n'];
%     text=[text,'Look steadily at the CENTER of each dot on screen.','\n\n'];
%     text=[text,'waiting until the next dot appears.', '\n\n'];
%     
% elseif strcmp(calibText, 'subsequent')
%     text=['Next calibration:','\n\n'];
% end

% nextScreen = [ 'Press the spacebar TWICE when you are ready to continue...'];
% 
% Screen('TextSize', p.scr.window, p.scr.textSize);
% DrawFormattedText(p.scr.window, text, 'center','center'); %% ,p.scr.textColor, p.scr.textType);
% DrawFormattedText(p.scr.window, nextScreen, 'center', p.scr.basicSquare - 100, p.scr.textColor);

% Screen('Flip',p.scr.window);
% doKbCheck(p);

%screenBlank(p)

% Run Calibration
% % display('EL_calibration_line26')
% % p.el
result = EyelinkDoTrackerSetup(p.el);
result
screenBlank(p)
end


