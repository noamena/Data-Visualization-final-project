with rides as (select * from Activities where
activity_type='Ride' or activity_type='Handcycle' or activity_type ='Ride-Commute' or activity_type='E-Bike Ride' or activity_type='Virtual Ride' or (
(activity_type='workout' or activity_type='Race' or activity_type='Race-Commute' or activity_type= 'Workout-Commute') 
and pace_units != '/km')
)


select country, distance,athlets= totals_2 from (
select country,distance,totals_2 = count(*) over (partition by country), rn_2 = ROW_NUMBER() over (partition by country order by distance) from (
select country,Athlete_ID, distance,totals=count(*) over (partition by athlete_ID,country),rn=ROW_NUMBER() over(partition by athlete_ID,country order by distance) from rides 
) as temp where rn=floor((totals+1)/2) or rn=ceiling((totals+1)/2)
) as temp2 where rn_2 = floor((totals_2+1)/2) or rn_2=ceiling((totals_2+1)/2)
order by distance desc
