##### demonstration of prediction 
##### using coef() to manually calculate
##### and predict() to automatically calculate

### clear the workspace
rm(list=ls())

### load the library
library(tidyverse)

### read the data in 
real_data<-read_csv("./data/hw_2_data.csv")
### make a variable, violent crimes per 1000 pop
real_data<-real_data%>%
  mutate(violent.pc = violent.crimes / pop_tot * 1000)

### run a model
model1<-lm(violent.pc ~ dissim_bw + dissim_wl,
           data= real_data)

### extract betas from model object
betas<-coef(model1)
### inspect
betas

### calculate yhat (predicted values) on observed
yhat<-betas[1] + betas[2] * real_data$dissim_bw + betas[3] * real_data$dissim_wl

### plot observed v predicted
plot(yhat, real_data$violent.pc)
### this is a terribly fitting model! but oh well...

### predict for fake data (manual)
### make interesting data for prediction (low segregation on both measures)
fake_data_scenario1<-data.frame("dissim_bw" = min(real_data$dissim_bw),
                                "dissim_wl" = min(real_data$dissim_wl))

### beta0 + beta1x1 + beta2x2
yhat_1<-betas[1] + 
  betas[2] * fake_data_scenario1$dissim_bw + 
  betas[3] * fake_data_scenario1$dissim_wl

### using predict()
yhat_2<-predict(model1, 
                newdata = fake_data_scenario1)
### with confindence intervals. Note that lwr and upr are 95 percent CI bounds
### these are useful for plotting!
yhat_2<-predict(model1, 
                newdata = fake_data_scenario1,
                interval = "confidence")
### are they equal, yes sir!
yhat_1 == yhat_2