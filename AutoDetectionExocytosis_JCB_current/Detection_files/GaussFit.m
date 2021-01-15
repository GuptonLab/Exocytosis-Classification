function detected_image = GaussFit(img)
%% Filter using DoG
%This detection algorithm is based off of looking for a gaussian-based
%change in fluorescence. To achieve this, images are first background
%subtracted, converted to 8-bit, and then histogram matched for bleach
%correction (This is done using the preprocessing matlab file).

%Med filtering: to look specifically for changes in fluorescence, the
%median pixel fluorescence of the previous 5 frames is subtracted from the
%current frame. This gives approximately a "background subtraction" that
%should highlight only changes over the generic background (median is used
%to be robust against outliers/other fluorescent objects)

%After median subtraction filtering, we are left with lots of noise and some exocytic
%events. The exocytic events should be gaussian while the random noise is
%not, so I employ a scale-invariant difference-of-gaussians that uses heavy
%convolution with the gaussians. The exocytic events should be the only
%object that stays bright over different octaves, so once again the median
%of all the DoG scales is found, and only the "stable" DoG pixels remain,
%which represent true exocytic events. Comparisons with hand-picked events
%suggest a value of 1 is noisy with lots of false positives, while values
%of 2 or more represent true exocytic events, so the final medial-DoG image
%is thresholded on any value > 1.

img = imgaussfilt(img,6);
stepsPerOctave = 3;
octaves = 4;
mult = nthroot(2,stepsPerOctave);

% Create blurry images
sigma = 1;
kernelSize = [10*sigma*2^(octaves),10*sigma*2^(octaves)];
for k = 1:octaves*stepsPerOctave+1
    gauss = fspecial('gaussian', kernelSize, sigma);
    blur(:,:,k) = imfilter(img, gauss, 'replicate', 'same');
    sigma = sigma * mult;
end

% Create DoG
for k = 1:octaves*stepsPerOctave
    dog(:,:,k) = blur(:,:,k) - blur(:,:,k+1);
end

%First, find the max of the SI-DoG
%squashed_down = max(dog,[],3);

%After experimenting, using the median seems to work wonders
med_down = median(dog,3);

%Threshold based on the difference. I chose 3 here; this can most likely
%vary based on the signal-to-background and variation in background
%detected_image = squashed_down>3;

%Threshold is now based on values greater than 1. Values of 1 have been
%shown 
%awesome
%detected_image = med_down>1;
%Saving the 
detected_image = med_down;
end