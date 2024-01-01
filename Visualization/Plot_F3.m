close all;clc; clear all;
load('R3.F4.mat',"TE","PE","KGE","Locat","KGE_mean","KGE_CI","KGE_CI_ep");
figure1 = figure('OuterPosition',[300 100 1200 800]);
idx = [1,2,6,11];
NameF = ["\bfa\rm NWM-Baseline";"\bfa\rm NWM-ECN 1-day";"\bfb\rm NWM-ECN 5-day";"\bfc\rm NWM-ECN 10-day"];
for i=2:4
    axes1 = axes('Parent',figure1,...
        'Position',[0.07+(i-2)*0.31 0.7 0.26 0.27]);hold on;
    USshape = shaperead("Data/basin_set_full_res/USborder.shp");
    mapshow(USshape,'FaceColor',[1 1 1],'LineWidth',1); hold on
    scatter(Locat(:,2), Locat(:,1),20, KGE_mean(:,idx(i)), 'o','filled','MarkerEdgeColor','k');
    colormap(redwhiteblue(-1,1,0));
    caxis([-1 1]);
    if i==4
        hcb=colorbar(axes1,'Position',...
    [0.95 0.7 0.0171452702702705 0.25]);
        hcb.Title.String = "KGE";
    end
    xlim([-126 -66]);ylim([24 51])
    set(axes1,'xcolor',[1 1 1],'ycolor',[1 1 1],'FontName','Calibri Light','FontSize',13);
    title(NameF{i},'FontSize',14,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';
end

for i=1:3
    axes1 = axes('Parent',figure1,...
        'Position',[0.03+(i-1)*0.31 0.71 0.07 0.1]);hold on;
    A = [KGE_mean(:,idx(1)),KGE_mean(:,idx(i+1))];
    B = mean(A');
    A = A(~isnan(B'),:);
    A(A<-1.1)=-1.1;
    heatscatter(A(:,1),A(:,2),0);caxis([0 100]);colormap(axes1,jet);
    plot([-1 1],[-1 1],'--','Color',[1 1 1],'LineWidth',1.5)
    ylim([-1 1]);xlim([-1 1]);
    if i==3
        colorbar(axes1,'Position',...
    [0.774493243243243 0.71 0.0126689189189191 0.0608203677510603]);
    end
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',11,'Xticklabel',[],'Yticklabel',[],'Layer','top');

    A = [KGE_mean(:,idx(1)),KGE_mean(:,idx(i+1))];
    B = mean(A');
    A = A(~isnan(B'),:);
    axes1 = axes('Parent',figure1,...
        'Position',[0.004+(i-1)*0.31 0.71 0.022 0.1]);hold on
    [f,xi] = ksdensity(A(:,2),[-1:0.01:1]);
    area(xi,f,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
    plot(median(A(:,2)),0,'Marker','o','Color','k','MarkerFaceColor','k')
    set(axes1,'Ycolor','None','Xcolor','None','Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',11,'Xticklabel',[],'Yticklabel',[]);
    view(axes1,[270 90]);

    axes1 = axes('Parent',figure1,...
        'Position',[0.03+(i-1)*0.31 0.668 0.07 0.036]);hold on; box on
    [f,xi] = ksdensity(A(:,1),[-1:0.01:1]);
    area(xi,f,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);xlim([-1 1])
    plot(median(A(:,1)),0,'Marker','o','Color','k','MarkerFaceColor','k')
    set(axes1,'Ycolor','None','Xcolor','None','Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',11,'Xticklabel',[],'Yticklabel',[]);
    view(axes1,[0 270]);
end
% Plot uncertain range
idx = [2, 6, 11];
xxx = [-1:0.01:1];
PerformanceA = [-0.41, 0.3, 0.6];
NameF = ["\bfd\rm 1-day";"\bfe\rm 5-day";"\bff\rm 10-day"];
for i=1:3
    axes1 = axes('Parent',figure1,...
        'Position',[0.05+(i-1)*0.33 0.4 0.27 0.23]);hold on;
    for j=1:3
        plot([PerformanceA(j) PerformanceA(j)],[0 1],'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1.5);
    end
    lowerb = KGE_CI{idx(i),1};
    lowerb = computecdf(xxx,lowerb);
    upperb = KGE_CI{idx(i),2};
    upperb = computecdf(xxx,upperb);                 
    XData1=[xxx,fliplr(xxx)];
    YData1=[upperb',fliplr(lowerb')];
    l1 = patch('Parent',axes1,'DisplayName',['90% CI_{NWM-ECN}'],...
        'YData',YData1,...
        'XData',XData1,...
        'FaceAlpha',0.5,...
        'EdgeAlpha',0.5,...
        'FaceColor',[0.8500 0.3250 0.0980],...
        'EdgeColor',[0.8500 0.3250 0.0980]);

    lowerb = KGE_CI_ep{idx(i),1};
    lowerb = computecdf(xxx,lowerb);
    upperb = KGE_CI_ep{idx(i),2};
    upperb = computecdf(xxx,upperb);              
    XData1=[xxx,fliplr(xxx)];
    YData1=[upperb',fliplr(lowerb')];
    l2 = patch('Parent',axes1,'DisplayName',['90% CI_{NWM-ECN-reducible}'],...
        'YData',YData1,...
        'XData',XData1,...
        'FaceAlpha',0.5,...
        'EdgeAlpha',0.5,...
        'FaceColor',[0 0.45 0.74],...
        'EdgeColor',[0 0.45 0.74]);

    NWM_cdf = computecdf(xxx,KGE{1, 1}); 
    l3 = plot(xxx,NWM_cdf,"Color",'k','LineWidth',1.5,'DisplayName','NWM');
    xlabel('KGE [-]','VerticalAlignment','middle')
    if i==1
        legend([l1, l2, l3],'Location','Best','Color',[1 1 1]);
        ylabel('cdf(KGE)','VerticalAlignment','baseline');
    end
    title(NameF{i},'FontSize',14,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top','Xtick',[-1,-0.41, 0.3, 0.6,1]);
end
annotation(figure1,'textbox',...
    [0.761824324324328 0.498292787138104 0.090371619180046 0.0381895325224337],...
    'String',{'Unsatisfactory'},...
    'Rotation',90,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.847993243243245 0.52 0.0903716191800468 0.0381895325224336],...
    'String',{'Satisfactory'},...
    'Rotation',90,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.916864864864866 0.4 0.0903716191800462 0.0381895325224336],...
    'String',{'Good'},...
    'Rotation',90,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',...
    [0.964331081081082 0.4 0.0903716191800464 0.0381895325224336],...
    'String',{'Very good'},...
    'Rotation',90,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Compute Delta
for i=1:10
    for j=1:numel(KGE{1})
        DeltaC{1}(j,i) = -((KGE{i+1}(j,1)-1)-(KGE{1}(j,1)-1))/(KGE{1}(j,1)-1)*100;
        DeltaC{2}(j,i) = -(abs(PE{i+1}(j,1)-0)-abs(PE{1}(j,1)-0))/abs(PE{1}(j,1)-0)*100;
        DeltaC{3}(j,i) = -(abs(TE{i+1}(j,1)-0)-abs(TE{1}(j,1)-0))*100;
    end
end

YYYY = [-100 100;-100 100;-100 300];
NameF = ["\bfg\rm KGE";"\bfh\rm PE";"\bfi\rm TPE"];
for i=1:3
    axes1 = axes('Parent',figure1,...
        'Position',[0.05+(i-1)*0.33 0.075 0.27 0.23]);hold on;
    aboxplot(DeltaC{i},'labels',[1:1:10],'colorgrad','ori_6'); 
    plot([0 10],[0 0],'--','Color',[0.5 0.5 0.5], 'LineWidth',1)
    if i==1
        ylabel('\Delta_{KGE} [%]','VerticalAlignment','middle')
    elseif i==2
        ylabel('\Delta_{PE} [%]','VerticalAlignment','middle')
    else
        ylabel('\Delta_{TPE} [%]','VerticalAlignment','middle')
    end
    xlabel('Lead time [days]','VerticalAlignment','middle');xlim([0.5 10.5]); ylim(YYYY(i,:));
     title(NameF{i},'FontSize',14,'Color','k','VerticalAlignment','middle');axes1.TitleHorizontalAlignment = 'left';
    set(axes1,'Color','None','Linewidth',1.5,'FontName','Calibri Light','FontSize',13,'Layer','top');
end

exportgraphics(figure1,"Figure_3.jpeg",'Resolution',600) 
exportgraphics(figure1, "Figure_3.pdf", 'ContentType', 'vector');