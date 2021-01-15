%This is a preprocessing step that takes in the file and the mask and
%does background subtaction, converts into 8-bit with linear scaling from
%min-max to 0-255, then performs histogram matching in order to bleach
%correct.
function new_bits = Convert_256_f(I_file,image_mask,ii)
%read in the file


%get the file info
tiff_info = imfinfo(I_file);

%read in the mask file
I_mask = imread(image_mask);

%reads in the file t obe tested
I_test = imread(I_file,ii);

%Get the background of the cell, using median to account for outlier values
I_mask = logical(I_mask);
I_mask_com = ~I_mask;

pixelsToTest = regionprops(I_mask_com,I_test, 'PixelValues');
background_average = median(pixelsToTest(1).PixelValues,'all');


%background subtract
I_test = I_test-background_average;

%get the min/max values
min_val = min(min(I_test));
max_val = max(max(I_test));

%convert to 256 using linear scaling: min-max to 0-255
I_test_double = double(I_test);
%I_test_double = I_test_double*255/2239;
new_bits = uint8(255 * mat2gray(I_test_double));
end