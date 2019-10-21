library(ggplot2)
library(dplyr)

source('dataclean.r')


benchmark <- getBenchmark()


simplified <- benchmark %>% 
  distinct(application, application_name, case, exception_factor,frame_count,avg_ccn)

finaldf <- simplified %>%
  group_by(application) %>% 
  summarise(cr = n(), frm = mean(frame_count), ccn = mean(avg_ccn))
#   summarise(cr = n(), frm = ave(frame_count), ccn = ave(avg_ccn))
cases <- simplified %>%
  distinct(case)

print(cases)