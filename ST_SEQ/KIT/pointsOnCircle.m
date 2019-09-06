function[] = pointsOnCircle()


% Plot a circle.
angles = linspace(0, 2*pi, 50); % 720 is the total number of points
radius = 20;
xCenter = 50;
yCenter = 50;

x = radius * cos(angles) + xCenter; 
y = radius * sin(angles) + yCenter;
% Plot circle.
plot(x, y, 'b-', 'LineWidth', 2);
% Plot center.
hold on;
plot(xCenter, yCenter, 'k+', 'LineWidth', 2, 'MarkerSize', 16);
grid on;
axis equal;
xlabel('X', 'FontSize', 16);
ylabel('Y', 'FontSize', 16);

% Now chose points in quads 
len = length(x);
X1 = x(1:len/4); 
Y1 = y(1:len/4);
X2 = x(len/4:len/2); 
Y2 = y(len/4:len/2) ;
X3 = x(len/2:len/1.3333); 
Y3 = y(len/2:len/1.3333) ;
X4 = x(len/1.3333:len); 
Y4 = y(len/1.3333:len) ;

plot(X1, Y1, 'ro', 'LineWidth', 2, 'MarkerSize', 16);% s1 = 5; % Number of random points to get.
plot(X2, Y2, 'go', 'LineWidth', 2, 'MarkerSize', 16);% s1 = 5; % Number of random points to get.
plot(X3, Y3, 'ko', 'LineWidth', 2, 'MarkerSize', 16);% s1 = 5; % Number of random points to get.
plot(X4, Y4, 'bo', 'LineWidth', 2, 'MarkerSize', 16);% s1 = 5; % Number of random points to get.

% choose random points on circle
s1 = 5; % Number of random points to get.
randomIndexes = randperm(length(angles), s1);
xRandom = x(randomIndexes);
yRandom = y(randomIndexes);
plot(xRandom, yRandom, 'ro', 'LineWidth', 2, 'MarkerSize', 16);
