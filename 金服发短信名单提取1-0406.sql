select trade_tag,count(distinct a.verified_mobile)
from (select a.member_no,a.verified_mobile,case when b.member_no is null then 0 else 1 end as trade_tag
from eif_member.t_member a
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) b on a.member_no=b.member_no
where length(a.verified_mobile) = 11 and substr(a.verified_mobile,1,1) = 1
) a
group by trade_tag ;

+-----------+-----------------------------------+
| trade_tag | count(distinct a.verified_mobile) |
+-----------+-----------------------------------+
|         0 |                            687866 |
|         1 |                             92663 |
+-----------+-----------------------------------+

create table test.buy_mobile as 
select distinct a.verified_mobile
from (select a.member_no,a.verified_mobile,case when b.member_no is null then 0 else 1 end as trade_tag
from eif_member.t_member a
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) b on a.member_no=b.member_no
where length(a.verified_mobile) = 11 and substr(a.verified_mobile,1,1) = 1
) a
where trade_tag = 1
;

create table test.not_buy_mobile as 
select distinct a.verified_mobile
from (select a.member_no,a.verified_mobile,case when b.member_no is null then 0 else 1 end as trade_tag
from eif_member.t_member a
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) b on a.member_no=b.member_no
where length(a.verified_mobile) = 11 and substr(a.verified_mobile,1,1) = 1
) a
where trade_tag = 0 
;


mysql -h 10.127.133.100 -u hdfax -pv6QB\(dqy4 -e 'select * from test.buy_mobile' > buy_mobile.csv
mysql -h 10.127.133.100 -u hdfax -pv6QB\(dqy4 -e 'select * from test.not_buy_mobile' > not_buy_mobile.csv

