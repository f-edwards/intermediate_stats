#### logistic regression
# using wells.csv
# data on people changing source of well water
# in rural bangladesh with notification of arsenic levels
library(tidyverse)
library(rstanarm)

## read
wells<-read_csv("./data/wells.csv")

# EDA
# first lets look at 'switch'
table(wells$switch)

## univariates
ggplot(wells,
       aes(x = arsenic)) + 
  geom_histogram()

ggplot(wells,
       aes(x = dist)) + 
  geom_histogram()
# start with a table on educ
table(wells$educ)

ggplot(wells,
       aes(x = educ)) + 
  geom_histogram()

table(wells$assoc)

# bivariates
ggplot(wells,
       aes(x = arsenic, y = dist)) + 
  geom_point() 

ggplot(wells,
       aes(x = arsenic, y = educ)) + 
  geom_jitter()

ggplot(wells,
       aes(x = arsenic)) + 
  geom_density() + 
  facet_wrap(~switch, 
             ncol = 1)

ggplot(wells,
       aes(x = arsenic,
           color = factor(switch))) + 
  geom_density() + 
  theme(legend.position = "bottom")

ggplot(wells,
       aes(x = arsenic,
           color = educ == 0)) + 
  geom_density() + 
  theme(legend.position = "bottom")
# model fitting
## let's fit a model

# logit(p) = \beta_0 + \beta_1 arsenic
# Switch ~ Bernoulli(p)
m0<-stan_glm(switch ~ arsenic,
             data = wells,
             family = "binomial")

### extract posteriors for B1

new_data<-data.frame(arsenic = 
                       seq(0, 5, by = 0.1))

p<-predict(m0, 
        newdata = new_data,
        type = "response")

new_data<-new_data %>% 
  mutate(p = p)

ggplot(new_data,
       aes(x = arsenic, y = p)) + 
  geom_point()

# model comparison using LOO
m0

m1<-stan_glm(switch ~ scale(arsenic) + 
               scale(dist),
             data = wells,
             family = "binomial")

m2<-stan_glm(switch ~ scale(arsenic) * 
               scale(dist),
             data = wells,
             family = "binomial")

m2<-stan_glm(switch ~ scale(arsenic) * 
               scale(dist),
             data = wells,
             family = "binomial")

m3<-stan_glm(switch ~ scale(arsenic) * 
               scale(dist) + scale(educ),
             data = wells,
             family = "binomial")

m0_loo<-loo(m0)
m1_loo<-loo(m1)
m2_loo<-loo(m2)
m3_loo<-loo(m3)

loo_compare(m0_loo,
            m1_loo, 
            m2_loo,
            m3_loo)
