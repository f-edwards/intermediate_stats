### make a directory for all this data
dir.create("./lab/data_test")
### assign teacher test scores over 5 years
for(year in 1:5){
  ### assign class test scores
  for(i in 1:13){
    temp<-data.frame(class = i,
                     year = year,
                     test_scores = 
                       rnorm(20, mean = 75 + rnorm(1, 5, 2),
                             sd = 5))
    file_name<-paste("./lab/data_test/test",year, "_",  i, ".csv", sep = "")
    write.csv(temp, file = file_name)
  }
}