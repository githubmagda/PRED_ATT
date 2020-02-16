function[p, sr, vbl] = draw_fix(p, tex, sr)

% Draws quadrant gratings, dot, fixation

% % % gratings
% % Screen('DrawTextures', p.scr.window, tex.sine, [], p.grat.rects( sr.quads,:)', sr.angles( sr.quads), [], 0, ...
% %     [0,0,0,1], [], [], p.grat.params( :, sr.quads));
% % 
% % % dot
% % if dot
% % 
% %     randSelect = randi([ 1, size(sr.dot.set)], 1, 1);    
% %     dotPos = sr.dot.set(randSelect,:, cue);
% %     
% %     p.dot.rects    = CenterRectOnPointd(tex.sineRect, dotPos(1), dotPos(2));
% %     
% %     Screen('DrawTexture', p.scr.window, tex.dot, tex.dotRect, p.dot.rect)
% %     
% % % % end

% fixation
Screen('DrawTexture', p.scr.window, tex.fix); 

% flip
    [vbl] = Screen('Flip',p.scr.window,[],1);
    
% % cue
% if cue
%     crossPos = sprintf( 'p.scr.fixCoords%d', cue);
%     crossColor = sprintf( 'p.scr.attn%d', cue);
%     Screen('DrawLines', p.scr.window, crossPos, p.scr.fixCrossLineWidth, crossColor, [ p.scr.centerX, p.scr.centerY ], 2);
%     
%     % flip
%     [vbl] = Screen('Flip',p.scr.window,[],0);
% else
%     % flip
%     [vbl] = Screen('Flip',p.scr.window,[],0);
% end


