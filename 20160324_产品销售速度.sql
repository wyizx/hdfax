--产品销售速度

select product_name
,trans_begin_time
,trans_end_time
from eif_fis.t_fis_prod_info
    ,sum(fund_trans_amount) as total_order_amt
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.trans_time>='2016-03-16' and a.status in (6,9,11)
group by substr(trans_time,1,10)

drop table test.hdfx_product_info;
create table test.hdfx_product_info as
select   product_name
        #产品销售分钟数
        ,(UNIX_TIMESTAMP(max(trans_time)) - UNIX_TIMESTAMP(trans_begin_time))/60 as sale_finish_minutes
        #,trans_begin_time
        #,trans_end_time
        ,product_scale
        #产品利率
        ,REPLACE(display_rate,'%','') as display_rate_num
        #产品投资天数
        ,round(((UNIX_TIMESTAMP(due_date) - UNIX_TIMESTAMP(inception_date))/((60*60*24)+1))/10)*10 as invest_days
        #,min(trans_time) as min_trans_time
        #,max(trans_time) as max_trans_time
        ,timediff(max(trans_time), trans_begin_time) as sale_finish_time
        #最小投资金额
        ,case when min(fund_trans_amount)<10000 then 100 else 10000 end as min_invest_amt
        #,sum(fund_trans_amount) as total_order_amt
        ,hour(trans_begin_time) as trans_begin_hour
        ,dayofweek(trans_begin_time) as trans_begin_week
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.status in (6,9,11)
and a.trans_time>='2016-03-16' 
group by product_name
,trans_begin_time
,trans_end_time
,product_scale
,display_rate
;

mysql -h 10.127.133.100 -u hdfax -p -e "select * from test.hdfx_product_info;">hdfax_product_sale_info.txt


drop table test.hdfx_product_info;
create table test.hdfx_product_info as
select date(trans_time) as trans_date
      ,hour(trans_time) as trans_hour
      ,dayofweek(trans_time) as trans_dateofweek
      ,round(((UNIX_TIMESTAMP(due_date) - UNIX_TIMESTAMP(inception_date))/((60*60*24)+1))/10)*10 as invest_days
      ,REPLACE(display_rate,'%','') as display_rate_num
      ,case when min(fund_trans_amount)<10000 then 100 else 10000 end as invest_amt_min 
      ,sum(fund_trans_amount) as total_order_amt
      ,sum(fund_trans_amount)/((UNIX_TIMESTAMP(max(trans_time))-UNIX_TIMESTAMP(min(trans_time)))/60) as sale_per_minute
      ,ln(sum(fund_trans_amount)/((UNIX_TIMESTAMP(max(trans_time))-UNIX_TIMESTAMP(min(trans_time)))/60)) as ln_sale_per_minute
      ,min(trans_time) as trans_begin_time
      ,max(trans_time) as trans_end_time
      ,max(trans_time)-min(trans_time) as sale_seconds
      ,(UNIX_TIMESTAMP(max(trans_time))-UNIX_TIMESTAMP(min(trans_time)))/60 as sale_minutes
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.status in (6,9,11)
and a.trans_time>='2016-03-16' 
and a.trans_time<'2016-03-31'
and hour(trans_time)>=11
and hour(trans_time)<=23
and cast(REPLACE(display_rate,'%','') as decimal)>=5.0
and cast(REPLACE(display_rate,'%','') as decimal)<=8.0
group by date(trans_time)
,dayofweek(trans_time)
,hour(trans_time)
,round(((UNIX_TIMESTAMP(due_date) - UNIX_TIMESTAMP(inception_date))/((60*60*24)+1))/10)*10
,cast(REPLACE(display_rate,'%','') as decimal)
;

