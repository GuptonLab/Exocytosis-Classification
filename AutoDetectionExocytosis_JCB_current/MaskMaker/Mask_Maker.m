
%% Get the directory of the data files
clear;
clc;

files = dir([pwd '/RawData/', '*.tif']);
if ~exist([pwd '/MaskFiles/'], 'dir')
  mkdir 'MaskFiles'
end

%% Create the cell masks; stop here to make sure they look fine. Otherwise, create your own masks before moving
%on to the next step. 
tic;
progressbar('Masks for videos')
for ii = 1:size(files,1)
    I = files(ii).name;
    image_path = [pwd '/RawData/',I];
    Cell_Mask_Arch_fin(image_path); %create the cell masks for these images
    progressbar(ii/size(files,1))
end
toc;
