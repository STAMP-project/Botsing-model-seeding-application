# R script
# 
# author: Xavier Devroey

library(ggplot2)

# -------------
# Constants
# -------------

COLOR_PALETTE="Spectral" # Use photocopy friendly colors (http://colorbrewer2.org/)

# ------------------------------
# Functions definition
# ------------------------------

# Plot Stacked bar graph for frames per application
#
buildStackedBarFrameStatusPerApp <- function(results){
  # Add count label and frequency
  df <- results %>%
    group_by(application_factor, configuration_factor, result_factor) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n)) 
  p <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = result_factor)) + 
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette=COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill=guide_legend(title=NULL)) +
    theme(legend.position="bottom") +
    coord_flip() +
    facet_grid(application_factor ~ .)
  return(p)
}

# Plot Stacked bar graph for frames for all applications
#
buildStackedBarFrameStatusAll <-function(results){
  # Add count label and frequency
  df <- results %>%
    group_by(configuration_factor, result_factor) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n)) 
  p <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = result_factor)) + 
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette=COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill=guide_legend(title=NULL)) +
    theme(legend.position="bottom") +
    coord_flip()
  return(p)
}

# Plot Stacked bar graph for crash reproduction per application
#
buildStackedBarCrashStatusPerApp <- function(results){
  # Get result status
  reproduction <- getReproduceStatus(results) 
  # Add count and frequency 
  df <- reproduction %>%
    group_by(application_factor, configuration_factor, status_factor) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n))
  p <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = status_factor)) + 
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette=COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill=guide_legend(title=NULL)) +
    theme(legend.position="bottom") +
    coord_flip() +
    facet_grid(application_factor ~ .)
  return(p)
}

# Plot Stacked bar graph for crash reproduction for all applications
#
buildStackedBarCrashStatusAll <- function(results){
  # Get result status
  reproduction <- getReproduceStatus(results) 
  # Add count and frequency 
  df <- reproduction %>%
    group_by(configuration_factor, status_factor) %>%
    summarise(n = n()) %>%
    mutate(Frequency = n / sum(n), label = paste0(n))
  p <- ggplot(df, aes(x = configuration_factor, y = Frequency, fill = status_factor)) + 
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 3) +
    scale_fill_brewer(palette=COLOR_PALETTE) +
    scale_y_continuous(labels = scales::percent) +
    xlab(NULL) +
    ylab(NULL) +
    guides(fill=guide_legend(title=NULL)) +
    theme(legend.position="bottom") +
    coord_flip()
  return(p)
}

