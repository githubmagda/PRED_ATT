function[] = screenBlank(p)
% projects a blank screen in the color set by Params.scr.background

    %% blank screen
    Screen('FillRect', p.scr.window, p.scr.background);
    Screen('Flip',p.scr.window, 0);
    WaitSecs(p.scr.waitBlank);
    %% end blank screen
    
end