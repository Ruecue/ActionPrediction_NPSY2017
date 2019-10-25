function [Table_GA_FFT_,Mouth_GA_FFT_]=ricbra_PCA14_GA_TvsM(INFO, IncludeSubs)

foldin=[INFO.PATHS.out , 'ExtraFFT', filesep];
%% Read in the FFT data and create a grand average
cond={'step1';'step2';'step3';'fix'};
clear FFT_data_all;

for sub=1:length(IncludeSubs)
    FFT_Table=[];
    FFT_Mouth=[];
    %load FFT Data
    subjname= IncludeSubs{sub};
    load([foldin,subjname],'FFT_Table')
    load([foldin,subjname],'FFT_Mouth')
    %Put in one variable
    for j=1:length(cond)
        %average the data across electrode groups
        Table_FFT_data_all.(cond{j}){sub,1}=FFT_Table.(cond{j});
        Mouth_FFT_data_all.(cond{j}){sub,1}=FFT_Mouth.(cond{j});
    end
end

%% Create grand average

%Table
    cond=fields(Table_FFT_data_all);
    
    for j=1:length(cond)
       FFT_temp=Table_FFT_data_all.(cond{j});
        %Grand average
        cfg=[];
        cfg.parameter='powspctrm';
        cfg.keepindividual = 'yes';
        Table_GA_FFT_.(cond{j}).FreqGA=ft_freqgrandaverage(cfg,FFT_temp{:,1});
        %Variances and descriptives
        cfg = [];
        cfg.variance      = 'yes';
         Table_GA_FFT_.(cond{j}).FreqDesc=ft_freqdescriptives(cfg, Table_GA_FFT_.(cond{j}).FreqGA);
    end

 %Mouth
     cond=fields(Mouth_FFT_data_all);
    
    for j=1:length(cond)
       FFT_temp=Mouth_FFT_data_all.(cond{j});
        %Grand average
        cfg=[];
        cfg.parameter='powspctrm';
        cfg.keepindividual = 'yes';
        Mouth_GA_FFT_.(cond{j}).FreqGA=ft_freqgrandaverage(cfg,FFT_temp{:,1});
        %Variances and descriptives
        cfg = [];
        cfg.variance      = 'yes';
         Mouth_GA_FFT_.(cond{j}).FreqDesc=ft_freqdescriptives(cfg, Mouth_GA_FFT_.(cond{j}).FreqGA);
    end
    
    
    %Baseline corrected version Table
    cond=cond(find(~ismember(cond,'fix')));
    for j=1:length(cond)
        %Grand average
        Table_GA_FFT_.(cond{j}).BaselinecorrectedFreqGA=Table_GA_FFT_.(cond{j}).FreqGA;
        Table_GA_FFT_.(cond{j}).BaselinecorrectedFreqGA.powspctrm=log(Table_GA_FFT_.(cond{j}).FreqGA.powspctrm./Table_GA_FFT_.fix.FreqGA.powspctrm);
        %Variances and descriptives
        cfg = [];
        cfg.variance      = 'yes';
        Table_GA_FFT_.(cond{j}).BaselinecorrectedFreqDesc = ft_freqdescriptives(cfg,Table_GA_FFT_.(cond{j}).BaselinecorrectedFreqGA);
    end

    %Baseline corrected version Mouth
    cond=cond(find(~ismember(cond,'fix')));
    for j=1:length(cond)
        %Grand average
        Mouth_GA_FFT_.(cond{j}).BaselinecorrectedFreqGA=Mouth_GA_FFT_.(cond{j}).FreqGA;
        Mouth_GA_FFT_.(cond{j}).BaselinecorrectedFreqGA.powspctrm=log(Mouth_GA_FFT_.(cond{j}).FreqGA.powspctrm./Mouth_GA_FFT_.fix.FreqGA.powspctrm);
        %Variances and descriptives
        cfg = [];
        cfg.variance      = 'yes';
        Mouth_GA_FFT_.(cond{j}).BaselinecorrectedFreqDesc = ft_freqdescriptives(cfg,Mouth_GA_FFT_.(cond{j}).BaselinecorrectedFreqGA);
    end


