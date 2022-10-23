%======================================================================%
% Title:    Supplementary Material of "Development of an inkjet setup  %
%           for printing and monitoring microdroplets"                 %
% Author:   Beatriz Cavaleiro de Ferreira                              %
% Software: MATLAB R2017b                                              %
% Date:     22 Oct 2022                                                %
%======================================================================%

function [IPrep]=ImagePreprocessing(I,t, crop)
    Ig    = im2double(rgb2gray(I));
    It    = imwarp(Ig,t);
	IPrep = imcrop(It,crop);
end
