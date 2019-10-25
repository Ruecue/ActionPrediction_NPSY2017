function [dataout]= ricbra_PCA14_rearrangeelec_sub27 (datain)

dataout=datain;

for trl=1:length(datain.trial)
    dataout.trial{1,trl}([1:32],:)=datain.trial{1,trl}([33:64],:);
    dataout.trial{1,trl}([33:64],:)=datain.trial{1,trl}([1:32],:);
end