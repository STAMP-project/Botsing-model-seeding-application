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

# Plot crash reproduction rates

p <- buildStackedBarCrashStatusPerApp(results)
ggsave(plot = p, filename = 'rq21-crashes-apps.pdf', width=85, height=215, units = "mm" )

p <- buildStackedBarCrashStatusAll(results)
ggsave(plot = p, filename = 'rq21-crashes-all.pdf', width=85, height=60, units = "mm" )

# Make significant oddratios table for model seeding
outputFile <- "rq21-crash-repr-oddratios.tex"
unlink(outputFile)
sink(outputFile, append = TRUE, split = TRUE)
oddsRatioRep <- getOddsRatioReproduction(results) %>% 
  filter(!is.na(oddsratio)) %>%
  filter(configuration.conf2 == 'no s.') %>%
  select('case', 'configuration.conf1', 'configuration.conf2', 'oddsratio', 'pValue')
  
printOddsRatiosTable(oddsRatioRep)
sink()


# Print general table with reproduction rates and odds ratio per configuration

outputFile <- "rq21-crash-repr-table.tex"
unlink(outputFile)
# Redirect cat outputs to file
sink(outputFile, append = TRUE, split = TRUE)
printGeneralReproductionTable(results)
# Restore cat outputs to console
sink()



