function [Params] = makeDirectory(Params)
%This makes a global directory for all participants using directoryName and a sub directory for
%each participant using id number as a name, e.g. Output_idNumStr. It ensures that no existing directory will be
%overwritten.

if IsOSX
    Params.dataPath = [Params.main_path,'/',Params.directoryName];
else
    Params.dataPath = [Params.main_path,'\',Params.directoryName];
end

if isdir(Params.dataPath)   %isdir(Params.directoryName)
    cd(Params.dataPath);
else
    mkdir(Params.dataPath); %%%([Params.m_path,directoryName]);
    cd(Params.directoryName)
end


%% check this subject directory does not already exist to avoid overwriting
newName = 0;  %%% initialize the newName to 0, then search for this 'name' in directory
while ~newName
    
    subjectNumber=input('Subject number?\n','s');
    if isempty(subjectNumber) 
        disp('No subject details entered, quitting script');
        return   
    end
    
    %% pad number to give e.g.'3' digits
    Params.subjectNumber = padString(subjectNumber, 3, 0);
    
    Params.subjectInitials = input('Subject initials?\n','s');
    
    if isempty(Params.subjectInitials) 
        disp('No subject details entered, quitting script');
        return   
    else
        % Make folder name 
        idFolder = [num2str(Params.subjectNumber), Params.subjectInitials]; % needs to be short for .edf file of max 8 characters
        %idFolder = ['S', num2str(Params.subjectNumber), '_', Params.subjectInitials];
    end
        
    % Be sure this folder name has NOT already been used    
    [sizeY sizeX] = size(Params.directoryName);
    
    % Add date/time
    Params.experimentStart = datestr(now,'yyyymmddHHMMSS');
       
    for i = 1:sizeY
        if isdir(idFolder)
           display('This ID already exists. Please use another id')
        else
            newName = 1;                   
            %%% Create a folder for the resulting output files for this subject          
            %Params.subjID = idFolder; %%%%['S' num2str(Params.SubjectNumber) '_' Params.SubjectInitials];
            Params.subjectFolder = idFolder; %Params.subjID;
            mkdir(Params.subjectFolder)
            %%cd(folderName);
        end
    end  
end

% intiate shell logging
if IsOSX
    diary(strcat([Params.main_path, '/', Params.directoryName, '/', Params.subjectFolder, '/log_', Params.experimentStart, '.txt'])); % note - a date scaler number is used after the date, it can be converted to date and time by entering it in datestr(...)
else
    diary(strcat([Params.main_path, '\', Params.directoryName, '\', Params.subjectFolder, '\log_', Params.experimentStart, '.txt'])); % note - a date scaler number is used after the date, it can be converted to date and time by entering it in datestr(...)
end
cd ..

end

