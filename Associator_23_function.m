%% Changes since Associator 22
% - intervention is fixed
% - intervention parameters are now stored in P.int_
% - the structure of Q changed
% - S is used only when performance is tested and saved
% - P.modes keeps the history of training

function [L, W, P, S, R, V, T, Q, D] = Associator_23_function(P)

%% Initialization

tic
timestamp = datestr(now, 'yyyy-mm-dd-HH-MM-SS')

if P.intervention == 0
    
    clear('int');
    [L, W, P, S, R, V, T, Q, D] = InitializeAssociator23(P);
    'Initialization done'
    
    P.int_interventiontype = 0;
    
end

%% Load and modify for intervention

if P.intervention == 1
    
    % Save intervention parameters
    newP = P;
    
    % Load
    load([P.folder, P.int_oldtimestamp, '.mat'], 'L', 'W', 'D', 'P', 'S', 'Q', 'T', 'V', 'R');
    
    % Rewrite parameters
    oldP = P;
    P.folder = newP.folder;
    P.intervention = newP.intervention;
    P.int_interventiontype = newP.int_interventiontype;
    P.int_trainingtype = newP.int_trainingtype;
    P.int_oldtimestamp = newP.int_oldtimestamp;
    P.int_keptepochs = newP.int_keptepochs;
    P.int_intended_S_epochs = newP.int_intended_S_epochs;
    P.int_intended_P_epochs = newP.int_intended_P_epochs;
    P.int_intended_R_epochs = newP.int_intended_R_epochs;
    P.int_intended_L_epochs = newP.int_intended_L_epochs;
    
    % Modify
    P.ID = [P.int_oldtimestamp, '-start', num2str(P.int_keptepochs), '-int', num2str(P.int_interventiontype), '-', timestamp];
    P.modes = modesequence(P.int_trainingtype, P.int_intended_S_epochs,P.int_intended_P_epochs, P.int_intended_R_epochs, P.int_intended_L_epochs);
    if is_partof(P.modes, 'S') &&  T.SS_all(P.int_keptepochs/P.test_performance) >= P.performance_threshold
        P.modes(regexp(P.modes, 'S')) = 'N';
    end
    if is_partof(P.modes, 'P') &&  T.PP_all(P.int_keptepochs/P.test_performance) >= P.performance_threshold
        P.modes(regexp(P.modes, 'P')) = 'N';
    end
    if length(regexp(P.modes, 'S')) + length(regexp(P.modes, 'P')) == 0 && is_partof(P.modes, 'R') &&  T.SP_all(P.int_keptepochs/P.test_performance)>= P.performance_threshold
        P.modes(regexp(P.modes, 'R')) = 'N';
    end
    if length(regexp(P.modes, 'S')) + length(regexp(P.modes, 'P')) == 0 && is_partof(P.modes, 'L') &&  T.PS_all(P.int_keptepochs/P.test_performance) >= P.performance_threshold
        P.modes(regexp(P.modes, 'L')) = 'N';
    end   
    P.intended_epochs = length(P.modes);
    P.test_RT = P.test_performance : P.test_performance : (P.intended_epochs + P.int_keptepochs);
    
    % Set weights
    where = which_element(P.int_keptepochs, P.save_weights);
    W = Q(where+1).weights;
    
    % Reinitialize
    oldD = D;
    oldQ = Q;
    oldS = S;
    oldT = T;
    oldR = R;    
       
    D = trainingset4intervention_23(oldD, S, P); % data in V is according to the original trainingset
    
    Q(1).epoch = P.int_keptepochs;
    Q(1).weights = W;
    
    clear('S');
    S(1, P.intended_epochs) = struct('epoch', [], 'test_SS',  [], 'test_PP',  [], 'test_SP',  [], 'test_PS',  [], 'error_SS',  [], 'error_PP',  [], 'error_SP',  [], 'error_PS', []);
    
    T = struct('SS_all', [], 'PP_all', [], 'SP_all', [], 'PS_all', [], 'SS_frequency', [], 'PP_frequency', [], 'SP_frequency', [], 'PS_frequency', [], 'SS_denseness', [], 'PP_denseness', [], 'SP_denseness', [], 'PS_denseness', [], 'SS_atypicality', [], 'PP_atypicality', [], 'SP_atypicality', [], 'PS_atypicality', [], 'SS_imag', [], 'PP_imag', [], 'SP_imag', [], 'PS_imag', []);
    T.RT_SS = NaN(length(P.test_RT), nrows(D.testingsems));
    T.RT_PP = NaN(length(P.test_RT), nrows(D.testingsems));
    T.RT_SP = NaN(length(P.test_RT), nrows(D.testingsems));
    T.RT_PS = NaN(length(P.test_RT), nrows(D.testingsems));
    if isempty(P.test_errors_atperc) == 0
        T.production = cell(numel(P.test_errors_atperc), nrows(D.testingsems));
    end
    if isempty(P.test_errors_atepoch) == 0
        T.production = cell(numel(P.test_errors_atepoch), nrows(D.testingsems));
    end
    T.prodsavedat = [];
    
    'No initialization; Loading and modifications done'
    
