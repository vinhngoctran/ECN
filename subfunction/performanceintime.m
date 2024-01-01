function [KGE, PE, TE]=performanceintime(R_Metrics,R_Metrics2,i,KGE, PE, TE)
DATETIME = [1979:1:2020];
Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];
load(Filename,"Data");
for i=1:size(Data.T,2)
    yyyy = str2num(datestr(Data.T(55,i),'yyyy'));
    idx = find(DATETIME==yyyy);
    KGE{idx}=[KGE{idx};R_Metrics2(i,1)];
    PE{idx}=[PE{idx};R_Metrics(i,4)];
    TE{idx}=[TE{idx};R_Metrics(i,5)];
end
end