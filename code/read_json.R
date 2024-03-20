#!/usr/bin/env Rscript

library("rjson")
library("tidyverse")
library("hms")

slidingwindow <-  30

# Read in the old data
all_values <- read_tsv("data/values.tsv")
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
    date <- as_date(date_time)
    time <- as_hms(date_time)

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