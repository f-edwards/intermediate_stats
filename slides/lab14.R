library(tidyverse)
library(rstanarm)

mpv<-read_csv("./data/mpv_1_3_24.csv")

### make a state-year time series

mpv_sy<-mpv %>% 
  mutate(date = mdy(date),
         year = year(date)) %>% 
  group_by(state, year) %>% 
  summarize(n_deaths = n())

#### populate missings as explicit zeroes
state<-unique(mpv_sy$state)
year<-unique(mpv_sy$year)
joindat<-expand_grid(state, year)


dat_new<-joindat %>% 
  left_join(mpv_sy) %>% 
  mutate(n_deaths = 
           ifelse(is.na(n_deaths),
                  0,
                  n_deaths))

# ggplot(mpv_sy,
#        aes(x = year, y = n_deaths)) + 
#   geom_line() + 
#   facet_wrap(~state, scales = "free")
# 
# ggplot(mpv_sy,
#        aes(x = year, y = n_deaths,
#            group = state)) + 
#   geom_line(alpha = 0.25)
### if you want a pretty plot 
# library(geofacet)
# ggplot(mpv_sy,
#        aes(x = year, y = n_deaths)) + 
#   geom_line() + 
#   facet_geo(~state, scales = "free")
### fit a model to see 
# if death frequencies increase on average
## within states over time
dat_new<-dat_new %>% 
  mutate(year_c = year - 2013)

m0<-stan_glm(n_deaths ~ -1 + 
               year_c + 
               factor(state),
             data = dat_new,
             family = "poisson")

library(tidybayes)
dat_sim<-dat_new %>% 
  add_epred_draws(m0, 
                  ndraws = 200)

ggplot(dat_sim,
       aes(y = .epred, x = year_c)) + 
  stat_lineribbon(size = 0.5) + 
  facet_wrap(~state, scales = "free") + 
  scale_fill_brewer()

tx<-dat_sim %>% 
  filter(state=="TX")

ggplot(tx,
       aes(y = .epred, x = year_c)) + 
  stat_lineribbon(size = 0.5) + 
  geom_line(aes(y = n_deaths), 
            lty = 2) + 
  scale_fill_brewer()

### look at predicted vs observed
dat_pred<-dat_new %>% 
  add_predicted_draws(m0, 
                  ndraws = 200)

nynj<-dat_pred %>% 
  filter(state=="NY" | 
           state == "NJ")

ggplot(nynj,
       aes(y = .prediction, x = year_c)) + 
  stat_lineribbon(size = 0.5) + 
  geom_point(aes(y = n_deaths)) + 
  scale_fill_brewer() + 
  facet_wrap(~state)

beta1<-data.frame(m0)

ggplot(beta1,
       aes(x = exp(year_c))) + 
  geom_density()



