require(RSocrata)
require(jsonlite)
require(dplyr)
# Address of API
api.address <- 'https://data.cms.gov/resource/x77v-hecv.csv'

ohio <- read.socrata(
  "https://data.cms.gov/resource/x77v-hecv.csv?nppes_provider_state=OH",
  app_token = "rPm0Ul8BPjZ8eJKRebNjNm9B3"#,
  # email     = "bonnie_jessica@bah.com",
  # password  = "qHSH9k3UotgU"
)

virginia <- read.socrata(
  "https://data.cms.gov/resource/x77v-hecv.csv?nppes_provider_state=VA",
  app_token = "rPm0Ul8BPjZ8eJKRebNjNm9B3"#,
  # email     = "bonnie_jessica@bah.com",
  # password  = "qHSH9k3UotgU"
)

connecticut <- read.socrata(
  "https://data.cms.gov/resource/x77v-hecv.csv?nppes_provider_state=CT",
  app_token = "rPm0Ul8BPjZ8eJKRebNjNm9B3"
)

westvirginia <- read.socrata(
  "https://data.cms.gov/resource/x77v-hecv.csv?nppes_provider_state=WV",
  app_token = "rPm0Ul8BPjZ8eJKRebNjNm9B3"
)



drugs <- unique(c(virginia$generic_name,westvirginia$generic_name,connecticut$generic_name,ohio$generic_name))
treatdrugs <- drugs[grepl('NALOXONE|METHADONE|BUPRENORPHINE|NALTREXONE',x = drugs,ignore.case = T)]

treaters <- rbind(virginia,westvirginia,connecticut,ohio) %>% filter(generic_name %in% treatdrugs)

addressesn2 <- lapply(treaters$npi,function(x){
  thing <- fromJSON(paste0('https://npiregistry.cms.hhs.gov/api?number=',x))
  blah <- as.data.frame(thing$results$addresses)
  if(nrow(blah) > 0){
  blah$npi <- x
  }
  return(blah)
})

addresses <- bind_rows(addressesn2) %>%
  filter(state %in% c('OH','WV','IN','CT'))
  


treaters2 <- merge(treaters,addresses,by="npi",all.x=T)

treaters.tmp <- treaters2 %>% filter(address_purpose == "LOCATION") %>%
  mutate(postal2 =substr(postal_code, 0, 5),
         uid=row_number()) 
treaters3 <- treaters.tmp %>%
  select(uid,address_1,city,state,postal2)

write.csv(treaters3[1:1000,],file = "treaters_forgeo1.csv",col.names =FALSE,q=FALSE,row.names = FALSE)
write.csv(treaters3[1001:2000,],file = "treaters_forgeo2.csv",col.names =FALSE,q=FALSE,row.names = FALSE)
write.csv(treaters3[2001:3000,],file = "treaters_forgeo3.csv",col.names =FALSE,q=FALSE,row.names = FALSE)
write.csv(treaters3[3001:4000,],file = "treaters_forgeo4.csv",col.names =FALSE,q=FALSE,row.names = FALSE)
write.csv(treaters3[4001:4796,],file = "treaters_forgeo5.csv",col.names =FALSE,q=FALSE,row.names = FALSE)


geocoded <- read.csv("~/Downloads/GeocodeResults1.csv",header=FALSE,stringsAsFactors = F)
for (i in 2:5){
  tmp <- read.csv(paste0("~/Downloads/GeocodeResults",i,".csv"),header=FALSE,stringsAsFactors = F)
geocoded <- rbind(geocoded,tmp)
}

treaters4 <- geocoded %>% 
  select(V1,V6) %>% 
  rename(uid=V1,latlong=V6) %>%
  merge(.,treaters.tmp,by="uid",all.y=T) %>%
  mutate(lon=strsplit(latlong,split=",")[[1]][1],
         lat=strsplit(latlong,split=",")[[1]][2]) %>%
  filter(generic_name != 'PENTAZOCINE HCL/NALOXONE HCL')


write.csv(file="./data/treatment_drug_prescribers_medicareD.csv",treaters4,row.names = F)

#Overdose Prevention Therapy Indiana (optIN) Registry (IN)
OD_prev_IN <- read.socrata('https://hhs-opioid-codeathon.data.socrata.com/resource/ytg4-cd6i.geojson')
https://hhs-opioid-codeathon.data.socrata.com/resource/ytg4-cd6i.csv


Indiana - Deaths from Drug Poisoning - Involving Herioin - 2012 to 2016
https://hhs-opioid-codeathon.data.socrata.com/State-Local-Datasets/Indiana-Deaths-from-Drug-Poisoning-Involving-Herio/bdd9-mnq2
https://hhs-opioid-codeathon.data.socrata.com/resource/y8pq-bkgk.csv


Indiana - Deaths from Drug Poisoning - Involving Opioid Pain Relievers - 2012 to 2016
https://hhs-opioid-codeathon.data.socrata.com/resource/xudd-pzkm.csv
https://hhs-opioid-codeathon.data.socrata.com/State-Local-Datasets/Indiana-Deaths-from-Drug-Poisoning-Involving-Opioi/bqzf-dxc6


Indiana - Deaths from Drug Poisoning - Involving Opioid Pain Relievers - 2015
https://hhs-opioid-codeathon.data.socrata.com/State-Local-Datasets/Indiana-Deaths-from-Drug-Poisoning-Involving-Opioi/vuhw-ww8r
https://hhs-opioid-codeathon.data.socrata.com/resource/8eyx-sd2k.csv

CDC WONDER Cause of Death – Multiple Cause (National)
https://hhs-opioid-codeathon.data.socrata.com/HHS-Datasets/CDC-WONDER-Cause-of-Death-Multiple-Cause-National-/uja2-sfu4
https://hhs-opioid-codeathon.data.socrata.com/resource/c3fc-ydnj.csv

Indiana - Substance Abuse Treatment - Non-Prescription Methadone - 2014
https://hhs-opioid-codeathon.data.socrata.com/resource/qc8g-ymzs.csv
https://hhs-opioid-codeathon.data.socrata.com/State-Local-Datasets/Indiana-Substance-Abuse-Treatment-Non-Prescription/psx7-grh8

National EMS Information System (NEMSIS) 2016 GEOCODES [RESTRICTED]
https://hhs-opioid-codeathon.data.socrata.com/resource/v2tz-e27e.csv
https://hhs-opioid-codeathon.data.socrata.com/Other-Federal-Datasets/National-EMS-Information-System-NEMSIS-2016-GEOCOD/ycuz-wph3
