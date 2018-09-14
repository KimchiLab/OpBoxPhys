# OpBoxPhys

Physiology acquisition using the OpBox System (Open Source/Operant Boxes for Behavioral Neurophysiology)
 
This software library uses NI-DAQ devices in Matlab to collect physiology and behavioral data from multiple subjects simultaneously but also asynchronously.

## Main Functions
* *OpBox_Setup*: Setup acquisition devices
* *OpBox_Add*: Add subjects once the system has been setup
* *OpBox_Remove*: Remove subjects that are currently being recorded from
* *OpBox_Stop*: Stop data acquisition

## Additional Functions
* OpBox_Axis_Time: Change the axis for the display of temporal data
* OpBox_ResetEP: Reset the evoked potentials being displayed

## Acknowledgements

This library includes the file csvimport.m from http://uk.mathworks.com/matlabcentral/fileexchange/23573-csvimport in OpBoxPhys_InfoBoxSubj
