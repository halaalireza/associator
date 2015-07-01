% Runs the model in loops

%% Load default parameters

clear
maxNumCompThreads(1);
rng('shuffle');
addpath(genpath('C:\Matlab_functions'));
load('C:\Matlab_functions\model_Associator\Associator23_params1.mat');

%% Modify parameters

P.folder = 'C:\Matlab_functions\RESULTS\Associator model_23\10. compare interventions\11. AT, AR = 25, random vocab\'; % folder to save results

% P.Ssize = 57;
% P.wordlength = 3;
% P.mindistance = 40;
% P.nbof_prototypes = 5;
% P.looseness = 0.1; % default: 0.05
% P.Sact = 15;

P.phoneticsgenerator = @phoneticsgenerator_exact;
P.semanticsgenerator = @semanticsgenerator_exact;
P.Psize = 57;
P.Pact = 15;
P.Ssize = 57;
P.Sact = 15;
P.prop = 0; % proportion of more frequent words; <1
P.trainingtype = 'random';
P.upper_TH = [0.9, 0.9, 0.9, 0.9]; % threshold of activation for answer = 1
P.lower_TH = 1-P.upper_TH; % threshold of activation for answer = 0

P.plot_compositefig = 0; % save composite figure
P.plot_simplefig = 1;

P.performance_threshold = 101;
t=2000;
P.nbof_S_epochs = t; % nb of epochs to train model on task S
P.nbof_P_epochs = t; % nb of epochs to train model on task S
P.nbof_R_epochs = t; % nb of epochs to train model on task S
P.nbof_L_epochs = t; % nb of epochs to train model on task S

P.size_SH = 100; % hidden layer in the semantic (left) module
P.size_PH = 100; % hidden layer in the phonological (right) module
P.size_AR = 25; % hidden (associator) layer between SH and PH, on the pathway to the right side of the model
P.size_AL = 100; % hidd

P.save_weights = 500;
P.intervention = 0; % Is it an intervention run?
r = 50;

%% Run

P.resultsfile = [P.folder, 'RESULTS_Associator model_', num2str(P.version), '.xlsx']; % file to save summary results
    
seeds = randchoose(1000:9999, 1000);
counter = 0;

for i = 1:r
   
    counter = counter + 1
    P.weightseed   = seeds(counter+100);
    P.semanticseed = seeds(counter+200);
    P.phoneticseed = seeds(counter+300); 
    [L, W, P, S, R, V, T, Q, D] = Associator_23_function(P); 
    
end

%% Beep

for i=1:P.beeps
    beep
    pause(0.5)
end