with rides as (select * from Activities where
activity_type='Ride' or activity_type='Handcycle' or activity_type ='Ride-Commute' or activity_type='E-Bike Ride' or activity_type='Virtual Ride' or (
(activity_type='workout' or activity_type='Race' or activity_type='Race-Commute' or activity_type= 'Workout-Commute') 
and pace_units != '/km')
) 

select *,(convert(float,total_rides-total_runs)/convert(float,(total_rides+total_runs))) as rides_VS_runs from (
select 
(case when v.country is not null then v.country
when m.country is not null then m.country end) as country,
(case when ride_amount is not null then ride_amount else 0 end) as total_rides,
(case when run_amount is not null then run_amount else 0 end) as total_runs from (
select country,ride_amount=count(*) from rides group by country) as v
full join
(
select country,run_amount=count(*) from runs group by country) as m
on v.country=m.country ) as t