end

%% Training and testing: temp, P, W, S, Q, T gets modified

'Training starts...'

trainedepochs = 0;
temp.retest_scores = zeros(4, P.vocabsize);
temp.retest_errors = zeros(4,1);
if isempty(P.test_errors_atperc) == 0
    temp.nextEtest = P.test_errors_atperc(1);
    temp.hanyadikEtest = 1;
    temp.Eswitch = 0;
end

for epoch = 1:P.intended_epochs
    
    if P.modes(epoch) ~= 'N'
        
        % Permute order of words before training
        
        if P.permute == 1
            neworder = randperm(nrows(D.trainingsems));
            oldphons = D.trainingphons;
            oldsems = D.trainingsems;
            for i = 1:nrows(D.trainingsems)
                D.trainingphons(i, :) = oldphons(neworder(i), :);
                D.trainingsems(i, :) = oldsems(neworder(i), :);
            end
        end
        
        % Training
        
        W = TrainAssociator22(L, W, P, D, epoch);
        trainedepochs = trainedepochs+1;
        
        % Save weights
        
        if ismember(trainedepochs, P.save_weights)
            where = which_element(trainedepochs, P.save_weights) + 1;
            Q(where).epoch = trainedepochs;
            Q(where).weights = W;
        end
        
        % Testing
        
        if gcd(trainedepochs, P.test_performance) == P.test_performance
            
            temp.retest_scores = zeros(4, P.vocabsize);
            temp.retest_errors = zeros(4,1);
            for i = 1:P.retest
                
                [T, SCORES, ERRORS] = TestAssociator22(L, W, P, T, D, trainedepochs, temp);
                
                temp.retest_scores = temp.retest_scores + SCORES;
                temp.retest_errors = temp.retest_errors + ERRORS;
            end
            temp.retest_scores = temp.retest_scores / P.retest;
            temp.retest_errors = temp.retest_errors / P.retest;
            
            % Save test results
            
            where = trainedepochs/P.test_performance;
            S(where).epoch = trainedepochs;
            S(where).test_SS = SCORES(1,:);  % contains score (1/0) for each word in each testing mode in each epoch
            S(where).test_PP = SCORES(2,:);
            S(where).test_SP = SCORES(3,:);
            S(where).test_PS = SCORES(4,:);
            S(where).error_SS = ERRORS(1);
            S(where).error_PP = ERRORS(2);
            S(where).error_SP = ERRORS(3);
            S(where).error_PS = ERRORS(4);
            
            % When to save production for later error categorization
            
            if isempty(P.test_errors_atperc) == 0
                if temp.Eswitch == 1
                    temp.Eswitch = 0;
                    temp.hanyadikEtest = temp.hanyadikEtest + 1;
                    
                    if temp.hanyadikEtest <= length(P.test_errors_atperc)
                        temp.nextEtest = P.test_errors_atperc(temp.hanyadikEtest);
                    end
                end
                if sum(temp.retest_scores(3,:)) >= (P.vocabsize/100)*temp.nextEtest && temp.hanyadikEtest <= length(P.test_errors_atperc)
                    temp.Eswitch = 1;
                end
            end
            
            % Print to screen
            
            if gcd(trainedepochs, P.print2screen) == P.print2screen
                ['Training epoch: ', num2str(trainedepochs), '; Vocab: ', num2str(sum(SCORES(1,:))), ', ', num2str(sum(SCORES(2,:))), ', ', num2str(sum(SCORES(3,:))), ', ', num2str(sum(SCORES(4,:)))]
            end
            
            % Changing the remaining modes
            
            if is_partof(P.modes(epoch+1:end), 'S') && sum(SCORES(1,:)) >= P.performance_threshold
                P.modes(epoch + regexp(P.modes(epoch+1:end), 'S')) = 'N';
            end
            if is_partof(P.modes(epoch+1:end), 'P') && sum(SCORES(2,:)) >= P.performance_threshold
                P.modes(epoch + regexp(P.modes(epoch+1:end), 'P')) = 'N';
            end
            if length(regexp(P.modes(epoch+1:end), 'S')) + length(regexp(P.modes(epoch+1:end), 'P')) == 0 && is_partof(P.modes(epoch+1:end), 'R') && sum(SCORES(3,:)) >= P.performance_threshold
                P.modes(epoch + regexp(P.modes(epoch+1:end), 'R')) = 'N';
            end
            if length(regexp(P.modes(epoch+1:end), 'S')) + length(regexp(P.modes(epoch+1:end), 'P')) == 0 && is_partof(P.modes(epoch+1:end), 'L') && sum(SCORES(4,:)) >= P.performance_threshold
                P.modes(epoch + regexp(P.modes(epoch+1:end), 'L')) = 'N';
            end
            
        end
        
    else
        % Skip epoch
    end
    
