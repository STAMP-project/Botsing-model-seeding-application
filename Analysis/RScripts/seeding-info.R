library(ggplot2)

source('dataclean.r')
source('tables.r')
# Without java package models

modelWithoutJava <- model.info %>%
  filter(!str_detect(className, "java") & BFS_HEIGHT != 0)

finalTableModels <- modelWithoutJava %>%
  select(project, NUMBER_OF_STATES, NUMBER_OF_TRANSITIONS, BFS_HEIGHT) %>%
  group_by(project) %>%
  summarise(avg_state = mean(NUMBER_OF_STATES),
            sd_state = sd(NUMBER_OF_STATES),
            avg_trans = mean(NUMBER_OF_TRANSITIONS),
            sd_trans = sd(NUMBER_OF_TRANSITIONS),
            avg_bfs = mean(BFS_HEIGHT),
            sd_bfs = sd(BFS_HEIGHT))


finalTableTests <- test.info %>%
  select(project, NUMBER_OF_TESTSUITES) %>%
  group_by(project) %>%
  summarise(avg_test_classes = mean(NUMBER_OF_TESTSUITES),
            sd_test_classes = sd(NUMBER_OF_TESTSUITES))

outputFile <- "models-table.tex"
unlink(outputFile)
sink(outputFile, append = TRUE, split = TRUE)
printModelsTable(finalTableModels)

sink()


outputFile <- "tests-table.tex"
unlink(outputFile)
sink(outputFile, append = TRUE, split = TRUE)
printTestsTable(finalTableTests)

sink()
# Basic box plot
p <- ggplot(model.info, aes(x=project, y=BFS_HEIGHT)) + 
  geom_boxplot()

p + stat_summary(fun.y=mean, geom="point", shape=23, size=4)


p2 <- ggplot(modelWithoutJava, aes(x=project, y=BFS_HEIGHT)) + 
  geom_boxplot()

p2 + stat_summary(fun.y=mean, geom="point", shape=23, size=4)


modelWithJava <- model.info %>%
  filter(str_detect(className, "java") & BFS_HEIGHT != 0)


p3 <- ggplot(modelWithJava, aes(x=project, y=BFS_HEIGHT)) + 
  geom_boxplot()