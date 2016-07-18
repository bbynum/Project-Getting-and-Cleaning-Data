#Load packages
library(dplyr)

#Download files
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile= "/Users/bbynum/Downloads/Project_Data.zip", method="curl")
unzip(zipfile="/Users/bbynum/Downloads/Project_Data.zip")

#Read needed files
features <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/features.txt")
activity_labels <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/activity_labels.txt")
X_train <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/train/subject_train.txt")
X_test <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("/Users/bbynum/Downloads/UCI HAR Dataset/test/subject_test.txt")

#Combine training and test data
X_data <- rbind(X_train, X_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

#Select mean and standard deviation variables
index <- grep("mean|std", features$V2 , perl=TRUE, value=FALSE)
X_data_selection <- X_data[,index]

#Merge Data Sets
data_selection <- cbind(subject_data, y_data, X_data_selection)

#Tidy variable names
variable_names <- features[index,2]
variable_names <- gsub("^t", "Time", variable_names)
variable_names <- gsub("^f", "Frequency", variable_names)
variable_names <- gsub("\\(\\)", "", variable_names)
variable_names <- gsub("Acc", "Accelerometer", variable_names)
variable_names <- gsub("Gyro", "Gyroscope", variable_names)
variable_names <- gsub("Mag", "Magnitude", variable_names)
variable_names <- gsub("BodyBody", "Body", variable_names)
variable_names <- gsub("mean", "Mean", variable_names)
variable_names <- gsub("std", "SD", variable_names)
names(data_selection) <- c("Subject", "Activity", as.character(variable_names))

#Recode activity variable
data_selection$Activity <- factor(data_selection$Activity, 
                                  labels=tolower(activity_labels[,2]))

#Finalize First Tidy DataSet by Ordering Data by Subject and Activity
data_selection <- data_selection[order(data_selection$Subject, data_selection$Activity),]

#Generate Second Tidy DataSet with means by Subject and Activity
data_means <- aggregate(. ~Subject + Activity, data_selection, mean)

