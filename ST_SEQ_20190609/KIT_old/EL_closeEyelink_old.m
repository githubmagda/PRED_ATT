function[p] = EL_closeFile(p, sr) 

    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    statusClose = Eyelink('CloseFile');
    
    if statusClose ~= 0
        display('Cannot close EDF file');
        cleanup;
        return;
    else
        display('File closed! Brava! Series'); display(num2str(sr.number));
        p.el.statusFile = 1; % perversely 1 means NOT open
    end
    
    %% download data file
    fileName = p.el.edfFileNameList{sr.number};
    if exist('fileName','var')
        edfFile = fileName(1:end-2);
        try
            fprintf('Receiving data file ''%s''\n', edfFile);
            cd(['.\data\' p.subjectFolder '\']);
            status=Eyelink('ReceiveFile',edfFile);
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist([edfFile '.edf'], 'file')
                newFileName = [fileName, '.edf'];
                %newFileName = [fileName '_' Params.experimentStart '.edf'];
                movefile([edfFile '.edf'],newFileName)
                fprintf('Data file ''%s'' can be found in ''%s''\n', newFileName, pwd );
            end
        catch
            fprintf('Problem receiving data file ''%s''\n', edfFile );
        end
        %%cd 'C:\Users\Display\Documents\Experiments\Yaniv\twoG_audvis1';
    end
    
    %close the eye tracker.
    Eyelink('ShutDown');
end