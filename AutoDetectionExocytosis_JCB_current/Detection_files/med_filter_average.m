function new_test = med_filter_average(I_file,mask_name,n)
%Creates a median of the previous 5 images, then subtracts that image from
%the current one.

%Grab the info from the file read in
tiff_info = imfinfo(I_file);
[pathstr,name, ~] = fileparts(I_file);

    %1read in the file and mask file
    I_test = imread(I_file,n);
    I_mask = imread(mask_name);

    %May need to invert the logical mask if created using imagej
    I_mask = logical(I_mask);
    %I_mask = ~I_mask;

    %Filter the mask for just 1 object
    I_mask = bwareafilt(I_mask,1);
    
    %Use a Gaussian match-filter to eliminate noise
    I_test = imgaussfilt(I_test,2);

    %Find the median of 5 previous frames
    for gib = 1:5
        med1 = imread(I_file,n-gib);
        med1 = imgaussfilt(med1,2);
        med1 = medfilt2(med1);
        X(:,:,gib) = med1;
    end
    
    %create the median frame from the previous 5
    Y = squeeze(median(X,3));

    %subtract the median-5 from the current image
    new_test = imsubtract(I_test,Y);
    
    %Multiply by the mask to get a final image
    new_test = immultiply(I_mask,new_test);
 
end