# Contains functions to produce a clean/easy to process dataframe from the input and 
# output csv files.
# authors: Xavier Devroey

library(dplyr)
library(questionr)

# -------------
# Constants
# -------------

APPLICATION_LEVELS = c("Commons-lang", "Commons-math", "Mockito", "Joda-Time", "JFreechart", "Closure comp.", "Elasticsearch", "XWiki")

EXCEPTION_LEVELS = c("NPE", "IAE", "CCE", "AIOOBE", "SIOOBE", "ISE", "Oth.")

CONFIGURATION_LEVELS = c("no s.", "test s. 0.2", "test s. 0.5", "test s. 0.8", "test s. 1.0",
                         "model s. 0.2", "model s. 0.5", "model s. 0.8", "model s. 1.0")

EXTRA_CNFIGURATION_LEVELS=c()
  
  
EXTRA_EXPERIMENT_CASES=c("MATH-97b", "MATH-101b", "XWIKI-14152", "MATH-51b", "LANG-13b", "XWIKI-13708", "XWIKI-14556", "MOCKITO-12b", "XWIKI-13407", "LANG-2b")

RESULT_LEVELS = c("not started", "line not reached", "line reached", "ex. thrown", "reproduced")

STATUS_LEVELS = c("not reproduced", "reproduced")

STARTED_STATUS_LEVELS = c("not started", "started")

TOTAL_RUNS = 30

SIGNIFICANCE_LEVEL = 0.05

MAX_NUMBER_F_EVAL = 62328 

# ------------------------------
# Functions definition
# ------------------------------

# Adds full name for applications
#
addApplicationName <- function(df){
  df$application_name[df$application == "lang"] <- APPLICATION_LEVELS[1]
  df$application_name[df$application == "math"] <- APPLICATION_LEVELS[2]
  df$application_name[df$application == "mockito"] <- APPLICATION_LEVELS[3]
  df$application_name[df$application == "time"] <- APPLICATION_LEVELS[4]
  df$application_name[df$application == "chart"] <- APPLICATION_LEVELS[5]
  df$application_name[df$application == "closure"] <- APPLICATION_LEVELS[6]
  df$application_name[df$application == "es"] <- APPLICATION_LEVELS[7]
  df$application_name[df$application == "xwiki"] <- APPLICATION_LEVELS[8]
  df$application_factor <- factor(df$application_name, levels = APPLICATION_LEVELS, ordered = TRUE)
  return(df)
}

# Adds accronyms for exceptions 
#
addExceptionShortName <- function(df){
  df$exception <- tail(EXCEPTION_LEVELS, n=1)
  df$exception[df$exception_name == "java.lang.NullPointerException"] <- EXCEPTION_LEVELS[1]
  df$exception[df$exception_name == "java.lang.IllegalArgumentException"] <- EXCEPTION_LEVELS[2]
  df$exception[df$exception_name == "java.lang.ClassCastException"] <- EXCEPTION_LEVELS[3]
  df$exception[df$exception_name == "java.lang.ArrayIndexOutOfBoundsException"] <- EXCEPTION_LEVELS[4]
  df$exception[df$exception_name == "java.lang.StringIndexOutOfBoundsException"] <- EXCEPTION_LEVELS[5]
  df$exception[df$exception_name == "java.lang.IllegalStateException"] <- EXCEPTION_LEVELS[6]
  df$exception_factor <- factor(df$exception, levels = EXCEPTION_LEVELS, ordered = TRUE)
  return(df)
}

# Produces an easy to process dataframe from the given results csv file.
# csvFile: a csv file produced by the experimentation framework
#
getCleanResultsDf <- function(csvFile){
  df <- read.csv(csvFile, stringsAsFactors = FALSE)
  # Restrict on population 
  # df <- df %>% 
  # 	filter(population == 100)
  # Add name of the applications
  df <- addApplicationName(df)
  # Add short name for exceptions
  df <- addExceptionShortName(df)
  # Add id for the frame
  df$case_frame <- paste0(df$case, '-', df$frame)
  # Set the global result of the execution
  df$result[is.na(df$fitness_function_value) | !is.numeric(df$fitness_function_value)] <- RESULT_LEVELS[1]
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value > 3] <- RESULT_LEVELS[2]
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value == 3] <- RESULT_LEVELS[3]
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value != 0 & df$fitness_function_value <= 1] <- RESULT_LEVELS[4]
  df$result[is.numeric(df$fitness_function_value) & df$fitness_function_value == 0] <- RESULT_LEVELS[5]
  # Set the order of exceptions
  df$result_factor <- factor(df$result, levels = RESULT_LEVELS, ordered = TRUE)
  return(df)
}

