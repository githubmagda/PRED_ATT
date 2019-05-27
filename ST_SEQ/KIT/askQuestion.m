
function [sr] = askQuestion( p, sr, f, useText)
% runs question routine, (p, sr, useText) useText is optional e.g. for first practice run

if useText
    
    textQuestion = [ 'Make a guess:' , '\n\n'];
    textQuestion = [ textQuestion, 'What will the next screen look like?' , '\n'];
    sr.question.textPre = textQuestion;
    moveForward = [ 'Press the spacebar TWICE when you are ready to continue...'];
    DrawFormattedText(p.scr.window, textQuestion, 'center', 'center', p.scr.textColor);
    DrawFormattedText(p.scr.window, moveForward, 'center', p.scr.basicSquare - 100, p.scr.textColor);
    Screen('Flip', p.scr.window);
    
    KbPressWait; KbPressWait;
    
    % display blank screen
    screenBlank(p);
end

% display 4 possible next-screens
rotationSet = [0,1,2,3];  % Shuffle([0,1,2,3]);

% initialize
found = 0;
i = sr.pred.series(f);

% stop to signal upcoming question
WaitSecs(0.7);

while ~found
    
    circleTime = GetSecs;
    thisRotation = rotationSet(i);
    thisQuad = rotationSet(i) + 1;
    leftX = or( thisQuad==1, thisQuad==4 );
    topY = thisQuad <= 2;
    
    if leftX
        circleXPos = p.circleXPosLeft; 
    else
        circleXPos = p.circleXPosRight; 
    end
    if topY
        circleYPos = p.circleYPosTop; 
    else
        circleYPos = p.circleYPosBottom;% - p.scr.gratPosPix/2;
    end
    
    KbQueueCreate();
    KbQueueStart();
    
    %for q = 1: p.scr.framesPerMovie % variation to keep movie running
    % if use Flash
    %     if q <= p.scr.predScreenDur
    %     Screen('DrawTexture', p.scr.window, texGratFlash(q),[],[],thisRotation * 90, [], [], []);
    % else
    %     Screen('DrawTexture', p.scr.window, texGrat(q),[],[],thisRotation * 90);
    Screen('DrawTexture', p.scr.window, p.textures.texGrat(1),[],[],thisRotation * 90);
    % DRAW fixation gaussian
    Screen('DrawTexture',p.scr.window, p.textures.gaus_fix_tex,[],[],[],[],[],p.scr.white)
    % Draw the cue fixation cross
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidthPix, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
    % Draw smaller center dot
    Screen('FillOval', p.scr.window, p.scr.white, [p.scr.centerX-p.scr.fixRadiusInner, p.scr.centerY-p.scr.fixRadiusInner, p.scr.centerX+p.scr.fixRadiusInner, p.scr.centerY+p.scr.fixRadiusInner],2.1*p.scr.fixRadiusInner );
    
    % end % if use Flash
    Screen('FrameOval', p.scr.window, [255,0,0], [circleXPos-p.scr.gratPosPix/2, circleYPos-p.scr.gratPosPix/2, circleXPos+p.scr.gratPosPix/2, circleYPos+p.scr.gratPosPix/2], 1.8,[]);
    
    if useText
        textInstructions = [ 'Use spacebar to move circle around; Use RETURN to select'];
        sr.question.textInstructions = textInstructions;
        
        Screen('TextSize',p.scr.window, p.scr.textSize);
        DrawFormattedText(p.scr.window, textInstructions, 'center', p.scr.basicSquare - 35, p.scr.textColor);
    end
    
    Screen('Flip', p.scr.window);
    WaitSecs(0.3)   % IFF movie doesn't keep running
    %end % movie keeps running
     
    [event, ~] = KbEventGet( [], 0.001); % CHECK how to suppress output ([device], [wait time])
    if  ~isempty(event) && event.Pressed == 1 % there was a keyPress and this is the downPress
        
        if strcmp( KbName(event.Keycode), 'Return')
            sr.question.responseQuad(f) = thisQuad;
            sr.question.responseCorrect(f) = ( thisQuad == sr.pred.series(f+1) );
            if sr.question.responseCorrect(f) == 1
                display('Correct');
            else
                display('Not correct, Should be:');
                sr.pred.series(f+1)
    
            end
            
            sr.question.RT(f) = event.Time - circleTime; % minus stim onset
            sr.question.chunkNum(f) = sr.pred.trackerByChunk(f);
            sr.question.elementNum(f) = sr.pred.trackerByElement (f);
            found = 1; % get out of loop
            
        elseif strcmp( KbName(event.Keycode), 'space')
            if i == numel(rotationSet)
                i = 1;
            else
                i = i+1;
            end
            
        end
        KbQueueStop();  % KbQueueStop([deviceIndex])   %[secs, keyCode, deltaSecs] = KbPressWait; % [secs, keyCode, deltaSecs] = KbPressWait([deviceNumber][, untilTime=inf][, more optional args for KbWait]);   % event = KbEventGet();
        KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
        KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
    end
% %     % add this question to series 'sr' structure
% %     questionName = sprintf('question%d', f);
% %     sr.(questionName) = question;
end

if useText
    % thanks screen
    textQuestion2 = [ 'Thanks for your guess!' , '\n\n'];
    sr.question.textPost = textQuestion2;
    moveForward = [ 'Press the spacebar TWICE when you are ready to continue...'];
    DrawFormattedText(p.scr.window, textQuestion2, 'center', 'center', p.scr.textColor);
    DrawFormattedText(p.scr.window, moveForward, 'center', p.scr.basicSquare - 100, p.scr.textColor);
    Screen('Flip', p.scr.window);
    
    KbPressWait; KbPressWait;
end
end % end question function