#Author: Hai Ton
#Date: 8/17/2014
#Purpose: Merge test and actual data set collected from sample smartphone devices.
#Data set source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#Data set descripton: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#Please refer to codebook and README for more information.
#References:
#text processing: http://en.wikibooks.org/wiki/R_Programming/Text_Processing
#join in R: http://www.dummies.com/how-to/content/how-to-use-the-merge-function-with-data-sets-in-r.html
#project guideline from TA, David Hood: https://class.coursera.org/getdata-006/forum/list?forum_id=10009

#set working directory
setwd("C:/Self_Dev/coursera_classes/Get_and_cleaning_data/project/data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset")

#step 1: download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#step 2: extract the data zip file
#step 3: read the README.txt in the data zip file.
#        read data set description http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#        read project requirement on course webpage


####################################
#step 4: load data sets into memory#
####################################
#step 4a: load possible activities into memory
#this dataset links the class labels with their activity name
activity <- read.table("activity_labels.txt", header=FALSE, stringsAsFactors=FALSE)
#rename columns
colnames(activity)[1] = "ActivityId"
colnames(activity)[2] = "Activity"

head(activity, n=10); str(activity); names(activity); nrow(activity); dim(activity)
class(activity)

#step 4b: load features into memory
#features or functions that use to measure the activities
#each row of this represent a column in x_test.txt or X_train.txt 
features <- read.table("features.txt", header=FALSE, stringsAsFactors=FALSE)
#change column names
colnames(features)[1] <- "FeatureId"
colnames(features)[2] <- "Feature"
head(features, n=3); str(features); names(features); dim(features); class(features)

#step 4b: load activity labels into memory
#each row represent an activity in the X_test.txt or X_train.txt
#use the activity_labels.txt to get the descriptive label
testActivityLabels <- read.table("./test/y_test.txt", header=FALSE, stringsAsFactors=FALSE)
trainActivityLabels <- read.table("./train/y_train.txt", header=FALSE, stringsAsFactors=FALSE)
 #change column name
colnames(testActivityLabels)[1] <- "ActivityId"
colnames(trainActivityLabels)[1] <- "ActivityId"

head(testActivityLabels, n=3); str(testActivityLabels); names(testActivityLabels); 
dim(testActivityLabels); class(testActivityLabels)
dim(trainActivityLabels); 

#step 4c: load  subject id into memory
#each row in this data set is linked to a row in the X_test.txt or X_train.txt
testSubject <- read.table("./test/subject_test.txt", header=FALSE,  stringsAsFactors=FALSE)
trainSubject <- read.table("./train/subject_train.txt", header=FALSE,  stringsAsFactors=FALSE)
 #change the column name for subject in the merged data set
colnames(testSubject)[1] = "SubjectId"
colnames(trainSubject)[1] = "SubjectId"

head(testSubject, n=3); str(testSubject); names(testSubject); class(testSubject)
dim(testSubject); dim(trainSubject)

#step 4d: load data into memory
#Notice: there are 561 columns, same as number of rows in the features dataset, 
#        thus each column represent a feature in the features dataset.
testData<- read.table("./test/X_test.txt", header=FALSE, stringsAsFactors=FALSE)
trainData<- read.table("./train/X_train.txt", header=FALSE, stringsAsFactors=FALSE)
head(testData, n=1); str(testData); names(testData);  
dim(testData); dim(trainData)


#step 5: Data explaration.
#After data exploration, here're what I concluded:
# there're 2947 rows in the X_test.txt, y_test.txt, and subject_test.txt
# and 7352 rows in the X_train.txt, y_train.txt, and subject_train.txt

##################################################################
############ Data Merging ########################################
##################################################################

#step 6: combine the data set on features.txt with X_test.text
#       and features.txt with X_train.txt
# pivot all rows in features.txt to columns and these are the labels for
# column V1 to V561 in the X_test.txt and Y_train.txt

featureCount <- nrow(features) #count for loop limit
i <- featureCount #position counter for loop

repeat{
  colnames(testData)[i] <- features[i, "Feature"]
  colnames(trainData)[i] <- features[i, "Feature"]
  
  i <- i - 1 #decrement position counter
  if (i <= 0){#exit loop when no more feature to process
    break
  }
}

