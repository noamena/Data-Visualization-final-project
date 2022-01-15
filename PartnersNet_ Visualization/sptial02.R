
##now we create 4 networks, one for run,ride,virtual-ride and walk.

##the edge color represents the activity type from spatial_network01 script
edges_rides<-edges %>% filter (edges$edge_col== 'red') 
edges_runs<-edges %>% filter (edges$edge_col =='blue')
edges_walks<-edges %>% filter (edges$edge_col =='black')
edges_virtuals<-edges %>% filter (edges$edge_col =='orange')

nodes_rides<-nodes %>% filter (nodes$Athlete_ID %in% edges_rides$from |nodes$Athlete_ID %in% edges_rides$to)
nodes_runs<-nodes %>% filter (nodes$Athlete_ID %in% edges_runs$from |nodes$Athlete_ID %in% edges_runs$to)
nodes_walks<-nodes %>% filter (nodes$Athlete_ID %in% edges_walks$from |nodes$Athlete_ID %in% edges_walks$to)
nodes_virtuals<-nodes %>% filter (nodes$Athlete_ID %in% edges_virtuals$from |nodes$Athlete_ID %in% edges_virtuals$to)
rides<-tbl_graph(nodes = nodes_rides, edges = as_tibble(edges_rides), directed = FALSE)
runs<-tbl_graph(nodes = nodes_runs, edges = as_tibble(edges_runs), directed = FALSE)
walks<-tbl_graph(nodes = nodes_walks, edges = as_tibble(edges_walks), directed = FALSE)
virtuals_rides<-tbl_graph(nodes = nodes_virtuals, edges = as_tibble(edges_virtuals), directed = FALSE)


edges_virtuals<-data.frame(edges_virtuals$from,edges_virtuals$to,athlete=edges_virtuals$from,partner=edges_virtuals$to,activity_type=edges_virtuals$activity_type,amount=edges_virtuals$amount,edges_virtuals$geom)




nodes_rides$Rides_avg_dist<-as.numeric(nodes_rides$Rides_avg_dist)
nodes_runs$Runs_avg_dist<-as.numeric(nodes_runs$Runs_avg_dist)
dists_walks<-data.frame(Athlete_ID=dists_walks$ï..Athlete_ID,avg_dist=dists_walks$avg_dist)
dists_rides<-read.csv(file.choose(),header=TRUE) #each athlete and his average in this kind of activity
dists_runs<-read.csv(file.choose(),header=TRUE)
dists_virtuals<-read.csv(file.choose(),header=TRUE)
dists_walks<-read.csv(file.choose(),header=TRUE)
nodes_rides<-sf::st_as_sf(nodes_rides)
nodes_runs<-sf::st_as_sf(nodes_runs)
nodes_walks<-sf::st_as_sf(nodes_walks)
edges_virtuals<-sf::st_as_sf(edges_virtuals)
nodes_rides$
nodes_rides$geometry
library(plyr)
partners_rides$

nodes_runs<- join(as.data.frame(nodes_runs), dists_runs, type = "left", match = "all")
nodes_rides<- join(as.data.frame(nodes_rides),dists_rides, type = "left", match = "all")
nodes_virtuals<- join(as.data.frame(nodes_virtuals), dists_virtuals, type = "left", match = "all")
nodes_walks<- join(as.data.frame(nodes_walks), dists_walks, type = "left", match = "all")

#nodes_rides$partners<-(nodes_rides$partners/10)+1
#nodes_rides$partners

##get the percentage of group activities (from same type) for every athlete participates in group activity

