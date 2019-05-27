function closeEyeLink(Params, fileName)
if Params.EyeLink
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    
    
    % download data file
    if exist('fileName','var')
        edfFile = fileName(1:end-2);
        try
            fprintf('Receiving data file ''%s''\n', edfFile);
            cd(['.\data\' Params.SubjectFolder '\']);
            status=Eyelink('ReceiveFile',edfFile);
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist([edfFile '.edf'], 'file')
                newFileName = [fileName '_' Params.experimentStart '.edf'];
                movefile([edfFile '.edf'],newFileName)
                fprintf('Data file ''%s'' can be found in ''%s''\n', newFileName, pwd );
            end
        catch
            fprintf('Problem receiving data file ''%s''\n', edfFile );
        end
        cd 'C:\Users\Display\Documents\Experiments\Yaniv\twoG_audvis1';
    end
    
    %close the eye tracker.
    Eyelink('ShutDown');
end
end
