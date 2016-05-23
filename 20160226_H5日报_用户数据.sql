
--用户数据
--日期	赚恒大币人数	赚恒大币	花恒大币人数	花恒大币	累计赚恒大币	累计花恒大币	当前恒大币存量

select a.*
    ,Total_Gain_points
    ,Total_Spend_points
    ,Total_Curr_points
from(
select  tx_dt
        ,count(distinct case when Distr_Point_Cnt>0 then Usr_ID end) as gain_user
        ,sum(Distr_Point_Cnt) as gain_amount
        ,count(distinct case when Consm_Point_Cnt>0 then Usr_ID end) as pay_user
        ,sum(Consm_Point_Cnt) as pay_amount

from csum.H52_MP_Point_TX_Csum a 
left outer join idata.h99_Camp_Act_Typ_Cd d
on a.Camp_Act_Typ_Cd=d.Camp_Act_Typ_Cd
where tx_dt >='2016-03-06'
and tx_dt <='2016-03-06'
group by TX_Dt
)a
join(
select   '2016-03-06'as statt_dt
        ,sum(Accm_Consm_Point) as Total_Spend_points --历史数据还在导入
        ,sum(Accm_Obted_Point) as Total_Gain_points --历史数据还在导入
        ,sum(Curr_Point_Bal) as Total_Curr_points
from csum.H52_MP_Usr_Csum_D
where  statt_dt='2016-03-06'
)b
on a.tx_dt=b.statt_dt;

2016-03-06      56500   480605  5714    172590  2701044 1234070 458446386


--拉霸用户
--日期	当日拉霸用户	当日投注恒大币	当日赚取恒大币	当日盈利率	
--累计拉霸用户	累计投注恒大币	累计赚取恒大币	累计盈利率

select a.*
    ,(td_pay_amount-td_gain_amount)/td_pay_amount
    ,all_usr
    ,pay_amount
    ,gain_amount
    ,(pay_amount-gain_amount)/pay_amount

from(
    select   tx_dt
            ,count(distinct usr_id) as td_usr
            ,sum(Consm_Point_Cnt) as td_pay_amount
            ,sum(Distr_Point_Cnt) as td_gain_amount
    from csum.H52_MP_Point_TX_Csum a
    left outer join idata.h99_Camp_Act_Typ_Cd d
    on a.Camp_Act_Typ_Cd=d.Camp_Act_Typ_Cd
    where camp_act_typ_desc='拉霸'
    and tx_dt='2016-03-06'
    group by tx_dt
)a
join(
select  '2016-03-06' as tx_dt
        ,count(distinct usr_id) as all_usr
        ,sum(Consm_Point_Cnt) as pay_amount
        ,sum(Distr_Point_Cnt) as gain_amount
from csum.H52_MP_Point_TX_Csum a
left outer join idata.h99_Camp_Act_Typ_Cd d
on a.Camp_Act_Typ_Cd=d.Camp_Act_Typ_Cd
where camp_act_typ_desc='拉霸'
and tx_dt<='2016-03-06'
)b
on a.tx_dt=b.tx_dt;

--扫码人群活跃度
--日期	 新用户 				 老用户 			
--	扫码	 拉霸业务 	 兑换业务 	 花恒大币(去重) 	扫码	 拉霸业务 	 兑换业务 	 花恒大币(去重) 
select   tx_dt
        ,count(distinct case when b.usr_id is not null and camp_act_typ_desc='有效扫码' then a.usr_id end) as new_sao
        ,count(distinct case when b.usr_id is not null and camp_act_typ_desc='拉霸' then a.usr_id end) as new_laba
        ,count(distinct case when b.usr_id is not null and camp_act_typ_desc='恒大币兑换' then a.usr_id end) as new_dui
        ,count(distinct case when b.usr_id is not null and camp_act_typ_desc in('拉霸','恒大币兑换')then a.usr_id end) as new_spend
        ,count(distinct case when  b.usr_id is  null and camp_act_typ_desc='有效扫码' then a.usr_id end) as old_sao
        ,count(distinct case when  b.usr_id is  null and camp_act_typ_desc='拉霸' then a.usr_id end) as old_laba
        ,count(distinct case when  b.usr_id is  null and camp_act_typ_desc='恒大币兑换' then a.usr_id end) as old_dui
        ,count(distinct case when  b.usr_id is  null and camp_act_typ_desc in('拉霸','恒大币兑换')then a.usr_id end) as old_spend
from csum.H52_MP_Point_TX_Csum a
left outer join csum.H52_MP_Usr_Base_Info b
on a.usr_id=b.usr_id and substr(create_tm,1,10)=tx_dt
left outer join idata.h99_Camp_Act_Typ_Cd d
on a.Camp_Act_Typ_Cd=d.Camp_Act_Typ_Cd
where tx_dt<='2016-03-10'
group by tx_dt;


