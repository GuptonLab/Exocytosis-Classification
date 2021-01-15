% Clear everything
clc
clear
 
%If the data folder and mask files folder exists, get a list of files from
%them
if exist([pwd '/RawData/'], 'dir')
  files = dir([pwd '/RawData/', '*.tif']);
else
    warning('RawData folder does not exist in this directory')
end


if exist([pwd '/MaskFiles/'], 'dir')
  mask_files = dir([pwd '/MaskFiles/','*tif']);
else
    warning('MaskFiles folder does not exist in this directory')
end

%Check to see if the same number of mask files matches the same number of
%data files in each folder

%% If the temporary and ProcessedFiles folders don't exist, make them

if ~exist([pwd '/ProcessedFiles/'], 'dir')
  mkdir 'ProcessedFiles'
end

%Creates the 

if ~exist([pwd '/DataFiles/'], 'dir')
  mkdir 'DataFiles'
end

if ~exist([pwd '/Temp/'], 'dir')
  mkdir 'Temp'
end

if ~exist([pwd '/PreProcessed/'], 'dir')
  mkdir 'PreProcessed'
end

%% Preprocessing the raw data files
%This algorithm takes in the raw data files in the RawData folder, then
%background subtracts, converts the images to 8 bit, and bleach corrects
%using histogram matching

%For each file in the folder,
progressbar('number of videos processed','preprocessing current video')
for jj = 1:size(files,1)
    %Get the filename from the RawData folder
    I = files(jj).name;
    image_path = [pwd '/RawData/',I];
    %Get the info/nameparts of the file
    tiff_info = imfinfo(image_path);
    [pathstr,name, ~] = fileparts(I);
    
    %Search for the matching mask_file in the MaskFiles folder
    mask_path = [pwd '/MaskFiles/',name,'_mask_file.tif'];

    if ~exist(mask_path, 'file')
        warning(['The associated mask file for ',I,' does not exist.']);
    end

    %Creat a new outfile name for the temporary file
    outfile_name = [pwd '/PreProcessed/',name, '_PreProcessed.tif'];
    

    %Perform 8-bit conversion and histogram matching, save in a Temp folder
    progressbar([],0)
    for i = 1:size(tiff_info, 1)
        %If its the first image, save it specially after conversion
        if i == 1
            Ref_image = Convert_256_f(image_path,mask_path,i);
            imwrite(Ref_image, outfile_name, 'Compression','none', 'Writemode', 'append');
        else
            %if not the first, convert and histogram match with the first
            image_con = Convert_256_f(image_path,mask_path,i);
            hist_ma_image = imhistmatch(image_con,Ref_image);            
            imwrite(hist_ma_image, outfile_name, 'Compression','none', 'Writemode', 'append');

        end
        progressbar([],i/size(tiff_info,1))
        
    end
    progressbar(jj/size(files,1))
end

%% Perform detection algorithm

%For each file in the folder,
progressbar('Videos Finished','Current Video Percent Complete')
for jj = 1:size(files,1)


    %Get the filename from the RawData folder
    I = files(jj).name;
    
    %Get the info/nameparts of the file
    [pathstr,name, ~] = fileparts(I);
    
    %if the PreProcessed folder exists, look in there for the files
    image_path = ([pwd '/PreProcessed/',name,'_PreProcessed.tif']);
    tiff_info = imfinfo(image_path);
    
    %Search for the matching mask_file in the MaskFiles folder
    mask_path = [pwd '/MaskFiles/',name,'_mask_file.tif'];

    if ~exist(mask_path, 'file')
        warning(['The associated mask file for ',I,' does not exist.']);
    end

    %Creat a new outfile name for the temporary file
    outfile_name_temp = [pwd '/Temp/',name, '_Temp.tif'];
    outfile_name = [pwd '/ProcessedFiles/',name, '_Processed.tif'];

    max_value_temp = [];
     progressbar([],0)
    %Perform spot-detection using Gaussians
    for i = 10:size(tiff_info, 1)
        
        %read in the image path
        image_temp = med_filter_average(image_path,mask_path,i);
       
        %GaussFit on the image; grab the maximum value distributions
        detected_spots = GaussFit(image_temp);
        max_value_temp(i) = max(max(detected_spots));
        
        %get the max values so as to threshold on later
        %Write the file to the Temp file
        imwrite(detected_spots, outfile_name_temp, 'Compression','none', 'Writemode', 'append');

    end
     progressbar([],1/3)
    
    %find the threshold value
    thresh_value = median(max_value_temp);
    
    %Loop through the temporary file, creating the final processed file
    %threshholding based off of the median max value
    tiff_info_temp = imfinfo(outfile_name_temp);
    
    for k = 1:size(tiff_info_temp,1)
        temp_image_to_thresh = imread(outfile_name_temp,k);
        final_processed_image = temp_image_to_thresh>thresh_value;
        imwrite(final_processed_image, outfile_name, 'Compression','none', 'Writemode', 'append');
    end
     progressbar([],2/3)
    %Next, perform kalman filter algorithm to link tracks
    multiObjectTracking_all_centroids(outfile_name);
    
    %refine the fusion events - unecessary step, taken out
    %refine_fusion_file_Arch(outfile_name);
    
    %Extract fusion events: first, get the path of the data file
   data_path = [pwd '/DataFiles/',name,'_Processed_tracking.csv'];
   
    %Next, extract the fusion fluorescent profiles
    centroid_calculation_n_fluorescence(image_path,data_path);   
    
    delete(outfile_name_temp)
    %delete(outfile_name)
    progressbar(jj/size(files,1))
    
    clear;
    clc;
end
