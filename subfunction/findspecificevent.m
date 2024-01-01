function [EventData, USGSID,EventTime] = findspecificevent(Estimated_Location,EventDate,info,ReportData,PriorID)
% Compute distances
Distance = sqrt((Estimated_Location(1,1)-info(:,3)).^2+(Estimated_Location(1,2)-info(:,4)).^2);
Distance(:,2) = (1:1:numel(Distance))';
Distance = sortrows(Distance,1);
Cond = 0;
Peak = 0;
% Find appropriate events and USGS station with Radius < 2.5 degree
% Select USGS with highest peak
for i=1:size(info,1)
    idx = find(PriorID==Distance(i,2));
     if ReportData(Distance(i,2),1) == 1 && Distance(i,1) <= 2.5 && isempty(idx)
        Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];
        load(Filename,"Data");
        for j=1:size(Data.T,2)
            if Data.T(41,j) >= EventDate(1) && Data.T(end,j) <= EventDate(2) || Data.T(41,j) <= EventDate(1) && Data.T(end,j) >= EventDate(1) || Data.T(41,j) <= EventDate(2) && Data.T(end,j) >= EventDate(2)
                if max(Data.Q(41:end,1,j)) > Peak
                    EventData = Data.Q(41:end,:,j);
                    EventTime = Data.T(41:end,j);
                    USGSID = Distance(i,2);
                    Peak = max(Data.Q(41:end,:,j));
                end
            end
        end
     end
%      if Cond ==1
%          break
%      end
end

end