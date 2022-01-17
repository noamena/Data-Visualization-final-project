select challenges_completed,av_act,av_distRun,av_distRide,premiums = convert(float,premiums)/convert(float,amount) from (
select challenges_completed,amount=count(*), av_act=AVG(activities), av_distRun=avg(dist_run), av_distRide=avg(dist_ride),premiums=sum(premium) from (
select (case
when amount_2=0 then '0'
when amount_2<11 then '1-10'
when amount_2<26 then '11-25'
when amount_2<41 then '26-40'
when amount_2<81 then '41-80'
when amount_2<131 then '81-130'
when amount_2<201 then '131-200'
when amount_2<351 then '201-350'
when amount_2>350 then '>350'
end
) as challenges_completed,

activities, dist_run,dist_ride,premium=premium from (
select athlete_ID,premium=avg(convert(float,premium)), amount_2=sum(challenges_joined), activities=sum(activities), dist_run=avg(dist_run),dist_ride=avg(dist_ride) from (summary join Athletes on summary.athlete_ID=Athletes.ID) where premium is not null group by summary.athlete_ID
) as temp) as temp2
group by challenges_completed) as temp3
order by av_act desc, av_distRun desc
