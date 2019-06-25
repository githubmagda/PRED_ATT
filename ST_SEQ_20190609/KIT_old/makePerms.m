function[permFinal]= makePerms(Params)

    %% input is a set including string of numbers e.g. [1,2,3,4]
    %% returns all possible permutations in rows, shuffles rows and selects required number
        perm1 = perms(Params.series.seqBasicSet);
        [r, c] = size(perm1);
        shufV = Shuffle(1:r);
        permFinal = perm1(shufV,:); % shuffle series
        %permFinal = perm2(1:Params.seriesPerBlock,:); % take number of rows you wanna fix
end

    
        
        
        
    