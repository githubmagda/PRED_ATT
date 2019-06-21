function [newString] = padString (oldNum, lengthString, padElement)
  padElementStr = num2str(padElement);
    startPad = repmat(padElementStr,1,lengthString); %%%the '1' makes this a one-dimensionarl array or vector
    oldString = num2str(oldNum);    
    partPad = length(startPad) - length(oldString);
    padV = startPad(1 : partPad);
    newString = strcat(padV, oldString);
end