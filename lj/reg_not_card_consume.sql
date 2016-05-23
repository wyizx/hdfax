create table test.wy_regnotcard_70w
(mobile char(20));

load data local infile '/home/wangyi/regnotcard_70w.txt'
into table test.wy_regnotcard_70w
FIELDS TERMINATED BY '\t'
;


create table test.wy_regnotcard_280w
(mobile char(20));

load data local infile '/home/wangyi/regnotcard_280w.txt'
into table test.wy_regnotcard_280w
FIELDS TERMINATED BY '\t'
;

drop table test.wy_regnotcard_94w;
create table test.wy_regnotcard_94w
(mobile char(20));

load data local infile '/home/wangyi/not_cardHD_XWSCAN0401.txt'
into table test.wy_regnotcard_94w
FIELDS TERMINATED BY '\t'
;

load data local infile '/home/wangyi/not_card_ice-spring.txt'
into table test.wy_regnotcard_94w
FIELDS TERMINATED BY '\t'
;

drop table test.wy_date;
create table test.wy_date
(hd_date char(10));
insert into test.wy_date set hd_date='2016-05-18';
insert into test.wy_date set hd_date='2016-05-19';
insert into test.wy_date set hd_date='2016-05-20';
insert into test.wy_date set hd_date='2016-05-21';
insert into test.wy_date set hd_date='2016-05-22';

drop table test.wy_hour;
create table test.wy_hour
(hd_hour int(10));
insert into test.wy_hour set hd_hour='0';
insert into test.wy_hour set hd_hour='1';
insert into test.wy_hour set hd_hour='2';
insert into test.wy_hour set hd_hour='3';
insert into test.wy_hour set hd_hour='4';
insert into test.wy_hour set hd_hour='5';
insert into test.wy_hour set hd_hour='6';
insert into test.wy_hour set hd_hour='7';
insert into test.wy_hour set hd_hour='8';
insert into test.wy_hour set hd_hour='9';
insert into test.wy_hour set hd_hour='10';
insert into test.wy_hour set hd_hour='11';
insert into test.wy_hour set hd_hour='12';
insert into test.wy_hour set hd_hour='13';
insert into test.wy_hour set hd_hour='14';
insert into test.wy_hour set hd_hour='15';
insert into test.wy_hour set hd_hour='16';
insert into test.wy_hour set hd_hour='17';
insert into test.wy_hour set hd_hour='18';
insert into test.wy_hour set hd_hour='19';
insert into test.wy_hour set hd_hour='20';
insert into test.wy_hour set hd_hour='21';
insert into test.wy_hour set hd_hour='22';
insert into test.wy_hour set hd_hour='23';

ALTER TABLE test.wy_regnotcard_70w  ADD INDEX ib (mobile);
ALTER TABLE test.wy_regnotcard_280w ADD INDEX ib (mobile);
ALTER TABLE test.wy_regnotcard_94w ADD INDEX ib (mobile);

ALTER TABLE test.wy_temp ADD INDEX im (member_no);
ALTER TABLE test.wy_temp ADD INDEX ib (mobile);


%%70W%%
select t.hd_date
      ,t.hd_hour
      ,coalesce(t1.card_cnt,0) as card_cnt
      ,coalesce(t2.trans1st_cnt,0) as trans1st_cnt
      ,coalesce(t3.trans_user_cnt_c97,0) as trans_user_cnt_c97
      ,coalesce(t3.trans_cnt_c97,0) as trans_cnt_c97
      ,coalesce(t3.trans_user_amt_c97,0) as trans_user_amt_c97
      ,coalesce(t4.trans_user_cnt,0) as trans_user_cnt
      ,coalesce(t4.trans_cnt,0) as trans_cnt
      ,coalesce(t4.trans_amt,0) as trans_amt
      ,coalesce(t5.trans_user_cnt_c97_all,0) as trans_user_cnt_c97_all
      ,coalesce(t5.trans_cnt_c97_all,0) as trans_cnt_c97_all
      ,coalesce(t5.trans_user_amt_c97_all,0) as trans_user_amt_c97_all
from
(select m.hd_date, h.hd_hour from test.wy_date m join test.wy_hour h on 1=1 order by hd_date, hd_hour)t

left outer join
(
select date(t.card_time) as card_date
      ,hour(t.card_time) as card_hour
      ,count(*) as card_cnt
from test.wy_regnotcard_70w s
join test.wy_temp t on s.mobile=t.mobile
#where date(card_time)>='2016-05-18'
group by date(t.card_time), hour(t.card_time)
)t1 on t.hd_date=t1.card_date and t.hd_hour=t1.card_hour

left outer join
(
select date(t.trans1st_time) as trans1st_date
      ,hour(t.trans1st_time) as trans1st_hour
      ,count(*) as trans1st_cnt
from test.wy_regnotcard_70w s
join test.wy_temp t on s.mobile=t.mobile
#where date(trans1st_time)>='2016-05-18'
group by date(t.trans1st_time), hour(t.trans1st_time)
)t2 on t.hd_date=t2.trans1st_date and t.hd_hour=t2.trans1st_hour

