function[statusRecord] = EL_startRecord(seriesNum)

%% START RECORDING
    Eyelink('StartRecording', 1, 1, 1, 1); %% Eyelink('StartRecording',[,file_samples, file_events, link_samples, link_events] )    
    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data
    WaitSecs(0.1); %% ??? From Yanik
    statusRecord = Eyelink('CheckRecording');
    if (statusRecord ~= 0)  %%  == -1
        display('Not recording!');
    return;
    end
    message = strcat(['START_RECORDING_SERIES', num2str(seriesNum)]);
    Eyelink('message',message)  
    display(message);
    WaitSecs(0.05);
    
end