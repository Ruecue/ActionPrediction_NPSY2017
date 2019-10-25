function [p_info]=ricbra_PCA14_Info();
%Version: 02-Sep-2015b


%% Information that is common to all sites

%OnCluster
p_info.PATHS.scripts     = ['']; %Add path to your scripts
p_info.PATHS.ft          = ['']; %Add path to fieldtrip
p_info.PATHS.datapath    = ['']; %Add path to your data
p_info.PATHS.out         = ['']; %Add path to where you want to store your output
p_info.PATHS.outbehavior = ['']; %Add path to where you want to store behavioral output

%Participant information
p_info.SUBJ.ETname = {'_pca14_1.idf'};
p_info.SUBJ.Logname = {'_sub1_PCA_log.txt'};
p_info.SUBJ.Eleclayout     = [p_info.PATHS.scripts, 'Layout', filesep, '', 'elec1010.lay']; %path to the folder with the .lay file

%Information on EEG markers and layout
p_info.MARKER.type= 'Stimulus';
p_info.MARKER.Videos = {'S101', 'S102','S103', 'S104','S105', 'S106','S107', 'S108','S109', 'S110','S111', 'S112','S113','S201', 'S202','S203', 'S204','S205', 'S206','S207', 'S208','S209', 'S210','S211', 'S212','S213','S214', 'S215','S216'};
p_info.MARKER.Fix         = {'S 10'};
p_info.MARKER.Resting.start  = {'S250','S252'};
p_info.MARKER.Resting.end   = {'S251','S253'};
p_info.MARKER.End   = {'S 40'};
p_info.MARKER.TrialInfo.Videos  = [101:113,201:216];
p_info.MARKER.TrialInfo.End  = [40];
p_info.MARKER.TrialInfo.Catch   = [31:38];
p_info.MARKER.TrialInfo.Fix     = [10];

% Markers Main Experiment:
%     10= begin fixation
%     20= new block
%     31-38,101-113, 201-216= begin filmpje
%     40= end filmpje
%     75= vraag
% Markers Resting State:
%     250-253= resting markers 250=eyesopenbegin,251=eyesopenend, 252=eyesclosedbegin, 253=eyesclosedend


%Information on Experimental Markers and Timing per Video
p_info.EXP.Videos(1,1)=31;
p_info.EXP.Videos(2,1)=32;
p_info.EXP.Videos(3,1)=33;
p_info.EXP.Videos(4,1)=34;
p_info.EXP.Videos(5,1)=35; 
p_info.EXP.Videos(6,1)=36;
p_info.EXP.Videos(7,1)=37;
p_info.EXP.Videos(8,1)=38;
p_info.EXP.Videos(9,1)=101;
p_info.EXP.Videos(10,1)=102;
p_info.EXP.Videos(11,1)=103;
p_info.EXP.Videos(12,1)=104;
p_info.EXP.Videos(13,1)=105;
p_info.EXP.Videos(14,1)=106;
p_info.EXP.Videos(15,1)=107;
p_info.EXP.Videos(16,1)=108;
p_info.EXP.Videos(17,1)=109;
p_info.EXP.Videos(18,1)=110;
p_info.EXP.Videos(19,1)=111;
p_info.EXP.Videos(20,1)=112;
p_info.EXP.Videos(21,1)=113; 
p_info.EXP.Videos(22,1)=201;
p_info.EXP.Videos(23,1)=202;
p_info.EXP.Videos(24,1)=203;
p_info.EXP.Videos(25,1)=204;
p_info.EXP.Videos(26,1)=205;
p_info.EXP.Videos(27,1)=206;
p_info.EXP.Videos(28,1)=207;
p_info.EXP.Videos(29,1)=208;
p_info.EXP.Videos(30,1)=209;
p_info.EXP.Videos(31,1)=210;
p_info.EXP.Videos(32,1)=211;
p_info.EXP.Videos(33,1)=212;
p_info.EXP.Videos(34,1)=213;
p_info.EXP.Videos(35,1)=214;
p_info.EXP.Videos(36,1)=216;

%ter info: video 215 was excluded prior to the experiment

%Corresponding timing of first action
p_info.EXP.Timing.Step1={NaN;
NaN;
NaN;
NaN;
NaN; 
NaN;
NaN;
NaN;
3200;
2880;
2680;
4040;
3120;
2840;
2760;
2720;
2960;
2720;
2760;
3280;
3120;
3200;
3440;
3320;
3320;
2720;
3120;
3160;
3000;
3080;
3120;
3040;
3280;
2800;
3600;
3120};

%Corresponding timing of second action
p_info.EXP.Timing.Step2={NaN;
NaN;
NaN;
NaN;
NaN; 
NaN;
NaN;
NaN;
7000;
6440;
6120;
7400;
6160;
6600;
5960;
6000;
6680;
6760;
6360;
7080;
7240;
6920;
6880;
6360;
6560;
6160;
6160;
6560;
6160;
5720;
6600;
6480;
6800;
6600;
6920;
6440};

%Corresponding timing of third action
p_info.EXP.Timing.Step3={NaN;
NaN;
NaN;
NaN;
NaN; 
NaN;
NaN;
NaN;
14640;
13680;
13720;
14520;
13840;
15400;
13400;
13760;
14440;
13880;
13720;
13920;
14800;
14080;
13680;
13840;
14120;
13920;
13920;
14800;
14240;
12680;
13720;
13240;
13800;
13640;
14640;
13480};


