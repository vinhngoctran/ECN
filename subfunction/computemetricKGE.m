function Metrics = computemetricKGE(SIM2,OBS2)
%     Metrics(1) = ComputeR2(SIM2,OBS2);
%     Metrics(2) = Nash(SIM2,OBS2);
    Metrics(1) = KGE_compute(SIM2,OBS2);
%     [Metrics(4), Metrics(5)] = computePT(SIM2, OBS2);
end