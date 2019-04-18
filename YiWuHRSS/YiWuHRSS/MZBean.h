//
//  MZBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface MZBean : BaseDictEntity

@property(nonatomic,strong) NSString        *cbrxm;       // 参保人姓名
@property(nonatomic,strong) NSString        *rylb;        // 人员类别
@property(nonatomic,strong) NSString        *yyyd;        // 医院药店
@property(nonatomic,strong) NSString        *yibxflx;     // 医保消费类型
@property(nonatomic,strong) NSString        *jzrq;        // 就诊日期

@property(nonatomic,strong) NSString        *xmgg;        // 项目规格
@property(nonatomic,strong) NSString        *je;          // 金额
@property(nonatomic,strong) NSString        *zfy;         // 总费用
@property(nonatomic,strong) NSString        *ybbx;        // 医保报销
@property(nonatomic,strong) NSString        *xjzf;        // 现金支付

@property(nonatomic,strong) NSString        *jbms;        // 疾病描述


@end
