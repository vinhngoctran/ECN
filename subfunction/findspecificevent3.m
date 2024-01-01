function [EventData, USGSID,EventTime,ML] = findspecificevent3(Estimated_Location,EventDate,info,ReportData,PriorID,R_Metrics)
% Compute distances
Distance = sqrt((Estimated_Location(1,1)-info(:,3)).^2+(Estimated_Location(1,2)-info(:,4)).^2);
Distance(:,2) = (1:1:numel(Distance))';
Distance = sortrows(Distance,1);
Cond = 0;
Peak = -999;
% Find appropriate events and USGS station with Radius < 2.5 degree
% Select USGS with highest peak
for i=1:size(info,1)
    idx = find(PriorID==Distance(i,2));
     if ReportData(Distance(i,2),1) == 1 && Distance(i,1) <= 5 && isempty(idx) && ~isempty(R_Metrics{i, 1})
        Filename = ['Data/EnsembleData4/USGS_',num2str(i),'.mat'];
        load(Filename,"Data");
        Nsize = size(Data.T,2) - round(0.1*size(Data.T,2))+1;
        for j=Nsize:size(Data.T,2)
            if Data.T(41,j) >= EventDate(1) && Data.T(end,j) <= EventDate(2) || Data.T(41,j) <= EventDate(1) && Data.T(end,j) >= EventDate(1) || Data.T(41,j) <= EventDate(2) && Data.T(end,j) >= EventDate(2)
%                 [j Nsize j+1-Nsize]
                NWM = R_Metrics{i, 1}.TestEvent(j+1-Nsize,2); 
                Value = R_Metrics{i, 1}.TestEvent_ML_all(:,2,j+1-Nsize); 
                KGE_mean=median(Value(:),'omitnan');
                if KGE_mean > Peak && KGE_mean > NWM+0.2
%                 if max(Data.Q(41:end,1,j)) > Peak
                    EventData = Data.Q(41:end,:,j);
                    EventTime = Data.T(41:end,j);
                    USGSID = Distance(i,2);
                    Peak = KGE_mean
                    Filename2 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(1)+".mat";
                    load(Filename2,'NWM_ML_ep');
                    ML(:,:,1) = NWM_ML_ep(:,:,j+1-Nsize);
                    Filename2 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(5)+".mat";
                    load(Filename2,'NWM_ML_ep');
                    ML(:,:,2) = NWM_ML_ep(:,:,j+1-Nsize);
                    Filename2 = "Results5/R1_2/W_"+num2str(i)+"_"+num2str(10)+".mat";
                    load(Filename2,'NWM_ML_ep');
                    ML(:,:,3) = NWM_ML_ep(:,:,j+1-Nsize);
                end
            end
        end
     end
%      if Cond ==1
%          break
%      end
end

end