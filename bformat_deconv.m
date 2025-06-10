% Processing of impulses responses from the B-format converted AMBEO mic

% 1. Load b-format file and inverse filter
% 2. Perform deconvolution to get impulse response
% 3. Check processing results (visually)
% 4. Normalization
% 5. Export of WYZX 4-ch IRs file (and WY 2-ch file)


%% 0: CLEARING WORKSPACE & WINDOW

close all
clear



%% 1: LOADING FILES 

% Inverse sweep required for the deconvolution process
% inv_sweep = audioread('./Audio_Files/INV-ESS.wav');      
% filename = "./example-inputs/170325-T002.wav";

addpath( './Lib' )   
Fs              = 48e3;             % Sampling rate [Hz]
L               = 2;                % Length of each IR in the SIMO matrix [s]
N               = Fs*L;             % Samples of each IR in the SIMO matrix

%% Select audio file to be deconvolved
[rec_file_name,rec_file_location] = uigetfile( ...
                '*.wav','Select the ambix file to be deconvolved...',pwd);

if isfloat(rec_file_name)
    fprintf("No file has been selected.")
    return
end

acquired_file = fullfile(rec_file_location,rec_file_name);

[rec_sweep, Fs] = audioread(acquired_file);


%% Select inverse filter file 
[inv_filter_file_name,inv_filter_location] = uigetfile( ...
                '*.wav','Select the inverse filter file...',pwd);

if isfloat(inv_filter_file_name)
    fprintf("No file has been selected.")
    return
end

inv_filter_file = fullfile(inv_filter_location,inv_filter_file_name);

inv_sweep = audioread(inv_filter_file);


%% Process 

tic

[~,n_ch] = size(rec_sweep);
IR = zeros(N,n_ch);  

% Performs deconvolution for each Mic 
for m = 1:n_ch
    fprintf('Processing channel %d of %d\n',m,n_ch);

    % Deconvolution of each channel of the mic with the inverse sweep
    convRes = fd_conv( rec_sweep(:,m), inv_sweep );   % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab
    
    % Show the first trimmed IR in order to check the process
    if (m==1)
        TrimSample = trimIR(convRes,N,acquired_file);
    end

    % Distribute the multiple IRs into separate cells of SIMO matrix
    IR(:,m) = convRes(TrimSample:TrimSample+N-1);
end

toc

% Plot all channels to check the result
figure()
for i_ch = 1 : n_ch
    subplot(n_ch,1,i_ch)
    plot(IR(:,i_ch))
end


%% Normalization

factor = 0.9; % Normalization factor
max_value = max(max(abs(IR)));
scalar = factor/max_value;
IR = IR*scalar;
fprintf("Gain applied for rescaling: %.2f dB\n",20*log10(scalar))


%% Export Ambeo B-format IR

[~,file_name] = fileparts(rec_file_name);
out_file_name = file_name+"-WYZX-IR.wav";

out_location = uigetdir(rec_file_location,"Export file location");

if isfloat(out_location)
    fprintf("No output location has been selected.")
    return
end

out_WYZX_file = fullfile(out_location,out_file_name);
audiowrite(out_WYZX_file,IR,Fs,"BitsPerSample",32);

out_WY_file = fullfile(out_location,file_name+"-WY-IR.wav");
audiowrite(out_WY_file,IR(:,1:2),Fs,"BitsPerSample",32);

fprintf("Exported deconvolved WYZX file in %s\n",string(out_WYZX_file))
fprintf("Exported deconvolved WY file in %s\n",string(out_WY_file))