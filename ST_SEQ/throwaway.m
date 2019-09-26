switch loopCounter
                    case 1
                        thisWaitTime = sr.time.dotOn(f) -(0.5 *p.scr.flipInterval);
                        thisWaitTime
                    case 2
                        % draw dot
                        Screen('DrawTexture', p.scr.window, dotTex, [], dstRectDot, [], 1, 0.5, [.5,.5,.5, thisProbe]); %, [], kPsychDontDoRotation, [1,15,1,1]');
                        %Screen('DrawTextures', p.scr.window, dotTex, [], dstRectDots', [], 1, 0.5, []); %, [], kPsychDontDoRotation, [1,15,1,1]');
                        loopCounter
                        diff = sr.time.dotOff(f) - p.scr.stimDur;
                        diff
                        
                        if diff < ( 2*p.scr.flipInterval)
                            thisWaitTime = p.scr.dotDur -(0.5 *p.scr.flipInterval);
                            thisWaitTime
                            
                        else
                            sr.dot.series(f+1) = 1;
                            sr.time.dotOn(f+1) = 1;
                            sr.time.dotOff(f+1) =diff;
                            loopOn = 0; % go to next trial
                        end
                        
                    case 3
                        loopCounter
                        thisWaitTime = p.scr.stimDur -sr.time.dotOff(f) -(0.5 *p.scr.flipInterval);
                        loopOn = 0;
                        thisWaitTime
                end