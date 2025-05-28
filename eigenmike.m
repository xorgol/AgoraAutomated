%-------------------------------------------------------------------------%
%------------------------------ SIMO SCRIPT ------------------------------%
%-------------------------------------------------------------------------%
% DOI Artsoundscapes Project:                              10.3030/787842 %
% Creation date:                                            December 2020 %
% Last update:                                              December 2023 %
%
% Description:          Adaptation of the MIMO script developed by Adriano
%                       Farina (xorgol@gmail.com), available at 
%                       https://github.com/xorgol/MIMO_Matlab. 
%
%                       This version of the code has been adapted by Daniel
%                       Benítez (danielbenitez@ub.edu) and reviewed by
%                       Lidia Álvarez (lidiaalvarez@ub.edu). Matlab version
%                       R2022a.
%
%                       This script allows to select a directory where
%                       recordings performed by the Zylia ZM-1 3rd-order
%                       Ambisonics microphone are located (with ".w64"
%                       extension).
%
%                       These recordings must cointain a single sine sweep
%                       reproduced by the IAG DD4 dodecahedron loudspeaker,
%                       or similar.
%
%                       An "Output" folder is created at the selected
%                       directory, where all the exports shall be stored.
%
%                       The script applies a process based on deconvolution
%                       that allows to obtain the Impulse Responses (IR) of
%                       each channel of the microphone, and store them in a
%                       ".wav" file.
%
%                       It also produces 1st and 3rd-order Ambisonics
%                       ".wav" files in B-Format, following the Ambix
%                       channel ordering (W-Y-Z-X), as well as a two track
%                       ".wav" file containing the W and Y channels. All
%                       these files are normalized, preserving the balance
%                       among channels, and trimmed to 1 second.
%
%                       Finally, it applies the AcouPar tool (by Angelo
%                       Farina), which generates a ".txt" file with the
%                       main acoustic parameters listed in the ISO3382-1.
%
%                       This script has been designed in Matlab R2022a and 
%                       it requires the Audio Toolbox to work.
%                        
% Variables:            InvSweep    Inverse sweep required for the 
%                                   deconvolution process.
%
%                       L           Length of IRs in the SIMO matrix [s].
%
%                       Filter      Sound source's inverse filter (".wav")
%                                   that shall be applied.
%
%                       factor      Normalization factor.
%
%-------------------------------------------------------------------------%

%% 1: CLEARING WORKSPACE & WINDOWS AND START TIMER
clear all; close all;
tic

%% 2: LOADING RELEVANT FILES 
% todo: rename Zylia variables to more generic Ambisonics microphone array
% nomenclature
InvSweep = audioread('./Audio_files/INV-ESS.wav');      % Inverse sweep required for the deconvolution process
ZyliaEnc = audioread('./Audio_files/EM64-to-Ambix-5th-order-Eigenstudio-Standard.wav');       % Characterization of the microphone (Beamforming matrix)
addpath( './Lib' )                                                  % Add to path the folder 'Lib' with required functions

%% 3: DEFINITION OF PARAMETERS & VARIABLES
Mic             = 64;               % Number of microphones employed (Zylia = 19 mics)
Swp             = 1;                % Number of sweeps employed (IAG DD4 dodecahedron = 1 sweep)

ambisonicsOrder = 3;                % Ideally should be read from the microphone convolution matrix
outputChannels = (ambisonicsOrder + 1)^2;

Fs              = 48e3;             % Sampling rate [Hz]

L               = 0.5;              % Length of each IR in the SIMO matrix [s]
N               = Fs*L;             % Samples of each IR in the SIMO matrix

SIMOIR = zeros(Swp,Mic,N);          % SIMO IR matrix [Sweeps x Microphones x N_Samples]

hZylia=beam(Mic,outputChannels,4096,ZyliaEnc);  % Beamforming matrix for the Zylia microphone [RMic x VMic x N]

problematicFiles = "";              % Store the paths of files which produce an error

check="NaN";                        % Checks when a new sub-directory is analyzed

%% 4: CHOOSING DIRECTORY
disp('Loading Sweep recording and IR deconvolution...')

% Selection of the folder containing the signals that need to be analyzed
selpath = uigetdir;         
DirName = selpath;          

% Build full file name from parts with 'fullfile' and creates a list of all '.w64' files that need to be analyzed
filesinfo = dir(fullfile(DirName, '**/*.w64')); 

% Get rid of all directories including "." and ".."
filesinfo([filesinfo.isdir]) = [];              

% Number of files that need to be analyzed
nfiles = length(filesinfo);      

%% 5: APPLICATION OF INVERSE FILTER
% for InvFilt=0:1
%     delete acoupar_pu.txt                                       % Reset ".txt" with acoustic parameters in each iteration
% 
%     if InvFilt == 0
%         Filter=1;                                               % No inverse filter (array with just a one).
%         lap="\n\n1st Round: Not applying inverse filter.\n"; 
%     else
%         %Filter=audioread('Audio files/DD4-Invfilt-ret.wav')';   % Inverse filter of the DD4 sound source.
%         Filter=audioread('Audio files/SPS12ToDodecMIMO.wav')';
%         lap="\n\n2º Round: Applying inverse filter.\n"; 
%     end
Filter = 1;
hSpk=ones(1,1,length(Filter));                                  % Three-dimensional array (for future deconvolution processes) to store the inverse filter 
hSpk(1,1,:)=Filter;                                             % The inverse filter's length is set as long as the IRs    

