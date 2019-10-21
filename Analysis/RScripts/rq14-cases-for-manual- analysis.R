# R script
# 
# author: Pouria Derakhshanfar

library(ggplot2)
library(dplyr)

source('dataclean.r')
source('graphs.r')
source('tables.r')
Configs<- c("test s. 0.2", "test s. 0.5", "test s. 0.8", "test s. 1.0")
noseeding <- getNoSeedingResults()
testseeding <- getTestSeedingResults()

# Restrict to frames that are in both test and no seeding 
results <- testseeding %>%
  bind_rows(noseeding %>%
              filter(case_frame %in% testseeding$case_frame))

# Search initialization
writeDifferingCrashesInStarting(results,configs)
# Crash reproduction
reproduction <- getReproduceStatus(results)
writeDifferingCrashes(reproduction,configs,"reproduced")

# ff evals
ffEvals <- getFFEvals(results)
writeffEvalsInterestingCases(ffEvals,Configs)