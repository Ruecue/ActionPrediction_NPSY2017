# ActionPrediction_NPSY2017_EEG
EEG Data Analysis Scripts for the 2017 Neuropsychologia paper Predictability of action sub-steps modulates motor system activation during the observation of goal-directed actions.10.1016/j.neuropsychologia.2017.07.009

#Overview of the listed scripts for the EEG analysis (excluding the FieldTrip scripts):

#
ricbra_PCA14_MainAnalysis_v4 		# Main analysis script you should run
%calls
ricbra_PCA14_Info 			% Contains information on your data and paths
ricbra_PCA14_trialfun 			% Trial definition function needed for the fieldtrip part
ricbra_PCA14_rearrangeelec_sub27 	% You probably dont need this but for one of my subjects there were electrodes I needed % to rearrange

ricbra_PCA14_GA 			%Grant Average analysis
ricbra_PCA14_Results_incFix 		%Results using absolute values
ricbra_PCA14_Results 			%Results using values relative to fixation

ricbra_PCA14_Plot_Results 		%Plots results
ricbra_PCA14_Topoplot 			%Plots a topoplot of the Results


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ricbra_PCA14_TvsM 			% Script to analyze table vs Mouth trials
%calls 
ricbra_PCA14_Info 			% Contains information on your data and paths
ricbra_PCA14_Plot_Results_v2		% Adapted version of the Results script
ricbra_PCA14_GA_TvsM			% Adapted version of the GA script
ricbra_PCA14_Topoplot_v2		% Adapted version of the topoplot script


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ricbra_PCA14_BehavioralResults 		% Script for the behavioral results 
%calls
ricbra_PCA14_Info 			% Contains information on your data and paths
