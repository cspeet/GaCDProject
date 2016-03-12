---
title: "README.md"
output: github_document
---

## README.md - Explaining processing for tidyset2

The run_analysis.R code contains the R code necessary to process the **UCI HAR Dataset** in 
order to procude the tidyset2 data set.

The script assumes that you have the **UCI HAR Dataset.zip** file in your working directory.
If so, you can simply source the run_analysis.R script to start the necessary sequence of
instructions and to produce the desired output file.

The script works in essentially 2 phases:

### Phase 1 - Produce a merged dataset from the test and train sets in the **UCI HAR Dataset**

The script begins by validating the presence of the **UCI HAR Dataset.zip** file in your working
directory (it will also recursively remove an expanded version of the contents of the zip, if
found). If the file exists, it will be unzipped. If not, the script throws an error and stops.

Next, the script prepares a vector of column names that will be used in creation of the merged
data set in phase 1.

Similarly, the script prepares a vector of the activity labels from the input dataset. This
vector will be used to translate the activities from numeric codes to text descriptions, and
it will also be used as the basis for converting the activity columns from a character
variable to a ordered factor variable.

Finally, the first phase of the script reads in the test and train datasets and processes them
according to the following sequence of steps:

1. Reads in subject, activity, and quantitative measures from the test dataset.
2. Reads in subject, activity, and quantitative measures from the train dataset.
3. Merges the subject, activity, and dataset values, resulting in 3 parallel table structures.
4. Applies column names to the merged dataset (test/train quantitative measures).
5. Subsets the columns in the merged dataset down to only those containing mean and standard deviation values.
6. Adds the subject column into the merged dataset.
7. Translates the activity values from numeric codes to text descriptions.
8. Converts the text descriptions of activity values to vector of ordered factor values.
9. Adds the activity factor vector to the merged dataset.
10. Reorders the columns in the merged dataset so that subject and activity columns are the left-most columns.

At this point, the merged dataset is complete.

### Phase 2 - Produce tidyset2 from the merged dataset

The second phase of processing takes the merged dataset produced in phase 1 as input, and it 
produced the tidyset2 dataset according to the following sequence of steps:

1. Splits the merged dataset according to the interactions between subject and activity.
2. Calculates the average of every quantitative measure for each split set using the colMeans function (remember, phase 1 already sub-setted the 652 original quantitative variables down to 66 quantitative variables that were calculated mean or standard deviation measurements).
3. Recovers the subject and activity values from the split names for each interaction (there are 180 observations, according to the interactions - 30 subjects * 6 activities = 180 interactions).
4. Builds a data frame consisting of the subject variable.
5. Adds the activity column (reconstituted as an ordered factor with 6 levels to the data frame).
6. Recovers the average values from the split dataset, converting them from named num to numeric values along the way.
7. Binds the quantitative values to the data frame.
8. Sets the column names for the dataset, pre-pending "average-" to the 66 quantitative variables.
9. Returns tidyset2.

Finally, the resulting tidy dataset is saved to a text file named tidyset2.txt.

