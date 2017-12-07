

#https://data.ct.gov/resource/htz8-fxbk.json?credential=Substance


narc <- read.csv("~/Downloads/narc_forreduce.csv",stringsAsFactors = FALSE) %>%
  select(-X,-X.1) %>%
  mutate(Zip=formatC(Zip,width = 5,format = "d",flag = "0"))


breakup <- function(textstring,part,sep){
  return(strsplit(textstring,split=sep)[[1]][part])
}

narc.tmp <- narc %>% mutate(uid = row_number()) %>% rowwise() %>%
  mutate(address1=trimws(breakup(Location,1,";")),
         address2=trimws(breakup(Location,2,";")),
         address3=trimws(breakup(Location,3,";")),
         countyname=trimws(str_extract(sub("Connecticut*|Indiana*|Ohio*|West Virginia*","",trimws(address3)),"[a-zA-Z ]+")),
         state=ifelse(
           Name=="Ohio","OH",ifelse(Name=="Indiana","IN",ifelse(Name=="Connecticut","CT",ifelse(Name=="West Virginia","WV",NA)))),
         address=paste(address2,countyname,state,Zip,sep=",")) 


narc.for.cross <- narc.tmp %>% select(uid,address)
write.csv(file="narc_lookup.csv",narc.for.cross,row.names = FALSE,quote = FALSE)

narc.geocode <- read.csv("~/Downloads/GeocodeResults_NARC.csv",stringsAsFactors = F,header=FALSE)

test <- narc.geocode %>% 
  select(V1,V6) %>% 
  rename(uid=V1,latlong=V6) %>%
  merge(.,narc.tmp,by="uid",all.y=T) %>%
  mutate(lon=strsplit(latlong,split=",")[[1]][1],
         lat=strsplit(latlong,split=",")[[1]][2]) %>%
  rename(venue=address1)


write.csv(test,file="NARC_meetings.csv")
