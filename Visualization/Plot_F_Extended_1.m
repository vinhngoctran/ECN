clear all; close all; clc
load('R3-F5_Event.mat');
load('R2.DataColection.mat',"info","ReportData","NameS");
figure1 = figure('OuterPosition',[300 100 1200 1000]);
k=0;
for i=1:5
    for j=1:5
        k=k+1;
        POSS(k,:) = [0.055+(j-1)*0.19 0.84-(i-1)*0.195 0.15 0.12];
        POSS2(k,:) = [0.22+(j-1)*0.19 0.835-(i-1)*0.195 0.107263510568521 0.0381895325224336];
        POSS3(k,:) = [0.055+(j-1)*0.19 0.9-(i-1)*0.195 0.07 0.0622347934748529];
        POSS4(k,:) = [0.12+(j-1)*0.19 0.855-(i-1)*0.195 0.1 0.106506363488998];
    end
end
i=0;
for k=1:37
        if Datacheck(k)==1
            i=i+1;
            axes1 = axes('Parent',figure1,...
                'Position',POSS(i,:));hold on;
            plot(EventTime(:,k),Obs_NWM(:,:,k),'LineWidth',1);
            colororder([0 0 0;0 0.4470 0.7410]);
            lowerb = prctile(ML(:,:,1,k)',5);
            upperb = prctile(ML(:,:,1,k)',95);
            XData1=[EventTime(:,k)',fliplr(EventTime(:,k)')];
            YData1=[lowerb,fliplr(upperb)];
            l1 = patch('Parent',axes1,'DisplayName',['90% CI_{NWM-ECN}'],...
                'YData',YData1,...
                'XData',XData1,...
                'FaceAlpha',0.5,...
                'EdgeAlpha',0.5,...
                'FaceColor',"#D95319",...
        'EdgeColor',"#D95319");
            if EventTime(15,k) >= datetime(2007,10,01) && EventTime(15,k) <= datetime(2013,10,30)
                set(axes1,'Layer','top','Color',[0.9 0.9 0.9],'FontName','Calibri Light','FontSize',11,'LineWidth',1,'Xtick',[EventTime(2,k):days(13):EventTime(end,k)]);xtickformat('MMM dd')
            else
                set(axes1,'Layer','top','FontName','Calibri Light','FontSize',11,'LineWidth',1,'Xtick',[EventTime(2,k):days(13):EventTime(end,k)]);xtickformat('MMM dd')
            end
            title(EventName(k),'FontSize',12,'Color','k','VerticalAlignment','baseline');
            xlim([EventTime(1,k) EventTime(end,k)+days(2)]);ylim([0 max([max(upperb), max(max(Obs_NWM(:,:,k)))])*1.6])
            if k==24
                legend(["USGS","NWM","90% CI_{NWM-ECN}"],'Position',[0.708360035193788 0.172377471778059 0.260979725803072 0.0297684667194557],...
    'Orientation','horizontal')
            end
            if i==1 || i==6 || i==11 || i==16 || i==21
                ylabel('Discharge [m^3/s]','VerticalAlignment','baseline');
            end
            ht = annotation(figure1,'textbox',...
    POSS2(i,:),...
    'String',{['USGS: ',NameS{USGSID(k)}]},...
    'LineStyle','none','FontSize',10); set(ht,'Rotation',90)
            annotation(figure1,'textbox',...
    POSS3(i,:),...
    'String',{['L: $',num2str(round(Damage(k)/1000,1)),'B'],['F: ',num2str(Fatalities(k))]},'LineStyle','none');
        EvalMetrics = computemetric(Obs_NWM(:,2,k),Obs_NWM(:,1,k));
        EvalMetrics2 = computemetric(mean(ML(:,:,1,k)','omitnan')',Obs_NWM(:,1,k));
        annotation(figure1,'textbox',...
    POSS4(i,:),...
    'String',{['KGE: ',num2str(round(EvalMetrics(3),1)),' | ',num2str(round(EvalMetrics2(3),1))],['PE: ',num2str(round(EvalMetrics(4))),' | ',num2str(round(EvalMetrics2(4))),'%'],['TPE: ',num2str(round(EvalMetrics(5))),' | ',num2str(round(EvalMetrics2(5))),'d']},...
    'LineStyle','none',...
    'FitBoxToText','off','FontSize',8);
        end
    end
exportgraphics(figure1,"Figure_E1.jpeg",'Resolution',600) 
exportgraphics(figure1, "Figure_E1.pdf", 'ContentType', 'vector');