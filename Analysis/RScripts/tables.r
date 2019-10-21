# R script
# 
# author: Xavier Devroey

library(ggplot2)
library(questionr)
library(effsize)

source('dataclean.r')

# -------------
# Constants
# -------------


# ------------------------------
# Functions definition
# ------------------------------
############################ Seeding information tables ############################

printModelsTable <- function(finalTableModels){
  cat("\\begin{tabular}{ l | r r r r r r}\n")
  cat("\\hline", "\n")
  cat("\\textbf{Project}", "&",
      "\\textbf{$\\overline{state}$}", "&", "\\textbf{$\\sigma$}", "&",
      "\\textbf{$\\overline{trans}$}", "&", "\\textbf{$\\sigma$}", "&",
      "\\textbf{$\\overline{BFS}$}", "&", "\\textbf{$\\sigma$}")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  for (row in 1:nrow(finalTableModels)) {
    #print(finalTableModels[row])
    cat(paste(finalTableModels[[row, 'project']]), " & ",
        formatC(finalTableModels[[row, 'avg_state']], digits = 2, format="f", big.mark = ','), " & ",
        formatC(finalTableModels[[row, 'sd_state']], digits = 2, format="f", big.mark = ','), " & ",
        formatC(finalTableModels[[row, 'avg_trans']], digits = 2, format="f", big.mark = ','), " & ",
        formatC(finalTableModels[[row, 'sd_trans']], digits = 2, format="f", big.mark = ','), " & ",
        formatC(finalTableModels[[row, 'avg_bfs']], digits = 2, format="f", big.mark = ','), " & ",
        formatC(finalTableModels[[row, 'sd_bfs']], digits = 2, format="f", big.mark = ','))
    cat("\\\\", "\n")
  }
  cat("\\end{tabular}")
}


printTestsTable <- function(finalTableTests){
  cat("\\begin{tabular}{ l | r r}\n")
  cat("\\hline", "\n")
  cat("\\textbf{Project}", "&",
      "\\textbf{$\\overline{test}$}", "&", "\\textbf{$\\sigma$}")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  for (row in 1:nrow(finalTableTests)) {
    cat(paste(finalTableTests[[row, 'project']]), " & ",
        formatC(finalTableTests[[row, 'avg_test_classes']], digits = 2, format="f", big.mark = ','), " & ",
        formatC(finalTableTests[[row, 'sd_test_classes']], digits = 2, format="f", big.mark = ','))
    cat("\\\\", "\n")
  }
  cat("\\end{tabular}")
}
############################ Reproduction status ############################

printOddsRatiosTable <- function(oddsRatioRep){
  cat("\\begin{tabular}{ l | l | r}\n")
  cat("\\hline", "\n")
  cat("\\textbf{Seeding Strategy}", "&", "\\textbf{Crash}", "&", "\\textbf{Odds Ratio (p-value)}")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  modelProbs = unique(oddsRatioRep$configuration.conf1)
  
  for(probsIndex in 1:length(modelProbs)){
    oddsRatiosOfModelProb <- oddsRatioRep %>%
      filter(configuration.conf1 == modelProbs[probsIndex])

    cat(modelProbs[probsIndex])
    oddsRatiosOfModelProb <- oddsRatioRep %>%
      filter(configuration.conf1 == modelProbs[probsIndex])
    for (row in 1:nrow(oddsRatiosOfModelProb)) {
      cat(paste(" & ",oddsRatiosOfModelProb[[row, 'case']], " & ", formatC(oddsRatiosOfModelProb[[row, 'oddsratio']], digits = 2, format="f", big.mark = ','), " (",formatC(oddsRatiosOfModelProb[[row, 'pValue']], format="e", digits = 2, , big.mark = ','),")", sep=""))
      cat("\\\\", "\n")
    }
    cat("\\hline", "\n")
  }
  cat("\\end{tabular}")

}

