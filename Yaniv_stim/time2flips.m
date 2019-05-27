function f = time2flips(Params,t)
 f = round(t./Params.Display.flipInterval);
end