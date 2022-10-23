%======================================================================%
% Title:    Supplementary Material of "Development of an inkjet setup  %
%           for printing and monitoring microdroplets"                 %
% Author:   Beatriz Cavaleiro de Ferreira                              %
% Software: MATLAB R2017b                                              %
% Date:     22 Oct 2022                                                %
%======================================================================%

function [IProc]=ImageProcessing(I)
%https://www.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html

    % Processing to enhance the drop border
    Ibright = I*10; 
    IProc = imgaussfilt(Ibright,3);    
end