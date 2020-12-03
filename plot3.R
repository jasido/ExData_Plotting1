### (1) After forking the repository, https://github.com/rdpeng/ExData_Plotting1, check README
### for the link to the dataset and download it.
### (2) Open Rstudio and start a project using version control.
### (3) Copy the SSH link from the forked repository above and use it in initializing the project.
### (4) Rstudio should now contain the files from the remote repository.
### (5) After finishing the code; add, commit changes to the local repo then push to Github.

### Also, rather than reading the entire data set and subsetting to the required dates, read_delim_chunked
### from readr package is used to efficiently read only the data that is needed.
### Tidyverse is a collection of packages which includes readr, dplyr, tidyr, lubridate etc.


# Load data------------------------------------------------------------------------------------------------

# Load necessary package
library(tidyverse)

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

df <- df %>%
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


# Create plot----------------------------------------------------------------------------------------------

# Set graphic device on png
png(
  filename = "plot3.png",
  width = 480,
  height = 480
)

# Create a blank canvas with labels
plot(df$date, df$value,
  xlab = "",
  ylab = "Energy sub metering",
  type = "n"
)

# Subset df for each energy sub-metering
submeter1 <- subset(a, key == "Sub_metering_1")
submeter2 <- subset(a, key == "Sub_metering_2")
submeter3 <- subset(a, key == "Sub_metering_3")

# Generate line plots with each subset on their respective colors
with(submeter1, lines(date, value, col = "black"))
with(submeter2, lines(date, value, col = "red"))
with(submeter3, lines(date, value, col = "blue"))

# Add legend
legend("topright",
  lty = 1,
  col = c("black", "red", "blue"),
  legend = c(
    "Sub_metering_1",
    "Sub_metering_2",
    "Sub_metering_1"
  )
)


# Shutdown connection to png
dev.off()
