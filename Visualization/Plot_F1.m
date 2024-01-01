clear all; close all; clc
load('R3.F1.mat',"TE","PE","KGE","NSE","Locat","KGE_new")
close all
KGE = KGE_new;
KGE0 = KGE;
KGE(KGE<-1)=-1;%re-arange to fixed scale [-1 1]
figure1 = figure('OuterPosition',[300 100 1200 800]);
axes1 = axes('Parent',figure1,...
                'Position',[0.22 0.4 0.35 0.3]);hold on;
USshape = shaperead("Data/basin_set_full_res/USborder.shp");
mapshow(USshape,'FaceColor',[1 1 1],'LineWidth',1); hold on
scatter(Locat(:,2), Locat(:,1),20, KGE, 'o','filled','MarkerEdgeColor','k');
colormap(redwhiteblue(-1,1,0));
hcb = colorbar(axes1,'Position',...
    [0.59 0.4 0.0188626126126127 0.27],'TickLength',0.03);
caxis([-1 1]);hcb.Title.String = "KGE [-]";
hcb.Ticks = [-1 -0.5 0 0.3 0.5 1];
xlim([-126 -62])
set(axes1,'xcolor',[1 1 1],'ycolor',[1 1 1],'FontName','Calibri Light','FontSize',13); 
title('a','FontSize',18,'Color','k','VerticalAlignment','cap');axes1.TitleHorizontalAlignment = 'left';

axes1 = axes('Parent',figure1,...
                'Position',[0.55 0.4 0.045 0.27]);hold on;box on
aboxplot([KGE0 KGE0],'labels',[1 2],'colorgrad','ori_1','widths',0.5);
xlim([0.5 1.5]);ylim([-1 1])
set(axes1,'Color','None','ycolor','None','FontName','Calibri Light','FontSize',13); 

TE(TE>5)=5; TE(TE<-5)=-5; %re-arange to fixed scale [-5 5] days
PE(PE>100)=100;PE(PE<-100)=-100; %re-arange to fixed scale [-100 100] %

axes1 = axes('Parent',figure1,...
                'Position',[0.69 0.58 0.28 0.12]);hold on;grid on
xlabel('PE [%]','VerticalAlignment','middle')
xxx = [min(PE):0.1:max(PE)];
NWM_cdf = computecdf(xxx,PE); 
plot(xxx,NWM_cdf,"Color",'k','LineWidth',1.5,'DisplayName','NWM');
ylabel('cdf(PE)');
xlim([-100 100])
set(axes1,'Layer','top','FontName','Calibri Light','FontSize',13,'LineWidth',1,'Ytick',[0:0.25:1],'Xtick',[-100, -33, 0, 50, 100]); 
title('b','FontSize',18,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';


axes1 = axes('Parent',figure1,...
                'Position',[0.69 0.39 0.28 0.12]);hold on;grid on
xxx = [min(TE):0.05:max(TE)];
NWM_cdf = computecdf(xxx,TE); 
plot(xxx,NWM_cdf,"Color",'k','LineWidth',1.5,'DisplayName','NWM');
ylabel('cdf(TPE)')
xlim([-5 5])
xlabel('TPE [days]','VerticalAlignment','middle')
set(axes1,'Layer','top','FontName','Calibri Light','FontSize',13,'LineWidth',1,'Xtick',[-5:1:5],'Ytick',[0:0.25:1]); 
title('c','FontSize',18,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';

% Plot 11 big historic events
DATETIME = [datetime(1979,02,01,01,00,00):days(1):datetime(2020,12,31,23,0,0)]';
load('R2.DataColection.mat',"info","ReportData","NameS");
load('R3-F5_Event.mat');
k=0;
for i=1:3
    for j=1:5
        if i==2 && j>1
        else
            k=k+1;
            POSS(k,:) = [0.055+(j-1)*0.19 0.79-(i-1)*0.33 0.15 0.18];
            axes1 = axes('Parent',figure1,...
                'Position',POSS(k,:));hold on;
            plot(EventTime(:,k),Obs_NWM(:,:,k),'LineWidth',1);hold on;
            colororder([0 0 0;0 0.4470 0.7410])
            if EventTime(15,k) >= datetime(2007,10,01) && EventTime(15,k) <= datetime(2013,10,30) 
                set(axes1,'Layer','top','Color',[0.9 0.9 0.9],'FontName','Calibri Light','FontSize',12,'LineWidth',1,'Xtick',[EventTime(2,k):days(13):EventTime(end,k)]);xtickformat('MMM dd')
            else
                set(axes1,'Layer','top','FontName','Calibri Light','FontSize',12,'LineWidth',1,'Xtick',[EventTime(2,k):days(13):EventTime(end,k)]);xtickformat('MMM dd')
            end
            title(EventName(k),'FontSize',12,'Color','k','VerticalAlignment','baseline');
            xlim([EventTime(1,k) EventTime(end,k)+days(2)]);ylim([0 max(max(Obs_NWM(:,:,k)))*1.6])
            if k==10
                legend(["USGS","NWM"],'Position',[0.815 0.03 0.149493242639142 0.0309789335491342],...
    'Orientation','horizontal')
            end
            if j==1
                ylabel('Discharge [m^3/s]','VerticalAlignment','baseline');
            end
            ht = annotation(figure1,'textbox',...
    [0.215+(j-1)*0.19 0.8-(i-1)*0.33 0.107263510568521 0.0381895325224336],...
    'String',{['USGS: ',NameS{USGSID(k)}]},...
    'LineStyle','none');
            set(ht,'Rotation',90)
            annotation(figure1,'textbox',...
    [0.055+(j-1)*0.19 0.9-(i-1)*0.33 0.07 0.0622347934748529],...
    'String',{['L: $',num2str(round(Damage(k)/1000,1)),'B'],['F: ',num2str(Fatalities(k))]},'LineStyle','none');
        EvalMetrics = computemetric(Obs_NWM(:,2,k),Obs_NWM(:,1,k));
        annotation(figure1,'textbox',...
    [0.135+(j-1)*0.19 0.865629420084866-(i-1)*0.33 0.0700000000000001 0.106506363488998],...
    'String',{['KGE: ',num2str(round(EvalMetrics(3),1))],['PE: ',num2str(round(EvalMetrics(4))),'%'],['TPE: ',num2str(round(EvalMetrics(5))),'d']},...
    'LineStyle','none',...
    'FitBoxToText','off');xtickformat('MMM dd');
        end
    end
end
exportgraphics(figure1,"Figure_1.jpeg",'Resolution',600) 
exportgraphics(figure1, "Figure_1.pdf", 'ContentType', 'vector');