# Prints general table with reproduction information per crash 
# (only crashes reproduced at least once are printed)
#
printReproductionTable <- function(results){
  # Prepare the data and compute reproduction rate and number of ff evaluations 
  df <- getReproductionRate(results) %>%
    arrange(case, configuration_factor)
  
  configs <- df %>%
    distinct(configuration_factor, configuration) %>%
    arrange(configuration_factor)
  
  # Print Table
  cat("\\begin{longtable}{ l r ")
  for(j in 1:nrow(configs)){
    cat("| r r r ")
  }
  cat("} \n")
  # Print headers 
  cat(" & ")
  for(j in 1:nrow(configs)){
    conf <- configs[j,]
    cat(" & \\multicolumn{3}{c}{\\textbf{", as.character(conf[1]), "}} ", sep = '')
  }
  cat("\\\\", "\n")
  # Print columns headers
  cat("\\textbf{id}", "&", "\\textbf{fl}")
  columnHeader <- " & \\textit{rate} & $\\overline{ff}$ & $\\sigma$ "
  for(j in 1:nrow(configs)){
    cat(columnHeader)
  }
  cat("\\\\", "\n")
  cat("\\hline", "\n")
  
  # Print the data for each case
  for(c in unique(df$case)){
    current <- df %>%
      filter(case == c)
    cat(current$case[1])
    cat(" & ")
    cat(current$highest[1])
    # Print all configurations of the case on one line
    for(conf in unique(configs$configuration)){
      line <- df %>%
        filter(case == c, configuration == conf)
      cat(" & ")
      if(nrow(line) > 0 && line$status == 'reproduced'){
        cat(formatC(line$reproduction_rate * 100, format="d", big.mark = ','), '\\%', sep='')
        cat(" & ")
        cat(formatC(line$avg_ff_evals, digits=1, format="f", big.mark = ','), sep='')
        cat(" & ")
        if(is.na(line$sd_ff_evals)){
          cat('-')
        } else {
          cat(formatC(line$sd_ff_evals, digits=2, format="f", big.mark = ','), sep='')
        }
      } else {
        cat("-", "&", "-", "&", "-")
      }
    }
    cat("\\\\", "\n")
  }
  
  cat("\\hline", "\n")
  cat("\\end{longtable}")
}


printGeneralReproductionTable <- function(results){
  oddsratios <- getOddsRatioComparisonReproduction(results)
  cat("\\begin{tabular}{ l r r | r r r }\n")
  cat("\\hline", "\n")
  cat("\\textbf{Conf.}", "&", "\\multicolumn{2}{c|}{Reproduction}", "&",
      "\\multicolumn{3}{c}{Comparison to no s.}")
  cat(" \\\\", "\n")
  cat(" ", "&", "$\\overline{\\text{rate}}$", "&","$\\sigma$", "&",
      "better", "&", "no diff.", "&", "worse")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  # Print no s. line 
  cat(CONFIGURATION_LEVELS[1], "&", 
      formatC(oddsratios[[1, 'meanCount.conf2']], digits=1, format="f", big.mark = ','), "&",
      formatC(oddsratios[[1, 'sdCount.conf2']], digits=2, format="f", big.mark = ','), "&",
      "-", "&",
      "-", "&",
      "-")
  cat(" \\\\", "\n")
  for(row in 1:nrow(oddsratios)){
    cat(oddsratios[[row, 'configuration.conf1']], "&", 
        formatC(oddsratios[[row, 'meanCount.conf1']], digits=1, format="f", big.mark = ','), "&",
        formatC(oddsratios[[row, 'sdCount.conf1']], digits=2, format="f", big.mark = ','), "&",
        oddsratios[[row, 'bettercount']], "&",
        oddsratios[[row, 'nodiffcount']], "&",
        oddsratios[[row, 'worsecount']])
    cat(" \\\\", "\n")
  }
  cat("\\hline", "\n")
  cat("\\end{tabular}")
}


