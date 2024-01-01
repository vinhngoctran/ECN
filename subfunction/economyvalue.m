function [Value,probab] = economyvalue(Obs,Sim,Threshold)
SelectedThres = Threshold([5, 10, 20, 50, 100]);
for i=1:5
    [probab(i),TP,FP,TN,FN] = computeweight(Obs,Sim,SelectedThres(i));
    Value(:,i) = economicval(probab(i),TP,FP,TN,FN);
end 
end
%%
function [probab,TP,FP,TN,FN] = computeweight(Obs,Sim,Threshold)
N_ensemble = size(Sim,2);
for i=1:numel(Obs)
    Simt = Sim(i,:);
    if Obs(i)>=Threshold
        TP(i,1) = sum(Simt>=Threshold)/numel(Simt);
        FN(i,1) = 1 - TP(i,1);
        TN(i,1) = 0;
        FP(i,1) = 0;
    else
        TN(i,1) = sum(Simt<Threshold)/numel(Simt);
        FP(i,1) = 1 - TN(i,1);
        TP(i,1) = 0;
        FN(i,1) = 0;
    end
end
TP = sum(TP)/numel(Obs);
TN = sum(TN)/numel(Obs);
FP = sum(FP)/numel(Obs);
FN = sum(FN)/numel(Obs);
probab = TP+FN;
end

%%
function Value= economicval(probab,TP,FP,TN,FN)
CL = [0:0.05:1];
for i=1:numel(CL)
    Ec = min([CL(i),probab]);
    Ep = probab*CL(i);
    Ef = (TP+FP)*CL(i) + FN;
    Value(i,1) = (Ef - Ec)/(Ep-Ec);
end
Value(isnan(Value)) = 0;
Value(Value<0)=0;
Value(Value==Inf)=0;
end