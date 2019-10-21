# R script
# 
# author: Xavier Devroey

library(ggplot2)
library(dplyr)

source('dataclean.r')
source('graphs.r')
source('tables.r')

noseeding <- getNoSeedingResults()
testseeding <- getTestSeedingResults()

# Restrict to frames that are in both test and no seeding 
results <- testseeding %>%
  bind_rows(noseeding %>%
              filter(case_frame %in% testseeding$case_frame))

outputFile <- "rq12-ff-evals-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printGeneralFFEvalsTable(results)
# Restore cat outputs to console
sink()
