%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code computes average histogram for individual colors
% 
% Input:
%   imageFolder --> Location of the cropped images of the buoy
% 
% Submitted by: Ashwin Goyal (UID - 115526297)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function varargout = segment1D(img)

    % Define the folder of cropped buoys
    imageFolder = '..\..\Images\TrainingSet\Frames\';
    
    % Read image names
    imgFiles = dir([imageFolder '*.jpg']);
    
    % Compute average color histogram for all images
    [greenHist,redHist,yellowHist] = averageHistogram('RGB');
    
    % Generate 1-D gaussian for green buoy
    [greenMean,greenSigma] = normfit(greenHist(:,2));
%     greenMean = mean(greenHist(:,2));
%     greenSigma = var(double(greenHist(:,2)));
    figure
    plot(0:255,normpdf(0:255,greenMean,greenSigma))
    title('1-D Gaussian to Detect Green Buoy')
    xlabel('Intensity')
    ylabel('Probability')
    saveas(gcf,'../../Output/Part0/G_gauss1D.jpg')
    
    % Generate 1-D gaussian for red buoy
    [redMean,redSigma] = normfit(redHist(:,1));
%     redMean = mean(redHist(:,1));
%     redSigma = var(double(redHist(:,1)));
    figure
    plot(0:255,normpdf(0:255,redMean,redSigma))
    title('1-D Gaussian to Detect Red Buoy')
    xlabel('Intensity')
    ylabel('Probability')
    saveas(gcf,'../../Output/Part0/R_gauss1D.jpg')
    
    % Generate 1-D gaussian for yellow buoy
    [yellowMean,yellowSigma] = normfit(mean(yellowHist(:,1:2),2));
