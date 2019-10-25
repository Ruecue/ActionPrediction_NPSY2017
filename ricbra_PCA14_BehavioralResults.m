%% Analysis of behavioral response to catch question

% S 40 = Ende Video
% S 75 = Frage
% <S100= Catch
% >S100= Experimental Trial
%R 1= left/yes?
%R 8= right/no?

clearvars
close all
clc
commandwindow

%% READ IN INFO FILE AND SET PATHS

%Go to Info directory
%cd('')
cd('')
INFO=ricbra_PCA14_Info();

%Add scripts and FT path
addpath(INFO.PATHS.scripts);
addpath (INFO.PATHS.ft);

%Restore FT defaults
ft_defaults

%% START ANALYSIS

%CREATE AN OUTPUT FOLDER
foldout=INFO.PATHS.outbehavior;
if ~exist(foldout, 'dir')
    mkdir(foldout);
end
%Define the different paths
EEGpath=[INFO.PATHS.datapath, 'EEG', filesep];
Logpath=[INFO.PATHS.datapath, 'Logfiles', filesep];

%Determine the number of subjects
cd(EEGpath)
subnum = dir('*.vhdr'); %check how many vhdr files we have

%check that this is consistent with the number of logfiles
cd(Logpath)
lognum = dir('*.txt'); %check how many vhdr files we have

if ~isequal(length(subnum),length(lognum))
    error ('unequal amount of EEG and logfiles. please check')
end

%% Loop Through subjects to calculate their response

for sub=2:length(subnum) %For each Subject
    
    %Make sure to clear all variables except the following
    clf
    close all
    clear Events TempEvents Catch Exp
    
    if sub<10
        subjname=['pil0',sprintf('%s', num2str(sub))];
    else
        subjname=['pil',sprintf('%s', num2str(sub))];
    end
    
    cd(EEGpath)
    TempEvents=ft_read_event([subjname, '.vmrk']);
    
    j=1;
    %Get the Values
    for i=1:size(TempEvents,2)
        if ~isempty(TempEvents(1,i).value)
            if ~isempty(str2num(TempEvents(1,i).value(2:end)))
                Events(j,1)=str2num(TempEvents(1,i).value(2:end));
                j=j+1;
            end
        end
    end
    
    %Check responses
    
    e=1;
    c=1;
    for j=3:size(Events,1) %If there is anything before marker 3 this should be ignored.
        
        if Events(j,1)==75 %Als het een Vraag is
            %Check if its Catch Trial or Experimental Trial
            if Events((j-2),1)<100
                Catch(c,1)=Events((j+1),1);
                c=c+1;
            elseif Events((j-2),1)>=100
                Exp(e,1)=Events((j+1),1);
                e=e+1;
            end
        end
        
    end
    
    %Calculate Percentage Correct
    Perc.Exp(sub,1)=length(find(Exp==1))/length(Exp);
    Perc.Cat(sub,1)=length(find(Catch==8))/length(Catch);
    Perc.Sub{sub,1}=subjname;
end
