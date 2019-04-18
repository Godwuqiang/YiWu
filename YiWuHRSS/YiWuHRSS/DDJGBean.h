//
//  DDJGBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/9.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface DDJGBean : BaseDictEntity

@property(nonatomic,strong) NSString        *ddyljgmc;       // 定点医疗机构名称
@property(nonatomic,strong) NSString        *dz;             // 地址
@property(nonatomic,strong) NSString        *lxdh;           // 联系电话
@property(nonatomic,strong) NSString        *jj;             // 简介
@property(nonatomic,strong) NSString        *jd;             // 经度
@property(nonatomic,strong) NSString        *wd;             // 纬度
@property(nonatomic,strong) NSString        *jl;             // 距离

@end