end

'Training finished'

%% Calculate results

% Deleting empty parts
S((floor(trainedepochs/P.test_performance)+1):end)=[];
last_savedweights = which_element(0, P.save_weights > trainedepochs);
Q(last_savedweights+2 : end) = [];

% Number of epochs needed for each task (ha elfelejtette es ujra megtanulta, akkor az utso megtanulas szamit)
R.passed_epochs = epoch;
if 1==0 % if simulation was stopped by user
    R.passed_epochs = epoch-1;
end

R.completed_S_epochs = length(regexp([P.modes], 'S'));
R.completed_P_epochs = length(regexp([P.modes], 'P'));
R.completed_R_epochs = length(regexp([P.modes], 'R'));
R.completed_L_epochs = length(regexp([P.modes], 'L'));
R.completed_epochs = R.completed_S_epochs + R.completed_P_epochs + R.completed_R_epochs + R.completed_L_epochs;

% Adding up results in case of intervention
if P.intervention
    
    for i = 1:length(S)
        S(i).epoch = S(i).epoch + P.int_keptepochs;
    end
    S = [oldS(1:P.int_keptepochs/P.test_performance), S];
    
    which = which_element(0, P.save_weights > P.int_keptepochs);
    Q = [oldQ(1:which+1), Q];
    
    which = which_element(0, P.test_RT > P.int_keptepochs);
    T.RT_SS = [oldT.RT_SS(1:which, :); T.RT_SS];
    T.RT_PP = [oldT.RT_PP(1:which, :); T.RT_PP];
    T.RT_SP = [oldT.RT_SP(1:which, :); T.RT_SP];
    T.RT_PS = [oldT.RT_PS(1:which, :); T.RT_PS];
    
    which = which_element(0, oldT.prodsavedat > P.int_keptepochs);
    T.production = [oldT.production(1:which,:); T.production];
    T.prodsavedat = T.prodsavedat + P.int_keptepochs;
    T.prodsavedat = [oldT.prodsavedat(1:which), T.prodsavedat];
    
    oldmodes = oldP.modes;
    oldmodes(regexp(oldmodes, 'N')) = [];
    newmodes = P.modes;
    newmodes(regexp(newmodes, 'N')) = [];
    modes = [oldmodes(1:P.int_keptepochs), newmodes];
    R.passed_epochs = R.passed_epochs + oldR.completed_epochs;
    R.completed_S_epochs = length(regexp(modes, 'S'));
    R.completed_P_epochs = length(regexp(modes, 'P'));
    R.completed_R_epochs = length(regexp(modes, 'R'));
    R.completed_L_epochs = length(regexp(modes, 'L'));
    R.completed_epochs = R.completed_epochs + P.int_keptepochs;
    
end

% When were words  finally learnt? (ha elfelejtette es ujra megtanulta, akkor az utso megtanulas szamit)
testedepochs = length(S);
for i = 2 : testedepochs
    learnt = S(i).test_SS - S(i-1).test_SS == 1;
    for j = 1:P.vocabsize
        if learnt(j)==1
            V(j).AoA(1) = i * P.test_performance;
        end
    end
    learnt = S(i).test_PP - S(i-1).test_PP == 1;
    for j = 1:P.vocabsize
        if learnt(j)==1
            V(j).AoA(2) = i * P.test_performance;
        end
    end
    learnt = S(i).test_SP - S(i-1).test_SP == 1;
    for j = 1:P.vocabsize
        if learnt(j)==1
            V(j).AoA(3) = i * P.test_performance;
        end
    end
    learnt = S(i).test_PS - S(i-1).test_PS == 1;
    for j = 1:P.vocabsize
        if learnt(j)==1
            V(j).AoA(4) = i * P.test_performance;
        end
    end