#check result
names(testData); names(trainData)
dim(testData); dim(trainData)

#step 7:
#merge activity_labels.txt and y_test.txt; activity_labels.txt and y_train.txt to get the activity name
#Inner join
#make sure to keep the original row order
# reference: http://stackoverflow.com/questions/17878048/r-merging-two-data-frames-while-keeping-the-original-row-order
# user plyr join() to retain the original order of the rows.
# Note: #merge() won't retain the original row order.
library(plyr)
testActivity <- join(testActivityLabels, activity, by="ActivityId")
trainActivity <- join(trainActivityLabels, activity, by="ActivityId")

#testActivity <- merge(testActivityLabels, activity
#                        , by.x="ActivityId", by.y="ActivityId"
#                        , all=FALSE, sort=FALSE)
head(testActivity, n=33); head(trainActivity, n=29);
tail(testActivity, n=3); tail(trainActivity, n=3); str(testActivity); 
names(testActivity); dim(testActivity)
table(testActivity$Activity) #count how many occurences per activity
dim(testActivity); dim(trainActivity);


#step 8: combine the data sets above with activity labels
#the merged data set at this step should include the following:
#  activity, subjectId, and the data in the X_test.txt
# the data set structure should be like below.
# Test data:  2947 rows and 563 columns.
# Train data: 7352 rows and 563 columns.
# ActivityId  Activity tBodyAcc-mean()-Y  ...  angle(Z,gravityMean)
#     5      STANDING    0.2571778        ...    -0.057978304
#     5      STANDING     .2860267        ...    -0.083898014
testMerged1 <- cbind(testActivity, testData)
trainMerged1 <- cbind(trainActivity, trainData)
head(testMerged1, n=1); testMerged1[1:33, c(1:4, 564)]; tail(testMerged1); str(testMerged1); 
names(testMerged1); names(trainMerged1); dim(testMerged1); dim(trainMerged1)

#step 9: combine subject_test.txt to testMerged and trainMerged data set on step 8.
# the data set structure should be like below.
# Test data:  2947 rows and 564 columns.
# Train data: 7352 rows and 564 columns.
# SubjectId ActivityId  Activity  tBodyAcc-mean()-Y  ...  angle(Z,gravityMean)
#     2       5         STANDING    0.2571778        ...    -0.057978304
#     2       5         STANDING     .2860267        ...    -0.083898014
testMerged2 <- cbind(testSubject, testMerged1)
trainMerged2 <- cbind(trainSubject, trainMerged1)
head(testMerged2, n=1); tail(testMerged2, n=3); str(testMerged2); 
names(testMerged2); names(trainMerged2); 
dim(testMerged2); dim(trainMerged2)

#step 10: combine merged test and train data set
# There'll be 10299 rows and 564 columns
testTrainMerged <- rbind(testMerged2, trainMerged2)
names(testTrainMerged);
dim(testTrainMerged); 

#step 11: only extract mean and standard devidation for each measurement(observation/row)
#use regular expression to search for all feature for mean and standard deviation
# There'll be 10299 rows and 79 columns(variables)
meanStdLogical <- grepl("mean()|meanFreq()|std()", colnames(testTrainMerged)) #79 columns with mean or standard deviation
testTrainMerged2 <- testTrainMerged[, meanStdLogical]
names(testTrainMerged2); str(testTrainMerged2); class(testTrainMerged2)
dim(testTrainMerged2)

#step 11: rename the data set columns by remove (), commas and hyphen
#reference: https://class.coursera.org/getdata-006/forum/thread?thread_id=132
#example: 
#         oldName                     newName
#   tBodyAcc-mean()-X             tBodyAccMeanX
#   tGravityAcc-std()-Z           tGravityAccStdZ
#   fBodyBodyGyroMag-meanFreq()   fBodyBodyGyroMagMeanFreq
oldVariableNames <- colnames(testTrainMerged2);
oldVariableNames
newVariableNames <- gsub("[()]|-|,","", oldVariableNames)#remove (), commas and hyphen
newVariableNames <- gsub("mean","Mean", newVariableNames)#capitalize first letter of mean
newVariableNames <- gsub("std","Std", newVariableNames)#captitalize first letter of std
newVariableNames



#step 12: Creates a second, independent tidy data set with the average 
#of each variable for each activity and each subject.




