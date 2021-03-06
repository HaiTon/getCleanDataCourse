



##Purpose:
Below is the logic and steps of how the run_analysis.R script works. The run_analysis.R merges test and actual people's activity data set collected from Samsung smartphone devices.

##Data set source:
   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip    
Data set description: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
Please refer to codebook and README for more information.  
Note: The script includes step by step of how the data is merged and output.
      Some functions like name, str, class, dim seem redundant, but I include them
        along with each step. This is mainly for learning purpose.
##References:
text processing: http://en.wikibooks.org/wiki/R_Programming/Text_Processing  
join in R: http://www.dummies.com/how-to/content/how-to-use-the-merge-function-with-data-sets-in-r.html  
project guideline from TA, David Hood: https://class.coursera.org/getdata-006/forum/list?forum_id=10009  
Tidy Data from Hadly Wickham: http://vita.had.co.nz/papers/tidy-data.pdf  

##The Files will be merged into a final tidy data set:
 1. features.txt:      List of all features.
 2. activity_labels.txt: Links the class labels with their activity name.
 3. test/X_test.txt:   Test set.
 4. test/y_test.txt:   Test labels.
 5. train/X_train.txt: Training set.
 6. train/y_train.txt: Training labels.
 7. train/subject_test.txt and test/subject_train.txt: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

##Assumptions: 
  We'll ignore files in the Inertial folders.

##Detailed Instructions:

step 1: download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip   
step 2: extract the data zip file  
step 3: read the README.txt in the data zip file.  
        read data set description http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  
        read project requirement on course webpage  

###Load data sets into memory.    
step 4a: load possible activities.  
step 4b: load features.  
step 4c: load activity labels.  
step 4d: load  subject id.  
step 4e: load test and train data.

**Step 5: Data exploration.**   
After data exploration, here're what I concluded:   
 there're 2947 rows in the X_test.txt, y_test.txt, and subject_test.txt  
 and 7352 rows in the X_train.txt, y_train.txt, and subject_train.txt  

###Data Merging   
**Step 6: combine the data set on features.txt with X_test.txt and features.txt with X_train.txt**    
 Pivot all rows in features.txt to columns and these are the labels for column V1 to V561 in the X_test.txt and Y_train.txt    

**Step 7:Merge activity_labels.txt and y_test.txt; activity_labels.txt and y_train.txt to get the activity name.**   
This is an inner join.  
Make sure to keep the original row order     
 reference: http://stackoverflow.com/questions/17878048/r-merging-two-data-frames-while-keeping-the-original-row-order   
 user plyr join() to retain the original order of the rows.    
 Note: merge() won't retain the original row order.    

**Step 8: Combine the data sets above with activity labels.**  
the merged data set at this step should include the following:  
  activity, subjectId, and the data in the X_test.txt  
 the data set structure should be like below.  
 Test data:  2947 rows and 563 columns.  
 Train data: 7352 rows and 563 columns.  
ActivityId&nbsp;&nbsp;Activity&nbsp;&nbsp;&nbsp;tBodyAcc-mean()-Y&nbsp;  ...&nbsp;&nbsp;  angle(Z,gravityMean)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5 &nbsp;&nbsp;&nbsp;&nbsp;STANDING &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  0.2571778&nbsp;   ...&nbsp;&nbsp;    -0.057978304  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 5 &nbsp; &nbsp;&nbsp;&nbsp;STANDING &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  0.2860267&nbsp;   ...&nbsp;&nbsp;    -0.083898014  

**Step 9: combine subject_test.txt to testMerged and trainMerged data set on step 8.**   
 the data set structure should be like below.  
 Test data:  2947 rows and 564 columns.  
 Train data: 7352 rows and 564 columns.  
 SubjectId&nbsp;&nbsp;&nbsp;&nbsp; ActivityId &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Activity  &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;tBodyAcc-mean()-Y&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ... angle(Z,gravityMean)  
  &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; STANDING&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.2571778 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ... &nbsp;&nbsp;&nbsp; -0.057978304  
  &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;STANDING&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; 0.2860267 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;... &nbsp;&nbsp;&nbsp;-0.083898014 
 
**Step 10: combine merged test and train data set.**    
 There'll be 10299 rows and 564 columns  

**Step 11: only extract mean and standard devidation for each measurement(observation/row).**  
use regular expression to search for all feature for mean and standard deviation.  
 There'll be 10299 rows and 82 columns(variables)  

**Step 12: Appropriately labels the data set with descriptive variable names.**      
Note: since this data set has 82 columns(variables), I don't want to make the names any longer.  
 I just rename the data set columns by remove (), commas and hyphen.   
 The codebook file on this github repo contain more detailed variables description.  
reference: https://class.coursera.org/getdata-006/forum/thread?thread_id=132  
example:   
...........oldName...................................newName  
tBodyAcc-mean()-X......................tBodyAccMeanX  
tGravityAcc-std()-Z........................tGravityAccStdZ   
fBodyBodyGyroMag-meanFreq()........fBodyBodyGyroMagMeanFreq   

###Compute Averages   
**Step 13: Creates a second, independent tidy data set with the averageof each variable for each activity and each subject.**  
Use melt() of reshape2 package to melt the data set into one skinny long data set.  
Note: id columns is the group by column.  
 And if measure parameter is left blank, melt() will use all non-id columns for measure  
The result is should be 180 rows (30 subject * 6 activities)  
cast the melt data set into a data frame and apply the mean function to each measure    

**Step 14: output to file and upload to course webpage.**   
Note: do not include row name in the file.
