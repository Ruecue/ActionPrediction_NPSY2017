function ricbra_PCA14_Plot_Results_v2(Results,ROI,FOI, name)

clearvars -except INFO FOI GA ROI Results name
clf

%Plot Average results
%     Mean=zeros(length(cond),length(cond));
%     SD=zeros(length(cond),length(cond));
    tempcond=fields(Results)
    
    if ismember('fix',tempcond)==1 %if fixation trials as well
       tempRes=Results;
     colors=[0,0.8,1;1,0.8,0;0,0.8,0;0.8,0,0];
    else
        tempRes=Results;
        colors=[1,0.8,0;0,0.8,0;0.8,0,0];
    end
    
     cond=fields(tempRes);
    for co=1:length(cond);
        Mean(1,co,:)=mean(cell2mat(tempRes.(cond{co})));
        SD(1,co,:)=std(cell2mat(tempRes.(cond{co})));
    end
    bar_handle=barweb(Mean,SD)
 
    xlabel(['Conditions'])
   
    legend(cond);
    title(['Condition ' name, ' n= ' num2str(length(Results.(cond{co}))), ', ' ROI{:}, ', ' num2str(FOI(1)),'-', num2str(FOI(2)),' Hz'])
    ylim('auto')
    xlim([0.5,1.5])
    set(gca,'xtick',[])
   
    if length(cond)==3
     ylabel('Mean Relative Frequency Power')
   else
     ylabel('Mean Absolute Frequency Power')
   end
    fig=['Condition: ' name ' Mean_Power_',ROI{:}, '_' num2str(FOI(1)),'-', num2str(FOI(2)),' Hz'];
    for co=1:length(cond);
        set(bar_handle.bars(co),'FaceColor',colors(co,:));
    end
end