# Returns a dataframe with the results of the evaluation for no seeding
#
getNoSeedingResults <- function(){
  noseeding <- getCleanResultsDf('../../Evaluation/crash-reproduction-no-seeding/results/results.csv') %>%
    mutate(configuration = CONFIGURATION_LEVELS[1])
  noseeding$configuration_factor = factor(noseeding$configuration, levels = CONFIGURATION_LEVELS, ordered = TRUE)
  return(noseeding)
}

# Returns a dataframe with the results of the evaluation for test seeding
#
getTestSeedingResults <- function(){
  testseeding <- getCleanResultsDf('../../Evaluation/crash-reproduction-test-seeding/results/results.csv') %>%
    mutate(configuration = case_when(
      seed_clone == 0.2 ~ CONFIGURATION_LEVELS[2],
      seed_clone == 0.5 ~ CONFIGURATION_LEVELS[3],
      seed_clone == 0.8 ~ CONFIGURATION_LEVELS[4],
      seed_clone == 1.0 ~ CONFIGURATION_LEVELS[5],
      TRUE ~ 'undef'
    ))
  # Discard the ones without any test cases (only one execution of test s. 0.2)
  tokeep <- testseeding %>%
    group_by(case, frame_level) %>%
    summarise(count = n()) %>%
    filter(count > TOTAL_RUNS) %>% # filter out configurations run only for one configuration
    mutate(id = paste0(case, '-', frame_level))
  testseeding <- testseeding %>%
    filter(paste0(case, '-', frame_level) %in% tokeep$id)
  testseeding$configuration_factor = factor(testseeding$configuration, levels = CONFIGURATION_LEVELS, ordered = TRUE)
  return(testseeding)
}

# Returns a dataframe with the results of the evaluation for model seeding
#
getModelSeedingResults <- function(){
  modelseeding <- getCleanResultsDf('../../Evaluation/crash-reproduction-model-seeding/results/results.csv') %>%
    mutate(configuration = case_when(
      seed_clone == 0.2 ~ CONFIGURATION_LEVELS[6],
      seed_clone == 0.5 ~ CONFIGURATION_LEVELS[7],
      seed_clone == 0.8 ~ CONFIGURATION_LEVELS[8],
      seed_clone == 1.0 ~ CONFIGURATION_LEVELS[9],
      TRUE ~ 'undef'
    ))
  modelseeding$configuration_factor = factor(modelseeding$configuration, levels = CONFIGURATION_LEVELS, ordered = TRUE)
  return(modelseeding)
}


getExtraResults <- function(){
  modelseeding <- getCleanResultsDf('../../Evaluation/crash-reproduction-model-seeding/results/results.csv') %>% filter(case %in% EXTRA_EXPERIMENT_CASES)
  extraModelSeeding <- getCleanResultsDf('../../Evaluation/crash-reproduction-model-seeding/extra-results.csv')
  total <- rbind(modelseeding, extraModelSeeding) %>% 
    mutate(configuration = paste("Pr[init]=", formatC(as.double(seed_clone), digits=1, format="f"), 
                                 " Pr[mut]=", formatC(as.double(p_object_pool), digits=1, format="f"),
                                 sep = ""))
  total$configuration_factor = factor(total$configuration, ordered = TRUE)
  return(total)
}

# Returns a dataframe with the results of the evaluation.
#
getResults <- function(){
  noseeding <- getNoSeedingResults()
  testseeding <- getTestSeedingResults()
  modelseeding <- getModelSeedingResults()
  # Bind results together
  results <- noseeding %>%
    bind_rows(testseeding) %>%
    bind_rows(modelseeding)
  # Add configuration factor
  #results$configuration_factor = factor(results$configuration, levels = CONFIGURATION_LEVELS, ordered = TRUE)
  return(results)
}

