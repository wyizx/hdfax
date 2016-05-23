--金服报表

登录mysql的方式是：
1、登录堡垒机，go 自己 如 ：go wh
2、输入mysql -h 10.127.133.202 -u hdfax -p
3、输入密码：v6QB(dqy4


--1.核心指标
select   substr(trans_time,1,10) as date_num 
        ,sum(fund_trans_amount)/count(distinct a.member_no)  as avg_mem_amount
        ,count(distinct fund_trans_order_no) as order_num
        ,max(fund_trans_amount) as max_order_amount
        ,sum(fund_trans_amount) as total_amount
        ,sum(case when e.group_tag =1  then fund_trans_amount end) as group_mem_amount
        ,sum(case when e.group_tag =0  then fund_trans_amount end) as outer_mem_amount
        ,sum(case when e.invited_code is not null and invite_group_tag=1 then fund_trans_amount end) as group_invite_amount
        ,sum(case when e.invited_code is not null and invite_group_tag=0 then fund_trans_amount end) as outer_invite_amount
from eif_ftc.t_ftc_fund_trans_order  a 
left outer join (
    select a.member_no
         ,invited_code 
         ,case when d.identity_num is not null then 1 else 0 end as group_tag
    from eif_member.t_member a
    left outer join eif_member.t_client_certification c 
    on a.member_no = c.member_no 
    left outer join employee.t_evergrande_employee d     
    on d.identity_num=c.idno
)e
on a.member_no=e.member_no
left outer join (
    select a.member_no
         ,invite_code 
         ,case when d.identity_num is not null then 1 else 0 end as invite_group_tag
    from eif_member.t_member a
    left outer join eif_member.t_client_certification c 
    on a.member_no = c.member_no 
    left outer join employee.t_evergrande_employee d     
    on d.identity_num=c.idno
)f
on e.invited_code=f.invite_code
where status in(6,9,11)  
and substr(trans_time,1,10)>='2016-03-16'
group by substr(trans_time,1,10)

--2.product
select substr(trans_time,1,10) date_id
    ,sum(case when product_name like '%新手专享%' or product_name like '%新人专享%' then fund_trans_amount end) as xinshou_order_amt
    ,sum(case when product_name like '%恒耀添利%' then fund_trans_amount end) as hy_tianli_order_amt
    ,sum(case when product_name like '%恒耀稳享%' then fund_trans_amount end) as hy_wenxiang_order_amt
    ,sum(case when product_name like '%恒耀安益%' then fund_trans_amount end) as hy_anyi_order_amt
    ,sum(fund_trans_amount) as total_order_amt
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.trans_time>='2016-03-16' and a.status in (6,9,11)
group by substr(trans_time,1,10);

--3.注册渠道
select
    b.reg_channel,
    count(distinct a.member_no) as member_count,
    sum(case when c.member_no is null then 0 else 1 end) as certificated_count,  
    sum(a.has_bankcard) as bankcard_count,
    sum(case when d.member_no is null then 0 else 1 end) as transaction_count
from eif_member.t_member a 
left outer join eif_member.t_member_client_external b on a.member_no=b.member_no
left outer join (select distinct member_no from eif_member.t_client_certification ) c on a.member_no=c.member_no
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) d on a.member_no=d.member_no
group by b.reg_channel;

