function [pointsSep] = makeArc(x1,y1,x2,y2,r,n,side)
% If (x1,y1) and (x2,y2) are the beginning and end points, respectively, and r the
% radius of the desired arc which is to bend in a counterclockwise
% direction, then do this:
%  If you want the bending to go clockwise, just change the second line to:
%  a = atan2(x2-x1,-(y2-y1));

d = sqrt((x2-x1)^2+(y2-y1)^2); % Distance between points
if strcmp(side,'left')
    a = atan2(x2-x1,-(y2-y1));
elseif strcmp(side,'right')
    a = atan2(-(x2-x1),y2-y1); % Perpendicular bisector angle
end
b = asin(d/2/r); % Half arc angle
c = linspace(a-b,a+b, n); % Arc angle range
e = sqrt(r^2-d^2/4); % Distance, center to midpoint
x = (x1+x2)/2-e*cos(a)+r*cos(c); % Cartesian coords. of arc
y = (y1+y2)/2-e*sin(a)+r*sin(c);

% axis equal
% plot(x,y,'k.',x1,y1,'r*',x2,y2,'b*')
points(:,1) = real(x');
points(:,2) = real(y');
lengthV =length(points)/4;
q1 = (1:lengthV)'; shufq1=Shuffle(q1);
q2 = (lengthV+1:lengthV*2)'; shufq2=Shuffle(q2);
q3 = (lengthV*2+1 : lengthV*3)'; shufq3 = Shuffle(q3);
q4 = (lengthV*3+1 : lengthV*4)'; shufq4 = Shuffle(q4);

n=1; V=zeros(length(points),1)';
for i = 1:4:(length(points)-3)
    V(i)= shufq1(n);
    V(i+1)=shufq3(n);
    V(i+2)=shufq2(n);
    V(i+3)=shufq4(n);
    n=n+1;
end
pointsSep=points(V,:);
end

% % make sure points are seperated in space
% primeFactors = factor(numTrialsPerSeries/2);
% halfLength = ceil(length(primeFactors/2));
% rowL = prod(primeFactors(1:halfLength));
% colL = prod(primeFactors(halfLength+1:end));
% pointMx = reshape(pointsX,rowL,colL);


