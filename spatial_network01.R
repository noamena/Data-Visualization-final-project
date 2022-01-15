##load vis_edgelist, vis_nodes

nodes<-read.csv(file.choose(),header= TRUE)
edges<-read.csv(file.choose(),header= TRUE)


library(sf)
library(tidygraph)
library(igraph)
library(dplyr)
library(tibble)
library(ggplot2)
library(units)
library(tmap)

library(osmdata)
library(rgrass7)
library(link2GI)
library(nabor)
as.character()
edges<-data.frame(from=edges$ï..from,to=edges$to,from_mbr=edges$from_mbr,to_mbr=edges$to_mbr)
nodes<-data.frame(Athlete_ID=nodes$ï..Athlete_ID,mbr_1=nodes$mbr_1)
lg_from<-strsplit(as.character(edges$from_mbr), ",")
lg_to<-strsplit(as.character(edges$to_mbr), ",")

lng_from<-c() 
lat_from<-c()
lng_to<-c() 
lat_to<-c()

for (i in (1:962)) {
  lng_from[i]<-as.numeric(lg_from[[i]][1])
  lat_from[i]<-as.numeric(lg_from[[i]][2]) 
  lng_to[i]<-as.numeric(lg_to[[i]][1])
  lat_to[i]<-as.numeric(lg_to[[i]][2])
}  
nodes$geometry
geom<-sprintf("LINESTRING(%s %s, %s %s)",lat_from,lng_from,lat_to, lng_to)
edges<-data.frame(athlete=edges$ï..athlete,partner=edges$partner,activity_type=edges$activity_type,amount=edges$amount,geom=geom)
temp<-edges$athlete
temp<-c(temp,edges$partner)
edges<-sf::st_as_sf(edges, wkt = "geom")
edges<-as.data.frame(edges)
nodes<-as.data.frame(nodes)
IDs<-nodes$Athlete_ID
edges<-edges %>% filter(from %in% IDs)
nodes<-nodes %>% filter(Athlete_ID %in% temp) 
lg<-strsplit(as.character(nodes$mbr_1), ",")
lng<-c() 
lat<-c()

for (i in (1:260)) {
  lng[i]<-as.numeric(lg[[i]][1])
  lat[i]<-as.numeric(lg[[i]][2])
}
edges$geometry
edges<-data.frame(from=edges$from,to=edges$to,activity_type=edges$activity_type,amount=edges$amount,geom=geom)
nodes<-data.frame(Athlete_ID=nodes$ï..Athlete_ID,gender=nodes$gender,isPremium=nodes$premium,followers_num=nodes$followers_num,following_num=nodes$following_num,fav_activity=nodes$fav,g_ratio=nodes$g_ratio,overseas_p=nodes$overseas_p,latitude=lat,longitude=lng)

edge_col<-c()
types<-unique(edges$activity_type)
types
for (i in (1:962)) {
  type<-edges$activity_type[i]
  if (type=='Ride' | type=='Handcycle' | type=='Ride-Commute' | type == 'E-Bike Ride') {
    foo = 'red'
    type = 'ride'
  }
  if (type=='Run' | type=='Long Run' | type=='Run-Commute') {
    foo = 'blue'
    type = 'run'
  }
  if (type=='Walk' |type=='Hike') {
    foo = 'black'
    type = 'walk'
  }
  if (type=='Virtual Ride') {
    foo = 'orange'
    type = 'virtualride'
  }
  else {
    type = 'pink' #Ski/Canoe
  }
  edge_col[i]<-foo
}

node_col<-c() ##each colour represent the favourite activity 

for (i in (1:260)) {
  favourite<-nodes$fav_activity[i]
  if (favourite=='run') {
    node_col[i]<-'blue'
  }
  if (favourite=='ride') {
    node_col[i]<-'red'
  }
  if (favourite=='other') {
    node_col[i]<-'black'
  }
}
workous_commute<-data.frame(edges$athlete[which(edges$activity_type=='Workout-Commute')],edges$partner[which(edges$activity_type=='Workout-Commute')])
edges$activity_type[which(edges$activity_type=='Workout-Commute')]<-'Ride'


races<-data.frame(edges$athlete[which(edges$activity_type=='Race')],edges$partner[which(edges$activity_type=='Race')])
workouts<-data.frame(edges$athlete[which(edges$activity_type=='Workout')],edges$partner[which(edges$activity_type=='Workout')])
workouts$types<-c('Ride','Ride','Ride','Ride','Run','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Walk','Walk','Ride','Ride','Ride','Ride','Walk','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Run','Walk','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride','Ride')
edges$activity_type[which(edges$activity_type=='Workout')] <-workouts$types
nodes<-sf::st_as_sf(nodes, coords = c("latitude","longitude"), crs = 4326)
graph<-tbl_graph(nodes = nodes, edges = as_tibble(edges), directed = FALSE)
#nodes$<-as.character(nodes$geometry)

##at first we tried to visualize the whole network
##after that we decided to split it into 4 networks, one for each activity_type

##here we thought to represent col node as favorite activity, and the size as the number of partners overseas for each athlete

edges$to<-as.character(edges$to)
nodes$Athlete_ID<-as.character(nodes$Athlete_ID)
nodes$d<-degree(graph)
nodes$temp_2<-temp_2
tmap_mode('view')
tm_shape(graph %>% activate(edges) %>% as_tibble() %>% st_as_sf()) +
  tm_lines('edge_col') +
  tm_shape(graph %>% activate(nodes) %>% as_tibble() %>% st_as_sf()) +
  tm_dots(col = 'node_col',size = 'overseas_p') +
  tmap_options(basemaps = 'OpenStreetMap')


tm_add_legend("fill", 
                labels = c('type_1','type_2,','type_3'),
                col = c('red','blue','black') ,
                title = "My Legend")

##after that we thought to represent the percent of group activity the athlete has as the node colour/size

nodes$g_ratio



trans<-transitivity(graph,"localundirected") ##we thought to represent the clustering coefficient for each athlete as the node size/color
trans<-trans+1.5
nodes$trans<-(trans-1)/8
edges$from<-as.character(edges$from)
edges$to<-as.character(edges$to)
nodes$Athlete_ID<-as.character(nodes$Athlete_ID)


