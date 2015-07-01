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

P.save_weights = [];

% Intervention
P.intervention = 1; % Is it an intervention run?
P.int_interventiontype = 0; % 0=unchanged; 1=only hard words; 2=hard words twice
P.int_trainingtype = 'random';
P.int_keptepochs = 500; % How many trained epochs to keep from the previous run? Must be one where weights were saved!
x = 2000;
P.int_intended_S_epochs = (x-P.int_keptepochs/4)*2;
P.int_intended_P_epochs = (x-P.int_keptepochs/4)*2;
P.int_intended_R_epochs = x-P.int_keptepochs/4;
P.int_intended_L_epochs = x-P.int_keptepochs/4;
P.save_weights = [];

timestamps = [
'2015-03-22-18-27-36';
'2015-03-22-18-38-30';
'2015-03-22-18-49-17';
'2015-03-22-19-00-02';
'2015-03-22-19-10-46';
'2015-03-22-19-21-36';
'2015-03-22-19-32-20';
'2015-03-22-19-43-09';
'2015-03-22-19-53-59';
'2015-03-22-20-04-46';
'2015-03-22-20-15-36';
'2015-03-22-20-26-24';
'2015-03-22-20-37-14';
'2015-03-22-20-48-03';
'2015-03-22-20-58-51';
'2015-03-22-21-09-44';
'2015-03-22-21-20-29';
'2015-03-22-21-31-17';
'2015-03-22-21-42-07';
'2015-03-22-21-52-58';
'2015-03-22-22-03-48';
'2015-03-22-22-14-37';
'2015-03-22-22-25-23';
'2015-03-22-22-36-08';
'2015-03-22-22-46-57';
'2015-03-22-22-57-49';
'2015-03-22-23-08-42';
'2015-03-22-23-19-33';
'2015-03-22-23-30-23';
'2015-03-22-23-41-10';
'2015-03-22-23-52-01';
'2015-03-23-00-02-53';
'2015-03-23-00-13-43';
'2015-03-23-00-24-32';
'2015-03-23-00-35-18';
'2015-03-23-00-46-10';
'2015-03-23-00-57-01';
'2015-03-23-01-07-52';
'2015-03-23-01-18-44';
'2015-03-23-01-29-32';
'2015-03-23-01-40-19';
'2015-03-23-01-51-08';
'2015-03-23-02-01-59';
'2015-03-23-02-12-46';
'2015-03-23-02-23-33';
'2015-03-23-02-34-19';
'2015-03-23-02-45-07';
'2015-03-23-02-55-52';
'2015-03-23-03-06-43';
'2015-03-23-03-17-37';

];

%% Run

P.resultsfile = [P.folder, 'RESULTS_Associator model_', num2str(P.version), '.xlsx']; % file to save summary results
counter = 0;

for i = 1:size(timestamps,1)
    
    counter = counter + 1
    P.int_oldtimestamp = timestamps(i,:);
    [L, W, P, S, R, V, T, Q, D] = Associator_23_function(P); 
    
end

%% Beep

for i=1:P.beeps
    beep
    pause(0.5)
end