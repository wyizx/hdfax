***--2016.05.04
----- BDͨ���ⲿ��ͣ��ʹ����������Ӵ�����ȡע���û���5��1��-5��3��С��Χ�������£��ֽ�û�м�ص�ע�����ݣ�
----- �鷳����߿����Ƿ��з������ݡ��������Ϊ��A_chubao0428a

select date(a.create_time), count(*) 
from eif_member.t_member a
join eif_member.t_member_client_external b on a.member_no=b.member_no
where b.market_channel='A_chubao0428a'
group by date(a.create_time)
;