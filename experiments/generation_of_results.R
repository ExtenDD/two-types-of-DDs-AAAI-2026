library(dplyr)
library(ggplot2)
library(scales)

setwd("C:/projekt_UŁ/python/AAAI 26/Datasets")


#reading the data attached to the appendix
g01 <- read.csv("GD_0.1.csv")
g03 <- read.csv("GD_0.3.csv")
g05 <- read.csv("GD_0.5.csv")

l01 <- read.csv("LD_0.1.csv")
l03 <- read.csv("LD_0.3.csv")
l05 <- read.csv("LD_0.5.csv")

NoDesc <-  read.csv("NoDesc.csv")



#merging the data
g01$data <- "g01"
g03$data <- "g03"
g05$data <- "g05"
l01$data <- "l01"
l03$data <- "l03"
l05$data <- "l05"
NoDesc$data <- "NoDesc"

all <- rbind(g01, g03, g05,l01, l03, l05, NoDesc)



#creating the reduced version of the data (excluding selected concepts) ----

#data for Table 1
all_red <- all %>% 
  filter(time_out == "False", no_rules_applied>1)


#data for the chart - reducing a small number of concepts of size over 800 for the chart
all_red_chart <- all %>% 
  filter(time_out == "False", no_rules_applied>1, form_size<801)



#data for Table 1 ----
all_red %>% 
  group_by(data) %>% 
  summarise(runtime_mean = mean(time_tableau_min),
            runtime_st_dev = sd(time_tableau_min),
            n=n())



#scatterplot ----

#recoded variable for the segments of formula sizes to be shown on the chart (for the dashed line)
all_red_chart$form_size_rec <- case_when(all_red_chart$form_size %in% 0:100 ~ "1",
                                         all_red_chart$form_size %in% 101:200 ~ "2",
                                         all_red_chart$form_size %in% 201:300 ~ "3",
                                         all_red_chart$form_size %in% 301:400 ~ "4",
                                         all_red_chart$form_size %in% 401:500 ~ "5",
                                         all_red_chart$form_size %in% 501:600 ~ "6",
                                         all_red_chart$form_size %in% 601:700 ~ "7",
                                         all_red_chart$form_size %in% 701:800 ~ "8")


all_red_chart$data_grouped <- case_when(all_red_chart$data %in% c("g01", "g03", "g05") ~ "GlobalDesc",
                                        all_red_chart$data %in% c("l01", "l03", "l05") ~ "LocalDesc",
                                        all_red_chart$data == "NoDesc" ~ "NoDesc")



#generate data for the dashed lines on the chart (inserted in the chart definition below)
chart_dash_line <-   all_red_chart %>% 
  group_by(data_grouped,form_size_rec) %>% 
  summarise(mean(time_tableau_min))



ggplot(all_red_chart, aes(x=form_size, y = time_tableau_min, color=factor(data_grouped))) +
  geom_point(size=2, alpha=0.5)+
  #scale_color_brewer(palette = "Set1") +
  #  geom_smooth(method="lm", se=FALSE)+
  #scale_y_log10()+
  scale_y_continuous("Runtime  (s)",
                     trans='log10',
                     breaks=trans_breaks('log10', function(x) 10^x),
                     labels=trans_format('log10',
                                         math_format(10^.x)),
                     guide = guide_axis_logticks())+
  scale_x_continuous("Concept size",
                     #limits=c(0,800),
                     breaks=seq(0,1000,100))+
  scale_color_manual(
    values = c("red", "green3","blue"),
    name = "",                       # Custom legend title
    labels = c("Local descriptions", "Global descriptions","No descriptions")      # Custom legend labels
  )+
  theme_classic() +
  theme(axis.ticks = element_blank(),
        panel.grid.major=element_line(color="grey"),
        legend.position = "bottom",
        legend.text = element_text(size = 11))+
  geom_segment(
    aes(x = 50, y = 0.0223, xend = 150, yend = 0.0676),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 150, y = 0.0676, xend = 250, yend = 0.665),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 250, y = 0.665, xend = 350, yend = 0.565),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 350, y = 0.565, xend = 450, yend = 0.727),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 450, y = 0.727, xend = 550, yend = 0.792),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 550, y = 0.792, xend = 650, yend = 0.846),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 650, y = 0.846, xend = 750, yend = 1.02),
    color = "green3", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 50, y = 0.00179, xend = 150, yend = 0.00507),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 150, y = 0.00507, xend = 250, yend = 0.0409),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 250, y = 0.0409, xend = 350, yend = 0.0306),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 350, y = 0.0306, xend = 450, yend = 0.0426),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 450, y = 0.0426, xend = 550, yend = 0.0265),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 550, y = 0.0265, xend = 650, yend = 0.196),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 650, y = 0.196, xend = 750, yend = 0.114),
    color = "blue", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 50, y = 0.0419, xend = 150, yend = 0.0274),
    color = "red", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 150, y = 0.0274, xend = 250, yend = 0.267),
    color = "red", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 250, y = 0.267, xend = 350, yend = 0.287),
    color = "red", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 350, y = 0.287, xend = 450, yend = 0.209),
    color = "red", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 450, y = 0.209, xend = 550, yend = 0.419),
    color = "red", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 550, y = 0.419, xend = 650, yend = 0.910),
    color = "red", size = 1.5, linetype = "dashed")+
  geom_segment(
    aes(x = 650, y = 0.910, xend = 750, yend = 0.678),
    color = "red", size = 1.5, linetype = "dashed")




