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


# Print general table with started rates and odds ratio per configuration for the highest started frame

outputFile <- "rq11-started-search-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printGeneralStartingSearchTable(results)
# Restore cat outputs to console
sink()


  