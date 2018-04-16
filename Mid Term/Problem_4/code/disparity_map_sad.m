%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code generates disparity map using SAD for defined window size.
% 
% Submitted by: Ashwin Goyal (UID - 115526297)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function disparity_map_sad(I_left, I_right, window_size)

% Add boundary to apply SAD on the edge pixels
I_left_mod = zeros(window_size-1+size(I_left,1),window_size-1+size(I_left,2));
I_left_mod(ceil(window_size/2):end-floor(window_size/2),ceil(window_size/2):end-floor(window_size/2)) = I_left;
I_right_mod = zeros(window_size-1+size(I_right,1),window_size-1+size(I_right,2));
I_right_mod(ceil(window_size/2):end-floor(window_size/2),ceil(window_size/2):end-floor(window_size/2)) = I_right;

% Compute disparity using SAD
D = zeros(size(I_left));
for i=ceil(window_size/2):floor(window_size/2)+size(I_left,1)
    for j=ceil(window_size/2):floor(window_size/2)+size(I_left,2)
        min_diff = Inf;
        % Create left window
        left_window = I_left_mod(i-floor(window_size/2):i+floor(window_size/2),j-floor(window_size/2):j+floor(window_size/2));
        for k=ceil(window_size/2):floor(window_size/2)+size(I_left,2)
            % Create right window
            right_window = I_right_mod(i-floor(window_size/2):i+floor(window_size/2),k-floor(window_size/2):k+floor(window_size/2));
            % Compute SAD
            sad = sum(sum(abs(left_window - right_window)));
            if sad<min_diff
                min_diff = sad;
                % If minimum SAD, store disparity
                D(i-floor(window_size/2),j-floor(window_size/2)) = abs(k - j);
            end
        end
    end
end

% Change range to 0 to 255
D = uint8(round(D*255/max(max(D))));

% Generate a histogram of the disparities
H = zeros(1,256);
for i=1:size(D,1)
    for j=1:size(D,2)
        H(D(i,j)+1) = H(D(i,j)+1) + 1;
    end
end

% Normalize the histogram to a value of 255
H = H*255/numel(D);

% Generate the CDF of the histogram
new_H = zeros(1,256);
for i=1:256
    new_H(i) = round(sum(H(1:i)));
end

% Generate the new disparities using CDF
new_D = D;
for i=1:size(new_D,1)
    for j=1:size(new_D,2)
        new_D(i,j) = new_H(D(i,j)+1);
    end
end

% Display the image with colormap
imshow(new_D)
colormap(gca,jet)
colorbar

% Save the image
saveas(gca,['../output/SAD/Disparity Map using SAD for window_size = ' num2str(window_size) '.jpg'])

end