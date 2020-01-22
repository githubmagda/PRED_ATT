 function[] = taskFeedback(p, sr)
%% Report back on detection performance

win         = sr.dot.attnNum;                       % correct responses
lose        = (sr.dot.UNAttnNum + sr.dot.FANum);    % incorrect responses

text=['You got ', num2str(sr.dot.attnNum), ' out of ', num2str(sr.dot.validNum),'\n\n'];
text=[text,'You win ', num2str(win *p.dot.payout) ' euros ', '\n\n\n'];

if lose > 0
    if sr.dot.UNAttnNum > 1
        text=[text,'But you also clicked for ', num2str(sr.dot.UNAttnNum), ' dots in the wrong quadrant','\n\n'];
    end

    if sr.dot.FANum > 1
        text=[text,'And clicked ', num2str(sr.dot.FANum), ' times, when there was no dot!','\n\n'];
    end

    text=[text,'So you lose ', num2str(lose *p.dot.payout), ' euros','\n\n\n'];
    text=[text,'This series you made ', num2str((win-lose) *p.dot.payout), ' euros','\n\n\n\n\n'];
end

if  sr.dot.attnRate >= .80 && lose < 5   
    
    imNum = 1;
    text=[text,'Great work - keep it up!','\n\n\n'];
    
elseif sr.dot.attnRate >= .60 && lose < 5
    
    imNum = 2;
    text=[text,'Pretty good - but still room for improvement!','\n\n\n'];
    
elseif sr.dot.attnRate <= .60 || lose >= 5
    
    imNum = 3;
    text=[text,'Uffa! Better luck next round!','\n\n\n'];
    
end

text=[text,'Remember to respond quickly only to dots in the hot corner!','\n\n\n\n\n\n'];
textContinue=['Press any key TWICE when you are ready to continue...'];

p.scr.imageSizeXPix = 100; p.scr.imageSizeYPix = 100;

%% display image
thisImageName = strcat('LOAD/stickFigure',num2str(imNum),'.jpg');
showImage = imread(thisImageName);
texture = Screen('MakeTexture', p.scr.window, showImage,0,[], 0);
imageRect = CenterRectOnPoint([0, 0, p.scr.imageSizeXPix, p.scr.imageSizeYPix], p.scr.centerX, p.scr.centerY);
Screen('DrawTexture', p.scr.window, texture,[], imageRect,0,[],1);  %%% textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] [, specialFlags=0] [, floatprecision=0] [, textureOrientation=0] [, textureShader=0]);
Screen('Flip',p.scr.window, 0);
WaitSecs(2);

Screen('FillRect',p.scr.window,p.scr.background);
Screen('Flip',p.scr.window, 0);
Screen('TextSize', p.scr.window, p.scr.textSize );
DrawFormattedText( p.scr.window, text, 'center','center',p.scr.textColor);
DrawFormattedText( p.scr.window, textContinue, 'center',p.scr.basicSquare - 100,p.scr.textColor);

Screen('Flip', p.scr.window, 0);

KbWait; while KbCheck; end
KbWait; while KbCheck; end
Screen('FillRect', p.scr.window, p.scr.background);
Screen('Flip',p.scr.window, 0);