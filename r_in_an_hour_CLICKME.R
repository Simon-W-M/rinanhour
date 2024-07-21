
#########################################################################################################

# Specify required packages
my_packages <- c("tidyverse",
                 "NHSRdatasets", 
                 "NHSRplotthedots",
                 "gt",
                 "scales",
                 "pacman") 

# Extract not installed packages
not_installed <- my_packages[!(my_packages %in% installed.packages()[ , "Package"])]  

# Install not installed packages
if(length(not_installed)) install.packages(not_installed)   

# Load all packages
pacman::p_load(char = my_packages) 

#########################################################################################################

# hash tag is a comment - the most important of all the commands
# it allows you to leave comments for future you and for others 
# who may be reading your code

# comments are free and not evaluated, there are schools of thought
# on the concept of too many comments 
# there is definate concensus on the lack of comments

# feel free to add any comments to this code, you will be able to access
# it after the event and run it locally


# Load  -  monthly A&E data from NHSE datasets
data("ae_attendances")

# to execute code, you can highlight the section that you want to run,
# like we did at the start,
# or you can press <control> & <enter> in which case it will run the single function 

# once you have an entire script written you can run everything by using 
# <shift> & <control> & <enter>

# See the data just like a spreadsheet in a window
# we do basic visual sorting and filtering on a view of the data
View(ae_attendances)

# Other handy function: summary.
# A generic method you can use on loads of stuff, but gives summary stats here:
summary(ae_attendances)

# r utilises something called the tidyverse, this is a library for data 
# manipulation and plotting.  

# so we have some data in our environment, this is stored as dataframe object
# we can have differnt types of objects such as indiviual varables or plots
# but for now we have that dataframe
# we can see it is a time series, from our nice summary function we can see it covers 
# the period Apr 16 to Mar 19
# It covers a number of different org codes which are different hospital providers
# It has a breadown of type 1, 2 and other and a count of attendances, breaches and admissions


# Data manipulation: describe it as like SQL.
# Dplyr has several 'verbs' that we can use, like 'select' 'group_by' 'filter' 'arrange' and 'summarise'
# Dplyr also has a special 'pipe' function |> that allows us to chain them together to make 'analytical sentences.'
# Essentially the |> means 'THEN' and so you can set up workflows such as filter these
# THEN group by THEN calculate THEN arrnge


# E.g. Show ae_attendances and filter for 'R1H' (Barts Health)

ae_attendances |>
  filter(org_code == "R1H") 

# we can also add functions to our commands to make them dynamic to the data
# in this instance we add another condition to the filter and filter to the
# latest date of submission for barts
ae_attendances |>
  filter(org_code == "R1H",
         period == max(period))


# You can save anything to an object using the 'arrow' symbol to assign it a name.
# If you ran the last bit of code again, but gave it the name `barts`, you would have a subset
# of just the Barts data, called `barts`:

barts <- ae_attendances |> 
  filter(org_code == "R1H") 

# you can see that we now have a new dataframe up in the environment called barts
# which contains just our barts data
# if we wanted to do more calculations on this it is just a data frame now 
# this is a little bit like setting up a new sheet in excel, except they are not linked
# directly, if we wanted to have one ch

# We can choose which columns to display with 'select'. E.g. period and attendances

ae_attendances |> 
  filter(org_code == "R1H") |> 
  select(period, attendances)

# Barts has Type 1, 2 and other A&E attendances. Let's restrict it to just Type 1
ae_attendances |> 
  filter(org_code == "R1H",
         type == "1") |> 
  select(period, attendances)

# How about the average number of Type 1 attendances at Barts?
ae_attendances |>
  filter(org_code == "R1H",
         type == "1") |> 
  summarise(mean_average = mean(attendances))

# quick note on = and ==
# a double equals is a test of equality - is left equal to right
4 == 4 
4 == 5
# a single equals in a function is an assignment in the example above
# we create a summary called 'mean_average' and assign it the value of the mean of attendances

# R can do a lot more than that. We commonly use medians instead of means with skewed data.
# Medians can be tricky things to do in Excel and SQL, as they rely on order.
# R can do this easily,so let's add it in
ae_attendances |> 
  filter(org_code == "R1H",
         type == "1") |> 
  summarise(mean_average = mean(attendances),
            median_average = median(attendances))


# Like SQL, we can do things by groups.  Let's see mean and median attendances by Type.
ae_attendances |> 
  filter(org_code == "R1H") |> 
  summarise(mean_average = mean(attendances),
            median_average = median(attendances),
            .by = type)

# Let's apply this to a few trusts. Add codes of Trust if you know them, or use our list.
# You need to list your trust in a 'vector' using 'c()' - the combine funciton.
# vectors are a basic building block in R and important to know.

ae_attendances |> 
  filter(org_code == c("R1H", "RF4", "RJ6", "RJ1", "RYJ")) |> 
  summarise(mean_average = mean(attendances),
            median_average = median(attendances),
            .by = c(org_code, type))

# we may want to reorder this output by mean_average
# we simply add another function to our pipe