%     yellowMean = mean(mean(yellowHist(:,1:2),2));
%     yellowSigma = var(mean(yellowHist(:,1:2),2));
    figure
    plot(0:255,normpdf(0:255,yellowMean,yellowSigma))
    title('1-D Gaussian to Detect Yellow Buoy')
    xlabel('Intensity')
    ylabel('Probability')
    saveas(gcf,'../../Output/Part0/Y_gauss1D.jpg')
    
    for num = 1:length(imgFiles)
    % Read the image
    I = imread([imageFolder imgFiles(num).name]);
    
    % Plot the image before making it a double
    figure
    imshow(I)
    hold on
    I = double(I);
    
    % Compute gaussian probabilities
    greenProb = zeros(size(I,1),size(I,2));
    redProb = zeros(size(I,1),size(I,2));
    yellowProb = zeros(size(I,1),size(I,2));
    for i = 1:size(I,1)
        for j = 1:size(I,2)
            greenProb(i,j) = gauss(I(i,j,2),greenMean,greenSigma);
            redProb(i,j) = gauss(I(i,j,1),redMean,redSigma);
            yellowProb(i,j) = gauss(mean(I(i,j,1:2)),yellowMean,yellowSigma);
        end
    end
    
    % Identify green buoy
    greenBuoy = greenProb > std2(greenProb);
    greenBuoy = bwareafilt(bwmorph(imfill(bwmorph(bwmorph(greenBuoy,'thicken',10),'close',5),'holes'),'thin',7),[475 625]);
    greenProperty = regionprops(greenBuoy);
    maxArea = 0;
    greenInd = [];
    for i = 1:length(greenProperty)
        if maxArea < greenProperty(i).Area
            if (all(greenProperty(i).Centroid > 35))&&(all(greenProperty(i).Centroid < flip(size(greenProb))-35))
                maxArea = greenProperty(i).Area;
                greenInd = i;
            end
        end
    end
    
    % Plot green buoy as there are no disparities
    if ~isempty(greenInd)
        greenConnected = bwconncomp(greenBuoy);
        greenBuoy = zeros(size(greenBuoy));
        greenBuoy(greenConnected.PixelIdxList{greenInd}) = 1;
        greenBoundary = bwboundaries(greenBuoy);
        plot(greenBoundary{1}(:,2),greenBoundary{1}(:,1),'g','LineWidth',2);
    end
    
    % Identify red buoy
    redBuoy = redProb > std2(redProb);
    redBuoy = bwareafilt(bwmorph(imfill(bwmorph(bwmorph(redBuoy,'thicken',10),'close',5),'holes'),'thin',8),[450 5000]);
    redProperty = regionprops(redBuoy);
    redMaxArea = 0;
    redNextMax = 0;
    redInd = [];
    redNextInd = [];
    for i = 1:length(redProperty)
        if redMaxArea < redProperty(i).Area
            if (all(redProperty(i).Centroid > 35))&&(all(redProperty(i).Centroid < flip(size(redProb))-35))
                if ~isempty(redInd)
                    redNextMax = redMaxArea;
                    redNextInd = redInd;
                end
                redMaxArea = redProperty(i).Area;
                redInd = i;
            end
        elseif redNextMax < redProperty(i).Area
            if (all(redProperty(i).Centroid > 35))&&(all(redProperty(i).Centroid < flip(size(redProb))-35))
                redNextMax = redProperty(i).Area;
                redNextInd = i;
            end
        end
    end
    
    % Identify yellow buoy
    yellowBuoy = yellowProb > std2(yellowProb);
    yellowBuoy = bwareafilt(bwmorph(imfill(bwmorph(bwmorph(yellowBuoy,'thicken',10),'close',5),'holes'),'thin',8),[500 4000]);
    yellowProperty = regionprops(yellowBuoy);
    yellowMaxArea = 0;
    yellowNextMax = 0;
    yellowInd = [];
    yellowNextInd = [];
    for i = 1:length(yellowProperty)
        if yellowMaxArea < yellowProperty(i).Area
            if (all(yellowProperty(i).Centroid > 35))&&(all(yellowProperty(i).Centroid < flip(size(yellowProb))-35))
                if ~isempty(yellowInd)
                    yellowNextMax = yellowMaxArea;
                    yellowNextInd = yellowInd;
                end
                yellowMaxArea = yellowProperty(i).Area;
                yellowInd = i;
            end
        elseif yellowNextMax < yellowProperty(i).Area
            if (all(yellowProperty(i).Centroid > 35))&&(all(yellowProperty(i).Centroid < flip(size(yellowProb))-35))
                yellowNextMax = yellowProperty(i).Area;
                yellowNextInd = i;
            end
        end
    end
    
    % Check for overlap
    if (~isempty(redInd))&&(~isempty(yellowInd))
        tempRedInd = redInd;
        if (redMaxArea - redNextMax > 325)&&(redMaxArea - redNextMax < 1000)&&(~isempty(redNextInd))
            tempRedInd = redNextInd;
        end
        tempYellowInd = yellowInd;
        if (yellowMaxArea - yellowNextMax > 325)&&(yellowMaxArea - yellowNextMax < 1000)&&(~isempty(yellowNextInd))
            tempYellowInd = yellowNextInd;
        end
        if norm(redProperty(tempRedInd).Centroid - yellowProperty(tempYellowInd).Centroid) < 10
            if tempRedInd == redInd
                if ~isempty(redNextInd)
                    redInd = redNextInd;
                else
                    redInd = [];
                end
            end
            yellowInd = tempYellowInd;
        else
            redInd = tempRedInd;
            yellowInd = tempYellowInd;
        end
        if abs(redProperty(redInd).Area - yellowProperty(yellowInd).Area) > 500
            if ~isempty(redNextInd)
                if abs(redProperty(redNextInd).Area - yellowProperty(yellowInd).Area) > 500
                    if ~isempty(yellowNextInd)
                        if abs(redProperty(redNextInd).Area - yellowProperty(yellowNextInd).Area) > 500
                            if length(redProperty) > 2
                                redLimit = false;
                            else
                                redLimit = true;
                            end
                            if length(yellowProperty) > 2
                                yellowLimit = false;
                            else
                                yellowLimit = true;
                            end
                            if ~(redLimit && yellowLimit)
                                redInd = redNextInd;
                                yellowInd = yellowNextInd;
                                while ~(redLimit && yellowLimit)
                                    if ~redLimit
                                        redMaxArea = redNextMax;
                                        redNextMax = 0;
                                        redInd = redNextInd;
                                        redNextInd = [];
                                        for i = 1:length(redProperty)
                                            if (redMaxArea > redProperty(i).Area)&&(redNextMax < redProperty(i).Area)
                                                if (all(redProperty(i).Centroid > 35))&&(all(redProperty(i).Centroid < flip(size(redProb))-35))
                                                    redNextMax = redProperty(i).Area;
                                                    redNextInd = i;
                                                end
                                            end
                                        end
                                        if isempty(redNextInd)
                                            redLimit = true;
                                        else
                                            redInd = redNextInd;
                                            if abs(redProperty(redInd).Area - yellowProperty(yellowInd).Area) < 500
                                                redLimit = true;
                                                yellowLimit = true;
                                                continue;
                                            end
                                        end
                                    end
                                    if ~yellowLimit
                                        yellowMaxArea = yellowNextMax;
                                        yellowNextMax = 0;
                                        yellowInd = yellowNextInd;
                                        yellowNextInd = [];
                                        for i = 1:length(yellowProperty)
                                            if (yellowMaxArea > yellowProperty(i).Area)&&(yellowNextMax < yellowProperty(i).Area)
                                                if (all(yellowProperty(i).Centroid > 35))&&(all(yellowProperty(i).Centroid < flip(size(yellowProb))-35))
                                                    yellowNextMax = yellowProperty(i).Area;
                                                    yellowNextInd = i;
                                                end
                                            end
                                        end
                                        if isempty(yellowNextInd)
                                            yellowLimit = true;
                                        else
                                            yellowInd = yellowNextInd;
                                            if abs(redProperty(redInd).Area - yellowProperty(yellowInd).Area) < 500
                                                redLimit = true;
                                                yellowLimit = true;
                                                continue;
                                            end
                                        end
                                    end
                                end
                            else
                                redInd = [];
                                yellowInd = [];
                            end
                        else
                            redInd = redNextInd;
                            yellowInd = yellowNextInd;
                        end
                    elseif length(redProperty) > 2
                        while abs(redProperty(redNextInd).Area - yellowProperty(yellowInd).Area) > 500
                            redMaxArea = redNextMax;
                            redNextMax = 0;
                            redNextInd = [];
                            for i = 1:length(redProperty)
                                if (redMaxArea > redProperty(i).Area)&&(redNextMax < redProperty(i).Area)
                                    if (all(redProperty(i).Centroid > 35))&&(all(redProperty(i).Centroid < flip(size(redProb))-35))
                                        redNextMax = redProperty(i).Area;
                                        redNextInd = i;
                                    end
                                end
                            end
                            if isempty(redNextInd)
                                yellowInd = [];
                                break;
                            end
                        end
                        redInd = redNextInd;
                    else
                        redInd = [];
                        yellowInd = [];
                    end
                else
                    redInd = redNextInd;
                end
            elseif ~isempty(yellowNextInd)
                if abs(redProperty(redInd).Area - yellowProperty(yellowNextInd).Area) > 500
                    if length(yellowProperty) > 2
                        while abs(redProperty(redInd).Area - yellowProperty(yellowNextInd).Area) > 500
                            yellowMaxArea = yellowNextMax;
                            yellowNextMax = 0;
                            yellowNextInd = [];
                            for i = 1:length(yellowProperty)
                                if (yellowMaxArea > yellowProperty(i).Area)&&(yellowNextMax < yellowProperty(i).Area)
                                    if (all(yellowProperty(i).Centroid > 35))&&(all(yellowProperty(i).Centroid < flip(size(yellowProb))-35))
                                        yellowNextMax = yellowProperty(i).Area;
                                        yellowNextInd = i;
                                    end
                                end
                            end
                            if isempty(yellowNextInd)
                                redInd = [];
                                break;
                            end
                        end
                        yellowInd = yellowNextInd;
                    else
                        redInd = [];
                        yellowInd = [];
                    end
                else
                    yellowInd = yellowNextInd;
                end
            else
                redInd = [];
                yellowInd = [];
            end
