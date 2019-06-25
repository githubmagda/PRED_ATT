function[p] = EL_openFile(p, thisFileName, thisFileNumber)
% CREATE FILE IF EDF RECORD WANTED

if ( p.createFile == 1)
    
    if p.testEdf
        edfFileName = 'test.edf';
    else
    edfFileName = strcat( p.subjectFolder, thisFileName,'.edf' ); % name .edf datafile to receive from eyelink
    p.edfFileNameList{ thisFileNumber} = edfFileName;
    end
    % open new file
    p.statusFile = Eyelink('Openfile', edfFileName);
    Eyelink('Message', 'File_created: ', edfFileName);
    % messageText = strcat('SERIES_START_',num2str(sr.number));
    % Eyelink('Message', messageText);
    if p.statusFile ~= 0
        display( [ 'Cannot create EDF file', edfFileName]);
        cleanup;
        return;
    else display( ['File created! Yay! Series:', edfFileName]);
    end
end
end



% % % %     if createFile
% % % %        
% % % %         if nargin > 4 %% there is an 'other name'
% % % %             edfFile = strcat(otherName, p.edfPrefix, p.edfIdStr,'_',num2str(j),'.edf'); % name .edf datafile to receive from eyelink           
% % % %         else
% % % %             display(p.edfPrefix)
% % % %             edfFile = strcat(p.edfPrefix,  p.edfIdStr,'_', num2str(j),'.edf'); % name .edf datafile to receive from eyelink           
% % % %         end
% % % %         %% open new file
% % % %         statusFile = Eyelink('Openfile', edfFile);  
% % % %         Eyelink('Message', 'File_created');
% % % % % % %         message = strcat('BLOCK_START_',num2str(block));
% % % % % % %         Eyelink('Message', message);
% % % %         if statusFile ~= 0
% % % %             display('Cannot create EDF file', edfFile);
% % % %             cleanup;
% % % %             return;
% % % %         else display('File created! Yay!');
% % % %         end
% % % %     end
% % % % end
