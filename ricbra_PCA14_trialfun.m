function [trl, event]=ricbra_PCA14_trialfun(cfg);
%Version: 02-Sep-2015b

INFO= cfg.INFO;
sub=cfg.sub;

%% Read in the data and select the parts with the markers
% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);
% search for "trigger" events
value  = {event(find(strcmp(INFO.MARKER.type, {event.type}))).value}';
sample = [event(find(strcmp(INFO.MARKER.type, {event.type}))).sample]';


%% Select only values in which the right trigger occured
% indicating the start of the trial (condition marker)
%Offset
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

trlall = [];
for j = 1:length(value)-1
    trg1 = value(j);
    trg2 = value(j+1);
    if sum(strcmp(trg1,cfg.trialdef.eventvaluebegin))==1 && sum(strcmp(trg2,cfg.trialdef.eventvalueend))==1
        %Here we want to select the three trials.
        %Therefore we need the timing of the three Action steps from the
        %info file
       
        stepname={'Step1','Step2','Step3'};
        
        for i=1:3
          marker   = str2num(trg1{1}(2:end));
          pos=find (INFO.EXP.Videos==marker);
          offset=INFO.EXP.Timing.(stepname{i}){pos};
          offset=offset/1000; %in seconds
          offset=round(offset * hdr.Fs);%in samples
         
        trlbegin = sample(j)+offset+pretrig;
        trlend   = sample(j)+offset+posttrig;
        offsettrl   = posttrig;
        step     = i;
        newtrl   = [trlbegin trlend offsettrl marker step];
        trlall   = [trlall; newtrl];
        end
    end
end

% %% In case specific trials need to be excluded because of some reason, exclude those
% if ~isnan(INFO.SITE{sit,1}.SUBJ.Excludetrials{sub})
%     autoex=INFO.SITE{sit,1}.SUBJ.Excludetrials{sub};
%     KeepTrial(autoex,1)=0;
% end

%%save this information and output the selected trials
Output_trialfun.trlall=trlall;
Output_trialfun.trlfinal=trlall;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Fixation trials
trlallfix = [];
INFO= cfg.INFO;
%% Read in the data and select the parts with the markers
% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "trigger" events
value  = {event(find(strcmp(INFO.MARKER.type, {event.type}))).value}';
sample = [event(find(strcmp(INFO.MARKER.type, {event.type}))).sample]';

%Offset
pretrig  = -round(cfg.trialdef.prestimfix  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststimfix * hdr.Fs);

%% Select only values in which the fixation was followed by a real video (exclude catch trials)
% indicating the start of the trial (condition marker)
for j = 1:length(value)-2
    trg1 = value(j);
    trg2 = value(j+1);
    trg3 = value(j+2);
    if sum(strcmp(trg1,cfg.trialdef.eventvaluefix))==1 && sum(strcmp(trg2,cfg.trialdef.eventvaluebegin))==1&& sum(strcmp(trg3,cfg.trialdef.eventvalueend))==1
        trlbegin = sample(j) +pretrig;
        trlend   = trlbegin +posttrig;
        offset   = 0;
        marker   = str2num(trg1{1}(2:end));
        step     = 55;
        newtrl   = [trlbegin trlend offset marker step];
        trlallfix   = [trlallfix; newtrl];
    end
end

% Check that the number of trials and trial order corresponds to the number of trials
% according to the output file
if ~isequal(length(trlallfix), length(trlall)/3)
    disp ('Selected trials:')
    trlallfix(:,4)
    error('not the same amount of fixation trials and number of trials, please check')
end

%%Create trl containing fixation and condition trials
trl=[trlall;trlallfix];

%Sort the trials
[values, order] = sort(trl(:,1));
trl= trl(order,:);

% Check that the number of trials is equal to 4x56 (which is 3x twice the number
% of videos (28, one for each action step), plus one fixation cross per video)

if cfg.sub~=23 %sub 23 misses the first trial
if ~isequal(length(trl),4*56)
    disp ('Number of trials:')
    length(trl)
    error('Trial number is unequal to the total number of trials the participant should have watched, please check')
end
end

%%save this information and output the selected trials
Output_trialfun.trlallfix=trlallfix;
Output_trialfun.trlfinalfix=trlallfix;
Output_trialfun.trlfinalall=trl;

if ~exist([INFO.PATHS.out, filesep, filesep], 'dir')
    mkdir([INFO.PATHS.out, filesep, filesep]);
end
save([INFO.PATHS.out, filesep,cfg.subjname],'Output_trialfun');

