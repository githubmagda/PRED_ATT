function f = round2flips(p, secs)
    f = round( secs ./ p.scr.frameRate) .* p.scr.frameRate;
end