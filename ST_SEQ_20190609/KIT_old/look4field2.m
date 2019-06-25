function [theValue flag] = look4field2 (theStruct, theField)

if isfield(theStruct, theField)
    theValue = theStruct.(theField);
    flag = 1;
    return

end

if ~isstruct(theStruct)
    theValue = 0;
    flag = 0;
    return
end
fns = fieldnames(theStruct);
for iField = 1:length(fns)
    [theValue flag] = look4field2 (theStruct.(fns{iField}), theField);
    if flag
        return
    end
end

theValue = 0;

end