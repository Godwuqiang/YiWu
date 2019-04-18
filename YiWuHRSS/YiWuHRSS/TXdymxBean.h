//
//  TXdymxBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface TXdymxBean : BaseDictEntity

@property(nonatomic,strong) NSString        *xzmc;         // 险种名称
@property(nonatomic,strong) NSString        *ffsj;         // 发放时间
@property(nonatomic,strong) NSString        *ffbank;       // 发放银行
@property(nonatomic,strong) NSString        *bankno;       // 银行卡号
@property(nonatomic,strong) NSString        *ffje;         // 发放金额
@property(nonatomic,strong) NSString        *jfStatus;     // 缴费状态

@end