end

% Deleting empty rows
for i = nrows(T.RT_SP) : -1 : 1
    if isnan(T.RT_SP(i,1))
        T.RT_SS(i, :) = [];
        T.RT_PP(i, :) = [];
        T.RT_SP(i, :) = [];
        T.RT_PS(i, :) = [];
    end
end
if isfield(T, 'production')
    for i = nrows(T.production) : -1 : 1
        if  isempty(T.production{i,1})
            T.production(i,:) = [];
        end
    end
end

% RT according to different dimensions
T.RT_SP_frequency = NaN(nrows(P.frequency), nrows(T.RT_SP));
T.RT_SP_imag = NaN(nrows(P.imag), nrows(T.RT_SP));
for i = 1:nrows(T.RT_SP)
    for j = 1:nrows(P.frequency)
        T.RT_SP_frequency(j,i) =  mean(T.RT_SP(i,P.frequency{j,:}));
    end
    for j = 1:nrows(P.imag)
        T.RT_SP_imag(j,i) =  mean(T.RT_SP(i,P.imag{j,:}));
    end
end

% Size of the vocabs after each epoch according to different dimensions - collecting data for plotting
% T is a structure; each field represents one dimension in one task; size of fields = matrix(nb of levels in the dimension, completed epochs)

for i = 1:testedepochs
    T.SS_all(i) = sum(S(i).test_SS);
    T.PP_all(i) = sum(S(i).test_PP);
    T.SP_all(i) = sum(S(i).test_SP);
    T.PS_all(i) = sum(S(i).test_PS);
    
    for j = 1:nrows(P.frequency)
        T.SS_frequency(j,i) =  sum(S(i).test_SS(P.frequency{j,:}));
        T.PP_frequency(j,i) =  sum(S(i).test_PP(P.frequency{j,:}));
        T.SP_frequency(j,i) =  sum(S(i).test_SP(P.frequency{j,:}));
        T.PS_frequency(j,i) =  sum(S(i).test_PS(P.frequency{j,:}));
    end
    if strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_ThomasAKS2003))
        for j = 1:nrows(P.denseness)
            T.SS_denseness(j,i) =  sum(S(i).test_SS(P.denseness{j,:}));
            T.PP_denseness(j,i) =  sum(S(i).test_PP(P.denseness{j,:}));
            T.SP_denseness(j,i) =  sum(S(i).test_SP(P.denseness{j,:}));
            T.PS_denseness(j,i) =  sum(S(i).test_PS(P.denseness{j,:}));
        end
    end
    if strcmp(func2str(P.semanticsgenerator), func2str(@semanticsgenerator_prototypes2))
        if isempty(P.prototypes)==0
            for j = 1:nrows(P.atypicality)
                T.SS_atypicality(j,i) = sum(S(i).test_SS(P.atypicality{j,:}));
                T.PP_atypicality(j,i) = sum(S(i).test_PP(P.atypicality{j,:}));
                T.SP_atypicality(j,i) = sum(S(i).test_SP(P.atypicality{j,:}));
                T.PS_atypicality(j,i) = sum(S(i).test_PS(P.atypicality{j,:}));
            end
        end
    end
    for j = 1:nrows(P.imag)
        T.SS_imag(j,i) = sum(S(i).test_SS(P.imag{j,:}));
        T.PP_imag(j,i) = sum(S(i).test_PP(P.imag{j,:}));
        T.SP_imag(j,i) = sum(S(i).test_SP(P.imag{j,:}));
        T.PS_imag(j,i) = sum(S(i).test_PS(P.imag{j,:}));
    end
    
end

% When did the Associator finally learn the whole vocab? (ha elfelejtette es ujra megtanulta, akkor az utso megtanulas szamit)
R.epochs_tolearn_SS = NaN;
R.epochs_tolearn_PP = NaN;
R.epochs_tolearn_SP = NaN;
R.epochs_tolearn_PS = NaN;

for i = testedepochs : -1 : 1
    if T.SS_all(i) == P.performance_threshold
        R.epochs_tolearn_SS = i * P.test_performance;
    end
    if T.PP_all(i) == P.performance_threshold
        R.epochs_tolearn_PP = i * P.test_performance;
    end
    if T.SP_all(i) == P.performance_threshold
        R.epochs_tolearn_SP = i * P.test_performance;
    end
    if T.PS_all(i) == P.performance_threshold
        R.epochs_tolearn_PS = i * P.test_performance;
    end