--从注册到交易的时间分布
drop table test.hdfax_reg2trans_cus;
create table test.hdfax_reg2trans_cus as
select t.*
      ,case when reg2cert_days>=0  and reg2cert_days<0.5  then '00.[0,0.5)'
            when reg2cert_days>=0.5  and reg2cert_days<1  then '01.[0.5,1)'
            when reg2cert_days>=1  and reg2cert_days<2  then '02.[1,2)'
            when reg2cert_days>=2  and reg2cert_days<3  then '03.[2,3)'
            when reg2cert_days>=3  and reg2cert_days<4  then '04.[3,4)'
            when reg2cert_days>=4  and reg2cert_days<5  then '05.[4,5)'
            when reg2cert_days>=5  and reg2cert_days<6  then '06.[5,6)'
            when reg2cert_days>=6  and reg2cert_days<7  then '07.[6,7)'
            when reg2cert_days>=7  and reg2cert_days<8  then '08.[7,8)'
            when reg2cert_days>=8  and reg2cert_days<9  then '09.[8,9)'
            when reg2cert_days>=9  and reg2cert_days<10 then '10.[9,10)'
            when reg2cert_days>=10 and reg2cert_days<11 then '11.[10,11)'
            when reg2cert_days>=11 and reg2cert_days<12 then '12.[11,12)'
            when reg2cert_days>=12 and reg2cert_days<13 then '13.[12,13)'
            when reg2cert_days>=13 and reg2cert_days<14 then '14.[13,14)'
            when reg2cert_days>=14 and reg2cert_days<15 then '15.[14,15)'
            when reg2cert_days>=15 and reg2cert_days<16 then '16.[15,16)'
            when reg2cert_days>=16 and reg2cert_days<17 then '17.[16,17)'
            when reg2cert_days>=17 and reg2cert_days<18 then '18.[17,18)'
            when reg2cert_days>=18 and reg2cert_days<19 then '19.[18,19)'
            when reg2cert_days>=19 and reg2cert_days<20 then '20.[19,20)'
            when reg2cert_days>=20 and reg2cert_days<30 then '21.[20,30)'
            when reg2cert_days>=30     then '22.>30'
            when reg2cert_days is null then '23.NotCert'
            else '24.Other'
        end as grp_reg2cert_days
      ,case when reg2card_days>=0  and reg2card_days<0.5  then '00.[0,0.5)'
            when reg2card_days>=0.5  and reg2card_days<1  then '01.[0.5,1)'
            when reg2card_days>=1  and reg2card_days<2  then '02.[1,2)'
            when reg2card_days>=2  and reg2card_days<3  then '03.[2,3)'
            when reg2card_days>=3  and reg2card_days<4  then '04.[3,4)'
            when reg2card_days>=4  and reg2card_days<5  then '05.[4,5)'
            when reg2card_days>=5  and reg2card_days<6  then '06.[5,6)'
            when reg2card_days>=6  and reg2card_days<7  then '07.[6,7)'
            when reg2card_days>=7  and reg2card_days<8  then '08.[7,8)'
            when reg2card_days>=8  and reg2card_days<9  then '09.[8,9)'
            when reg2card_days>=9  and reg2card_days<10 then '10.[9,10)'
            when reg2card_days>=10 and reg2card_days<11 then '11.[10,11)'
            when reg2card_days>=11 and reg2card_days<12 then '12.[11,12)'
            when reg2card_days>=12 and reg2card_days<13 then '13.[12,13)'
            when reg2card_days>=13 and reg2card_days<14 then '14.[13,14)'
            when reg2card_days>=14 and reg2card_days<15 then '15.[14,15)'
            when reg2card_days>=15 and reg2card_days<16 then '16.[15,16)'
            when reg2card_days>=16 and reg2card_days<17 then '17.[16,17)'
            when reg2card_days>=17 and reg2card_days<18 then '18.[17,18)'
            when reg2card_days>=18 and reg2card_days<19 then '19.[18,19)'
            when reg2card_days>=19 and reg2card_days<20 then '20.[19,20)'
            when reg2card_days>=20 and reg2card_days<30 then '21.[20,30)'
            when reg2card_days>=30     then '22.>30'
            when reg2card_days is null then '23.NotCard'
            else '24.Other'
        end as grp_reg2card_days
      ,case when reg2trans_days>=0  and reg2trans_days<0.5  then '00.[0,0.5)'
            when reg2trans_days>=0.5  and reg2trans_days<1  then '01.[0.5,1)'
            when reg2trans_days>=1  and reg2trans_days<2  then '02.[1,2)'
            when reg2trans_days>=2  and reg2trans_days<3  then '03.[2,3)'
            when reg2trans_days>=3  and reg2trans_days<4  then '04.[3,4)'
            when reg2trans_days>=4  and reg2trans_days<5  then '05.[4,5)'
            when reg2trans_days>=5  and reg2trans_days<6  then '06.[5,6)'
            when reg2trans_days>=6  and reg2trans_days<7  then '07.[6,7)'
            when reg2trans_days>=7  and reg2trans_days<8  then '08.[7,8)'
            when reg2trans_days>=8  and reg2trans_days<9  then '09.[8,9)'
            when reg2trans_days>=9  and reg2trans_days<10 then '10.[9,10)'
            when reg2trans_days>=10 and reg2trans_days<11 then '11.[10,11)'
            when reg2trans_days>=11 and reg2trans_days<12 then '12.[11,12)'
            when reg2trans_days>=12 and reg2trans_days<13 then '13.[12,13)'
            when reg2trans_days>=13 and reg2trans_days<14 then '14.[13,14)'
            when reg2trans_days>=14 and reg2trans_days<15 then '15.[14,15)'
            when reg2trans_days>=15 and reg2trans_days<16 then '16.[15,16)'
            when reg2trans_days>=16 and reg2trans_days<17 then '17.[16,17)'
            when reg2trans_days>=17 and reg2trans_days<18 then '18.[17,18)'
            when reg2trans_days>=18 and reg2trans_days<19 then '19.[18,19)'
            when reg2trans_days>=19 and reg2trans_days<20 then '20.[19,20)'
            when reg2trans_days>=20 and reg2trans_days<30 then '21.[20,30)'
            when reg2trans_days>=30     then '22.>30'
            when reg2trans_days is null then '23.NotTrans'
            else '24.Other'
        end as grp_reg2trans_days
