% Processing of impulses responses
% 1. Get omni signal, by converting A-format to B-format
% 2. Convolve with inverse sweep, get impulse response
% 3. Calculate acoustical parameters

%% 0: CLEARING WORKSPACE & WINDOWS AND START TIMER
clear all; close all;
tic

% 1. Get omni signal
% If 1 channel, already omni
% If there are 4 channels, Ambeo
% If there are 19 channels, Zylia
% If there are 64 channels, Eigenmike 64

%% 1.1: LOADING RELEVANT FILES 
InvSweep = audioread('./Audio_Files/INV-ESS.wav');      % Inverse sweep required for the deconvolution process
MicArrayEnc = audioread('./Audio_files/EM64-to-Ambix-5th-order-Eigenstudio-Standard.wav');       % Characterization of the microphone (Beamforming matrix)

filename = "./example-inputs/290425-T001.WAV";

addpath( './Lib' )   
Fs              = 48e3;             % Sampling rate [Hz]
L               = 2;              % Length of each IR in the SIMO matrix [s]
N               = Fs*L;             % Samples of each IR in the SIMO matrix
%ambisonicsOrder = 3;                % Ideally should be read from the microphone convolution matrix
%outputChannels = (ambisonicsOrder + 1)^2;
[RecSweep, Fs] = audioread(filename);

% Assume we only have 1 channel
Mic = 1;
%outputChannels = 1;

IR = zeros(1,Mic,N);  
%hMic=beam(Mic,outputChannels,4096,MicArrayEnc);  % Beamforming matrix for the Zylia microphone [RMic x VMic x N]


% Performs deconvolution for each Mic 
%convRes = fd_conv(RecSweep(:,1), InvSweep);
for m = 1:Mic
    fprintf('Mic: (%d/%d)\n',m,Mic);

    % Deconvolution of each channel of the mic with the inverse sweep
    convRes = fd_conv( RecSweep(:,m), InvSweep );   % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab
    
    % Show the first trimmed IR in order to check the process
    if (m==1)
        TrimSample = trimIR(convRes,N,filename);
    end
end 

% trim
IR = convRes(TrimSample:TrimSample+N-1);

    

%% 9: NORMALIZE & EXPORT OF OUTPUTS
    % Normalization factor
    factor=0.9;

% Impulse respones (IRs) Normalization
mx=max(max(abs(IR)));
mx
scalar=factor/mx;
IR=IR'*scalar;

% Export
outname = filename+"IR.wav"
audiowrite(outname,IR,Fs,"BitsPerSample",32); % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab

% Application of Acoupar tool. Further information of this executable at https://www.angelofarina.it/Public/AcouPar/

% Windows Version
command = "./AcouPar_omni_x64.exe " + sprintf('"%s"',outname);

% Mac or Linux Version
% setenv('PATH', [getenv('PATH') ':/opt/homebrew/bin/wine/']);
% command = "wine AcouPar_omni_x64.exe " + sprintf('"%s"',outname);


fprintf("%s\n", command);
[status, results] = system(command);
fprintf("%s\n", results);