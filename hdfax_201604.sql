--�ͻ�����RFM
----�ͻ���Ż�����Ωһ��ʶ��
----ÿλ�ͻ�����һ�ζ�������
----�ÿͻ���ɵĽ�������
----�ÿͻ�������������
drop table test.hafax_rfm;
create table test.hafax_rfm as
select member_no, max(trans_time) as max_trans_time, count(*) as trans_num, sum(fund_trans_amount) as trans_amount
from eif_ftc.t_ftc_fund_trans_order
where status in (6,9,11)
group by member_no
;


--��ע�ᵽ���׵�ʱ��ֲ�
drop table test.hdfax_reg2trans_cus;
create table test.hdfax_reg2trans_cus as
select a.member_no
      ,a.create_time
      ,b.min_trans_time
      ,b.max_trans_time
      ,datediff(b.min_trans_time, a.create_time) as reg2trans_days_datediff
      ,round(((UNIX_TIMESTAMP(b.min_trans_time) - UNIX_TIMESTAMP(a.create_time))/((60*60*24)+1)),1) as reg2trans_days
from eif_member.t_member a
left outer join
(select member_no
       ,min(trans_time) as min_trans_time
       ,max(trans_time) as max_trans_time
 from eif_ftc.t_ftc_fund_trans_order 
 where status in ('6','9','11')
 group by member_no
)b on a.member_no=b.member_no
where length(a.verified_mobile) = 11 and substr(a.verified_mobile,1,1) = 1
;

select reg2trans_days, count(*) from test.hdfax_reg2trans_cus group by reg2trans_days;


drop table test.hdfax_temp;
create table test.hdfax_temp as
select a.*,mem_num,cert_num,bank_num,trade_num
from(
    select substr(a.create_time,1,10) as data_dt
            ,count(distinct a.member_no)
            ,count(distinct c.member_no) as new_cert_num
            ,count(distinct b.member_no) as new_bank_num
            ,count(distinct d.member_no) as new_trad_num
    from eif_member.t_member a
    left outer join (
        select distinct member_no,substr(create_time,1,10) as data_dt
        from eif_member.t_client_certification 
        
        where status='1' 
     )c 
    on a.member_no=c.member_no and substr(a.create_time,1,10)=c.data_dt
    left outer join(
    select a.member_no,min(substr(c.create_time,1,10)) as data_dt
    from eif_member.t_member a
    join eif_member.t_member_bankcard b
    on a.member_no=b.member_no 
    join eif_member.t_member_bankcard_detail c
    on b.bankcard_uuid=c.bankcard_uuid
    where c.status='3'
    group by a.member_no
    )b
    on a.member_no=b.member_no and substr(a.create_time,1,10)=b.data_dt
    left outer join (
        select distinct member_no,substr(trans_time,1,10) as data_dt
        from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')
     )d 
    on a.member_no=d.member_no and substr(a.create_time,1,10)=d.data_dt
    where substr(a.create_time,1,10)>='2016-03-16'
    group by  substr(a.create_time,1,10)
)a
left outer join (
    select a.data_dt,mem_num,cert_num,bank_num,trade_num
    from 
    (
    select substr(a.create_time,1,10) as data_dt,count(distinct member_no) as mem_num
    from  eif_member.t_member a
    group by substr(a.create_time,1,10) 
    )a
    left outer join (
        select substr(create_time,1,10) as data_dt,count(distinct member_no) as cert_num
        from eif_member.t_client_certification 
        where status='1' 
        group by substr(create_time,1,10) 
     )c 
    on  a.data_dt=c.data_dt
    left outer join(
    select data_dt,count(distinct member_no) as bank_num
    from(
    select a.member_no,min(substr(c.create_time,1,10)) as data_dt
    from eif_member.t_member a
    join eif_member.t_member_bankcard b
    on a.member_no=b.member_no 
    join eif_member.t_member_bankcard_detail c
    on b.bankcard_uuid=c.bankcard_uuid
    where c.status='3'
    group by a.member_no
    )a
    group by data_dt
    )b
    on a.data_dt=b.data_dt
    left outer join (
        select substr(trans_time,1,10) as data_dt,count(distinct member_no) as trade_num
        from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')
        group by substr(trans_time,1,10)
     )d 
    on a.data_dt=d.data_dt
    where a.data_dt>='2016-03-16'
    
)b
on a.data_dt=b.data_dt
;