% %         elseif redNextMax < redProperty(i).Area
% %             if (all(redProperty(i).Centroid > 35))&&(all(redProperty(i).Centroid < flip(size(redProb))-35))
% %                 redNextMax = redProperty(i).Area;
% %                 redNextInd = i;
% %             end
% %         end
% %     end
% 
        end
    elseif ~isempty(redInd)
        if (redMaxArea - redNextMax > 325)&&(redMaxArea - redNextMax < 1000)&&(~isempty(redNextInd))
            redInd = redNextInd;
        end
    elseif ~isempty(yellowInd)
        if (yellowMaxArea - yellowNextMax > 325)&&(yellowMaxArea - yellowNextMax < 1000)&&(~isempty(yellowNextInd))
            yellowInd = yellowNextInd;
        end
    end
    
    % Plot red buoy
    if ~isempty(redInd)
        redConnected = bwconncomp(redBuoy);
        redBuoy = zeros(size(redBuoy));
        redBuoy(redConnected.PixelIdxList{redInd}) = 1;
        redBoundary = bwboundaries(redBuoy);
        plot(redBoundary{1}(:,2),redBoundary{1}(:,1),'r','LineWidth',2);
    end
    
    % Plot yellow buoy
    if ~isempty(yellowInd)
        yellowConnected = bwconncomp(yellowBuoy);
        yellowBuoy = zeros(size(yellowBuoy));
        yellowBuoy(yellowConnected.PixelIdxList{yellowInd}) = 1;
        yellowBoundary = bwboundaries(yellowBuoy);
        plot(yellowBoundary{1}(:,2),yellowBoundary{1}(:,1),'y','LineWidth',2);
    end
    
    hold off

