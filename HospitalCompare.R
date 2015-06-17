library(dplyr)

setwd("~/DataScience/datasciencecoursera/CMS-HospitalCompare/Hospital_Revised_Flatfiles")

# Read the Structural Measures file

sm <- read.csv("Structural Measures - Hospital.csv", colClasses="character")

# Clean up the table and make the measure response variable as a logical variable

sm$Measure.Response <- sub("^Y$","TRUE",sm$Measure.Response)
sm$Measure.Response <- sub("^Yes$","TRUE",sm$Measure.Response)
sm$Measure.Response <- sub("^N$","FALSE",sm$Measure.Response)
sm$Measure.Response <- sub("^No$","FALSE",sm$Measure.Response)
sm$Measure.Response <- sub("^Not Available$","NA",sm$Measure.Response)
sm$Measure.Response <- sub("^D.*$","NA",sm$Measure.Response)
sm$Measure.Response <- as.logical(sm$Measure.Response)
sm <- tbl_df(sm)

#Read the Hospital General Information File

hgi <- read.csv("Hospital General Information.csv", colClasses="character")
hgi <- tbl_df(hgi)

#Read the Timely and Effective Care File

tec <- read.csv("Timely and Effective Care - Hospital.csv", colClasses="character")
tec <- tbl_df(tec)

# Read the Readmissions, Complications and Deaths file

readmit <- read.csv("Readmissions Complications and Deaths - Hospital.csv",
                    colClasses = "character")
readmit <- tbl_df(readmit)

# Shed the duplicate columns
subset.sm  <- select(sm,
                     Provider.ID, 
                     State, 
                     City, 
                     County.Name, 
                     Measure.ID, 
                     Measure.Response)

subset.hgi <- select(hgi, 
                     Provider.ID, 
                     Hospital.Name)

subset.tec <- select(tec, 
                     Provider.ID, 
                     Condition, 
                     Measure.ID, 
                     Measure.Name, 
                     Score, 
                     Sample, 
                     Footnote)

subset.readmit <- select(readmit,
                         Provider.ID,
                         Measure.Name,
                         Measure.ID,
                         Denominator,
                         Score,
                         Lower.Estimate,
                         Higher.Estimate,
                         Compared.to.National)

# Find the hospitals whose performance is less than national average

low.rank <- subset.readmit[subset.readmit$Compared.to.National == 
                           "Worse than the National Rate",]

hf.low.rank <- low.rank[low.rank$Measure.ID == "MORT_30_HF",]
hf.subset.tec <- subset.tec[subset.tec$Condition == "Heart Failure",]
hf.stats <- merge(hf.low.rank, hf.subset.tec, by="Provider.ID")
