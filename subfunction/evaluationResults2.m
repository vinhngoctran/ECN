function Metrics = evaluationResults2(OBS_all,NWM_all,OBS, NWM, NWM_ML_ep,NWM_ML_ale,NWM_ML_combine)
for i=1:size(OBS_all,2)
    Metrics.AllEvent(i,:) = computemetricKGE(NWM_all(:,i),OBS_all(:,i));
end
for i=1:size(OBS,2)
    Metrics.TestEvent(i,:) = computemetricKGE(NWM(:,i),OBS(:,i));
    for j=1:1000
        Metrics.TestEvent_ML_ep(j,:,i) = computemetricKGE(NWM_ML_ep(:,j,i),OBS(:,i));
        Metrics.TestEvent_ML_all(j,:,i) = computemetricKGE(NWM_ML_combine(:,j,i),OBS(:,i));
    end
%     Metrics.UncertainRange(i,1) = UncerRange(NWM_ML_ep(:,:,i));
%     Metrics.UncertainRange(i,2) = UncerRange(NWM_ML_ale(:,:,i));
%     Metrics.UncertainRange(i,3) = UncerRange(NWM_ML_combine(:,:,i));
end

end