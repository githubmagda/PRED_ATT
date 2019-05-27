function RTHistogram(Params, Logger)
RelativeRT.vis=[];
RelativeRT.aud = [];
for i=1:length(Logger)
    if Logger(i).RT>0
        if Logger(i).type == 1
            RelativeRT.vis = [RelativeRT.vis Logger(i).RT-(Logger(i).visTargOnset+Params.visTargDuration/1000)];
        elseif Logger(i).type == 0
            RelativeRT.aud = [RelativeRT.aud Logger(i).RT-(Logger(i).audTargOnset+Params.audTargDuration/1000)];
        end
    end
end
figure(11); subplot(2,1,1); hist(RelativeRT.aud); title('auditory');
subplot(2,1,2); hist(RelativeRT.vis); title('visual');
end