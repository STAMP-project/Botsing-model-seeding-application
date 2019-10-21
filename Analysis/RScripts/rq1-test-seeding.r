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

majority <- getMostFrequentResult(results)

# Plot and save graphs

p <- buildStackedBarFrameStatusPerApp(results)
ggsave(plot = p, filename = 'rq1-frames-apps.pdf', width=160, height=215, units = "mm" )

p <- buildStackedBarFrameStatusAll(results)
ggsave(plot = p, filename = 'rq1-frames-all.pdf', width=160, height=60, units = "mm" )

# Build results tables

outputFile <- "rq1-results-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printReproductionTable(results)
# Restore cat outputs to console
sink()




