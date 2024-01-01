function Data = selectevent2(DATE,Q_obs,Q_sim,Clim_US,ModStates_Dat,thres)
Qlevel = prctile(Q_obs(:,1),thres);
if Qlevel==0
    Qlevel = 5;
end
k=0;
Data = [];
for i=56:size(DATE,1)-16
    OBS = Q_obs(i-54:i+15,1);
    SIM = Q_sim(i-54:i+15,1);

    WEATH = Clim_US(i-54:i+15,:);
%     STATES = ModStates_Dat(i-25:i+14,:);
    idx = find(OBS == max(OBS));
    if isempty(idx)
        idx = [];
    else
        DATE_temp = DATE(i-55+idx(1),:);
        if k==0
            idx = [];
        else
            idx = find(Data.T(:,k)==DATE_temp);
        end
    end
    if Q_obs(i,1) >= Qlevel && Q_obs(i,1)==max(OBS(41:70,1)) && isempty(idx)
        if isempty(find(isnan(SIM))) && isempty(find(isnan(OBS))) && isempty(find(isnan(WEATH)))
            k=k+1;
            Data.Q(:,:,k) = [OBS SIM];
%             Data.S(:,:,k) = STATES;
            Data.W(:,:,k) = WEATH;
            Data.T(:,k) = DATE(i-54:i+15,:);
        end
    end
end

end


