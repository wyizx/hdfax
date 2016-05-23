***--2014.04.26
-----客户前两次购买时间
drop table  test.wy_temp;
create table test.wy_temp(
member_no char(32)
,trans_time timestamp
,product_id bigint(20)
,product_name varchar(255)
,display_rate varchar(15)
,days int(10)
,amount decimal(26,6)
,rank int(10)
,min_invest_amt bigint(10)
);

insert into test.wy_temp
select a.*, b.min_invest_amt
from(
    select  member_no, trans_time, product_id, product_name, display_rate, days, amount, rank 
    from(
    select a.*
          ,@rownum:=@rownum+1
          ,if(@member_no=a.member_no,@rank:=@rank+1,@rank:=1) as rank
          ,@member_no:=a.member_no
    from(
        select  member_no
                ,trans_time 
                ,a.product_id
                ,product_name
                ,display_rate
                ,datediff(b.due_date,b.inception_date) as days 
                ,fund_trans_amount as amount
        from eif_ftc.t_ftc_fund_trans_order a
        left outer join eif_fis.t_fis_prod_info b on a.product_id = b.id
        where a.status in (6,9,11) and date(a.trans_time) <= '2016-05-08'
        -- and member_no='8a8180bd528fb43001529a7c39aa03fa'
        order by member_no asc,trans_time asc
    )a,(select @rownum:=0,@member_no:=null,@rank:=0)b
    )result
)a

left outer join
(select product_id, case when min(fund_trans_amount)<10000 then 100 else 10000 end as min_invest_amt
from eif_ftc.t_ftc_fund_trans_order 
where status in (6,9,11) and date(trans_time) <= '2016-05-08'
group by product_id
)b on a.product_id=b.product_id
--where rank in (1,2)
;

-----各阶段时间分布
drop table test.wy_temp2;
create table test.wy_temp2(
member_no char(32)
,mobile char(20)
,market_channel char(32)
,idno char(32)
,age int(10)
,gender char(5)
,grp_age char(10)
,reg_time DATETIME
,cert_time DATETIME
,card_time DATETIME
,trans1st_time DATETIME
,trans2nd_time DATETIME
,reg2cert_days int(10)
,cert2card_days int(10)
,card2trans1st_days int(10)
,trans1st2nd_days char(20)
,reg2trans1st_days int(10)
,grp_reg2cert_days char(20)
,grp_cert2card_days char(20)
,grp_card2trans1st_days char(20)
,grp_trans1st2nd_days char(20)
,grp_reg2trans1st_days char(20)
);


