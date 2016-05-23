
#1.新手大礼包礼券到期且未使用过礼券
drop table test.wy_coupon_part1;
create table test.wy_coupon_part1(
user_id char(32)
,mobile varchar(32)
);

INSERT INTO test.wy_coupon_part1
select t1.user_id, m.verified_mobile as mobile from
(#到期且没有使用的券用户
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10)='2014-04-29'
and a.status='1'  and b.name like '%新手大礼包%'
group by a.user_id
)t1 left outer join
(#使用过任意一张券的用户
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%新手大礼包%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where t2.user_id is null and verified_mobile like '1%' and length(verified_mobile)=11
;

#2.新手大礼包礼券到期，且曾经使用过1张及以上礼券，剔除仅剩余一张500元优惠券（需满10万使用，受支付通道限制不可用）的用户
drop table  test.wy_coupon_part2;
create table test.wy_coupon_part2(
user_id char(32)
,mobile varchar(32)
);

INSERT INTO test.wy_coupon_part2
select t1.user_id, m.verified_mobile as mobile from 
(#4月15日到期且没有使用的券用户
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10)='2014-04-29'
and a.status='1' and b.name like '%新手大礼包%' and rule_discription not like '%100000%'
group by a.user_id
)t1 join
(#使用过任意一张券的用户
select a.user_id 
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%新手大礼包%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where verified_mobile like '%1%' and length(verified_mobile)=11
;

