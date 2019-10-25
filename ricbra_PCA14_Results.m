function [Results]=ricbra_PCA14_Results(GA,ROI,FOI)


Cond=fields(GA);
Cond=Cond(find(~ismember(Cond,'fix')));
for co=1:length(Cond)
    GAtemp=GA.(Cond{co}).BaselinecorrectedFreqGA;
    
    %Find the Electrode position
    elecpos=find(ismember(GAtemp.label,ROI))';
    
    %Find the Frequency of interest
    freqbegin=min(find(GAtemp.freq>FOI(1)));
    freqend=max(find(GAtemp.freq<FOI(2)));
    
    %Average
    for pa=1:size(GAtemp.powspctrm,1)
        if size(elecpos,1)==1
            tempres=squeeze((GAtemp.powspctrm(pa, elecpos,:)));
        else
        tempres=squeeze(mean(GAtemp.powspctrm(pa, elecpos,:)));
        end
        tempres=mean(tempres([freqbegin:freqend]));
        %Output
        Results.(Cond{co}){pa,1}=tempres;
    end
    
end