g_ratio_rides<-dbGetQuery(conn, "select Athlete_ID,g_ratio_rides=sum(convert(float,group_activity))/convert(float,count(*)) from Activities where
activity_type='Ride' or activity_type='Handcycle' or activity_type ='Ride-Commute' or activity_type='E-Bike Ride'
group by Athlete_ID
having sum(convert(float,group_activity)) > 0")

g_ratio_runs<-dbGetQuery(conn, "select Athlete_ID,g_ratio_runs=sum(convert(float,group_activity))/convert(float,count(*)) from Activities where
activity_type='Run' or activity_type='Long Run' or activity_type ='Run-Commute'
group by Athlete_ID
having sum(convert(float,group_activity)) > 0")

g_ratio_virtuals<-dbGetQuery(conn, "select Athlete_ID,g_ratio_virt=sum(convert(float,group_activity))/convert(float,count(*)) from Activities where
activity_type='Virtual Ride'
group by Athlete_ID
having sum(convert(float,group_activity)) > 0")

g_ratio_walks<-dbGetQuery(conn, "select Athlete_ID,g_ratio_walks=sum(convert(float,group_activity))/convert(float,count(*)) from Activities where
activity_type='Walk' or activity_type='Hike'
group by Athlete_ID
having sum(convert(float,group_activity)) > 0")



nodes_runs<- join(as.data.frame(nodes_runs), g_ratio_runs, type = "left", match = "all")
nodes_rides<- join(as.data.frame(nodes_rides),partners_rides, type = "left", match = "all")
nodes_virtuals<- join(as.data.frame(nodes_virtuals), g_ratio_virtuals, type = "left", match = "all")
nodes_walks<- join(as.data.frame(nodes_walks), g_ratio_walks, type = "left", match = "all")
#nodes_rides$partners<-log2(nodes_rides$partners)+1

#min(nodes_rides[which(!is.na(nodes_rides$partners))])
#nodes_rides$partners<-(nodes_rides$partners)*3
#log(nodes_rides$partners,1)
#nodes_rides$partners<-log(nodes_rides$partners)


#we thought to represent the number of partners from each activity_type as the node size/colour

##it is not the same as node degree because not all of the athlete's partners are in the network (they are not in athletes table)
partners_rides<-dbGetQuery(conn,"select Athlete_ID, partners = count(distinct partner_) from Activity_Partners join Activities on athlete=Athlete_ID
where activity_type='Ride' or activity_type='Handcycle' or activity_type ='Ride-Commute' or activity_type='E-Bike Ride'
group by Athlete_ID") 
## we decided not to use it eventually 

#nodes_rides$partners<-(nodes_rides$partners+10)/2
#nodes_rides$partners<-
#nodes_rides$partners<-partners_rides
#nodes_virtuals$g_ratio_virt
#nodes_virtuals$overseas_p
#nodes_rides$partners<-nodes_rides$partners+4
#edges_rides$amount<-edges_rides$amount*100

##size if followers_num, color is by the athlete avg dist in this activity 

tmap_mode('view')
tm_shape(rides %>% activate(edges) %>% as_tibble() %>% st_as_sf()) +
  tm_lines('#000F61') +
  tm_shape(rides %>% activate(nodes) %>% as_tibble() %>% st_as_sf()) +
  tm_dots('Rides_avg_dist',breaks = c(0,25,50,75,90,Inf),size='followers_num') +  tm_shape(runs %>% activate(edges) %>% as_tibble() %>% st_as_sf()) +
  tm_lines('#a45b63') +
  tm_shape(runs %>% activate(nodes) %>% as_tibble() %>% st_as_sf()) +
  tm_dots('Runs_avg_dist',size='followers_num') +
  tm_shape(walks %>% activate(edges) %>% as_tibble() %>% st_as_sf()) +
  tm_lines('#5ba49c') +
  tm_shape(walks %>% activate(nodes) %>% as_tibble() %>% st_as_sf()) +
  tm_dots('Walks_avg_dist', breaks = c(0,3,6,9,12,Inf),size='followers_num') +
  tm_shape(virtuals_rides %>% activate(edges) %>% as_tibble() %>% st_as_sf()) +
  tm_lines('#a99992') +
  tm_shape(virtuals_rides %>% activate(nodes) %>% as_tibble() %>% st_as_sf()) +
  tm_dots('VirtualsRides_avg_dist',breaks=c(0,15,30,45,60,Inf),size='followers_num') +
  tmap_options(basemaps = 'OpenStreetMap')+
  tm_layout(title="Activity Partners Network")+
tm_add_legend("fill", 
              labels = c('Ride','Run,','Walk','Virtual-Ride'),
              col = c('#000F61','#a45b63','#5ba49c','#a99992') ,
              title = "activity_type")

edges_rides$athlete<-edges_rides$from
edges_rides$partner<-edges_rides$to
edges_rides<- data.frame(from=edges_rides$athlete,to=edges_rides$partner,athlete=edges_rides$athlete,partner=edges_rides$partner,activity_type=edges_rides$activity_type,amount=edges_rides$edges_rides.edges_rides.amount,edges_rides$geometry)
nodes_runs$Runs_avg_dist<-nodes_runs$avg_dist
nodes_rides$Rides_avg_dist<-nodes_rides$avg_dist
nodes_virtuals$VirtualsRides_avg_dist<-nodes_virtuals$avg_dist
nodes_walks$Walks_avg_dist<-nodes_walks$avg_dist
