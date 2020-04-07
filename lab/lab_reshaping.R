library(tidyverse)

fe<-read_csv("fatal_encounters.csv")

fe<-fe %>% 
  rename(age = "Subject's age",
         gender = "Subject's gender",
         race = "Subject's race",
         year = "Date (Year)") %>% 
  select(year, age, gender, race)

table(fe$race)

fe %>% 
  group_by(race) %>% 
  summarise(n = n())

### fix the typos!

fe <- fe %>% 
  mutate(race = 
           case_when(
             race == "African-American/Black" ~ "African American",
             race == "Asian/Pacific Islander" ~ "Asian/Pacific Islander",
             race == "European American/White" ~ "White",
             race == "European-American/White" ~ "White",
             race == "Hispanic/Latina" ~ "Latinx",
             race == "Hispanic/Latino" ~ "Latinx",
             race == "HIspanic/Latino" ~ "White",
             race == "Middle Eastern" ~ "White",
             race == "Native American/Alaskan" ~ "American Indian/AK Native",
             race == "Race unspecified" ~ "NA"))

### check out gender

table(fe$gender)

fe<-fe %>% 
  mutate(gender = 
           ifelse(gender == "Femalr", 
                  "Female",
                  ifelse(gender == "Transexual", ### nest the ifelse
                         "Transgender", 
                         ifelse(gender == "White",
                                "NA",
                                gender)))) 

### remove non-numerics from age

fe<-fe %>% 
  mutate(age = as.numeric(age))

##### read in the pop data

pop<-read_csv("pop_nat.csv")

### Make the FE data the same shape as the pop data
### reshape the FE data to be national-level by age, sex, and race, year
fe<-fe %>% 
  mutate(age = case_when(
    age<1 ~ "0",
    age<5 ~ "1-4",
    age<10 ~ "5-9",
    age<15 ~ "10-14",
    age<20 ~ "15-19",
    age<25 ~ "20-24",
    age<30 ~ "25-29",
    age<35 ~ "30-34",
    age<40 ~ "35-39",
    age<45 ~ "40-44",
    age<50 ~ "45-49",
    age<55 ~ "50-54",
    age<60 ~ "55-59",
    age<65 ~ "60-64",
    age<70 ~ "65-69",
    age<75 ~ "70-74",
    age<80 ~ "80-84",
    age>=85 ~ "85+"
  ))

### aggregate to the national by age, sex, and race, year

fe<-fe %>% 
  group_by(year, age, gender, race) %>% 
  summarise(deaths = n())

## here's how we go to wide

fe_wide<-fe %>% 
  pivot_wider(id_cols = c(year, age, gender),
              names_from = race, values_from = deaths)

### here's how we go back

fe_long<-fe_wide %>% 
  pivot_longer(cols = `American Indian/AK Native`:`Asian/Pacific Islander`,
               names_to = "race") %>% 
  mutate(value = ifelse(is.na(value),
                        0,
                        value)) %>% 
  rename(deaths = value) %>% 
  rename(sex = gender)

### let's think about the join

### to fill in the missings, we could use complete()
### I'm going to use a join()
fe_pop <- pop %>% 
  filter(year>=2000) %>% 
  left_join(fe_long) %>% 
  mutate(deaths = ifelse(is.na(deaths),
                         0, 
                         deaths)) 

fe_pop <- fe_pop %>% 
  mutate(death_rate = deaths / pop * 1e5)


fe_pop_total<-fe_pop %>% 
  group_by(year, race, sex) %>% 
  summarise(death_rate = sum(deaths)/sum(pop) * 1e5) 

ggplot(fe_pop_total %>% 
         filter(year>2008),
       aes(x = year, y = death_rate, color = race)) + 
  geom_line() + 
  facet_wrap(~sex, scales = "free_y")

fe_demo<-fe_pop %>% 
  group_by(year, sex, race) %>% 
  summarise(deaths = sum(deaths),
            pop = sum(pop)) %>% 
  filter(year>2008) 

write_csv(fe_demo, "fe_no_age.csv")