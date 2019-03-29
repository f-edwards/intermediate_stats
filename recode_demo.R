rm(list=ls())
library(tidyverse)
titanic<-read_csv('./slides/data/titanic_messy.csv')

######################################
## RENAME

### one way to recode names using base
# names(titanic)[which(
#   names(titanic)==
#     "Siblings/Spouses Aboard")]<-"sibs"
### another way to do the same thing in base
# recodes<-c("Siblings/Spouses Aboard", 
#            "Parents/Children Aboard")
# recode_values<-c("sibs", "kids")
# names(titanic)[which(
#   names(titanic)%in%recodes
# )]<-recode_values
# names(titanic)[5:6]<-c("sibs", "kids")
### or in dplyr
titanic<-titanic%>%
  rename(sibs = `Siblings/Spouses Aboard`,
         kids = `Parents/Children Aboard`)

names(titanic)<-tolower(names(titanic))

######################################
## EXPLORE FOR RECODE
unique(titanic$sex)
### HUH THAT'S WEIRD
unique(titanic$age)
### ALSO WEIRD
unique(titanic$pclass)
### Fine
titanic$fare[1:20]
### that's no good

######################################
## RECODING THE DATA
######### gender
titanic<-titanic%>%
  mutate(sex = case_when(
    #is.na(sex) ~ "missing",
    sex == "femlae" ~ "female",
    sex == "femlar" ~ "female",
    sex == "mule" ~ "male",
    ### LOTS OF WAYS TO DO THE SAME THING
    #sex %in% c("male", "female") ~ sex
    # sex=="male" ~ "male",
    # sex == "female" ~ "female"
    # sex=="male" ~ sex,
    # sex == "female" ~ sex
     !sex %in% c("femlae", "femlar", "mule") ~ sex
  ))

####### FARE
fare_length<-nchar(titanic$fare)
titanic<-titanic%>%
  mutate(fare =
           as.numeric(
             str_sub(fare, 
                     3, 
                     -1)))

####### AGE

titanic<-titanic%>%
  mutate(age_convert = as.numeric(age))

titanic_recodes<-titanic%>%
  filter(is.na(age_convert))

titanic_recodes<-titanic%>%
  mutate(age_convert = 
           case_when(
    str_detect(titanic$age, "a") ~ str_sub(age, 1,2),
    str_detect(age, "]") ~ str_sub(age, 1,2),
    str_detect(age, "&") ~ str_sub(age,1,2),
    str_detect(age, "%") ~ str_sub(age, 1,2)
  ))

titanic<-titanic%>%
  filter(is.na(age_convert))%>%
  bind_rows(titanic_recodes)