insert into test.wy_temp2
select t.*
      ,case when reg2cert_days>=0  and reg2cert_days<1  then '01.[0,1)'
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
      ,case when cert2card_days>=0  and cert2card_days<1  then '01.[0,1)'
            when cert2card_days>=1  and cert2card_days<2  then '02.[1,2)'
            when cert2card_days>=2  and cert2card_days<3  then '03.[2,3)'
            when cert2card_days>=3  and cert2card_days<4  then '04.[3,4)'
            when cert2card_days>=4  and cert2card_days<5  then '05.[4,5)'
            when cert2card_days>=5  and cert2card_days<6  then '06.[5,6)'
            when cert2card_days>=6  and cert2card_days<7  then '07.[6,7)'
            when cert2card_days>=7  and cert2card_days<8  then '08.[7,8)'
            when cert2card_days>=8  and cert2card_days<9  then '09.[8,9)'
            when cert2card_days>=9  and cert2card_days<10 then '10.[9,10)'
            when cert2card_days>=10 and cert2card_days<11 then '11.[10,11)'
            when cert2card_days>=11 and cert2card_days<12 then '12.[11,12)'
            when cert2card_days>=12 and cert2card_days<13 then '13.[12,13)'
            when cert2card_days>=13 and cert2card_days<14 then '14.[13,14)'
            when cert2card_days>=14 and cert2card_days<15 then '15.[14,15)'
            when cert2card_days>=15 and cert2card_days<16 then '16.[15,16)'
            when cert2card_days>=16 and cert2card_days<17 then '17.[16,17)'
            when cert2card_days>=17 and cert2card_days<18 then '18.[17,18)'
            when cert2card_days>=18 and cert2card_days<19 then '19.[18,19)'
            when cert2card_days>=19 and cert2card_days<20 then '20.[19,20)'
            when cert2card_days>=20 and cert2card_days<30 then '21.[20,30)'
            when cert2card_days>=30     then '22.>30'
            when cert2card_days is null then '23.NotCard'
            else '24.Other'
       end as grp_cert2card_days
      ,case when card2trans1st_days>=0  and card2trans1st_days<1  then '01.[0,1)'
            when card2trans1st_days>=1  and card2trans1st_days<2  then '02.[1,2)'
            when card2trans1st_days>=2  and card2trans1st_days<3  then '03.[2,3)'
            when card2trans1st_days>=3  and card2trans1st_days<4  then '04.[3,4)'
            when card2trans1st_days>=4  and card2trans1st_days<5  then '05.[4,5)'
            when card2trans1st_days>=5  and card2trans1st_days<6  then '06.[5,6)'
            when card2trans1st_days>=6  and card2trans1st_days<7  then '07.[6,7)'
            when card2trans1st_days>=7  and card2trans1st_days<8  then '08.[7,8)'
            when card2trans1st_days>=8  and card2trans1st_days<9  then '09.[8,9)'
            when card2trans1st_days>=9  and card2trans1st_days<10 then '10.[9,10)'
            when card2trans1st_days>=10 and card2trans1st_days<11 then '11.[10,11)'
            when card2trans1st_days>=11 and card2trans1st_days<12 then '12.[11,12)'
            when card2trans1st_days>=12 and card2trans1st_days<13 then '13.[12,13)'
            when card2trans1st_days>=13 and card2trans1st_days<14 then '14.[13,14)'
            when card2trans1st_days>=14 and card2trans1st_days<15 then '15.[14,15)'
            when card2trans1st_days>=15 and card2trans1st_days<16 then '16.[15,16)'
            when card2trans1st_days>=16 and card2trans1st_days<17 then '17.[16,17)'
            when card2trans1st_days>=17 and card2trans1st_days<18 then '18.[17,18)'
            when card2trans1st_days>=18 and card2trans1st_days<19 then '19.[18,19)'
            when card2trans1st_days>=19 and card2trans1st_days<20 then '20.[19,20)'
            when card2trans1st_days>=20 and card2trans1st_days<30 then '21.[20,30)'
            when card2trans1st_days>=30     then '22.>30'
            when card2trans1st_days is null then '23.NotTrans'
            else '24.Other'
       end as grp_card2trans1st_days
      ,case when trans1st2nd_days>=0  and trans1st2nd_days<1  then '01.[0,1)'
            when trans1st2nd_days>=1  and trans1st2nd_days<2  then '02.[1,2)'
            when trans1st2nd_days>=2  and trans1st2nd_days<3  then '03.[2,3)'
            when trans1st2nd_days>=3  and trans1st2nd_days<4  then '04.[3,4)'
            when trans1st2nd_days>=4  and trans1st2nd_days<5  then '05.[4,5)'
            when trans1st2nd_days>=5  and trans1st2nd_days<6  then '06.[5,6)'
            when trans1st2nd_days>=6  and trans1st2nd_days<7  then '07.[6,7)'
            when trans1st2nd_days>=7  and trans1st2nd_days<8  then '08.[7,8)'
            when trans1st2nd_days>=8  and trans1st2nd_days<9  then '09.[8,9)'
            when trans1st2nd_days>=9  and trans1st2nd_days<10 then '10.[9,10)'
            when trans1st2nd_days>=10 and trans1st2nd_days<11 then '11.[10,11)'
            when trans1st2nd_days>=11 and trans1st2nd_days<12 then '12.[11,12)'
            when trans1st2nd_days>=12 and trans1st2nd_days<13 then '13.[12,13)'
            when trans1st2nd_days>=13 and trans1st2nd_days<14 then '14.[13,14)'
            when trans1st2nd_days>=14 and trans1st2nd_days<15 then '15.[14,15)'
            when trans1st2nd_days>=15 and trans1st2nd_days<16 then '16.[15,16)'
            when trans1st2nd_days>=16 and trans1st2nd_days<17 then '17.[16,17)'
            when trans1st2nd_days>=17 and trans1st2nd_days<18 then '18.[17,18)'
            when trans1st2nd_days>=18 and trans1st2nd_days<19 then '19.[18,19)'
            when trans1st2nd_days>=19 and trans1st2nd_days<20 then '20.[19,20)'
            when trans1st2nd_days>=20 and trans1st2nd_days<30 then '21.[20,30)'
            when trans1st2nd_days>=30     then '22.>30'
            when trans1st2nd_days is null then '23.NotTrans2nd'
            else '24.Other'
       end as grp_trans1st2nd_days
      ,case when reg2trans1st_days>=0  and reg2trans1st_days<1  then '01.[0,1)'
            when reg2trans1st_days>=1  and reg2trans1st_days<2  then '02.[1,2)'
            when reg2trans1st_days>=2  and reg2trans1st_days<3  then '03.[2,3)'
            when reg2trans1st_days>=3  and reg2trans1st_days<4  then '04.[3,4)'
            when reg2trans1st_days>=4  and reg2trans1st_days<5  then '05.[4,5)'
            when reg2trans1st_days>=5  and reg2trans1st_days<6  then '06.[5,6)'
            when reg2trans1st_days>=6  and reg2trans1st_days<7  then '07.[6,7)'
            when reg2trans1st_days>=7  and reg2trans1st_days<8  then '08.[7,8)'
            when reg2trans1st_days>=8  and reg2trans1st_days<9  then '09.[8,9)'
            when reg2trans1st_days>=9  and reg2trans1st_days<10 then '10.[9,10)'
            when reg2trans1st_days>=10 and reg2trans1st_days<11 then '11.[10,11)'
            when reg2trans1st_days>=11 and reg2trans1st_days<12 then '12.[11,12)'
            when reg2trans1st_days>=12 and reg2trans1st_days<13 then '13.[12,13)'
            when reg2trans1st_days>=13 and reg2trans1st_days<14 then '14.[13,14)'
            when reg2trans1st_days>=14 and reg2trans1st_days<15 then '15.[14,15)'
            when reg2trans1st_days>=15 and reg2trans1st_days<16 then '16.[15,16)'
            when reg2trans1st_days>=16 and reg2trans1st_days<17 then '17.[16,17)'
            when reg2trans1st_days>=17 and reg2trans1st_days<18 then '18.[17,18)'
            when reg2trans1st_days>=18 and reg2trans1st_days<19 then '19.[18,19)'
            when reg2trans1st_days>=19 and reg2trans1st_days<20 then '20.[19,20)'
            when reg2trans1st_days>=20 and reg2trans1st_days<30 then '21.[20,30)'
            when reg2trans1st_days>=30     then '22.>30'
            when reg2trans1st_days is null then '23.NotTrans'
            else '24.Other'
      end as grp_reg2trans1st_days
