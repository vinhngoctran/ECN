clear all; close all;clc
load('R3_F6.mat');
load('S2.Wcon.mat','Wcon','DefineValue',"ClassW");
RFCs = shaperead('Data/USGS_boundary/RFC12.shp');
for ii=1:numel(PerformanceClass)
    for jj=1:numel(PerformanceClass{ii})
        for i=1:10
            for j=1:size(PerformanceClass{ii}{jj},1)
                DeltaC{ii}{jj}(j,i) = -((PerformanceClass{ii}{jj}(j,i+1)-1)-(PerformanceClass{ii}{jj}(j,1)-1))/(PerformanceClass{ii}{jj}(j,1)-1)*100;
            end
        end
    end
end
Col = ["ori_6","ori_2","ori_3"];
figure1 = figure('OuterPosition',[300 100 1200 1000]);
SharedP = [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0]; 
NameX = unique(ClassW(:,2));
NameX = ["Controlled","Natural"];
axes1 = axes('Parent',figure1,...
                'Position',[0.06 0.72 0.10 0.2]);hold on;
for i=1:2
    if SharedP(i)==1
        area([1+(i-1)*4, 1+(i)*4],[100,100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
        area([1+(i-1)*4, 1+(i)*4],[-100,-100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
    end
    Data = DeltaC{1}{i}(:,[1,5,10]);
    Data0 = [];
    Data0(1:size(Data,1),1:1+(i-1)*4) = -9999;
    aboxplot([Data0, Data(:,1)],'labels',[1:1:10],'colorgrad',Col(1)); 
    for j=2:3
        Data1 = [];
        Data1(1:size(Data,1),1:j-1) = -9999;
        aboxplot([Data0,Data1, Data(:,j)],'labels',[1:1:10],'colorgrad',Col(j)); 
    end
    
    
    ylim([-100 100]);xlim([1.5 8.5]);
    ylabel('\Delta_{KGE} [%]','VerticalAlignment','baseline')
    title('\bfa\rm Class','FontSize',12,'Color','k','VerticalAlignment','baseline');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top','Xtick',[3 7],'XTickLabel',NameX);
end
axes1 = axes('Parent',figure1,...
                'Position',[0.18 0.72 0.43 0.2]);hold on;
NameX = unique(ClassW(:,3));
for i=1:numel(DeltaC{2})
    if SharedP(i)==1
        area([1+(i-1)*4, 1+(i)*4],[100,100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
        area([1+(i-1)*4, 1+(i)*4],[-100,-100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
    end
    Data = DeltaC{2}{i}(:,[1,5,10]);
    Data0 = [];
    Data0(1:size(Data,1),1:1+(i-1)*4) = -9999;
    aboxplot([Data0, Data(:,1)],'labels',[1:1:10],'colorgrad',Col(1)); 
    for j=2:3
        Data1 = [];
        Data1(1:size(Data,1),1:j-1) = -9999;
        aboxplot([Data0,Data1, Data(:,j)],'labels',[1:1:10],'colorgrad',Col(j)); 
    end
    
    plot([0 100],[0 0],'--','Color',[0.5 0.5 0.5], 'LineWidth',1)
    ylim([-100 100]);
    xlim([1.5 36.5]);
    title('\bfb\rm Ecoregion','FontSize',12,'Color','k','VerticalAlignment','bottom');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top','Xtick',[3:4:100],'XTickLabel',NameX,'YTickLabel',[]);
end
axes1 = axes('Parent',figure1,...
                'Position',[0.63 0.72 0.33 0.2]);hold on;
NameX = unique(ClassW(:,4));
k=0;
for i=1:numel(DeltaC{3})
    if ~isempty(DeltaC{3}{i})
        k=k+1;
        preDat{k}=DeltaC{3}{i};
    end
end
for i=1:numel(preDat)
    if SharedP(i)==1
        area([1+(i-1)*4, 1+(i)*4],[100,100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
        area([1+(i-1)*4, 1+(i)*4],[-100,-100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
    end
    Data = preDat{i}(:,[1,5,10]);
    Data0 = [];
    Data0(1:size(Data,1),1:1+(i-1)*4) = -9999;
    aboxplot([Data0, Data(:,1)],'labels',[1:1:10],'colorgrad',Col(1)); 
    for j=2:3
        Data1 = [];
        Data1(1:size(Data,1),1:j-1) = -9999;
        aboxplot([Data0,Data1, Data(:,j)],'labels',[1:1:10],'colorgrad',Col(j)); 
    end
    plot([0 100],[0 0],'--','Color',[0.5 0.5 0.5], 'LineWidth',1)
    ylim([-100 100]);
    xlim([1.5 28.5]);
    title('\bfc\rm Geology','FontSize',12,'Color','k','VerticalAlignment','bottom');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top','Xtick',[3:4:100],'XTickLabel',NameX,'YTickLabel',[]);
end
legend1 = legend(["","","1-day","5-day","10-day"]);
set(legend1,...
    'Position',[0.78 0.93 0.149493242639142 0.0309789335491342],...
    'Orientation','horizontal',"Box",'off');
axes1 = axes('Parent',figure1,...
                'Position',[0.06 0.4 0.3 0.2]);hold on;
NameX = ["0-100","100-200","200-500","500-1000","1000-2000","2000-5000"];
for i=1:numel(DeltaC{4})
     if SharedP(i)==1
        area([1+(i-1)*4, 1+(i)*4],[100,100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
        area([1+(i-1)*4, 1+(i)*4],[-100,-100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
    end
    Data = DeltaC{4}{i}(:,[1,5,10]);
    Data0 = [];
    Data0(1:size(Data,1),1:1+(i-1)*4) = -9999;
    aboxplot([Data0, Data(:,1)],'labels',[1:1:10],'colorgrad',Col(1)); 
    for j=2:3
        Data1 = [];
        Data1(1:size(Data,1),1:j-1) = -9999;
        aboxplot([Data0,Data1, Data(:,j)],'labels',[1:1:10],'colorgrad',Col(j)); 
    end
    plot([0 100],[0 0],'--','Color',[0.5 0.5 0.5], 'LineWidth',1)
    ylim([-100 100]);
    xlim([1.5 24.5]);
    ylabel('\Delta_{KGE} [%]','VerticalAlignment','middle')
    title('\bfd\rm Area','FontSize',12,'Color','k','VerticalAlignment','baseline');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top','Xtick',[3:4:100],'XTickLabel',NameX);
end
axes1 = axes('Parent',figure1,...
                'Position',[0.38 0.4 0.58 0.2]);hold on;

for i=1:numel(DeltaC{5})
     if SharedP(i)==1
        area([1+(i-1)*4, 1+(i)*4],[100,100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
        area([1+(i-1)*4, 1+(i)*4],[-100,-100],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none','FaceAlpha',0.5);
    end
    NameX(i) =string(RFCs(i).BASIN_ID);
    Data = DeltaC{5}{i}(:,[1,5,10]);
    Data0 = [];
    Data0(1:size(Data,1),1:1+(i-1)*4) = -9999;
    aboxplot([Data0, Data(:,1)],'labels',[1:1:10],'colorgrad',Col(1)); 
    for j=2:3
        Data1 = [];
        Data1(1:size(Data,1),1:j-1) = -9999;
        aboxplot([Data0,Data1, Data(:,j)],'labels',[1:1:10],'colorgrad',Col(j)); 
    end
    plot([0 100],[0 0],'--','Color',[0.5 0.5 0.5], 'LineWidth',1)
    ylim([-100 100]);
    xlim([1.5 48.5]);
    title('\bfe\rm River forecast center','FontSize',12,'Color','k','VerticalAlignment','bottom');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top','Xtick',[3:4:100],'XTickLabel',NameX,'YTickLabel',[]);
end
exportgraphics(figure1,"Figure_4.jpeg",'Resolution',600) ;
exportgraphics(figure1, "Figure_4.pdf", 'ContentType', 'vector');