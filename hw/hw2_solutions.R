library(tidyverse)

### 5.1
# a
shoot_baskets<-function(x){
  misses<-0
  baskets<-0
  while(misses<2){
    shot<-rbinom(1, 1, 0.6)
    baskets<-ifelse(shot==1, baskets + 1, baskets)
    misses<-ifelse(shot==0, misses + 1, misses)
  }
  return(c(baskets, misses))
}

# b 

n_sims<-1000
results<-data.frame(baskets = rep(NA, n_sims),
                    misses = rep(NA, n_sims))
for(i in 1:n_sims){
  results[i,]<-shoot_baskets()
}

results<-results %>% 
  mutate(total_shots = baskets + misses)

mean(results$total_shots)
sd(results$total_shots)

ggplot(results,
       aes(x = total_shots)) + 
  geom_histogram()

# c

results<-results %>% 
  mutate(prop_baskets = baskets / total_shots)

ggplot(results,
       aes(x = total_shots,
           y = prop_baskets)) + 
  geom_point()

### 5.2

# define functions to sample M and F weights

samp_m<-function(x){
  return(rnorm(x, 5.13, 0.17))
}
samp_f<-function(x){
  return(rnorm(x, 4.96, 0.2))
}

# define function to sample gender from 10 

samp_10<-function(x){
  return(n_fem<-rbinom(1, 10, 0.5))
}

# initiate empty DF for output
n_sims<-1000
output<-data.frame(total_weight = rep(NA, n_sims))
# simulate for solution
for(i in 1:1000){
  n_fem<-samp_10()
  n_mal<-10 - n_fem
  log_weights<-c(samp_m(n_mal), samp_f(n_fem))
  total_weight<-sum(exp(log_weights))
  output$total_weight[i]<-total_weight
}

# now evaluate proportion over limit
output<-output %>% 
  mutate(over_limit = total_weight > 1750)

# pr(over_limit = T)
mean(output$over_limit)

### 5.3
# a
dbinom(3, 10, 0.4)
# b 
# this works
mean(rbinom(10000, 10, 0.4)==3)
## so does this
n_sims<-10000
output<-rep(NA, n_sims)
make_shots<-function(x){
  shots<-rbinom(1, 10, 0.4)
  return(shots)
}
for(i in 1:n_sims){
  output[i]<-make_shots()
}
mean(output==3)

### 5.5
sim_x<-function(){
  heights<-rnorm(100, 69.1, 2.9)
  return(mean(heights))
}
sim_y<-function(){
  heights<-rnorm(100, 63.7, 2.7)
  return(mean(heights))
}

# prep for storage
n_sims<-1000
sim_data<-data.frame(x = rep(NA, n_sims),
                     y = rep(NA, n_sims))

for(i in 1:n_sims){
  sim_data$x[i]<-sim_x()
  sim_data$y[i]<-sim_y()
}

sim_data<-sim_data %>% 
  mutate(diff = x - y)
## visualize difference
ggplot(sim_data, 
       aes(x = diff)) + 
  geom_histogram()
## compute mean and sd of our sim values
mean(sim_data$diff)
sd(sim_data$diff)

## compute exact values
# mean is simple difference
69.1 - 63.7
# sd is the sum of the sqrt of the sum of the square of each SE
se_m<-2.9 / sqrt(100)
se_f<-2.7 / sqrt(100)

se_diff<-sqrt(se_m^2 + se_f^2)


