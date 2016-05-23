***--2016.05.04
----- BD通过外部获客，和触宝合作，从触宝获取注册用户。5月1号-5月3号小范围测试了下，现金花没有监控到注册数据，
----- 麻烦您这边看下是否有访问数据。渠道编号为：A_chubao0428a

select date(a.create_time), count(*) 
from eif_member.t_member a
join eif_member.t_member_client_external b on a.member_no=b.member_no
where b.market_channel='A_chubao0428a'
group by date(a.create_time)
;