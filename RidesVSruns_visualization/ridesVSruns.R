##load data

countries<-read.csv(file.choose(),header=TRUE)
totals<-read.csv(file.choose(),header=TRUE)

library(tmap)
library(tmaptools)
library(plyr)


data('World')
countries$name<-as.factor(countries$ï..country)
totals$name<-as.factor(totals$ï..name)
countries<-join(countries,totals,type="left",match="all")
RidesVSruns<- join(as.data.frame(World), countries, type = "left", match = "all")
RidesVSruns<-sf::st_as_sf(RidesVSruns)
class(World.01$rides_VS_runs)

##text size is proprotinal to the amount of observations from this country
tmap_mode("view")
tm_view(text.size.variable = TRUE)
tm_shape(RidesVSruns)+
  tm_polygons('rides_VS_runs',n=8,title="Normalized Rides-Runs")+
                tm_text("amount", remove.overlap = TRUE,size='text_size',col='text_col')

ans<-c()
ans_2<-c()


##modify text colour so we can see it clearly
for (i in (1:177)){
  x<-RidesVSruns$rides_VS_runs[i]
  if (!is.na(x)) {
    if (x>=0.6 | x<=-0.6){
      ans[i]<-'white'
      ans_2[i]<-0.6
    }
    else {
      ans[i]<-'black'
      ans_2[i]<-0.6
    }
  }
  else {
    ans[i]<-'black'
    ans_2[i]<-0.6
  }
  if (RidesVSruns$name[i]=='Brazil' | RidesVSruns$name[i]=='United States' | RidesVSruns$name[i]=='India' | RidesVSruns$name[i]=='United Kingdom'){
    ans[i]<-'red'
    ans_2[i]<-1.2
  }
}
RidesVSruns$text_col<-ans


countries_names<-as.data.frame(countries$name)
countries_out<-countries_out %>% filter(countries_out %in% countries_names)
countries_out<-as.data.frame(World$name[which(is.na(World.01$rides_VS_runs))])


##Runs&rie med 

runsMed<-read.csv(file.choose(),header=TRUE)
runsMed$name<-as.factor(runsMed$ï..name)
totals$name<-as.factor(totals$ï..name)
RunsMed<-join(as.data.frame(World),runsMed,type="left",match="all")
RunsMed<-sf::st_as_sf(RunsMed)
temp_2<-(log(RunsMed$athletes)+0.5)/1.5
RunsMed$text_size<-temp_2
tmap_ele
RidesVSruns$continent
RidesMed$athlets
ridesMed<-read.csv(file.choose(),header=TRUE)
ridesMed$name<-as.factor(ridesMed$ï..name)
RidesMed<-join(as.data.frame(World),ridesMed,type="left",match="all")
RidesMed<-sf::st_as_sf(RidesMed)
temp_2<-(log(RidesMed$athlets)+0.5)/1.5
RidesMed$text_size<-temp_2

Rides_VS_Runs<-RidesVSruns
qtm(RidesVSruns)
qtm(RunsMed)

##Runs VS Rides
tm_view(text.size.variable = TRUE)+
tm_shape(Rides_VS_Runs)+
  tm_polygons('rides_VS_runs',n=8,id='name', legend.show=FALSE)+
  #add_te
  tm_add_legend(type = "fill", labels = c('Mostly Runs','','','','Bit More Runs','Bit More Rides','','','','Mostly Rides','Missing'), title = 'Amount Comparison',
                col=c('#A50026','#D73027','#F46D43','#FDAE61','#FEE08B','#D9EF8B','#A6D96A','#66BD63','#1A9850','#006837','grey'))+
  tm_layout(title="Runs VS Rides")+tmap_options(basemaps = 'Esri.WorldTopoMap')
  
##we decided to split it to 2 different visualizations 

##Runs & Cyclings Distance Across Countries
  
  tm_shape(RunsMed)+
    tm_polygons('dist',breaks=c(0,3,5,7,9,12,Inf),title="Median Running Distance (KM)",id='name')+
  tm_shape(RidesMed)+
  tm_polygons('distance',palette = "Greens",breaks=c(0,7,15,22,30,37,45,52,60,Inf),title="Median Cycling Distance (KM)",id='name')+
  tm_layout(title="Runs & Cyclings Distance Across Countries")+tmap_options(basemaps = 'Esri.WorldTopoMap')
Rides_VS_Runs$rides_VS_runs

#we thought to set text inside each country instead of numbers, but eventually we decided not to use it

ids<-c()
for (i in (1:177)) {
    id = ''
    val = Rides_VS_Runs$rides_VS_runs[i] 
    val <- as.numeric(val)
    if (is.na(val)) {
      id= NA
    }
    else if (val >= 0.8) {
      id = 'mostly rides'
    }
    else if (val >= 0.6) {
      id = 'more rides'
    }
    else if (val >= 0.4) {
      id = 'some more rides'
    }
    else if (val >= 0.2) {
      id = 'bit more rides'
    }
    else if (val <= -0.8) {
      id = 'mostly runs'
    }
    else if (val <= -0.6) {
      id = 'more runs'
    }
    else if (val <= -0.4) {
      id = 'some more runs'
    }
    else if (val <= -0.2) {
      id = 'bit more runs'
    }

    ids[i]<-id
}

Rides_VS_Runs$Popular_Activity<-c(1:177)
#?? Rides_VS_Runs$Popular_Activity<-ids

for (i in (1:177)) {
  Rides_VS_Runs$Popular_Activity[i]<-ids[i]
}

#lets see from which colors the palette is build so we can set them in tm_add_legend
#we need this because we need to modify the legend names in RidesVsRuns

library('RColorBrewer')
#install.packages('Color Palette')
#palette.colors(n = 8, palette = "ReIGn")
brewer.pal(10, 'RdYlGn')

