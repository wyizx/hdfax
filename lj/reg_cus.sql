drop table test.wy_temp1;
create table test.wy_temp1
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
);

insert into test.wy_temp1
select a.member_no
      ,a.mobile
      ,substr(a.mobile,1,7) as prefix
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

from(select member_no, create_time, verified_mobile as mobile from eif_member.t_member where length(verified_mobile)=11 and verified_mobile like '1%')a

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