from        
(
select a.member_no
      ,a.create_time as reg_time
      ,b.create_time as cert_time
      ,c.create_time as card_time
      ,d.min_trans_time
      ,d.max_trans_time
      ,round(((UNIX_TIMESTAMP(b.create_time) - UNIX_TIMESTAMP(a.create_time))/((60*60*24)+1)),1) as reg2cert_days
      ,round(((UNIX_TIMESTAMP(c.create_time) - UNIX_TIMESTAMP(a.create_time))/((60*60*24)+1)),1) as reg2card_days
      ,round(((UNIX_TIMESTAMP(d.min_trans_time) - UNIX_TIMESTAMP(a.create_time))/((60*60*24)+1)),1) as reg2trans_days
      ,d.trans_amount
from eif_member.t_member a

left outer join
(select member_no
       ,create_time
 from eif_member.t_client_certification
 where status=1
)b on a.member_no=b.member_no

left outer join
(select aa.member_no, min(ab.create_time) as create_time
 from eif_member.t_member_bankcard aa 
 join eif_member.t_member_bankcard_detail ab
 on aa.bankcard_uuid=ab.bankcard_uuid
 where ab.status=3
 group by aa.member_no
)c on a.member_no=c.member_no

left outer join
(select member_no
       ,min(trans_time) as min_trans_time
       ,max(trans_time) as max_trans_time
       ,sum(fund_trans_amount) as trans_amount
 from eif_ftc.t_ftc_fund_trans_order 
 where status in (6,9,11) and trans_time>='2016-03-16' and trans_time <= '2016-04-26 11:00:00'
 group by member_no
)d on a.member_no=d.member_no

left outer join
(select member_no
       ,min(trans_time) as min_trans_time
       ,max(trans_time) as max_trans_time
       ,sum(fund_trans_amount) as trans_amount
 from eif_ftc.t_ftc_fund_trans_order 
 where status in (6,9,11) and trans_time>='2016-03-16' and trans_time <= '2016-04-26 11:00:00'
 group by member_no
)e on a.member_no=e.member_no

where length(a.verified_mobile) = 11 and substr(a.verified_mobile,1,1) = 1
)t
;

select count(*) from test.hdfax_reg2trans_cus where reg2trans_days is not null and reg2card_days>reg2trans_days;
