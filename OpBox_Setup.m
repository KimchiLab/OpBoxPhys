% OpBox Physiology (EEG/EMG) Acquisition system
% 
% Physiology acquisition using NI-DAQ in Matlab as part of the OpBox System:
% Open Source/Operant Boxes for Behavioral Neurophysiology
%
% Primary Variables (3)
% s_in: Data Acquisition Devices: National Instruments Session & Devices are set up at start (daq term is reserved for libary)
% lh: Listener Handles: Event Listener handles: Log & Draw listeners set up at start
% subjects: Subject specific information, changes on fly as subjects added/removed
% room: Room name from which to identify subjects
%
% Copyright (c) 2014 Eyal Kimchi, MD, PhD (KimchiLab.org)
% 
% The MIT License (MIT)
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

% Clear info/data
clear all;
clc;
set(gcf, 'WindowStyle', 'docked')
clf;

% Identify Room: Only variable that needs to change between rooms
% Can't pass in as argument to function, 
% needs to be declared global outside of function before use, 
% hence script here rather than function
% room = 'TestRoom'; % Should be char/string
room = 'TyeHomeCageOpto'; % Should be char/string

global subjects; % Need to declare before setting up listener handles
                 % Global so that listener handles can catch changes

% Go to Directory to store data
cd(fileparts(mfilename('fullpath'))); % Directory of this mfile

% Setup devices
Fs = 1e3; % Sampling rate must be shared amongst all subjects
s_in = OpBoxPhys_DaqSetup(Fs); % Setup Data Acquisition Devices
lh = OpBoxPhys_Start(s_in); % Setup Listener Handles for data available events & start acquisition

%%% Additional Scripts:
% Add Subjects
OpBox_Add; % Run as a script

%%% Finish recording
% OpBox_Remove;  % Remove Subject(s)
% OpBox_Stop;  % Stop Acquisition
