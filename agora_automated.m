% Processing of impulses responses recorded on the Zoom F8
% We have a 
% 1. Convolve with inverse sweep, get impulse response
% 2. Get omni signal, by converting A-format to B-format
% 3. Calculate acoustical parameters

%% 0: CLEARING WORKSPACE & WINDOWS AND START TIMER
clear all; close all;
tic

%% 1: LOADING RELEVANT FILES 
InvSweep = audioread('./Audio_Files/INV-ESS.wav');      % Inverse sweep required for the deconvolution process
%MicArrayEnc = audioread('./Audio_files/EM64-to-Ambix-5th-order-Eigenstudio-Standard.wav');       % Characterization of the microphone (Beamforming matrix)
MicArrayEnc = audioread('./Audio_files/Ambeo-Ambix.wav');
filename = "./example-inputs/170325-T002-trim.wav";


addpath( './Lib' )   
Fs              = 48e3;             % Sampling rate [Hz]
L               = 2;              % Length of each IR in the SIMO matrix [s]
N               = Fs*L;             % Samples of each IR in the SIMO matrix

[RecSweep, Fs] = audioread(filename);

Mic = 7;
IR = zeros(1,Mic,N);  

% Performs deconvolution for each Mic 
for m = 1:Mic
    fprintf('Mic: (%d/%d)\n',m,Mic);

    % Deconvolution of each channel of the mic with the inverse sweep
    convRes = fd_conv( RecSweep(:,m), InvSweep );   % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab
    
    % Show the first trimmed IR in order to check the process
    if (m==1)
        TrimSample = trimIR(convRes,N,filename);
    end

    % Distribute the multiple IRs into separate cells of SIMO matrix
    IR(1,m,:) = convRes(TrimSample:TrimSample+N-1);
end 

% trim
% IR = convRes(TrimSample:TrimSample+N-1);

    

%% NORMALIZE
% Normalization factor
factor=0.9;
mx=max(max(abs(IR)));
scalar=factor/mx;
IR=IR*scalar;

% Export all 7 channels
IR=squeeze(IR);
TotalOutname = filename+"IR.wav";
audiowrite(TotalOutname,IR',Fs,"BitsPerSample",32); % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab

% Export binaural IR (ch5-6)
BinauralOutname = filename+"-binaural-IR.wav";
rowIR = IR';
selectedIR = rowIR(:,5:6);
audiowrite(BinauralOutname,selectedIR,Fs,"BitsPerSample",32); 

% Export Behringer omni (ch7)
OmniOutname = filename+"-omni-IR.wav";
selectedIR = rowIR(:,7);
audiowrite(OmniOutname,selectedIR,Fs,"BitsPerSample",32); 

% Ambeo A-format to B-format
AmbixIR = IR(:,1:4);
AmbixIR = squeeze(AmbixIR);
fprintf("AmbixIR size = ");
size(AmbixIR)
%size(MicArrayEnc')
MicArrayEnc = MicArrayEnc';
%size(MicArrayEnc)
AmbixIR = matrix_conv(AmbixIR, MicArrayEnc);

% Export Ambeo B-format IR
outname = filename+"-Ambix-IR.wav";
selectedIR = AmbixIR';
audiowrite(outname,selectedIR,Fs,"BitsPerSample",32);

%% Application of Acoupar tool. Further information of this executable at https://www.angelofarina.it/Public/AcouPar/

% Omni Acoustical Parameters
command = "AcouPar_omni_x64.exe " + sprintf('"%s"',OmniOutname);
fprintf("%s\n", command);
[status, results] = system(command);
fprintf("%s\n", results);

% Binaural Acoustical Parameters
command = "AcouPar_bin_x64.exe " + sprintf('"%s"',OmniOutname);
fprintf("%s\n", command);
[status, results] = system(command);
fprintf("%s\n", results);

% Pressure-Velocity Acoustical Parameters, using the W and Y channels of
% Ambix
% command = "AcouPar_omni_x64.exe " + sprintf('"%s"',OmniOutname);
%fprintf("%s\n", command);
%[status, results] = system(command);
%fprintf("%s\n", results);

toc