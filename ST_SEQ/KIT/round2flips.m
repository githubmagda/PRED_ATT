function f = round2flips(p, secs)
    f = round( secs ./ p.scr.flipInterval) .* p.scr.flipInterval;
end