% % REGULAR SERIES
% 
% if ~strcmp(sr.type, 'LR') %     staircase or main
%     
%     % determine x/y positions for red circle for question re predictions
%     p.circleXPosLeft    = p.scr.leftGrat; %= p.scr.centerX - ceil( p.scr.rectGrating(3)/2);   % - p.scr.gratPosPix/2; % size of quad minus 1/2 grating box minus
%     p.circleXPosRight   = p.scr.rightGrat; 
%     p.circleYPosTop     = p.scr.topGrat; 
%     p.circleYPosBottom  = p.scr.bottomGrat; 
%     
%     % Before animation loop show attentional-fixation cross indicates attn quadrant
%     % thisCue determines attentional pointer and probabilistic placement of attentional dot
%     pos = randi( length( p.series.seqBasicSet));        %
%     thisCue = p.series.seqBasicSet( pos);               % choose attn quadrant / cue
%     sr.thisCue = thisCue;  % save to series level
%     
%     % used to calculate dot position below
%     setOther = p.series.seqBasicSet; % set of possible cue and dot quadrants
%     setOther( setOther==thisCue) = [];  % remaining options when cue is invalid
%     
%     % initialize question - where will next flash appear?
%     sr.question.numCorrect = 0;
%     
%     switch thisCue
%         case 1
%             attn = p.scr.attn1;             % selects the fixation cue (arm of cross)
%             fixCoords = p.scr.fixCoords1;   % quad and length of fixation cue arms
%         case 2
%             attn = p.scr.attn2;
%             fixCoords = p.scr.fixCoords2;
%         case 3
%             attn = p.scr.attn3;
%             fixCoords = p.scr.fixCoords3;
%         case 4
%             attn = p.scr.attn4;
%             fixCoords = p.scr.fixCoords4;
%     end
% end
% 
% % DISPLAY SEQUENCE
% % initialize timing and response vectors
% sr.angle.series         = nan( p.series.stimPerSeries, 4);
% sr.time.trialEvents     = nan( p.series.stimPerSeries, 4);
% 
% sr.time.dotOn           = nan( 1, p.series.stimPerSeries ); 
% sr.time.dotOff          = nan( 1, p.series.stimPerSeries );  
% sr.dot.posX             = nan( 1, p.series.stimPerSeries );                % dot position and timing
% sr.dot.posY             = nan( 1, p.series.stimPerSeries );
% sr.dot.dstRectDot       = nan( p.series.stimPerSeries, 4);
% sr.dot.continues        = zeros( 1, p.series.stimPerSeries );
% sr.dot.valid            = zeros( 1, p.series.stimPerSeries );
% sr.dot.response         = zeros( 1, p.series.stimPerSeries );             % dot response
% sr.dot.responseAttn     = nan( 1, p.series.stimPerSeries );
% sr.dot.responseUNAttn   = nan( 1, p.series.stimPerSeries );
% sr.dot.checked          = nan( 1, p.series.stimPerSeries );
% sr.dot.FA               = nan( 1, p.series.stimPerSeries );
% sr.dot.missed           = nan( 1, p.series.stimPerSeries );
% sr.dot.responsekeyCode  = nan( 1, p.series.stimPerSeries );
% sr.dot.RT               = nan( 1, p.series.stimPerSeries );
% sr.dot.quad             = nan( 1, p.series.stimPerSeries );
% loopCounterTrack        = nan( p.series.stimPerSeries,4);
% 
% if strcmp(sr.type, 'sr')
%     
%     % set probe value
%     thisProbe = mean([p.scr.probeEstimate(:)]);
%     
%     %  question initialize
%     sr.question.responseQuad    = nan( 1, p.series.stimPerSeries );
%     sr.question.responseCorrect = nan( 1, p.series.stimPerSeries );
%     sr.question.RT              = nan( 1, p.series.stimPerSeries );
%     sr.question.chunkNum        = nan( 1, p.series.stimPerSeries );
%     sr.question.elementNum      = nan( 1, p.series.stimPerSeries );
%     
%     % SELECT QUESTION TRIALS % N.B. not trial with dot ??
%     dot = find( sr.dot.series == 1);
%     
%     % ensure last trial not included: find( sr.dot.series( 1:( length(sr.dot.series)-1)) == 1);
%     questionSet = find( sr.pred.trackerByChunk > 1);                    % number of elements in sequence already viewed
%     questionSet = Shuffle( setdiff( questionSet,dot));
%     thisQuestionSet = questionSet( 1:p.question.num);
% end
% 
% % STAIRCASE START
% if strcmp(sr.type, 'STR')
%     % INITIALIZE STAIRCASE (see MinExpEntStairDemo from Psychtoolbox)
%     % stair input
%     probeset    = .01 : .05 :1; % -15:0.5:15;       % set of possible probe values
%     meanset     = .01 : .05 :1; % -10:0.2:10;       % sampling of pses, doesn't have to be the same as probe set
%     slopeset    = [.05:.1:1].^2;                    % set of slopes, quad scale
%     lapse       = 0.05;                             % lapse/mistake rate
%     guess       = 0.50;                             % guess rate / minimum correct response rate (for detection expt: 1/num_alternative, 0 for discrimination expt)
%     
%     % STAIRCASE: general settings / test timing
%     %     ntrial              = length( sr.dot.series( sr.dot.series == 1));
%     %     sr.time.probeStart  = nan( 1, ntrial);
%     %     sr.time.probeEnd    = nan( 1, ntrial);
%     %     sr.time.probeDur    = nan( 1, ntrial);
%     
%     % STAIRCASE: Create staircase instance.
%     stair = MinExpEntStair('v2');
%     
%     % STAIRCASE:stair.init.
%     stair.set_use_lookup_table(true);
%     
%     % option: use logistic instead of default cumulative normal. best to call
%     % before stair.init
%     %stair('set_psychometric_func','logistic');
%     
%     % STAIRCASE: initialize
%     stair.init( probeset, meanset, slopeset, lapse, guess);
%     
%     % option: use a subset of all data for choosing the next probe
%     stair.toggle_use_resp_subset_prop( 5, .7);               % STAIRCASE: %( 10,.9);
%     
%     % STAIRCASE: set value for first probe based on probeset values
%     first_value = probeset( ( round( length( probeset) /2)*100)/100);   % STAIRCASE: MA set to mode of probeset
%     stair.set_first_value( first_value);  % STAIRCASE: stair.set_first_value(3);
%     
%     ktrial = 1; % set counter for dot probes
%     [thisProbe, ~, ~]  = stair.get_next_probe();            % thisProbe is the value that changes along the staircase
% end % STAIRCASE END
% 
% % START KEYBOARD QUEUE - reset below in trial loop
% KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
% KbQueueStart();   %% KbQueueStart([deviceIndex])
% 
% % FLIP blank screen for trial timing
% [vbl] = Screen('Flip', p.scr.window, 0);
% 
% % SERIES START MESSAGES
% if p.useEyelink
%     messageText = strcat('SERIES_START', num2str(sr.number));
%     Eyelink('message', messageText)
% end
% 
% sr.time.seriesStart = GetSecs;
% thisWaitTime = p.scr.stimDur; % preset for first trial (not a dot)
% validDotCount = 0;
% 
% for f = 1: p.series.stimPerSeries % number of times stimulus will be shown
%     
%     % SETUP
%     if ~(strcmp(sr.type, 'LR'))  % REGULAR OR STAIRCASE SERIES: set predictive gratings
%         
%         if sr.dot.series(f) == 1 % PREPARE DOT
%             
%             if ~sr.dot.continues(f) % if dot continues, don't override previous trial f+1 settings
%                 sr.time.dotOn(f) = dotOnset(f);
%                 sr.time.dotOff(f) = sr.time.dotOn(f) + p.dot.dur;
%                 
%                 % DOT POSITION - is  dot in attentional quad, 'VALID'?
%                 selEl = randi( 100, 1, 1);
%                 
%                 if selEl <= (p.dot.valid*100)
%                     sr.dot.valid(f) = 1;
%                     dotQuad = thisCue;
%                     validDotCount = validDotCount +1;
%                 else
%                     ShuffleSet = Shuffle(setOther);     % select next random position (not including cued position)
%                     dotQuad = ShuffleSet(1);            % random allocation to any other quad
%                 end
%                 
%                 switch dotQuad                              % xy coordinates for dot in specified quadrants 1:4
%                     case 1
%                         dotSetX = p.dot.setX1;
%                         dotSetY = p.dot.setY1;           % defines set of possible dot locations
%                     case 2
%                         dotSetX = p.dot.setX2;
%                         dotSetY = p.dot.setY2;
%                     case 3
%                         dotSetX = p.dot.setX3;
%                         dotSetY = p.dot.setY3;
%                     case 4
%                         dotSetX = p.dot.setX4;
%                         dotSetY = p.dot.setY4;
%                 end
%                 
%                 sr.dot.quad(f) = dotQuad;
%                 
%                 % DOT SPECS
%                 % get location of occasional dot using random selection wihtin
%                 % specified quadrant;then randomly choose pair of x,y coordinates
%                 % for dot from dotSets X,Y
%                 pos = randi( length(dotSetX), 1);
%                 thisDotX = round( dotSetX( pos));
%                 thisDotY = round( dotSetY( pos));
%                 sr.dot.posX(f) = thisDotX;
%                 sr.dot.posY(f) = thisDotY;
%                 
%                 % make dstRect and update params for dot and grats
%                 dstRectDot                  = OffsetRect([0,0, p.dot.len, p.dot.len], thisDotX-p.dot.radius, thisDotY-p.dot.radius);
%                 sr.dot.dstRectDot(f,:)      = dstRectDot;
%                 %         else % show in same place as last trial
%                 %             sr.dot.dstRectDot(f,:) = sr.dot.dstRectDot(f-1,:);
%             end
%         end % END DOT SETUP
%     end
%     
%     loopOn = 1;
%     loopCounter = 1;
%     checked = 0;
%     
%     while loopOn   % loop to control trial and dot appearance
%         
%         if ~(strcmp(sr.type, 'LR'))
%             
%             thisPred = sr.pred.series(f);
%             
%             if loopCounter == 1
%                 % predictive angle change
%                 angleSet(thisPred) = mod(angleSet(thisPred) + angleIncrement, 180);
%                 sr.angleSet(f,:) = angleSet;
%             end
%             
%             if sr.dot.series(f) == 1
%                 
%                 if sr.dot.continues(f) && loopCounter == 1       % continuing dot should start on first flip of next trial
%                     loopCounter = 2;          % skip first dotOff loop
%                 end
%                 
%                 %display(strcat('loop', num2str(loopCounter)))
%                 
%                 switch loopCounter % loop1 = noDot; loop2 = displayDot; loop3 = dotOff
%                     
%                     case 1
%                         thisWaitTime = sr.time.dotOn(f); % blank screen
%                         loopCounterTrack(f,loopCounter) = thisWaitTime;
%                         
%                     case 2
%                         % draw dot
%                         Screen('DrawTexture', p.scr.window, p.scr.dotTex, [], sr.dot.dstRectDot(f,:), [], 1, 1, [0,0,0,thisProbe]); % [1,0,0, thisProbe], [], kPsychDontDoRotation, [1,15,1,1]');
%                         %Screen('DrawTextures', p.scr.window, dotTex, [], dstRectDots', [], 1, 0.5, []); %, [], kPsychDontDoRotation, [1,15,1,1]');final estimates
%                         diff = sr.time.dotOff(f) - p.scr.stimDur;
%                         
%                         if  diff > 2*p.scr.flipInterval % dot continues on next trial
%                             
%                             % dot continues on next trial (reset variables for f+1)
%                             sr.dot.continues(f+1) = 1;
%                             sr.dot.series(f+1) = 1;
%                             if sr.dot.valid(f)
%                                 sr.dot.valid(f+1) = 1;
%                             end
%                             sr.time.dotOn(f+1) = p.scr.flipInterval;
%                             sr.time.dotOff(f+1) = diff;
%                             sr.dot.dstRectDot(f+1,:) = sr.dot.dstRectDot(f,:);
%                             
%                             thisWaitTime = p.scr.stimDur - sr.time.dotOn(f); % remaining time in trial
%                             loopCounterTrack(f,loopCounter) = thisWaitTime;
%                             loopOn = 0; % go directly to next trial
%                         
%                         elseif sr.dot.continues(f)
%                             thisWaitTime = sr.time.dotOff(f);                          
%                             loopCounterTrack(f,loopCounter) = thisWaitTime;
%                         else   
%                             % dot duration within trial
%                             thisWaitTime = p.dot.dur; %sr.time.dotOff(f)-sr.time.dotOn(f);
%                             loopCounterTrack(f,loopCounter) = thisWaitTime;
%                         end
%                         
%                     case 3
%                         thisWaitTime = p.scr.stimDur -sr.time.dotOff(f);
%                         loopCounterTrack(f,loopCounter) = thisWaitTime;
%                         loopOn = 0;
%                         loopCounter = 0;
%                 end
%                 loopCounter = loopCounter +1;
%             else
%                 thisWaitTime = p.scr.stimDur;
%                 loopOn = 0;     % don't repeat loop
%             end
%             
%             Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
%                 [0,0,0,1], [], [], paramsGrats);
%             
%         else % localizer LR
%             thisWaitTime = p.scr.stimDur;
%             Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats(:,sr.series(f)), angleSetLR(f), [], 0, ...
%                 [0,0,0,1], [], [], paramsGrats(:,sr.series( f)));
%             
%             loopCounter = 1; % loop unused - just to keep track of wait time
%             loopCounterTrack(f,1) = thisWaitTime;
%             loopOn = 0;
%         end
%         
%         % Draw  fixation cross without cue : dark cross two nested white gaussians
%         Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
%         
%         Screen('DrawingFinished', p.scr.window);
%         
%         % FLIP
%         oldVbl = vbl;
%         [vbl] = Screen('Flip', p.scr.window); %, vbl+thisWaitTime -(0.9 *p.scr.flipInterval));
%         sr.time.trialEvents(f, loopCounter) = vbl - oldVbl;
%         sr.time.trialEventsGetSecs(f, loopCounter) = GetSecs;
%         thisWaitTime = thisWaitTime-(0.9 *p.scr.flipInterval);
%         
%         % START POLICING FIXATION
%         if p.useEyelink == 1
%             
%             % send message EYETRACKER .edf file
%             if strcmp( sr.type, 'LR')
%                 messageText = strcat( sr.type, '_BL_', num2str(bl.number), '_LR_', num2str(sr.number), '_TRIALSTART');
%             elseif strcmp( sr.type, 'STR')
%                 messageText = strcat(sr.type, '_BL_', num2str(bl.number), '_STR_', num2str(sr.number),'_TRIALSTART_',num2str(f),'_PredQUAD_', num2str(thisPred), '_DotQUAD_', num2str(thisDot) );
%             else
%                 messageText = strcat(sr.type, '_BL_', num2str(bl.number), '_SR_', num2str(sr.number),'_TRIALSTART_',num2str(f),'_PredQUAD_', num2str(thisPred), '_DotQUAD_', num2str(thisDot) );
%             end
%             Eyelink('Message', messageText);
%             monitorFixation( p, sr, thisWaitTime);   %% CHECK
%         else
%             WaitSecs(thisWaitTime);
%         end
%         
%         if ~strcmp(sr.type, 'LR')  %check for dot response
%             
%             [event] = KbEventGet;  %%      [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(); %% KbQueueCheck([deviceIndex])
%             
%             if  f>2 && ~isempty(event)  && event.Keycode == KbName('space')   % && sr.dot.response(f-1)==0 && ~sr.dot.response(f-2)==0%f >= 2 && ~isempty(event) % event.Pressed == 1
%                 
%                 sr.dot.response(f) = 1;
%                 
%                 for tr = 0:p.dot.zeroPad
%                     
%                     if ~checked
%                         if sr.dot.series(f-tr)      % this trial had a dot
%                             if sr.dot.valid(f-tr)   % dot was in cued quad
%                                 sr.dot.responseAttn(f-tr) = 1;
%                                 checked = 1;
%                                 % play positive beep
%                                 if p.useAudio
%                                     PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepHappy);
%                                     PsychPortAudio('Start', p.audio.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
%                                     PsychPortAudio('Stop', p.audio.handle, 1);
%                                 end
%                             else
%                                 sr.dot.responseUNAttn(f-tr) = 1;
%                                 checked = 1;
%                                 % play positive beep
%                                 if p.useAudio
%                                     PsychPortAudio('FillBuffer', p.audio.handle, p.audio.beepWarn);
%                                     PsychPortAudio('Start', p.audio.handle, 1, 0, 1);  % startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
%                                     PsychPortAudio('Stop', p.audio.handle, 1);
%                                 end
%                             end
%                             
%                             % calculate response time
%                             if ~sr.dot.continues( f-tr)           % dot started and finished within same trial
%                                 sr.dot.RT( f) = event.Time - sr.time.trialEventsGetSecs( f-tr, 2); %sr.time.dotOn(f);
%                             else
%                                 sr.dot.RT( f) = event.Time - sr.time.trialEventsGetSecs( f-tr-1, 2); %sr.time.dotOn(f);
%                             end
%                         end
%                     end
%                     % if checked
%                     %     break;
%                     % end
%                 end
%                 if ~checked     % no dot found on current or last 2 trials
%                     sr.dot.FA(f) = 1;
%                 end
%                 checked = 0; % reset
%             end
%             
%             % clear old queue and start next one
%             KbQueueRelease();   %KbQueueFlush([],3); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
%             event = [];
%             KbQueueCreate();  %% PsychHID('KbQueueCreate', [deviceNumber][, keyFlags=all][, numValuators=0][, numSlots=10000][, flags=0][, windowHandle=0])
%             KbQueueStart();   %% KbQueueStart([deviceIndex])
%         end
%         
%         % PROBE ADJUST - check for response on trial f-2?
%         if strcmp(sr.type, 'STR')
%             
%             if f > 2 && sr.dot.series( f-2) == 1 % check if response/no response on trial n-1
%                 
%                 r = 0; % reset default response to zero
%                 
%                 if sr.dot.responseAttn( f-2) == 1
%                     r = 1;  % get response for staircase routine
%                 end
%                 
%                 stair.process_resp(r); % convert to logical type; process response
%                 
%                 %check timing of  next probe routine
%                 %sr.time.probeStart(f) = GetSecs; % just to check time of calculation
%                 [thisProbe,entexp,rot_i]  = stair.get_next_probe(); % get next probe to test  [thisProbe, entexp, ind]  = stair.get_next_probe();
%                 thisProbe
%                 %sr.time.probeEnd(f) = GetSecs;
%                 % sr.time.probeDur(f) = sr.time.probeEnd(f) - sr.time.probeStart(f);
%                 % fprintf('response: %d\n',r);
%                 % fprintf('%d, new sample point: %f\nexpect ent: %f\n', ...
%                 %   ktrial,thisProbe,entexp(rot_i));
%                 %
%             end
% 
%         end
%         
%         % QUESTION ROUTINE
%         if strcmp(sr.type, 'sr')
%             if uint8( any( thisQuestionSet == f)) % Question re 'next screen': uses Colored Ring
%                 
%                 [sr] = questionRoutine( p, sr, f, 0);  % (p, sr, f, useText=1)
%                 
% % %                 % possible next-screens
% % %                 rotationSet = 0:3;
% % %                 % initialize
% % %                 found = 0;
% % %                 rot_i = 0; % index for rotation
% % %                 
% % %                 % stop to signal upcoming question
% % %                 WaitSecs(0.7);
% % %                 
% % %                 while ~found
% % %                     
% % %                     circleTime = GetSecs;
% % %                     
% % %                     KbQueueCreate();
% % %                     KbQueueStart();
% % %                     
% % %                     % Draw  fixation cross without cue and Gratings
% % %                     Screen('DrawLines', p.scr.window, p.scr.fixCoords0, p.scr.fixCrossLineWidth, p.scr.attn0, [ p.scr.centerX, p.scr.centerY ], 2);
% % %                     Screen('DrawTextures', p.scr.window, p.scr.sineTex, p.scr.sineTexRect, dstRectGrats, angleSet, [], 0, ...
% % %                         [0,0,0,1], [], [], paramsGrats);
% % %                     
% % %                     % which quad should circle appear in - adjust thisRect
% % %                     thisQuad = mod( rot_i, length( rotationSet))+1;  % mod rotates but have to add +1 to avoid index of zero
% % %                     thisRect = dstRectGrats(:,thisQuad)';
% % %                     Screen('FrameOval', p.scr.window, [255,0,0], thisRect, 1.8,[]);
% % %                     
% % %                     Screen('Flip', p.scr.window);
% % %                     WaitSecs(0.3)   % IFF movie doesn't keep running
% % %                     %end % movie keeps running
% % %                     
% % %                     [event, ~] = KbEventGet( [], 0.001); % CHECK how to suppress output ([device], [wait time])
% % %                     if  ~isempty(event) && event.Pressed == 1 && found == 0 % there was a keyPress and this is the downPress
% % %                         
% % %                         if strcmp( KbName(event.Keycode), 'Return')
% % %                             
% % %                             sr.question.responseQuad(f) = thisQuad;
% % %                             sr.question.responseCorrect(f) = ( thisQuad == sr.pred.series(f-(p.series.chunkLength-1)) );
% % %                             
% % %                             if sr.question.responseCorrect(f) == 1
% % %                                 display('Correct');
% % %                             else
% % %                                 display('Not correct, Should be:');
% % %                                 sr.pred.series(f-(p.series.chunkLength-1))
% % %                             end
% % %                             
% % %                             sr.question.RT(f) = event.Time - circleTime; % minus stim onset
% % %                             sr.question.chunkNum(f) = sr.pred.trackerByChunk(f);
% % %                             sr.question.elementNum(f) = sr.pred.trackerByElement (f);
% % %                             found = 1; % get out of loop
% % %                             
% % %                         elseif strcmp( KbName(event.Keycode), 'space')
% % %                             rot_i = rot_i+1;
% % %                         end
% % %                         
% % %                         KbQueueStop();  % KbQueueStop([deviceIndex])   %[secs, keyCode, deltaSecs] = KbPressWait; % [secs, keyCode, deltaSecs] = KbPressWait([deviceNumber][, untilTime=inf][, more optional args for KbWait]);   % event = KbEventGet();
% % %                         KbEventFlush(); % nflushed = KbEventFlush([deviceIndex]) %%CHECK
% % %                         KbQueueFlush(); % nflushed = KbQueueFlush([deviceIndex][flushType=1])
% % %                     end
% % %                 end
%                 WaitSecs(1.0);
%             end  %% END QUESTION
%         end % end question routine
%     end
%     % SEND EYETRACKER MESSAGE
%     if p.useEyelink
%         messageText = strcat('SERIES_%d',sr.number, 'TRIALEND_%d', f);
%         Eyelink('message', messageText)
%     end
% end % end of trial f-loop
% 
% % record series times
% sr.time.seriesEnd = GetSecs;
% sr.time.seriesDur = sr.time.seriesEnd - sr.time.seriesStart;
% 
% loopCounterTrack(:,4) = nansum( loopCounterTrack(:,1:3),2);
% sr.time.trialEvents(:,4) = nansum(sr.time.trialEvents(:,1:3),2);
% 
% sr.time.trialStart = sr.time.trialEvents(:,1);
% sr.time.trialDur= sr.time.trialStart(2:end) - sr.time.trialStart(1:end-1);
% 
% % SEND EYETRACKER MESSAGE
% if p.useEyelink
%     messageText = strcat('SeriesEND_%d',sr.number);
%     Eyelink('message', messageText)
% end
% 
% % STAIRCASE: RESULTS
% if strcmp(sr.type, 'STR') % staircase
%     [sr.PSEfinal, sr.DLfinal, loglikfinal]  = stair.get_PSE_DL();
%     finalent                                = sum(-exp(loglikfinal(:)).*loglikfinal(:));
%     fprintf('final estimates:\nPSE: %f\nDL: %f\nent: %f\n',sr.PSEfinal, sr.DLfinal, finalent);
%     p.scr.thisProbe                         = sr.PSEfinal;   %thisProbe;
%     sr.staircase = stair;
% end
% 
% if ~strcmp(sr.type, 'LR') % staircase or main
%     
%     % CALCULATE Attn/UNAtnn clicks, misses, FAs for report
%     sr.dot.totalNum     = numel( sr.dot.series( sr.dot.series ==1));
%     sr.dot.validNum     = numel( sr.dot.valid(  sr.dot.valid ==1));
%     sr.dot.attnNum      = numel(sr.dot.responseAttn(sr.dot.responseAttn ==1)); %int8( (v1 + v2) > 0 );
%     sr.dot.UNAttnNum    = numel(sr.dot.responseUNAttn(sr.dot.responseUNAttn ==1)); %int8( (v1 + v2) > 0 );
%     sr.dot.FANum        = numel(sr.dot.FA(sr.dot.FA ==1));
%     sr.dot.missedNum    = sr.dot.validNum - sr.dot.attnNum;
%     
%     if sr.dot.attnNum > 0
%         sr.dot.attnRate = sr.dot.attnNum / sr.dot.validNum;
%     else
%         sr.dot.attnRate = 0;
%     end
%     sr.dot.win         = sr.dot.attnNum *p.dot.payout;                       % correct responses
%     sr.dot.lose        = (sr.dot.UNAttnNum + sr.dot.FANum) *p.dot.payout;    % incorrect responses
%     sr.dot.Payount     = ( (sr.dot.win+sr.dot.lose) *p.dot.payout);
% end
% 
% if strcmp( sr.type, 'sr')
%     % calculate question results
%     sr.question.numCorrect = length(find( sr.question.responseCorrect == 1));
%     sr.question.ratioCorrect = sr.question.numCorrect ./ numel(thisQuestionSet);
% end
% end
% 
