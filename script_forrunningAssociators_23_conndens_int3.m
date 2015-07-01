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
x = 1000;
P.int_intended_S_epochs = x-P.int_keptepochs/4;
P.int_intended_P_epochs = (x-P.int_keptepochs/4) * 2;
P.int_intended_R_epochs = x-P.int_keptepochs/4;
P.int_intended_L_epochs = x-P.int_keptepochs/4;

timestamps = [
'2013-08-28-09-54-26';
'2013-08-28-11-34-48';
'2013-08-28-13-11-12';
'2013-08-28-14-49-56';
'2013-08-28-15-55-04';
'2013-08-28-16-39-07';
'2013-08-28-18-54-07';
'2013-08-28-19-53-06';
'2013-08-28-21-30-14';
'2013-08-28-22-11-38'
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