%     imshow(yellowBuoy)
%     yellowBuoy = bwmorph(imfill(bwmorph(bwmorph(yellowBuoy,'thicken',10),'close',5),'holes'),'thin',8);
%     yellowBuoy2 = bwareafilt(yellowBuoy,[500 5000]);

%     maskR = bwmorph(maskR,'thicken',2);
%     maskR = bwmorph(maskR,'close',10);
%     maskR = bwareafilt(maskR2,[200 2000]);
%     maskR = imfill(maskR,'holes');
%     imshow(maskR)
    
    end

%     % Create 1-D gaussians
%     value = (0.5:255.5)';
%     [muG,sigmaG] = normfit(value,0.05,zeros(size(value)),greenHist);
%     [muR,sigmaR] = normfit(value,0.05,zeros(size(value)),redHist);
%     [muY,sigmaY] = normfit(value,0.05,zeros(size(value)),yellowHist);
%     totalHist = (sum(greenHist)*greenHist + sum(redHist)*redHist + sum(yellowHist)*yellowHist)/sum(greenHist + redHist + yellowHist);
%     [mu,sigma] = normfit(value,0.05,zeros(size(value)),totalHist);
%     
%     % Save gaussians being used
%     normG = normpdf(value,muG,sigmaG);
%     normR = normpdf(value,muR,sigmaR);
%     normY = normpdf(value,muY,sigmaY);
%     norm = normpdf(value,mu,sigma);
%     plot(value,normG);
%     saveas(gcf,'../../Output/Part0/G_gauss1D.jpg')
%     plot(value,normR);
%     saveas(gcf,'../../Output/Part0/R_gauss1D.jpg')
%     plot(value,normY);
%     saveas(gcf,'../../Output/Part0/Y_gauss1D.jpg')
%     plot(value,norm);
%     saveas(gcf,'../../Output/Part0/gauss1D.jpg')
    
    
% end