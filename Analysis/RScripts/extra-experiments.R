library(dplyr)

source('dataclean.r')
source('graphs.r')
source('tables.r')

extraModelSeedingResults <- getExtraResults() 

#p <- buildStackedBarCrashStatusPerApp(extraModelSeedingResults)
#ggsave(plot = p, filename = 'additional-expe-apps.pdf', width=110, height=400, units = "mm" )

p <- buildStackedBarCrashStatusAll(extraModelSeedingResults)
ggsave(plot = p, filename = 'additional-expe-all.pdf', width=110, height=100, units = "mm" )

# Print general table with started rates and odds ratio per configuration

df <- getSearchStartedStatus(extraModelSeedingResults) %>%
  group_by(configuration_factor, started_status_factor) %>%
  summarise(number_crashes = n())
cat('Started status for the additional evaulation:', '\n')
print(df)

# Print general table with reproduction rates and odds ratio per configuration

outputFile <- "additional-expe-repr-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printAdditionalEvalReproductionTable(extraModelSeedingResults) 
# Restore cat outputs to console
sink()

# Print general table with number of fitness evaluations per configuration 

outputFile <- "additional-expe-ff-evals-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printAdditionalEvalFFEvalsTable(extraModelSeedingResults) 
# Restore cat outputs to console
sink()


