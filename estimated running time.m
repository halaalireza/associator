one_epoch = 1; % sec
vocab = 1000;
szorzo = 1000;
linear_a = 1300; % first param of linear fitted line on nb of epochs needed
linear_b = 4000; % second param of linear fitted line on nb of epochs needed

%% Different methods to estimate the number of epochs needed

%epochs = vocab*szorzo;
%epochs = linear_a * vocab + linear_b;
epochs = 104182;

%% Estimated time needed based on the nb of epochs

mins = epochs*one_epoch/60;
hours = mins/60
days = hours/24