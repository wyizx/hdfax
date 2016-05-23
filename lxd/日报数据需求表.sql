***--2016.05.05
-----表1：PC端新增注册人数	移动端新增注册人数	其他新增注册人数（非PC端和移动端）	新增交易用户	交易用户数(当天有过交易人数)

#每日渠道注册人数
select t1.reg_date
      ,t1.reg_web_cnt
      ,t1.reg_mobile_cnt
      ,t1.reg_other_cnt
      ,coalesce(t2.new_trans_cnt,0) as new_trans_cnt
      ,coalesce(t3.trans_cnt,0) as trans_cnt
from(
select date(m.create_time) as reg_date
      ,sum(case when c.reg_channel in (20)    then 1 else 0 end) as reg_web_cnt 
      ,sum(case when c.reg_channel in (11,12) then 1 else 0 end) as reg_mobile_cnt 
      ,sum(case when c.reg_channel is null    then 1 else 0 end) as reg_other_cnt 
from eif_member.t_member m
left outer join(select member_no, reg_channel from eif_member.t_member_client_external where reg_channel in (11,12,20))c on m.member_no=c.member_no
group by date(m.create_time)
)t1

left outer join(
#每日新增交易用户
select date(min_trans_time) as min_trans_date
      ,count(*) as new_trans_cnt
from(select member_no, min(trans_time) as min_trans_time from eif_ftc.t_ftc_fund_trans_order where status in (6,9,11) group by member_no)t
group by date(min_trans_time)
)t2 on t1.reg_date=t2.min_trans_date

left outer join(
#每日交易用户数
select date(trans_time) as trans_date, count(*) as trans_cnt from eif_ftc.t_ftc_fund_trans_order where status in (6,9,11) group by date(trans_time)
)t3 on t1.reg_date=t3.trans_date
;

-----表2：渠道编号	年龄段	城市	当日新增注册用户	当日新增首次交易用户	当日新增交易用户对应的交易额	当月新增注册用户	当月新增首次交易用户	当月新增交易用户对应的交易额	当年新增注册用户	当年新增首次交易用户	当年新增交易用户对应的交易额

create table test.mobile_mapping
(prefix char(10)
,corp char(10)
,province char(10)
,city char(10)
);

load data local infile '/home/wangyi/mobile_mapping.txt' 
into table test.mobile_mapping(prefix, corp, province, city)
;


drop table test.wy_market_channel;
create table test.wy_market_channel
(market_channel      char(32)
,grp_age             char(10)
,isStaff             int(3)
,today_new_cus_cnt   int(20)
,today_new_trans_cnt decimal(26,6)
,today_trans_amt     decimal(26,6)
,month_new_cus_cnt   int(20)
,month_new_trans_cnt decimal(26,6)
,month_trans_amt     decimal(26,6)
,year_new_cus_cnt    int(20)
,year_new_trans_cnt  decimal(26,6)
,year_trans_amt      decimal(26,6)
);

insert into test.wy_market_channel
select market_channel
      ,grp_age
      ,isStaff
      #,city
      ,coalesce(sum(is_today_new_cus)  ,0) as today_new_cus_cnt
      ,coalesce(sum(is_today_new_trans),0) as today_new_trans_cnt
      ,coalesce(sum(today_trans_amt)   ,0) as today_trans_amt
      
      ,coalesce(sum(is_month_new_cus)  ,0) as month_new_cus_cnt
      ,coalesce(sum(is_month_new_trans),0) as month_new_trans_cnt
      ,coalesce(sum(month_trans_amt)   ,0) as month_trans_amt
      
      ,coalesce(sum(is_year_new_cus)   ,0) as year_new_cus_cnt
      ,coalesce(sum(is_year_new_trans) ,0) as year_new_trans_cnt
      ,coalesce(sum(year_trans_amt)    ,0) as year_trans_amt
      
