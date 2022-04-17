# Working with colors in ggplot2
# milan.kuzmanivic@student.unisg.ch and peter.gruber@usi.ch
# 2017-03-12

# FIRST: set the working directory!

# Type ctrl-L to clear the console
rm(list=ls())                   # Delete all variables
Sys.setenv(LANG = "en")         # Set language to English

library(ggplot2)
library(RColorBrewer)
# if this line does not work --> install the package
install.packages("RColorBrewer")          # Solution

load("Student.RData")

## Case 1: Specify *fixed colors* (i.e. NOT a function of the data)
# --> Color is in geom, not in aes!!
# Changing colors in the barplots we had created before

# Change the fill color by specifying fill = c("color1","color2",...)
ggplot(data = grade, aes(x = country)) + geom_bar(width = 0.4)
ggplot(data = grade, aes(x = country)) + 
  geom_bar(width = 0.4, fill=c("grey1","deeppink4","darkslateblue"))

# Specify a color in the RGB system
rgb(1,0,0)                   # Output: R uses "hexadecimal code"
rgb(red=1,blue=0,green=0)

# Alternative notation
rgb(255,0,0,max=255)         # Specify up to 255

## How to
ggplot(data = grade, aes(x = gender)) + 
  geom_bar(fill = c(rgb(1,0.2,0.7),rgb(0.5,0.5,1))) # 1st red, 2nd green

## Exercises
# change the colors in the above plot using the RGB system to darker red and a fitting darker green
ggplot(data = grade, aes(x = gender)) + 
  geom_bar(fill = c(rgb(0.5,0,0),rgb(0,0.4,0))) # solution

# Case 2: Specify colors for an aes with a *categorical* variable 
# Check the data structure first
str(grade)                                              # Solution

# Use scale_fill_manual(values = c("color1","color2","color3")
ggplot(grade,aes(gender, fill = country)) + geom_bar() 
ggplot(grade,aes(gender, fill = country)) + geom_bar() + 
  scale_fill_manual(values = c("magenta", "deepskyblue", "chocolate"))

# Add a few labels
ggplot(data = grade, aes(x = gender, fill = country)) + 
  geom_bar(position = "dodge") +
  scale_fill_manual("Countries", labels = c("Austria", "Switzerland","Germany"),
                    values = c("purple", "orange", "yellow"))

# Case 2a: Specify colors for an aes in a scatterplot
ggplot(data = grade, aes(x = math, y = stats, col = gender)) +
  geom_point(size = 2)

ggplot(data = grade, aes(x = math, y = stats, col = gender)) +
  geom_point(size = 2) +
  scale_color_manual("Gender", labels = c("Girls","Boys"), 
                     values = c(rgb(1,0.5,0.5), "dodgerblue")) +
  xlab("Mathematics") + ylab("Statistics")

ggplot(data = grade, aes(x = math, y = stats, col = gender)) +
  geom_point(size = 2) +
  scale_color_manual("Gender", labels = c("Girls","Boys"), 
                     values = c(rgb(0,0,0.5), rgb(1,0.7,0.7))) +
  xlab("Mathematics") + ylab("Statistics")

# Add a shape to convey 4th variable
ggplot(data = grade, aes(x = math, y = stats, col = gender, 
       shape=country)) + geom_point(size = 2) 
  
ggplot(data = grade, aes(x = math, y = stats, col = gender, shape=country)) + geom_point(size = 2) +
  scale_color_manual("Gender", labels = c("Girls","Boys"), values = c("firebrick", "dodgerblue")) +
  scale_shape_manual("Countries", labels=c("Austria","Switzerland", "Germany"),
                     values=c(0,1,2))

# Change the shapes so that they are filled shapes
ggplot(data = grade, aes(x = math, y = stats, col = gender, shape=country)) + geom_point(size = 4) +
  scale_color_manual("Gender", labels = c("Girls","Boys"), values = c("firebrick", "dodgerblue")) +
  scale_shape_manual(values=c(15,16,17))

