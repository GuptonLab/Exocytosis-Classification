
#You have to individually change the file paths for this piece
#code. I had to fidget a bit with it and dropped the automation, and for time this is the non-automated.

#This is the final code and your output file name should be/contain the detected events.

file_path_name = "E:/Libraries/Documents/SCIENCE_GUPTON/TESTING/DataFiles/VAMP2pHluorin_488_wt_4_PreProcessed_fluorescence_traces.csv"
output_file_name = "E:/Libraries/Documents/SCIENCE_GUPTON/TESTING/DataFiles/Stream_4_fusion_stats.csv"




#read in the file
wt1_fin <- read.table(file=file_path_name, header=T, sep=",")
#separate out the data portion
data_only <- wt1_fin[c(25:55)]
background <- wt1_fin[c(5:23)]
#separate out the centroid,time point, and length of track
frame_obj <- wt1_fin[c(3:4)]
#transpose the matrixes back and forth to turn it into a matrix data type
frame_obj = t(frame_obj)
frame_obj = t(frame_obj)
data_only = t(data_only)
data_only = t(data_only)
background <- t(background)
background <- t(background)


for (i in 1:length(data_only[,1])){
  mean_bac = mean(background[i,])
  for (f in 1:length(data_only[i,])){
    data_only[i,f] = (data_only[i,f] - mean_bac)/mean_bac
  }
}
#Taking the centroid x,y values
centroid <- wt1_fin[c(1:2)]
#transform the data into a different data type
centroid <- t(centroid)
centroid <- t(centroid)
#Set up the time points in seconds
x_time = seq(0.1,3.1, by = 0.1)

#Add a non-negative term for log transform
data_only = data_only + 10

#creat the vector for the R-square, half_life, and max intensity
r_sq <- vector()
half_life <- vector()
max_int <- vector()
r_sq_2 <- vector()
r_beyond_sig <- vector()

print(length(data_only[,1]))
for (i in 1:length(data_only[,1])){
  max_int[i] <- max(data_only[i,])
  if(max(data_only[i,]) > 10.1){
    dat <- data_only[i,]
    exponential.model <- lm(dat~ log(x_time))
    exponential_2.model <- lm(dat~x_time)
    coef <- summary(exponential.model)$coefficients
    half_life[i] <- -coef[2]
    r_sq[i] <- summary(exponential.model)$r.squared
    r_sq_2[i] <- summary(exponential_2.model)$r.squared
    r_beyond_sig[i] = r_sq[i]/r_sq_2[i]
  }else{
    half_life[i] = NA
    r_sq[i] = NA
    r_sq_2[i] = NA
    r_beyond_sig[i] = NA
  }
}

#file_path_contrast = "E:/Libraries/Documents/SCIENCE_GUPTON/TESTING/RawData/VAMP2pHluorin_488_wt_4_contrast.csv"
#file_path_correlation = "E:/Libraries/Documents/SCIENCE_GUPTON/TESTING/RawData/VAMP2pHluorin_488_wt_4_correlation.csv"
#file_path_energy = "E:/Libraries/Documents/SCIENCE_GUPTON/TESTING/RawData/VAMP2pHluorin_488_wt_4_energy.csv"
#file_path_homogeneity = "E:/Libraries/Documents/SCIENCE_GUPTON/TESTING/RawData/VAMP2pHluorin_488_wt_4_PreProcessed_fluorescence_traces.csv"


tea = rbind(r_sq,r_sq_2,r_beyond_sig,half_life)
tea = t(tea)
tea = cbind(centroid,tea)
tea = cbind(frame_obj,tea)
max_int = max_int - 10
tea = cbind(max_int,tea)
full_fusion <- na.omit(tea)

write.csv(full_fusion,file = output_file_name)