--ͳ�Ʋ�Ʒ���۶�
select substr(trans_time,1,10) date_id
    ,sum(case when product_name like '%����ר��%' or product_name like '%����ר��%' then fund_trans_amount end) as xinshou_order_amt
    ,sum(case when product_name like '%��ҫ����%' then fund_trans_amount end) as hy_tianli_order_amt
    ,sum(case when product_name like '%��ҫ����%' then fund_trans_amount end) as hy_wenxiang_order_amt
    ,sum(case when product_name like '%��ҫ����%' then fund_trans_amount end) as hy_anyi_order_amt
    ,sum(case when product_name like '%��ҫ��ѡ%' then fund_trans_amount end) as hy_youxuan_order_amt
    ,sum(case when product_name like '%��ҫ��Ӯ%' then fund_trans_amount end) as hy_huiying_order_amt
    ,sum(fund_trans_amount) as total_order_amt
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.status in (6,9,11)
group by substr(trans_time,1,10)
;

----��Ʒ�����ٶ�
select product_name
      ,product_scale
      ,REPLACE(display_rate,'%','') as display_rate_num
      ,
      ,(UNIX_TIMESTAMP(max(trans_time)) - UNIX_TIMESTAMP(trans_begin_time))/60
from eif_fis.t_fis_prod_info
group by product_name
;



**--2016.04.15
--�������������4��15-17�����ִ������ȯ���ڵ��û����Ͷ��ţ����æ������Ҫ����ȡ���ݽ��������ŷ��ͣ���Ⱥɸѡ���£�

--1��4��15�����ִ������ȯ���ڣ���δʹ�ù���ȯ
drop table  test.wy_coupon_0415;
create table test.wy_coupon_0415(
user_id char(32)
,verified_mobile varchar(32)
);

