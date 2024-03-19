#!/usr/bin/env Rscript

library(tidyverse)
library(hms)

# Read in the values
values <- read_tsv("values.tsv")

# Change so easier to handle
normalized_values <- values %>%
    mutate(
        sensor_id = as.factor(sensor_id),
        hour = hms(hours = floor(as.numeric(time)/3600))
    ) %>%
    select(-time)

# Extract the last day date from the values
last_row <- normalized_values %>%
    slice_tail(n = 1)
last_day <- last_row$date

# Plot the temperatures for today so far
normalized_values %>%
    filter(date == last_day) %>%
    ggplot(aes(x = hour, y = temperature, group = sensor_id))+
    geom_line()
ggsave("visuals/day_temp.png")

# Extract the latest values for all sensors
last_values <- normalized_values %>%
    group_by(sensor_id) %>%
    slice_tail(n = 1) %>%
    ungroup()

# Plot the maximum daily values for each sensor
values %>%
    group_by(date, sensor_id) %>%
    mutate(max_temp = max(temperature)) %>%
    ggplot(aes(x = date, y = max_temp, group = sensor_id))+
    geom_line()
ggsave("visuals/max_temp.png")

