% CopyPasteAzk

%% Parameters
clear % delete everything in memory
path('F:\Matlab_functions',path); % my own functions

azk_folder = 'F:\Birkbeck\WFD project\results\azk\'; % folder containing the .azk files
xlsx_folder = 'F:\Birkbeck\WFD project\results\individual excel files\'; % the one big excel file 

% Picture Naming D2

%% Files in the azk folder

cd(azk_folder);
all=dir;
files=cell((length(all)-2),1);
for i=3:length(all)
    files{i-2}=all(i).name;
end

%% Read files

i=1;
file=[azk_folder, files{i}];
fid = fopen(file);

% Read fields determined by the number of fileds
y = textscan(fid, '%s', '');
texty = y{1};
IDofsubject = texty{14}(1:(end-1));
day = texty{15};
hour = texty{16};   

% Read sections determined by starting and ending words
x = textread(file, '%s', 'whitespace', '');
textx = x{1};
cots = regexp(textx, 'COT');
subjects = regexp(textx, 'Subject');
subjects(1)=[];

for j = 1: length(subjects)
    if j==length(subjects)
        colend = length(textx);
    else colend = subjects(j+1)-77;
    end
    data(j).ID = textx((subjects(j)+8));     
    data(j).columns = textx((cots(j)+5) : colend);

end


    
 



fclose(fid);    
%%

%x=textread(file, '%s', 'whitespace', '');
    %text = x{1};
 
%  %intro = textscan(fid, '%[COT]');
%     fseek(fid, 3, 'bof');
%     x =fread(fid, 2, 'uint32')
%     %x = textscan(fid, '%[COT] %f32 %f32 %f32')
%     x{1}
%     %columns = textscan(fid, '%s');
%     %columns{1}
%  
 
 