% OpBox Physiology (EEG/EMG) Acquisition system
% Copyright (c) 2014 Eyal Kimchi, MD, PhD (KimchiLab.org)
% MIT License (see License.txt)
% 
% Primary Variables:
% subjects: Subject specific information, changes on fly as subjects added/removed
% s_in: Data Acquisition Devices: National Instruments Session & Devices are set up at start (daq term is reserved for libary)
% lh: Listener Handles: Event Listener handles: Log & Draw listeners set up at start

% Clear info/data
clear all;
clc;
set(gcf, 'WindowStyle', 'docked')
clf;

% Identify Room: Only variable that needs to change between rooms
% Can't pass in as argument to function, 
% needs to be declared global outside of function before use, 
% hence script here rather than function
room = 'TestRoom'; % Should be char/string

global subjects; % Need to declare before setting up listener handles, Global so that listener handles can catch changes

% Go to Directory to store data
cd(fileparts(mfilename('fullpath'))); % Directory of this mfile

% Setup devices
Fs = 1e3; % Sampling rate must be shared amongst all subjects
s_in = OpBoxPhys_SetupDevices(Fs); % Setup all available Data Acquisition Devices
lh = OpBoxPhys_Start(s_in); % Prepare Listener Handles for data available events & start acquisition

%%% Additional Scripts
OpBox_Add; % Add Subjects after initial start


%% Finish recording
% OpBox_Remove;  % Remove Subject(s)
% OpBox_Stop;  % Stop Acquisition
