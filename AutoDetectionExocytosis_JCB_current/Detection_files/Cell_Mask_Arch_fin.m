function Cell_Mask_Arch_fin(I_file)
% This function generates all of the cell masks thatwill be used by the
% program. It will find the perimeter and save those as a separate file as
% well, in it's own folder.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setup variables and parse the command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.StructExpand = true;
i_p.addRequired('I_file',@(x)exist(x,'file') == 2);
i_p.parse(I_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic; %start the timer for the mask maker

%Read in the file information
info = imfinfo(I_file);
Ifilenum1 = imread(I_file,1);
num_images = numel(info);


R = uint32(imread(I_file,1)); %convert into uint32

%Find the average of the stack of images
for i = 2:num_images

    R = imadd(R,uint32(imread(I_file, i)));
end
R = imdivide(R,num_images);


%Subtracts the average from the first frame
R = imsubtract(uint32(imread(I_file,1)),R);

%medfilter + massive sharpening allows easy segmentation against background
R = uint8(R); %reduce to 8 bit
RR = medfilt2(R, [12 12]); %Giant median convolution filter
tryingout = imsharpen(RR, 'Radius',15,'Amount',15); %Sharpen greatly
levelagain = graythresh(tryingout); %find a good threshold
BWagain = im2bw(tryingout,levelagain); %segment

%Only keeps the largest object, the neuron
bigobjects2 = bwareafilt(BWagain,1);
%bigobjects2 = bigobjects2';
example2 = bwperim(bigobjects2,8); %get the perimeter

%Traces the perimeter of the cell
%[tempx,tempy] = find(bigobjects2,1);
%contour = bwtraceboundary(bigobjects2,[tempx tempy],'E',4,Inf,'clockwise');
%contour(:,[1,2]) = contour(:,[2,1]);

%writes a mask file image (.tif), a CSV file for spatstat to use, and a
%contour file for another spatial statistics package.

[pathstr,name, ~] = fileparts(I_file); %get the filename parts

%create the file names
%out_file_mask = fullfile(pathstr,[name,'_mask_file.tif']);
out_file_mask = [pwd '/MaskFiles/',name,'_mask_file.tif'];
out_file_csv = fullfile(pathstr,[name,'_mask_file.csv']);
%out_file_contour = fullfile(pathstr,[name,'_contour_file.csv']);

%save the mask file in CSV format, tif format, png, and the countour
%csvwrite(out_file_contour,contour);
imwrite(bigobjects2, out_file_mask, 'compression', 'none');
%imwrite (bigobjects2, 'temp_mask.png', 'BitDepth',1);
%blag = imread('temp_mask.png'); %Have to read in the png weirdly
%csvwrite(out_file_csv, blag);

toc; %ends the timer
end