%% Uncertainty range
function UR = UncerRange(Data)

    UR = mean(prctile(Data',95)-prctile(Data',5));
end