INSERT INTO  test.wy_coupon_0415(
select t1.user_id, m.verified_mobile from 
(#--4��15�յ�����û��ʹ�õ�ȯ�û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10)='2016-04-15'
and a.status='1'  and b.name like '%���ִ����%' 
group by a.user_id
)t1 left outer join
(#--ʹ�ù�����һ��ȯ���û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%���ִ����%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where t2.user_id is null and verified_mobile like '1%' and length(verified_mobile)=11
)
;

select * from 

--2��4��15�����ִ������ȯ���ڣ�������ʹ�ù�1�ż�������ȯ���޳���ʣ��һ��500Ԫ�Ż�ȯ������10��ʹ�ã���֧��ͨ�����Ʋ����ã����û�
drop table  test.wy_coupon_0415_2;
create table test.wy_coupon_0415_2(
user_id char(32)
,verified_mobile varchar(32)
);

INSERT INTO test.wy_coupon_0415_2(
select t1.user_id, m.verified_mobile from 
(#--4��15�յ�����û��ʹ�õ�ȯ�û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10)='2016-04-15'
and a.status='1' and b.name like '%���ִ����%' and rule_discription not like '%100000%'
group by a.user_id
)t1 join
(#--ʹ�ù�����һ��ȯ���û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%���ִ����%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where verified_mobile like '%1%' and length(verified_mobile)=11
)
;

--3��4��16-17�����ִ������ȯ���ڣ���δʹ�ù���ȯ
drop table  test.wy_coupon_0415_3;
create table test.wy_coupon_0415_3(
user_id char(32)
,verified_mobile varchar(32)
);

INSERT INTO  test.wy_coupon_0415_3(
select t1.user_id, m.verified_mobile from 
(#--4��15�յ�����û��ʹ�õ�ȯ�û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10) in ('2016-04-16','2016-04-17')
and a.status='1'  and b.name like '%���ִ����%' 
group by a.user_id
)t1 left outer join
(#--ʹ�ù�����һ��ȯ���û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%���ִ����%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where t2.user_id is null and verified_mobile like '1%' and length(verified_mobile)=11
)
;
--4��4��16-17�����ִ������ȯ���ڣ�������ʹ�ù�1�ż�������ȯ���޳���ʣ��һ��500Ԫ�Ż�ȯ������10��ʹ�ã���֧��ͨ�����Ʋ����ã����û�
drop table  test.wy_coupon_0415_4;
create table test.wy_coupon_0415_4(
user_id char(32)
,verified_mobile varchar(32)
);

INSERT INTO test.wy_coupon_0415_4(
select t1.user_id, m.verified_mobile from 
(#--4��15�յ�����û��ʹ�õ�ȯ�û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10) in ('2016-04-16','2016-04-17')
and a.status='1' and b.name like '%���ִ����%' and rule_discription not like '%100000%'
group by a.user_id
)t1 join
(#--ʹ�ù�����һ��ȯ���û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%���ִ����%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where verified_mobile like '%1%' and length(verified_mobile)=11
)
;



**--ÿ�հ�ʧ���ʺͽ���ʧ����

select card_date, status, count(*) from
(
select date(create_time) as card_date, bankcard_no, min(status) as status
from eif_member.t_member_bankcard_detail
group by date(create_time), bankcard_no
)t
group by card_date, status
;




select trans_date
 ,count(*)
 ,sum(fund_trans_amount) as trans_amount
 ,count(distinct member_no) as cus_num
 ,sum(is_success) as succeed_order
 ,sum(is_fault) as fault_order
from
(
select date(create_time) as trans_date
,fund_trans_amount
,member_no 
,case when status in ('6','9','11') then 1 else 0 end as is_success
,case when status in ('7','10') then 1 else 0 end as is_fault
from eif_ftc.t_ftc_fund_trans_order 
)t
group by trans_date
;

select date(create_time), count(*), count(distinct member_no) from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11') group by date(create_time);


select date(create_time), count(distinct member_no) from eif_ftc.t_ftc_fund_trans_order group by date(create_time);

select p.product_name, t.status, t.trans_time, t.create_time from eif_ftc.t_ftc_fund_trans_order t
join eif_member.t_member m on t.member_no=m.member_no
join eif_fis.t_fis_prod_info p on t.product_id = p.id
where m.verified_mobile = '13671519029'
;

select status, count(*) from eif_ftc.t_ftc_fund_trans_order group by status;


select t.products_name, t.payment_time, t.create_time, t.modify_time, t.status_detail, t.status, amount from eif_ftc.t_paycore_payment t
join eif_member.t_member m on t.member_no=m.member_no
where m.verified_mobile = '13671519029'
;

mysql -e 'select date(create_time) as pay_time, status, status_detail, count(*) as pay_count, count(distinct member_no) as pay_cus from eif_ftc.t_paycore_payment where status='6' group by date(create_time), status, status_detail order by pay_time, pay_count desc;' > pay.txt

mysql -e 'select status_detail, count(*) as pay_count, count(distinct member_no) as pay_cus from eif_ftc.t_paycore_payment where status='6' and date(create_time)>='2016-04-01' group by status_detail order by pay_count desc;' > pay_asum.txt


select status_detail, count(*) as pay_count, count(distinct member_no) as pay_cus from eif_ftc.t_paycore_payment where status='6' and date(create_time)>='2016-04-01' group by status_detail order by pay_count desc;


4 -��֧��;
5 -֧����;
6 -֧���ɹ�;
7 -֧��ʧ��;
8 -�����״�����;
9 -�����׳ɹ�;
10-������ʧ��;
11-�����׽��֪ͨ�ɹ�;
12-�˿���;
13-�˿�ɹ�;
14-�˿�ʧ��;
15-�޶��ع���;
17-ȡ��;
18-���ڹر�;
19-�����˿�ɹ�;
20-������;
21-���ֳɹ�;
22-����ʧ��;
23-����ύ�ɹ�;
24-�ȴ�������֤;
25-��ع���;
26-��ؾܾ�


***--2016.04.18
--1��4��19�����ִ������ȯ���ڣ���δʹ�ù���ȯ
drop table  test.wy_coupon_0426;
create table test.wy_coupon_0426(
user_id char(32)
,mobile varchar(32)
);

INSERT INTO  test.wy_coupon_0426(
select t1.user_id, m.verified_mobile as mobile from 
(#--4��15�յ�����û��ʹ�õ�ȯ�û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10)='2016-04-26'
and a.status='1'  and b.name like '%���ִ����%'
group by a.user_id
)t1 left outer join
(#--ʹ�ù�����һ��ȯ���û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%���ִ����%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where t2.user_id is null and verified_mobile like '1%' and length(verified_mobile)=11
)
;

--2��4��19�����ִ������ȯ���ڣ�������ʹ�ù�1�ż�������ȯ���޳���ʣ��һ��500Ԫ�Ż�ȯ������10��ʹ�ã���֧��ͨ�����Ʋ����ã����û���
drop table  test.wy_coupon_0426_2;
create table test.wy_coupon_0426_2(
user_id char(32)
,mobile varchar(32)
);

INSERT INTO test.wy_coupon_0426_2(
select t1.user_id, m.verified_mobile as mobile from 
(#--4��15�յ�����û��ʹ�õ�ȯ�û�
select a.user_id
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where substr(a.expripration_time,1,10)='2016-04-26'
and a.status='1' and b.name like '%���ִ����%' and rule_discription not like '%100000%'
group by a.user_id
)t1 join
(#--ʹ�ù�����һ��ȯ���û�
select a.user_id 
from eif_market.t_market_coupon_user a
join eif_market.t_market_activity_coupon b on a.activity_coupon_id=b.id
where a.status='2' and b.name like '%���ִ����%' 
group by a.user_id
)t2 on t1.user_id=t2.user_id
join eif_member.t_member m on t1.user_id=m.member_no
where verified_mobile like '%1%' and length(verified_mobile)=11
)
;


***--2016.04.20

--ҵ����ע���û�
drop table  test.wy_fax_allhs_user_0420;
create table test.wy_fax_allhs_user_0420(
member_no char(32)
);

insert into test.wy_fax_allhs_user_0420
select distinct member_no
from (
    select b.member_no
          ,idno
          ,a.idtfy_info
          ,case when a.idtfy_info is not null then 1 else 0 end as idno_tag
          ,verified_mobile
          ,a.mobl_num1
          ,0 as mobile_tag
    from eif_member.t_member b 
    left outer join eif_member.t_client_certification c 
    on b.member_no = c.member_no and c.id_type ='0'
    left outer join (
        select  vmobilephone as mobl_num1,vlicensecode as idtfy_info  
        from eif_bi.pr_bd_customer
        where dr != 1
        #union all  
        #select mobl_num1,idtfy_info
        #from test.h52_cust_inds_merge 
        #where Estate_Purc_Ind=1
        )a on a.idtfy_info = c.idno 
       where c.idno != "" 
union all
    select b.member_no
          ,idno
          ,a.idtfy_info
          ,0 as idno_tag
          ,verified_mobile
          ,a.mobl_num1
          ,case when a.mobl_num1 is not null then 1 else 0 end  as mobile_tag
     from eif_member.t_member b 
     left outer join eif_member.t_client_certification c 
     on b.member_no = c.member_no and c.id_type ='0'
     left outer join (
        select  vmobilephone as mobl_num1,vlicensecode as idtfy_info  
        from eif_bi.pr_bd_customer
        where dr != 1
        #union all  
        #select mobl_num1,idtfy_info
        #from test.h52_cust_inds_merge 
        #where Estate_Purc_Ind=1
        )a  on a.mobl_num1 = b.verified_mobile
       where  b.verified_mobile!=""
 )a
where (a.idno_tag =1 or mobile_tag = 1)
;

select count(*), count(distinct a.member_no), sum(fund_trans_amount)
from test.wy_fax_allhs_user_0420 a
join eif_ftc.t_ftc_fund_trans_order b on a.member_no=b.member_no
where b.status in (6,9,11)
;



select a.member_no, sum(fund_trans_amount) as trans_amount
from test.wy_fax_allhs_user_0420 a
join eif_ftc.t_ftc_fund_trans_order b on a.member_no=b.member_no
where b.status in (6,9,11)
group by a.member_no
order by trans_amount desc
limit 30; 


select member_no, sum(fund_trans_amount) as trans_amount
from eif_ftc.t_ftc_fund_trans_order
where status in (6,9,11)
group by member_no
order by trans_amount desc
limit 10
;

select * from eif_ftc.t_ftc_fund_trans_order where member_no='8a8180bd536aed65015383a28d6e05b7' where status in (6,9,11);


select count(*) from test.wy_fax_allhs_user_0420;
24584

-----ҵ��δע���û�
drop table  test.wy_fax_allhs_user_0420_n;
create table test.wy_fax_allhs_user_0420_n(
verified_mobile varchar(60)
);

insert into test.wy_fax_allhs_user_0420_n
select distinct a.verified_mobile from
(select vmobilephone as verified_mobile from eif_bi.pr_bd_customer where dr != 1 and vmobilephone<>'' and vmobilephone is not null group by vmobilephone)a
left outer join test.wy_fax_allhs_user_0420 b on a.verified_mobile=b.verified_mobile
where b.verified_mobile is null and a.verified_mobile like '1%' and length(a.verified_mobile)=11
; 466713


--������������û����޳��ز�ҵ���û���
--�������ע��δ�����û����޳��ز�ҵ���û���
drop table  test.wy_fax_allhs_user_0420_jy;
create table test.wy_fax_allhs_user_0420_jy(
verified_mobile varchar(32)
,is_trans varchar(10)
);



insert into test.wy_fax_allhs_user_0420_jy
select m.verified_mobile, case when t.member_no is not null then 'trans1' else 'trans0' end as is_trans
from eif_member.t_member m
left outer join(select member_no from eif_ftc.t_ftc_fund_trans_order where status in (6,9,11) group by member_no)t on t.member_no=m.member_no 
left outer join test.wy_fax_allhs_user_0420 yz on m.verified_mobile=yz.verified_mobile
left outer join(select vmobilephone as verified_mobile from eif_bi.pr_bd_customer where dr != 1 and vmobilephone<>'' and vmobilephone is not null group by vmobilephone)y on y.verified_mobile=m.verified_mobile
where yz.verified_mobile is null and y.verified_mobile is null and m.verified_mobile like '1%' and length(m.verified_mobile)=11
;

select count(*) from test.wy_fax_allhs_user_0420_jy a join (select vmobilephone as verified_mobile from eif_bi.pr_bd_customer where dr != 1)b on a.verified_mobile=b.verified_mobile;

select count(*) from test.wy_fax_allhs_user_0420_jy a 
join eif_member.t_member m on a.verified_mobile=m.verified_mobile
join(select member_no from eif_ftc.t_ftc_fund_trans_order where status in (6,9,11) group by member_no)t on m.member_no=t.member_no
where a.is_trans='trans1'
;


drop table  test.wy_temp;
create table test.wy_temp(
verified_mobile varchar(32)
,idno char(32)
,name varchar(64)
,certname varchar(10)
);

insert into test.wy_temp
select t.verified_mobile, c.idno, c.name, c.certname from
(select verified_mobile from test.wy_fax_allhs_user_0420_jy 
 where is_trans='trans1' 
  and verified_mobile is not null 
  and verified_mobile<>'NULL' 
  and verified_mobile<>''
)t
join eif_member.t_member m on t.verified_mobile=m.verified_mobile
join
(select member_no, idno, name
       ,case when length(idno)=18 and substr(idno,17,1) in (1,3,5,7,9) then concat(substr(name,1,1),'����')
             when length(idno)=18 and substr(idno,17,1) in (2,4,6,8,0) then concat(substr(name,1,1),'Ůʿ')
             else concat(substr(name,1,1),'����/Ůʿ')
        end as certname
 from eif_member.t_client_certification
 where status='1'
)c on m.member_no=c.member_no
;

mysql -e "select verified_mobile as mobile from test.wy_fax_allhs_user_0420;">yz_reg.txt
mysql -e "select verified_mobile as mobile from test.wy_fax_allhs_user_0420_n">yz_not_reg.txt
mysql -e "select verified_mobile as mobile from test.wy_fax_allhs_user_0420_jy where is_trans='trans1' and verified_mobile is not null and verified_mobile<>'NULL' and verified_mobile<>'';">trans.txt
mysql -e "select verified_mobile as mobile from test.wy_fax_allhs_user_0420_jy where is_trans='trans0' and verified_mobile is not null and verified_mobile<>'NULL' and verified_mobile<>'';">not_trans.txt


drop table bi.wy_fax_allhs_user_0420;
create table bi.wy_fax_allhs_user_0420
(verified_mobile string)
row format delimited fields terminated by ','
lines terminated by '\n'
stored as textfile
--location "/bi/wangyi/wy_fax_allhs_user_0420"
;
load data local inpath '/home/wangyi/yz_reg.txt' overwrite into table bi.wy_fax_allhs_user_0420
;

drop table bi.wy_temp;

create table bi.wy_temp as
select m.verified_mobile, case when t.member_no is not null then 'trans1' else 'trans0' end as is_trans
from sdata.s_fax_t_member_d_20160419 m
left outer join(select member_no from sdata.s_fax_t_ftc_fund_trans_order_d_20160419 where status in (6,9,11) group by member_no)t on t.member_no=m.member_no 
left outer join bi.wy_fax_allhs_user_0420 yz on m.verified_mobile=yz.verified_mobile
left outer join(select vmobilephone as verified_mobile from sdata.s_hpm_pr_bd_customer_d_20160419 where dr != 1 and vmobilephone<>'' and vmobilephone is not null group by vmobilephone)y on y.verified_mobile=m.verified_mobile
where yz.verified_mobile is null and y.verified_mobile is null and m.verified_mobile like '1%' and length(m.verified_mobile)=11
;

hive -e "select verified_mobile as mobile from bi.wy_temp where is_trans='trans1';">trans.txt
hive -e "select verified_mobile as mobile from bi.wy_temp where is_trans='trans0';">not_trans.txt



***--2016.04.22

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



(
select product_id
      ,trans_begin_time
      ,max(a.trans_time) as trans_end_time
      ,round(((UNIX_TIMESTAMP(due_date) - UNIX_TIMESTAMP(inception_date))/((60*60*24)+1))/10)*10 as invest_days
      ,display_rate
      ,sum(fund_trans_amount)/((UNIX_TIMESTAMP(max(trans_time))-UNIX_TIMESTAMP(trans_begin_time))/60) as sale_per_minute
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.status in (6,9,11)
and a.trans_time>='2016-04-01'
and display_rate='6.8%'
group by a.product_id
)a
join
(
select product_id
      ,trans_begin_time
      ,max(a.trans_time) as trans_end_time
      ,round(((UNIX_TIMESTAMP(due_date) - UNIX_TIMESTAMP(inception_date))/((60*60*24)+1))/10)*10 as invest_days
      ,display_rate
      ,sum(fund_trans_amount)/((UNIX_TIMESTAMP(max(trans_time))-UNIX_TIMESTAMP(min(trans_time)))/60) as sale_per_minute
from eif_ftc.t_ftc_fund_trans_order a
left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
where a.status in (6,9,11)
and a.trans_time>='2016-04-01'
and display_rate='7%'
group by a.product_id
)b on a.trans_begin_time

***--2014.04.22
������       û��       4192270
������       ����       1080722


select Estate_Purc_Inte_Ind,
Estate_Purc_Ind, 
count(*) as cnt 
from csum.H52_Cust_Inds_Merge 
group by Estate_Purc_Inte_Ind
,Estate_Purc_Ind 
where coalesce(b.Mobl_Num1, b.Mobl_Num2, b.Mobl_Num3, '') is not null 
and coalesce(b.Mobl_Num1, b.Mobl_Num2, b.Mobl_Num3, '')<>'';



  һ�������ѹ���
  һ������δ����


select Estate_Purc_Inte_Ind
      ,case when substr(Estate_Fst_Purc_Inte_Dt)
  
���������־	Estate_Purc_Inte_Ind
���������������	Estate_Fst_Purc_Inte_Dt
�����ͻ���־	Estate_Purc_Ind
�״ι�������	Estate_Purc_Fst_Dt


select * from 
(
select Estate_Fst_Purc_Inte_Dt
      ,case when substr(Estate_Fst_Purc_Inte_Dt,1,10)>='2015-04-22' then 1 else 0 end as f1
      ,case when substr(Estate_Purc_Fst_Dt,1,10)>='2015-04-22' then 1 else 0 end as f2
from csum.H52_Cust_Inds_Merge
where Estate_Fst_Purc_Inte_Dt is not null and Estate_Fst_Purc_Inte_Dt<>''
)t
limit 10
;

select count(*) from csum.H52_Cust_Inds_Merge


select Estate_Purc_Inte_Ind, Estate_Fst_Purc_Inte_Dt, Estate_Purc_Ind, Estate_Purc_Fst_Dt
from csum.H52_Cust_Inds_Merge where Estate_Purc_Ind='1'
;


select Estate_Purc_Inte_Ind, Estate_Purc_Ind, is_lastest_1y, is_sp, count(*) from
(
select t1.*
 ,t2.max_sign_dt
 ,case when max_sign_dt is not null and substr(t2.max_sign_dt,1,10)>='2015-04-22' then 1 else 0 end as is_lastest_1y
 ,case when t3.indv_id is null then 0 else 1 end as is_sp 
from
(select Gu_Indv_Id, Estate_Purc_Inte_Ind, Estate_Purc_Ind from csum.H52_Cust_Inds_Merge where coalesce(Mobl_Num1, Mobl_Num2, Mobl_Num3, '') is not null 
and coalesce(Mobl_Num1, Mobl_Num2, Mobl_Num3, '')<>'')t1
left outer join
(select Gu_Indv_Id, max(Contr_Sign_Dt) as max_sign_dt from csum.H52_Estt_Tx_Csum where Contr_Sign_Dt is not null and Contr_Sign_Dt<>'' group by Gu_Indv_Id)t2 on t1.Gu_Indv_Id=t2.Gu_Indv_Id
left outer join
(select indv_id from csum.h62_indv_tag_matrix where ctgy_12213002='100040')t3 on t1.Gu_Indv_Id=t3.indv_id
)t
group by Estate_Purc_Inte_Ind, Estate_Purc_Ind, is_lastest_1y, is_sp
;


***--2014.04.22
--֧��ʧ�ܰ����н���ͳ��

select member_no, status_detail from eif_ftc.t_paycore_payment where status=6
join eif_member.t_member_bankcard_detail bankcard_uuid


