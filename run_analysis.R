# 0. Getting data

# 0.1. Download data
myfile <- "getdata-projectfiles-UCI HAR Dataset.zip"
if (!file.exists(myfile)){
  URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(URL, myfile, method="curl")}  
unzip(myfile) 

# 0.2. Unzipped data in folder "UCI HAR Dataset"
path <- file.path("UCI HAR Dataset")
files<-list.files(path)
files

# 0.3. Reading files
# 0.3.1. Activity files
Activity_Test  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
Activity_Train <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
# 0.3.2. Subject files
Subject_Test  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
Subject_Train <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
# 0.3.3. Features files
Features_Train <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)
Features_Test  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)

# 1. Merges the training and the test sets to create one data set
Subject <- rbind(Subject_Train, Subject_Test)
Activity<- rbind(Activity_Train, Activity_Test)
Features<- rbind(Features_Train, Features_Test)
FeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2
names(Subject)<-c("Subject")
names(Activity)<- c("Activity")
Data = cbind(Subject, Activity, Features);
View(Data)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement
# 2.1.Creating a subset from "mean" and "st-deviation" using logical vector
which_one<-grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)
features_selected<-FeaturesNames$V2[which_one]
# 2.2. Extracted data
filter<-c("Subject", "Activity", as.character(features_selected))
result<-subset(Data, select=filter)
View(result)

# 3. Uses descriptive activity names to name the activities in the data set
Activity_labels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE, col.names = c("Activity", "Activity"))
finalData= merge(result,Activity_labels,by='Activity',all.x=TRUE);
finalData<-finalData[,-1]
View(finalData)

# 4. Appropriately labels the data set with descriptive names
names(finalData)
names(finalData)<-gsub('\\(|\\)',"",names(finalData), perl = TRUE)
names(finalData)<-gsub("^t", "time", names(finalData))
names(finalData)<-gsub("^f", "frequency", names(finalData))
names(finalData)<-gsub("Acc", "Accelerometer", names(finalData))
names(finalData)<-gsub("Gyro", "Gyroscope", names(finalData))
names(finalData)<-gsub("Mag", "Magnitude", names(finalData))
names(finalData)<-gsub("BodyBody", "Body", names(finalData))
names(finalData) <- gsub('\\.mean',".Mean",names(finalData))
names(finalData) <- gsub('\\.std',".StandardDeviation",names(finalData))
names(finalData)<-gsub("Activity.1", "Activity", names(finalData))
colnames(finalData) = colNames
names(finalData)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
library(plyr);
newData<-aggregate(. ~Subject + Activity, finalData, mean)
newData<-newData[order(newData$Subject,newData$Activity),]
write.table(newData, file = "tidydataset.txt",row.name=FALSE)