%======================================================================%
% Title:    Supplementary Material of "Development of an inkjet setup  %
%           for printing and monitoring microdroplets"                 %
% Author:   Beatriz Cavaleiro de Ferreira                              %
% Software: MATLAB R2017b                                              %
% Date:     22 Oct 2022                                                %
%======================================================================%

clear all , clc, close all
load('ToProcessDropsSF.mat')
%load('ToProcessDropsT.mat')
load('Distortion','t', 'umpixel')

tic;
rad=50;

for j=1:(length(IAcquiredDiff))
    [IPrep]=ImagePreprocessing(IAcquiredDiff{j},t,crop);
    [IProc]=ImageProcessing(IPrep);
    [Results.circen(j,:),Results.cirrad(j),Results.metric(j),...
        empty(j), outFrame(j), weak(j)]=ImageAnalysis(IProc, rad, j,crop);
    if Results.cirrad(j)>0
        rad=Results.cirrad(j);
    end
    Results.cirrad(j)=Results.cirrad(j)*umpixel;
    IProcessed{j} = IProc;
    toc
    tic;
end
    clear('IAcquiredDiff','t','umpixel')
    save('ResultsSF.mat','Results', 'j', '-v7.3')
    save('ProcessedDropsSF.mat','IProcessed', 'j', '-v7.3')
    %save('ResultsT.mat','Results', 'j', '-v7.3')
    %save('ProcessedDropsT.mat','IProcessed', 'j', '-v7.3')