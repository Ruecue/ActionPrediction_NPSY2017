%%% Analysis Pipeline for PCA14 EEG STUDY
% %v2: final data sample, subject 27 electrodes sets have been swobed by
% accident and this is corrected here. sub 24:32 tested in januari 2016
% v3: analyzing the data using cluster based permutation tests
% v4: shared on Github - October 2019

clearvars
close all
clc
commandwindow

%% READ IN INFO FILE AND SET PATHS

%Go to Info directory
%cd 
('') %cd to your directory 
INFO=ricbra_PCA14_Info();

%Add scripts and FT path
addpath(INFO.PATHS.scripts);
addpath(INFO.PATHS.ft);

%Restore FT defaults
ft_defaults

%% START ANALYSIS

%CREATE AN OUTPUT FOLDER
foldout=INFO.PATHS.out;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FIRST LOOP THROUGH THE SUBJECTS: READING IN DATA, PREPROCESSING, ARTIFACT REJECTION

for sub=1:length(subnum) %sub=1:length(subnum) %For each Subject
    %Make sure to clear all variables except the following
    clf
    close all
    clearvars -except INFO foldout sub subnum EEGpath Logpath channel
    
    if sub<10
        subjname=['pil0',sprintf('%s', num2str(sub))];
    else
        subjname=['pil',sprintf('%s', num2str(sub))];
    end
    
    %Display the Subject name
    fprintf('\n')
    disp('------------------')
    disp (['Analysis Part1: Reading in Data for Subject: ' subjname])
    disp('------------------')
    fprintf('\n')
    
    %READ IN DATA
    dataname= [EEGpath, filesep,subjname,'.vhdr'];
    
    cfg=[];
    cfg.dataset                 = dataname;
    cfg.trialdef.eventtype      = INFO.MARKER.type;                 % marker type (Stimulus, STATUS, Response etc.)
    cfg.trialdef.eventvaluebegin   = INFO.MARKER.Videos;
    cfg.trialdef.eventvalueend     = INFO.MARKER.End;
    cfg.trialdef.prestim     = 1.2;                          % time before the period for the trials
    cfg.trialdef.poststim    = 0;                             % time after the period (both in seconds)
    cfg.trialdef.eventvaluefix  = INFO.MARKER.Fix;
    cfg.trialdef.prestimfix     = 0;                          % time before specified marker for the fixation period
    cfg.trialdef.poststimfix    = 1;                             % time after specified marker (both in seconds)
    cfg.INFO                    = INFO;
    cfg.subjname                = subjname;
    cfg.sub                     = sub;
    cfg.trialfun                = 'ricbra_PCA14_trialfun';          % in this trialfun, I create my trials (all trials and the rejected ones based on my coding)
    cfg                         = ft_definetrial(cfg);
    
    %Do an initial clean-up of the data before we put the data into ICA
    % We demean and detrend the data in a first step
    hdr     = ft_read_header(cfg.dataset);
    channel = ft_channelselection('EEG', hdr.label);
    
    cfg.preproc.demean      = 'yes';
    %cfg.channel             = channel; %not yet because of subject 27(rearrange first)
    cfg.detrend             = 'yes';
    data              = ft_preprocessing(cfg);
    
    %Rearrange the channels for subject 27 (here the green and yellow
    %electrode sets were swobed during testing by accident
    
    if strcmpi('pil27', subjname)==1
        %electrode 1-32 becomes 33-64
       [data]=ricbra_PCA14_rearrangeelec_sub27 (data);
       warning('rearranging electrodes subject 27')
    end
    
    %Now we can select the correct ones (EEG only) :)
    cfg =[]
    cfg.channel       = channel; %only use EEG channels %because of subject 27 we cant do this yet
    data              = ft_preprocessing(cfg, data);
    
    %CHANNEL REJECTION AND REJECTION OF VERY NOISY TRIALS
    %Trial View
    cfg                = [];
    cfg.method         = 'trial';                                    % all channel per trial
    cfg.keepchannel    = 'nan';                                      % when rejecting channels, values are replaced by NaN (helpful because it keeps the total number of channels consistent)
    cfg.preproc.bpfilter    = 'yes';
    cfg.preproc.bpfilttype  = 'but';
    cfg.preproc.bpfreq      = [1 45];
    data   =  ft_rejectvisual(cfg,data);
    
    %NOTE DOWN BAD CHANNELS FOR LATER INTERPOLATION
    i=1;
    j=1;
    badchannel={};
    goodchannel={};

    for row=1:size(data.trial{1,1},1)
        number=(data.trial{1,1}(row,1));
        if isnan(number)==1
            badchannel(i,1)=data.label(row,1);
            i=i+1;
        else
            goodchannel(j,1)=data.label(row,1);
            j=j+1;
        end
    end
    clear i number row
    
    %SAVE DATA
    save([foldout,subjname],'data', '-append')
    
    % Save the preprocessing information of which channels/trials have been rejected
    %1. channels:
    ichannel=badchannel;
    Output_preproc.interpolatedchannel=ichannel;
    Output_preproc.gooddchannel =goodchannel;
    save([foldout,subjname],'Output_preproc', '-append');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear variables except the following
