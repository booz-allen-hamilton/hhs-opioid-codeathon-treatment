require(jsonlite)
require(dplyr)
require(RSocrata)

indiana_od_prev <- read.socrata('https://hhs-opioid-codeathon.data.socrata.com/resource/ytg4-cd6i.csv',
             app_token = "XXXXXXXXXXXXXXX",
             email     = "XXX@XXX.com",
             password  = "XXXXXXXXXXX")

withlatlong <- indiana_od_prev %>%
  mutate(long=gsub("\\(",replacement="",strsplit(geocoded_column,split = " ",)[[1]][2]),
                lat=gsub(')',replacement="",strsplit(geocoded_column,split=" ")[[1]][3]))
write.csv(withlatlong,file="indiana_od_prev.csv",row.names = FALSE)
