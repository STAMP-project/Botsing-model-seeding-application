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
testseeding <- getTestSeedingResults()

# Restrict to frames that are in both test and no seeding 
results <- noseeding %>%
  bind_rows(modelseeding)

majority <- getMostFrequentResult(results)

# Plot and save graphs

p <- buildStackedBarFrameStatusPerApp(majority)
ggsave(plot = p, filename = 'rq2-frames-apps.pdf', width=160, height=215, units = "mm" )

p <- buildStackedBarFrameStatusAll(majority)
ggsave(plot = p, filename = 'rq2-frames-all.pdf', width=160, height=60, units = "mm" )

#p <- buildStackedBarCrashStatusPerApp(majority)
#ggsave(plot = p, filename = 'rq2-crashes-apps.pdf', width=85, height=215, units = "mm" )

#p <- buildStackedBarCrashStatusAll(majority)
#gsave(plot = p, filename = 'rq2-crashes-all.pdf', width=85, height=60, units = "mm" )

outputFile <- "rq2-results-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printReproductionTable(results)
# Restore cat outputs to console
sink()

