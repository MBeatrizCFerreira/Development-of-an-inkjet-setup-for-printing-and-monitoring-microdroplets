%======================================================================%
% Title:    Supplementary Material of "Development of an inkjet setup  %
%           for printing and monitoring microdroplets"                 %
% Author:   Beatriz Cavaleiro de Ferreira                              %
% Software: MATLAB R2017b                                              %
% Date:     22 Oct 2022                                                %
%======================================================================%

function [circen, cirrad, metric, empty, outFrame, weak]=...
    ImageAnalysis(I, rad, i, crop)
% https://www.mathworks.com/help/images/ref/imfindcircles.html

    % Identify the Region were the drop can land
    xlim1=round(crop(3)/4);
    xlim2=crop(3)-xlim1;
    ylim1=round(crop(4)/4);
    ylim2=crop(4)-ylim1;
    %Identify the radius range
    Rvar = 7;
    Rlim = [20 65];
    metriclim = 0.23;
    if rad<Rlim(1)+Rvar
        rad=Rlim(1)+Rvar;
    elseif rad>Rlim(2)-Rvar
        rad=Rlim(2)-Rvar;
    end
    Rrange=[round(rad-Rvar) round(rad+Rvar)];
    
    % Circular Hough Transform
    [circen,cirrad,metric] = imfindcircles(I,Rrange,'ObjectPolarity','bright','Sensitivity',1,'EdgeThreshold',0);
    empty=nan;
    outFrame=nan;
    weak=nan;
    if isempty(cirrad)
        cirrad=0;
        circen=[0 0];
        metric=0;
        empty=0;
    end
    if circen(1,1)<xlim1|circen(1,1)>xlim2|circen(1,2)<ylim1|circen(1,2)>ylim2
        cirrad=0;
        circen=[0 0];
        metric=0;
        outFrame=0;
    end
    if metric(1)<metriclim
        cirrad=0;
        circen=[0 0];
        metric=0;
        weak=0;
    end
    
    circen=circen(1,:);
    cirrad=cirrad(1);
    metric=metric(1);
    imshow(I);
    title(['Frame ', num2str(i)]);
    viscircles(circen,cirrad,'EnhanceVisibility',0,'LineWidth',0.4);
    drawnow
end