--4.投资区间
--累计投资金额区间，集团用户，外部用户，总用户数
select case when total_benjin <=100 then '1'
when total_benjin <=500 then '2'
when total_benjin <=1000 then '3'
when total_benjin <=5000 then '4'
when total_benjin <=10000 then '5'
when total_benjin <=20000 then '6'
when total_benjin <=50000 then '7'
when total_benjin <=100000 then '8'
when total_benjin <=200000 then '9'
else '10' end as benjin_tag
,count(distinct case when is_hd_mem = 1 then member_no end) as hd_mem_cnt
,count(distinct case when is_hd_mem = 0 then member_no end) as non_hd_mem_cnt
,count(distinct member_no) as total_mem_cnt
from (select a.total_benjin as total_benjin
,case when c.identity_num is null then 0 else 1 end as is_hd_mem
,a.member_no
from (select c.member_no
,sum(settlement_capital) as total_benjin
from eif_ftc.t_amc_fund_detail a
left outer join eif_ftc.t_amc_fund_total b on b.fund_total_uuid = a.fund_total_uuid
left outer join eif_ftc.t_amc_mem_asset c on c.member_asset_uuid = b.member_asset_uuid 
group by member_no) a
left outer join eif_member.t_client_certification b on a.member_no = b.member_no 
left outer join employee.t_evergrande_employee c on b.idno = c.identity_num) a
group by case when total_benjin <=100 then '1'
when total_benjin <=500 then '2'
when total_benjin <=1000 then '3'
when total_benjin <=5000 then '4'
when total_benjin <=10000 then '5'
when total_benjin <=20000 then '6'
when total_benjin <=50000 then '7'
when total_benjin <=100000 then '8'
when total_benjin <=200000 then '9'
else '10' end
;

--5.年龄
select 
(case 
when a.age=999 or a.age is null then '1'
when a.age<=20 then '2'
when a.age<=30 then '3'
when a.age<=40 then '4'
when a.age<=50 then '5'
else '6'
end) as age_group 
,sum(a.mem_no1) as mem_no1 
,sum(a.mem_no2) as mem_no2 
from (
select
(case when e.idno is null then 999 else 
TIMESTAMPDIFF(YEAR,DATE_FORMAT(IF(LENGTH(e.idno)=18,SUBSTR(e.idno,7,8),CONCAT('19',SUBSTR(e.idno,7,6))),'%Y-%m-%d'),CURDATE())
end ) as age  
,count(distinct a.member_no) as mem_no1 
,count(distinct case when c.member_no is not null then a.member_no end) as mem_no2  
from eif_member.t_member a 
left outer join 
(select distinct member_no from eif_ftc.t_ftc_fund_trans_order a where a.status in ('6','9','11')) c 
on c.member_no = a.member_no
left outer join eif_member.t_client_certification e on e.member_no = a.member_no and e.id_type in ('0','1')
group by 
(case when e.idno is null then 999 else 
TIMESTAMPDIFF(YEAR,DATE_FORMAT(IF(LENGTH(e.idno)=18,SUBSTR(e.idno,7,8),CONCAT('19',SUBSTR(e.idno,7,6))),'%Y-%m-%d'),CURDATE())
end )
) a
group by 
(case 
when a.age=999 or a.age is null then '1'
when a.age<=20 then '2'
when a.age<=30 then '3'
when a.age<=40 then '4'
when a.age<=50 then '5'
else '6'
end);

--6.营销活动
select
    b.market_channel,
    count(distinct a.member_no) as member_count, 
    sum(case when c.member_no is null then 0 else 1 end) as certificated_count, 
    sum(a.has_bankcard) as bankcard_count,
    sum(case when d.member_no is null then 0 else 1 end) as transaction_count
from eif_member.t_member a 
left outer join eif_member.t_member_client_external b on a.member_no=b.member_no
left outer join (select distinct member_no from eif_member.t_client_certification ) c on a.member_no=c.member_no
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) d on a.member_no=d.member_no
group by b.market_channel
;

--短信营销效果
--MySql导入文本数据

create table test.sms_send(  
mobile varchar(20) not null
);

load data local infile '/home/wangyi/mobile.txt' 
into table test.sms_send(mobile)
;

select
    b.market_channel,
    count(distinct a.member_no) as member_count,
    sum(case when c.member_no is null then 0 else 1 end) as certificated_count,  
    sum(a.has_bankcard) as bankcard_count,
    sum(case when d.member_no is null then 0 else 1 end) as transaction_count
from eif_ftc.return_list t
join eif_member.t_member a on t.phone=a.verified_mobile
left outer join eif_member.t_member_client_external b on a.member_no=b.member_no
left outer join (select distinct member_no from eif_member.t_client_certification ) c on a.member_no=c.member_no
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) d on a.member_no=d.member_no
where Sent_Time<=a.create_time
and t.status ='DELIVRD'
group by b.market_channel
;