--扫码频次人群分布
select a.tx_dt
,case when a.times =1 then '1次'
when a.times =2 then '2次'
when a.times =3 then '3次'
when a.times =4 then '4次'
when a.times =5 then '5次'
when a.times <=10 then '5-10次'
when a.times <=20 then '10-20次'
else '>20次' end as times_tag
,count(distinct a.usr_id)
--,sum(a.times)
from(select tx_dt,usr_id,count(*) as times
from csum.H52_MP_Point_TX_Csum a
where tx_dt<='2016-03-10'
and tx_dt>='2016-03-10'
and a.Camp_Act_Typ_Cd = '070101'
group by tx_dt,usr_id) a
group by a.tx_dt
,case when a.times =1 then '1次'
when a.times =2 then '2次'
when a.times =3 then '3次'
when a.times =4 then '4次'
when a.times =5 then '5次'
when a.times <=10 then '5-10次'
when a.times <=20 then '10-20次'
else '>20次' end
;



--总用户积分分布
select case when Curr_Point_Bal=0 or Curr_Point_Bal is null then 1
        when Curr_Point_Bal<=2 then 2
        when Curr_Point_Bal<=5 then 3
        when Curr_Point_Bal<=10 then 4
        when Curr_Point_Bal<=50 then 5
        when Curr_Point_Bal<=80 then 6
        when Curr_Point_Bal<=100 then 7
        when Curr_Point_Bal<=200 then 8
        when Curr_Point_Bal<=300 then 9
        when Curr_Point_Bal<=500 then 10
        when Curr_Point_Bal<=800 then 11
        else 12 end as type_tag
    ,count(distinct usr_id)
    ,sum(Curr_Point_Bal)
from csum.H52_MP_Usr_Base_Info  a
left outer join csum.H52_MP_Usr_Csum_D b
on a.usr_id=b.Cust_ID and statt_dt='2016-03-10'
where substr(create_tm,1,10)<='2016-03-10'
group by case when Curr_Point_Bal=0 or Curr_Point_Bal is null then 1
        when Curr_Point_Bal<=2 then 2
        when Curr_Point_Bal<=5 then 3
        when Curr_Point_Bal<=10 then 4
        when Curr_Point_Bal<=50 then 5
        when Curr_Point_Bal<=80 then 6
        when Curr_Point_Bal<=100 then 7
        when Curr_Point_Bal<=200 then 8
        when Curr_Point_Bal<=300 then 9
        when Curr_Point_Bal<=500 then 10
        when Curr_Point_Bal<=800 then 11
        else 12 end
order by type_tag asc;


--扫码人在前一天的积分存量+当天获得的积分分布
select case when Curr_Point_Bal=0 or Curr_Point_Bal is null then 1
        when Curr_Point_Bal<=2 then 2
        when Curr_Point_Bal<=5 then 3
        when Curr_Point_Bal<=10 then 4
        when Curr_Point_Bal<=50 then 5
        when Curr_Point_Bal<=80 then 6
        when Curr_Point_Bal<=100 then 7
        when Curr_Point_Bal<=200 then 8
        when Curr_Point_Bal<=300 then 9
        when Curr_Point_Bal<=500 then 10
        when Curr_Point_Bal<=800 then 11
        else 12 end
    ,count(distinct Cust_ID)
    ,sum(Curr_Point_Bal)
from (
select cust_id
      ,sum(left_amount+gain_amount) as Curr_Point_Bal
        from(
        select usr_id as Cust_ID
                ,sum(Distr_Point_Cnt) as gain_amount
                ,0 as left_amount
        from csum.H52_MP_Point_TX_Csum a
        left outer join idata.h99_Camp_Act_Typ_Cd d
        on a.Camp_Act_Typ_Cd=d.Camp_Act_Typ_Cd
        where camp_act_typ_desc='有效扫码'
        and tx_dt ='2016-03-03'
        group by usr_id
        union all 
        select Cust_ID
                ,0 as gain_amount 
                ,Curr_Point_Bal as left_amount
        from (select distinct usr_id from csum.H52_MP_Point_TX_Csum a
        left outer join idata.h99_Camp_Act_Typ_Cd d
        on a.Camp_Act_Typ_Cd=d.Camp_Act_Typ_Cd
        where camp_act_typ_desc='有效扫码'
        and tx_dt ='2016-03-03')a 
        left outer join  csum.H52_MP_Usr_Csum_D b
        on a.usr_id=b.Cust_ID
        where statt_dt='2016-03-02'
        )a
        group by cust_id
)a
group by case when Curr_Point_Bal=0 or Curr_Point_Bal is null then 1
        when Curr_Point_Bal<=2 then 2
        when Curr_Point_Bal<=5 then 3
        when Curr_Point_Bal<=10 then 4
        when Curr_Point_Bal<=50 then 5
        when Curr_Point_Bal<=80 then 6
        when Curr_Point_Bal<=100 then 7
        when Curr_Point_Bal<=200 then 8
        when Curr_Point_Bal<=300 then 9
        when Curr_Point_Bal<=500 then 10
        when Curr_Point_Bal<=800 then 11
        else 12 end
        
        
        
