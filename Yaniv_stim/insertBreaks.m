function Block = insertBreaks(Params, Block, breakEvery)
for t = breakEvery+1:breakEvery:length(Block)
    Block(t).instructions.rtl = 0;
    Block(t).instructions.contKey = [32 Params.calibKey Params.quitKey];
    Block(t).instructions.text = 'Break. Press the space key to continue';
end
end