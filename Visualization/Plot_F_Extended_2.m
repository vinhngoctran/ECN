load('F5.Eco_Analysed.mat',"VALUES","VALUES_ens");
k=0;
Ret = [1, 2, 3];
LT = [1, 5, 10];
CLR = ([3:2:19]);
for i=1:3
    for j=1:9
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
        MediAnValue(j,i,1) = median(Data);
        MediAnValue(j,i,2) = median(Data2);
        MediAnValue(j,i,3) = median(Data4);
        
        SumValue(j,i,1) = sum(Data);
        SumValue(j,i,2) = sum(Data2);
        SumValue(j,i,3) = sum(Data4);
        

        SumRatio(j,i) = (sum(Data2)-sum(Data))/sum(Data)*100;
        CSumRatio(j,i) = (sum(SumValue(1:j,i,2))-sum(SumValue(1:j,i,1)))/sum(SumValue(1:j,i,1))*100;
    end
    SumAllRatio(i) = sum(SumValue(:,i,2))/sum(SumValue(:,i,1));
end
TTT = ["a","b"];
close all
figure1 = figure('OuterPosition',[300 100 1200 700]);
NameF = ["R_p >= 5-year";"R_p >= 10-year";"R_p >= 20-year"];
for i=1:2
    axes1 = axes('Parent',figure1,...
        'Position',[0.1+(i-1)*0.45 0.15 0.37 0.4]);hold on;
    for j=1:3
        if i==1
        plot([0.1:0.1:0.9],SumRatio(:,j) ,'LineWidth',4,"DisplayName",NameF{j});
        else
            plot([0.1:0.1:0.9],CSumRatio(:,j) ,'LineWidth',4,"DisplayName",NameF{j});
        end
    end
    if i==1
        legend('Location','best','Box','off')
    end
    xlim([0.1 0.9])
    ylabel('Difference_{NWM-ECN/NWM} [%]')
    if i==2
        ylabel('Cumulative difference [%]')
    end
    xlabel('Cost/Loss ratio [-]')
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',14,'Xtick',[0.1:0.1:0.9])
    title(TTT{i},'FontSize',17,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';
end
exportgraphics(figure1,'Figure_E2.jpeg",'Resolution',600)
exportgraphics(figure1, "Figure_E2.pdf", 'ContentType', 'vector');