% Set up National Instrument data acquisition devices
% Using Mathworks Data Acquisition Toolbox
function [s_in] = OpBoxPhys_Setup(Fs)

%% Default Parameters
% Sampling rate if none specified
if nargin < 1
    Fs = 1e3;
end

%% Initialize National Instruments Device & Add Analog&Digital Input/Output Channels
fprintf('OpBox: Initializing devices...\n');
if ~exist('daq')
    fprintf('daq from Data Acquisition Toolbox not found\n');
end
nidevs = daq.getDevices; % Gets device info
if 0 == numel(nidevs)
    fprintf('No NI devices found to setup OpBox.\nPlease make sure NI-DAQmx drivers are installed and NI DAQ devices are connected.\n');
    s_in = [];
    return;
end

s_in = daq.createSession('ni'); % Create a session for National Instruments devices

% Set standard session parameters:
s_in.Rate = Fs;
s_in.IsContinuous = true;
s_in.NotifyWhenDataAvailableExceeds = s_in.Rate / 10; % Updates based on loops/sec, up to 20 Hz. 10 = 10 Hz = 100ms

num_pci_sync = 0; % If find 2 PCI devices, then will try to sync via hardware connection later

% initialize all channels from all devices
for i_dev = 1:numel(nidevs)
    name_dev = get(nidevs(i_dev), 'ID');
    dev_model = get(nidevs(i_dev), 'Model'); % have to know which channels are differential, can not easily figure out posthoc reliably for each device
    % subsys = get(nidevs(i_dev), 'Subsystems');
    digital_chans = ''; % Specified as text
    counter_chans = []; % Specified as num/doubles, like analog chans
    switch (dev_model)
        case 'PCIe-6323'
            analog_chans = [0:7, 16:23];
            digital_chans = '0:31';
            num_pci_sync = num_pci_sync + 1;
            volt_range = 1;
        case 'PCI-6225'
            analog_chans = [0:7, 16:23, 32:39, 48:55, 64:71];
            digital_chans = '0:7';
            num_pci_sync = num_pci_sync + 1;
            volt_range = 1;
        case 'USB-6001'
            max_fs = 20e3;  % http://www.ni.com/pdf/manuals/371303n.pdf
            max_chans = 4;  % if bipolar/referential
            num_chans = min(floor(max_fs / Fs), max_chans);
            if num_chans < max_chans
                fprintf('NI %s can only sample up to %d channels with sampling rate of %d\n(Max rate of %d total, across max of %d chans)\n', dev_model, num_chans, Fs, max_fs, max_chans);
            end
            analog_chans = 0:num_chans-1;
            % digital_chans = '';  % Digital channels are software clocked rather than hardware, so can not be streamed along with analog data
            volt_range = 10;
        case 'USB-6009'
            max_fs = 48e3;  % http://www.ni.com/pdf/manuals/371303n.pdf
            max_chans = 4;  % if bipolar/referential
            num_chans = min(floor(max_fs / Fs), max_chans);
            if num_chans < max_chans
                fprintf('NI %s can only sample up to %d channels with sampling rate of %d\n(Max rate of %d total, across max of %d chans)\n', dev_model, num_chans, Fs, max_fs, max_chans);
            end
            analog_chans = 0:num_chans-1;
            % digital_chans = '';  % Digital channels are software clocked rather than hardware, so can not be streamed along with analog data
            volt_range = 1;
        case 'USB-6210'
            max_fs = 250e3;  % http://www.ni.com/pdf/manuals/371303n.pdf
            max_chans = 8;  % if bipolar/referential
            num_chans = min(floor(max_fs / Fs), max_chans);
            if num_chans < max_chans
                fprintf('NI %s can only sample up to %d channels with sampling rate of %d\n(Max rate of %d total, across max of %d chans)\n', dev_model, num_chans, Fs, max_fs, max_chans);
            end
            analog_chans = 0:num_chans-1;
            % digital_chans = '';  % Digital channels are software clocked rather than hardware, so can not be streamed along with analog data
            counter_chans = [0 1]; % 2 counter channels for rotary encoders. 32 Bit counters. http://www.ni.com/pdf/manuals/375195d.pdf
            volt_range = 5; % Supports 1V but also using for 0-5V analog input in OpBox shield multiplexed trigger inputs
        case 'USB-6211'
            max_fs = 250e3;  % http://www.ni.com/pdf/manuals/371303n.pdf
            max_chans = 8;  % if bipolar/referential
            num_chans = min(floor(max_fs / Fs), max_chans);
            if num_chans < max_chans
                fprintf('NI %s can only sample up to %d channels with sampling rate of %d\n(Max rate of %d total, across max of %d chans)\n', dev_model, num_chans, Fs, max_fs, max_chans);
            end
            analog_chans = 0:num_chans-1;
            % digital_chans = '';  % Digital channels are software clocked rather than hardware, so can not be streamed along with analog data
            counter_chans = [0 1]; % 2 counter channels for rotary encoders. 32 Bit counters. http://www.ni.com/pdf/manuals/375195d.pdf
            volt_range = 5; % Supports 1V but also using for 0-5V analog input in OpBox shield multiplexed trigger inputs
        otherwise
            fprintf('Device model %s not recognized.\n', dev_model);
            continue;
    end
    fprintf('%s %s recognized.\n', name_dev, dev_model);
    % Add analog channels to session
    s_in.addAnalogInputChannel(name_dev, analog_chans, 'Voltage'); 
    % Add digital channels to session
    if ~isempty(digital_chans)
        s_in.addDigitalChannel(name_dev, sprintf('Port0/Line%s', digital_chans), 'InputOnly'); % Much faster than 1 at a time
    end
    % Add counter channels to session
    if ~isempty(counter_chans)
        s_in.addCounterInputChannel(name_dev, counter_chans, 'Position'); % https://www.mathworks.com/help/daq/ref/addcounterinputchannel.html
    end
