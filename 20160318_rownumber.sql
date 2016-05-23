-- hive
select a.*
from(
select t.* ,row_number() over (distribute by tx_dt
sort by pay_amount desc ) as rownum
from (
select  tx_dt
        ,prod_nm  --产品名称
        ,sum(Consm_Point_Cnt) as pay_amount
from csum.H52_MP_Point_TX_Csum a
left outer join idata.h03_product b
on a.prod_id=b.prod_id
where tx_dt >='2016-03-01'
and tx_dt <='2016-03-09'
group by TX_Dt,prod_nm
)t
)a
where rownum=1;


--下面是我的感受：
--我现在使用的hive的版本是0.12，但如果写成上面那样，还是报错，不会执行：如：
hive> select sale_ord_id,ivc_tm from 
    > (select sale_ord_id,ivc_tm,row_number() over (distribute by sale_ord_id sort by ivc_tm desc) rn 
    > from gdm_mXX_inv_actual_det_sum_da 
    > where dt='2014-12-09'
    > and valid_flag=1) a
    > where a.rn=1
    > limit 50
    > ;
--FAILED: NullPointerException null
--后来同事告诉我，这个版本还是不支持的，需要写在row_number()的括号里面，于是我改成了如下方式：
select sale_ord_id,ivc_title,row_number(ivc_tm) as rn 
from 
(select sale_ord_id,ivc_tm,ivc_title 
from gdm_mXX_inv_actual_det_sum_da 
where dt='2014-12-09'
and valid_flag=1
distribute by sale_ord_id 
sort by ivc_tm desc) a
where row_number(ivc_tm)=1
limit 50
;
--这次可以了。


-- mysql 实现

    select empid,deptid,salary,rank 
    from (
    select heyf_tmp.empid,heyf_tmp.deptid,heyf_tmp.salary,@rownum:=@rownum+1 ,
    if(@pdept=heyf_tmp.deptid,@rank:=@rank+1,@rank:=1) as rank,
     @pdept:=heyf_tmp.deptid
    from (
   select empid,deptid,salary from heyf_t10 order by deptid asc ,salary desc
    ) heyf_tmp ,(select @rownum :=0 , @pdept := null ,@rank:=0) a ) result
     ;
+——-+——–+———-+——+
| empid | deptid | salary   | rank |
+——-+——–+———-+——+
|     1 |     10 |  5500.00 |    1 |
|     2 |     10 |  4500.00 |    2 |
|     4 |     20 |  4800.00 |    1 |
|     3 |     20 |  1900.00 |    2 |
|     7 |     40 | 44500.00 |    1 |
|     6 |     40 | 14500.00 |    2 |
|     5 |     40 |  6500.00 |    3 |
|     9 |     50 |  7500.00 |    1 |
|     8 |     50 |  6500.00 |    2 |


-- mysql 实现求累加
-- 求累加

SELECT a.id,a.money,SUM(lt.money)  as cum 
FROM cum_demo a 
JOIN cum_demo lt  
ON a.id >= lt.id 
GROUP BY a.money 
ORDER BY id 

结果

id money cum 
1 10 10 
2 20 30 
3 30 60 
4 40 100 
