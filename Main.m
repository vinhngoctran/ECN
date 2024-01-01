function test()
% clear all; close all; clc
% addpath(genpath('functions'));

%% Read NWM output (discharge) and USGS data
% https://waterdata.usgs.gov
% https://www.usgs.gov/data/national-water-model-v21-retrospective-selected-nwis-gage-locations-1979-2020
StartDate = '1979-02-01';
Endate = '2020-12-31';
USGS_All_shp = readgeotable('Data/GageLoc/GageLoc.shp');
for i=1:size(USGS_All_shp,1)
    USGS_All(i,:) =  [USGS_All_shp.Shape(i,1).Latitude,USGS_All_shp.Shape(i,1).Longitude];
    USGS_Name(i,1) = USGS_All_shp.SOURCE_FEA(i);
end
Filename = 'Data/nwmv21_nwis.nc';
ID_LATLON(:,1) = ncread(Filename,'latitude');ID_LATLON(:,2) = ncread(Filename,'longitude');
for i=1:size(ID_LATLON,1)
    i
    ID_USGS(i,:) = findusgs(ID_LATLON(i,:),USGS_All,1000);
    if ~isnan(ID_USGS(i,:))
        % Download USGS data
        SelectedStreamflow(:,i) = usgsdownload(USGS_Name{ID_USGS(i,1)},StartDate,Endate);
    end
end
save('Data/R_USGS.mat','ID_USGS','USGS_Name','USGS_All','ID_LATLON','SelectedStreamflow','-v7.3')
TotalStation = sum(~isnan(ID_USGS(:,1)));

%% Read GAGE-II dataset
close all; clear all; clc
load('Data/R_USGS.mat','ID_USGS','USGS_Name','USGS_All','ID_LATLON');
Watershed0 = shaperead('Data/USGS_boundary/boundaries-shapefiles-by-aggeco/All_Watershed_arc.shp'); % Convert to UTM-WGS84

for i=1:size(Watershed0,1)
    GageID(i,1) = string(Watershed0(i).GAGE_ID);
end
k=0;
for i=1:size(ID_USGS,1)
    if ~isnan(ID_USGS(i,1))
        idx = find(GageID==USGS_Name{ID_USGS(i,1)});
        if isempty(idx)
            idy = find(GageID2==USGS_Name{ID_USGS(i,1)});
            if ~isempty(idy)
                k=k+1;
                SelectedGauge(k,:) = [i ID_USGS(i,1) idy(1) 2]; % [NWM_ID    USGS_ID    WATERSHED_ID]
                SelectedGaugeName(k,1) = USGS_Name(ID_USGS(i,1));
            end
        else
            if k==0
                idy = [];
            else
                idy = find(SelectedGauge(:,2)==ID_USGS(i,1));
            end
            if isempty(idy)
                k=k+1;
                SelectedGauge(k,:) = [i ID_USGS(i,1) idx(1) 1]; % [NWM_ID    USGS_ID    WATERSHED_ID 1]
                SelectedGaugeName(k,1) = USGS_Name(ID_USGS(i,1));
            end
        end
    end
end
save('Results/R1_SelectedGage_2.mat','SelectedGauge','SelectedGaugeName','Watershed0');




%% Save final dataset
clear all; close all; clc
% USGS gages
USGS_All_shp = readgeotable('Data/GageLoc/GageLoc.shp');
for i=1:size(USGS_All_shp,1)
    USGS_All(i,:) =  [USGS_All_shp.Shape(i,1).Latitude,USGS_All_shp.Shape(i,1).Longitude];
    USGS_Name(i,1) = USGS_All_shp.SOURCE_FEA(i);
end

% USGS-Gages-II watersheds
Watershed0 = shaperead('Data/USGS_boundary/boundaries-shapefiles-by-aggeco/All_Watershed_arc.shp'); % Convert to UTM-WGS84
for i=1:size(Watershed0,1)
    GageID(i,1) = string(Watershed0(i).GAGE_ID);
end

