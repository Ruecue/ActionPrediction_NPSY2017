%ricbra_PCA14_TABLEVSMOUTHTrials
%%% Analysis Pipeline for PCA14 EEG STUDY
clearvars
close all
clc
commandwindow

%% READ IN INFO FILE AND SET PATHS

%Go to Info directory
%cd('C:\Users\U120122\SURFdrive\_PHD\_Experiments\Other Studies\PCA14\Analysis\EEG\Scripts\')
cd([filesep 'home' filesep 'ricbra' filesep 'Desktop' filesep 'OtherStudies' filesep 'PCA14' filesep 'EEG' filesep 'Scripts' filesep ''])
INFO=ricbra_PCA14_Info();

%Add scripts and FT path
addpath(INFO.PATHS.scripts);
addpath (INFO.PATHS.ft);

%Restore FT defaults
ft_defaults

%% START ANALYSIS

%CREATE AN OUTPUT FOLDER
foldin=INFO.PATHS.out;

foldout=[INFO.PATHS.out, filesep 'ExtraFFT' filesep];
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

for sub=3:length(subnum)
    if sub<10
        subjname=['pil0',sprintf('%s', num2str(sub))];
    else
        subjname=['pil',sprintf('%s', num2str(sub))];
    end
    
    %Step in before FFT
    load([foldin,subjname],'cleandata')
    
    %Redo the FFT with a slight adjustment in ordering the groups
    %% FFT analysis of the data
    
    Table_Trials=find(cleandata.trialinfo(:,1)>=200);
    Mouth_Trials=find(cleandata.trialinfo(:,1)>=100 & cleandata.trialinfo(:,1)<200);
    
    
    steps1 = find(ismember(cleandata.trialinfo(:,2),1)==1);
    steps2 = find(ismember(cleandata.trialinfo(:,2),2)==1);
    steps3 = find(ismember(cleandata.trialinfo(:,2),3)==1);
    
    T_step1=intersect(Table_Trials,steps1);
    T_step2=intersect(Table_Trials,steps2);
    T_step3=intersect(Table_Trials,steps3);
    
    M_step1=intersect(Mouth_Trials,steps1);
    M_step2=intersect(Mouth_Trials,steps2);
    M_step3=intersect(Mouth_Trials,steps3);
    
    trial_cond.fix = find(ismember(cleandata.trialinfo(:,2),55)==1);
    
    for conditions=1:2
        
        if conditions==1 %Table
            trial_cond.step1=T_step1;
            trial_cond.step2=T_step2;
            trial_cond.step3=T_step3;
        elseif conditions ==2 %Mouth
            trial_cond.step1= M_step1;
            trial_cond.step2= M_step2;
            trial_cond.step3= M_step3;
        end
        
        cfg = [];
        FFT=[]
        cfg.method = 'mtmfft';
        cfg.output = 'pow';
        cfg.taper  = 'hanning';
        cfg.foi = [1:45];
        
        for i=1:length(fields(trial_cond))
            cfg.trials=[];
            if i==1
                cfg.trials = trial_cond.step1;                                    % analyses for the trials per condition
                FFT.step1 = ft_freqanalysis(cfg, cleandata);
            elseif i==2
                cfg.trials = trial_cond.step2;                                    % analyses for the trials per condition
                FFT.step2 = ft_freqanalysis(cfg,cleandata);
            elseif i==3
                cfg.trials = trial_cond.step3;                                    % analyses for the trials per condition
                FFT.step3 = ft_freqanalysis(cfg,cleandata);
            elseif i==4
                cfg.trials = trial_cond.fix;                                    % analyses for the trials per condition
                FFT.fix = ft_freqanalysis(cfg,cleandata);
            end
        end
        if conditions==1 %Table
            FFT_Table=FFT;
            save([foldout,subjname],'FFT_Table')
        elseif conditions==2 %Mouth
            FFT_Mouth=FFT;
            save([foldout,subjname],'FFT_Mouth', '-append')
        end
    end
   
end

%Perform GA analysis again
clf
close all
clearvars -except INFO
cd([filesep 'home' filesep 'ricbra' filesep 'Desktop' filesep 'OtherStudies' filesep 'PCA14' filesep 'EEG' filesep 'Scripts' filesep ''])
INFO=ricbra_PCA14_Info();

IncludeSubs={'pil03','pil04','pil05','pil06','pil07','pil08','pil09','pil10','pil11','pil12','pil13','pil14','pil15','pil16','pil17','pil19','pil20','pil21','pil22','pil23'};

%Included in ET battery:
% 6,9,10,12,15,19,20,21,22,23
%IncludeSubs={'pil06','pil09','pil10','pil12','pil15','pil19','pil20','pil21','pil22','pil23'};

%Create grand average
[Table_GA,Mouth_GA]=ricbra_PCA14_GA_TvsM(INFO, IncludeSubs);

%Select Data
%Next, we select the specific frequencies of interest and regions of interest
%and export an average for this (per participant) from the data

%ROI={'O1','Oz','O2'};
%ROI={'F3','Fz','F4'};
%ROI={'C3','Cz','C4'};
ROI={'Cz'};

%FOI=[7,12]; %Mu:7-12Hz, Beta:16-25Hz
FOI=[16,25]; %Beta, PG experiment

%% Table
[Table_Results_incFix]=ricbra_PCA14_Results_incFix(Table_GA,ROI,FOI); %Absoulte values
[Table_Results]=ricbra_PCA14_Results(Table_GA,ROI,FOI); %Relative to Fixation cross

ricbra_PCA14_Plot_Results_v2(Table_Results,ROI,FOI,'table');
ricbra_PCA14_Plot_Results_v2(Table_Results_incFix,ROI,FOI,'table');

%Create Topoplot of the data
condname={'step1','step2','step3'};
ricbra_PCA14_Topoplot_v2(Table_GA,FOI,INFO.SUBJ.Eleclayout,condname, 'table')

%% Mouth
[Mouth_Results_incFix]=ricbra_PCA14_Results_incFix(Mouth_GA,ROI,FOI); %Absoulte values
[Mouth_Results]=ricbra_PCA14_Results(Mouth_GA,ROI,FOI); %Relative to Fixation cross

ricbra_PCA14_Plot_Results_v2(Mouth_Results,ROI,FOI,'mouth');
ricbra_PCA14_Plot_Results_v2(Mouth_Results_incFix,ROI,FOI,'mouth');

%Create Topoplot of the data
condname={'step1','step2','step3'};
ricbra_PCA14_Topoplot_v2(Mouth_GA,FOI,INFO.SUBJ.Eleclayout,condname,'mouth')











