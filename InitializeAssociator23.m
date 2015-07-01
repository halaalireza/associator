function [L, W, P, S, R, V, T, Q, D] = InitializeAssociator23(P)

P.ID = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
P.modes = modesequence(P.trainingtype, P.nbof_S_epochs, P.nbof_P_epochs, P.nbof_R_epochs, P.nbof_L_epochs);
P.intended_epochs = length(P.modes);
if sum(P.noise) == 0
    P.retest = 1;
end

%% Generate input

% Testingvocab
D.start = [];

if strcmp(P.phoneticseed, 'noseed')
    rng shuffle
    s = rng;
    P.phoneticseed = s.Seed;
else
    rng(P.phoneticseed, 'twister');
end
[P, D] = P.phoneticsgenerator(P, D);

if strcmp(P.semanticseed, 'noseed')
    rng shuffle
    s = rng;
    P.semanticseed = s.Seed;
else
    rng(P.semanticseed, 'twister');
end
[P, D] = P.semanticsgenerator(P, D);

D.trainingphons = D.testingphons;
D.trainingsems = D.testingsems;

% Trainingvocab: change frequency of words
rng(1, 'twister');
normalwords = 1:P.vocabsize;
frequentwords = [];
if P.prop > 0 % creating more frequent words
    freqnb = round(P.vocabsize*P.prop);
    frequentwords = sort(randchoose(1:P.vocabsize, freqnb), 'descend');
    for i = 1:freqnb
        normalwords(frequentwords(i))=[];
    end
    for i = frequentwords
        for j = 1:(P.freq-1)
            D.trainingphons = [D.trainingphons; D.testingphons(i,:)];
            D.trainingsems = [D.trainingsems; D.testingsems(i,:)];
        end
    end
end

%% Collect all variables regarding words in V

V(1, P.vocabsize) = struct('frequency',  [], 'AoA',  [], 'P_repr',  [], 'P_pattern',  [], 'P_transcript', [], 'P_nbofneighbours', [], 'P_denseness', [], 'S_repr', [], 'S_word', [], 'S_protcat', [], 'S_prototype', [], 'S_atypicality', [], 'S_imag', []);

% The phonemes that occur during training: 1 phoneme/row
if strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_ThomasAKS2003)) || strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_phonpheat))
    P.usedphonemes = NaN(0, 19);
    for i = 1:nrows(D.trainingphons)
        for j = 1:P.wordlength
            P.usedphonemes = [P.usedphonemes; frameslider(D.trainingphons(i,:), 19, j)];
        end
    end
    P.usedphonemes = unique(P.usedphonemes, 'rows');
end

for i = 1:P.vocabsize
    
    V(i).frequency = length(which_row(D.trainingphons, D.testingphons(i,:)));
    V(i).AoA = NaN(1,4); % SS, PP, SP, PS
    V(i).P_repr = D.testingphons(i,:);
    
    if strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_ThomasAKS2003)) || strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_phonpheat))
        V(i).P_pattern = P.patterns(i,:);
        V(i).P_transcript = [P.phonemes(V(i).P_pattern(1)), P.phonemes(V(i).P_pattern(2)), P.phonemes(V(i).P_pattern(3))];
        V(i).P_nbofneighbours = P.phon_neighbours(i,:); % nb of common phonemes = 0, 1, 2
        V(i).P_denseness = V(i).P_nbofneighbours(3);
    end
    
    V(i).S_repr = D.testingsems(i,:);
    V(i).S_imag = sum(D.testingsems(i,:));
    
    if strfind(func2str(P.semanticsgenerator), func2str(@semanticsgenerator_prototypes))
        if isempty(P.prototypes)
            V(i).S_word = P.words{i};
        else
            V(i).S_protcat = P.protcats(i);
            V(i).S_prototype = P.prototypes(V(i).S_protcat, :);
            V(i).S_atypicality = Eucledian_distance(V(i).S_repr, V(i).S_prototype);
        end
    end
    
end

%% Categorize words according to levels in the dimensions

% Frequency
P.frequency = cell(max([V.frequency]), 1);
for i = 1:P.vocabsize
    for j = 1:max([V.frequency])
        if V(i).frequency == j
            P.frequency{j} = [P.frequency{j}, i];
        end
    end
end

% Densness of phonological neighbourhood
if strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_ThomasAKS2003)) || strcmp(func2str(P.phoneticsgenerator), func2str(@phoneticsgenerator_phonpheat))
    P.denseness = cell(max([V.P_denseness])+1, 1);
    for i = 1:P.vocabsize
        for j = 0:max([V.P_denseness])
            if V(i).P_denseness == j
                P.denseness{j+1} = [P.denseness{j+1}, i];
            end
        end
    end
end

