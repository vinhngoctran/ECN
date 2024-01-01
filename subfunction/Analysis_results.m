close all;clc; clear all;
load('Results5\R3.F4.mat',"TE","PE","KGE","Locat","KGE_mean","KGE_CI","KGE_CI_ep");
BetterBasins(1:3)=0;
idx = [2,6,11];
for i=1:3
    for j=1:size(Locat,1)
        if KGE_mean(j,idx(i))>KGE_mean(j,1)
            BetterBasins(i) = BetterBasins(i)+1;
        end
    end
end

%%
BetterEvent(1:3) = 0;
for i=1:3
    for j=1:size(KGE{1,1},1)
        if KGE{idx(i)}(j)>KGE{1}(j)
            BetterEvent(i) = BetterEvent(i)+1;
        end
    end
end

%%
idx = [1, 2,6,11];
for i=1:4
PercentAbove03(i)=sum(KGE{idx(i)}>0.3);
end

%%
for i=1:10
    for j=1:numel(KGE{1})
        DeltaC{1}(j,i) = -((KGE{i+1}(j,1)-1)-(KGE{1}(j,1)-1))/(KGE{1}(j,1)-1)*100;
        DeltaC{2}(j,i) = -(abs(PE{i+1}(j,1)-0)-abs(PE{1}(j,1)-0))/abs(PE{1}(j,1)-0)*100;
        DeltaC{3}(j,i) = -(abs(TE{i+1}(j,1)-0)-abs(TE{1}(j,1)-0))*100;
    end
    for k=1:3
        MedianDelta(i,k) = median(DeltaC{k}(:,i),'omitnan');
    end
end

%%
load('Results5\R3_F6.mat');
load('Results5\S2.Wcon.mat','Wcon','DefineValue',"ClassW");
RFCs = shaperead('Data/USGS_boundary/RFC12.shp');
for ii=1:numel(PerformanceClass)
    for jj=1:numel(PerformanceClass{ii})
        for i=1:10
            for j=1:size(PerformanceClass{ii}{jj},1)
                DeltaC{ii}{jj}(j,i) = -((PerformanceClass{ii}{jj}(j,i+1)-1)-(PerformanceClass{ii}{jj}(j,1)-1))/(PerformanceClass{ii}{jj}(j,1)-1)*100;
            end
            try
            MedianRegion{ii}(i,jj) = median(DeltaC{ii}{jj}(:,i),'omitnan');
            catch
            end
        end
    end
end
AllValue = [];
for ii=1:numel(PerformanceClass)
AllValue = [AllValue, MedianRegion{ii}];
end
AllValue2 = AllValue(:,AllValue(1,:)>0);
MinDelta = min(AllValue2');
MaxDelta = max(AllValue2');

%% Count the number of better basin for West Plains (WestPlains) and West Xeric (WestXeric) ecoregions
for i=1:9
    N_basin(i) = size(DeltaC{1, 2}{i},1);
    for j=1:10
        Nbetter(j,i) = sum(DeltaC{1, 2}{i}(:,j)>0) ;
    end
end
sum(Nbetter(:,end-1:end)')
sum(Nbetter(:,end-1:end)')/sum(N_basin(end-1:end))
sum(N_basin(end-1:end))
%% Count the number of better basin for River forecast center
for i=1:12
    N_basinRFC(i) = size(DeltaC{1, 5}{i},1);
    for j=1:10
        NbetterRFC(j,i) = sum(DeltaC{1, 5}{i}(:,j)>0) ;
        PercentBetterRFC(j,i) = NbetterRFC(j,i)/N_basinRFC(i);
    end
end
MinRFC = min(PercentBetterRFC(:,1:11)');
MaxRFC = max(PercentBetterRFC(:,1:11)');