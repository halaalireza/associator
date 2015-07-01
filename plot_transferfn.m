clear
path('E:\Matlab_functions',path);

x = -10 : 0.1 : 10;
T = 0.8 : 0.1 : 1.2;
%T = [1,2,10];
figurefile = ['E:\Matlab_functions\RESULTS_backup\transferfns\logsig_T_0.8_0.1_1.2.png'];

%%

felirat = cell(1, length(T));
for i = 1:length(T)
    felirat{i} = num2str(T(i));
end

figure;
hold all
for i = 1:length(T)
    plot(x, transferfn_logsig(x, T(i)));
end

title('transferfn logsig'); % kesobbi MatLabban %suptitle(figtitle);    
legend(felirat)

%%
print('-dpng', figurefile);
hold off
%close