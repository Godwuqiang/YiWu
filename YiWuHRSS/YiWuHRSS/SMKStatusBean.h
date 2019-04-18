//
//  SMKStatusBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/23.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface SMKStatusBean : BaseDictEntity

@property(nonatomic,strong) NSString        *name;      // 姓名
@property(nonatomic,strong) NSString        *shbzh;     // 社会保障号
@property(nonatomic,strong) NSString        *cardNo;    // 卡号
@property(nonatomic,strong) NSString        *bankNo;    // 银行卡号
@property(nonatomic,strong) NSString        *bankMobile; // 注册手机号
@property(nonatomic,strong) NSString        *cardType;   // 卡类型

@end
