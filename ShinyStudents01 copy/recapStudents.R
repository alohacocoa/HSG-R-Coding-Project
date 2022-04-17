# A super quick recap of the students dataset
# milan.kuzmanivic@student.unisg.ch and peter.gruber@usi.ch
# 2017-04-16

# FIRST: set the working directory!
# Type ctrl-L to clear the console

rm(list = ls())
graphics.off()

library(ggplot2)
load("Student.RData")

# so far
ggplot(data = grade, aes(x = math, y = stats, col = gender)) +
  geom_point(size=3) + xlim(2.5,6.5) + ylim(2.5,6.5) + coord_fixed() 

# slightly new command: aes_string requires quotation marks
ggplot(data = grade, aes_string(x = "math", y = "stats", col = "gender")) +
  geom_point(size=3) + xlim(2.5,6.5) + ylim(2.5,6.5) + coord_fixed() 

# this makes the following possible
myXvariable <- "econ"
myYvariable <- "arts"
ggplot(data = grade, aes_string(x = myXvariable, y = myYvariable, col = "gender")) +
  geom_point(size=3) + xlim(2.5,6.5) + ylim(2.5,6.5) + coord_fixed()

# Now change the plot so that we see econ against arts
