### (1) After forking the repository, https://github.com/rdpeng/ExData_Plotting1, check README
### for the link to the dataset and download it.
### (2) Open Rstudio and start a project using version control.
### (3) Copy the SSH link from the forked repository above and use it in initializing the project.
### (4) Rstudio should now contain the files from the remote repository.
### (5) After finishing the code; add, commit changes to the local repo then push to Github.

### Also, rather than reading the entire data set and subsetting to the required dates, read_delim_chunked
### from readr package is used to efficiently read only the data that is needed.
### Tidyverse is a collection of packages which includes readr, dplyr, tidyr etc.


# Load data------------------------------------------------------------------------------------------------

# Load necessary packages
library(tidyverse)
library(lubridate)

# Create a function to subset data only on the desired dates
f <- function(x, pos) {
  subset(x, Date == "1/2/2007" | Date == "2/2/2007")
}

# Read the data
df <- read_delim_chunked("exdata_data_household_power_consumption/household_power_consumption.txt",
  # on the condition above
  callback = DataFrameCallback$new(f),
  # specifying the delimiter
  delim = ";",
  # and values that are considered NA's
  na = "?"
)


# Wrangle data---------------------------------------------------------------------------------------------

# Create df for energy sub-metering plot
df_energy <- df %>%
  # unite Date and Time columns into date
  unite(col = "date", c("Date", "Time"), sep = " ") %>%
  # parse date as datetime object
  mutate(date = dmy_hms(date)) %>%
  # select desired columns
  select(date, Sub_metering_1, Sub_metering_2, Sub_metering_3) %>%
  # Gather submetering columns into one column
  gather(
    key = "key", value = "value",
    contains("sub_metering")
  )

# Create df for other plots
df_other <- df %>%
  # unite Date and Time columns into date
  unite(col = "date", c("Date", "Time"), sep = " ") %>%
  # parse date as datetime object
  mutate(date = dmy_hms(date)) %>%
  # select desired columns
  select(date, Global_active_power, Voltage, Global_reactive_power)


# Create plot----------------------------------------------------------------------------------------------

# Set graphic device on png
png(
  filename = "plot4.png",
  width = 480,
  height = 480
)

# Set plot matrix
par(mfrow = c(2, 2), mar = c(4, 4, 1, 1))

# Plot date vs Global_active_power
plot(df_other$date,
  df_other$Global_active_power,
  xlab = "",
  ylab = "Global Active Power",
  type = "l"
)

# Plot date vs Voltage
plot(df_other$date,
  df_other$Voltage,
  xlab = "datetime",
  ylab = "Voltage",
  type = "l"
)

# Plot date vs Energy sub metering

# # The ff produces the same output with less code.
# # On second thought, gathering columns really are unnecessary.
# # I initially thought col = <some factor variable> would work
# # with base's plot() function.
# 
# plot(df$date, df$Sub_metering_1,
#   type = "l",
#   col = "black",
#   xlab = "",
#   ylab = "Energy sub metering"
# )
# lines(df$date, df$Sub_metering_2, col = "red")
# lines(df$date, df$Sub_metering_3, col = "blue")

with(df_energy, {
  # Create a blank canvas with labels
  plot(df_energy$date, df_energy$value,
    xlab = "",
    ylab = "Energy sub metering",
    type = "n"
  )

  # Subset df for each energy sub-metering
  submeter1 <- subset(df_energy, key == "Sub_metering_1")
  submeter2 <- subset(df_energy, key == "Sub_metering_2")
  submeter3 <- subset(df_energy, key == "Sub_metering_3")

  # Generate line plots with each subset on their respective colors
  with(submeter1, lines(date, value, col = "black"))
  with(submeter2, lines(date, value, col = "red"))
  with(submeter3, lines(date, value, col = "blue"))

  # Add legend
  legend("topright",
    lty = 1,
    bty = "n",
    col = c("black", "red", "blue"),
    legend = c(
      "Sub_metering_1",
      "Sub_metering_2",
      "Sub_metering_3"
    )
  )
})

# Plot date vs Global_reactive_power
plot(df_other$date,
  df_other$Global_reactive_power,
  xlab = "datetime",
  ylab = "Global_reactive_power",
  type = "l"
)


# Shutdown connection to png
dev.off()

