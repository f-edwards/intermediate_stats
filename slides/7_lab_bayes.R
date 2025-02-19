library(tidyverse)
library(rstanarm)

# Let's use hibbs.dat for this one

dat<-read_delim("./data/hibbs.dat")

## visualizing
ggplot(dat,
       aes(x = growth, y = vote)) + 
  geom_point()

## estimate with stan_glm()

m1<-stan_glm(vote ~ growth,
         dat = dat)

posteriors_beta<-data.frame(m1)

ggplot(posteriors_beta,
       aes(x = growth)) + 
  geom_density() + 
  labs(subtitle = "Posterior distribution of B1")

ggplot(posteriors_beta,
       aes(x = X.Intercept.)) + 
  geom_density()

#### prediction 3 ways, from most certain to least certain
sim_dat<-data.frame(
  growth = 
    seq(-0.4, 4, by = 0.1))

e_y<-predict(m1, 
             newdata = sim_dat)

sim_dat$e_y<-e_y 
  
# here's our model fit
plot0<-ggplot(sim_dat,
       aes(x = growth, y = e_y)) + 
  geom_line()
# use posterior linpred to generate simulations of posterior X*Beta
e_y<-posterior_linpred(m1, newdata = sim_dat)
# compute medians
medians<-apply(e_y, 2, median)
# define function to pull 90 percent interva
get_interval90<-function(x){
  quantile(x, probs = c(0.05, 0.95))
}
# compute intervals
intervals<-apply(e_y, 2, get_interval90)
# stick together to plot it
plot_dat<-data.frame(post_med = medians,
                     post_lwr90 = intervals[1,],
                     post_upr90 = intervals[2,],
                     growth = sim_dat$growth)
# visualize
plot1<-ggplot(plot_dat,
       aes(x = growth,
           y = post_med,
           ymin = post_lwr90,
           ymax = post_upr90)) + 
  geom_line() + 
  geom_ribbon(alpha = 0.5) 
# a different way to get somewhere similar
# but this time with waaay more variation in y
yhat<-data.frame(posterior_predict(m1, 
                  newdata = sim_dat)) %>% 
  pivot_longer(cols = everything(),
               names_to = "row",
               values_to = "sim")
# compute needed quantities
yhat<-yhat %>% 
  group_by(row) %>% 
  summarize(post_med = median(sim),
            post_upr90 = quantile(sim, 0.95),
            post_lwr90 = quantile(sim, 0.05))
# need to make a key column to join
sim_dat<-sim_dat %>% 
  mutate(row_n = 1:nrow(sim_dat),
         row = paste("X", row_n, sep = "")) %>% 
  select(growth, row)

yhat<-yhat %>% 
  left_join(sim_dat)

plot2<-ggplot(yhat,
       aes(x = growth,
           y = post_med,
           ymin = post_lwr90,
           ymax = post_upr90)) + 
  geom_line() + 
  geom_ribbon(alpha = 0.5) 

### 3 kinds of predictions

library(patchwork)

plot0 + plot1 + plot2 
