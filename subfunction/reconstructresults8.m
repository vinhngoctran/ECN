function [OBS_all,NWM_all,OBS, NWM, NWM_ML_ep,NWM_ML_ale,NWM_ML_combine,BaseFlow,PearsonC,RunTime] = reconstructresults7(i,LT,Q_USGS,DATETIME)
Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];load(Filename);
Filename = "Results5/R1/W_"+num2str(i)+"_"+num2str(LT)+".mat";load(Filename);
load("Data/Input8/W_"+num2str(i)+"_"+num2str(LT)+".mat","SY","CY",'Ytest');
Ytest = Ytest*SY+CY;
eps = eps*SY+CY;
a_u = a_u*SY+CY;
BaseFlow = sig_BFI(Q_USGS, DATETIME);
if isnan(BaseFlow)
    BaseFlow = min(Q_USGS(~isnan(Q_USGS)&Q_USGS>0));
end
nEvent = size(eps,1)/30;
for i=1:size(Data.Q,3)
    OBS_all(:,i) = Data.Q(41:end,1,i);
    NWM_all(:,i) = Data.Q(41:end,2,i);
    
    % Pearson correlation
    for j=1:size(Data.W,2)
        R = corrcoef(OBS_all(:,i),Data.W(41:end,j,i));
        PearsonC(i,j) = double(R(2,1));
    end
end
for i=1:nEvent
    OBS(:,i)=Data.Q(41:end,1,size(Data.Q,3)-nEvent+i);
    NWM(:,i)=Data.Q(41:end,2,size(Data.Q,3)-nEvent+i);
    NWM_ML_ep(:,:,i) = eps((i-1)*30+1:i*30,:)+NWM(:,i);
    NWM_ML_ale(:,:,i) = a_u((i-1)*30+1:i*30,:);
%     NWM_ML_combine(:,:,i) = mean(NWM_ML_ep(:,:,i)')'+NWM_ML_ale(:,:,i);
    NWM_ML_combine(:,:,i) = NWM_ML_ep(:,:,i)+NWM_ML_ale(:,:,i);
end
    % Avoid negative values
    NWM_ML_ep(NWM_ML_ep<0) = BaseFlow;
    NWM_ML_combine(NWM_ML_combine<0) = BaseFlow;
    try
        RunTime = RunTime/nEvent;
    catch
        RunTime = NaN;
    end
end