from
(
select m.member_no
      ,coalesce(c.market_channel,'unknown') as market_channel
      ,case when ee.identity_num is not null and c.market_channel='promotion' then 1 else 0 end as isStaff
      ,coalesce(t.grp_age,'06.other') as grp_age
      #,coalesce(p.city,'unknown') as city
      
      ,case when date(m.create_time)    ='2016-05-05' then 1 else 0 end as is_today_new_cus
      ,case when date(s.min_trans_time) ='2016-05-05' then 1 else 0 end as is_today_new_trans
      ,case when date(m.create_time)    ='2016-05-05' then today_trans_amt else 0 end as today_trans_amt
      
      ,case when month(m.create_time)   = 5 then 1 else 0 end as is_month_new_cus
      ,case when month(s.min_trans_time)= 5 then 1 else 0 end as is_month_new_trans
      ,case when month(m.create_time)   = 5 then month_trans_amt else 0 end as month_trans_amt

      ,case when year(m.create_time)    = 2016 then 1 else 0 end as is_year_new_cus
      ,case when year(s.min_trans_time) = 2016 then 1 else 0 end as is_year_new_trans
      ,case when year(m.create_time)    = 2016 then year_trans_amt else 0 end as year_trans_amt
      
from eif_member.t_member m

left outer join eif_member.t_member_client_external c on m.member_no=c.member_no

#left outer join test.mobile_mapping p on substr(m.verified_mobile,1,7)=p.prefix

left outer join
(select member_no
       ,idno
       ,case when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate()) <20 then '01.<20'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=20 and timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())<30 then '02.[20,30)'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=30 and timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())<40 then '03.[30,40)'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=40 and timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())<50 then '04.[40,50)'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=50 then '05.>=50'
             else '06.other'
        end as grp_age
       ,case cast(substring(idno,17,1) as UNSIGNED)%2 when 1 then '男' when 0 then '女' else '未知' end as gender
 from eif_member.t_client_certification where length(idno)=18
)t on m.member_no=t.member_no

left outer join employee.t_evergrande_employee ee on  t.idno=ee.identity_num

left outer join
(select member_no
       ,min(trans_time) as min_trans_time
 from eif_ftc.t_ftc_fund_trans_order where status in (6,9,11) and date(trans_time)<='2016-05-05' group by member_no
)s on m.member_no=s.member_no

left outer join
(select member_no
       ,sum(case when date(trans_time) ='2016-05-05' then fund_trans_amount else 0 end) as today_trans_amt
       ,sum(case when month(trans_time)=5            then fund_trans_amount else 0 end) as month_trans_amt
       ,sum(case when year(trans_time) =2016         then fund_trans_amount else 0 end) as year_trans_amt
 from eif_ftc.t_ftc_fund_trans_order where status in (6,9,11) and date(trans_time)<='2016-05-05' group by member_no
)r on m.member_no=r.member_no
)t
group by market_channel, grp_age, isStaff#, city
;



-----表3：销售速度/（万元/小时） --> 时间	3个月	6个月	12个月	18个月	24个月
select trans_date
      ,invest_days
      ,sum(trans_hour)
      ,sum(trans_amount)
      ,sum(trans_amount)/sum(trans_hour)
from
(select date(trans_time) as trans_date
      ,product_id
      ,invest_days
      ,min(trans_begin_time) as trans_begin_time
      ,max(trans_time) as trans_end_time
      ,(unix_timestamp(max(trans_time))-unix_timestamp(min(trans_begin_time)))/3600 as trans_hour
      ,sum(fund_trans_amount) as trans_amount
from
(select a.product_id
       ,a.trans_time
       ,case when datediff(b.trans_begin_time,a.trans_time)=0 then b.trans_begin_time 
             else date_format(concat(substr(trans_time,1,10),' 00:00:00'),'%Y-%m-%d %H:%i:%s')
        end as trans_begin_time
       ,round(((UNIX_TIMESTAMP(b.due_date) - UNIX_TIMESTAMP(b.inception_date))/((60*60*24)+1))/10)*10 as invest_days
       ,fund_trans_amount
 from eif_ftc.t_ftc_fund_trans_order a
 left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
 where a.status in (6,9,11) and date(a.trans_time)>='2016-03-16'
)t group by date(trans_time), product_id, invest_days
)t group by trans_date, invest_days
;


--5号所有产品的开始时间和结束时间及资产包大小


select a.product_id
      ,product_scale
      ,trans_begin_time
      ,max(trans_time) as trans_end_time
      ,datediff(due_date,inception_date) as invest_days 
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.status in (6,9,11)
and date(a.trans_time)='2016-05-08' 
group by a.product_id
;




