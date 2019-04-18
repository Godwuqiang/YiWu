//
//  YLAccountBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface YLAccountBean : BaseDictEntity

@property(nonatomic,strong) NSString        *ffnd;         // 发放年度
@property(nonatomic,strong) NSString        *snmzhze;      // 上年末账户余额
@property(nonatomic,strong) NSString        *bnsjjfys;     // 本年实际缴费月数
@property(nonatomic,strong) NSString        *dnhzje;       // 当年划账金额
@property(nonatomic,strong) NSString        *dnzhlx;       // 当年账户类型
@property(nonatomic,strong) NSString        *sjjfys;       // 实际缴费月数
@property(nonatomic,strong) NSString        *ljcce;        // 累计储存额

@end
