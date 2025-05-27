function [filename,outnames,suffix] = directories(DirName,filesinfo,j,InvFilt)

    % Indicates whether the files are filtered or not
    if InvFilt == 1
        suffix="Filtered";   % Sets sufix to "acoupar.txt" file
    else
        suffix="Raw";        % Sets sufix to "acoupar.txt" file
    end

    % Creation, if necessary, of the output subfolder within the path defined previously
    outDir = strcat(filesinfo(j).folder, '/Output');    % Adding 'output' to the file path
    outDirIR = strcat(filesinfo(j).folder, '/Output/IR');    % Adding 'IR' to the file path. It is not affected by the filter.
    outDir3A = strcat(filesinfo(j).folder, '/Output/W_3AMBI_',suffix);    % Adding 'W_3AMBI' to the file path
    outDir1A = strcat(filesinfo(j).folder, '/Output/W_1AMBI_',suffix);    % Adding 'W_1AMBI' to the file path
    outDirWY = strcat(filesinfo(j).folder, '/Output/W_WY_',suffix);    % Adding 'W_WY' to the file path
    outDirW = strcat(filesinfo(j).folder, '/Output/W_W_',suffix);    % Adding 'W_W' to the file pathOutDirW
    
    % Creation of "Output" folder
    if  ~exist(outDir, 'dir') % If the output folder does not exist...
        mkdir(outDir)         % then it gets created.
        fprintf('Created folder: %s\n', outDir);
    end
    
    if ~exist(outDirIR, 'dir') % If the output folder does not exist...
        mkdir(outDirIR)         % then it gets created.
        fprintf('Created folder: %s\n', outDirIR);
    end

    if ~exist(outDir3A, 'dir') % If the output folder does not exist...
        mkdir(outDir3A)         % then it gets created.
        fprintf('Created folder: %s\n', outDir3A);
    end
    
    if ~exist(outDir1A, 'dir') % If the output folder does not exist...
        mkdir(outDir1A)         % then it gets created.
        fprintf('Created folder: %s\n', outDir1A);
    end

    if ~exist(outDirWY, 'dir') % If the output folder does not exist...
        mkdir(outDirWY)         % then it gets created.
        fprintf('Created folder: %s\n', outDirWY);
    end

    if ~exist(outDirW, 'dir') % If the output folder does not exist...
        mkdir(outDirW)         % then it gets created.
        fprintf('Created folder: %s\n', outDirW);
    end

    % Gets file name
    filename = fullfile(filesinfo(j).folder, filesinfo(j).name);
    disp("File name = " + filename);
    
    % Gets file path
    [filepath,name,ext] = fileparts(filename);
    disp("File path = " + filepath);
    
    % Gets file extension
    [~, FolderName] = fileparts(DirName);
    outnames(1)=strcat(filepath, "/output/IR/", name,"_IR.wav"); % It is not affected by the filter
    outnames(2)=strcat(filepath, "/output/W_3AMBI_",suffix,"/", name,"_W_3AMBI_",suffix,".wav");
    outnames(3)=strcat(filepath, "/output/W_1AMBI_",suffix,"/", name,"_W_1AMBI_",suffix,".wav");
    outnames(4)=strcat(filepath, "/output/W_WY_",suffix,"/", name,"_W_WY_",suffix,".wav");
    outnames(5)=strcat(filepath, "/output/W_W_",suffix,"/", name,"_W_W_",suffix,".wav");
    outnames(6)=outDir; % Main "Output" folder to save up the "acoupar.txt" file

    fprintf("Extension = %s\n", ext)
    
    % Starts progress bar in order to supervise the process
    progressbar('Files', 'Microphones', 'Beamforming', 'Background Noise');

end