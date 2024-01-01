import ee
import numpy as np 
import pandas as pd
import datetime
from datetime import datetime
from datetime import timedelta
import warnings
warnings.filterwarnings('ignore')
import geopandas as gpd
import gc
import os.path
import os					
import time					
service_account = ''
credentials = ee.ServiceAccountCredentials(service_account, '')
ee.Initialize(credentials)
def watershed_engine(watershed,idx):
    #Name = "Watershed/each_watershed/W_"+idx+".shp"
    idxx = watershed.GAGE_ID[idx]
    #watershed = gpd.read_file(Name)
    watershedx = watershed.to_crs(4326)
    ee_geometry = ee.Geometry(watershedx.geometry.values[0].__geo_interface__)
    startdate = '1979-01-01'
    c = 0
    start_time = time.time()
    while True:
        #print(watershed.area)
        try:
            collection = ee.ImageCollection('NASA/NLDAS/FORA0125_H002')
            # Date filtering
            if c == 0:
                start_date = startdate
            else:
                start_date = str(pd.to_datetime(end_date))[:10]
            print(start_date)
            end_date = str(pd.to_datetime(start_date) + timedelta(days = 30))[:10]
            filtered = collection.filterDate(start_date, end_date)
            filtered = filtered.filterBounds(ee_geometry)
            if c == 0:
                resolution = 111139*1
                values = filtered.getRegion(ee_geometry, resolution).getInfo() #10 km/ 5km /1 km /500 m
                if len(values)  == 1:
                    resolution = 111139*0.125*2
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/2
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/4
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/8
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/10
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/20
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/50
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
                if len(values)  == 1:
                    resolution = 111139*0.125/100
                    values = filtered.getRegion(ee_geometry, resolution).getInfo()
            else:
                values = filtered.getRegion(ee_geometry, resolution).getInfo()
            #print(values)
            colname = values[0].copy()
            values = pd.DataFrame(values[1:])
            values.columns = colname
            values['Time'] = pd.to_datetime(values['id'].str.split('A', expand = True).iloc[:, 1], format = '%Y%m%d_%H%M')
            values['date'] = values['Time'].dt.floor('d')
            values = values.groupby('date').agg(np.nanmean)
            values['date'] = values.index
            values.index = list(range(0, len(values)))
            values = values[['date', 'temperature', 'specific_humidity',
                   'pressure', 'wind_u', 'wind_v', 'longwave_radiation',
                   'convective_fraction', 'potential_energy', 'potential_evaporation',
                   'total_precipitation', 'shortwave_radiation']]
            if c == 0:
                values_all = values
            else:
                values_all = pd.concat([values_all, values])
            c += 1
            gc.collect()
            end_time = time.time()
            running_time = end_time - start_time
            print("Running time:", running_time, "seconds")
        except:                
            try:
            	values_all = values_all.reset_index()[['date', 'temperature', 'specific_humidity',
                   'pressure', 'wind_u', 'wind_v', 'longwave_radiation',
                   'convective_fraction', 'potential_energy', 'potential_evaporation',
                   'total_precipitation', 'shortwave_radiation']]
            	Name = "Forcings/W_"+idxx+".csv"
            	values_all.to_csv(Name, index=False)
            except:
            	print("No values: "+idxx)
            	values_er = [0,0]
            	Name = "Forcings/E_"+idxx+".csv"
            	np.savetxt(Name , values_er)
            break
import scipy.io
all_watershed = gpd.read_file("Watershed/All_Watershed_arc_selected.shp")
Data = scipy.io.loadmat('MissingID2.mat')
IDData = Data['IDE']
IDData = IDData.tolist()
IDData = np.array(IDData)
for i in range(0,10000):
    idx = int(IDData[i])
    Name = "Forcings/W_"+all_watershed.GAGE_ID[idx]+".csv"
    Name2 = "Forcings/E_"+all_watershed.GAGE_ID[idx]+".csv"
    each_watershed = gpd.GeoDataFrame(all_watershed.iloc[idx:idx+1, :])
    if os.path.isfile(Name2)==True:
        os.remove(Name2)
            
    if os.path.isfile(Name)==True:
        Data = pd.read_csv(Name)
        if Data.shape[0] < 16000:
            os.remove(Name)
    if os.path.isfile(Name)==False:
        watershed_engine(each_watershed,idx)

    
    