ae_attendances |> 
  filter(org_code == c("R1H", "RF4", "RJ6", "RJ1", "RYJ")) |> 
  summarise(mean_average = mean(attendances),
            median_average = median(attendances),
            .by = c(org_code, type)) |>
  arrange(mean_average)

# more of a side note for sql users, once you have created a variable within a piped function,
# it is immediately available for use, no need for CTEs or sub queries


# We might use a pivot table in Excel on this kind of output.
# R has a similar syntax, allowing us to 'pivot_wider' (normal 'pivot) or 'pivot_longer' ('unpivot').
# Let's do this with the median attendances like above:

ae_attendances |> 
  filter(org_code == c("R1H", "RF4", "RJ6", "RJ1", "RYJ")) |>
  summarise(median_average = median(attendances),
            .by = c(org_code, type)) |> 
  pivot_wider(id_cols = org_code, 
              names_from = type, 
              values_from = median_average,
              names_sort = TRUE)


# RJ6 didn't have type 2 A&E
ae_attendances |> 
  filter(org_code == c("R1H", "RF4", "RJ6", "RJ1", "RYJ")) |>
  summarise(median_average = median(attendances),
            .by = c(org_code, type)) |> 
  pivot_wider(id_cols = org_code, 
              names_from = type, 
              values_from = median_average,
              names_sort = TRUE)

# lets create an object of that summary
ae_summary <- ae_attendances |> 
  filter(org_code == c("R1H", "RF4", "RJ6", "RJ1", "RYJ")) |>
  summarise(median_average = median(attendances),
            .by = c(org_code, type)) |> 
  pivot_wider(id_cols = org_code, 
              names_from = type, 
              values_from = median_average,
              names_sort = TRUE)

# we can feed our ae summary into the gt (great tables) function to convert
# it into a table
ae_summary |>
  gt() 

# dont like the NA in the table
# gt allows you to make amazing tables with notes, grouped columns
# span headers, mini graphs, icons, conditional formatting
# hyperlinks, multiple formats to publication level standards
ae_summary |>
  gt() |>
  sub_missing(
    columns = everything(),
    rows = everything(),
    missing_text = "-") |> 
  fmt_auto()


####################################################################################
# Visualisation using `ggplot2`
####################################################################################

# Most common plotting package in R. 
# Works in layer, connecting them with `+` and needs the following three parts:
# `data` =  and input data.frame
# Aesthetic `aes` = what data items control which parts of the plot. Usually columns in your data
# Geometric `geom_*` = shapes to draw on the plot

# Applying this to 'Barts' data let's plot the attendances on a line chart
# data = barts data.frame
# aes = attendances on the `y`/vertical axis, period on the `x`/horizontal axis
# geom = geom_line() function


barts |> ggplot(aes(y=attendances, x=period))+
  geom_line()

# That's a bit weird. Jumping up and down.
# Remember that Barts had three A&E types with difference numbers.
# We have a few options here:

# 1: Filter for each type,  showing just type 1 here, and using dplyr too:

barts |> 
  filter(type == "1") |> 
  ggplot(aes(y=attendances, x=period))+
  geom_line()

# 2:Add 'colour' as another aes, controlled by `type`:
barts |>
  ggplot(aes(y=attendances, x=period, colour = type))+
  geom_line()

# 3: use a `facet` function to split them out in many ways. We'll also kee the colour from the last one.
barts |>
  ggplot(aes(y=attendances, x=period, colour = type))+
  geom_line() +
  facet_wrap(facets = vars(type))

# we can even give each graph its own Y axis
barts |> 
  ggplot(aes(y=attendances, x=period, colour = type))+
  geom_line() +
  facet_wrap(facets = vars(type), scales = "free_y")


# Formatting and styling
# Colour palettes, themes, 
# Labelling, styles
# can also add dynamic information such as dates runs
# or automatic annotations and additional notes 

barts |>
  ggplot(aes(y = attendances, x = period, colour = type)) +
  geom_line(linewidth = 1.2) +
  labs(
    title = "A&E attendances at Bart's",
    subtitle = "Example chart from R training",
    caption = paste0(
      "Data taken from NHSR Dataset and run on ",
      format(Sys.Date(), "%d %b %y")),
    x = "Month",
    y = "A&E Attendances",
    colour = "A&E Type"
  ) +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_labels = "%b-%y", date_breaks = "3 month") +
  scale_colour_viridis_d() +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(face = "italic"),
    plot.caption = element_text(face = "italic")
  )

# Example:  SPC chart using 'Plot the dots' rules from NHSE's Making Data COunt
# NHS-R community built a package to do this for you called: 'NHSRplotthedots'

sub_set <- barts %>%
  filter(type == 1, 
         period < as.Date("2018-04-01"))

sub_set %>%
  ptd_spc(value_field = breaches, 
          date_field = period, 
          improvement_direction = "decrease")


## lets do a quick count of entries for the next bit
print(ae_attendances |>
  count(org_code, 
        sort = TRUE), 
  n = 14)


