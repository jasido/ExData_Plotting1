### (1) After forking the repository, https://github.com/rdpeng/ExData_Plotting1, check README.md
### for the link to the dataset and download it.
### (2) Open Rstudio and start a project using version control.
### (3) Copy the SSH link from the forked repository above and use it in initializing the project.
### (4) Rstudio should now contain the files from the remote repository.
### (5) After finishing the code; add, commit changes to the local repo then push to Github.

### Also, rather than reading the entire data set and subsetting to the required dates, readr package
### is used to efficiently read only the data that is needed.


# Load data-------------------------------------------------------------------------------------------

# Load necessary package
library(readr)

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


# Create plot-----------------------------------------------------------------------------------------

# Set graphic device on png
png(
    filename = "plot1.png",
    width = 480,
    height = 480
)

# Generate the histogram
hist(df$Global_active_power,
  main = "Global Active Power",
  xlab = "Global Active Power (kilowatts)",
  ylab = "Frequency",
  col = "red"
)

# Shut down connection to png
dev.off()