% NWM predicted locations
Filename = 'Data/nwmv21_nwis.nc';
ID_LATLON(:,1) = ncread(Filename,'latitude');ID_LATLON(:,2) = ncread(Filename,'longitude');
load('Data/R_USGS.mat','SelectedStreamflow');
StartDate = '1979-02-01';
Endate = '2020-12-31';
DATETIME = [datetime(1979,02,01,01,00,00):hours(1):datetime(2020,12,31,23,0,0)]';
% Criteria:
    % 1: Distance between NWM location and USGS gage < 1000m
    % 2: Total streamflow data avaliable > 10 years = 3650 days
    % 3: The USGS gages is the outlet of a Gages-II watershed

k=0;
for i=1:size(ID_LATLON,1)
    [temp_ID_USGS temp_distance] = findusgs(ID_LATLON(i,:),USGS_All,1000);
    temp_obs = SelectedStreamflow(:,i);
    temp_obs(temp_obs==0) = NaN;
    nvalue = numel(temp_obs(~isnan(temp_obs)));
    if ~isnan(temp_ID_USGS) && nvalue>3650
        temp_Name_USGS = USGS_Name(temp_ID_USGS,1);
        idx = find(GageID==temp_Name_USGS);
        if ~isempty(idx)
            if k==0
                idy = [];
            else
                idy = find(NameS(:,1)==temp_Name_USGS);
            end
            if isempty(idy)
                NameFile = "Data/NWM_Forcing/Forcings/W_"+temp_Name_USGS+".csv";
                if exist(NameFile)
                    k=k+1
                    info(k,:) = [i-1, temp_distance,ID_LATLON(i,:),USGS_All(temp_ID_USGS,:)];
                    NameS(k,1) = temp_Name_USGS;
                    [Q_SIM(:,k), Q_USGS(:,k)] = generateSimData(SelectedStreamflow(:,i),i-1,DATETIME);
                end
            else
                if temp_distance<info(idy)
                    info(idy,:) = [i-1, temp_distance,ID_LATLON(i,:),USGS_All(temp_ID_USGS,:)];
                    [Q_SIM(:,idy), Q_USGS(:,idy)] = generateSimData(SelectedStreamflow(:,i),i-1,DATETIME);
                end
            end
        end
    end
end

save('Results\R2.DataColection.mat',"Q_USGS","Q_SIM","NameS","info");

%% Select Flood Events and save the dataset for each selected streamgage
% Using peak-over-threshold: https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019WR024701
% https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2016WR019426
% https://www.sciencedirect.com/science/article/pii/S136481522100222X#bib7
clear all; close all; clc
load('Results\R2.DataColection.mat',"Q_USGS","Q_SIM","NameS","info");
DATETIME = [datetime(1979,02,01,01,00,00):days(1):datetime(2020,12,31,23,0,0)]';
StartDate = '1979-02-01';
Endate = '2020-12-31';
for i=1:size(info,1)
    i
    NameFile = "Data/NWM_Forcing/Forcings/W_"+NameS(i)+".csv";
    ForcingData = readtable(NameFile);
    idx = find(ForcingData.date==StartDate);
    idy = find(ForcingData.date==Endate);
    ForcingData = ForcingData(idx:idy,:);ForcingData = table2array(ForcingData(:,2:end));
    Data = selectevent2(DATETIME,Q_USGS(:,i),Q_SIM(:,i),ForcingData,[],90);
    if isempty(Data)
        ReportData(i,:) = [0 0];         % [RunCheck     number of events]; RunCheck = 1 (run model) and vice versa.
    else
        if size(Data.T,2)<20             % Select streamgages that have >= 20 flood events
            ReportData(i,:) = [0 size(Data.T,2)];
        else
            ReportData(i,:) = [1 size(Data.T,2)];
        end
        Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];
        save(Filename,"Data");
    end
end
save('Results5\R2.DataColection.mat',"Q_USGS","Q_SIM","NameS","info","ReportData");

