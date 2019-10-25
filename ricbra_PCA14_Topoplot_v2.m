function ricbra_PCA14_Topoplot_v2(GA,FOI,lay,cond, name)
close all

%Plotting Conditional Differences in relative power
for fig=1:3
    if fig==1
        data=GA.step1.BaselinecorrectedFreqGA;
        data.powspctrm=GA.step1.BaselinecorrectedFreqGA.powspctrm-GA.step2.BaselinecorrectedFreqGA.powspctrm;
        tit=(['Condition: ' name, ' Step1-Step2,', num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
    elseif fig==2
        data=GA.step1.BaselinecorrectedFreqGA;
        data.powspctrm=GA.step1.BaselinecorrectedFreqGA.powspctrm-GA.step3.BaselinecorrectedFreqGA.powspctrm;
        tit=(['Condition: ' name,' Step1-Step3,' num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
    else
        data=GA.step1.BaselinecorrectedFreqGA;
        data.powspctrm=GA.step2.BaselinecorrectedFreqGA.powspctrm-GA.step3.BaselinecorrectedFreqGA.powspctrm;
        tit=(['Condition: ' name,' Step2-Step3,' num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
    end
    figure(fig)
    cfg = [];
    cfg.interactive = 'yes';
    cfg.xlim = [FOI];
    cfg.layout = lay;
    cfg.parameter = 'powspctrm';
    cfg.colorbar = 'yes';
    cfg.zlim=[-.05, 0.15]%'maxmin';
    cfg.marker = 'labels'
     ft_topoplotTFR(cfg, data);
    title (tit)
    
end

% %Plotting the individual conditions
% for c=1:length(cond)
%
%     data=GA.(cond{c}).BaselinecorrectedFreqGA;
%
% cfg = [];
% cfg.interactive = 'yes';
% cfg.xlim = [FOI];
% cfg.layout = lay;
% cfg.parameter = 'powspctrm';
% cfg.colorbar = 'yes';
% cfg.zlim=[-0.5 -0.25]%'maxmin';
% cfg.marker = 'labels'
%
%
% figure(c)
% ft_topoplotTFR(cfg, data);
% title ([cond{c},' ' num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
%
% end

% % Plotting absolute power difference
% for fig=1:3
%     if fig==1
%         data=GA.step1.FreqDesc;
%         data.powspctrm=GA.step1.FreqDesc.powspctrm-GA.step2.FreqDesc.powspctrm;
%         tit=(['Step1-Step2,', num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
%     elseif fig==2
%         data=GA.step1.FreqDesc;
%         data.powspctrm=GA.step1.FreqDesc.powspctrm-GA.step3.FreqDesc.powspctrm;
%         tit=(['Step1-Step3,' num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
%     else
%         data=GA.step1.FreqDesc;
%         data.powspctrm=GA.step2.FreqDesc.powspctrm-GA.step3.FreqDesc.powspctrm;
%         tit=(['Step2-Step3,' num2str(FOI(1)), '-' num2str(FOI(2)) 'Hz'])
%     end
%     figure(fig)
%     cfg = [];
%     cfg.interactive = 'yes';
%     cfg.xlim = [FOI];
%     cfg.layout = lay;
%     cfg.parameter = 'powspctrm';
%     cfg.colorbar = 'yes';
%     cfg.zlim=[-0.05, 0.15] %'maxmin';
%     cfg.marker = 'labels'
%      ft_topoplotTFR(cfg, data);
%     title (tit)
%     
% end
