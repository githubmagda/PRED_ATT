function[p] = EL_stopRecord(p, sr)    
%%% STOP RECORDING IF RECORDING 
    messageText = strcat('ENDFILE / STOPRECORD SERIES' num2str(sr.number));
    Eyelink('message',messageText) 
    Eyelink('Stoprecording');
    p.el.statusRecord = 0;
end