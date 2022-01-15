select country, distance,athlets= totals_2 from (
select country,distance,totals_2 = count(*) over (partition by country), rn_2 = ROW_NUMBER() over (partition by country order by distance) from (
select country,Athlete_ID, distance,totals=count(*) over (partition by athlete_ID,country),rn=ROW_NUMBER() over(partition by athlete_ID,country order by distance) from RUNS 
) as temp where rn=floor((totals+1)/2) or rn=ceiling((totals+1)/2)
) as temp2 where rn_2 = floor((totals_2+1)/2) or rn_2=ceiling((totals_2+1)/2)
order by distance desc