%% Evaluate the performace of NWM
clear all; close all; clc
addpath(genpath(pwd));
load('Data/R_USGS.mat','ID_USGS','USGS_Name','USGS_All','ID_LATLON');
load('Results/R1_SelectedGage_2.mat','SelectedGauge','SelectedGaugeName','Watershed0');
load('Data/R_USGS.mat','SelectedStreamflow');
DATETIME = [datetime(1979,02,01,01,00,00):hours(1):datetime(2020,12,31,23,0,0)]';
k=0;
for i=1:size(SelectedGauge,1)
    [SIM OBS] = generateData(SelectedStreamflow,SelectedGauge(i,:)-1,DATETIME);
    [SIM2 OBS2] = removenan(SIM,OBS);
    if ~isempty(SIM2)
        k=k+1;
        Metrics(k,:) = computemetric(SIM2,OBS2);
        LATLON_Comp(k,:) = ID_LATLON(SelectedGauge(i,1),:);
    end
end
save('Results/R2_evaluation.mat','Metrics','LATLON_Comp');

%% Apply machine learning to increase the accuracy of NWM
clear al; close all; clc;
addpath(genpath(pwd));
%------------Anaconda active-----------
pyExec = 'C:/ProgramData/Anaconda3/';
pyRoot = fileparts(pyExec);
p = getenv('PATH');
p = strsplit(p, ';');
addToPath = {
   pyRoot
   fullfile(pyRoot, 'Library', 'mingw-w64', 'bin')
   fullfile(pyRoot, 'Library', 'usr', 'bin')
   fullfile(pyRoot, 'Library', 'bin')
   fullfile(pyRoot, 'Scripts')
   fullfile(pyRoot, 'bin')
};
p = [addToPath(:); p(:)];
p = unique(p, 'stable');
p = strjoin(p, ';');
setenv('PATH', p);
!conda activate base
%------------Anaconda active-----------
load('Results5\R2.DataColection.mat',"info","ReportData");
for i=1:size(info,1)
    for LT = 1:10
        [i LT]
        if ReportData(i,1) == 1
            Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];load(Filename);
            [Xtrain, Xapply,Xtest, Ytrain, Yapply,Ytest, CY,SY] = formdatacamel6(Data,LT);
            save("Data/Input8/W_"+num2str(i)+"_"+num2str(LT)+".mat",'Xtrain','Ytrain','Xapply','Yapply',"Xtest","Ytest","SY","CY");
            % Run ECN - This task was done using HPC from the University of Michigan
            !python ErrorCastNet.py
        end
    end
end

% Extract model results
clear all; close all; clc
addpath(genpath(pwd));
load('Results5\R2.DataColection.mat',"info","ReportData");
for i=1:size(info,1)
    if ReportData(i,1) == 1
        extractdata_US(i);
    end
end

%% Recompute metrics
clear all; close all; clc
addpath(genpath(pwd));
load('Results5\R2.DataColection.mat',"info","ReportData");
for i=1:size(info,1)
    for LT = 1:10
    [i LT]
    if ReportData(i,1) == 1
        Filename1 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(LT)+".mat";
        load(Filename1);
        Metrics = evaluationResults2(OBS_all,NWM_all,OBS, NWM, NWM_ML_ep,NWM_ML_ale,NWM_ML_combine);
        Filename2 = "Results5/R1_3/W_"+num2str(i)+"_"+num2str(LT)+".mat";
        save(Filename2,'OBS_all','NWM_all','OBS', 'NWM', 'NWM_ML_ep','NWM_ML_ale','NWM_ML_combine',"PearsonC","BaseFlow","Metrics","RunTime");
    end
    end
end

%% Ensemble results
clear all; close all; clc
addpath(genpath(pwd));
load('Results5\R2.DataColection.mat',"info","ReportData");
DATETIME = [datetime(1979,02,01,01,00,00):days(1):datetime(2020,12,31,23,0,0)]';
for i=1:size(info,1)
    for LT = 1:10
        [i LT]
        Filename = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(LT)+".mat";
        if ReportData(i,1) == 1 && exist(Filename)
            load(Filename,"Metrics","BaseFlow","PearsonC","RunTime");
            R_Metrics{i,LT} = Metrics;
            R_BaseFlow(i,1) =BaseFlow;
            R_PearsonC{i,LT} = PearsonC;
        end
    end
end
save('Results5\R2_Metrics.mat',"R_Metrics",'-v7.3');
save('Results5\R2_other.mat',"R_PearsonC","R_BaseFlow");