end


%% Synchronize devices if applicable:
% If 2 PCI/e cards are being used, then need to synchronize their clocks 
% (must be connected with a 34 pin ribbon (RTSI) cable inside the computer)
% This is especially important if the channels from 1 subject 
% (e.g. analog vs. digital) are split between devices)
% http://www.mathworks.com/help/daq/examples/synchronize-ni-pci-devices-using-rtsi.html
% Note: Must be done after adding connections
% Note: Error from Matlab: "Warning: The PCI-6225 'Dev2' does not support external triggers for the DigitalIO subsystem". 
% However, still seems to work as long as have an analog channel in use too
% Note: USB clocks can not be synchronized in this way
if num_pci_sync == 2
    addTriggerConnection(s_in,'Dev1/RTSI0','Dev2/RTSI0','StartTrigger'); 
    addClockConnection(s_in,'Dev1/RTSI1','Dev2/RTSI1','ScanClock');
    % s_in.Connections % shows connections
    fprintf('Synchronized PCI/e device clocks.\n');
end

%% Set channel parameters: Voltage Range & Input Type for analog channels
chans = get(s_in, 'Channels');
chan_analog = strncmp('ai', {chans.ID}, 2);

% Volt ranges:
% PCI-6255  : ±10 V, ±5 V, ±2 V, ±1 V, ±0.5 V, ±0.2 V, ±0.1 V: http://www.ni.com/datasheet/pdf/en/ds-22
% PCIe-6323 : ±10 V, ±5 V, ±1 V, ±0.2 V: http://www.ni.com/pdf/manuals/370785d.pdf
% USB-6210/1: ±10 V, ±5 V, ±1 V, ±0.2 V: http://www.ni.com/datasheet/pdf/en/ds-9
% USB-6009  : ±20 V, ±10 V, ±5 V, ±4 V, ±2.5 V, ±2 V, ±1.25 V, ±1 V. http://techteach.no/tekdok/usb6009/. http://www.tau.ac.il/~electro/pdf_files/computer/ni_6008_ADC_manual.pdf. ONLY TRUE FOR DIFFERENTIAL RECORDINGS
% USB-6001  : ±10 V, ONLY SUPPORTED AS OF MATLAB 2014B: http://www.mathworks.com/matlabcentral/answers/146228-is-it-possible-to-use-an-unsupported-daq-board
volt_range = [0-volt_range, volt_range];
set(chans(chan_analog), 'Range', volt_range); % Set default volt range for all analog inputs, modify below. This way sets at least once for all channels, even hidden (i.e. jumpers)
set(chans(chan_analog), 'InputType', 'Differential'); % Set all analog inputs as differential

% % Default Axis/Zoom: Can't add to struct s_in since no public such property
% s_in.axis_x_default = [0 5];
% s_in.axis_y_default = [-0.5 0.5];

%% Set channel parameters: Encoder resolution for counter/rotary encoder channels
chan_counter = strncmp('ctr', {chans.ID}, 3);
set(chans(chan_counter), 'EncoderType', 'X4'); % Default X1, res = X1 < X2 < X4. % https://www.mathworks.com/help/daq/ref/encodertype.html

%% Finish
fprintf('Done setting up acquisition devices.\n');

%% Try to set up cameras
if ~exist('imaqhwinfo', 'file')
    fprintf('Image Acquisition Toolbox not found\n');
else
    adaptor_info = imaqhwinfo;
    fprintf('%d camera adaptor(s) found using imaqhwinfo from Image Acquisition Toolbox\n', numel(adaptor_info.InstalledAdaptors));
    wincam_info = imaqhwinfo('winvideo');
    fprintf('%d Windows camera device(s) found using imaqhwinfo from Image Acquisition Toolbox\n', numel(wincam_info.DeviceInfo));
end
