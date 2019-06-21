function[p] = EL_closeFile(p, sr) 

    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    p.statusClose = Eyelink('CloseFile');
    
    if statusClose ~= 0
        disp('Cannot close EDF file');
        cleanup;
        return;
    else
        disp('File closed! Brava! Series', num2str(sr.number));
        p.statusFile = 1; % perversely 1 means NOT open
    end
    
    %% set offline so can transfer data
    Eyelink('Command', 'set_offline_mode');
    
    % download data file
    fileName = p.edfFileNameList{sr.number};
    
    if exist('fileName','var')
        
        edfFile = fileName(1:end-4); %% CHECK remove .edf extension
        
        try
            fprintf('Receiving data file ''%s''\n', edfFile);
            
            % cd p.subjectPathStr  %% CHECK problem with PC
            p.statusReceiveFile = Eyelink('ReceiveFile',edfFile);
            
            if status > 0
                fprintf('ReceiveFile status %d\n', p.el.statusReceiveFile);
            end
            
%             if 2==exist([edfFile '.edf'], 'file')
%                 newFileName = [fileName '_' Params.experimentStart '.edf'];
%                 %newFileName = [fileName '_' Params.experimentStart '.edf'];
%                 movefile([edfFile '.edf'],newFileName)
%                 fprintf('Data file ''%s'' can be found in ''%s''\n', newFileName, pwd );
%             end
            cd ..
            cd ..
        catch
            fprintf('Problem receiving data file ''%s''\n', edfFile );
        end
        %cd 'C:\Users\Display\Documents\Experiments\Yaniv\twoG_audvis1';
    end
    
    %close the eye tracker.
    Eyelink('ShutDown');
end