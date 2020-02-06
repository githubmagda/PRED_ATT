function[exper, text2show] = makeTexts( exper, p, textName, sr, calibrationResult)
% includes texts for the experiment ; texts are selected by 'textName' then displayed
% displayText

% defaults for showing images, main text presentation area
graphic             = 0;
textCenter          = 1;
police              = 0;
displayGrat         = 0;
localizer           = 0;
dotSequence         = 0;
thisDot             = 0;
displayQuestion     = 0;
calibrateMessage    = 0;
calibrationSuccess  = 0;
dotTimes            = Shuffle([ 50:1: 1000*( p.scr.stimDur-p.dot.dur)]) ./1000;

switch textName
    
    case 'welcome'
        
        if p.english == 1
            exper.texts.welcome     = ['Welcome to the BCBL!!', '\n\n'];
            exper.texts.welcome     = [exper.texts.welcome, 'Let''s get going', '\n\n'];
        else
            exper.texts.welcome     = ['Gracias por venir al BCBL', '\n\n'];
            exper.texts.welcome     = [exper.texts.welcome, 'Vamos a empezar!', '\n\n'];       
        end
            
        text2show               = exper.texts.welcome;
%         thisImageName           = strcat('LOAD/goldStarGreyBack','.png');   % strcat('LOAD/star',num2str(imNum),'.jpg');
%         graphic = 1;
        
    case 'cross_Intro'
        
        if p.english == 1
            exper.texts.cross_Intro     = ['In this experiment you will need to keep your eyes', '\n\n'];
            exper.texts.cross_Intro     = [exper.texts.cross_Intro, 'on the center of the fixation cross (shown below)'];
        else
            exper.texts.cross_Intro     = ['En este experimento deberás concentrarte en', '\n\n'];
            exper.texts.cross_Intro     = [exper.texts.cross_Intro, 'el centro de la cruz de fijación que ves abajo.'];            
        end
        
        % Draw  fixation cross without cue 
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        
        text2show               = exper.texts.cross_Intro;
        textCenter              = 0;
        
    case 'cross_Intro_2'
        
        if p.english == 1
            exper.texts.cross_Intro_2     = ['It''s not always easy to fixate the cross','\n\n'];
            exper.texts.cross_Intro_2     = [exper.texts.cross_Intro_2,'because there will be many ''gratings'' on screen', '\n\n\n\n' ];
            exper.texts.cross_Intro_2     = [exper.texts.cross_Intro_2, 'As you''re about to see now...'];
        else
            exper.texts.cross_Intro_2     = ['A veces no será tan fácil, ya que verás 4 objetos visuales,','\n\n']; 
            exper.texts.cross_Intro_2     = [exper.texts.cross_Intro_2, 'a los que llamaremos enrejados, como los que verás','\n\n\n\n' ];
            exper.texts.cross_Intro_2     = [exper.texts.cross_Intro_2, 'en la siguiente pantalla...' ];
        end
        
        text2show               = exper.texts.cross_Intro_2;
        textCenter = 0;
        
    case 'cross_Intro_ex'
        text2show = [];
        displayGrat             = 1;
        numTimes                = 15;
        
    case 'calibration_Intro'
        
        if p.english == 1
            exper.texts.calibration_Intro  = ['Your gaze will be monitored using an eyetracker', '\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, 'Let’s calibrate it now!!', '\n\n\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, 'Just look steadily at the center of each dot that appears', '\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, 'Ready?'];
        else
            exper.texts.calibration_Intro  = ['Para monitorizar tu pupila, vamos a utilizar', '\n\n']; 
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, 'una cámara de seguimiento ocular: el eyetracker!', '\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, '¡Vamos a calibrarlo!', '\n\n\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, 'Solo tienes que mirar fijamente','\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, 'en el centro de los puntos que aparezcan','\n\n\n\n'];
            exper.texts.calibration_Intro  = [exper.texts.calibration_Intro, '¿Preparado?','\n\n'];
        end
        
        text2show               = exper.texts.calibration_Intro;
        calibrateMessage        = 1;
        
    case 'calibration_result' 
        
        if p.useEyelink
            
            if calibrationResult == 0  % sent back from eyetracker?
               if p.english 
                   exper.texts.calibration_result  = ['FANTASTIC! The eyetracker is calibrated'];
               else
                exper.texts.calibration_result  = ['¡GENIAL! El eyetracker está calibrado'];
               end
            else
                if p.english
                    exper.texts.calibration_result  = ['Oops! That didn''t work', '\n\n'];
                    exper.texts.calibration_result  = [exper.texts.calibration_result, 'Let''s try again', '\n\n'];
                    exper.texts.calibration_result  = [exper.texts.calibration_result, 'Ready?', '\n\n'];
                else
                    exper.texts.calibration_result  = ['¡Ups! Algo no ha ido bien. Vamos a intentarlo otra vez!', '\n\n'];
                    exper.texts.calibration_result  = [exper.texts.calibration_result, '¿Preparado?'];
                end              
                text2show            = exper.texts.calibration_result;
            end
            
        else
            exper.texts.calibration_result = ['[Not using eyetracker]'];
        end
        text2show            = exper.texts.calibration_result;
    
    case 'police_Intro'
        
        if p.english == 1
            exper.texts.police_Intro     = ['Now, the computer knows where you are looking!!', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'During the experiment, if you fail to fixate the cross', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'it will turn red and you will hear a beep', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'When you fixate again, the cross will turn white', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'Give it a try!!!', '\n\n'];
        else
            exper.texts.police_Intro     = ['Ahora el ordenador ya sabe a dónde estás mirando!', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'Durante el experimento, la cruz se pondrá en rojo cuando', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'no consigas mirarla fijamente y oirás una alarma', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'Pero cuando lo hagas bien, la cruz se pondrá blanca', '\n\n'];
            exper.texts.police_Intro     = [exper.texts.police_Intro, 'Inténtalo!', '\n\n\n\n'];
        end
        
        text2show                    = exper.texts.police_Intro;
        
%          % Draw  fixation cross without cue 
%         Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
%        textCenter              = 0;
        
    case 'police_Intro_ex'
        
        text2show = [];  
        displayGrat             = 1;
        police                  = 1;
        numTimes                = 15;  
        
    case 'police_reminder'
        
        if p.english == 1
            exper.texts.police_reminder     = ['If you make even small head or body movements', '\n\n'];
            exper.texts.police_reminder     = [exper.texts.police_reminder, 'the eyetracker can lose track of your eyes', '\n\n'];
            exper.texts.police_reminder     = [exper.texts.police_reminder, 'Then the cross will stay red even when you fixate', '\n\n'];
            exper.texts.police_reminder     = [exper.texts.police_reminder, 'and we''ll have to recalibrate', '\n\n\n\n'];
            exper.texts.police_reminder     = [exper.texts.police_reminder, 'The secret is to stay still: You make more money and save time!'];
        else
            exper.texts.police_reminder     = ['El eyetracker es una cámara sensible a los movimientos de la cabeza y el cuerpo', '\n\n'];
            exper.texts.police_reminder     = [exper.texts.police_reminder, 'por lo que debes intentar permanecer lo más quieto posible'];
        end
        
        text2show = exper.texts.police_reminder ;
               
    case 'LR_Intro'
        
        if p.english == 1
            exper.texts.LR_Intro    = ['Now let''s practice...', '\n\n'];
            exper.texts.LR_Intro    = [exper.texts.LR_Intro, 'This time, just fixate the cross while gratings appear', '\n\n'];
            %exper.texts.LR_Intro  = [exper.texts.LR_Intro, 'This sequence will take about 2 minutes. Don’t get distracted - fixate!', '\n\n\n\n'];
            exper.texts.LR_Intro    = [exper.texts.LR_Intro, 'And keep still!!'];
        else
            exper.texts.LR_Intro    = ['Now let''s practice...', '\n\n'];
            exper.texts.LR_Intro    = [exper.texts.LR_Intro, 'Esta vez, solo tienes que mirar la cruz mientras aparecen los enrejados', '\n\n'];
            exper.texts.LR_Intro    = [exper.texts.LR_Intro, 'Está secuencia durará unos xxx minutos', '\n\n\n\n'];
            exper.texts.LR_Intro    = [exper.texts.LR_Intro, 'Intenta no distraerte y moverte lo menos posible!'];            
        end
        
        text2show               = exper.texts.LR_Intro ;
                 
    case 'LR_Intro_ex'
        exper.texts.LR_Intro_ex =[];
        text2show              = exper.texts.LR_Intro_ex ;
        localizerList          = pseudoRandListNoRpt(p);
        text2show              = [];
        
        displayGrat             = 1;
        localizer               = 1;
        numTimes                = 15;
        
    case 'LR'
        
         if p.english == 1
            exper.texts.LR    = ['Great! Now let''s collect some real data!!', '\n\n'];
            exper.texts.LR    = [exper.texts.LR, 'Again, just fixate the cross while gratings appear', '\n\n'];
            %exper.texts.LR  = [exper.texts.LR, 'This sequence will take about 2 minutes. Don’t get distracted - fixate!', '\n\n\n\n'];
            exper.texts.LR    = [exper.texts.LR, 'And keep as still as possible!!'];
        else
            exper.texts.LR    = ['Ahora, ¡vamos a recoger algunos datos REAL!', '\n\n'];
            exper.texts.LR    = [exper.texts.LR, 'AGAIN, solo tienes que mirar la cruz mientras aparecen los enrejados', '\n\n'];
            exper.texts.LR    = [exper.texts.LR, 'Está secuencia durará unos xxx minutos', '\n\n\n\n'];
            exper.texts.LR    = [exper.texts.LR, 'Intenta no distraerte y moverte lo menos posible!'];            
        end
        
        text2show               = exper.texts.LR;
            
    case 'staircase_Intro'
        if p.english == 1
            exper.texts.staircase_Intro         = ['FANTASTIC!!', '\n\n'];
            exper.texts.staircase_Intro         = [exper.texts.staircase_Intro, 'Now let''s try something a bit more interesting!!', '\n\n'];
            exper.texts.staircase_Intro         = [exper.texts.staircase_Intro, 'During the experiment, dots may appear in one of the gratings', '\n\n'];
            exper.texts.staircase_Intro         = [exper.texts.staircase_Intro, 'As you''ll see now'];
        else
            exper.texts.staircase_Intro         = ['Ahora vamos a probar algo más interesante!, '\n\n']; 
            exper.texts.staircase_Intro         = [exper.texts.staircase_Intro, 'Durante el experimento, puede que los puntos aparezcan aleatoriamente, '\n\n']; 
            exper.texts.staircase_Intro         = [exper.texts.staircase_Intro, 'dentro de los enrejados circulares. Mira este ejemplo...'];
            
        end
        
        text2show = exper.texts.staircase_Intro ; 
        
    case 'staircase_Intro_ex'
        
        exper.texts.staircase_Intro_ex = [];
        text2show = exper.texts.staircase_Intro_ex ; 
        textCenter = 0;
        
        % show one example of dot in grating
        thisDotX            = p.dot.setX2( 10);
        thisDotY            = p.dot.setY2( 10);
        dstRectDot          = OffsetRect([0,0, p.dot.len, p.dot.len], thisDotX-p.dot.radius, thisDotY-p.dot.radius);
        
        % make destination rects for gratings
        dstRectGrats        = OffsetRect( p.scr.sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet')';
        paramsGrats         = repmat([p.scr.phaseGrat, p.scr.freqGrat, p.scr.contrastGrat, 0], 4, 1)';
        angleSet            = [30,60,90,120];
        thisProbe           = randi(100,1,1) *.01;
        
        Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
            [0,0,0,1], [], [], paramsGrats);
        Screen('DrawTexture', p.scr.window, p.scr.dotTex, [], dstRectDot, [], 1, 1, [0,0,0,thisProbe]); % [1,0,0, thisProbe], [], kPsychDontDoRotation, [1,15,1,1]');

        % Draw fixation cross without cue
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);

    case 'staircase_Intro2'
        if p.english
            exper.texts.staircase_Intro2         = ['In the experiment, there will be only a few dots, and they can be hard to see', '\n\n'];           
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'One  arm of the cross will turn yellow', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'pointing towards the grating you should monitor', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'If you see a dot on any grating, press the space bar as fast as possible', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'The trick is to do this while ALWAYS fixating the cross!!', '\n\n\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'Here''s a quick example...'];         
        else
            exper.texts.staircase_Intro2         = ['En el experimento, estos puntos aparecerán muy brevemente', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'y puede ser difícil percibirlos', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'Cada vez que detectes uno de estos puntos, deberás responder con XXX lo más rápido posible.', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'Para ayudarte a encontrar estos puntos, el brazo amarillo de la cruz de fijación', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'apuntará al enrejado en el que probablemente aparezca el punto', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'Pon atención, esta pista no siempre será correcta!', '\n\n'];
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'Y recuerda, ¡intenta mantener SIEMPRE la mirada fija!', '\n\n'];  
            exper.texts.staircase_Intro2         = [exper.texts.staircase_Intro2, 'Vamos a ver un ejemplo....'];               
        end
        
        text2show = exper.texts.staircase_Intro2;
        
    case 'staircase_Intro2_ex'
        
        text2show               = [];
        displayGrat             = 1;
        dotSequence             = 1;
        police                  = 1;
        numTimes                = 30;

    case 'STR'

        if p.english
            
            if sr.number == 1
                exper.texts.str  = ['Now let''s collect some real data!', '\n\n']; 
                exper.texts.str  = [exper.texts.str, 'There will be few dots and they can be harder to see', '\n\n'];
                exper.texts.str  = [exper.texts.str, 'Remember... every time you spot a dot, you earn 50 cents!', '\n\n'];
                exper.texts.str  = [exper.texts.str, 'Yep! In this experiment, you can make up to €€€ extra !!!', '\n\n\n\n'];
                exper.texts.str  = [exper.texts.str, 'But careful! If you click when there''s no dot, you lose 50 cents', '\n\n'];
                exper.texts.str  = [exper.texts.str, 'And if your eyes leave fixation, you have to start all over again', '\n\n'];
                exper.texts.str  = [exper.texts.str, 'Good luck!!!', '\n\n'];
            else
                exper.texts.str  = ['You''re doing great! Let''s try another round'];
            end
            
        else % spanish
            if sr.number == 1
                exper.texts.str  = ['Add spanish text'];
            else
                exper.texts.str  = ['Add spanish text'];
            end   
        end
        
        text2show = exper.texts.str;
                
    case 'question_Intro'
        exper.texts.question_Intro  = ['Once and while, the sequence will stop','\n\n']; 
        exper.texts.question_Intro  = [exper.texts.question_Intro,'You need to choose which grating will move next', '\n\n'];
        exper.texts.question_Intro  = [exper.texts.question_Intro, 'Just guess!! Don’t worry about being correct', '\n\n'];
        exper.texts.question_Intro  = [exper.texts.question_Intro,'It won''t affect your winnings', '\n\n'];
        exper.texts.question_Intro  = [exper.texts.question_Intro, 'it''s just a diagnostic component of the experiment', '\n\n'];
        exper.texts.question_Intro  = [exper.texts.question_Intro, 'Let''s give it a try now!!','\n\n'];
   
        text2show                   = exper.texts.question_Intro ;
       
    case 'question_Intro_ex' 
        text2show                   = [];
        textCenter                  = 0;
        displayGrat                 = 1;
        dotSequence                 = 1;
        displayQuestion             = 1;
        numTimes                    = 30;
        
% %     case 'LR'
% %         exper.texts.localizer       = ['In the next series, there are no dots', '\n\n'];
% %         exper.texts.localizer       = ['But it''s very important', '\n\n'];
% %         exper.texts.localizer       = [exper.texts.localizer, 'Just fixate the cross!!', '\n\n'];
% %         
% %         text2show = exper.texts.localizer;
     
%     case 'STR'
%         exper.texts.staircase = ['In this sequence, you will need to monitor for  dots', '\n\n'];
%         exper.texts.staircase = ['everytime you see a dot, press the space bar', '\n\n'];
%         exper.texts.staircase = [exper.texts.staircase,'Give it a try!!', '\n\n'];
%         exper.texts.staircase = [exper.texts.staircase,'In this series, there are many dots','\n\n'];
% 
%         exper.texts.staircase = [exper.texts.staircase,'Press the spacebar as soon as you see a dot','\n\n'];
%         exper.texts.staircase= [exper.texts.staircase, 'Remember: Fixate the cross!!'];
%         
%         text2show = exper.texts.staircase;
        
    case 'intro'
        exper.texts.intro = ['In all of the next series, you need to monitor for dots', '\n\n'];
        exper.texts.intro = [exper.texts.intro, 'in the corner indicated by the yellow pointer', '\n\n'];      
        exper.texts.intro = [exper.texts.intro, 'At the end of each sequence, you''ll find out', '\n\n'];
        exper.texts.intro = [exper.texts.intro, 'how much money you won... or lost', '\n\n\n\n'];
        exper.texts.intro = [exper.texts.intro, 'But ALWAYS keep your gaze at center!'];
        
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


if calibrateMessage
    if p.english == 0
        exper.texts.nextScreen = [ 'Presiona XXX dos veces para EMPEZAR la calibración o YYY para volver atrás...'];        
    else
        exper.texts.nextScreen = [ 'Press XXX TWICE to start CALIBRATION or YYY to go back...' ];        
    end
else
    if p.english == 0
        exper.texts.nextScreen = [ 'Presiona XXX dos veces para continuar o YYY para volver atrás...'];
    else
        exper.texts.nextScreen = [ 'Press XXX TWICE to continue or YYY to go back...' ];
    end
end

% DISPLAY TEXTS
Screen('TextSize',p.scr.window, p.text.textSize);

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
    DrawFormattedText( p.scr.window, text2show, 'center', p.scr.centerY-100, p.scr.textColor); %% , p.scr.textType
end

% if ~displayGrat
%     DrawFormattedText( p.scr.window, exper.texts.nextScreen, 'center', p.scr.basicSquare - 20, p.scr.textColor);
% end
% 
% Screen('Flip',p.scr.window,0);

% ROUTINE TO SHOW GRATINGS / DOT
if displayGrat 
    
    WaitSecs(0.5);
    % make destination rects for gratings
    dstRectGrats        = OffsetRect( p.scr.sineTexRect, p.scr.offsetXSet', p.scr.offsetYSet')';
    paramsGrats         = repmat([p.scr.phaseGrat, p.scr.freqGrat, p.scr.contrastGrat, 0], 4, 1)';
    angleSet            = [30,60,90,120];
    
    [ seriesPred,~,~]   = makePredSeries(p);        %% SUB-SCRIPT
    %%[ seriesPred,~,~]   = makePredSeriesReplaceNoRptEven(p);        %% SUB-SCRIPT
    [ dotSeries ]       = makeDotSeries( p, .07);    %% SUB-SCRIPT
    
    if dotSequence
        Screen('DrawLines', p.scr.window, p.scr.fixCoords2, p.scr.fixCrossLineWidth, p.scr.attn2, [ p.scr.centerX, p.scr.centerY ], 2);
        Screen('Flip', p.scr.window, 0);
        WaitSecs(p.preSeriesFixTime);
    end
    
    for ii = 1:numTimes
        
        thisWaitTime = p.scr.stimDur; % default
        
        if dotSequence % sequence in which dot MAY appear (see thisDot)
            
            thisDot     = dotSeries(ii);
            
            if thisDot
                prob                    = randi(10,1,1);
                if prob <= 8
                    len                 = length(p.dot.setX2);
                    select              = randi(len,1,1);
                    thisDotX            = p.dot.setX2( select);
                    thisDotY            = p.dot.setY2( select);
                    dstRectDot          = OffsetRect([0,0, p.dot.len, p.dot.len], thisDotX-p.dot.radius, thisDotY-p.dot.radius);
                else
                    len                 = length(p.dot.setX2);
                    select              = randi(len,1,1);
                    thisDotX            = p.dot.setX4( select);
                    thisDotY            = p.dot.setY4( select);
                    dstRectDot          = OffsetRect([0,0, p.dot.len, p.dot.len], thisDotX-p.dot.radius, thisDotY-p.dot.radius); 
                end
                select                  = randi( length(dotTimes),1,1);
                thisWaitTime            = dotTimes(select);   % change from default
                dotOn                   = thisWaitTime;
            end 
        end

        if localizer % only draw one grating
            thisQuad = localizerList(ii);
            angleSet( thisQuad) = mod( angleSet(thisQuad) + 60, 180);
            Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats(:,thisQuad), angleSet(thisQuad), [], 0, ...
                [0,0,0,1], [], [], paramsGrats(:,thisQuad));
        else
            thisGrat = seriesPred(ii);
            angleSet(thisGrat) = mod( angleSet(thisGrat) + 60, 180);
            Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
                [0,0,0,1], [], [], paramsGrats);
        end
        
        % Draw fixation cross without cue
        Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
        Screen('Flip',p.scr.window,0);
        
        % police
        if police && p.useEyelink
            
            [thisErrorTime, totalFixTime, totalErrorTime] = monitorFixation(p, thisWaitTime);   
            if totalErrorTime >= p.maxPoliceErrorTime
                Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
                    [0,0,0,1], [], [], paramsGrats);
                % draw warning fixation
                Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attnWarning, [ p.scr.centerX, p.scr.centerY ], 2);
                Screen('Flip',p.scr.window,0);
            end
        else
            WaitSecs( thisWaitTime);
        end
            
        % add dot?
        if thisDot
            
            % draw dot
            thisWaitTime = p.dot.dur;            
            Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
                [0,0,0,1], [], [], paramsGrats);
            Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);

            Screen('DrawTexture', p.scr.window, p.scr.dotTex, [], dstRectDot, [], 1, 1, [0,0,0,1]); % [1,0,0, thisProbe], [], kPsychDontDoRotation, [1,15,1,1]');
            Screen('Flip',p.scr.window,0);
            WaitSecs( thisWaitTime);
            
            % draw plain screen
            Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...                
            [0,0,0,1], [], [], paramsGrats);
            Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
            thisWaitTime = p.scr.stimDur - p.dot.dur - dotOn;
            
            Screen('Flip',p.scr.window,0);
            WaitSecs( thisWaitTime);

        end
    end
    
    if displayQuestion
        sr = [];
        sr.angleSet = angleSet;
        questionRoutine(p, sr, ii, 1) ; %1=useText
    end
%   DrawFormattedText( p.scr.window, exper.texts.nextScreen, 'center', p.scr.basicSquare - 20, p.scr.textColor);
% Screen('Flip',p.scr.window,0);  
    
end
DrawFormattedText( p.scr.window, exper.texts.nextScreen, 'center', p.scr.basicSquare - 20, p.scr.textColor);
Screen('Flip',p.scr.window,0);

[quitNow] = doKbCheck( p, 2);  %% SUB-SCRIPT

if quitNow
    return;
end

end



