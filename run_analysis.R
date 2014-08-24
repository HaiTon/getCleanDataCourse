#Author: Hai Ton
#Date: 8/17/2014
#Purpose: Merge test and actual data set collected from sample samsung smartphone devices.
#Data set source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#Data set description: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#Please refer to codebook and README for more information.
#Note: The script includes step by step of how the data is merged and output.
#      This some functions like name, str, class, dim seem redundant, but I include them
#        along with each step. This is mainly for learning purpose.
#References:
#text processing: http://en.wikibooks.org/wiki/R_Programming/Text_Processing
#join in R: http://www.dummies.com/how-to/content/how-to-use-the-merge-function-with-data-sets-in-r.html
#project guideline from TA, David Hood: https://class.coursera.org/getdata-006/forum/list?forum_id=10009
#Tidy Data from Hadly Wickham: http://vita.had.co.nz/papers/tidy-data.pdf


#load packages
install.packages("plyr")
install.packages("dplyr")
install.packages("reshape2")
library(dplyr)
library(plyr)
library(reshape2)


#set working directory
setwd("C:/Self_Dev/coursera_classes/Get_and_cleaning_data/project/data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset")

#step 1: download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#step 2: extract the data zip file
#step 3: read the README.txt in the data zip file.
#        read data set description http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#        read project requirement on course webpage


##########################################
#  step 4: load data sets into memory. ###
##########################################
#step 4a: load possible activities into memory
#this dataset links the class labels with their activity name
activity <- read.table("activity_labels.txt", header=FALSE, stringsAsFactors=FALSE)
#rename columns
colnames(activity)[1] = "ActivityId"
colnames(activity)[2] = "Activity"

#check result
head(activity, n=10); str(activity); names(activity); nrow(activity); dim(activity)
class(activity)

#step 4b: load features into memory
#features or functions that use to measure the activities
#each row of this represent a column in x_test.txt or X_train.txt 
features <- read.table("features.txt", header=FALSE, stringsAsFactors=FALSE)
#change column names
colnames(features)[1] <- "FeatureId"
colnames(features)[2] <- "Feature"
#check result
head(features, n=3); str(features); names(features); dim(features); class(features)

#step 4c: load activity labels into memory
#each row represent an activity in the X_test.txt or X_train.txt
#use the activity_labels.txt to get the descriptive label
testActivityLabels <- read.table("./test/y_test.txt", header=FALSE, stringsAsFactors=FALSE)
trainActivityLabels <- read.table("./train/y_train.txt", header=FALSE, stringsAsFactors=FALSE)
 #change column name
colnames(testActivityLabels)[1] <- "ActivityId"
colnames(trainActivityLabels)[1] <- "ActivityId"

#check result
head(testActivityLabels, n=3); str(testActivityLabels); names(testActivityLabels); 
dim(testActivityLabels); class(testActivityLabels)
dim(trainActivityLabels); 

#step 4d: load  subject id into memory
#each row in this data set is linked to a row in the X_test.txt or X_train.txt
testSubject <- read.table("./test/subject_test.txt", header=FALSE,  stringsAsFactors=FALSE)
trainSubject <- read.table("./train/subject_train.txt", header=FALSE,  stringsAsFactors=FALSE)
 #change the column name for subject in the merged data set
colnames(testSubject)[1] = "SubjectId"
colnames(trainSubject)[1] = "SubjectId"

#check result
head(testSubject, n=3); str(testSubject); names(testSubject); class(testSubject)
dim(testSubject); dim(trainSubject)

#step 4e: load data into memory
#Notice: there are 561 columns, same as number of rows in the features dataset, 
#        thus each column represent a feature in the features dataset.
testData<- read.table("./test/X_test.txt", header=FALSE, stringsAsFactors=FALSE)
trainData<- read.table("./train/X_train.txt", header=FALSE, stringsAsFactors=FALSE)
#check result
head(testData, n=1); str(testData); names(testData);  
dim(testData); dim(trainData)


#step 5: Data explaration.
#After data exploration, here're what I concluded:
# there're 2947 rows in the X_test.txt, y_test.txt, and subject_test.txt
# and 7352 rows in the X_train.txt, y_train.txt, and subject_train.txt

