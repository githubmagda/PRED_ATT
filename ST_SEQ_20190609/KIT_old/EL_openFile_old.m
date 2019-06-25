function[p] = EL_openFile(p, thisFileName, thisFileNumber)
% CREATE FILE IF EDF RECORD WANTED

if p.createFile
    
    if p.testEdf
        edfFileName = 'test.edf';
    else
        edfFileName = strcat( p.subjectFolder, thisFileName,'.edf' ); % name .edf datafile to receive from eyelink
        p.edfFileNameList{ thisFileNumber} = edfFileName;
    end
    
    % open new file
    p.statusFile = Eyelink('Openfile', edfFileName);
    Eyelink('Message', 'File_created: ', edfFileName);
    
    if p.statusFile ~= 0
        display( [ 'Cannot create EDF file', edfFileName]);
        cleanup;
        return;
    else display( ['File created! Yay! Series:', edfFileName]);
    end
end
end

