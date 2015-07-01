% Runs the model in loops

%% Load default parameters

clear
maxNumCompThreads(1);
rng('shuffle');
addpath(genpath('C:\Matlab_functions'));

%% Modify parameters

P.folder = 'C:\Matlab_functions\RESULTS\Associator model_23\10. compare interventions\9. AT, AR = 25, fixed number of epochs\'; % folder to save results

% Get seeds
filenames = dir([P.folder, '*.mat']);
weightseeds = NaN(1, numel(filenames));
semanticseeds = NaN(1, numel(filenames));
phoneticseed = NaN(1, numel(filenames));
controls = 1:4:numel(filenames);
for i = controls
    load(filenames(i).name, 'P');
    weightseeds(i) = P.weightseed;
    semanticseeds(i) = P.semanticseed;
    phoneticseed(i) = P.phoneticseed;
end

i = find(~isnan(weightseeds));
weightseeds = weightseeds(i);
i = find(~isnan(semanticseeds));
semanticseeds = semanticseeds(i);
i = find(~isnan(phoneticseed));
phoneticseed = phoneticseed(i);

% Load default parameters
load('C:\Matlab_functions\model_Associator\Associator23_params1.mat');

% Modify parameters
P.Ssize = 57;
P.wordlength = 3;
P.mindistance = 40;
P.nbof_prototypes = 5;
P.looseness = 0.1; % default: 0.05
P.Sact = 15;

P.performance_threshold = 101;
P.trainingtype = 'fourphase';
t=1000;
P.nbof_S_epochs = t*2; % nb of epochs to train model on task S
P.nbof_P_epochs = t*2; % nb of epochs to train model on task S
P.nbof_R_epochs = t; % nb of epochs to train model on task S
P.nbof_L_epochs = t; % nb of epochs to train model on task S

P.size_SH = 100; % hidden layer in the semantic (left) module
P.size_PH = 100; % hidden layer in the phonological (right) module
P.size_AR = 25; % hidden (associator) layer between SH and PH, on the pathway to the right side of the model
P.size_AL = 100; % hidd

P.intervention = 0; % Is it an intervention run?
P.save_weights = 500;
r = 50;

%% Run

P.folder = 'C:\Matlab_functions\RESULTS\Associator model_23\10. compare interventions\9. AT, AR = 25, fixed number of epochs\'; % folder to save results
P.resultsfile = [P.folder, 'RESULTS_Associator model_', num2str(P.version), '.xlsx']; % file to save summary results

counter = 0;
for i = 1:r
    
    counter = counter + 1    
    P.weightseed   = weightseeds(i);
    P.semanticseed = semanticseeds(i);
    P.phoneticseed = phoneticseed(i);
    [L, W, P, S, R, V, T, Q, D] = Associator_23_function(P); 
    
end

%% Beep

for i=1:P.beeps
    beep
    pause(0.5)
end