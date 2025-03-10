library(tidyverse)
library(rstanarm)

dat<-read_csv("./data/binary.csv")

# fit a model
m0<-stan_glm(admit ~ gre,
             data = dat,
             family = "binomial")

m1<-stan_glm(admit ~ gre + gpa,
             data = dat,
             family = "binomial")

m2<-stan_glm(admit ~ gre * gpa,
             data = dat,
             family = "binomial")

loo_compare(loo(m0), loo(m1), loo(m2))

m2_s<-stan_glm(admit ~ scale(gre) * 
                 scale(gpa),
             data = dat,
             family = "binomial")

# FOR GRE = 1 AND GPA = 1.2
# E(log odds) = b_0 + b_1 * 1 + b_2 * 1.2
# + b_3 * 1 * 1.2

# gre = 2, gpa = 1
# -0.8 + 0.3 * 2 + 0.3 * 1 + -0.2 * 2 * 1

# i imagine a lo/med/hi GRE and GPA combo
gre<-c(400, 600, 800)
gpa<-c(2.5, 3.3, 4.0)
fake_data<-expand_grid(gre, gpa) 

fake_data<-fake_data%>% 
  mutate(yhat = predict(m2_s, 
                        newdata = fake_data))

ggplot(fake_data,
       aes(x = gpa,
           y = exp(yhat))) + 
  geom_line() + 
  facet_wrap(~gre)

m2_post<-data.frame(m2_s)

ggplot(m2_post,
       aes(x = scale.gre.)) + 
  geom_histogram()

# a standard deviation increase in GRE
# is associated with an increase in the log
# odds of admission of between 0.1 and 0.6 
# (90% posterior interval) WHN GPA IS AT THE 
# MEAN


# estimate model 3
m3<-stan_glm(admit ~ 
               scale(gre) * scale(gpa) + 
               factor(rank),
             data = dat,
             family = "binomial")

m3_post<-data.frame(m3)

ggplot(m3_post,
       aes(x = factor.rank.3)) + 
  geom_histogram()



gre<-c(400, 600, 800)
gpa<-c(2.5, 3.3, 4.0)
rank<-c(1, 2, 3, 4)
fake_data<-expand_grid(gre, gpa, rank) 

library(tidybayes)

fake_data<-fake_data %>% 
  add_epred_draws(m3)

temp<-epred_draws(m3, newdata= fake_data)

ggplot(fake_data,
       aes(x = gpa,
           y = .epred)) + 
  stat_lineribbon() + 
  scale_fill_brewer() + 
  facet_grid(rank ~ gre)
  








