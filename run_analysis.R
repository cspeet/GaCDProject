## Filename: run_analysis.R
##
## This script encapsulates the code needed to manipulate input Samsung data
## into the target tidy data set contemplated by the assignment. This script
## assumes that the Samsung data file has been loaded into your working directory
## in .zip format.
library(stringr)

## This function reads in the activity labels from the dataset documentation
## and processed them into a vector of split character that can be used
## later to translate the activity values to meaningful descriptions and 
## convert to a factor variable
getActivityLabels <- function() {
  ## Read the activity labels into a character vector
  aNames <- readLines("./UCI HAR Dataset/activity_labels.txt", n=6L)
  
  ## Split the values on the intervening space
  aNames <- strsplit(aNames, " ")
  
  ## Return the split vector
  aNames
}

## This function reads in the column names from the dataset documentation
## and processes them into a vector of character values that can be used
## later to assign the column names into the datasets
getColumnNames <- function() {
  ## Set up the column names (Taken from features.txt in input data files)
  cNames <- readLines("./UCI HAR Dataset/features.txt", n=561L)
  cNames <- strsplit(cNames, " ")
  for(i in seq_along(cNames)) {
    cNames[[i]] <- cNames[[i]][2]
  }
  cNames
}

## This function processes the test and train datasets and performs all the 
## modifications required to make  a tidy dataset.
##
## The 'dsname' argument is a character string indicating which dataset is 
## being processed. It only accepts the values "test" and "train". It is used 
## to calculate the path/filenames that should be loaded.
processDatasets <- function() {
  
  ## Read in the two datasets files
  testSub <- read.table("./UCI HAR Dataset/test/subject_test.txt")
  testLab <- read.table("./UCI HAR Dataset/test/y_test.txt", colClasses=c("character"))
  testSet <- read.table("./UCI HAR Dataset/test/X_test.txt")
  
  trainSub <- read.table("./UCI HAR Dataset/train/subject_train.txt")
  trainLab <- read.table("./UCI HAR Dataset/train/y_train.txt", colClasses=c("character"))
  trainSet <- read.table("./UCI HAR Dataset/train/X_train.txt")
  
  ## Merge the two datasets
  dSet <- rbind(testSet, trainSet)
  dSub <- rbind(testSub, trainSub)
  dLab <- rbind(testLab, trainLab)
   
  ## Set column names on the merged dataset
  names(dSet) <- cNames

  ## Extract only the columns that include mean or standard deviation calculations
  dSet <- dSet[,grep("mean\\Q()\\E|std\\Q()\\E", names(dSet))]
  
  ## Add subject columns to both datasets
  dSet$subject <- dSub$V1
  
  ## Translate numeric activity codes to text descriptions
  for(i in seq_along(aNames)) {
    dLab$V1 <- gsub(as.character(i), aNames[[i]][2], dLab$V1)
  }

  ## Convert label vector to factor variable
  dLab$V1 <- factor(dLab$V1, levels=c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"), ordered=TRUE)
  
  ## Add factor to dSet
  dSet$activity <- dLab$V1
  
  ## Reorder columns (bring subject and activity to the leftmost 2 columns in the datasets)
  dSet <- dSet[, c(67:68, 1:66)]
  
  ## Return the tidy dataset
  dSet
}

## This function processes the data in the input dataset to produce
## a second tidy dataset with the averages of the mean and std measurements
## for every subject and activity.
## The 'ds' parameter is the input dataset containing the full set of 
## Gyroscopic measurements.
processTDS2 <- function(ds) {
  ## Split the first tidy dataset on the interactions between subject and activity
  aveSet <- split(ds, interaction(ds$subject, ds$activity), drop=TRUE)
  
  ## Apply the colMeans function across all the splits
  aveSet2 <- lapply(aveSet, function(x) { colMeans(x[, c(3:68) ] ) } )
  
  ## Loop through the splits and extract the subject and activity values from the split names
  iNames <- strsplit(names(aveSet2), "\\.")
  subList <- NULL
  actList <- NULL
  for(i in seq_along(iNames)) {
    ## Recover the subject and activity from the interaction name
    subject <- as.numeric(iNames[[i]][1]) 
    activity <- iNames[[i]][2]
    subList <- c(subList, subject)
    actList <- c(actList, activity)
  }
  
  ## Rebuild data.frame from the split set, first add the interactions (subject, activity)
  tds <- as.data.frame(subList)
  names(tds) <- c("subject")
  tds$activity <- factor(actList, levels=c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", 
                                            "SITTING", "STANDING", "LAYING"), ordered=TRUE)
  
  ## Recover the averages from aveSet2 (add them to tds2, row by row)
  rAve <- NULL
  for(i in seq_along(aveSet2)) {
    rAve <- rbind(rAve, as.numeric(aveSet2[[i]]))
  }
  ## Now cbind the interactions and the averages together
  tds <- cbind(tds, rAve)
  
  ## Fix up the names for the second tidy dataset
  tNames <- paste0("average-", names(ds[3:68]))
  names(tds) <- c("subject", "activity", tNames)
  
  ## return the resulting dataset
  tds
}

## This function checks to see that the download zip file exists in the
## working directory. Assuming that it is found, it unzips the file (it 
## would also delete the unzipped folder, if it is present)
validateInput <- function() {
  ## Erase the unzipped data directory and nested content, if it exists
  if (file.exists("./UCI HAR Dataset")) { 
    unlink("UCI HAR Dataset", recursive=TRUE)
  }
  
  ## Unzip the input file, if it exists
  if(file.exists("./UCI HAR Dataset.zip")) {
    unzip("./UCI HAR Dataset.zip")
  } else {
    stop("input datafile not found")
  }
}

##=======================================================
## This section represents the mainline processing of the initial files into
## The first tidy dataset.

## Validate that expected input files exists
validateInput()

## Read in the column names for the test and train datasets
cNames <- getColumnNames()

## Read in the activity names
aNames <- getActivityLabels()

## Now merge the two datasets, row-wise
mergedset <- processDatasets()

##=======================================================
## This section represents the mainline processing of the first file into
## the second tidy dataset.
tds2 <- processTDS2(mergedset)

## Write the tidy dataset out to disk
write.table(tds2, file="./tidyset2.txt", row.names=FALSE)
