%Clear variables for ease of use
clc;
clear;


%lets try this: histeq with first frame?
%First, get the list of images and csvs 
image_path = dir([pwd '/PreProcessed/','*.tif']);
csv_path = dir([pwd '/DataFiles/', '*_tracking.csv']);

%For each image
%for loop here
for z = size(image_path,1)
    
        I = image_path(z).name;   
    %Get the info/nameparts of the file
    [pathstr,name, ~] = fileparts(I);
    
    %Get the image name path
    image_name = image_path(z).name;
    image_name_path = [pwd '/PreProcessed/',image_name];
    
    %Create the final output name
    outfile_name = [pwd '/ProcessedFiles/',name, '_vizual.tif'];
    
    %Next, read in the CSV path
    csv_fil = [csv_path(z).folder,'/',csv_path(z).name]; %Get the csv name
    csv = readtable(csv_fil); %Default works here


    %For each frame in the video,
    tiff_info = imfinfo(image_name_path); %get the number of frames
    for i = 1:size(tiff_info,1)
        %extract the X, Y, T, bounding box
        row_idx = []; %Set these to blank since we loop over
        col_idx = [];

        %Read in the file
        image = imread(image_name_path,i);
    
        image_8b = image; %legacy, easier to keep this variable switch
        
        %get all exocytic events in this frame
        temp_csv = csv(csv.time == i,:);
    
        %if there are not exocytic events
        if isempty(temp_csv)
            %just keep the image without events
            temp_image = image_8b;
            temp_image = cat(3,temp_image,temp_image,temp_image);
        else
            %insert the circle shape
            radi = repmat(10,size(temp_csv.centroid_1,1),1); %constant: radius for circle
            temp_image = insertShape(image_8b,'Circle',[temp_csv.centroid_1 temp_csv.centroid_2 radi], 'LineWidth',4, 'Color','red');
        end
        
        %Save file
        imwrite(temp_image, outfile_name, 'Compression','none', 'Writemode', 'append');        
    end
end