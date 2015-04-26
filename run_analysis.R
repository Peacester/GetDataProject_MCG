# load required libraries
library(dplyr)
library(reshape2)

# read features (i.e. names of data measurements) and activity description key
features <- read.csv("./UCI HAR Dataset/features.txt", header=FALSE, sep=" ")

# read activity description key and place into single vector data frame for later use
activities <- read.csv("./UCI HAR Dataset/activity_labels.txt", header=FALSE, sep=" ")
activityDF <- data.frame("Activity"=as.vector(activities[,2]))

# read test data readings and subject and activity keys for data readings
testData <- read.table("./UCI HAR Dataset/test/X_test.txt", header=FALSE)
testSubject <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header=FALSE)
testActivity <- read.csv("./UCI HAR Dataset/test/y_test.txt", header=FALSE)

# label test data readings columns with features
colnames(testData) <- as.vector(features[,2])

# add column for activity using test activity key and activity description key
testData$activity <- activityDF$Activity[as.vector(testActivity[,1])]

# add column name to test subject key
colnames(testSubject) <- c("subject")

# join test data (with activity descriptions) and test subject key
testJoin <- cbind(testData, testSubject)

# repeat procedures for test data on training data  
trainData <- read.table("./UCI HAR Dataset/train/X_train.txt", header=FALSE)
trainSubject <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header=FALSE)
trainActivity <- read.csv("./UCI HAR Dataset/train/y_train.txt", header=FALSE)
colnames(trainData) <- as.vector(features[,2])
trainData$activity <- activityDF$Activity[as.vector(trainActivity[,1])]
colnames(trainSubject) <- c("subject")
trainJoin <- cbind(trainData, trainSubject)

# merge test data and training data
fullData <- rbind(testJoin, trainJoin)

# cleanse column names for select
clean_column_names <- make.names(names=names(fullData), unique=TRUE, allow_ = TRUE)
names(fullData) <- clean_column_names

# extract only data for means and standard deviations into a new data set
focusData <- select(fullData, subject, activity, contains("mean"), contains("std"))

# creat a final data set with the average of each data variable for each activity and each subject
finalData <- focusData %>% group_by(subject, activity) %>% summarise_each(funs(mean))

# create a txt file with the final data set
write.table(finalData, file="tidyData.txt", row.names=FALSE)

