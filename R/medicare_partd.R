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

addresses2 <- lapply(addresses,function(x){
  return(as.data.frame(x$results$addresses))
  
})

addresses3 <- bind_rows(addresses2)

npi_info <- read.csv('~/Downloads/NPPES_Data_Dissemination_112717_120317_Weekly/npidata_20171127-20171203.csv',stringsAsFactors = F) %>%
  mutate(npi = as.character(NPI))

treaters2 <- merge(treaters,npi_info[
  c("npi","Entity.Type.Code","Employer.Identification.Number..EIN.",
    "Provider.Organization.Name..Legal.Business.Name.",
    "Provider.Credential.Text"),],by="npi",all.x=T)
treaters2[is.na(treaters2$Entity.Type.Code),] %>% nrow()


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