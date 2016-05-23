--导入已成功发送客户手机号码
drop table bi.wy_temp
;
create table bi.wy_temp
(
mobile string
)
row format delimited fields terminated by ','
lines terminated by '\n'
stored as textfile
location "/bi/wangyi/wy_temp.txt"
;
load data local inpath '/home/wangyi/lufax_invest_m6.csv' overwrite  into table bi.wy_temp
;


--MySql导入文本数据

create table test.sms_send(  
mobile varchar(20) not null
);

load data local infile '/home/wangyi/mobile.txt' 
into table test.sms_send(mobile)
;

--关联

select
b.reg_channel,
sum(case when a.invited_code is null then 0 else 1 end) as recommanded_count,
sum(a.has_bankcard) as bankcard_count,
sum(case when c.member_no is null then 0 else 1 end) as certificated_count,
sum(case when d.member_no is null then 0 else 1 end) as transaction_count,
count(a.member_no) as member_no
from test.sms_send t
join eif_member.t_member a on t.mobile=a.verified_mobile
left outer join eif_member.t_member_client_external b on a.member_no=b.member_no
left outer join (select distinct member_no from eif_member.t_client_certification ) c on a.member_no=c.member_no
left outer join (select distinct member_no from eif_ftc.t_ftc_fund_trans_order where status in ('6','9','11')) d on a.member_no=d.member_no
group by b.reg_channel
;

select verified_mobile from eif_member.t_member
-- ----------------------------
DROP TABLE IF EXISTS `t_member`;
CREATE TABLE `t_member` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `member_no` char(32) NOT NULL,
  `name` varchar(64) DEFAULT NULL COMMENT '名称',
  `member_level` int(4) NOT NULL COMMENT '会员级别 0...',
  `member_type` int(4) NOT NULL COMMENT '会员类型；0-个人会员，1-机构会员，2-商户会员',
  `verified_email` varchar(64) DEFAULT NULL,
  `verified_mobile` varchar(32) DEFAULT NULL,
  `certificated_level` int(4) DEFAULT NULL COMMENT '实名认证等级，如果member_type是c端用户：0-未实名（手机号都没），1-弱实名（手机号），2-中实名（手机号＋身份证），3-强实名（手机号＋身份证＋银行卡）；如果是企业级别用户：0-未经过认证，1-已经过认证；如果是内部用户，0-未认证员工身份，1-认证员工身份',
  `certificated_type` int(4) DEFAULT NULL COMMENT '身份认证方式；C端用户，0-未认证，1-后台人工修改，2-手机号，3-快捷认证，4-账户汇款，5－关联认证，6－国政通，7-银行认证，8-企业认证。9-内部员工认证。。。',
  `outer_id` char(32) NOT NULL COMMENT '外部id，用于生成qr-code或者其他对外暴露用途。',
  `payment_password` varchar(256) DEFAULT NULL COMMENT '支付密码',
  `payment_pwd_strength` int(4) DEFAULT NULL COMMENT '支付密码强度，0-弱，1-中，2-强',
  `status` int(4) NOT NULL COMMENT '会员状态',
  `has_bankcard` int(4) DEFAULT NULL COMMENT '是否有银行卡',
  `has_payment_pwd` int(4) DEFAULT NULL COMMENT '是否有支付密码',
  `invite_code` char(32) NOT NULL COMMENT '当前用户的邀请码',
  `invited_code` char(32) DEFAULT NULL COMMENT '推荐者的邀请码',
  `white_list_group` varchar(256) DEFAULT NULL COMMENT '白名单组，用于辅助金融产品系统的千人千面业务区分，存储数据以“a,b,c”',
  `isStaff` int(4) DEFAULT NULL COMMENT '是否员工，0-否，1-是',
  `isRookie` int(4) DEFAULT NULL COMMENT '是否新手，0-否，1-是',
  `funds_to_type` int(4) DEFAULT NULL COMMENT '资金到款方，0 - 到银行卡；1 - 到活期理财，默认到活期理财',
  `commission` decimal(26,6) DEFAULT NULL COMMENT '佣金',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_t_member_collection` (`member_no`,`member_level`,`member_type`,`certificated_level`,`certificated_type`,`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=22727 DEFAULT CHARSET=utf8mb4 COMMENT='会员信息表';


13671519029     王一
15221513573     蔡文妹
13917799544     徐进进
13816807157     王恒
18510276782     有
18065296680     陆新元
13916925356     刘强