from    
(
select a.member_no
      ,a.verified_mobile as mobile
      ,m.market_channel
      ,s.idno
      ,s.age
      ,s.gender
      ,s.grp_age
      ,a.create_time as reg_time
      ,b.create_time as cert_time
      ,c.create_time as card_time
      ,d.trans_time as trans1st_time
      ,e.trans_time as trans2nd_time
      ,datediff(b.create_time, a.create_time) as reg2cert_days
      ,datediff(c.create_time, b.create_time) as cert2card_days
      ,datediff(d.trans_time, c.create_time)  as card2trans1st_days
      ,datediff(e.trans_time, d.trans_time)   as trans1st2nd_days
      ,datediff(d.trans_time, a.create_time)  as reg2trans1st_days
from(select member_no, create_time, verified_mobile from eif_member.t_member where create_time<='2016-04-29 12:00:00' and length(verified_mobile)=11 and verified_mobile like '1%')a

join(select member_no, market_channel from eif_member.t_member_client_external where market_channel<>'ice-spring' or market_channel is null)m on a.member_no=m.member_no

left outer join
(select member_no, idno, age, gender
,case when age>0 and age<=30 then '01.<=30'
      when age>30 and age<=40 then '02.(30,40]'
      when age>40 and age<=50 then '03.(40,50]'
      when age>50 and age<=60 then '04.(50,60]'
      when age>60 then '05.>60'
      else 'Other'
 end as grp_age 
from
(select member_no, idno
,case when idno is null then 999 else 
TIMESTAMPDIFF(YEAR,DATE_FORMAT(IF(LENGTH(idno)=18,SUBSTR(idno,7,8),CONCAT('19',SUBSTR(idno,7,6))),'%Y-%m-%d'),CURDATE())
end as age
,case if(length(idno)=18, cast(substring(idno,17,1) as UNSIGNED)%2, if(length(idno)=15,cast(substring(idno,15,1) as UNSIGNED)%2,3)) 
when 1 then '男'
when 0 then '女'
else '未知'  end as gender
from eif_member.t_client_certification where length(idno)=18
)t
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

left outer join(select * from test.wy_temp where rank=1)d on a.member_no=d.member_no

left outer join(select * from test.wy_temp where rank=2)e on a.member_no=e.member_no

)t
;

%%关联用户所属产业%%
mysql -e 'select * from test.wy_temp2;' > hdfax_cus.txt
%%hive%%
drop table bi.wy_temp;
create table bi.wy_temp
(member_no              string
,mobile                 string
,market_channel         string
,idno                   string
,age                    int
,gender                 string
,grp_age                string
,reg_time               string
,cert_time              string
,card_time              string
,trans1st_time          string
,trans2nd_time          string
,reg2cert_days          int
,cert2card_days         int
,card2trans1st_days     int
,trans1st2nd_days       int
,reg2trans1st_days      int
,grp_reg2cert_days      string
,grp_cert2card_days     string
,grp_card2trans1st_days string
,grp_trans1st2nd_days   string
,grp_reg2trans1st_days  string
)
row format delimited fields terminated by '\t'
lines terminated by '\n'
stored as textfile
--location "/bi/wangyi/wy_fax_allhs_user_0420"
;
load data local inpath '/home/wangyi/hdfax_cus.txt' overwrite into table bi.wy_temp
;
 
drop table bi.wy_temp1;
create table bi.wy_temp1 as
select t.*
      ,case when cert_time = 'NULL' then 0 else 1 end as is_cert
      ,case when card_time = 'NULL' then 0 else 1 end as is_card
      ,case when trans1st_time = 'NULL' then 0 else 1 end as is_trans1
      ,case when trans2nd_time = 'NULL' then 0 else 1 end as is_trans2
      ,coalesce(m.Estate_Purc_Ind, 0)   as is_fangchan
      ,coalesce(m.Lodger_Ind, 0)        as is_kefang
      ,coalesce(m.Hotel_Mem_Ind, 0)     as is_jiudian
      ,coalesce(m.Bevrg_Cust_Ind, 0)    as is_canyin
      ,coalesce(m.Rest_Mem_Ind, 0)      as is_canyinhy
      ,coalesce(m.Spring_Cust_Ind, 0)   as is_bingquan
      ,coalesce(m.Sport_User_Ind, 0)    as is_tiyu
      ,coalesce(m.Foot_Comn_Usr_Ind, 0) as is_football
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


%%国内城市分级%%
drop table bi.wy_city;
create table bi.wy_city
(city string
,class string
)
row format delimited fields terminated by ','
lines terminated by '\n'
stored as textfile
--location "/bi/wangyi/wy_fax_allhs_user_0420"
;
load data local inpath '/home/wangyi/city.txt' overwrite into table bi.wy_city
;

drop table bi.wy_temp2;
create table bi.wy_temp2 as
select t1.mobile
,t1.cus_id
,case when t1.reg2cert_days>20 and t1.reg2cert_days<=30 then 25
      when t1.reg2cert_days>20 then 35
      else t1.reg2cert_days
 end as reg2cert_days
,case when t1.cert2card_days>20 and t1.cert2card_days<=30 then 25
      when t1.cert2card_days>20 then 35
      else t1.cert2card_days
 end as cert2card_days
,case when t1.card2trans1st_days>20 and t1.card2trans1st_days<=30 then 25
      when t1.card2trans1st_days>20 then 35
      else t1.card2trans1st_days
 end as card2trans1st_days
,case when t1.trans1st2nd_days>20 and t1.trans1st2nd_days<=30 then 25
      when t1.trans1st2nd_days>20 then 35
      else t1.trans1st2nd_days
 end as trans1st2nd_days
,t1.grp_reg2cert_days
,t1.grp_cert2card_days
,t1.grp_card2trans1st_days
,t1.grp_trans1st2nd_days
,t1.reg_time
,t1.cert_time
,t1.card_time
,t1.trans1st_time
,t1.trans2nd_time
,t1.is_cert
,t1.is_card
,t1.is_trans1
,t1.is_trans2
,case when t1.is_fangchan=1 then '房产客户' else '非房产客户' end as is_fangchan
,case when t1.is_bingquan=1 then '冰泉客户' else '非冰泉客户' end as is_bingquan
,case when t1.is_fb_fans =1 then '球迷客户' else '非球迷客户' end as is_fb_fans
,case when t1.grp_age='NULL' then 'UnKnownAge' else grp_age end as grp_age
,case when t1.gender ='NULL' then 'UnKnownGender' else gender  end as gender
,case when market_channel='HD_XWSCAN0401' then 'TOP1:HD_XWSCAN0401'
      when market_channel='HD_bqcode0330b' then 'TOP2:HD_bqcode0330b'
      when market_channel='promotion' then 'TOP3:promotion'
      when market_channel='AppStore' then 'TOP4:AppStore'
      when market_channel='wx_promotion' then 'TOP5:wx_promotion'
      else 'OtherMarketChannel'
 end as top_market_channel
,case when market_channel in 
('F_fansshake0331a'
,'F_fansshake0409a'
,'F_fansshake0415a'
,'A_sinasports0418a'
,'A_sinasports0418b'
,'A_sinasports0418c'
,'W_sinasports0418d'
,'S_sinasports0418wb'
,'P_letv0418a'
,'P_letv0418b'
,'P_letv0418c'
,'P_letv0418d'
,'P_letv0418e'
,'A_letv0418j'
,'A_hupu0418a'
,'A_hupu0418b'
,'P_hupu0418c'
,'P_hupu0418d'
,'P_hupu0418e'
,'P_hupu0418f'
,'A_dongqiu0418a'
,'A_dongqiu0418b'
,'A_dongqiu0418c'
,'A_dongqiu0418d'
,'F_fansshake0419a'
,'F_fansshake0424a'
,'S_gdsport0424a'
,'P_hupu0428a'
,'P_hupu0428b'
,'P_hupu0428c'
,'A_dongqiu0428a'
,'A_dongqiu0428b'
,'F_fansshake0430a'
) then 1 else 0 end as is_sports_channel_cus
,case when market_channel in
('HDDC_heilongjiang'
,'HDDC_shanghai'
,'HDDC_shenzhen'
,'HDDC_jilin'
,'HDDC_yuedong'
,'HDDC_jiangsu'
,'HDDC_liaoning'
,'HDDC_shandong'
,'HDDC_anhui'
,'HDDC_gansu'
,'HDDC_shan'
,'HDDC_fujian'
,'HDDC_jiangxi'
,'HDDC_guangdong'
,'HDDC_hainan'
,'HDDC_shanxi'
,'HDDC_hunan'
,'HDDC_henan'
,'HDDC_chongqing'
,'HDDC_guangxi'
,'HDDC_sichuan'
,'HDDC_beijing'
,'HDDC_hubei'
) then 1 else 0 end as is_dichan_channel_cus
,case when market_channel in 
('F_bqjfl0513a'
,'A_bqjfl0513b'
,'P_bqjfl0513defult'
) then 1 else 0 end as is_bingquan_channel_cus
,m.city
,coalesce(y.class,'OtherCityClass') as city_class
from bi.wy_temp1 t1
left outer join(select mobile_7, regexp_replace(city,'市','') as city from bi.mobile_mapping)m on substr(t1.mobile,1,7)=mobile_7
left outer join bi.wy_city y on m.city=y.city
where market_channel not in ('HD_XWSCAN0401','ice-spring')
;

hive -e "select card2trans1st_days,grp_age,gender,city_class,is_fangchan,is_bingquan,is_fb_fans,top_market_channel,count(*) from bi.wy_temp2 where is_trans1=1 and date(card_time)>='2016-04-05' group by card2trans1st_days,grp_age,gender,city_class,is_fangchan,is_bingquan,is_fb_fans,top_market_channel;">cus_lifecycle_card2trans1st.txt

select card2trans1st_days, count(*) from bi.wy_temp2 where substr(card_time,1,10)>='2016-04-05' group by card2trans1st_days;


%%二次交易产品分布%%
select display_rate, days, count(*) from test.wy_temp where rank=2
group by display_rate, days
;

%%购买最多的产品组合%%
select product_comp, buy_cnt from
(select concat(t1.product_name '+', t2.product_name) as product_comp, count(*) as buy_cnt from
(select * from test.wy_temp where rank=1)t1
join
(select * from test.wy_temp where rank=2)t2 on t1.member_no=t2.member_no
group by concat(t1.product_name, '+', t2.product_name)
)t order by buy_cnt desc
;


%%首笔交易产品分布%%
select t.* from
(
select display_rate, days, min_invest_amt, count(*) as cnt from
(select *, case when product_name like '%新人%' then 1 else 0 end as is_xinren_product from test.wy_temp where rank=2)t
group by display_rate, days, min_invest_amt
)t
order by cnt desc
;

%%用户转化漏斗图%%
--产业用户
select is_cert, count(*) from bi.wy_temp2 where is_fb_fans=1 group by is_cert;
select is_card, count(*) from bi.wy_temp2 where is_fb_fans=1 group by is_card;
select is_trans1, count(*) from bi.wy_temp2 where is_fb_fans=1 group by is_trans1;
select is_trans2, count(*) from bi.wy_temp2 where is_fb_fans=1 group by is_trans2;

--认证信息
select grp_age, count(*) from bi.wy_temp2 group by grp_age;
select gender, count(*) from bi.wy_temp2 group by gender;
select city_class, count(*) from bi.wy_temp2 group by city_class;
select top_market_channel, count(*) from bi.wy_temp2 group by top_market_channel;


select grp_age,            count(*) from bi.wy_temp2 where is_trans2=1 group by grp_age;
select gender,             count(*) from bi.wy_temp2 where is_trans2=1 group by gender;
select city_class,         count(*) from bi.wy_temp2 where is_trans2=1 group by city_class;
select top_market_channel, count(*) from bi.wy_temp2 where is_trans2=1 group by top_market_channel;


----球迷群体



***--2016.05.03
-----从注册到首笔交易的时间
hive -e 'select datediff(trans1st_time, reg_time) as days, city_class, grp_age, count(*) as cnt from bi.wy_temp2 where is_trans1=1 group by datediff(trans1st_time, reg_time), city_class, grp_age'>temp.txt
;

***--2016.05.04
-----注册时间的决策树模型
drop table bi.wy_temp4;
create table bi.wy_temp4 as
select case when datediff(cert_time, reg_time)<=3 then 1 else 0 end as is_lt_evgdays
      ,grp_age
      ,gender
      ,top_market_channel
      ,city_class
      ,is_fangchan
      ,is_bingquan
      ,is_fb_fans
from bi.wy_temp2 where is_cert=1 
;



***--2016.05.09
drop table bi.wy_city;
create table bi.wy_city
(city string
,class string
)
row format delimited fields terminated by ','
lines terminated by '\n'
stored as textfile
--location "/bi/wangyi/wy_fax_allhs_user_0420"
;
load data local inpath '/home/wangyi/city.txt' overwrite into table bi.wy_city
;

drop table test.wy_city;
create table test.wy_city
(city char(20)
,class char(20)
);

load data local infile '/home/wangyi/city.txt' 
into table test.wy_city
FIELDS TERMINATED BY ','
;

-----实名未交易 仅一次交易 一次以上交易
drop table test.wy_temp5;
create table test.wy_temp5
(member_no char(32)
,mobile char(20)
,type char(20)
,grp_trans_amt char(20)
,grp_age char(20)
,gender char(10)
,city char(20)
,class char(20)
)
;

insert into test.wy_temp5
select a.member_no
      ,a.mobile
      ,case when n.trans_cnt is null then '01.实名未交易'
            when n.trans_cnt = 1 then '02.仅交易一次'
            when n.trans_cnt>= 1 then '03.交易一次以上'
       end as type
      ,case when trans_amount<=10000 then '01.小于1万'
            when trans_amount>10000 and trans_amount<=50000 then '02.(1万,5万]'
            when trans_amount>50000 and trans_amount<=100000 then '03.(5万,10万]'
            when trans_amount>100000 then '04.大于10万'
            else '05.Other'
       end as grp_trans_amt
      ,case when age>0  and age<=30 then '01.<=30'
            when age>30 and age<=40 then '02.(30,40]'
            when age>40 and age<=50 then '03.(40,50]'
            when age>50 and age<=60 then '04.(50,60]'
            when age>60 then '05.>60'
            else 'Other'
       end as grp_age 
      ,s.gender
      ,p.city
      ,y.class
      
from(select member_no, create_time, verified_mobile as mobile from eif_member.t_member where date(create_time)<='2016-05-08')a

 join
(select member_no, idno
,case when idno is null then 999 else 
TIMESTAMPDIFF(YEAR,DATE_FORMAT(IF(LENGTH(idno)=18,SUBSTR(idno,7,8),CONCAT('19',SUBSTR(idno,7,6))),'%Y-%m-%d'),CURDATE())
end as age
,case if(length(idno)=18, cast(substring(idno,17,1) as UNSIGNED)%2, if(length(idno)=15,cast(substring(idno,15,1) as UNSIGNED)%2,3)) 
when 1 then '男'
when 0 then '女'
else '未知'  end as gender
from eif_member.t_client_certification where length(idno)=18
)s on a.member_no=s.member_no

left outer join 

left outer join
(select member_no, count(*) as trans_cnt, sum(fund_trans_amount) as trans_amount from eif_ftc.t_ftc_fund_trans_order 
 where status in (6,9,11)
 group by member_no
)n on a.member_no=n.member_no

left outer join test.mobile_mapping p on substr(mobile,1,7)=p.prefix

left outer join test.wy_city y on replace(p.city,'市','')=replace(y.city,'市','')
;


-----实名绑卡用户
drop table test.wy_temp2;
create table test.wy_temp2
(member_no char(32)
,mobile char(20)
,grp_age char(20)
,gender char(10)
);

insert into test.wy_temp2
select a.member_no
      ,a.verified_mobile as mobile
      ,case when age>0  and age<=30 then '01.<=30'
            when age>30 and age<=40 then '02.(30,40]'
            when age>40 and age<=50 then '03.(40,50]'
            when age>50 and age<=60 then '04.(50,60]'
            when age>60 then '05.>60'
            else 'Other'
       end as grp_age
      ,s.gender
      
from eif_member.t_member a

join 
(select member_no, idno
,case when idno is null then 999 else 
TIMESTAMPDIFF(YEAR,DATE_FORMAT(IF(LENGTH(idno)=18,SUBSTR(idno,7,8),CONCAT('19',SUBSTR(idno,7,6))),'%Y-%m-%d'),CURDATE())
end as age
,case if(length(idno)=18, cast(substring(idno,17,1) as UNSIGNED)%2, if(length(idno)=15,cast(substring(idno,15,1) as UNSIGNED)%2,3)) 
when 1 then '男'
when 0 then '女'
else '未知'  end as gender
from eif_member.t_client_certification where length(idno)=18
)s on a.member_no=s.member_no

join
(select aa.member_no
 from eif_member.t_member_bankcard aa 
 join eif_member.t_member_bankcard_detail ab
 on aa.bankcard_uuid=ab.bankcard_uuid
 where ab.status=3
 group by aa.member_no
)c on a.member_no=c.member_no
;


drop table test.wy_temp4;
create table test.wy_temp4
(member_no char(32)
,trans_cnt int(10)
,trans_amount decimal(26,6)
);

insert into test.wy_temp4
select member_no, count(*) as trans_cnt, sum(fund_trans_amount) as trans_amount from eif_ftc.t_ftc_fund_trans_order 
 where status in (6,9,11)
 group by member_no
;



drop table test.wy_temp6;
create table test.wy_temp6
(member_no char(32)
,mobile char(20)
,grp_age char(20)
,gender char(10)
,type char(20)
,grp_trans_amt char(20)
#,city char(20)
#,class char(20)
);

insert into test.wy_temp6
select t.member_no
       ,t.mobile
       ,t.grp_age
       ,t.gender
       ,case when n.trans_cnt is null then '01.实名未交易'
             when n.trans_cnt = 1 then '02.仅交易一次'
             when n.trans_cnt>= 1 then '03.交易一次以上'
        end as type
       ,case when trans_amount<=10000 then '01.小于1万'
             when trans_amount>10000 and trans_amount<=50000 then '02.(1万,5万]'
             when trans_amount>50000 and trans_amount<=100000 then '03.(5万,10万]'
             when trans_amount>100000 then '04.大于10万'
             else '05.Other'
        end as grp_trans_amt
       #,p.city
       #,y.class
from test.wy_temp2 t

left outer join test.wy_temp4 n on t.member_no=n.member_no

#left outer join test.mobile_mapping p on substr(mobile,1,7)=p.prefix

#left outer join test.wy_city y on replace(p.city,'市','')=replace(y.city,'市','')
;

ALTER TABLE test.wy_temp2 ADD INDEX im ( member_no ); 
ALTER TABLE test.wy_temp4 ADD INDEX im ( member_no );

ALTER TABLE test.mobile_mapping ADD INDEX im ( city ); 
ALTER TABLE test.mobile_mapping ADD INDEX im ( city );

mysql -e "select * from test.wy_temp6;">cus_nima.txt


drop table bi.wy_temp6
;
create table bi.wy_temp6
(
member_no string
,mobile string
,grp_age string
,gender string
,type string
,grp_trans_amt string
)
row format delimited fields terminated by '\t'
lines terminated by '\n'
stored as textfile
;
load data local inpath '/home/wangyi/cus_nima.txt' overwrite  into table bi.wy_temp6
;

drop table bi.wy_temp7;
create table bi.wy_temp7 as
select t.*, y.class
from bi.wy_temp6 t
left outer join bi.mobile_mapping p on substr(mobile,1,7)=p.mobile_7

left outer join bi.wy_city y on regexp_replace(y.city,'市','')=regexp_replace(p.city,'市','')
;


select grp_age, class, gender, type, grp_trans_amt from bi.wy_temp7 group by grp_age, class, gender, type, grp_trans_amt;


select date(a.create_time) as reg_date, b.market_channel, count(*) from eif_member.t_member a
join eif_member.t_member_client_external b on a.member_no=b.member_no
where b.market_channel in ('HD_XWSCAN0401','ice-spring')
group by date(a.create_time), b.market_channel
;




***--2015.05.11
-----注册未实名绑卡用户分类

drop table bi.wy_temp5;
create table bi.wy_temp5 as

select market_channel, count(*), count(distinct t2.mobile) from bi.wy_temp2 t2
join bi.wy_temp t on t2.mobile=t.mobile
where is_cert=0 and is_fangchan='非房产客户' and is_bingquan='非冰泉客户' and is_fb_fans='非球迷客户'
group by market_channel
;






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