# Case 3: Adding additional continuous variable to scatterplot
# Watch the 3 cases -- different interpretations
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 2)
ggplot(data = grade, aes(x = math, y = stats, col = econ)) + geom_point(size = 2)
ggplot(data = grade, aes(x = math, y = econ, col = arts)) + geom_point(size = 2)

# Change the color using scale_color_gradient()
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) +
  scale_color_gradient(low = rgb(0.9,0.9,0.9), high = rgb(0.1,0.1,0.1))

# scale_color_gradient2() allows for supplying the midpoint
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) +
  scale_color_gradient2(high = "green", mid="blue", low = "red",midpoint = 4.8)

ggplot(data = grade, aes(x = math, y = stats, col = gender)) + geom_point(size = 2) +
  scale_color_manual("Gender",breaks = c("female", "male"), labels = c("Girls","Boys"),
                     values = c("firebrick", "dodgerblue"))

## RColorBrewer: predefined "optimal" palettes
# instead of scale_color/fill_manual, use scale_color/fill_brewer
# instead of scale_color_gradient, use scale_color_distiller
# and specify palletes form RColorBrewer 

# There are 3 types of palettes
# a) sequential
# b) qualitative
# c) diverging

# To see the available palettes run below:
?RColorBrewer
display.brewer.all() 

# Specific examples
display.brewer.pal(6,name="Set2") 
display.brewer.pal(10,name="Set2")   # read the warning!

display.brewer.pal(4,name="YlOrRd") 
display.brewer.pal(9,name="YlOrRd") 

display.brewer.pal(5,name="RdYlGn") 

# Back to our plots
#  Case 4a) we don't specify anything -> sequential palette. Good choice?
ggplot(data = grade, aes(x = gender, fill = country)) +  
  geom_bar(position = "dodge") +
  scale_fill_brewer()

# Case 4b) we specify the type (can be "div"/"qual"/"seq")
ggplot(data = grade, aes(x = gender, fill = country)) +  
  geom_bar(position = "dodge") +
  scale_fill_brewer(type = "qual")

# Case 4c) we specify the palette
ggplot(data = grade, aes(x = gender, fill = country)) + 
  geom_bar(position = "dodge")  +
  scale_fill_brewer(palette = "Set3")

# Scatterplot
# Remember
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) 

# Case 5a) Change color using brewer
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) +
  scale_color_brewer()
# Doesn't work since the palette has finite/discrete number of colors and here
# we assign continuous variable to color

# RColorBrewer palettes can be used, however with a function that converts them to continuous colors
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + 
  geom_point(size = 3) +
  scale_color_distiller(palette = "Blues")

## ** Our own color palette
# Can we produce our own palette based on the HCL system?

# Case 6a) change h = color angle
h1<-0      # "base" angle
h2<-h1 + 90  # rotate 1/4 circle
c <-80       # color intensity
l <-55      # lightness
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) +
  scale_color_gradient(low = hcl(h1,c,l), high = hcl(h2,c,l))

# Case 6b) change  c = color intensity
h <-240       # hue = color shade
c1<-0         # base color intensity
c2<-80        # final color intensity
l <-65        # lightness
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) +
  scale_color_gradient(low = hcl(h,c1,l), high = hcl(h,c2,l))

# Case 6c) change  l = brightness
h <-60        # hue = color shade
c <-80        # color intensity
l1<-80        # initial lightness
l2<-20        # final lightness
ggplot(data = grade, aes(x = math, y = stats, col = arts)) + geom_point(size = 3) +
  scale_color_gradient(low = hcl(h,c,l1), high = hcl(h,c,l2))

# Which one can be perceived best?

# Now change ...
# In case 6a)
# ... h1
# ... c to zero
# ... l to zero

# In case 6b)
# ... h
# ... c1,c2
# ... l to zero

# In case 6c)
# ... h
# ... c to zero
# ... l1,l2