# OpBox System for Physiology & Camera Recordings

Physiology acquisition (EEG & EMG) using the **OpBox System**  
(Open Source/Operant Boxes for Behavioral Neurophysiology)
 
Reproducible in vivo electrophysiology experiments require the collection of data from multiple subjects, often for extended periods. Studying multiple subjects for extended periods can be made more efficient through simultaneous recordings, but scaling up recordings to accommodate larger numbers of subjects simultaneously requires coordination and consideration of costs and flexibility. To facilitate this process, we have developed OpBox, an open source set of tools to acquire electroencephalography (EEG) and electromyography (EMG) flexibly from multiple rodent subjects simultaneously. OpBox combines open source hardware and software with off-the-shelf components to create a system that is inexpensive on a per-subject basis and can be easily deployed for multiple subjects. Coded in MATLAB, software widely used in neuroscience laboratories, OpBox scripts can simultaneously collect and display real-time EEG and EMG, and can be integrated with other data streams such as behavior. OpBox also calculates and displays real-time spectral representations and event-related potentials (ERPs). To verify the performance of our system, we compare our amplifiers with two other commercial amplifiers using common benchmarks. We also demonstrate that our acquisition system can reliably record multi-channel data from multiple subjects, and has been successfully tested with at least 12 subjects running simultaneously on a single standard desktop computer. Together, OpBox increases the flexibility and lowers the cost for simultaneous acquisition of electrophysiology data from multiple subjects.


## Folders
* **Amplifier PCB Designs**: Multi-channel, open source OpBox amplifier PCB designs (3 and 4 channel)
* **How to Build and Parts List**: How to build information and parts lists for OpBox amplifiers
* **OpBox Phys Scripts**: MATLAB based scripts to acquire data from OpBox amplifiers, using National Instruments data acquisition devices


## Changing Windows USB Webcam names
* Note, this requires editing the Registry, which should only be undertaken by experienced users at their own risk after backing it up *  
1. Open Device Manager
1. Right click on the camera, select Properties
1. Click on the details tab
1. Under Property, select Driver Key
1. Right click and copy the Value
1. Run regedit.exe
1. Go to HKEY_LOCAL_MACHINE -> SYSTEM -> ControlSet001 (left click on that)
1. Ctrl-F to find: paste the Driver Key Value
1. It should take you to a folder within Enum -> USB
1. Double Click on Friendly Name and adjust the name (e.g. HD USB Camera -> HD USB Camera 01)
1. Back to Device Manager, under Property, select Device instance path
1. Right click and copy the Value
1. Back to Registry Editor
1. Go to HKEY_LOCAL_MACHINE -> SYSTEM -> CurrentControlSet
1. Ctrl-F to find: paste the Device instanc path Value
1. It should take you to a folder within Control -> DeviceClasses
1. Go within that folder to #GLOBAL -> Device Parameters
1. Double Click on Friendly Name and adjust the name (e.g. HD USB Camera -> HD USB Camera 01)
1. Back to Device Manager -> Action -> Scan for Hardware Changes
1. You may need to restart Matlab or at least run imaqreset, which will cause problems if OpBox is running, so stop all recordings first


## FYI: Pinnacle 2 EEG/ 1 EMG Connections

| Mouse Connection | Pinnacle Connector | Pinnacle Label | Plastics1 Cable Color | Plug Pos | Commutator Socket Pos | Commutator color | Amp Channel | BNC Channel | Matlab Color | Desc |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EEG Ant Left | Ant Left | AGND | Red | 4 | 6 | ***Black*** | G | | | |
| EEG Ant Right | Ant Mid | EEG2 | White | 5 | 5 | White | EEG B | 2 | Orange | Contra-A/P|
| EMG Right | Ant Right | EMG B | Black | 6 | 4 | ***Red*** | EMG | | | |
| EEG Post Left | Post Left | EEG Common | Green | 1 | 1 | Green | EEG Ref | | | |
| EEG Post Right | Post Mid | EEG1 | Blue | 2 | 2 | Blue | EEG A | 1 | Blue | Contra-Horiz |
| EMG Left | Post Right | EMG A | Yellow | 3 | 3 | Yellow | EMG | 3 | Yellow | EMG |
