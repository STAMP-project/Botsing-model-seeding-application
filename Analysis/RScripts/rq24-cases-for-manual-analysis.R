# R script
# 
# author: Pouria Derakhshanfar

library(ggplot2)
library(dplyr)

source('dataclean.r')
source('graphs.r')
source('tables.r')
Configs <-c("model s. 0.2", "model s. 0.5", "model s. 0.8", "model s. 1.0")

noseeding <- getNoSeedingResults()
modelseeding <- getModelSeedingResults()

# Restrict to frames that are in both test and no seeding 
results <- modelseeding %>%
  bind_rows(noseeding %>%
              filter(case_frame %in% modelseeding$case_frame))

# Search initialization
writeDifferingCrashesInStarting(results,configs)
# Crash reproduction
reproduction <- getReproduceStatus(results)
writeDifferingCrashes(reproduction,configs,"reproduced")

# ff evals
ffEvals <- getFFEvals(results)
writeffEvalsInterestingCases(ffEvals,Configs)