# Returns a dataframe with the results occuring in the majority of execution for each frame. 
# Adds majority_result and majority_result_factor columns.
#
getMostFrequentResult <- function(results){
  majority <- results %>%
    group_by(application_name, application_factor, case, exception, exception_factor, frame_level, case_frame,
             configuration, configuration_factor) %>%
    summarise(result_factor = names(which.max(table(result_factor)))) %>%
    mutate(result = as.character(result_factor))
  df <- data.frame(majority)
  df$result_factor <- factor(df$result, levels = RESULT_LEVELS, ordered = TRUE)
  return(df)
}

############################ Reproduction status ############################


# Returns a dataframe with the highest frame reproduced for the crash and the reproduction status of the crash.
# For each crash, we consider the highest reproduced frame (if any) amongst the different configurations 
# as basis for that crash.
#
getReproduceStatus <- function(results){
  df <- results %>%
    group_by(case, configuration_factor, result) %>%
    mutate(max_reproduced = ifelse(result == 'reproduced', max(frame_level), 0)) %>%
    ungroup() %>%
    group_by(case, configuration_factor) %>%
    mutate(max_reproduced = max(max_reproduced)) %>%
    ungroup() %>%
    distinct(application_name, application_factor, case, exception, exception_factor, 
             configuration, configuration_factor, max_reproduced)
  df <- data.frame(df) %>%
    group_by(case) %>%
    mutate(highest = max(max_reproduced)) %>%
    ungroup() %>%
    mutate(status = ifelse(max_reproduced > 0 & max_reproduced >= highest, STATUS_LEVELS[2], STATUS_LEVELS[1]))
  df <- data.frame(df)
  df$status_factor <- factor(df$status, levels = STATUS_LEVELS, ordered = TRUE)
  return(df)
}

# Returns a dataframe with the reproduction rate and mean number of fitness evaluations for each crash
# and each configuration. 
#
getReproductionRate <- function(results){
  df <- getReproduceStatus(results) %>%
    inner_join(results, by = c("case", "application_name", "application_factor", "exception", 
                               "exception_factor", "configuration", "configuration_factor")) %>%
    filter(frame_level == highest) %>%
    group_by(application_name, application_factor, exception, exception_factor, configuration, 
             configuration_factor, case, highest, status, status_factor) %>%
    filter(result_factor >= max(result_factor)) %>%
    summarise(count = ifelse(result[1] == 'reproduced', n(), 0) , 
              reproduction_rate = count/TOTAL_RUNS,
              avg_ff_evals = mean(number_of_fitness_evaluations),
              sd_ff_evals = sd(number_of_fitness_evaluations)) %>%
    data.frame()
  return(df)
}

