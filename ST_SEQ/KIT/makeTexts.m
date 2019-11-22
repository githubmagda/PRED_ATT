function[exper, text2show] = makeTexts( exper, p, textName, sr)
% includes texts for the experiment ; texts are selected by 'textName' then displayed
% displayText

% defaults for showing images, main text presentation area
graphic             = 0;
textCenter          = 1;
police              = 0;
displayGrat         = 0;
displayDot          = 0;
displayQuestion     = 0;
localizer           = 0;
calibrationSuccess  = 0;

switch textName
    
    case 'Intro_1'
        exper.texts.Intro_1     = ['Welcome to the BCBL!!', '\n\n'];
        exper.texts.Intro_1     = [exper.texts.Intro_1, 'Let''s get going', '\n\n'];
        text2show               = exper.texts.Intro_1;
        %         thisImageName               = strcat('LOAD/star','.jpg');   % strcat('LOAD/star',num2str(imNum),'.jpg');
        %         graphic = 1;
        
    case 'Intro_2'
        exper.texts.Intro_2     = ['In this experiment you will need to keep your eyes ', '\n\n'];
        exper.texts.Intro_2     = [exper.texts.Intro_2, 'on the center of the fixation cross (shown below)'];
        
        % Draw  fixation cross without cue : dark cross two nested white gaussians
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        
        text2show               = exper.texts.Intro_2;
        textCenter              = 0;
        
    case 'Intro_3'
        exper.texts.Intro_3     = ['It''s not always easy','\n\n'];
        exper.texts.Intro_3     = [exper.texts.Intro_3,'because there''ll be many ''gratings'' on screen', '\n\n\n\n'];
        exper.texts.Intro_3     = [exper.texts.Intro_3, 'As you''re about to see...'];
           
        text2show               = exper.texts.Intro_3;
        displayGrat             = 1;
        numTimes                = 15;
        
    case 'Intro_3a'
        exper.texts.Intro_3a     = [];
        
    case 'Intro_4'
        exper.texts.Intro_4  = ['Your gaze will be monitored using an eyetracker', '\n\n'];
        exper.texts.Intro_4  = [exper.texts.Intro_4, 'Let’s calibrate it now!!', '\n\n\n\n'];
        exper.texts.Intro_4  = [exper.texts.Intro_4, 'Just look steadily at the center of each dot that appears', '\n\n'];
        exper.texts.Intro_4  = [exper.texts.Intro_4, 'Ready?'];
        
        text2show            = exper.texts.Intro_4;
        textCenter           = 0;
            
