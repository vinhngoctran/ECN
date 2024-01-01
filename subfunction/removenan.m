function [SIM2 OBS2] = removenan(SIM,OBS)
k=0;
SIM2 = [];
OBS2 = [];
for i=1:numel(SIM)
    if ~isnan(SIM(i)) && ~isnan(OBS(i))
        k=k+1;
        SIM2(k,1) = SIM(i);
        OBS2(k,1) = OBS(i);
    end
end
end