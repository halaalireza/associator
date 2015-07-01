% Calculates RTs for correct words only
% Calculates means and median
% output is mean (or median) of RTs (rows = tasks, columns = )


function RT_medians = matfileanalyzator_Assoc_RT(matfile, param)

%%
load(matfile, 'T', 'S')

collectSS = cell(nrows(T.RT_SS), 1);
collectPP = cell(nrows(T.RT_SS), 1);
collectSP = cell(nrows(T.RT_SS), 1);
collectPS = cell(nrows(T.RT_SS), 1);
for e = 1:nrows(T.RT_SS)
    for s = 1:ncols(T.RT_SS)
        if S(e).test_SS(s) == 1
            collectSS{e} = [collectSS{e}, T.RT_SS(e,s)];
        end
        if S(e).test_PP(s) == 1
            collectPP{e} = [collectPP{e}, T.RT_PP(e,s)];
        end
        if S(e).test_SP(s) == 1
            collectSP{e} = [collectSP{e}, T.RT_SP(e,s)];
        end
        if S(e).test_PS(s) == 1
            collectPS{e} = [collectPS{e}, T.RT_PS(e,s)];
        end
    end
end
%%

RT_means = NaN(4, nrows(T.RT_SS));
for e = 1:nrows(T.RT_SS)
    RT_means(1,e) = mean(collectSS{e});
    RT_means(2,e) = mean(collectPP{e});
    RT_means(3,e) = mean(collectSP{e});
    RT_means(4,e) = mean(collectPS{e});
end

RT_medians = NaN(4, nrows(T.RT_SS));
for e = 1:nrows(T.RT_SS)
    RT_medians(1,e) = median(collectSS{e});
    RT_medians(2,e) = median(collectPP{e});
    RT_medians(3,e) = median(collectSP{e});
    RT_medians(4,e) = median(collectPS{e});
end

%%
%output = RT_means(1, param.epoch/100);
    
    
    
    
    
    


