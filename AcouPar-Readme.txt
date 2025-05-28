AcouPar is a Command Line Utility for computing acoustical parameters according to ISO3382-1
It produces exactly the same results as the Aurora plugin named ISO3382 Acoustical Parameters
Of course the latest version of this plugin, version 4.5c Alpha, which can be downloaded here:
http://www.angelofarina.it/aurora/download/Aurora45-Alpha/ - the file is named acoustics45.xfm


We provide 3 versions of AcouPar, each for a different type of stereo impulse response:
AcouPar_omni.exe for a single or two independent omnidirectional microphones
AcouPar_pu.exe for omni-figure of 8 (pressure-velocity) WY-Ambix impulse responses (NOT for old FuMa WY)
AcouPar_BIN.exe for binaural impulse responses

The executables are compiled also as x64 versions for faster usage on modern 64-bits versions of Windows

For using AcouPar_pu.exe you can type this command in a DOS prompt:
AcouPar_pu filename_WY.wav
In case the filename or its path contain spaces, it is necessary to bracket it with double scores:
AcouPar_pu "C:\Temp\folder with spaces\file name with spaces WY.wav"
Indeed, folder or file names containing spaces are highly deprecated and should be avoided entirely!

The output will be appended as a new row in the file named acoupar_pu.txt, in the current folder
where the executable is launched. Of course, with the other two versions of the program, you will
get output files named respectively AcouPar_omni.txt and AcouPar_BIN.txt
The acoupar_xx.txt files are tab-separated. Easy for Excel. But be aware that the decimal point is 
always used, despite the International settings of your machine. So Excel will import it correctly 
only if the machine is set for using English international parameters (decimal dot).

Please note that currently we are not supprting yet the two other possible formats for stereo
impulse responses: Soundfield WY (the old FuMa format) and p-p sound intensity probe.
These will possibly be added in the future.

(C) Angelo Farina, 15 November 2020