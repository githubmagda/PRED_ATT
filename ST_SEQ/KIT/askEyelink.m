function [ p ] = askEyelink( p )
% check whether eyetracker is used 
% and whether dummy mode is used

%% eyetracker parameters and question 
%p.location = 'dev'; % 'dev'/'meg'    % Where we are - set for display parameters

button = questdlg('Use eyetracking?','Eyetracking','Yes','No','Yes');

switch button
    case 'Yes'
        p.useEyelink = 1;
    case 'No'
        p.useEyelink = 0;
end
p.EyelinkMouse = 0;


if p.useEyelink
    button = questdlg('Use which eye for policing?','Eyetracking',...
        'Left','Right','Left');
    switch button
        case 'Left'
            p.policeEye = 1;
        case 'Right'
            p.policeEye = 2;
    end
end

if p.useEyelink
    button = questdlg('Use "dummy" mode?','Testing',...
        'Dummy','Record','Dummy');
    switch button
        case 'Dummy'
            p.dummyMode = 1;
        case 'Record'
            p.dummyMode = 0;
    end
end

clear button
end

