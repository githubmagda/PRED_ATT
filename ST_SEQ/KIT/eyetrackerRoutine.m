
function[ p, result] =  eyetrackerRoutine(p, sr)

if nargin > 1
    % if a file is still open from previous recording, close it
    if p.el.statusFile == 0
        p.el.statusFile = EL_closeFile();
    end
    % open .edf file for new series
    thisFileName = strcat( sr.type, num2str( sr.number));
    EL_openFile(p, thisFileName, sr.number) % open and name file for this series
    
    % do calibration, save .edf file, (re)start eyetracker
    if sr.number == 1 % choose text to show 'first' or 'subsequent'
        calText = 'first';
    else
        calText = 'subsequent';
    end
    [p, result] = EL_calibration(p, calText);   %% CHECK 'main' vs. 'practice' or 'staircase'
    % Do last check of eye position (does NOT recalibrate)
    %EyelinkDoDriftCorrection(p.el);
    p.statusRecord = EL_startRecord(sr.number);
    
else % just a trial run
    [p, result] = EL_calibration(p);
    % EyelinkDoDriftCorrection(p.el);
end
end