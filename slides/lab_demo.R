library(tidyverse)

# estimate a regression of kid score ~ mom age

dat<-read_csv("./data/kidiq.csv")

m0<-lm(kid_score ~ mom_age, 
       data = dat)

ggplot(dat,
       aes(x = mom_age, y = kid_score)) + 
  geom_point(alpha = 0.25) + 
  geom_abline(intercept = coef(m0)[1],
              slope = coef(m0)[2], 
              color = "red") + 
  labs(x = "Mother's age", 
       y = "Kid test score",
       title = "Linear fit of test score by age") + 
  theme_minimal()
  #geom_smooth(method = "lm")
# the expected child's test score is 0.7 points higher
# for each year of mom's age

## add another predictor: mothers edu
## this is the good one 
ggplot(dat,
       aes(x = mom_age, y = kid_score)) + 
  geom_point(alpha = 0.25) + 
  geom_abline(intercept = coef(m1)[1],
              slope = coef(m1)[2], 
              color = "red") + 
  geom_abline(intercept = coef(m1)[1] + coef(m1)[3],
              slope = coef(m1)[2], 
              color = "blue") + 
  labs(x = "Mother's age", 
       y = "Kid test score",
       title = "Linear fit of test score by age") + 
  theme_minimal()
## not so good
ggplot(dat,
       aes(x = mom_age, y = kid_score)) + 
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm") + 
    facet_wrap(~mom_hs)

m1<-lm(kid_score ~ mom_age + mom_hs, 
       data = dat)

m2<-lm(kid_score ~ mom_age + mom_hs + 
         mom_age * mom_hs, 
       data = dat)
### same thing less code
m3<-lm(kid_score ~ mom_age * mom_hs, 
       data = dat)

data_training<-dat[1:200,]
data_test<-dat[201:400,]

m2_train<-lm(kid_score ~ mom_age + mom_hs + 
         mom_age * mom_hs, 
       data = data_training)

yhat_test<-predict(m2_train,
                   newdata = data_test)
### get set up to plot
data_test<-data_test %>% 
  mutate(yhat = predict(m2_train,
                        newdata = data_test))

ggplot(data_test,
       aes(x = yhat,
           y = kid_score)) + 
  geom_point() + 
  geom_abline(intercept = 0, slope = 1)
