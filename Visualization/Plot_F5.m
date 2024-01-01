load('F5_EconomicValue_2.mat',"VS_NWM",'probab','VS_ECN_All',"VS_ECN_1",'QRP_All','VS_ECN_Ep');
load('R2.DataColection.mat',"info","ReportData","NameS");
load('F5.Eco_Analysed.mat',"VALUES","VALUES_ens");
close all
figure1 = figure('OuterPosition',[300 100 1200 700]);
NameF = ["\bfa\rm R_p = 5-year";"\bfb\rm R_p = 10-year";"\bfc\rm R_p = 20-year"];
k=0;
Ret = [1, 2, 3];
LT = [1, 5, 10];
CLR = ([3:2:19]);
for i=1:3
    for j=1:9
        axes1 = axes('Parent',figure1,...
            'Position',[0.06+(j-1)*0.28/9 + (i-1)*0.32 0.6 0.28/9 0.3]);hold on;
        Data = VALUES{Ret(i),LT(1)}(CLR(j),:,1);
        Data(Data==1)=0;
        Data2 = VALUES{Ret(i),LT(1)}(CLR(j),:,3);
        Data2(Data2>1)=1;
        Data4 = VALUES{Ret(i),LT(1)}(CLR(j),:,2);
        Data4(Data4>1)=1;
        for ens = 1:16
            Data3 = VALUES_ens{Ret(i),LT(1)}(CLR(j),:,ens);
            Data3(Data3>1)=1;
            MediAnValue_ens(ens,j,i) = median(Data3);
        end
        [f,xi] = ksdensity(Data(:),'Bandwidth',0.05);
        MaxF = max(f);
        area(xi,f,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5],'FaceAlpha',0.5);
        [f,xi] = ksdensity(Data2(:),'Bandwidth',0.05);
        area(xi,f,'FaceColor',[0.8500 0.3250 0.0980],'EdgeColor',[0.8500 0.3250 0.0980],'FaceAlpha',0.5);
        plot(median(Data),0,'Marker','o','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5])
        plot(MediAnValue_ens(end,j,i),0,'Marker','o','Color',[0.8500 0.3250 0.0980],'MarkerFaceColor',[0.8500 0.3250 0.0980])
        plot(median(Data4),0,'Marker','o','Color',[0.5 0.5 0.5],'MarkerFaceColor',[0 0.4470 0.7410])
        MediAnValue(j,i,1) = median(Data);
        MediAnValue(j,i,2) = median(Data2);
        MediAnValue(j,i,3) = median(Data4);
        SumValue(j,i,1) = sum(Data);
        SumValue(j,i,2) = sum(Data2);
        SumValue(j,i,3) = sum(Data4);
        SumRatio(j,i) = sum(Data2)/sum(Data);
        xlim([-0.2 1]);
        ylim([0 MaxF])
        if j>1
            set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',14,'XColor',[0.7 0.7 0.7],'ytick',[0],'XTick',[-0.2:0.2:1],'XTickLabel',[],'YTickLabel',num2str(j*0.1));
        else
            set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',14,'ytick',[0],'XTick',[-0.2:0.2:1],'YTickLabel',num2str(j*0.1));
        end
        if j==1
            title(NameF{i},'FontSize',14,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';
        end
        if i==3 && j==9
            legend(["NWM","NWM-ECN"],'box','off','Position',[0.79724941025396 0.9 0.181587834993528 0.0512820499888539],...
                'Orientation','horizontal');
        end
        view(axes1,[90 -90]);
        if i==1 && j==1
            xlabel('{\itVS} [-]')
        end
        if j==5
            ylabel('Cost/Loss ratio [-]')
        end
    end
    SumAllRatio(i) = sum(SumValue(:,i,2))/sum(SumValue(:,i,1));
end
for i=1:3
    axes1 = axes('Parent',figure1,...
        'Position',[0.06+(i-1)*0.32 0.6 0.25 0.3]);hold on;
    plot([0.1:0.1:0.9],(MediAnValue(:,i,1)),'LineWidth',4,'Color',[0.5 0.5 0.5]);
    plot([0.1:0.1:0.9],MediAnValue_ens(end,:,i) ,'LineWidth',2,'Color',[0.8500 0.3250 0.0980]);
    plot([0.1:0.1:0.9],(MediAnValue(:,i,3)),'LineWidth',2,'Color',[0 0.4470 0.7410]);
    xlim([0.1 0.9]);ylim([-0.2 1])
    set(axes1,'Color','None','XColor','None','YColor','None');
end
EnSize = [1,5,10,20,30,50,100:100:1000];
newcolors = [0.5 0.5 0.5; 0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840; 0 0 0];
NameF = ["\bfd\rm R_p = 5-year";"\bfe\rm R_p = 10-year";"\bff\rm R_p = 20-year"];
for i=1:3
    axes1 = axes('Parent',figure1,...
        'Position',[0.06+(i-1)*0.32 0.15 0.28 0.3]);hold on;
    area(EnSize,MediAnValue_ens(:,:,i),'FaceAlpha',0.5);
    colororder(newcolors)
    xlabel('Ensemble size');
    if i==1
        ylabel('{\itVS} [-]')
    end
    ylim([0 1.6])
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',14,'XScale','log');
    title(NameF{i},'FontSize',14,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';
    if i==3
        legend(["C/L=0.1","C/L=0.2","C/L=0.3","C/L=0.4","C/L=0.5","C/L=0.6"],'Box',"off",...
            'Position',[0.871058559867444 0.241887306971591 0.0869932419343574 0.228171327950731]);
    end
end
exportgraphics(figure1,"Figure_5.jpeg",'Resolution',600)
exportgraphics(figure1, "Figure_5.pdf", 'ContentType', 'vector');