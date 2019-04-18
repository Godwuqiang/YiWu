//
//  TXdyBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface TXdyBean : BaseDictEntity

@property(nonatomic,strong) NSString        *ffsj;         // 发放时间
@property(nonatomic,strong) NSString        *ffje;         // 发放金额
@property(nonatomic,strong) NSString        *ffStatus;     // 发放状态

@end
