%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code runs all the commands used in this Project.
% 
% Submitted by: Ashwin Goyal (UID - 115526297)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define the folder of training set
trainFolder = '..\input\Images\TrainingSet\Frames\';
% Read all training image names
trainFiles = dir([trainFolder '*.jpg']);

% Define the folder of testing set
testFolder = '..\input\Images\TestSet\Frames\';
% Read all training image names
testFiles = dir([testFolder '*.jpg']);

% Define the folder of cropped buoys
cropFolder = '..\input\Images\TrainingSet\CroppedBuoys\';

% % Extract frames from the given video
% video2images('..\input\detectbuoy.avi',{trainFolder,testFolder})

% % Crop the images to get the training set
% cropImages(trainFolder,cropFolder)

% % Compute average histogram as well as the color distribution
% averageHistogram(trainFolder,cropFolder,'RGB')

% % Get color distributions
% greenDist = []; redDist = []; yellowDist = [];
% load('..\output\colorDistributions_RGB.mat','greenDist','redDist','yellowDist')
% [var(1,1),var(1,2)] = normfit(greenDist(:,2));
% [var(2,1),var(2,2)] = normfit(redDist(:,1));
% [var(3,1),var(3,2)] = normfit(mean(yellowDist(:,1:2),2));
% % Plot the three gaussians if asked
% figure('units','normalized','outerposition',[0 0 1 1])
% plot(0:255,normpdf(0:255,var(1,1),var(1,2)))
% title('1-D Gaussian to Detect Green Buoy')
% xlabel('Intensity')
% ylabel('Probability')
% saveas(gcf,'../output/G_gauss1D.jpg')
% plot(0:255,normpdf(0:255,var(2,1),var(2,2)))
% title('1-D Gaussian to Detect Red Buoy')
% xlabel('Intensity')
% ylabel('Probability')
% saveas(gcf,'../output/R_gauss1D.jpg')
% plot(0:255,normpdf(0:255,var(3,1),var(3,2)))
% title('1-D Gaussian to Detect Yellow Buoy')
% xlabel('Intensity')
% ylabel('Probability')
% saveas(gcf,'../output/Y_gauss1D.jpg')
% % Create video of segmented images using 1-D gaussian
% vidObj = VideoWriter('..\output\segment1D.mp4','MPEG-4');
% vidObj.Quality = 100;
% open(vidObj)
% count = 0;
% for i = 1:length(testFiles)+length(trainFiles)
%     if rem(i,10) == 1
%         count = count + 1;
%         I = segment1D(var,[trainFolder trainFiles(count).name],false);
%     else
%         I = segment1D(var,[testFolder testFiles(i-count).name],false);
%     end
%     for j = 1:6
%         writeVideo(vidObj,I)
%     end
% end
% close(vidObj)

% % Create data using 3 1-D gaussians
% data = cat(3,linspace(10,30)',linspace(30,50)',linspace(50,70)');
% mu = [mean(data(:,:,1));mean(data(:,:,2));mean(data(:,:,3))];
% sigma = cat(3,var(data(:,:,1)),var(data(:,:,2)),var(data(:,:,3)));
% X = [data(:,:,1); data(:,:,2); data(:,:,3)];
% X = sort(X);
% figure('units','normalized','outerposition',[0 0 1 1])
% gmObj = gmdistribution(mu,sigma);
% Y = pdf(gmObj,X);
% plot(X,Y)
% hold on
% % Use EM to retrieve the three gaussians used
% [gmObj_1D3N,isConverged] = EM(X,3);
% if isConverged
%     Y_1D3N = pdf(gmObj_1D3N,X);
%     plot(X,Y_1D3N)
%     xlabel('Data Points')
%     ylabel('Probability')
%     title('Probability Distribution')
%     legend('Actual PDF','Derived PDF')
%     saveas(gcf,'..\output\EM1D3N.jpg')
% end
% hold off
% 
% % Plot the data generated using 3 1-D gaussians again
% figure('units','normalized','outerposition',[0 0 1 1])
% plot(X,Y)
% hold on
% % Use EM to retrieve four gaussians instead of three
% [gmObj_1D4N,isConverged] = EM(X,4);
% if isConverged
%     Y_1D4N = pdf(gmObj_1D4N,X);
%     plot(X,Y_1D4N)
%     xlabel('Data Points')
%     ylabel('Probability')
%     title('Probability Distribution')
%     legend('Actual PDF','Derived PDF')
%     saveas(gcf,'..\output\EM1D4N.jpg')
% end
% hold off

% Generate 1-D gaussians for each buoy
% colorModels_test('RGB','..\output\ColorModels_test\',5,1);
% Generate 2-D gaussians for each buoy
% colorModels_test('RGB','..\output\ColorModels_test\',5,2);

% Create video of segmented images using gaussians generated from EM
% vidObj = VideoWriter('..\output\segment1D.mp4','MPEG-4');
% vidObj.Quality = 100;
% open(vidObj)
count = 0;
for i = 1:length(testFiles)+length(trainFiles)
    if rem(i,10) == 1
        count = count + 1;
        I = detectBuoy(gmObjs,[trainFolder trainFiles(count).name],false);
    else
        I = detectBuoy(gmObjs,[testFolder testFiles(i-count).name],false);
    end
%     for j = 1:6
%         writeVideo(vidObj,I)
%     end
end
% close(vidObj)














function N = gauss(x, mu, sigma)
% This function computes N(x|mu,sigma)

    sigma = reshape(sigma,[size(sigma,2) size(sigma,3)]);
    N = (1/(2*pi)^(size(x,2)/2))*(1/sqrt(det(sigma)))*exp(-0.5*((x - mu)/sigma)*(x - mu)');
    if isnan(N)
        N = 0;
    end
    
end