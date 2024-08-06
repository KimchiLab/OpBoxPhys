% OpBox Physiology (EEG/EMG) Acquisition system
% Copyright (c) 2014 Eyal Kimchi, MD, PhD (KimchiLab.org)
% MIT License (see License.txt)
% 
% Primary Variables:
% subjects: Subject specific information, changes on fly as subjects added/removed
% s_in: Data Acquisition Devices: National Instruments Session & Devices are set up at start (daq term is reserved for libary)
% lh: Listener Handles: Event Listener handles: Log & Draw listeners set up at start
%
% Required Matlab toolboxes/packages include:
% Data Acquisition Toolbox + Data Acquisition Toolbox Support Package for National Instruments NI-DAQmx Devices
% Image Acquisition Toolbox + Image Acquisition Toolbox Support Package for OS Generic Video Interface 

% Clear info/data
clear all; % Releases NI devices if previously reserved
% clc;
set(gcf, 'WindowStyle', 'docked')
clf;

% Identify Room: Only variable that needs to change between rooms
% Can't pass in as argument to function, 
% needs to be declared global outside of function before use, 
% hence script here rather than function
% room = 'TestRoom'; % Should be char/string
room = '13-341'; % Should be char/string

global subjects; % Need to declare before setting up listener handles, Global so that listener handles can catch changes
global cam_global; % Need to declare before setting up listener handles, Global so that listener handles can catch changes

% Go to Directory to store data
cd(fileparts(mfilename('fullpath'))); % Start at the directory of this mfile
addpath(pwd); % Add this directory to path, important for listener handle functions to stay accessible

% Setup devices
Fs = 1e3; % Sampling rate must be shared amongst all subjects/devices
[s_in, cam_global, wincam_info] = OpBoxPhys_SetupDevices(Fs); % Setup all available Data Acquisition Devices
OpBoxPhys_Start(s_in); % Prepare Listener Handles for data available events & start acquisition

% Additional Scripts
OpBox_Add; % Add Subjects after initial start


%% Finish recording
% OpBox_Remove;  % Remove Subject(s)
% OpBox_Stop;  % Stop Acquisition
