#!/usr/bin/env Rscript

library("rjson")
library("tidyverse")
library("hms")

slidingwindow <-  365 # 365 days old maximum? Consider removing?

# Read in the old data
all_values <- read_tsv("data/values.tsv")
# Copy it out
write_tsv(all_values, "data/values_old.tsv")

data_files <- list.files(path = "data", pattern = ".json", full.names = TRUE)

for (i in 1:length(data_files)){
    # Read in the current sensor
    current_sensor <- fromJSON(file = data_files[i])
    sensor_id = current_sensor[[1]]$sensor$id

    # Convert to dataframe and remove unnecessary columns
    json_df <- as.data.frame(current_sensor[[1]]$sensordatavalues)
    json_df <- select(json_df, -starts_with(c("id")))

    # Extract all value types
    value_types <- json_df %>%
        select(starts_with("value_type")) 
        #unname() # Nödvändigt?

    # Extract all values 
    values <- json_df %>%
        select("value", starts_with("value."))
        #unname() # Nödvändigt?
    
    # Combine them, since they are in the same order
    names(values) <- value_types

    # Create time and date
    date_df <- as.data.frame(current_sensor[[1]]$timestamp)
    date_time <- ymd_hms(date_df)
    print(date_time)
    date <- as_date(date_time)
    # Correct for timezone
    time <- as_hms(as_hms(date_time)+as_hms("1:00:00"))
    print(time)

    # Add date and time
    values["date"] <- date
    values["time"] <- time

    # Add the sensor id
    values["sensor_id"] <- sensor_id
    
    values_nice <- values %>%
        relocate("sensor_id", "date", "time") %>%
        mutate(across(where(is.character), as.double))

    # Add this row to main the dataframe
    all_values <- add_row(all_values, values_nice)

}

# Filter out old dates
all_values <- all_values %>%
    filter(today()-date <= slidingwindow)

# Write it to the file again
write_tsv(all_values, "data/values.tsv")

# ----------------------------------------------------------------------------
# VISUALIZE

# Change the values from above so easier to handle
normalized_values <- all_values %>%
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
ggsave("public/visuals/day_temp.png")

# Plot the maximum daily values for each sensor
all_values %>%
    group_by(date, sensor_id) %>%
    mutate(max_temp = max(temperature)) %>%
    ggplot(aes(x = date, y = max_temp, group = sensor_id))+
    geom_line()
ggsave("public/visuals/max_temp.png")

# Extract the latest values for all sensors
last_values <- normalized_values %>%
    group_by(sensor_id) %>%
    slice_tail(n = 1) %>%
    ungroup()

write_tsv(last_values, "data/current_values.tsv")