printAdditionalEvalReproductionTable <- function(results){
  oddsratios <- getOddsRatioReproduction(results) %>%
    mutate(better = if_else(oddsratio > 1, 1, 0, 0),
           nodiff = if_else(oddsratio == 1, 1, 0, 0),
           worse = if_else(oddsratio < 1, 1, 0, 0)) %>%
    group_by(configuration.conf1) %>%
    summarise(bettercount = sum(better),
              nodiffcount = sum(nodiff),
              worsecount = sum(worse),
              meanCount.conf1 = mean(count.conf1),
              sdCount.conf1 = sd(count.conf1),
              meanCount.conf2 = mean(count.conf2),
              sdCount.conf2 = sd(count.conf2))
  cat("\\begin{tabular}{ l r r | r r r }\n")
  cat("\\hline", "\n")
  cat("\\textbf{Conf.}", "&", "\\multicolumn{2}{c|}{Reproduction}", "&",
      "\\multicolumn{3}{c}{Comparison to other conf.}")
  cat(" \\\\", "\n")
  cat(" ", "&", "$\\overline{\\text{rate}}$", "&","$\\sigma$", "&",
      "better", "&", "no diff.", "&", "worse")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  for(row in 1:nrow(oddsratios)){
    cat(oddsratios[[row, 'configuration.conf1']], "&", 
        formatC(oddsratios[[row, 'meanCount.conf1']], digits=1, format="f", big.mark = ','), "&",
        formatC(oddsratios[[row, 'sdCount.conf1']], digits=2, format="f", big.mark = ','), "&",
        oddsratios[[row, 'bettercount']], "&",
        oddsratios[[row, 'nodiffcount']], "&",
        oddsratios[[row, 'worsecount']])
    cat(" \\\\", "\n")
  }
  cat("\\hline", "\n")
  cat("\\end{tabular}")
}

############################ Search initialized status ############################

printGeneralStartingSearchTable <- function(results){
  oddsratios <- getOddsRatioComparisonStarted(results)
  cat("\\begin{tabular}{ l r r | r r r }\n")
  cat("\\hline", "\n")
  cat("\\textbf{Conf.}", "&", "\\multicolumn{2}{c|}{Search started}", "&",
      "\\multicolumn{3}{c}{Comparison to no s.}")
  cat(" \\\\", "\n")
  cat(" ", "&", "$\\overline{\\text{rate}}$", "&","$\\sigma$", "&",
      "better", "&", "no diff.", "&", "worse")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  # Print no s. line 
  cat(CONFIGURATION_LEVELS[1], "&", 
      formatC(oddsratios[[1, 'meanCount.conf2']], digits=1, format="f", big.mark = ','), "&",
      formatC(oddsratios[[1, 'sdCount.conf2']], digits=2, format="f", big.mark = ','), "&",
      "-", "&",
      "-", "&",
      "-")
  cat(" \\\\", "\n")
  for(row in 1:nrow(oddsratios)){
    cat(oddsratios[[row, 'configuration.conf1']], "&", 
        formatC(oddsratios[[row, 'meanCount.conf1']], digits=1, format="f", big.mark = ','), "&",
        formatC(oddsratios[[row, 'sdCount.conf1']], digits=2, format="f", big.mark = ','), "&",
        oddsratios[[row, 'bettercount']], "&",
        oddsratios[[row, 'nodiffcount']], "&",
        oddsratios[[row, 'worsecount']])
    cat(" \\\\", "\n")
  }
  cat("\\hline", "\n")
  cat("\\end{tabular}")
}

printAdditionalEvalStartingSearchTable <- function(results){
  oddsratios <- getOddsRatioStarted(results) %>%
    mutate(better = if_else(oddsratio > 1, 1, 0, 0),
           nodiff = if_else(oddsratio == 1, 1, 0, 0),
           worse = if_else(oddsratio < 1, 1, 0, 0)) %>%
    group_by(configuration.conf1) %>%
    summarise(bettercount = sum(better),
              nodiffcount = sum(nodiff),
              worsecount = sum(worse),
              meanCount.conf1 = mean(count.conf1),
              sdCount.conf1 = sd(count.conf1),
              meanCount.conf2 = mean(count.conf2),
              sdCount.conf2 = sd(count.conf2))
  cat("\\begin{tabular}{ l r r | r r r }\n")
  cat("\\hline", "\n")
  cat("\\textbf{Conf.}", "&", "\\multicolumn{2}{c|}{Search started}", "&",
      "\\multicolumn{3}{c}{Comparison to other conf.}")
  cat(" \\\\", "\n")
  cat(" ", "&", "$\\overline{\\text{rate}}$", "&","$\\sigma$", "&",
      "better", "&", "no diff.", "&", "worse")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  for(row in 1:nrow(oddsratios)){
    cat(oddsratios[[row, 'configuration.conf1']], "&", 
        formatC(oddsratios[[row, 'meanCount.conf1']], digits=1, format="f", big.mark = ','), "&",
        formatC(oddsratios[[row, 'sdCount.conf1']], digits=2, format="f", big.mark = ','), "&",
        oddsratios[[row, 'bettercount']], "&",
        oddsratios[[row, 'nodiffcount']], "&",
        oddsratios[[row, 'worsecount']])
    cat(" \\\\", "\n")
  }
  cat("\\hline", "\n")
  cat("\\end{tabular}")
}