clf
close all
clearvars -except INFO foldout subnum EEGpath Logpath

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SECOND LOOP THROUGH THE SUBJECTS: PERFORMING ICA

for sub=1:length(subnum) %sub=1:length(subnum) %For each Subject
    clear comp data goodchannel
    if sub<10
        subjname=['pil0',sprintf('%s', num2str(sub))];
    else
        subjname=['pil',sprintf('%s', num2str(sub))];
    end
    
    load([foldout,subjname],'data');
    load([foldout,subjname],'Output_preproc');
    goodchannel=Output_preproc.gooddchannel;
    
    %PERFORM ICA TO REMOVE EYE ARTIFACTS
    cfg        = [];
    cfg.channel=goodchannel;
    cfg.method = 'runica'; %this is the default and uses the implementation from EEGLAB
    comp = ft_componentanalysis(cfg, data);
    
    % Save the data of the participant
    compcfg.topolabel=comp.topolabel;
    compcfg.unmixing=comp.unmixing;
    save([foldout,subjname],'compcfg', '-append')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear variables except the following
clf
close all
clearvars -except INFO foldout subnum EEGpath Logpath
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% THIRD LOOP THROUGH THE SUBJECTS: REJECTING ICA COMPONENTS AND RECREATE THE DATA

for sub=1:length(subnum) %sub=1:length(subnum) %For each Subject
    
    clf
    close all
    clearvars -except INFO foldout subnum EEGpath Logpath sub
    
    %Display the Subject name
    if sub<10
        subjname=['pil0',sprintf('%s', num2str(sub))];
    else
        subjname=['pil',sprintf('%s', num2str(sub))];
    end
    
    fprintf('\n')
    disp('------------------')
    disp (['Analysis Part3: Rejecting ICA components for Subject: ' subjname])
    disp('------------------')
    fprintf('\n')
    
    %Load the saved information
    load([foldout,subjname],'data');
    load([foldout,subjname],'compcfg');
    load([foldout,subjname],'Output_preproc');
    goodchannel=Output_preproc.gooddchannel;
    
    %Recreate the components
    cfg=[];
    cfg.unmixing  = compcfg.unmixing;
    cfg.channel   = goodchannel;
    cfg.topolabel = compcfg.topolabel;
    comp = ft_componentanalysis(cfg, data);
    
    %% Looking for EOG artifacts
    
    %Create an average vEOG and hEOG channel
    %load EEG data
    trleog=data.sampleinfo;
    trleog(:,3)=0;
    EEGpath=[INFO.PATHS.datapath, 'EEG', filesep];
    dataname= [EEGpath, filesep,subjname,'.vhdr'];
    
    cfg = [];
    cfg.dataset             = dataname;
    cfg.preproc.demean      = 'yes';
    cfg.detrend             = 'yes';
    %cfg.channel             = {'vEOGup','vEOGdown','RHEOG','LHEOG'};
    cfg.trl                 = trleog;
    dataEOG              = ft_preprocessing(cfg);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Rearrange for subject 27!
    if strcmpi('pil27', subjname)==1
        %electrode 1-32 becomes 33-64
       [dataEOG]=ricbra_PCA14_rearrangeelec_sub27 (dataEOG);
       warning('rearranging EOG electrodes subject 27')
    end
    
    %Now I can select the correct ones.
    cfg=[];
    cfg.channel          = {'vEOGup','vEOGdown','RHEOG','LHEOG'};
    dataEOG              = ft_preprocessing(cfg,dataEOG);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %calculate a difference between the bipolar EOG channels
    for tr=1:size(dataEOG.trial,2)
        dataEOG.trial{1,tr}(1,:)=dataEOG.trial{1,tr}(1,:)-dataEOG.trial{1,tr}(2,:); %up-down
        dataEOG.trial{1,tr}(2,:)=dataEOG.trial{1,tr}(3,:)-dataEOG.trial{1,tr}(4,:); %L-R
        dataEOG.trial{1,tr}(3:4,:)=[];
    end
    dataEOG.label={'vEOG';'hEOG'};
    
    %Per trial: calculate a correlation between the EOG data and the different components
    for tr=1:size(dataEOG.trial,2) %for each trial
        for com=1:size(comp.unmixing,1) %for each component
            temp.corcoefV=corrcoef(comp.trial{1,tr}(com,:),dataEOG.trial{1,tr}(1,:));
            temp.corV(tr,com)= temp.corcoefV(2,1); %vertical
            temp.corcoefH=corrcoef(comp.trial{1,tr}(com,:),dataEOG.trial{1,tr}(2,:)); %horizontal;
            temp.corH(tr,com)=temp.corcoefH(2,1);
        end
    end
    %Calculate the average correlation
    cor_comeog_V=abs(mean(temp.corV,1))'; %mean over the first dimension (trls)
    cor_comeog_H=abs(mean(temp.corH,1))';
    
    %Plot this for a first inspection
    figure
    scatter([1:length(cor_comeog_H)],cor_comeog_H, 'b');
    num2str((1:length(cor_comeog_H))','%d');
    temp.labels = num2str((1:length(cor_comeog_H))','%d');
    text([1:length(cor_comeog_H)], cor_comeog_H, temp.labels, 'horizontal','left', 'vertical','bottom');
    hold on
    scatter([1:length(cor_comeog_V)],cor_comeog_V, 'r');
    num2str((1:length(cor_comeog_V))','%d');
    temp.labels = num2str((1:length(cor_comeog_V))','%d');
    text([1:length(cor_comeog_V)], cor_comeog_V, temp.labels, 'horizontal','left', 'vertical','bottom');
    
    disp('')
    input('Press Enter to continue')
    
    %Sort these values
    [cor_comeog_H,temp.posH]=sort(cor_comeog_H, 'descend'); %Sort on basis of correlation
    [cor_comeog_V,temp.posV]=sort(cor_comeog_V, 'descend');
    %Get the corresponding component labels
    comp_comeog_H=comp.label(temp.posH);
    comp_comeog_V=comp.label(temp.posV);
    
    %Export these correlations
    Varnames={'ComponentH','CorrelationHorizontal','ComponentV','CorrelationVertical'};
    M_Corr(:,1)=comp_comeog_H;
    M_Corr(:,2)=num2cell(cor_comeog_H);
    M_Corr(:,3)=comp_comeog_V;
    M_Corr(:,4)=num2cell(cor_comeog_V);
    
    DS_Corr=mat2dataset(M_Corr,'VarNames',Varnames);
    export(DS_Corr,'file',[foldout,subjname,'_CorrelationComponentsEOGChannels.txt'],'delimiter','\t')
    
    %Get one array for both correlations
    temp.Cor_all=[cor_comeog_H;cor_comeog_V];
    [temp.Cor_all,temp.posAll]=sort(temp.Cor_all, 'descend');
    
    temp.Comp_Cor_all=[comp_comeog_H;comp_comeog_V];
    temp.Comp_Cor_all=temp.Comp_Cor_all(temp.posAll); %correct order
    [temp.Comp_Cor_all, temp.posnew]=unique(temp.Comp_Cor_all, 'stable'); %determine order of occurance components
    
    temp.Cor_all=temp.Cor_all(temp.posnew);
    
    [temp.x,posCom]=ismember(temp.Comp_Cor_all,comp.label);
    
    % Plot the components for visual inspection
    
    % 20 components highest correlation Horizontal and Vertical
    figure
    cfg = [];
    cfg.component = [posCom(1:20)];       % specify the component(s) that should be plotted
    cfg.layout    = INFO.SUBJ.Eleclayout; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    ft_topoplotIC(cfg, comp)
    
    disp('')
    input('Press Enter to continue')
    
    %Rest of the components
    figure
    cfg = [];
    cfg.component = [posCom(21:length(posCom))];       % specify the component(s) that should be plotted
    cfg.layout    = INFO.SUBJ.Eleclayout; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    ft_topoplotIC(cfg, comp)
    
    disp('')
    input('Press Enter to continue')
    
    %% Looking for ECG artifacts
    
    %Usually within the first 20 components, so check these again
    figure
    cfg = [];
    cfg.component = [1:20];       % specify the component(s) that should be plotted
    cfg.layout    = INFO.SUBJ.Eleclayout; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    ft_topoplotIC(cfg, comp)
    
    disp('')
    input('Press Enter to continue')
    
    %In the end, plot the time course of all components again to check
    %whether the components you want to remove indeed look like artifacts
    %over time :)
    
    cfg = [];
    cfg.layout = INFO.SUBJ.Eleclayout; % specify the layout file that should be used for plotting
    cfg.viewmode = 'component'
    ft_databrowser(cfg, comp)
    
    disp('')
    input('Press Enter to continue')
    
    %Remove the bad components
    % remove the bad components and backproject the data
    
    rejcom=[];
    
    yn=input('Do you want to reject components? [y/n]','s');
    if strcmp(yn,'y')==1
        s=1;
        prompt = 'Which component do you want to reject [enter number between 1 and n]';
        rejcom(1) = input(prompt);
        t=2;
    elseif strcmp(yn,'n')==1
        s=0;
    else
        error ('Not a valid input')
    end
    
    while s==1
        yn=input('Do you want to reject another component? [y/n]','s');
        if strcmp(yn,'y')==1
            prompt = 'Which component do you want to reject? [enter number between 1 and n]';
            rejcom(t)=input(prompt);
            t=t+1;
        elseif strcmp(yn,'n')==1
            s=0;
        else
            error ('Not a valid input, starting again')
        end
    end
    
    close all
    disp('')
    disp('Rejecting the following components')
    rejcom
    disp('')
    yn=input('Press y to continue and n to stop','s')
    if strcmp(yn,'y')==1
        
    elseif strcmp(yn,'n')==1
        error ('Not the correct components, starting again')
    else
        error ('Not a valid input, starting again')
    end
    
    if ~isempty(goodchannel)
        %Select part of the data (disregard the NaNs for reconstruction)
        include=find(ismember(data.label,goodchannel));
        exclude=find(~ismember(data.label,goodchannel));
        tempdata=data;
        for trl=1:length(tempdata.trial)
            tempdata.trial{1,trl}(exclude,:)=[];
            tempdata.label=goodchannel;
        end
    else
        tempdata=data;
    end

    %Perform reconstruction
    cfg = [];
    cfg.component = rejcom; % to be removed component(s)
    cfg.channel = goodchannel
    tempcleandata = ft_rejectcomponent(cfg, comp, tempdata);
    
   if ~isempty(goodchannel)
        %Include the original data in here again
    cleandata=data;
   for trl=1:length(cleandata.trial) %for all trials
       in=1; 
          for ri=1:size(cleandata.trial{1,trl},1) %for all channels
              if isnan(cleandata.trial{1,trl}(ri,1))==0 %if its not a missing channel, replace, otherwise do nothing
                 cleandata.trial{1,trl}(ri,:)= tempcleandata.trial{1,trl}(in,:);
                 in=in+1;
              else
              end
          end
   end
    else
       cleandata=tempcleandata;
    end
    
    
    %save the rejected components
    save([foldout,subjname],'rejcom', '-append');
    %save the cleaned data
    save([foldout,subjname],'cleandata', '-append');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear variables except the following
clf
close all
clearvars -except INFO foldout subnum EEGpath Logpath

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FORTH LOOP THROUGH THE SUBJECTS: INTERPOLATE BAD CHANNELS, FINAL DATA CHECK, REJECTION OF TRIALS, REREFERNCING AND PERFORMING FFT

for sub=1:length(subnum) %sub=1:length(subnum) %For each Subject
   
clearvars -except INFO foldout subnum EEGpath Logpath tempsub SUBS sub


    if sub<10
        subjname=['pil0',sprintf('%s', num2str(sub))];
    else
        subjname=['pil',sprintf('%s', num2str(sub))];
    end
    
    fprintf('\n')
    disp('------------------')
    disp (['Analysis Part4: Interpolation, Rejection of trials, Rereferencing and FFT: ' subjname])
    disp('------------------')
    fprintf('\n')
    
    load([foldout,subjname],'cleandata')
    load([foldout,subjname],'Output_preproc');
    goodchannel=Output_preproc.gooddchannel;
    badchannel=Output_preproc.interpolatedchannel;
    
    %INTERPOLATE THE DATA
    
    if ~isempty(badchannel)
        %prepare layout
        cfg         = [];
        cfg.layout  = INFO.SUBJ.Eleclayout;
        layout = ft_prepare_layout(cfg, cleandata);
        
        %prepare neighborhood file
        if ~exist([foldout,'neighbours.mat'], 'file')
            cfg               = [];
            cfg.method        = 'triangulation'
            cfg.layout        = layout;
            %cfg.channel       = channel;
            cfg.feedback      = 'yes';
            neighbours = ft_prepare_neighbours(cfg, cleandata);
            %wait for button press
            disp('Check channel layout and press Enter to continue')
            input('')
            save([foldout,'neighbours.mat'], 'neighbours')
        else
            load([foldout,'neighbours.mat'], 'neighbours')
        end
        
        %perform interpolation of bad channels
        cfg                = [];
        cfg.method         = 'nearest';
        cfg.badchannel     = badchannel;
        cfg.missingchannel =[]; 
        cfg.layout         = layout;
        cfg.neighbours     = neighbours;
        [cleandata] = ft_channelrepair(cfg, cleandata);
    end
    
    %REJECT TRIALS, BASED ON SUMMARY OR BASED ON TRIAL VIEW
    cfg                       = [];
    cfg.method                = 'summary';                              % summary mode
    cfg.alim                  = 1e2;                                    % limits the y-axis
    cfg.keepchannel           = 'nan';                                  % when rejecting channels, values are replaced by NaN (helpful because it keeps the total number of channels consistent)
    cfg.preproc.bpfilter    = 'yes';
    cfg.preproc.bpfilttype  = 'but';
    cfg.preproc.bpfreq      = [1 45];
    cleandata              = ft_rejectvisual(cfg,cleandata);
    
    %Or based on visual inspection
    cfg                = [];
    cfg.method         = 'channel';                                  % all trials per channel
    cfg.keepchannel    = 'nan';                                      % when rejecting channels, values are replaced by NaN (helpful because it keeps the total number of channels consistent)
    cfg.preproc.bpfilter    = 'yes';
    cfg.preproc.bpfilttype  = 'but';
    cfg.preproc.bpfreq      = [1 45];
    cleandata       =  ft_rejectvisual(cfg,cleandata);
    
    %RE-REFERENCE THE DATA
    cfg=[];
    cfg.refchannel         = 'all'; %only use EEG channels
    cfg.preproc.reref      = 'yes';
    cfg.preproc.refchannel = 'all';
    cleandata=ft_preprocessing(cfg, cleandata);
    
    %CHECK TRIALS ONCE MORE
    cfg                = [];
    cfg.method         = 'trial';                                    % all channels per trial
    cfg.keepchannel    = 'nan';                                      % when rejecting channels, values are replaced by NaN (helpful because it keeps the total number of channels consistent)
    cfg.preproc.bpfilter    = 'yes';
    cfg.preproc.bpfilttype  = 'but';
    cfg.preproc.bpfreq      = [1 45];
    cleandata        =  ft_rejectvisual(cfg,cleandata);
    
    %SAVE STUFF
    % Save the data of the participant
    save([foldout,subjname],'cleandata', '-append')
    
    % Add information on trials to preprocessing output
    load([foldout,subjname],'Output_preproc')
    %2. trials:
    load([foldout,subjname],'Output_trialfun')
    Orig=Output_trialfun.trlfinalall(:,1);
    
    New=cleandata.sampleinfo(:,1);
    rejectedtrls=~ismember(Orig,New);
    Output_preproc.rejectedtrls=rejectedtrls;
    
    save([foldout,subjname],'Output_preproc', '-append');
    
        %% FFT analysis of the data
        trial_cond.step1 = find(ismember(cleandata.trialinfo(:,2),1)==1);
        trial_cond.step2 = find(ismember(cleandata.trialinfo(:,2),2)==1);
        trial_cond.step3 = find(ismember(cleandata.trialinfo(:,2),3)==1);
        trial_cond.fix = find(ismember(cleandata.trialinfo(:,2),55)==1);
    
        %OLD FFT SETTINGS WHICH GIVE INCONSISTENT FREQUENCY SPECTRUMS FOR
        %FIXATION AND CONDITION TRIALS. DO NOT USE ANYMORE
        % %         cfg = [];
        % %         cfg.method = 'mtmfft';
        % %         cfg.output = 'pow';
        % %         cfg.taper  = 'hanning';
        % %         cfg.foi = [1:45];
        
        %NEW CORRECTED SETTINGS
        cfg = [];
        cfg.method = 'mtmfft';
        cfg.output = 'pow';
        cfg.taper  = 'hanning';
        cfg.foilim = [1,45];
        cfg.pad = 1.201; %the conditions in my case are 1.201(1201 samples) and I need my fixation (1000 samples) to the padded to the same length
        
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
        save([foldout,subjname],'FFT', '-append')
    
    
                % PRESS BUTTON BEFORE CONTINUING WITH NEW SUBJECT
                disp('Press any key to continue')
                input('')
end

clf
close all
clearvars -except INFO

IncludeSubs={'pil03','pil04','pil05','pil06','pil07','pil08','pil09','pil10','pil11','pil12','pil13','pil14','pil15','pil16','pil17','pil19','pil20','pil21','pil22','pil23', 'pil24','pil25','pil26','pil27','pil28','pil29','pil30','pil31'};
%Create grand average
GA=ricbra_PCA14_GA(INFO, IncludeSubs);

%Select Data
%Next, we select the specific frequencies of interest and regions of interest
%and export an average for this (per participant) from the data

%ROI={'O1','Oz','O2'};
%ROI={'F3','Fz','F4'};
%ROI={'C3','Cz','C4'};
ROI={'Cz'};

%FOI=[7,12]; %Mu:7-12Hz, Beta:16-25Hz
FOI=[16,25]; %Beta, PG experiment

[Results_incFix]=ricbra_PCA14_Results_incFix(GA,ROI,FOI); %Absoulte values
[Results]=ricbra_PCA14_Results(GA,ROI,FOI); %Relative to Fixation cross


ricbra_PCA14_Plot_Results(Results,ROI,FOI);
ricbra_PCA14_Plot_Results(Results_incFix,ROI,FOI);

%Create Topoplot of the data
condname={'step1','step2','step3'};
ricbra_PCA14_Topoplot(GA,FOI,INFO.SUBJ.Eleclayout,condname)



