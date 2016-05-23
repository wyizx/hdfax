drop table test.mobile_mapping;
create table test.mobile_mapping
(prefix char(20)
,corp char(20)
,province char(20)
,city char(20)
);

load data local infile '/home/wangyi/mobile_mapping.txt' 
into table test.mobile_mapping
FIELDS TERMINATED BY '\t'
;


drop table test.wy_mobile_city_class;
create table test.wy_mobile_city_class
(prefix char(20)
,corp char(20)
,province char(20)
,city char(20)
,class char(20)
)
;

insert into test.wy_mobile_city_class
select m.prefix, m.corp, m.province, m.city, coalesce(c.class,'其他') as class
from test.mobile_mapping m 
left outer join test.wy_city c on replace(m.city,'市','')=replace(c.city,'市','')
;

ALTER TABLE test.wy_mobile_city_class ADD INDEX im (prefix);



drop table test.wy_temp;
create table test.wy_temp
(member_no char(32)
,mobile char(20)
,prefix char(20)
,market_channel char(20)
,idno char(20)
,age int(10)
,gender char(10)
,grp_age char(10)
,reg_time DATETIME
,cert_time DATETIME
,card_time DATETIME
,trans1st_time DATETIME
,reg2trans1st_days int(10)
,grp_reg2trans1st_days char(20)
,trans_cnt int(10)
,grp_trans_cnt char(20)
,trans_amount decimal(26,6)
,grp_trans_amount char(20)
#,class char(15)
);

insert into test.wy_temp
select a.member_no
      ,a.verified_mobile as mobile
      ,substr(a.verified_mobile,1,7) as prefix
      ,m.market_channel
      ,s.idno
      ,s.age
      ,s.gender
      ,s.grp_age
      ,a.create_time as reg_time
      ,b.create_time as cert_time
      ,c.create_time as card_time
      ,t.trans1st_time
      ,datediff(t.trans1st_time, a.create_time) as reg2trans1st_days
      ,case when datediff(t.trans1st_time, a.create_time)<=3 then '01.注册至首投<=3天'
            when datediff(t.trans1st_time, a.create_time)>3 and datediff(t.trans1st_time, a.create_time)<=15 then '02.注册至首投[4,15]天'
            when datediff(t.trans1st_time, a.create_time)>15 and datediff(t.trans1st_time, a.create_time)<=30 then '03.注册至首投[16,30]天'
            when datediff(t.trans1st_time, a.create_time)>30 then '04.注册至首投>30天'
            else '05.ohter'
        end as reg2trans1st_days
      ,t.trans_cnt
      ,case when t.trans_cnt=1 then '01.投资1次'
            when t.trans_cnt>1 and t.trans_cnt<=5 then '02.投资(1,5]次'
            when t.trans_cnt>5 then '03.投资5次以上'
            else '04.other'
       end as grp_trans_cnt
      ,t.trans_amount
      ,case when t.trans_amount<=10000 then '01.<1万'
            when t.trans_amount >10000 and t.trans_amount<= 50000  then '02.[1万,5万)'
            when t.trans_amount >50000 and t.trans_amount<=100000 then '03.[5万,10万)'
            when t.trans_amount >100000 then '04.10万以上'
            else '05.other'
       end as grp_trans_amount

from eif_member.t_member a

join eif_member.t_member_client_external m on a.member_no=m.member_no

left outer join
(select member_no
       ,idno
       ,timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate()) as age
       ,case when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate()) <20 then '01.<20'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=20 and timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())<30 then '02.[20,30)'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=30 and timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())<40 then '03.[30,40)'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=40 and timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())<50 then '04.[40,50)'
             when timestampdiff(year,date_format(substr(idno,7,8),'%y-%m-%d'),curdate())>=50 then '05.>=50'
             else '06.other'
        end as grp_age
       ,case cast(substring(idno,17,1) as UNSIGNED)%2 when 1 then '男' when 0 then '女' else '未知' end as gender
 from eif_member.t_client_certification where length(idno)=18 and status=1
)s on a.member_no=s.member_no

left outer join
(select member_no,create_time from eif_member.t_client_certification where status=1)b on a.member_no=b.member_no

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
       ,min(trans_time) as trans1st_time
       ,count(*) as trans_cnt
       ,sum(fund_trans_amount) as trans_amount
 from eif_ftc.t_ftc_fund_trans_order 
 where status in (6,9,11) 
 group by member_no
)t on a.member_no=t.member_no

;




select grp_reg2trans1st_days, count(*), avg(reg2cert_days), avg(cert2card_days), avg(card2trans1_days)
from(
select grp_reg2trans1st_days
      ,datediff(cert_time, reg_time)  as reg2cert_days
      ,datediff(card_time, cert_time) as cert2card_days
      ,datediff(trans1st_time, card_time) as card2trans1_days  
from test.wy_temp where grp_reg2trans1st_days<>'05.ohter' and datediff(trans1st_time, card_time)>=0
)t
group by grp_reg2trans1st_days
;


