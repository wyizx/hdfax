#%%"绑卡送券"某日过期的人%%
# 18日发券 25日零点到期
# 19日发券 26日零点到期
# 以此类推

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
left outer join
(select d.user_id from
(select user_id, activity_coupon_id, order_no from eif_market.t_market_use_rec where activity_coupon_id=97)d
left outer join eif_ftc.t_ftc_fund_trans_order e on d.order_no=e.business_order_item_no
where e.status in (6,9,11)
)f on f.user_id=a.user_id
where a.activity_coupon_id=97 
      and date(a.issued_time)='2016-05-18' #限定发券日期
      #and a.status='1'
      and f.user_id is null
;