# Returns the offs ratio for the cases and configurations in results.
#
getOddsRatioReproduction <- function(results){
  computeReproductionOddsRatio <- Vectorize(function(count1, count2){
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- odds.ratio(m, level = 1.0 - SIGNIFICANCE_LEVEL)
    if(or$p <= SIGNIFICANCE_LEVEL){
      return(or$OR)
    } else {
      return(NA)
    }
  })
  
  getPValue <- Vectorize(function(count1, count2){
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Reproduced' = c('yes', 'no'))
    or <- odds.ratio(m, level = 1.0 - SIGNIFICANCE_LEVEL)
    return(or$p)
  })

  df <- getReproductionRate(results)
  df <- df %>%
    inner_join(df, by=c('case'), suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>%
    mutate(oddsratio = computeReproductionOddsRatio(count.conf1, count.conf2)) %>%
    mutate(pValue = getPValue(count.conf1, count.conf2)) %>%
    select(case, configuration.conf1, configuration.conf2, count.conf1, count.conf2, oddsratio, pValue)
  return(df)
}

# Returns a dataframe with the number of times odds ratio indicates that the 
# configuration is better, worse or not different from no seeding. 
#
getOddsRatioComparisonReproduction <- function(results){
  df <- getOddsRatioReproduction(results) %>%
    mutate(better = if_else(oddsratio > 1, 1, 0, 0),
           nodiff = if_else(oddsratio == 1, 1, 0, 0),
           worse = if_else(oddsratio < 1, 1, 0, 0)) %>%
    group_by(configuration.conf1, configuration.conf2) %>%
    summarise(bettercount = sum(better),
              nodiffcount = sum(nodiff),
              worsecount = sum(worse),
              meanCount.conf1 = mean(count.conf1),
              sdCount.conf1 = sd(count.conf1),
              meanCount.conf2 = mean(count.conf2),
              sdCount.conf2 = sd(count.conf2)) %>%
    filter(configuration.conf2 == 'no s.') %>%
    select(configuration.conf1, bettercount, nodiffcount, worsecount,
           meanCount.conf1, sdCount.conf1, meanCount.conf2, sdCount.conf2)
  return(df)
}

############################ Search initialized status ############################

# Returns a dataframe with the highest frame for which the search has started for the crash 
# and the search started status of the crash.
# For each crash, we consider the highest started frame (if any) amongst the different configurations 
# as basis for that crash.
#
getSearchStartedStatus <- function(results){
  df <- results %>%
    group_by(case, configuration_factor, result) %>%
    mutate(max_started = ifelse(result != RESULT_LEVELS[1], max(frame_level), 0)) %>%
    ungroup() %>%
    group_by(case, configuration_factor) %>%
    mutate(max_started = max(max_started)) %>%
    ungroup() %>%
    distinct(application_name, application_factor, case, exception, exception_factor, 
             configuration, configuration_factor, max_started)
  df <- data.frame(df) %>%
    group_by(case) %>%
    mutate(highest_started = max(max_started)) %>%
    ungroup() %>%
    mutate(started_status = ifelse(max_started > 0 & max_started >= highest_started, STARTED_STATUS_LEVELS[2], STARTED_STATUS_LEVELS[1]))
  df <- data.frame(df)
  df$started_status_factor <- factor(df$started_status, levels = STARTED_STATUS_LEVELS, ordered = TRUE)
  return(df)
}

# Returns a dataframe with the started rate.
#
getStartedRate <- function(results){
  df <- getSearchStartedStatus(results) %>%
    inner_join(results, by = c("case", "application_name", "application_factor", "exception", 
                               "exception_factor", "configuration", "configuration_factor")) %>%
    filter(frame_level == highest_started) %>%
    group_by(application_name, application_factor, exception, exception_factor, configuration, 
             configuration_factor, case, highest_started, started_status, started_status_factor) %>%
    summarise(started_count = ifelse(result[1] != RESULT_LEVELS[1], n(), 0) , 
              started_rate = started_count/TOTAL_RUNS) %>%
    data.frame()
  return(df)
}

# Returns the odds ratio for the cases and configurations in results that could be started.
#
getOddsRatioStarted <- function(results){
  computStartedOddsRatio <- Vectorize(function(count1, count2){
    m <- matrix(c(count1, TOTAL_RUNS - count1,
                  count2, TOTAL_RUNS - count2), ncol = 2, byrow = TRUE)
    dimnames(m) <- list('Configuration' = c('conf1', 'conf2'),
                        'Started' = c('yes', 'no'))
    or <- odds.ratio(m, level = 1.0 - SIGNIFICANCE_LEVEL)
    if(or$p <= SIGNIFICANCE_LEVEL){
      return(or$OR)
    } else {
      return(NA)
    }
  })
  
  df <- getStartedRate(results)
  df <- df %>%
    inner_join(df, by=c('case','highest_started'), suffix = c('.conf1', '.conf2')) %>%
    filter(configuration.conf1 != configuration.conf2) %>%
    mutate(startedOddsratio = computStartedOddsRatio(started_count.conf1, started_count.conf2)) %>%
    select(case, highest_started, configuration.conf1, configuration.conf2, started_count.conf1, started_count.conf2, startedOddsratio)
  return(df)
}

# Returns a dataframe with the number of times odds ratio indicates that the 
# configuration is better, worse or not different from no seeding. 
#
getOddsRatioComparisonStarted <- function(results){
  df <- getOddsRatioStarted(results) %>%
    mutate(better = if_else(startedOddsratio > 1, 1, 0, 0),
           nodiff = if_else(startedOddsratio == 1, 1, 0, 0),
           worse = if_else(startedOddsratio < 1, 1, 0, 0)) %>%
    group_by(configuration.conf1, configuration.conf2) %>%
    summarise(bettercount = sum(better),
              nodiffcount = sum(nodiff),
              worsecount = sum(worse),
              meanCount.conf1 = mean(started_count.conf1),
              sdCount.conf1 = sd(started_count.conf1),
              meanCount.conf2 = mean(started_count.conf2),
              sdCount.conf2 = sd(started_count.conf2)) %>%
    filter(configuration.conf2 == 'no s.') %>%
    select(configuration.conf1, bettercount, nodiffcount, worsecount,
           meanCount.conf1, sdCount.conf1, meanCount.conf2, sdCount.conf2)
  return(df)
}


writeDifferingCrashes <- function(df,configs,state_factor){
  no_seeding_good <- df %>% 
    filter(configuration_factor == "no s." & status_factor == state_factor) %>% 
    select(case,highest)
  
  for (confg in Configs){
    confg_good <- df %>% 
      filter(configuration_factor == confg & status_factor == state_factor) %>% 
      select(case,highest)
    no_better_than_seed <- setdiff(no_seeding_good,confg_good)
    no_better_than_seed['winner']='no s.'
    seed_better_than_no <- setdiff(confg_good,no_seeding_good)
    seed_better_than_no['winner']=confg
    
    result <- union(no_better_than_seed,seed_better_than_no)
    write.csv(result,paste(state_factor,'_',confg,'_no.csv'))
  }
}


writeDifferingCrashesInStarting <- function(results,configs){
  for (confg in Configs){
    worse <- getOddsRatioStarted(results) %>% filter(startedOddsratio > 1 & configuration.conf1 == "no s." & configuration.conf2 == confg) %>%
      select(case,highest_started)
    if (nrow(worse)>0){
      worse['winner']='no s.'
    }
    better <-  getOddsRatioStarted(results) %>% filter(startedOddsratio < 1 & configuration.conf1 == "no s." & configuration.conf2 == confg) %>%
      select(case,highest_started)
    if (nrow(better)>0){
      better['winner']=confg
    }
    if (nrow(better) != 0 & nrow(worse)!=0){
      result <- union(better,worse)
    }else if(nrow(better) != 0){
      result <- better
    }else if(nrow(worse) != 0){
      result <- worse
    }else{
      result <- data.frame()
    }
    write.csv(result,paste('started_',confg,'_no.csv'))
  }
}
getFFEvals <- function(results){
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
    filter(configuration.conf2 == 'no s.')
}


writeffEvalsInterestingCases <- function(ffEvals,Configs){
  for (conf in Configs){
    for (magnitude in c("large", "medium", "small")) {
      for (category in c("< 0.5", "> 0.5")){
        line <- ffEvals %>%
          filter(configuration.conf1 == conf, VD.magnitude == magnitude,
               VD.estimate.category == category, configuration.conf2 == "no s.")
        write.csv(line,paste('ffEval_',conf,'_',magnitude,'_',ifelse(category == "< 0.5", "better", "worse"),'.csv'))
      }
    }
  }
}

# Returns a dataframe containing benchmark information
#
getBenchmark <- function(){
  df <- getCleanBenchmarkDf('../benchmark/benchmark.csv') %>%
    filter(!(case == "LANG-27b" & frame_level == 2))
  return(df)
}

getCleanBenchmarkDf <- function(csvFile){
  df <- read.csv(csvFile, stringsAsFactors = FALSE)
  # Add name of the applications
  df$application <- tolower(df$application)
  df <- addApplicationName(df)
  df <- addApplicationKind(df)
  # Add short name for exceptions
  df <- addExceptionShortName(df)
  return(df)
}

# Adds application kind
#
addApplicationKind <- function(df){
  df$application_kind[df$application == "lang"] <- "Defects4J"
  df$application_kind[df$application == "math"] <- "Defects4J"
  df$application_kind[df$application == "mockito"] <- "Defects4J"
  df$application_kind[df$application == "time"] <- "Defects4J"
  df$application_kind[df$application == "chart"] <- "Defects4J"
  df$application_kind[df$application == "closure"] <- "Defects4J"
  df$application_kind[df$application == "xwiki"] <- "XWiki"
  df$application_kind[df$application == "es"] <- "Elasticsearch"
  df$application_kind_factor <- factor(df$application_kind, levels = c("Defects4J", "XWiki", "Elasticsearch"))
  return(df)
}