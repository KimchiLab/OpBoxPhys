# OpBox Phys

Physiology acquisition (EEG & EMG) using the **OpBox System**  
(Open Source/Operant Boxes for Behavioral Neurophysiology)
 
The OpBox Phys software library was written in MATLAB to use National Instruments Data Acquisition Devices to collect physiology and behavioral data from multiple subjects simultaneously. It requires MATLAB's Data Acquisition Toolbox and NI's DAQmx drivers.

## Scripts/Functions
OpBox MATLAB scripts are grouped into several types:  

* OpBox_\*.m: Intended to be called by users  
* OpBoxPhys_\*.m: Called internally by other scripts
* \*.csv: Spreadsheets (in text based comma separated value format) used for configuration by users

## Main Functions
* *OpBox_Setup*: Setup data acquisition devices
* *OpBox_Add*: Add subjects once the system has been setup
* *OpBox_Remove*: Remove one or more subjects that are currently being recorded from
* *OpBox_Stop*: Stop data acquisition

## Additional functions
* *OpBox\_Axis\_Time*: Change the axis for the display of temporal data
* *OpBox_ResetEP*: Reset the evoked potentials being displayed
* *OpBox_LoadPhysData*: Load data collected in a prior session

## Configuration
The .csv spreadsheets can be edited using a text editor or standard spreadsheet program. If using a program such as Excel, make sure to save in the same text based .csv format when done

* *InfoBoxes.csv*: Configuration for various the various "OpBoxes". This includes assignments of different DAQ devices and input channels (analog, digital, rotary encoders) to specific boxes/amplifiers. It is also possible to associate webcams.
* *InfoSubjects.csv*: Configuration for assigments of various subjects to various boxes and groups

Webcams can be used to monitor and save video during acquisition, although MATLAB's image acquisition from webcams can be slower than other more dedicated systems. OpBox will try to connect to webcams using MATLAB's winvideo driver. In general OpBox has been written for Windows, but can be adapted to other OSes.

## Acknowledgements

This library includes the file [csvimport.m](http://uk.mathworks.com/matlabcentral/fileexchange/23573-csvimport) in OpBoxPhys_InfoBoxSubj.m
This file is used to load csv files for OpBox in MATLAB R2013a. 
Subsequent MATLAB releases included the function *readtable.m*
