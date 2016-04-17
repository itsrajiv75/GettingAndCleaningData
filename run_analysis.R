## R script - run_analysis.R 

## Packages "data.table" and "reshape2" already installed
library("data.table")
library("reshape2")

## Zip file from location "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## already downloaded and extracted under working directory

# Activity labels extracted from activity_labels.txt file
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Data column names extracted from features.txt file
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extractFeatures <- grepl("mean\\(\\)|std\\(\\)", features)

# Extract X_test, y_test and subject_test data.
XTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Define column names for X_test data
names(XTest) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
XTest = XTest[,extractFeatures]

# Define column names for y_test and subject_test data
yTest[,2] = activityLabels[yTest[,1]]
names(yTest) = c("ActivityID", "ActivityLabel")
names(subjectTest) = "Subject"

# Column bind test data
testData <- cbind(as.data.table(subjectTest), yTest, XTest)

# Extract X_train, y_train and subject_train data.
XTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Define column names for X_train data
names(XTrain) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
XTrain = XTrain[,extractFeatures]

# Define column names for y_train and subject_train data
yTrain[,2] = activityLabels[yTrain[,1]]
names(yTrain) = c("ActivityID", "ActivityLabel")
names(subjectTrain) = "Subject"

# Column bind train data
trainData <- cbind(as.data.table(subjectTrain), yTrain, XTrain)

# Row bind test and train data
mergedData = rbind(testData, trainData)

# Create tidy data set
idLabels   = c("Subject", "ActivityID", "ActivityLabel")
dataLabels = setdiff(colnames(mergedData), idLabels)
meltedData   = melt(mergedData, id = idLabels, measure.vars = dataLabels)
tidyData   = dcast(meltedData, Subject + ActivityLabel ~ variable, mean)

# Output - Tidy data set as a txt file created with write.table() using row.name=FALSE
write.table(tidyData, file = "./tidyData.txt", row.names = FALSE)