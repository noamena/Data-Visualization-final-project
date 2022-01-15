with mbrs as (
select Athlete_ID, mbr_1 from (
select Athlete_ID,date_, mbr_1, ROW_NUMBER() over (partition by Athlete_ID order by date_ desc) as rn
from Activities where mbr_1 !='null' and group_activity=1) as temp where rn=1 and Athlete_ID in (select distinct partner_ from Activity_Partners)

) 
select at_last.Athlete_ID,at_last.gender,at_last.premium,at_last.followers_num,at_last.following_num,at_last.fav,at_last.g_ratio,
(case 
when at_last.overseas_partners is null then 0 
when at_last.overseas_partners is not null then at_last.overseas_partners
end) as overseas_p,

at_last.mbr_1
from (
select mbrs.Athlete_ID,Athletes.gender,Athletes.premium,followers_num,following_num,favr.fav,y.g_ratio,overseas_partners =r.amount,mbrs.mbr_1 from (
mbrs join(
select Athlete_ID,g_ratio=sum(convert(float,group_activity))/convert(float,count(*)) from Activities group by Athlete_ID
)
as y
on mbrs.Athlete_ID=y.athlete_ID
join (
select *, fav =
case 
when others>runs_totals AND others>rides_totals THEN 'other'
when others<runs_totals AND runs_totals>rides_totals THEN 'run'
when others<rides_totals AND runs_totals<rides_totals THEN 'ride'
end
from (

select athlete_ID,others = sum(activities)-sum(runs)-sum(bikes), runs_totals = sum(runs), rides_totals = sum(bikes) from summary group by athlete_ID
) as sums
) as favr 
on mbrs.Athlete_ID=favr.athlete_ID 
join Athletes on mbrs.Athlete_ID=Athletes.ID

left join

(

select athlete, amount = count(*) from (
select distinct partner_,athlete,partner_country = a.country,athlete_country = a2.country from 
(
(select * from Activity_Partners where partner_ in (select ID from athletes)) as v
join Athletes as a 
on v.partner_ = a.ID 
join 
Athletes as a2
on v.athlete=a2.ID
)) as temp
where partner_country!=athlete_country
group by athlete 

) as r
on mbrs.Athlete_ID=r.athlete
)
)as at_last