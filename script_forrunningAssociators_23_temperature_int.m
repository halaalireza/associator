% Runs the model in loops

%% Load default parameters

clear all
maxNumCompThreads(1);
rng('shuffle')
addpath(genpath('C:\Matlab_functions'));
load('C:\Matlab_functions\model_Associator\Associator23_params1.mat')

%% Modify parameters

P.folder = 'C:\Matlab_functions\RESULTS\Associator model_23\7. AT_temperature_mixed locations\'; % folder to save results

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
% '2013-08-28-09-44-16';
% '2013-08-28-11-03-17';
% '2013-08-28-12-24-28';
% '2013-08-28-13-35-30';
% '2013-08-28-14-36-01';
% '2013-08-28-15-38-10';
% '2013-08-28-15-57-56';
% '2013-08-28-17-44-09';
% '2013-08-28-17-49-15';
'2013-08-28-20-18-21'
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
clear all