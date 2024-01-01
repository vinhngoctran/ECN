Simulation data (download): 

The NWM-ECN simulation data for 42,407 flood events over 4497 locations is stored in the NWM-ECN.zip file. Specifically, the zip file contains 44,970 text files, each of which corresponds to a location and its corresponding lead time predictions (44970 = 4497 locations * 10 lead time predictions).
The file names are structured as "NWM-ECN_USGS=" + Name/ID of USGS gage + "_LT=" + lead time + "-day.txt".
Each text file contains columns including [Date and Time, USGS observation, NWM simulation, NWM-ECN_1,... NWM-ECN_1000]. The last 1000 columns on the right side of each text file represent 1000 ensemble predictions of NWM-ECN.

ECN code (ExportSources.zip):

Python code (i.e., ECN.py) to train ECN for each location and lead time,
Matlab codes to generate figures in the Main text.

Reference: doi:10.5281/zenodo.10443931
