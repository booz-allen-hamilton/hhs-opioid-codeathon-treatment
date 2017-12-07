library(lubridate)
CT<-read.csv("~/Downloads/CT-DrugRelated-2012-17.csv")
CT$Date<-as.Date(CT$Date,format='%m/%d/%Y')
CT$Year<-year(CT$Date)

CT <- filter(CT,Year %in% c(2015,2016))
CT$DeathLoc <- as.character(CT$DeathLoc)

addresses3 <- lapply(CT$DeathLoc,function(x){
  what <- str_extract_all(x,pattern = "[0-9\\.\\-]+")
  coords <- what[[1]]
  urlstring <- paste0('http://data.fcc.gov/api/block/find?format=json&latitude=',coords[1],'&longitude=',coords[2],'&showall=true')
  thing <- fromJSON(urlstring)
  return(thing)
  # blah <- as.data.frame(thing$results$addresses)
  # if(nrow(blah) > 0){
  #   blah$npi <- x
  # }
  # return(blah)
})

df <- as.data.frame(addresses3[[1]]$County)
df$FIPS <- as.character(df$FIPS)
for (i in 2:length(addresses3)){
  tmp <- as.data.frame(addresses3[[i]]$County)
  tmp$FIPS <- as.character(tmp$FIPS)
  df <- rbind(df,tmp)
}
CT <- cbind(CT,df) %>% rename(DeathFIPS=FIPS,DeathCounty=name)

#from here on, i filter by residence.county, instead want to filter by deathloc (lat,lon) then convert this lat,lon to county/fips.
#please keep the filtering of cocaine and heroin to keep the "opioids" count accurate.

CT_heroin <- CT %>%
  filter(Year,Heroin=="Y") %>%
  group_by(Year,DeathCounty,DeathFIPS) %>%
  summarise(death_ct=n())
CT_heroin$Type<-"Heroin"
CT_notH <- filter(CT,Heroin!="Y")
CT_notH <- filter(CT_notH,!(tolower(ImmediateCauseA) %in% c("cocaine","cocaine toxicity","acute cocaine toxicity",
                                                  "cocaine intoxication","acute cocaine intoxication",
                                                  "acute cocaine intoxicaton",
                                                  "complications of cocaine and ethanol intoxication",
                                                  "the combined effects of cocaine and alcohol",
                                                  "complications of cocaine toxicity",
                                                  "complications of intracerebral hemorrhage due to acute cocaine intoxication",
                                                  "acute intoxication due to the combined effects of cocaine and alcohol",
                                                  "acute intoxication due to the combined effects of cocaine and ethanol",
                                                  "intracerebral hemorrhage due to acute cocaine intox")))
CT_other <- CT_notH %>% group_by(Year,DeathCounty,DeathFIPS) %>%
  summarise(death_ct=n())
CT_other$Type<-"Opioids"
CT_mortality_1516<-rbind(CT_heroin,CT_other)

fipzip <- read.csv("./data/whateverman.csv",stringsAsFactors = FALSE) %>%
  mutate(zip=formatC(zip,width=5,flag = "0",format="d"),
         county=formatC(county,width=5,flag = "0",format="d"))

CT_final <- merge(CT_mortality_1516,fipzip,by.x="DeathFIPS",by.y="county",all.x=TRUE) %>%
  select(-X,-State.FIP)
write.csv(CT_final,file="./data/CT_mortality.csv",row.names = FALSE)
