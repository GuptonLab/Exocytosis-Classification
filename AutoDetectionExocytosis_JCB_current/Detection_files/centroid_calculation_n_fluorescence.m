function centroid_calculation_n_fluorescence (I_file,csv_fil)

n = 20;

%% The purpose of this function is to read in a xyt co-ordinates file and get features of an nxn square centered on the centroid of the xyt co-ordinates
tiff_info = imfinfo(I_file);
[pathstr,name, ~] = fileparts(I_file);

%Get the pathstring for the CSV file to make the output file name and path
[pathstr2,name2,~] = fileparts(csv_fil);
%create the output file name
out_file_s = fullfile(pathstr2,[name,'_fluorescence_traces.csv']);


%csv = csvread(csv_fil,1,0); %read in the xyt file
csv = readtable(csv_fil,'Delimiter','comma');
%create the out file name

%%%
%Seperate out the columns for time, x, and y positions
Xv = csv.centroid_1;
indx = ~isnan(Xv);
Xv = Xv(indx);

Yv = csv.centroid_2;
indy = ~isnan(Yv);
Yv = Yv(indy);

timez = csv.time;
indt = ~isnan(timez);
timez = timez(indt);
timez = timez;

%create a vector that indexes each time curve
cv_id = csv.id; 
indid = ~isnan(cv_id);
ind_num = cv_id(indid);

ROI = [];
ROI_mean = [];
%% loop
%for 1: length of the csv column
tic; %start the timer
for ii = 1:size(csv,1)
    row_idx = [];
    col_idx = [];
    %read in the time index
    %time_i = int64(10*csv(ii,3));
    time_i = timez(ii);
    %get the centroidz
    %col_idx = int64(csv(ii,1));
    col_idx = round(Xv(ii));
    
    %row_idx = int64(csv(ii,2));
    row_idx = round(Yv(ii));
    %counter for the cells
    count = 1;
    
    for jj = time_i-20:time_i+30
        %check to see if the index is inside the range of the video
        if (0 < jj && jj < size(tiff_info,1))
            %read in the frame of the image
            I_f = imread(I_file,jj);
            %get the values of the bounding box
            ROI = I_f((row_idx-floor(n/2)):(row_idx+floor(n/2)),(col_idx-floor(n/2)):(col_idx+floor(n/2)));
            ROI_mean(ii,count) = mean(mean(I_f((row_idx-floor(n/2)):(row_idx+floor(n/2)),(col_idx-floor(n/2)):(col_idx+floor(n/2)))));
            %ROI_SD(ii,count) = std(std(I_f((row_idx-floor(n/2)):(row_idx+floor(n/2)),(col_idx-floor(n/2)):(col_idx+floor(n/2)))));%I is your image. These are the actual pixels.
            count = count+1;
        else
            ROI_mean(ii,count) = 0;
            count = count+1;
        end
    end
    
end

%Create a table with an index, the centroids, the time point, and the
%fluorescent trace curves

%create the header with the 
%Create the header for the time series
header_one = {"index","x_pos","y_pos","frame_num"};
numheaders = 51;
header_two = arrayfun(@(n) sprintf('TimePoint_%d', n), 1:numheaders, 'UniformOutput', false);

header_fin = cat(2,header_one,header_two);

fin = cat(2,ind_num,Xv,Yv,timez,ROI_mean);
fin = [header_fin;num2cell(fin)];

%write data to a file
%csvwrite(out_file_s,ROI_mean);

writetable(cell2table(fin),out_file_s,'WriteVariableNames',false);
toc;
end
