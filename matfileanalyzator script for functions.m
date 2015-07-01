%% Parameters

clear all
addpath(genpath('C:\Matlab_functions'));
folder = 'C:\Matlab_functions\RESULTS\Associator model_23\10. compare interventions\7. AT, AR=25\';
filename = '';
tol = 'all'; % starting from which file (No) counted from the end; 'all' if from beginning
ig = 1; % finished at which file (No) counted from the end

analyzatorfunction = @matfileanalyzator_performance_when; % name of the function
param.range = 0.5;
param.fps = 24;   % 24 in movies
param.frames = 1: 10: 2000;
param.reruns = 1;
param.epoch = 700;
param.score = 90;
param.resize = 10; % This will be the new P.test_performance
param.weights = 1000;
param.mode = 'R';
param.layer2plot = '';
param.dim_2D = 1;
param.dim_3D = 0;
param.explained = 0;
param.activations = 0;
param.dimensions = {'semclass'};

%% Batch

if isempty(filename)
    
    opengl software
    filenames = dir([folder, '*.mat']);
    if tol == 'all'
        tol=length(filenames);
    end
    
    O = cell(1, numel((length(filenames)-tol+1) : (length(filenames)-ig+1)));
    
    for i = 1 : numel((length(filenames)-tol+1) : (length(filenames)-ig+1))
        matfile = [folder, filenames(i).name];
        O{i} = analyzatorfunction(matfile, param);
        
       %load(matfile, 'T');
%         [P.int_intended_S_epochs, P.int_intended_P_epochs]
        
    end
    
    % Transform O
    if 1==1
        M = NaN(numel(O), numel(O{1}));
        for i = 1:numel(O)
            for j = 1:numel(O{1})
                M(i,j) = O{i}(j);
            end
        end
    end
    M/100;
    M
end

%% Individual

if isempty(filename)==0
    matfile = [folder, filename, '.mat']
    analyzatorfunction(matfile, param)
end

%%

% x = reshape(M, 3, length(O)/3);
% %x = reshape(M, 2, length(O)/2);
% 
% x=x';
% x(:,1) = age(x(:,1), 500);    % semantic int.
% x(:,2) = age(x(:,2), 500);    % phonological int.
% x(:,3) = age(x(:,3), 0);      % no int.
% x;
% 
% y = x;
% y(:, 1) = x(:, 3);
% y(:, 2) = x(:, 1);
% y(:, 3) = x(:, 2);




