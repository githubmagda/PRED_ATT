function[exper, text2show] = makeTexts( exper, p, textName, sr)
% includes texts for the experiment ; texts are selected by 'textName' then displayed
% displayText

switch textName
    
    case 'LR'
        exper.texts.localizer = ['You will see images in the corners', '\n\n'];
        exper.texts.localizer= [exper.texts.localizer, 'But ALWAYS keep your gaze at CENTER!', '\n\n'];
        
        text2show = exper.texts.localizer;
        
    case 'STR'
        exper.texts.staircase = ['You will see images in the corners', '\n\n'];
        exper.texts.staircase = [exper.texts.staircase,'Press the button quickly if you see a dot','\n\n'];            
        exper.texts.staircase= [exper.texts.staircase, 'But ALWAYS keep your gaze at CENTER!', '\n\n'];
    
        text2show = exper.texts.staircase;
        
    case 'intro'
        exper.texts.intro = ['The red pointer shows the corner', '\n\n'];
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
    DrawFormattedText(p.scr.window, text2show, 'center', 'center', p.scr.textColor); %% , p.scr.textType
    DrawFormattedText(p.scr.window, exper.texts.nextScreen, 'center', p.scr.basicSquare - 100, p.scr.textColor);
    
    Screen('Flip',p.scr.window,0);   
end



