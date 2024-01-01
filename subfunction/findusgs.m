function [ID_USGS, temp_distance] = findusgs(ID_LATLON,USGS_All,MaxDistance)

Distance = sqrt((ID_LATLON(1)-USGS_All(:,1)).^2+(ID_LATLON(2)-USGS_All(:,2)).^2)*111139;
if min(Distance) < MaxDistance % 1000 m
    idx = find(Distance==min(Distance));
    ID_USGS = idx(1);
    temp_distance = Distance(idx(1));
%     ID_USGS = double([USGS_All(idx(1),1), min(Distance)]);
else
    ID_USGS = NaN;
    temp_distance = NaN;
end

end