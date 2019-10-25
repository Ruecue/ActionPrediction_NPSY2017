function [GA_FFT_]=ricbra_PCA14_GA(INFO, IncludeSubs)

foldin=[INFO.PATHS.out , 'Input_GA', filesep];
%% Read in the FFT data and create a grand average
cond={'step1';'step2';'step3';'fix'};
clear FFT_data_all;

for sub=1:length(IncludeSubs)
    FFT=[];
    %load FFT Data
    subjname= IncludeSubs{sub};
    load([foldin,subjname],'FFT')
    %Put in one variable
    for j=1:length(cond)
        %average the data across electrode groups
        FFT_data_all.(cond{j}){sub,1}=FFT.(cond{j});
    end
end

%% Create grand average

    cond=fields(FFT_data_all);
    
    for j=1:length(cond)
       FFT_temp=FFT_data_all.(cond{j});
        %Grand average
        cfg=[];
        cfg.parameter='powspctrm';
        cfg.keepindividual = 'yes';
        GA_FFT_.(cond{j}).FreqGA=ft_freqgrandaverage(cfg,FFT_temp{:,1});
        %Variances and descriptives
        cfg = [];
        cfg.variance      = 'yes';
        GA_FFT_.(cond{j}).FreqDesc=ft_freqdescriptives(cfg,GA_FFT_.(cond{j}).FreqGA);
        
    end
    
    %Baseline corrected version
    cond=cond(find(~ismember(cond,'fix')));
    for j=1:length(cond)
        %Grand average
        GA_FFT_.(cond{j}).BaselinecorrectedFreqGA=GA_FFT_.(cond{j}).FreqGA;
        GA_FFT_.(cond{j}).BaselinecorrectedFreqGA.powspctrm=log(GA_FFT_.(cond{j}).FreqGA.powspctrm./GA_FFT_.fix.FreqGA.powspctrm);
        %Variances and descriptives
        cfg = [];
        cfg.variance      = 'yes';
        GA_FFT_.(cond{j}).BaselinecorrectedFreqDesc = ft_freqdescriptives(cfg,GA_FFT_.(cond{j}).BaselinecorrectedFreqGA);
    end



