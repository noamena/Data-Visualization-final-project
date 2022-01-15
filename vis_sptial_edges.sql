with edge_list as (
select Athlete_ID, mbr_1 from (
select Athlete_ID,date_, mbr_1, ROW_NUMBER() over (partition by Athlete_ID order by date_ desc) as rn
from Activities where mbr_1 !='null' and group_activity=1) as temp where rn=1 and Athlete_ID in (select distinct partner_ from Activity_Partners)

)

select m2.partner_,m2.athlete,activity_type, amount = count(*), m2.from_mbr,m2.to_mbr from (
select m.partner_, m.athlete,m.activity,v.mbr_1 as from_mbr, v2.mbr_1 as to_mbr  from
edge_list as v
join 
(
select partner_,athlete,activity from Activity_Partners where partner_ in (select distinct Athlete_ID from Activities))
as m
on v.Athlete_ID=m.partner_
join edge_list as v2
on v2.Athlete_ID=m.athlete

where partner_ in(select Athlete_ID from edge_list) and athlete in (select Athlete_ID from edge_list) and partner_!=athlete
) as m2 
join Activities on m2.activity=ID 
group by m2.partner_,m2.athlete,activity_type, m2.from_mbr,m2.to_mbr
