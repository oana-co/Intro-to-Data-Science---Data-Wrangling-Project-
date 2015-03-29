# Data for the project was downloaded on 3-28-2015 from:
# 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# with the documentations from: 
# 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#  

#libraries loaded

library(dplyr)
library(tidyr)
library(data.table)

# Load the subject factors

trainS<-read.table('UCI HAR Dataset/train/subject_train.txt',col.names="subject")
testS<-read.table('UCI HAR Dataset/test/subject_test.txt',col.names="subject")

# Check to make sure there is no overlap

table(trainS)
table(testS)

features<-read.table('UCI HAR Dataset/features.txt',col.names=c("row","feature"))
activity<-read.table('UCI HAR Dataset/activity_labels.txt',col.names=c("activity_label","activity"))

#load X data

trainX<-tbl_df(read.table('UCI HAR Dataset/train/X_train.txt',col.names=features$feature))
testX<-tbl_df(read.table('UCI HAR Dataset/test/X_test.txt',col.names=features$feature))

# Remove all unwanted columns - 
#"Extracts only the measurements on the mean and standard deviation for each measurement."
# The measurements use "mean" and "std" to identify these operations. There is also names with 
# meanFreq which we will remove.

testX<-select(testX,c(contains("mean"),contains("std")))
testX<-select(testX, -contains("meanFreq"))

trainX<-select(trainX,c(contains("mean"),contains("std")))
trainX<-select(trainX, -contains("meanFreq"))

# Load Y data

trainy<-read.table('UCI HAR Dataset/train/y_train.txt',col.names="activity_label")

testy<- read.table('UCI HAR Dataset/test/y_test.txt',col.names="activity_label")

# Add descriptive activity test

trainy<-dplyr::left_join(trainy,activity,by="activity_label")
testy<-dplyr::left_join(testy,activity,by="activity_label")

# Add subject, activity columns to data

train<-cbind(trainS,trainy,trainX)

test<-cbind(testS,testy,testX)

# Add a factor the designates whics data set each row came from before merging the data

train<-dplyr::mutate(train,source="train")

test<-dplyr::mutate(test,source="test")

# Merge data all data 

all_data<-rbind(test,train)

# Convert a few columns to factor 

all_data$subject <-as.factor(all_data$subject)
all_data$activity <-as.factor(all_data$activity)
all_data$source <-as.factor(all_data$source)


# all_data is a short-wide tidy data set for all activities and subjects.

# Remove the activity_label column as it is redundent with activity.

all_data$activity_label<-NULL

# Remove the source column

all_data$source <- NULL 

# Calulate the summary statistics

summary <- summarise_each(group_by(all_data,subject,activity),funs(mean,sd))


# Convert this to a tidy tall-skinny set with each row correspondig to asingle oberservat

tall_skiny_summary<-gather(summary, Measure , value,tBodyAcc.mean...X_mean:fBodyBodyGyroJerkMag.std.._sd)

write.table(tall_skiny_summary,file="tall_skiny_summary.txt",row.name=FALSE)