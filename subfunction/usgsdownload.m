function SelectedStreamflow = usgsdownload(ID_USGS,StartDate,Enddate)
FinalDate = [datetime(StartDate):days(1):datetime(Enddate)]';
LinkName = ['https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=',num2str(ID_USGS),'&legacy=&referred_module=sw&period=&begin_date=',StartDate,'&end_date=',Enddate];
outfilename = websave('Data/Temp/test.txt',LinkName);
% pause
try
    data = readtable('Data/Temp/test.txt');
    DATED = datetime(data.datetime);
    Streamflow = table2array(data(:,4));
    for i=1:numel(FinalDate)
        idx = find(DATED==FinalDate(i));
        if isempty(idx)
            SelectedStreamflow(i,1) = NaN;
        else
            SelectedStreamflow(i,1) = Streamflow(idx);
        end
    end
catch
    SelectedStreamflow(1:numel(FinalDate),1) = NaN;
end
delete 'Data/Temp/test.txt'
end