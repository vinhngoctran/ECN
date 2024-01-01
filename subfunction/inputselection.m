function SelectedLagMI = inputselection(Candidate,TargetQoI,Delay)
for k=1:size(Candidate,2)              % The number of candidate inputs
    for l=1:Delay          % The number of lookback periods
        MI(l,k) = mi(TargetQoI(l+1-1:end),Candidate(1:end-l+1,k));
    end
    DMI = abs(MI(:,k) - median(MI(:,k)));
    SelectedLagMI(k,1) = 7;    % Set minimum lookback period = 7-day
    for l=8:Delay
        Z = DMI(l)/(median(DMI)*1.4826);
        if Z<3
            break
        else
            SelectedLagMI(k,1)=SelectedLagMI(k,1)+1;
        end
    end
end
end