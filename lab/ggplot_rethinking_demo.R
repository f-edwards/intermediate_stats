library(rethinking)
library(tidyverse)

data(mtcars)

### visualize relationship between hp and wt
ggplot(mtcars, 
       aes(y = hp, x = wt)) + 
  geom_point()

### sounds good - let's model it

ggplot(mtcars,
       aes(x = hp)) + 
  geom_histogram()

## E(hp) = mu = alpha + beta * wt

temp<-rnorm(1e2, 2, 1)

## b ~ dlnorm(2, 1)
## a ~ dnorm(10, 10)

m0<-quap(alist(
  hp ~ dnorm(mu, sigma),
  mu <- alpha + beta * wt,
  alpha ~ dnorm(10,10),
  beta ~ dlnorm(2,1),
  sigma ~ dexp(1)
), data = mtcars)

### plot out the posterior distributions of the parameters

post_samples<-extract.samples(m0)

ggplot(post_samples, aes(x = alpha)) + 
  geom_density()

ggplot(post_samples, aes(x = beta)) + 
  geom_density()

### plot out the posterior for mu

post_mu_plot_dat<-data.frame(wt = 
                               seq(0, 5, length.out = 101))

post_mu<-link(m0, data = post_mu_plot_dat)

post_mu_mn <- apply(post_mu, 2, mean)
post_mu_pi <- apply(post_mu, 2, PI)

post_mu_plot_dat<- post_mu_plot_dat %>% 
  mutate(mu_mn = post_mu_mn,
         mu_lwr = post_mu_pi[1,],
         mu_upr = post_mu_pi[2,])

ggplot(post_mu_plot_dat, 
       aes(x = wt, y = mu_mn,
           ymin = mu_lwr, ymax = mu_upr)) + 
  geom_line() + 
  geom_ribbon(alpha = 0.5)

## posterior predictive 

post_pred<-sim(m0, data = post_mu_plot_dat)

post_hp_mn <- apply(post_pred, 2, mean)
post_hp_pi <- apply(post_pred, 2, PI)

post_mu_plot_dat<-post_mu_plot_dat %>% 
  mutate(hp_lwr = post_hp_pi[1,],
         hp_upr = post_hp_pi[2,])

ggplot(post_mu_plot_dat, 
       aes(x = wt, y = mu_mn,
           ymin = mu_lwr, ymax = mu_upr)) + 
  geom_line() + 
  geom_ribbon(alpha = 0.5) + 
  geom_ribbon(aes(ymin = hp_lwr, ymax = hp_upr), alpha = 0.5)

## For checking model fit

fit_post_pred<-sim(m0)
fit_hp_pi <- apply(fit_post_pred, 2, PI)

mtcars<-mtcars %>% 
  mutate(hp_lwr = fit_hp_pi[1,],
         hp_upr = fit_hp_pi[2,])

ggplot(mtcars, aes(x = wt, y = hp,
                   ymin = hp_lwr, ymax = hp_upr)) + 
  geom_point(aes(color = factor(cyl))) + 
  geom_ribbon(alpha = 0.5)
