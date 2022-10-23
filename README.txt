This repository contains all the programs used in the paper "Development of an inkjet setup for printing and monitoring microdroplets", doi [to be updated].

In particular:

Arduino DUE:
These programs were used to generate the wave to actuate the piezoelectric printhead.
-WaveGenerationIndependent: Arduino Due program used to generate the data presented in the paper. This program changes the amplitude of the applied pulse autonomously, without input from the user.
-WaveGenerationSerial: this program allows the user to update the wave parameters amplitude (V_HIGH), dwell time (P_WIDTH) and period (sample) via serial port during operation.

MATLAB:
-MainSavedFrames.m: program used to analyse the recorded droplets obtained from running "WaveGenerationIndependent". The video from which the droplets' frames were extracted is "210506_21_26_04.mp4". The already extracted frames after removing the background are saved in "ToProcessDropsSF.mat".
Input data:
.ToProcessDropsSF.mat
.Distortion.mat
Output data:
.ResultsSF.mat
.ProcessedDropsSF.mat
Functions:
.ImagePreprocessing.m
.ImageProcessing.m
.ImageAnalysis.m

-MainCamera.m: program to process and analyse the deposited droplets using the installed USB camera during operation. It requires that either the timer "tm" or the manual trigger of "vid" is synchronized with the droplets deposition.
Input data:
.Distortion.mat
.videoObjt used to identify the used camera
Output data:
.ResultsC.mat
.ProcessedDropsC.mat
.AcquiredDropsC.mat
Functions:
.ImagePreprocessing.m
.ImageProcessing.m
.ImageAnalysis.m

-ImagePreprocessing.m: function used for preprocessing the acquired frames.
-ImageProcessing.m: function used to process the preprocessed frames.
-ImageAnalysis.m: function to search and characterize the droplets.
Output:
.circen: center of the most likely circle found
.cirrad: radius of the most likely circle found
.metric: measure of confidence in the most likely circle found
.empty: 0 if no circle was found
.outFrame: 0 if the most likely circle is outside the area of landing
.weak: 0 if the metric of the most likely circle found is too low

NOTE: All ".mat" files are available upon request.

GCode:
-Trajectory: GCode commands used to define the printhead trajectory during printing.

Marlin:
Used files to configurate the Witbox firmware.
-Configuration.h
-Configuration_adv.h

uStepper:
-Ytest_uStepper: used program to configure the uSteppers installed in the X and Y stepper motors of the used Witbox 3D printer.