%% Classify Watershed charateristics
clear all; close all; clc
load('Results5\R2.DataColection.mat',"info","ReportData");
opts = delimitedTextImportOptions("NumVariables", 5);
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";
opts.VariableNames = ["STAID", "CLASS", "AGGECOREGION", "GEOL_REEDBUSH_DOM", "DRAIN_SQKM"];
opts.VariableTypes = ["string", "string", "string",  "string", "string"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["STAID", "CLASS", "AGGECOREGION",  "GEOL_REEDBUSH_DOM", "DRAIN_SQKM"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["STAID", "CLASS", "AGGECOREGION",  "GEOL_REEDBUSH_DOM", "DRAIN_SQKM"], "EmptyFieldRule", "auto");
ClassW = readmatrix("Data\USGS_boundary\basinchar_and_report_sept_2011\Clasification.txt", opts);
clear opts
load('Results5\R2.DataColection.mat',"info","ReportData",'NameS');
DefineValue(1:size(ClassW,1),3) = 0;
for i=1:3
    Data = ClassW(:,i+1);
    Data = unique(Data);
    for j=1:numel(Data)
        idx = find(ClassW(:,i+1)==Data(j));
        DefineValue(idx,i)=j;
    end
end
for i=1:size(ClassW,1)
    DefineValue(i,4) = str2num(ClassW(i,5));
end
for i=1:size(info,1)
    idx = find(ClassW(:,1)==NameS(i,1));
    Wcon(i,:) = DefineValue(idx,:);
end
idx = find(ReportData(:,1)==1);
Wcon = Wcon(idx,:);
DefineValue = DefineValue(idx,:);
ClassW = ClassW(idx,:);
save('Results5\S2.Wcon.mat','Wcon','DefineValue',"ClassW");

%% RESULTS ANALYSIS ======================================================================================================================================
% Performance of NWM
clear all; close all; clc
addpath(genpath(pwd));
load('Results5\R2.DataColection.mat',"info","ReportData");
load('Results5\R2_Metrics.mat');
load('Results5\R3_Metrics_NewKGE.mat');
k=0;
KGE_A = [];
PE = [];
TE = [];
for i=1:size(ReportData,1)
    if ReportData(i,1) == 1
        k=k+1;
        Locat(k,:) = info(i,3:4);
        NSE(k,1)=median(R_Metrics{i, 1}.AllEvent(:,2),'omitnan');
        KGE(k,1)=median(R_Metrics{i, 1}.AllEvent(:,3),'omitnan');
        KGE_new(k,1)=median(R_Metrics2{i, 1}.AllEvent(:,1),'omitnan');
        KGE_A = [KGE_A;R_Metrics2{i, 1}.AllEvent(:,1)];
        PE = [PE;R_Metrics{i, 1}.AllEvent(:,4)];
        TE = [TE;R_Metrics{i, 1}.AllEvent(:,5)];
        meanPE(k,1) = median(R_Metrics{i, 1}.AllEvent(:,4),'omitnan');
        meanTE(k,1) = median(R_Metrics{i, 1}.AllEvent(:,5),'omitnan');
    end
end
save('Results5\R3.F1_2.mat',"TE","PE","KGE","Locat","NSE","KGE_new","meanPE","meanTE","KGE_A");

% Total events
load('Results5\R2.DataColection.mat',"info","ReportData");
idx = ReportData(:,1)==1;
Nevent = sum(ReportData(idx,2));

% Performance of NWM for 12 RFCs
clear all; close all; clc
addpath(genpath(pwd));
load('Results5\R2.DataColection.mat',"info","ReportData");
load('Results5\R2_Metrics.mat');
RFCs = shaperead('Data/USGS_boundary/RFC12.shp');
load('Results5\R3_Metrics_NewKGE.mat');
for i=1:12
    k=0;
    KGE{i} = [];
    PE{i} = [];
    TE{i} = [];
    in = inpolygon(info(:,4),info(:,3),RFCs(i).X(1:end-1),RFCs(i).Y(1:end-1));
    idx = find(in==1);
    for j=1:numel(idx)
        if ReportData(idx(j),1) == 1
            k=k+1;
            Locat{i}(k,:) = info(idx(j),3:4);
            KGE{i} = [KGE{i};R_Metrics2{idx(j), 1}.AllEvent(:,1)];
            PE{i} = [PE{i};R_Metrics{idx(j), 1}.AllEvent(:,4)];
            TE{i} = [TE{i};R_Metrics{idx(j), 1}.AllEvent(:,5)];
        end
    end
end
save('Results5\R3.F2.mat',"TE","PE","KGE","Locat");

% Anual performance of NWM
clear all; close all; clc
addpath(genpath(pwd));
load('Results5\R2.DataColection.mat',"info","ReportData");
load('Results5\R2_Metrics.mat');
RFCs = shaperead('Data/USGS_boundary/RFC12.shp');
load('Results5\R3_Metrics_NewKGE.mat');
DATETIME = [1979:1:2020];
for i=1:13
    for j=1:numel(DATETIME)
        KGE{i}{j}=[];
        PE{i}{j}=[];
        TE{i}{j}=[];
    end
end

for i=1:size(ReportData,1)
    if ReportData(i,1) == 1
        [KGE{1}, PE{1}, TE{1}]=performanceintime(R_Metrics{i, 1}.AllEvent,R_Metrics2{i, 1}.AllEvent,i,KGE{1}, PE{1}, TE{1});
    end
end

for i=1:12
    in = inpolygon(info(:,4),info(:,3),RFCs(i).X(1:end-1),RFCs(i).Y(1:end-1));
    idx = find(in==1);
    for j=1:numel(idx)
        if ReportData(idx(j),1) == 1
            [KGE{1+i}, PE{1+i}, TE{1+i}]=performanceintime(R_Metrics{idx(j), 1}.AllEvent,R_Metrics2{idx(j), 1}.AllEvent,idx(j),KGE{1+i}, PE{1+i}, TE{1+i});
        end
    end
end
save('Results5\R3.F3.mat',"TE","PE","KGE");

% Performance of NWM-ECN according to lead-time predictions
clear all; close all; clc
load('Results5\R2.DataColection.mat',"info","ReportData");
load('Results5\R2_Metrics.mat');
load('Results5\R3_Metrics_NewKGE.mat');
RFCs = shaperead('Data/USGS_boundary/RFC12.shp');
for i=1:11
        KGE{i}=[];
        PE{i}=[];
        TE{i}=[];
        KGE_CI{i,1}=[];
        KGE_CI{i,2}=[];
        KGE_CI_ep{i,1}=[];
        KGE_CI_ep{i,2}=[];
end
k=0;
for i=1:size(ReportData,1)
    if ReportData(i,1) == 1
        k=k+1;
        Locat(k,:) = info(i,3:4);
        KGE_mean(k,1)=median(R_Metrics2{i, 1}.TestEvent(:,1),'omitnan');
        KGE{1} = [KGE{1};R_Metrics2{i, 1}.TestEvent(:,1)];
        PE{1} = [PE{1};R_Metrics{i, 1}.TestEvent(:,4)];
        TE{1} = [TE{1};R_Metrics{i, 1}.TestEvent(:,5)];

        for LT=1:10
            Value = R_Metrics2{i, LT}.TestEvent_ML_all(:,1,:); 
            KGE_mean(k,1+LT)=median(mean(Value,'omitnan'),'omitnan');
            ValueM = mean(Value,'omitnan');
            KGE{1+LT} = [KGE{1+LT};ValueM(:)];
            PP5 = prctile(Value,5);
            KGE_CI{1+LT,1} = [KGE_CI{1+LT,1};PP5(:)];
            PP95 = prctile(Value,95);
            KGE_CI{1+LT,2} = [KGE_CI{1+LT,2};PP95(:)];
            Value = R_Metrics2{i, LT}.TestEvent_ML_ep(:,1,:);
            PP5 = prctile(Value,5);
            KGE_CI_ep{1+LT,1} = [KGE_CI_ep{1+LT,1};PP5(:)];
            PP95 = prctile(Value,95);
            KGE_CI_ep{1+LT,2} = [KGE_CI_ep{1+LT,2};PP95(:)];
            Value = R_Metrics{i, LT}.TestEvent_ML_all(:,4,:); 
            Value = mean(Value,'omitnan');
            PE{1+LT} = [PE{1+LT};Value(:)];
            Value = R_Metrics{i, LT}.TestEvent_ML_all(:,5,:); 
            Value = mean(Value,'omitnan');
            TE{1+LT} = [TE{1+LT};Value(:)];
        end
    end
end
save('Results5\R3.F4.mat',"TE","PE","KGE","Locat","KGE_mean","KGE_CI","KGE_CI_ep");

% Performance of NWM according to specific extreme events
clear all; close all; clc
load('Results5/R3-F1_Event.mat');
load('Results5\R2_Metrics.mat');
load('Results5\R2.DataColection.mat',"info","ReportData","NameS");
load('Results5\R3.F4.mat',"Locat");
for i=1:37
    try
        [Obs_NWM(:,:,i), USGSID(i,1),EventTime(:,i),ML(:,:,:,i)] = findspecificevent2(Estimated_Location(i,:),EventDate(i,:),info,ReportData,USGSID,R_Metrics);
        Datacheck(i,1) = 1;
    catch
        try
        [Obs_NWM(:,:,i), USGSID(i,1),EventTime(:,i)] = findspecificevent(Estimated_Location(i,:),EventDate(i,:),info,ReportData,USGSID);
        Datacheck(i,1) = 0;
        catch
            Datacheck(i,1) = 0;
        end

    end
end
save('Results5/R3-F5_Event.mat',"EventTime","USGSID","Obs_NWM","Estimated_Location","EventName","EventDate","Damage","Fatalities","EventData",'Datacheck',"ML");

clear all; close all; clc
load('Results5/R3-F1_Event.mat');
load('Results5\R2_Metrics.mat');
load('Results5\R2.DataColection.mat',"info","ReportData","NameS");
load('Results5\R3.F4.mat',"Locat");
for i=1:37
    try
        [Obs_NWM(:,:,i), USGSID(i,1),EventTime(:,i),ML2(:,:,:,i)] = findspecificevent3(Estimated_Location(i,:),EventDate(i,:),info,ReportData,USGSID,R_Metrics);
        Datacheck(i,1) = 1;
    catch
        try
        [Obs_NWM(:,:,i), USGSID(i,1),EventTime(:,i)] = findspecificevent(Estimated_Location(i,:),EventDate(i,:),info,ReportData,USGSID);
        Datacheck(i,1) = 0;
        catch
            Datacheck(i,1) = 0;
        end

    end
end
save('Results5/R3-F5_Event_Combine.mat',"EventTime","USGSID","Obs_NWM","Estimated_Location","EventName","EventDate","Damage","Fatalities","EventData",'Datacheck',"ML2");

% Performance of NWM with different watershed conditions
clear all; close all; clc
load('Results5\R2.DataColection.mat',"info","ReportData","NameS");
load('Results5\S2.Wcon.mat','Wcon','DefineValue',"ClassW");
load('Results5\R3.F4.mat',"TE","PE","KGE","Locat","KGE_mean","KGE_CI","KGE_CI_ep");
AreaUS = [0,100,200,500,1000,2000,5000];
for i=1:size(Wcon,2)
    if i<=3
        for j=1:max(Wcon(:,i))
            idx = find(Wcon(:,i)==j);
            PerformanceClass{i}{j}= KGE_mean(idx,:);
        end
    elseif i==4
        for j=1:numel(AreaUS)-1
            idx = find(Wcon(:,i)>=AreaUS(j)&Wcon(:,i)<AreaUS(j+1));
            PerformanceClass{i}{j}= KGE_mean(idx,:);
        end
    end
end
load('Results5\R3_Metrics_NewKGE.mat');
RFCs = shaperead('Data/USGS_boundary/RFC12.shp');
for i=1:12
    in = inpolygon(Locat(:,2),Locat(:,1),RFCs(i).X(1:end-1),RFCs(i).Y(1:end-1));
    idx = find(in==1);
    PerformanceClass{5}{i}= KGE_mean(idx,:);
end
k=0;
for i=1:size(ReportData,1)
    if ReportData(i,1) == 1
        k=k+1;
        Nevent(k,1) = round(numel(R_Metrics2{i, 1}.AllEvent)*0.9);
    end
end
eventN = [20,50,100,150,200,300];
for j=1:numel(eventN)-1
    idx = find(Nevent>=eventN(j)&Nevent<eventN(j+1));
    PerformanceClass{6}{j}= KGE_mean(idx,:);
end
load('E:\NWM21\Results5\R2_other.mat', 'R_PearsonC')

CorrelationUS = [];
for i=1:size(ReportData,1)
    if ReportData(i,1) == 1
        Ne = numel(R_Metrics2{i, 1}.TestEvent);
        CorrelationUS = [CorrelationUS;R_PearsonC{i, 1}(end-Ne+1:end,:)];
    end
end
SelectedVariables = [10,9,1]; % Precipitation, Potential ET, Temperature
save('Results5\R3_F6.mat',"PerformanceClass","AreaUS","eventN",'CorrelationUS',"SelectedVariables");

%  Estimate Flood Frequency-Return period
clear all; close all; clc
load('Results5\R2.DataColection.mat',"Q_USGS","info","ReportData","NameS");
DATETIME = [datetime(1979,02,01,01,00,00):days(1):datetime(2020,12,31,23,0,0)]';
for i=1:size(ReportData,1)
    i
    try
    if ReportData(i,1) == 1
        QRP(i,:) = floodfrequency_returnp(Q_USGS(:,i),DATETIME); % Using  log-Pearson III
    end
    catch
    end
end

% Compute economic value of NWM, NWM-ECN, NWM-ECN-reducible
load('Results5\R2.DataColection.mat',"info","ReportData","NameS");
load('Results5\Returnperiod.mat', 'QRP_All');
EnSize = [1,5,10,20,30,50,100:100:1000];
for i=1:size(ReportData,1)
    i
    if ReportData(i,1) == 1 && QRP_All(i,5) > 0
        for LT = 1:10
            Filename1 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(LT)+".mat";
            load(Filename1);
            for Nevent = 1:size(OBS,2)
                [VS_NWM{i,LT}(:,:,Nevent), probab{i,1}(Nevent,:,LT)] = economyvalue(OBS(:,Nevent),NWM(:,Nevent),QRP_All(i,:));       % NWM
                ECN_mean = mean(NWM_ML_combine(:,:,Nevent)');
                VS_ECN_mean{i,LT}(:,:,Nevent) = economyvalue(OBS(:,Nevent),ECN_mean',QRP_All(i,:));       % NWM
                VS_ECN_All{i,LT}(:,:,Nevent) = economyvalue(OBS(:,Nevent),NWM_ML_combine(:,:,Nevent),QRP_All(i,:));       % NWM 
                VS_ECN_Ep{i,LT}(:,:,Nevent) = economyvalue(OBS(:,Nevent),NWM_ML_ep(:,:,Nevent),QRP_All(i,:));       % NWM
                for ens=1:numel(EnSize)
                    VS_ECN_1{i,LT}(:,:,ens,Nevent) = economyvalue(OBS(:,Nevent),NWM_ML_combine(:,1:EnSize(ens),Nevent),QRP_All(i,:)); 
                end
            end
        end
    end
end
save('Results5/F5_EconomicValue_2.mat',"VS_NWM",'probab','VS_ECN_All',"VS_ECN_mean",'QRP_All','VS_ECN_1','VS_ECN_Ep','-v7.3');

% Additional Analysis results
Analysis_results;

%% Export Simulation Results (Obs, NWM, NWM-ECN)
load('Results5\R2.DataColection.mat',"info","ReportData","NameS");

for i=4500:size(ReportData,1)
    i
    if ReportData(i,1)
        for LT = 1:10
            Filename1 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(LT)+".mat";load(Filename1);
            Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];load(Filename);
            DataTable = maketable(Data.T,OBS,NWM,NWM_ML_combine);
            SaveName = ['ExportResults/NWM-ECN_USGS=',NameS{i},'_LT=',num2str(LT),'-day.txt'];
            writetable(DataTable,SaveName)
        end
    end
end
%% Plot main figures
Plot_F1;                    % Figure 1
Plot_F3;                    % Figure 3
Plot_F4;                    % Figure 4
Plot_F5;                    % Figure 5
Plot_F_Extended_1;          % Exteneted Figure 1
Plot_F_Extended_2;          % Exteneted Figure 2
end