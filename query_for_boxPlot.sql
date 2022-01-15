select v.ID,
(
select count(temp.from_athlete) from 
(select * from  kudos join activities as a2 on kudos.activity=a2.ID) as temp
where temp.from_athlete = v.Athlete_ID and temp.date_<v.date_ and temp.date_>= v.last_date
) as kudos_byAthlete_SinceLastAct, 

(
select count(temp.from_athlete) from 
(select * from  comments join activities as a2 on comments.activity=a2.ID) as temp
where temp.from_athlete = v.Athlete_ID and temp.date_<v.date_ and temp.date_>= v.last_date
) as comments_byAthlete_SinceLastAct


from Activities_withLastDates as v 