# R script
# 
# author: Xavier Devroey

library(ggplot2)
library(dplyr)

source('dataclean.r')
source('graphs.r')
source('tables.r')

noseeding <- getNoSeedingResults()
modelseeding <- getModelSeedingResults()

# Restrict to frames that are in both test and no seeding 
results <- modelseeding %>%
  bind_rows(noseeding %>%
              filter(case_frame %in% modelseeding$case_frame))


outputFile <- "rq22-ff-evals-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printGeneralFFEvalsTable(results)
# Restore cat outputs to console
sink()