% %         if calibrationSuccess
% %             
% %             exper.texts.Intro_4a  = ['YBLABLA', '\n\n'];
% %             exper.texts.Intro_4a  = [exper.texts.Intro_4a, 'YBLABLA', '\n\n'];
% %             exper.texts.Intro_4a  = [exper.texts.Intro_4a, 'YBLABLA', '\n\n'];
% %             exper.texts.Intro_4a  = [exper.texts.Intro_4a, 'Ready?', '\n\n'];
% %             
% %             text2show            = exper.texts.Intro_4a;
% %         end      
        
    case 'Intro_5'
        exper.texts.Intro_5     = ['Now, the computer knows where you are looking!!', '\n\n\n\n'];
        exper.texts.Intro_5     = [exper.texts.Intro_5, 'During the experiment, if you fail to fixate the cross', '\n\n'];
        exper.texts.Intro_5     = [exper.texts.Intro_5, 'it will turn red', '\n\n'];
        exper.texts.Intro_5     = [exper.texts.Intro_5, 'and you will hear a beep', '\n\n'];
        exper.texts.Intro_5     = [exper.texts.Intro_5, 'When you fixate again, the cross will turn white. ', '\n\n\n\n'];
        exper.texts.Intro_5     = [exper.texts.Intro_5, 'Give it a try!!!', '\n\n'];
         
        text2show               = exper.texts.Intro_5;
        cue                     = 1;
        police                  = 1;
        textCenter              = 0;
        
    case 'Intro_6'
        exper.texts.Intro_6  = ['If you make even small head or body movements', '\n\n'];
        exper.texts.Intro_6  = [exper.texts.Intro_6, 'the eyetracker can lose track of your eyes'', '\n\n'];
        exper.texts.Intro_6  = [exper.texts.Intro_6, 'Then the cross will stay red even when you fixate', '\n\n'];
        exper.texts.Intro_6  = [exper.texts.Intro_6, 'and we''ll have to recalibrate', '\n\n\n\n'];
        exper.texts.Intro_6  = [exper.texts.Intro_6, 'The secret is to stay still: You make more money and save time!'];
        
        text2show = exper.texts.Intro_6 ;
               
    case 'Intro_7'
        exper.texts.Intro_7  = ['Now let’s collect some data!', '\n\n\'];
        exper.texts.Intro_7  = [exper.texts.Intro_7, 'This time, you just need to fixate the cross while gratings appear', '\n\n\n\n'];
        exper.texts.Intro_7  = [exper.texts.Intro_7, 'This sequence will take about 1 minute. Don’t get distracted - fixate!', '\n\n\n\n'];
        exper.texts.Intro_7  = [exper.texts.Intro_7, 'And keep still!!'];
        
        text2show            = exper.texts.Intro_7 ;
        displayGrat          = 1;
        numTimes             = 30;
        
    case 'Intro_8'
        exper.texts.Intro_8         = ['FANTASTIC!!', '\n\n'];       
        exper.texts.Intro_8         = [exper.texts.Intro_8, 'Now let''s try something a bit more interesting!!', '\n\n'];
        exper.texts.Intro_8         = [exper.texts.Intro_8, 'The green line on the cross will show you which grating to monitor', '\n\n'];
        exper.texts.Intro_8         = [exper.texts.Intro_8, 'If you see a dot on this grating, press XX ', '\n\n'];
        exper.texts.Intro_8         = [exper.texts.Intro_8, 'But if the dot appears elsewhere, do nothing', '\n\n'];
        exper.texts.Intro_8         = [exper.texts.Intro_8, 'The trick is to do this while ALWAYS fixating the cross!!', '\n\n\n\n'];
        exper.texts.Intro_8         = [exper.texts.Intro_8, 'Here''s a quick example...', '\n\n'];
        
        text2show = exper.texts.Intro_8 ;
        displayGrat           = 1;
        displayDot            = 1;
        numTimes              = 10;
        
    case 'Intro_9'

        exper.texts.Intro_9  = ['In the real experiment, there are fewer dots and they may be harder to see', '\n\n\'];
        exper.texts.Intro_9  = [exper.texts.Intro_9, 'But... every time you spot a dot on the correct grating, you earn 50 cents!', '\n\n\'];
        exper.texts.Intro_9  = [exper.texts.Intro_9, 'Yep! In this experiment, you can make up to €€€ extra !!!', '\n\n\\n\n\'];
        exper.texts.Intro_9  = [exper.texts.Intro_9, 'But careful! If you click for a dot on the wrong grating, you lose 50 cents', '\n\n\'];
        exper.texts.Intro_9  = [exper.texts.Intro_9, 'And if your eyes leave fixation, you will forfeit the sequence', '\n\n\'];
        exper.texts.Intro_9  = [exper.texts.Intro_9, 'Give it a try!!!', '\n\n\'];
        
        text2show            = exper.texts.Intro_9 ;
        displayGrat          = 1;
        displayDot           = 1;
        numTimes             = 60;
        
    case 'Intro_10'
        exper.texts.Intro_10  = ['Once and while, the sequence will stop. You need to say which grating will rotate next', '\n\n\'];
        exper.texts.Intro_10  = [exper.texts.Intro_10, 'Just guess! Don’t worry about being correct; this doesn’t affect your winnings', '\n\n\'];
        exper.texts.Intro_10  = [exper.texts.Intro_10, 'it''s just a diagnostic component of the experiment', '\n\n\'];
        exper.texts.Intro_10  = [exper.texts.Intro_10, 'Let''s give it a try now!!','\n\n\'];
        
        text2show            = exper.texts.Intro_9 ;
        displayGrat          = 1;
        displayDot           = 1;
        displayQuestion      = 1;
        numTimes             = 30;   
        
    case 'LR'
        exper.texts.localizer       = ['In the next series, there are no dots', '\n\n'];
        exper.texts.localizer       = ['But it''s very important', '\n\n'];
        exper.texts.localizer       = [exper.texts.localizer, 'So fixate  the cross!!', '\n\n'];
        
        text2show = exper.texts.localizer;
        
    case 'STR'
        exper.texts.staircase = ['I this series, there are quite a few dots', '\n\n'];
        exper.texts.staircase = [exper.texts.staircase,'Press XX as soon as you see a dot','\n\n'];
        exper.texts.staircase= [exper.texts.staircase, 'Remember: fixate the cross!!', '\n\n'];
        
        text2show = exper.texts.staircase;
        
    case 'intro'
        exper.texts.intro = ['In all of the next series, there will be dots. The red pointer shows the corner', '\n\n'];
        exper.texts.intro = [exper.texts.intro, 'you should attend', '\n\n\n\n'];
        exper.texts.intro = [exper.texts.intro, 'But ALWAYS keep your gaze at center!', '\n'];
        
        text2show = exper.texts.intro;
        
    case 'sr'
        exper.texts.main = ['Now the main experiment begins', '\n\n'];
        exper.texts.main = [exper.texts.main,'There are ',num2str(p.seriesNumber),' series', '\n\n\n\n'];
        exper.texts.main = [exper.texts.main,'Press the button quickly if you see a dot','\n\n'];
        exper.texts.main = [exper.texts.main,'But ALWAYS keep your gaze at CENTER','\n'];
        
        text2show = exper.texts.main;
        
    case 'nextSeries'
        exper.texts.nextSeries = ['Ready for another series?', '\n\n'];
        exper.texts.nextSeries = [exper.texts.nextSeries,'This is series ', num2str(sr.number), ' out of ', num2str(p.seriesNumber),'\n\n\n\n'];
        exper.texts.nextSeries = [exper.texts.nextSeries,'Press the button quickly if you see a dot','\n\n'];
        exper.texts.nextSeries = [exper.texts.nextSeries,'But ALWAYS keep your gaze at CENTER,'\n'];
        
        text2show = exper.texts.nextSeries;
        
    case 'calibrate'
        exper.texts.calibrate = ['Next we calibrate the eyetracker', '\n\n\n\n'];
        exper.texts.calibrate = [exper.texts.calibrate, 'Look at the center of each dot when it appears', '\n\n\'];
        exper.texts.calibrate = [exper.texts.calibrate, 'Keep looking at this dot right until the next one appears', '\n'];
        
        text2show = exper.texts.calibrate;
        
    case 'recalibrate'
        exper.texts.reCalibrate = ['Now we''re going to calibrate the eyetracker again', '\n\n'];
        exper.texts.reCalibrate = [exper.texts.reCalibrate, 'Look at the black center of each dot when it appears', '\n\n\'];
        exper.texts.reCalibrate = [exper.texts.reCalibrate, 'Keep looking till the next one appears', '\n'];
        
        text2show = exper.texts.reCalibrate;
        
    case 'endExperiment'
        exper.texts.endExperiment = [ 'Thanks, fantastic work! The experiment is done!' ];
        
        text2show = exper.texts.endExperiment;
end
% at bottom of all screens
exper.texts.nextScreen = [ 'Press the spacebar TWICE when you are ready to continue...' ];

%% DISPLAY TEXTS
Screen('TextSize',p.scr.window, p.scr.textSize);

if graphic
    %load image
    thisImage       = imread(thisImageName);
    % Make the image into a texture
    imageTexture    = Screen('MakeTexture', p.scr.window, thisImage);
    % Draw texture
    Screen('DrawTexture', p.scr.window, imageTexture, [], [], 0);
    % Draw  fixation cross without cue
    Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
end

if textCenter
    DrawFormattedText( p.scr.window, text2show, 'center', 'center', p.scr.textColor); %% , p.scr.textType
else
    DrawFormattedText( p.scr.window, text2show, 'center', p.scr.centerY-150, p.scr.textColor); %% , p.scr.textType
end

DrawFormattedText( p.scr.window, exper.texts.nextScreen, 'center', p.scr.basicSquare - 100, p.scr.textColor);

Screen('Flip',p.scr.window,0);

% ROUTINE TO SHOW GRATINGS / DOT
if displayGrat 
    
    WaitSecs(3.5);
    % make destination rects for gratings
    dstRectGrats        = OffsetRect( p.scr.sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet')';
    paramsGrats         = repmat([p.scr.phaseGrat, p.scr.freqGrat, p.scr.contrastGrat, 0], 4, 1)';
    angleSet            = [30,60,90,120];
    
    [ seriesPred,~,~]   = makePredSeriesReplaceNoRptEven(p);        %% SUB-SCRIPT
    [ dotSeries ]       = makeDotSeries( p, p.dot.probStaircase);    %% SUB-SCRIPT
    
    
    for ii = 1:numTimes
        
        thisDot = 0;    % reset
        
        if displayDot % just a variable to manage examples
            
            thisDot     = dotSeries(ii);
            
            if thisDot
                prob      = randi(10,1,1);
                if prob <= 8
                    select  = randi(20,1,1);
                    thisDotX            = p.dot.setX2( select);
                    thisDotY            = p.dot.setY2( select);
                    dstRectDot          = OffsetRect([0,0, p.scr.lenDot, p.scr.lenDot], thisDotX-p.dot.radius, thisDotY-p.dot.radius);
                else
                    select  = randi(20,1,1);
                    thisDotX            = p.dot.setX4( select);
                    thisDotY            = p.dot.setY4( select);
                    dstRectDot          = OffsetRect([0,0, p.scr.lenDot, p.scr.lenDot], thisDotX-p.dot.radius, thisDotY-p.dot.radius); 
                end
            end
            WaitSecs(0.2);
            
        elseif displayGrat
            WaitSecs(0.5);
        end
        
        thisGrat = seriesPred(ii);
        angleSet(thisGrat) = angleSet(thisGrat) + 60;
        
        Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
            [0,0,0,1], [], [], paramsGrats);
        
        % Draw fixation cross without cue
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        Screen('Flip',p.scr.window,0);
        
        if thisDot
            WaitSecs(0.1);
            Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
                [0,0,0,1], [], [], paramsGrats);
            Screen('DrawTexture', p.scr.window, p.scr.dotTex, [], dstRectDot, [], 1, 1, [0,0,0,1]); % [1,0,0, thisProbe], [], kPsychDontDoRotation, [1,15,1,1]');
            Screen('Flip',p.scr.window,0);
        end
    end
    
    DrawFormattedText( p.scr.window, exper.texts.nextScreen, 'center', p.scr.basicSquare - 100, p.scr.textColor);
    Screen('Flip',p.scr.window,0);
    
    if displayQuestion
        questionRoutine(p, sr, f, 1, angleSet) ; %1=useText
    end
    
    
    if p.useEyelink && police
        thisWaitTime = 15;
        monitorFixation(p, thisWaitTime);
    end
    
end

[quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT

if quitNow
    return;
end

end