left outer join
(
select trans_date
      ,trans_hour
      ,count(distinct c.member_no) as trans_user_cnt_c97
      ,count(*) as trans_cnt_c97
      ,sum(fund_trans_amount) as trans_user_amt_c97
from
(select b.member_no
       ,date(b.trans_time) as trans_date
       ,hour(b.trans_time) as trans_hour
       ,b.fund_trans_amount
 from eif_market.t_market_use_rec a 
 join eif_ftc.t_ftc_fund_trans_order b on a.order_no=b.business_order_item_no 
 where a.activity_coupon_id=97 and b.status in (6,9,11) and date(b.trans_time)>='2016-05-18'
)c
join test.wy_temp t on c.member_no=t.member_no
join test.wy_regnotcard_70w n on t.mobile=n.mobile
group by trans_date, trans_hour
)t3 on t.hd_date=t3.trans_date and t.hd_hour=t3.trans_hour

left outer join
(
select date(r.trans_time) as trans_date
      ,hour(r.trans_time) as trans_hour
      ,count(distinct r.member_no) as trans_user_cnt
      ,count(*) as trans_cnt
      ,sum(r.fund_trans_amount) as trans_amt
from test.wy_regnotcard_70w n
join test.wy_temp t on n.mobile=t.mobile
join eif_ftc.t_ftc_fund_trans_order r on t.member_no=r.member_no
where r.status in (6,9,11) and date(r.trans_time)>='2016-05-18'
group by date(r.trans_time), hour(r.trans_time)
)t4 on t.hd_date=t4.trans_date and t.hd_hour=t4.trans_hour

left outer join
(
select trans_date
      ,trans_hour
      ,count(*) as trans_cnt_c97_all
      ,count(distinct c.member_no) as trans_user_cnt_c97_all
      ,sum(fund_trans_amount) as trans_user_amt_c97_all
from
(select b.member_no
       ,date(b.trans_time) as trans_date
       ,hour(b.trans_time) as trans_hour
       ,b.fund_trans_amount
 from(select user_id from eif_market.t_market_use_rec where activity_coupon_id=97 group by user_id)a
 join eif_ftc.t_ftc_fund_trans_order b on a.user_id=b.member_no
 where b.status in (6,9,11) and date(b.trans_time)>='2016-05-18'
)c
join test.wy_temp t on c.member_no=t.member_no
join test.wy_regnotcard_70w n on t.mobile=n.mobile
group by trans_date, trans_hour
)t5 on t.hd_date=t5.trans_date and t.hd_hour=t5.trans_hour
;











%%%%
drop table test.wy_temp2;
create table test.wy_temp2
(member_no char(32)
,trans_time DATETIME
,trans_amt decimal(26,6)
,id int(10)
);

insert into test.wy_temp2
select a.member_no
      ,a.trans_time
      ,a.fund_trans_amount as trans_amt
      ,c.id
from (select * from eif_ftc.t_ftc_fund_trans_order where date(trans_time)>='2016-05-16' and status in (6,9,11))a 
join eif_market.t_market_use_rec b on a.business_order_item_no=b.order_no
join eif_market.t_market_activity_coupon c on b.activity_coupon_id=c.id
;



from eif_market.t_market_use_rec bb
join eif_market.t_market_activity_coupon cc on bb.activity_coupon_id=cc.id
join eif_ftc.t_ftc_fund_trans_order aa on bb.order_no=aa.business_order_item_no
where b.id=97 and c.status in(6,9,11)
; 


select count(*), count(distinct b.member_no) from eif_market.t_market_use_rec a join eif_ftc.t_ftc_fund_trans_order b on a.order_no=b.business_order_item_no where a.activity_coupon_id=97 and b.status in (6,9,11);
+----------+-----------------------------+
| count(*) | count(distinct b.member_no) |
+----------+-----------------------------+
|      411 |                         411 |
+----------+-----------------------------+


select count(*) from
(select b.member_no
 from eif_market.t_market_use_rec a 
 join eif_ftc.t_ftc_fund_trans_order b on a.order_no=b.business_order_item_no 
 where a.activity_coupon_id=97 and b.status in (6,9,11) and date(b.trans_time)>='2016-05-18'
 group by b.member_no
)c
join test.wy_temp t on c.member_no=t.member_no
join test.wy_regnotcard_70w r on t.mobile=r.mobile
;


select  b.name
,count(distinct a.user_id)
,count(distinct a.order_no) as order_num
,sum(fund_trans_amount) as total_amount
,sum(deduction_amt)
from eif_market.t_market_use_rec a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
join eif_ftc.t_ftc_fund_trans_order c on a.order_no=c.business_order_item_no
where c.status in(6,9,11)
group by b.name,max_allowance_amount


mysql -h 10.127.133.100 -u hdfax -pv6QB\(dqy4 -A -e "select user_id, order_no, activity_coupon_id from eif_market.t_market_use_rec;" > t_market_use_rec.txt


%%"绑卡送券"某日过期的人%%
#18日发券 25日零点到期
#19日发券 26日零点到期
#以此类推

select b.verified_mobile
      ,coalesce(c.certname,'先生/女士') as certname
from eif_market.t_market_coupon_user a
join eif_member.t_member b on a.user_id=b.member_no
join
(select member_no, idno, name
       ,case when length(idno)=18 and substr(idno,17,1) in (1,3,5,7,9) then concat(substr(name,1,1),'先生')
             when length(idno)=18 and substr(idno,17,1) in (2,4,6,8,0) then concat(substr(name,1,1),'女士')
             else concat(substr(name,1,1),'先生/女士')
        end as certname
 from eif_member.t_client_certification
 where status='1' and length(name)>1
)c on a.user_id=c.member_no
where a.activity_coupon_id=97 
      and date(a.issued_time)='2016-05-18' #限定发券日期
      and a.status='1'
;
