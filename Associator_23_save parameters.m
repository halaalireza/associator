%% Description

% L: layers
% W: weights
% P: parameters
% S: test results
% R: short results
% V: properties of words
% T: collects vocabsize according to dimensions for plotting
% D: IO data
% Q: saved weights

%% Parameters

clear
P.directory = 'C'; % main directory
P.version = 23; % version of the model

% Initialization
P.layerinit = @zeros; % layer initialization function; does not make any difference
P.weightinit = @randn; % weight initialization function: rand, randn (zeros do not work, because increment is always 0)
P.randmin = 0; % rand: the lower limit of randomly initialized uniform weights; randn: the mean of the normally distributed random weights; zeros: has to be 0
P.randmax = 0.1; % rand: the upper limit of randomly initialized uniform weights; randn: the multiplier of the standard normal distribution
P.weightseed   = 'noseed'; % 'noseed' or a number between 0 and 2^31-2
P.semanticseed = 'noseed'; % 'noseed' or a number between 0 and 2^31-2
P.phoneticseed = 'noseed'; % 'noseed' or a number between 0 and 2^31-2

% Vocabulary
P.vocabsize = 100; % nb of words in the lexicon; with ecological and ratio: max 57!
P.prop = 0.5; % proportion of more frequent words; <1
P.freq = 2; % frequency of more frequent words
P.phoneticsgenerator = @phoneticsgenerator_phonpheat; % ThomasAKS2003, exact, phonpheat
P.semanticsgenerator = @semanticsgenerator_prototypes2; % prototypes, ecological, ratio, exact
P.Ssize = 57; % nb of semantic features
P.Sact = 28; % nb of active semantic features in each prototype or meaning
P.nbof_prototypes = 5; % nb of semantic prototypes
P.mindistance = 40; % the minimum Eucledian distance of semantic prototypes
P.looseness = 0.05; % the looseness of semantic prototype-categories (the probability that an activation is different from that of the prototype)
P.Psize = 120; % nb of phonological features for phoneticsgenerator_exact
P.Pact = 12; % exact number of active features in each form for phoneticsgenerator_exact
P.wordlength = 9; % the number of phonemes in words

% Size of variable size layers (the size of all other layers depends on the lexicon)
P.size_SH = 500; % hidden layer in the semantic (left) module
P.size_PH = 500; % hidden layer in the phonological (right) module
P.size_AR = 500; % hidden (associator) layer between SH and PH, on the pathway to the right side of the model
P.size_AL = 500; % hidden (associator) layer between PH and SH, on the pathway to the left side of the model
P.usebias = 1;   % 1= yes, 0=no                    
P.biasvalue = 1; % the value of the bias

% Connection densities (=< 1)
P.dens_SISH = 1;
P.dens_SHSO = 1;
P.dens_PIPH = 1;
P.dens_PHPO = 1;
P.dens_SHAR = 1;
P.dens_ARPH = 1;
P.dens_PHAL = 1;
P.dens_ALSH = 1;

% Training
P.trainingtype = 'fourcycle'; % fourphase, fourcycle, random, twophase
P.permute = 0; % permute order of items before each epoch
P.transferfn = @transferfn_logsig; % transferfn_logsig for 0/1 targets; use tansig when target is -1/1; threshold does not work with backprop
P.delta = @delta_logsig_withT; % use it according to the transferfn! logsig, logsig_CE, tansig
P.normfn = @nochange; % use nochange with backprop; nochange, normfn_bymatrixmax, _byrowmax, _bymatrixsum
P.offset = 0; % the offset of the transferfunction
P.temperatures =  [1.0, 1.0, 1.0, 1.0]; % temperature for logsig and tansig transferfunctions, the threshold for threshold/step transferfn
P.learningrates = [0.1, 0.1, 0.1, 0.1]; % SS (SISH, SHSO), PP (PIPH, PHPO), SP (SHAR, ARPH), PS (PHAL, ALSH)
P.momentums =     [0.3, 0.3, 0.3, 0.3]; % SS (SISH, SHSO), PP (PIPH, PHPO), SP (SHAR, ARPH), PS (PHAL, ALSH)
P.noise =         [0.0, 0.0, 0.0, 0.0]; % maximum absolute value of random noise

% Evaluating
t=1000;
test = 100;
P.upper_TH = [0.9, 0.9, 0.9, 0.9]; % threshold of activation for answer = 1
P.lower_TH = 1-P.upper_TH; % threshold of activation for answer = 0
P.test_performance = test; % test performance after each xth epoch
P.retest = 1; % retest performance x times in each testing session (1=testing just once, no retesting)
P.test_errors_atperc = []; % test errortypes at these performance percentages; don't use atperc and atepoch together!
P.test_errors_atepoch = [test:test:t*4]; % test errortypes at these epochs; don't use atperc and atepoch together!
P.test_RT = [test:test:t*4]; % test reaction time in these epochs
P.recurrence = 1; % 1/0 switch for recurrence during testing
P.timeout = 100; % maximum number of cycles for RT testing
P.asymptote_TH = 10^(-15); % threshold for cleanup recurrence
P.errorcatfn = @CategorizeErrors_rounded; % function for categorizing errors: CategorizeErrors_rounded, _closest, _recurrent

% Stop conditions
P.nbof_S_epochs = t; % nb of epochs to train model on task S
P.nbof_P_epochs = t; % nb of epochs to train model on task S
P.nbof_R_epochs = t; % nb of epochs to train model on task S
P.nbof_L_epochs = t; % nb of epochs to train model on task S
P.performance_threshold = P.vocabsize; % stop training when performance reaches this criterion (nb of words) in each task
P.convergence_threshold = 0; % DOES NOT WORK!!! 1.0e-008; % break condition/weight; with 1.0e-004 breaks instantly
P.error_threshold = 0; % DOES NOT WORK!!! % break condition for error/both output layers
P.beeps = 3; % Do you want a very annoying reminder when the run is over?

% Saving results, controlling outputs
P.folder = [P.directory, ':\Matlab_functions\RESULTS\Associator model_', num2str(P.version), '\']; % folder to save results
P.resultsfile = [P.folder, 'RESULTS_Associator model_', num2str(P.version), '.xlsx']; % file to save summary results
P.print2screen = 100; % 0 for NO, anynumber for the period to print
P.save_2excel = 1; % save results or not?
P.save_matfile = 1; % save matfile or not?
P.plot_compositefig = 1; % save composite figure
P.plot_simplefig = 0;
P.save_weights = [test:test:t*4]; % save weights after these epochs

% Intervention
P.intervention = 0; % Is it an intervention run?
P.int_interventiontype = 0; % 0=unchanged; 1=only hard words; 2=hard words twice
P.int_oldtimestamp = '';
P.int_keptepochs = 2700; % How many trained epochs to keep from the previous run? Must be one where weights were saved!
P.int_intended_S_epochs = 2000;
P.int_intended_P_epochs = 2000;
P.int_intended_R_epochs = 2000;
P.int_intended_L_epochs = 2000;

%% Save

save('C:\Matlab_functions\model_Associator\Associator23_params1.mat', 'P')

'Parameters saved'