ALTER TABLE test.wy_temp ADD INDEX ik (member_no);
ALTER TABLE test.wy_temp ADD INDEX im (prefix);

drop table test.wy_temp1;
create table test.wy_temp1
(member_no char(32)
,mobile char(20)
,prefix char(20)
,market_channel char(20)
,idno char(20)
,age int(5)
,gender char(10)
,grp_age char(10)
,reg_time DATETIME
,cert_time DATETIME
,card_time DATETIME
,trans1st_time DATETIME
,class char(15)
);

insert into test.wy_temp1
select t.*, c.class
from test.wy_temp t
left outer join test.wy_mobile_city_class c on t.prefix=c.prefix
;


drop table test.wy_temp2;
create table test.wy_temp2
(user_id char(32)
,is_expri char(20)
);

insert into test.wy_temp2
select a.user_id
      ,case when date(max(a.expripration_time))>='2016-05-13' then '新手大礼包未过期' else '新手大礼包已过期' end as is_expri
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where b.name like '%新手大礼包%' 
group by a.user_id
;

ALTER TABLE test.wy_temp2 ADD INDEX ik (user_id);


drop table test.wy_temp3;
create table test.wy_temp3
(member_no char(32)
,mobile char(20)
,idno char(20)
,market_channel char(32)
,reg_time DATETIME
,reg_days char(20)
,is_expri char(20)
);

insert into test.wy_temp3
select t.member_no
      ,mobile
      ,idno
      ,t.market_channel
      ,reg_time
      ,case when datediff(now(), reg_time)>=15 then '注册时间>=15天' else '注册时间<15天' end as reg_days
      ,coalesce(t2.is_expri, '新手大礼包已过期') as is_expri
from test.wy_temp t left outer join test.wy_temp2 t2 on t.member_no=t2.user_id
where t.card_time is null
;

mysql -e "select * from test.wy_temp3;">cus_info.txt


%%hive%%
drop table bi.wy_temp;
create table bi.wy_temp
(member_no string
,mobile string
,idno string
,market_channel string
,reg_time string
,reg_days string
,is_expri string
)
row format delimited fields terminated by '\t'
lines terminated by '\n'
stored as textfile
;
load data local inpath '/home/wangyi/cus_info.txt' overwrite into table bi.wy_temp
;

drop table bi.wy_temp1;
create table bi.wy_temp1 as
select t.*
      ,coalesce(m.Estate_Purc_Ind, 0)   as is_fangchan
      ,coalesce(m.Spring_Cust_Ind, 0)   as is_bingquan
      ,case when fb.mobl_num is null then 0 else 1 end as is_fb_fans
from(
select t.*
      ,coalesce(m1.Gu_Indv_Id, m2.Gu_Indv_Id, m3.Gu_Indv_Id, m4.Gu_Indv_Id) as cus_id
      ,case when m1.mobl_num1  is null then 0 else 1 end as m1_match
      ,case when m2.mobl_num2  is null then 0 else 1 end as m2_match
      ,case when m3.mobl_num3  is null then 0 else 1 end as m3_match
      ,case when m4.Idtfy_Info is null then 0 else 1 end as id_match     
from bi.wy_temp t
left outer join(select mobl_num1, max(Gu_Indv_Id) as Gu_Indv_Id from csum.H52_Cust_Inds_Merge where mobl_num1 is not null and mobl_num1<>'' group by mobl_num1)m1 on t.mobile=m1.mobl_num1
left outer join(select mobl_num2, max(Gu_Indv_Id) as Gu_Indv_Id from csum.H52_Cust_Inds_Merge where mobl_num2 is not null and mobl_num2<>'' group by mobl_num2)m2 on t.mobile=m2.mobl_num2
left outer join(select mobl_num3, max(Gu_Indv_Id) as Gu_Indv_Id from csum.H52_Cust_Inds_Merge where mobl_num3 is not null and mobl_num3<>'' group by mobl_num3)m3 on t.mobile=m3.mobl_num3
left outer join(select Idtfy_Info,max(Gu_Indv_Id) as Gu_Indv_Id from csum.H52_Cust_Inds_Merge where Idtfy_Info is not null and Idtfy_Info<>'' group by Idtfy_Info)m4 on t.idno=m4.Idtfy_Info
)t
left outer join csum.H52_Cust_Inds_Merge m on t.cus_id=m.Gu_Indv_Id
left outer join(select mobl_num from csum.H052_Fb_Mem_Csum Mobl_Num where mobl_num is not null and mobl_num<>'' group by mobl_num)fb on t.mobile=fb.mobl_num
;


select reg_days, market_channel, is_expri, is_fangchan, is_bingquan, is_fb_fans, count(*), count(distinct mobile) from bi.wy_temp1 group by reg_days, market_channel, is_expri, is_fangchan, is_bingquan, is_fb_fans;