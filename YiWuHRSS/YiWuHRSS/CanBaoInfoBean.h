//
//  CanBaoInfoBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/8.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface CanBaoInfoBean : BaseDictEntity

@property(nonatomic,strong) NSString        *xzname;       // 险种名称
@property(nonatomic,strong) NSString        *cbdw;         // 参保单位
@property(nonatomic,strong) NSString        *cbzt;         // 参保状态
@property(nonatomic,strong) NSString        *jfzt;         // 缴费状态

@end
