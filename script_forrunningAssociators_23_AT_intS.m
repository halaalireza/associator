% Runs the model in loops

%% Load default parameters

clear
maxNumCompThreads(1);
rng('shuffle');
addpath(genpath('C:\Matlab_functions'));

%% Modify parameters

P.folder = 'C:\Matlab_functions\RESULTS\Associator model_23\10. compare interventions\12. AT, AR = 25, more epochs\'; % folder to save results
P.resultsfile = [P.folder, 'RESULTS_Associator model_23.xlsx']; % file to save summary results

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
'2015-03-26-14-43-35';
'2015-03-26-15-28-50';
'2015-03-26-15-43-18';
'2015-03-26-15-57-45';
'2015-03-26-16-12-12';
'2015-03-26-16-26-36';
'2015-03-26-16-41-22';
'2015-03-26-16-55-56';
'2015-03-26-17-10-25';
'2015-03-26-17-25-00';
'2015-03-26-17-39-30';
'2015-03-26-17-53-57';
'2015-03-26-18-08-21';
'2015-03-26-18-22-50';
'2015-03-26-18-37-23';
'2015-03-26-18-51-51';
'2015-03-26-19-06-22';
'2015-03-26-19-20-54';
'2015-03-26-19-35-31';
'2015-03-26-19-50-04';
'2015-03-26-20-04-35';
'2015-03-26-20-19-04';
'2015-03-26-20-33-41';
'2015-03-26-20-48-08';
'2015-03-26-21-02-39';
'2015-03-26-21-17-18';
'2015-03-26-21-31-46';
'2015-03-26-21-46-15';
'2015-03-26-22-00-44';
'2015-03-26-22-15-14';
'2015-03-26-22-29-49';
'2015-03-26-22-44-20';
'2015-03-26-22-58-51';
'2015-03-26-23-13-16';
'2015-03-26-23-27-46';
'2015-03-26-23-42-18';
'2015-03-26-23-56-46';
'2015-03-27-00-11-15';
'2015-03-27-00-25-49';
'2015-03-27-00-40-24';
'2015-03-27-00-54-55';
'2015-03-27-01-09-24';
'2015-03-27-01-23-53';
'2015-03-27-01-38-24';
'2015-03-27-01-52-51';
'2015-03-27-02-07-21';
'2015-03-27-02-21-51';
'2015-03-27-02-36-25';
'2015-03-27-02-50-53';
'2015-03-27-03-05-24';
];

%% Run

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