% Semantic atypicality (difference from prototype)
if strfind(func2str(P.semanticsgenerator), func2str(@semanticsgenerator_prototypes))
    if isempty(P.prototypes)==0
        P.atypicality = cell(max([V.S_atypicality])+1, 1);
        for i = 1:P.vocabsize
            for j = 0:max([V.S_atypicality])
                if V(i).S_atypicality == j
                    P.atypicality{j+1} = [P.atypicality{j+1}, i];
                end
            end
        end
        nbof_categories = length (P.atypicality);
        regroup = cell(2,1);
        regroup{1} = [P.atypicality{1:floor(nbof_categories/2)}];
        regroup{2} = [P.atypicality{floor(nbof_categories/2)+1:nbof_categories}];
        P.atypicality = regroup;
    end
else
    P.mindistance = 'NA';
    P.looseness = 'NA';
    
    if isfield(P, 'semdist_withinclasses') == 0
        P.nbof_prototypes = 'NA';
        P.semdist_withinclasses = 'NA';
        P.semdist_betweenclasses = 'NA';
    end
end

% Imageability
range = max([V.S_imag])-min([V.S_imag])+1;
half = floor(range/2);
P.imag = cell(2,1);
for i = 1:P.vocabsize
    if V(i).S_imag < min([V.S_imag]) + half
        P.imag{1} = [P.imag{1}, i];
    else
        P.imag{2} = [P.imag{2}, i];
    end
end

% P.imag = cell(max([V.S_imag])+1, 1);
% for i = 1:P.vocabsize
%     for j = 0:max([V.S_imag])
%         if V(i).S_imag == j
%             P.imag{j+1} = [P.imag{j+1}, i];
%         end
%     end
% end

% Semantic (prototype) class
if strfind(func2str(P.semanticsgenerator), func2str(@semanticsgenerator_prototypes))

    P.semclass = cell(max(P.protcats),1);
    for i = 1:numel(P.protcats)
        P.semclass{P.protcats(i)} = [P.semclass{P.protcats(i)},  i];
    end

end
%% Layers

P.size_SI = ncols(D.testingsems);    % retinal/semantic input layer
P.size_SO = ncols(D.testingsems);
P.size_PI = ncols(D.testingphons);    % label/phonetic input layer
P.size_PO = ncols(D.testingphons);

P.layernames = {'SI', 'SH', 'SO', 'PI', 'PH', 'PO', 'AR', 'AL'};
P.layersizes = {P.size_SI, P.size_SH, P.size_SO, P.size_PI, P.size_PH, P.size_PO, P.size_AR, P.size_AL};

for i = 1:length(P.layernames)
    L(i).name = P.layernames{i};
    L(i).state = P.layerinit(1, P.layersizes{i});
    L(i).size = P.layersizes{i};
end

%% Weights

P.weightnames = {'SISH', 'SHSO', 'PIPH', 'PHPO', 'SHAR', 'ARPH', 'PHAL', 'ALSH'};
P.weightsizes = {
    [P.size_SI, P.size_SH],
    [P.size_SH, P.size_SO],
    [P.size_PI, P.size_PH],
    [P.size_PH, P.size_PO],
    [P.size_SH, P.size_AR],
    [P.size_AR, P.size_PH],
    [P.size_PH, P.size_AL],
    [P.size_AL, P.size_SH],
    };

if strcmp(P.weightseed, 'noseed')
    %rng shuffle
    s = rng;
    P.weightseed = s.Seed;
else
    rng(P.weightseed, 'twister');
end

for i = 1:length(P.weightnames)
    W(i).name = P.weightnames{i};
    W(i).size = [P.weightsizes{i}(1) + P.usebias, P.weightsizes{i}(2)];
    W(i).state = P.randmin + (P.randmax-P.randmin) .* P.weightinit(W(i).size);     % For randn this will be: P.randmax*randn(P.weightsizes{i})
    W(i).momentumterm = zeros(W(i).size);
    W(i).change = zeros(W(i).size);
    
    if P.usebias == 1
        W(i).biasweights = nrows(W(i).state) : nrows(W(i).state) : numel(W(i).state); % this gives you a list of the biasweight Nos (sorszamok)
    else
        W(i).biasweights = [];
    end
    
end

P.bias = zeros(1, P.usebias)+P.biasvalue; % 1x0 empty vector if no bias; 1x1 vector contains biasvalue, if usebias = 1

% Non-existent connections
P.densities = {P.dens_SISH, P.dens_SHSO, P.dens_PIPH, P.dens_PHPO, P.dens_SHAR, P.dens_ARPH, P.dens_PHAL, P.dens_ALSH};
for i = 1:length(W)
    nbof_eliminated = round(numel(W(i).state) * (1-P.densities{i}));
    rng(1);
    W(i).eliminated = randchoose(1:numel(W(i).state), nbof_eliminated);
    W(i).state(W(i).eliminated) = 0;
end

% Store weights
Q(1).epoch = 0;
Q(1).weights = W;

%% Tests, scores, errors

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
R.start = 1;

