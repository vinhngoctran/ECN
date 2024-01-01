%% Evaluation
function extractdata_US(i)
% addpath(genpath(pwd));
load('Results5/R2.DataColection.mat',"info","ReportData","Q_USGS");
%load('Results5/R2.EventReport.mat',"ReportData","Q_USGS");
%load('Results5/R1.Data.mat',"USGS_Q","DATETIME");
DATETIME = [datetime(1979,02,01,01,00,00):days(1):datetime(2020,12,31,23,0,0)]';
for LT = 1:10
        [i LT]
        Filename = "Results5/R1/W_"+num2str(i)+"_"+num2str(LT)+".mat";
        Filename2 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(LT)+".mat";
        if ReportData(i,1) == 1 && exist(Filename) && ~exist(Filename2)
          
            [OBS_all,NWM_all,OBS, NWM, NWM_ML_ep,NWM_ML_ale,NWM_ML_combine,BaseFlow,PearsonC, RunTime] = reconstructresults8(i,LT,Q_USGS(:,i),DATETIME);
            %ReturnP = floodfrequency(OBS_all,Q_USGS(:,i),DATETIME); % Using  log-Pearson III
            Metrics = evaluationResults(OBS_all,NWM_all,OBS, NWM, NWM_ML_ep,NWM_ML_ale,NWM_ML_combine);
            save(Filename2,'OBS_all','NWM_all','OBS', 'NWM', 'NWM_ML_ep','NWM_ML_ale','NWM_ML_combine',"PearsonC","BaseFlow","Metrics","RunTime");
            
        end
end
