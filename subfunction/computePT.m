function [DeltaP, DeltaT] = computePT(Sim, Obs)
idx = find(Sim==max(Sim));
idy = find(Obs==max(Obs));
DeltaP = (Sim(idx(1),1) - Obs(idy(1),1))/Obs(idy(1),1)*100;
DeltaT = idx(1) - idy(1);
end