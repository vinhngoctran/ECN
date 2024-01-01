# Source code:
* Main.m is the Matlab code for data processing, model simulating, and data analysis
* Sub Matlab functions are included in Subfunction folder
* Python code (i.e., Errorcastnet.py) to train ECN for each location and lead time is located in Subfunction folder
* Visualization folder contains Matlab codes to generate figures in the Main text.

# Simulation data: 
* The NWM-ECN simulation data for 42,407 flood events over 4497 locations is stored in the [NWM-ECN.zip](https://drive.google.com/u/0/uc?id=1sXNPbawz_9oN9damjoRDToiBa_CG7LKy&export=download) file that can be downloaded [here](https://drive.google.com/u/0/uc?id=1sXNPbawz_9oN9damjoRDToiBa_CG7LKy&export=download). Specifically, the zip file contains 44,970 text files, each of which corresponds to a location and its corresponding lead time predictions (44970 = 4497 locations * 10 lead time predictions).
* The file names are structured as "NWM-ECN_USGS=" + Name/ID of USGS gage + "_LT=" + lead time + "-day.txt".
* Each text file contains columns including [Date and Time, USGS observation, NWM simulation, NWM-ECN_1,... NWM-ECN_1000]. The last 1000 columns on the right side of each text file represent 1000 ensemble predictions of NWM-ECN.

Data reference: Vinh Ngoc Tran, vinhtn@umich.edu