end

% Size of the final vocab
R.vocab_SS = T.SS_all(end);
R.vocab_PP = T.PP_all(end);
R.vocab_SP = T.SP_all(end);
R.vocab_PS = T.PS_all(end);

'Calculating results finished'

%% Categorize errors

if isfield(T, 'production')
    
    % Creates field in T: errortypes, mainerrortypes, mainerrorperc
    if isfield(P, 'protcats')
        T = P.errorcatfn(T, D, P);
    end
    
else
    T.production = [];
    T.errortypes = NaN(1,12);
    T.mainerrortypes = NaN(1,4);
    T.errorperc = NaN(1,4);
end
'Categorizing errors finished'

%% Save results

R.runningtime_min = toc/60;
if P.save_matfile == 1 % Save all variables in .mat file; later can be loaded
    save([P.folder, P.ID, '.mat'], 'L', 'W', 'P','S','R','V','T','Q','D','-v7.3');
end

if P.save_2excel
    where = nrows(xlsread(P.resultsfile))+1;
    tosave = {
        P.ID,
        % Main results
        R.vocab_SS,
        R.vocab_PP,
        R.vocab_SP,
        R.vocab_PS,
        R.completed_epochs,
        R.completed_S_epochs,
        R.completed_P_epochs,
        R.completed_R_epochs,
        R.completed_L_epochs,
        R.runningtime_min,
        % Intervention
        P.intervention,
        P.int_interventiontype,
        % Seeds
        P.weightseed,
        P.semanticseed,
        P.phoneticseed,
        % Input
        P.vocabsize,
        P.performance_threshold,
        func2str(P.phoneticsgenerator),
        func2str(P.semanticsgenerator),
        P.prop,
        P.freq,
        P.Ssize,
        P.Sact,
        P.nbof_prototypes,
        P.mindistance,
        P.looseness,
        P.semdist_withinclasses,
        P.semdist_betweenclasses,
        P.Sact_avg,
        P.Psize,
        P.Pact_avg,
        % Architecture
        P.size_SH,
        P.size_PH,
        P.size_AR,
        P.size_AL,
        P.dens_SISH;
        P.dens_SHSO;
        P.dens_PIPH;
        P.dens_PHPO;
        P.dens_SHAR;
        P.dens_ARPH;
        P.dens_PHAL;
        P.dens_ALSH;
        P.usebias,
        P.biasvalue,
        % Learning
        P.trainingtype,
        P.recurrence,
        P.timeout,
        func2str(P.errorcatfn),
        P.retest,
        func2str(P.transferfn),
        func2str(P.delta),
        num2str(P.temperatures),
        num2str(P.learningrates),
        num2str(P.momentums),
        num2str(P.noise),
        num2str(P.upper_TH),
        num2str(P.lower_TH),
        func2str(P.weightinit),
        P.randmax
        %max(T.mainerrortypes(:,2)),
        %max(T.mainerrortypes(:,3))
        };
    
    % Save summary of results to an excel file
    xlswrite(P.resultsfile, tosave', 'results', ['A', num2str(where)]);
end

'Saving results finished'
R

%% Plot figure

if P.plot_compositefig
    compositefigs(P, T, R);    
end

% if P.plot_simplefig
%     figure
%     title('Developmental trajectories');
%     x = P.test_performance : P.test_performance : R.completed_epochs;
%     hold all
%     plot(x, T.SS_all, '--m', 'LineWidth', 1.5);
%     plot(x, T.PP_all, '--c', 'LineWidth', 1.5);
%     plot(x, T.SP_all, ':r', 'LineWidth', 1.5);
%     plot(x, T.PS_all, ':b', 'LineWidth', 1.5);
%     if P.intervention == 1
%         plot(repmat(P.int_keptepochs, 1, P.vocabsize+3), -1:P.vocabsize+1,  '-k', 'LineWidth',1);
%     end
%     felirat3 = [{'Task SS'}; {'Task PP'}; {'Task SP'}; {'Task PS'}];
%     set(legend(felirat3),'Location', 'SouthEast');  %[0.6756 0.1897 0.2018 0.2778])
%     axis([0 R.completed_epochs+100 0 P.vocabsize+1]);
%     set(gca,'TickDir','out');
%     xlabel('Number of epochs');
%     ylabel('Number of known words');
%     hold off
%     figurefile =  [P.folder, P.ID, '_composite.png'];
%     print('-dpng', figurefile);
%     close
% end


'Plotting finished'
rng('shuffle')