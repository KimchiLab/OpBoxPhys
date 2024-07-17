# OpBox System for Physiology & Camera Recordings

Physiology acquisition (EEG & EMG) using the **OpBox System**  
(Open Source/Operant Boxes for Behavioral Neurophysiology)
 
Reproducible in vivo electrophysiology experiments require the collection of data from multiple subjects, often for extended periods. Studying multiple subjects for extended periods can be made more efficient through simultaneous recordings, but scaling up recordings to accommodate larger numbers of subjects simultaneously requires coordination and consideration of costs and flexibility. To facilitate this process, we have developed OpBox, an open source set of tools to acquire electroencephalography (EEG) and electromyography (EMG) flexibly from multiple rodent subjects simultaneously. OpBox combines open source hardware and software with off-the-shelf components to create a system that is inexpensive on a per-subject basis and can be easily deployed for multiple subjects. Coded in MATLAB, software widely used in neuroscience laboratories, OpBox scripts can simultaneously collect and display real-time EEG and EMG, and can be integrated with other data streams such as behavior. OpBox also calculates and displays real-time spectral representations and event-related potentials (ERPs). To verify the performance of our system, we compare our amplifiers with two other commercial amplifiers using common benchmarks. We also demonstrate that our acquisition system can reliably record multi-channel data from multiple subjects, and has been successfully tested with at least 12 subjects running simultaneously on a single standard desktop computer. Together, OpBox increases the flexibility and lowers the cost for simultaneous acquisition of electrophysiology data from multiple subjects.


## Folders

* **Amplifier PCB Designs**: Multi-channel, open source OpBox amplifier PCB designs (3 and 4 channel)
* **How to Build and Parts List**: How to build information and parts lists for OpBox amplifiers
* **OpBox Phys Scripts**: MATLAB based scripts to acquire data from OpBox amplifiers, using National Instruments data acquisition devices
