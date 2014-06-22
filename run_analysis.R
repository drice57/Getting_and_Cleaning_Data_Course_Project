## R script for Getting and Cleaning Data course project

## Install (as needed) and load data.table package
## install.packages("data.table")
library(data.table)

## Read data files, which were downloaded and unzipped
## into the "UCI HAR Dataset" folder in the working directory

## Read column labels (variables and statistics calculated on them)
measure_labels <- read.table("UCI HAR Dataset/features.txt")

## Read cleaned up column labels (done with Excel, see separate notes)
column_labels <- read.table("UCI HAR Dataset/columns.txt")

## Read "test" and "train" datasets, add cleaned up column labels

test <- read.table("UCI HAR Dataset/test/X_test.txt")
ntest <- dim(test)[1] ## number of rows/observations
names(test) <- column_labels[,2]
test <- cbind(1:ntest,"test",test)  ## prepend sequence number and source columns
temp <- names(test)  ## update column labels for additional columns
temp[1] <- "sequence"
temp[2] <- "source"
names(test) <- temp

train <- read.table("UCI HAR Dataset/train/X_train.txt")
ntrain <- dim(train)[1] ## number of rows/observations
names(train) <- column_labels[,2]
train <- cbind(1:ntrain,"train",train)  ## prepend sequence number and source columns
temp <- names(train)  ## update column labels for additional columns
temp[1] <- "sequence"
temp[2] <- "source"
names(train) <- temp

## Read subject number vectors for test and train data

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_test <- cbind(1:ntest, subject_test)  ## prepend sequence column for later sort/merge
names(subject_test) <- c("sequence","subject")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_train <- cbind(1:ntrain, subject_train)  ## prepend sequence column for later sort/merge
names(subject_train) <- c("sequence","subject")

## Read activity number vectors for test and train data, and activity labels

activity_test <- read.table("UCI HAR Dataset/test/y_test.txt")
activity_test <- cbind(1:ntest, activity_test)  ## prepend sequence column for later sort/merge

activity_train <- read.table("UCI HAR Dataset/train/y_train.txt")
activity_train <- cbind(1:ntrain, activity_train)  ## prepend sequence column for later sort/merge

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

## Merge activity labels into codes, and apply to activity_test and _train

names(activity_labels) <- c("activity_code","activity_name")
names(activity_test) <- c("sequence","activity_code")
activity_test <- merge(activity_test,activity_labels,sort=FALSE)
names(activity_train) <- c("sequence","activity_code")
activity_train <- merge(activity_train,activity_labels,sort=FALSE)

## Append source (test or train), subject and actvity columns to left of data

test <- merge(test,activity_test,sort=FALSE)
test <- merge(test,subject_test,sort=FALSE)
train <- merge(train,activity_train,sort=FALSE)
train <- merge(train,subject_train,sort=FALSE)

## Combine test and train tables, save to folder
combined <- rbind(test,train)
write.table(combined,"combined.txt")

## Identify columns with "mean" or "standardDeveiation", plus ID columns
subset <- grep("mean_of|standardDeviation_of|sequence|source|activity_code|activity_name|subject", names(combined))

## Subset the combined test/train table to retain only the columns with mean/standard deviation
combined_subset <- combined[,subset]
write.table(combined_subset,"combined_subset.txt")

## Calculate sums and stds of all columns, aggregated by subject and activity

combined_means <- data.table(combined)

combined_means <- aggregate(combined_means,by=list(combined_means$subject,combined_means$activity_name),FUN=mean)
keep <- c(1:2,5:565)
combined_means <- combined_means[,keep]  ## Delete extraneous columns
combined_means <- cbind("mean",combined_means)
temp <- names(combined_means)
temp[1] <- "statistic"
temp[2] <- "subject"
temp[3] <- "activity"
names(combined_means) <- temp

write.table(combined_means,"combined_means.txt")
