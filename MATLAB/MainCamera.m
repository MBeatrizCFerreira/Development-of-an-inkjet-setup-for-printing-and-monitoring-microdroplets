%======================================================================%
% Title:    Supplementary Material of "Development of an inkjet setup  %
%           for printing and monitoring microdroplets"                 %
% Author:   Beatriz Cavaleiro de Ferreira                              %
% Software: MATLAB R2017b                                              %
% Date:     22 Oct 2022                                                %
%======================================================================%

ar = instrfind();
if ~isempty(ar)
    fclose(ar);
end
clear all , clc, close all

global Results
global IAcquired
global IProcessed
global rad
global j
global vid
global t
global umpixel

load('Distortion','t', 'umpixel')
time = 60;
period = 1;
j=0;
rad=50;

%% Inicializar câmara
objects = imaqfind;         %find video input objects in memory
delete(objects)
imaqreset; 

vid = videoinput('winvideo', 2, 'YUY2_640x480');
%vid = videoinput('winvideo',1, 'MJPG_1280x720');
src = getselectedsource(vid);
set(vid, 'FramesPerTrigger', 3);
set(vid, 'TriggerRepeat', Inf);
set(vid, 'ReturnedColorspace', 'rgb');
%vid.ROIPosition = [xmin ymin width height];
frameRates = set(src, 'FrameRate')
src.FrameRate = frameRates{1};
triggerconfig(vid, 'manual');

%% Definir timer
tm = timer('TimerFcn',@ImageAquisition,'StopFcn',@StopAquisition,...
    'Period',period, 'ExecutionMode', 'fixedRate','TasksToExecute', time/period);

start(vid);
%tst=datetime(2022,10,22,13,45,0)
%startat(t,tst);
start(tm);

%% Aquisição de imagem
function ImageAquisition(tm, event) %global vid, t, IProc, IAqui, Results, j, rad
    global Results
    global IAcquired
    global IProcessed
    global rad
    global j
    global vid
    global t
    global umpixel
    crop = [370 640 200 185];
    
    tic;
    j=j+1;
    trigger(vid);
    [I, time, metadata] = getdata(vid);
    flushdata(vid);
    IAcquired{j}=I(:,:,:,3);
    Idiff = I(:,:,:,1)-I(:,:,:,3);
    [IPrep]=ImagePreprocessing(Idiff,t,crop);
    [IProc]=ImageProcessing(IPrep);
    [Results.circen(j,:),Results.cirrad(j),Results.metric(j),...
        empty(j), outFrame(j), weak(j)]=ImageAnalysis(IProc, rad, j, crop);
    if Results.cirrad(j)>0
        rad=Results.cirrad(j);
    end
    Results.cirrad(j)=Results.cirrad(j)*umpixel;
    IProcessed{j} = IProc;
    toc
end
%% Parar vídeo
function StopAquisition(tm,event)
    global Results
    global IAcquired
    global IProcessed
    global rad
    global j
    global vid
    global t
    global umpixel
    
    delete(tm);
    stop(vid);
    clear('t','umpixel')
    save('ResultsC.mat','Results', 'j', '-v7.3')
    save('ProcessedDropsC.mat','IProcessed', 'j', '-v7.3')
    save('AcquiredDropsC.mat','IAcquired', 'j', '-v7.3')
end