% Runs the model in loops

%% Load default parameters

clear
maxNumCompThreads(1);
rng('shuffle')
addpath(genpath('C:\Matlab_functions'));
load('C:\Matlab_functions\model_Associator\Associator23_params1.mat')

%% Modify parameters

P.folder = 'C:\Matlab_functions\RESULTS\Associator model_23\8. AT_conndens_mixed locations\'; % folder to save results

% Intervention
P.intervention = 1; % Is it an intervention run?
P.int_interventiontype = 0; % 0=unchanged; 1=only hard words; 2=hard words twice
P.int_trainingtype = 'random';
P.int_keptepochs = 500; % How many trained epochs to keep from the previous run? Must be one where weights were saved!
P.int_intended_S_epochs = 200;
P.int_intended_P_epochs = 100;
P.int_intended_R_epochs = 100;
P.int_intended_L_epochs = 100;

timestamps = [
'2013-08-25-12-16-19';
'2013-08-25-12-36-18';
'2013-08-25-12-38-42';
'2013-08-25-13-00-11';
'2013-08-25-13-04-14';
'2013-08-25-13-35-35';
'2013-08-25-13-39-02';
'2013-08-25-14-27-33';
'2013-08-25-14-31-26';
'2013-08-25-15-21-17';
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