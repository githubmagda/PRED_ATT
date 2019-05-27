function f = round2flips(Params,t)
 f = round(t./(Params.Display.flipInterval))...
    .* Params.Display.flipInterval;
end