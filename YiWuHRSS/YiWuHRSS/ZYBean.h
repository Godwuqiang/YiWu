//
//  ZYBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface ZYBean : BaseDictEntity

@property(nonatomic,strong) NSString        *cbrxm;       // 参保人姓名
@property(nonatomic,strong) NSString        *rylb;        // 人员类别
@property(nonatomic,strong) NSString        *yyyd;        // 医院药店
@property(nonatomic,strong) NSString        *ybxflx;     // 医保消费类型

@property(nonatomic,strong) NSString        *ryrq;        // 住院日期
@property(nonatomic,strong) NSString        *cyrq;        // 出院日期

@property(nonatomic,strong) NSString        *jlypfy;      // 甲类药品费用
@property(nonatomic,strong) NSString        *ylypfy;      // 乙类药品费用
@property(nonatomic,strong) NSString        *blypfy;      // 丙类药品费用
@property(nonatomic,strong) NSString        *jlzlfy;      // 甲类诊疗费用
@property(nonatomic,strong) NSString        *ylzlfy;      // 乙类诊疗费用
@property(nonatomic,strong) NSString        *blzlfy;      // 丙类诊疗费用


@property(nonatomic,strong) NSString        *xyf;         // 西药费
@property(nonatomic,strong) NSString        *cwf;         // 床位费
@property(nonatomic,strong) NSString        *zcf;         // 诊查费
@property(nonatomic,strong) NSString        *jyf;         // 检验费
@property(nonatomic,strong) NSString        *zlf;         // 治疗费
@property(nonatomic,strong) NSString        *hlf;         // 护理费


@property(nonatomic,strong) NSString        *zfy;         // 总费用
@property(nonatomic,strong) NSString        *ybbx;        // 医保报销
@property(nonatomic,strong) NSString        *xjzf;        // 现金支付
@property(nonatomic,strong) NSString        *jbms;        // 疾病描述


@end
