function DataTable = maketable(TT,OBS,NWM,NWM_ECN)
for i=1:size(OBS,2)
    if i==1
        TimeTab = TT(41:end,end-size(OBS,2)+i);
        Observation = OBS(:,i);
        NWMSim = NWM(:,i);
        NWMECN = NWM_ECN(:,:,i);
    else
        TimeTab = [TimeTab;TT(41:end,end-size(OBS,2)+i)];
        Observation = [Observation;OBS(:,i)];
        NWMSim = [NWMSim;NWM(:,i)];
        NWMECN = [NWMECN;NWM_ECN(:,:,i)];
    end

end
DataTable = table(TimeTab,Observation,NWMSim,NWMECN);
end