%% 6: IR DECONVOLUTION
for j = 1 : nfiles  % Iterates through all files in the target folder
    %fprintf(lap); 
    fprintf("Processing file %d out of %d\n\n", j, nfiles);

    InvFilt=0;
    % Loads files (sweep recordings) and creates output folder for the resulting files
    [filename,outnames,suffix] = directories_v3(DirName,filesinfo,j,InvFilt);

    % Checks when a new sub-directory is analyzed
    if j>1                                                                  % The very first file of the directory is not taken into account to avoid errors              
        if check ~= outnames(5)
            copyfile('acoupar_pu.txt',sprintf('acoupar_pu_%s.txt',suffix))  % Creates a new ".txt" considering whether the inverse filter has been applied or not
            movefile(sprintf('acoupar_pu_%s.txt',suffix),check)             % Moves this new ".txt" to its corresponding directory
            delete acoupar_pu.txt
        end
    end

    % Reads the current file which contains recorded sweeps
    [RecSweep,Fs] = audioread(filename);

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
        SIMOIR(Swp,m,:) = convRes(TrimSample:TrimSample+N-1);

        % Progress bar to supervise the process
        progressbar(j/nfiles, m/Mic, [], []);           % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab
                
    end

    %% 7: AMBISONIC 1°order x 3°order beamformer
    disp('Ambisonic 1°x3° order beamforming...')

    % Perform beamforming of source and microphone on the SIMOIR 
    AMBI3IR = oa_matrix_convconv(hSpk,SIMOIR,hZylia); % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab

    %% 8: TRIMMING FILES
    % Trimming & squeezing Ambisonics files
    AMBI3IR=squeeze(AMBI3IR);
    [~, maxIndex] =  max(AMBI3IR(1,:));
    TrimSample = maxIndex-0.1*N;
    AMBI3IR=AMBI3IR(:,TrimSample:TrimSample+N-1);

    SIMOIR=squeeze(SIMOIR);
    
    %% 9: NORMALIZE & EXPORT OF OUTPUTS
    % Normalization factor
    factor=0.9;

    % Impulse respones (IRs)
    % Normalization
    mx=max(max(abs(SIMOIR)));
    scalar=factor/mx;
    SIMOIR=SIMOIR'*scalar;

    % Export
    audiowrite(outnames(1),SIMOIR,Fs,"BitsPerSample",32); % Further information of this sub-routine at https://github.com/xorgol/MIMO_Matlab

    % 3rd order ambisonics to omnidirectional source filter matrix to WAV file
    % Normalization
    mx=max(max(abs(AMBI3IR)));
    scalar=factor/mx;
    AMBI3IR=AMBI3IR'*scalar;

    % Export
    audiowrite(outnames(2),AMBI3IR,Fs,"BitsPerSample",32);

    % 1st order ambisonics to omnidirectional source filter matrix to WAV file
    % Normalization
    mx=max(max(abs(AMBI3IR(:,1:4))));
    scalar=factor/mx;
    AMBI3IR(:,1:4)=AMBI3IR(:,1:4)*scalar;

    % Export
    audiowrite(outnames(3),AMBI3IR(:,1:4),Fs,"BitsPerSample",32);

    % W and Y mic channels with omnidirectional source to WAV file
    % Normalization
    mx=max(max(abs(AMBI3IR(:,1:2))));
    scalar=factor/mx;
    AMBI3IR(:,1:2)=AMBI3IR(:,1:2)*scalar;

    % Export
    audiowrite(outnames(4),AMBI3IR(:,1:2),Fs,"BitsPerSample",32);

    % W mic channel with omnidirectional source to WAV file
    % Normalization
    mx=max(max(abs(AMBI3IR(:,1))));
    scalar=factor/mx;
    AMBI3IR(:,1)=AMBI3IR(:,1)*scalar;
    
    % Export
    audiowrite(outnames(5),AMBI3IR(:,1),Fs,"BitsPerSample",32);
 
    % Application of Acoupar tool. Further information of this executable at https://www.angelofarina.it/Public/AcouPar/
    command = "AcouPar_pu_x64.exe " + sprintf('"%s"',outnames(4));
    fprintf("%s\n", command);
    [status, results] = system(command);

    check=outnames(6);

    %clear RecSweep convRes convResTrim AMBI3IR SIMOIR % Variables are cleared for the next iteration

    close all
end
%         copyfile('acoupar_pu.txt',sprintf('acoupar_pu_%s.txt',suffix))  % Creates a new ".txt" considering whether the inverse filter has been applied or not
%         movefile(sprintf('acoupar_pu_%s.txt',suffix),check)             % Moves this new ".txt" to its corresponding directory
% end

%% 10: FINAL STEPS
fprintf("\n\nDone, processed %d files\n", nfiles);

disp("These files had problems!\n\n");
disp(problematicFiles); 

close all

toc