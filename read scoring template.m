%% Description


%% Parameters
clear % delete everything in memory
path('E:\Matlab_functions',path); % my own functions

folder='E:\Birkbeck\WFD project\results\'; % folder containing the excel files
outputfile = 'E:\Birkbeck\WFD project\fileforSPSS.xlsx'; % the one big excel file 

%% Main

% Store the names of the files
cd(folder);
all=dir;
files=cell((length(all)-2),1); % it is empty now
for i=3:length(all)
    files{i-2}=all(i).name;
end

for i=1:length(files)
    file=[folder,files{i}];
    
    % Read one of the worksheets   
    [numbers, texts] = xlsread(file, 'PJs');
    
    % Select everything you want from this worksheet WRITE!!!
    codeofchild=files{i}(1:end-5);
    firstacc=numbers(1,3);
    researcher= texts{3,2};
    
    % Put everything in one big cell
    row={codeofchild, firstacc, researcher};

    % Write the data in the common outputfile    
    where = nrows(xlsread(outputfile))+1;
    xlswrite(outputfile, row, 'all',['A', num2str(where)]);    
    
    % Repeat with the other worksheets WRITE!!!
    
end
beep
'Ready!'