############################ Fitness functions evaluations ############################

printGeneralFFEvalsTable <- function(results){
  reproduced <- getReproduceStatus(results)
  df <- results %>%
    inner_join(reproduced %>%
                 rename(frame_level = highest),
               by = c("case", "frame_level", "application_name", "application_factor", "exception", 
                      "exception_factor", "configuration", "configuration_factor")) %>%
    mutate(number_of_fitness_evaluations = if_else(result == 'reproduced', as.double(number_of_fitness_evaluations), MAX_NUMBER_F_EVAL))
  df2 <- df %>%
    inner_join(df, by=c('case', 'frame_level', 'execution_idx'), suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>% 
    group_by(case,frame_level, configuration.conf1, configuration.conf2) %>%
    summarise(VD.magnitude = VD.A(number_of_fitness_evaluations.conf1, number_of_fitness_evaluations.conf2)$magnitude,
              VD.estimate = VD.A(number_of_fitness_evaluations.conf1, number_of_fitness_evaluations.conf2)$estimate,
           wilcox.test.pvalue = wilcox.test(number_of_fitness_evaluations.conf1, number_of_fitness_evaluations.conf2)$p.value) %>%
    filter(wilcox.test.pvalue <= SIGNIFICANCE_LEVEL) %>%
    mutate(VD.estimate.category = case_when(
      VD.estimate < 0.5 ~ '< 0.5',
      VD.estimate > 0.5 ~ '> 0.5',
      TRUE ~ '= 0.5'
    )) %>%
    group_by(configuration.conf1,frame_level, configuration.conf2, VD.estimate.category, VD.magnitude) %>%
    summarise(count.VD = n()) %>%
    filter(configuration.conf2 == 'no s.')
  
  cat("\\begin{tabular}{ l r r | rr | rr | rr }\n")
  cat("\\hline", "\n")
  cat("\\textbf{Conf.}", "&", "\\multicolumn{2}{c|}{Fitness}", "&",
      "\\multicolumn{6}{c}{Comparison to no s.}")
  cat(" \\\\", "\n")
  cat(" ", "&", " ", "&"," ", "&",
      "\\multicolumn{2}{c}{large}", "&", "\\multicolumn{2}{c}{medium}", "&", 
      "\\multicolumn{2}{c}{small}")
  cat(" \\\\", "\n")
  cat(" ", "&", "$\\overline{\\text{evaluations}}$", "&","$\\sigma$", "&",
      "$<0.5$", "&", "$>0.5$", "&",
      "$<0.5$", "&", "$>0.5$", "&",
      "$<0.5$", "&", "$>0.5$")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  # Print no s. line 
  line <- df %>%
    filter(configuration == CONFIGURATION_LEVELS[1]) %>%
    summarise(mean.ffevals = mean(number_of_fitness_evaluations),
              sd.ffevals = sd(number_of_fitness_evaluations))
  cat(CONFIGURATION_LEVELS[1], "&", 
      formatC(line[[1, 'mean.ffevals']], digits=1, format="f", big.mark = ','), "&",
      formatC(line[[1, 'sd.ffevals']], digits=2, format="f", big.mark = ','), "&",
      "-", "&", "-", "&", 
      "-", "&", "-", "&", 
      "-", "&", "-")
  cat(" \\\\", "\n")
  configs <- df %>%
    distinct(configuration_factor, configuration) %>%
    filter(configuration != "no s.") %>%
    arrange(configuration_factor)
  for(i in 1:nrow(configs)){
    conf <- as.character(configs[i, 'configuration_factor'])
    line <- df %>%
      filter(configuration == conf) %>%
      summarise(mean.ffevals = mean(number_of_fitness_evaluations),
                sd.ffevals = sd(number_of_fitness_evaluations))
    cat(conf, "&", 
        formatC(line[[1, 'mean.ffevals']], digits=1, format="f", big.mark = ','), "&",
        formatC(line[[1, 'sd.ffevals']], digits=2, format="f", big.mark = ','))
    for (magnitude in c("large", "medium", "small")) {
      for (category in c("< 0.5", "> 0.5")){
        line <- df2 %>%
          filter(configuration.conf1 == conf, VD.magnitude == magnitude,
                 VD.estimate.category == category)
        if(nrow(line) > 0){
          cat("&", formatC(line[[1, 'count.VD']], format="d", big.mark = ','))  
        } else {
          cat("&", "-")  
        }
      }
    }
    cat(" \\\\", "\n")
  }
  cat("\\hline", "\n")
  cat("\\end{tabular}")
}


printAdditionalEvalFFEvalsTable <- function(results){
  reproduced <- getReproduceStatus(results)
  df <- results %>%
    inner_join(reproduced %>%
                 rename(frame_level = highest),
               by = c("case", "frame_level", "application_name", "application_factor", "exception", 
                      "exception_factor", "configuration", "configuration_factor")) %>%
    mutate(number_of_fitness_evaluations = if_else(result == 'reproduced', as.double(number_of_fitness_evaluations), MAX_NUMBER_F_EVAL))
  df2 <- df %>%
    inner_join(df, by=c('case', 'frame_level', 'execution_idx'), suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>% 
    group_by(case,frame_level, configuration.conf1, configuration.conf2) %>%
    summarise(VD.magnitude = VD.A(number_of_fitness_evaluations.conf1, number_of_fitness_evaluations.conf2)$magnitude,
              VD.estimate = VD.A(number_of_fitness_evaluations.conf1, number_of_fitness_evaluations.conf2)$estimate,
              wilcox.test.pvalue = wilcox.test(number_of_fitness_evaluations.conf1, number_of_fitness_evaluations.conf2)$p.value) %>%
    filter(wilcox.test.pvalue <= SIGNIFICANCE_LEVEL) %>%
    mutate(VD.estimate.category = case_when(
      VD.estimate < 0.5 ~ '< 0.5',
      VD.estimate > 0.5 ~ '> 0.5',
      TRUE ~ '= 0.5'
    )) %>%
    group_by(configuration.conf1, frame_level, VD.estimate.category, VD.magnitude) %>%
    summarise(count.VD = n()) 
  
  cat("\\begin{tabular}{ l r r | rr | rr | rr }\n")
  cat("\\hline", "\n")
  cat("\\textbf{Conf.}", "&", "\\multicolumn{2}{c|}{Fitness}", "&",
      "\\multicolumn{6}{c}{Comparison to other configurations}")
  cat(" \\\\", "\n")
  cat(" ", "&", " ", "&"," ", "&",
      "\\multicolumn{2}{c}{large}", "&", "\\multicolumn{2}{c}{medium}", "&", 
      "\\multicolumn{2}{c}{small}")
  cat(" \\\\", "\n")
  cat(" ", "&", "$\\overline{\\text{evaluations}}$", "&","$\\sigma$", "&",
      "$<0.5$", "&", "$>0.5$", "&",
      "$<0.5$", "&", "$>0.5$", "&",
      "$<0.5$", "&", "$>0.5$")
  cat(" \\\\", "\n")
  cat("\\hline", "\n")
  configs <- df %>%
    distinct(configuration_factor, configuration) %>%
    filter(configuration != "no s.") %>%
    arrange(configuration_factor)
  for(i in 1:nrow(configs)){
    conf <- as.character(configs[i, 'configuration_factor'])
    line <- df %>%
      filter(configuration == conf) %>%
      summarise(mean.ffevals = mean(number_of_fitness_evaluations),
                sd.ffevals = sd(number_of_fitness_evaluations))
    cat(conf, "&", 
        formatC(line[[1, 'mean.ffevals']], digits=1, format="f", big.mark = ','), "&",
        formatC(line[[1, 'sd.ffevals']], digits=2, format="f", big.mark = ','))
    for (magnitude in c("large", "medium", "small")) {
      for (category in c("< 0.5", "> 0.5")){
        line <- df2 %>%
          filter(configuration.conf1 == conf, VD.magnitude == magnitude,
                 VD.estimate.category == category)
        if(nrow(line) > 0){
          cat("&", formatC(line[[1, 'count.VD']], format="d", big.mark = ','))  
        } else {
          cat("&", "-")  
        }
      }
    }
    cat(" \\\\", "\n")
  }
  cat("\\hline", "\n")
  cat("\\end{tabular}")
}
