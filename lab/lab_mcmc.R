# ### fresh installs of rstan and rethinking
# 
# remove.packages(c("rstan"))
# if (file.exists(".RData")) file.remove(".RData")
# 
# install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE)
# 
# devtools::install_github("rmcelreath/rethinking")
# 
# ## confirm that your C++ toolchain is working
# pkgbuild::has_build_tools(debug = TRUE)
# ## If not, follow guide on 
# ## https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started

library(rethinking)
library(tidyverse)

### WORKING THROUGH QUESTION 9H2 in the book

data(WaffleDivorce)

### D ~ dnorm(mu, sigma)
### mu <- a + bA * A
### a ~ N(0, 0.2)
### bA ~ N(0, 0.5)
### sigma ~ Exp(1)

d<-WaffleDivorce %>% 
  mutate(D = scale(Divorce),
         A = scale(MedianAgeMarriage),
         M = scale(Marriage))

m5.1 <- quap(alist(
  D ~ dnorm(mu, sigma),
  mu <- a + bA * A,
  a ~ dnorm(0, 0.2),
  bA ~ dnorm(0, 0.5),
  sigma ~ dexp(1)
), data = d)

d_slim<-list(
  D = d$D,
  A = d$A,
  M = d$M
)

m9.1 <- ulam(alist(
  D ~ dnorm(mu, sigma),
  mu <- a + bA * A,
  a ~ dnorm(0, 0.2),
  bA ~ dnorm(0, 0.5),
  sigma ~ dexp(1)
), data = d_slim, chains = 1, cores = 1)

m9.1.4 <- ulam(alist(
  D ~ dnorm(mu, sigma),
  mu <- a + bA * A,
  a ~ dnorm(0, 0.2),
  bA ~ dnorm(0, 0.5),
  sigma ~ dexp(1)
), data = d_slim, chains = 4, cores = 1, log_lik = T)

m9.2 <- ulam(alist(
  D ~ dnorm(mu, sigma),
  mu <- a + bM * M,
  a ~ dnorm(0, 0.2),
  bM ~ dnorm(0, 0.5),
  sigma ~ dexp(1)
), data = d_slim, chains = 2, cores = 2, log_lik = T)

m9.3 <- ulam(alist(
  D ~ dnorm(mu, sigma),
  mu <- a + bM * M + bA * A,
  a ~ dnorm(0, 0.2),
  bA ~ dnorm(0, 0.5),
  bM ~ dnorm(0, 0.5),
  sigma ~ dexp(1)
), data = d_slim, chains = 2, cores = 2)

### check out traceplots for convergence diagnostics
traceplot(m9.1.4)

### visualize m9.3

sim_dat<-data.frame(
  M = 0,
  A = seq(-2, 2, length.out = 100)
)

mu_post<-sim(m9.3, sim_dat)

mu_mn<-apply(mu_post, 2, mean)
mu_pi<-apply(mu_post, 2, PI)

sim_dat<-sim_dat %>% 
  mutate(mu_mn = mu_mn,
         mu_lwr = mu_pi[1,],
         mu_upr = mu_pi[2,])

ggplot(sim_dat, aes(x = A, y = mu_mn,
                    ymin = mu_lwr, 
                    ymax = mu_upr)) + 
  geom_line() + 
  geom_ribbon(alpha = 0.5)
