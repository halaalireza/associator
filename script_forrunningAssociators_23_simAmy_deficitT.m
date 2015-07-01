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
'2013-08-25-12-38-49';
'2013-08-25-13-38-16';
'2013-08-25-14-32-51';
'2013-08-25-16-23-29';
'2013-08-25-17-51-49';
'2013-08-25-19-27-59';
'2013-08-25-20-45-50';
'2013-08-25-22-46-33';
'2013-08-26-00-03-31';
'2013-08-26-01-18-21';
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