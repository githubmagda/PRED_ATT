function [visTargLoc, visTargEcc] = getVisTargLoc(Params)
switch Params.visTargType
    case 'peripheral'
        visTargEcc = rand() * range(Params.visTargEccRange) + Params.visTargEccRange(1);
        annulusSize = Params.gratingSize - Params.visTargEdge * ...
            Params.visTargSize; % area on grating that target can be on - equivalent to smaller circle on grating
        [xtargBoundries, ytargBoundries] = circcirc(0,0,visTargEcc,...
            0, Params.gratingEcc, annulusSize); % Intersection of two circles - boundries of annulus
        Params.visRadTargBound = sort([atan2(ytargBoundries(1),xtargBoundries(1)),...
            atan2(ytargBoundries(2),xtargBoundries(2))]);  % Convert points to radians around fixation
        
        locOnArc = rand() * range(Params.visRadTargBound) + Params.visRadTargBound(1);     % Random point on the arc
        
        visTargLoc = [visTargEcc * cos(locOnArc), visTargEcc * sin(locOnArc)];
    case 'central'
        visTargEcc = rand() * range(Params.visTargEccRange) + Params.visTargEccRange(1);
        visTargAng = rand() * 2 * pi;
        visTargLoc = [visTargEcc * cos(visTargAng), visTargEcc * sin(visTargAng)];
end
end