##################################################################
################ Data Merging ####################################
##################################################################

#step 6: combine the data set on features.txt with X_test.txt
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
testActivity <- join(testActivityLabels, activity, by="ActivityId")
trainActivity <- join(trainActivityLabels, activity, by="ActivityId")

#check result
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
#check result
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
#check result
head(testMerged2, n=1); tail(testMerged2, n=3); str(testMerged2); 
names(testMerged2); names(trainMerged2); 
dim(testMerged2); dim(trainMerged2)

#step 10: combine merged test and train data set
# There'll be 10299 rows and 564 columns
testTrainMerged <- rbind(testMerged2, trainMerged2);
#check result
names(testTrainMerged);
dim(testTrainMerged); 

#step 11: only extract mean and standard devidation for each measurement(observation/row)
#use regular expression to search for all feature for mean and standard deviation
# There'll be 10299 rows and 82 columns(variables)
meanStdLogical <- grepl("mean()|meanFreq()|std()", colnames(testTrainMerged)); #79 columns with mean or standard deviation
testTrainMerged2 <- cbind(testTrainMerged[, c("SubjectId", "ActivityId", "Activity")]
                          , testTrainMerged[, meanStdLogical]);
#check result
head(testTrainMerged2, n=1)
names(testTrainMerged2); str(testTrainMerged2); class(testTrainMerged2)
dim(testTrainMerged2)

#step 12: Appropriately labels the data set with descriptive variable names.
#Note: since this data set has 82 columns(variables), I don't want to make the names any longer.
# I just rename the data set columns by remove (), commas and hyphen. 
# The codebook file on this github repo contain more detailed variables description.
#reference: https://class.coursera.org/getdata-006/forum/thread?thread_id=132
#example: 
#         oldName                     newName
#   tBodyAcc-mean()-X             tBodyAccMeanX
#   tGravityAcc-std()-Z           tGravityAccStdZ
#   fBodyBodyGyroMag-meanFreq()   fBodyBodyGyroMagMeanFreq
oldVariableNames <- colnames(testTrainMerged2);
oldVariableNames; oldVariableNames[1]; class(oldVariableNames)
newVariableNames <- gsub("[()]|-|,","", oldVariableNames)#remove (), commas and hyphen
newVariableNames <- gsub("mean","Mean", newVariableNames)#capitalize first letter of mean
newVariableNames <- gsub("std","Std", newVariableNames)#captitalize first letter of std

#check result
newVariableNames[1]; class(newVariableNames);

#update merged data set columns
variableCount <- ncol(testTrainMerged2) #count for loop limit
i <- variableCount #position counter for loop

repeat{
  colnames(testTrainMerged2)[i] <- newVariableNames[i]
  
  i <- i - 1 #decrement position counter
  if (i <= 0){#exit loop when no more feature to process
    break
  }
}

#check result
names(testTrainMerged2); dim(testTrainMerged2); str(testTrainMerged2)

##################################################################
################ Compute Averages #################################
##################################################################
#step 13: Creates a second, independent tidy data set with the average 
#of each variable for each activity and each subject.

#use melt() of reshape2 package to melt the data set into one skinny long data set.
#note: id columns is the group by column.
# And if measure parameter is left blank, melt() will use all non-id columns for measure
#The result is should be 180 rows (30 subject * 6 activities)
testTrainMelt <- melt(testTrainMerged2, id=c("SubjectId", "ActivityId" ,"Activity"))
dim(testTrainMelt); class(testTrainMelt)
#cast the melt data set into a data frame and apply the mean function to each measure 
testTrainMergedAverages <- dcast(testTrainMelt, SubjectId + Activity ~ variable, mean)

#check result
names(testTrainMergedAverages); 
str(testTrainMergedAverages); 
dim(testTrainMergedAverages);
class(testTrainMergedAverages);
testTrainMergedAverages[1:50,1:5]

#output to file and upload to course webpage
write.csv(testTrainMergedAverages, file = 'C:/Self_Dev/coursera_classes/Get_and_cleaning_data/project/getCleanDataCourseRepo/testTrainMergedAverages.txt')

#########################   End of Script #################################################

