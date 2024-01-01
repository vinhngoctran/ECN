function [SIM OBS] = generateSimData(SelectedStreamflow,SelectedGauge,DATETIME)              
    OBS = SelectedStreamflow*0.028316847; % Units: cfs to cms
    NAMEF = ['Data/NWM/NWM_',num2str(SelectedGauge(1))]; load(NAMEF);
    TT = array2timetable(Q','RowTimes',DATETIME,'VariableNames',{'Q'});
    Qdaily = retime(TT,'daily','mean');
    SIM = Qdaily.Q;                         % Units: cms
end