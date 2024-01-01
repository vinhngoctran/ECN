function [SIM OBS] = generateData(SelectedStreamflow,SelectedGauge,DATETIME)
    OBS = SelectedStreamflow(:,SelectedGauge(1));                       % Units: cfs
    OBS = OBS*0.028316847;
    NAMEF = ['Data/NWM/NWM_',num2str(SelectedGauge(1))]; load(NAMEF);
    TT = array2timetable(Q','RowTimes',DATETIME,'VariableNames',{'Q'});
    Qdaily = retime(TT,'daily','mean');
    SIM = Qdaily.Q;                         % Units: cms
end