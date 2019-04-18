//
//  ParkBean.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/8/1.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface ParkBean : BaseDictEntity

@property(nonatomic,strong) NSString        *parkname;       // 停车场名称
@property(nonatomic,strong) NSString        *count;          // 车位总数
@property(nonatomic,strong) NSString        *surplusnum;     // 可用车位
@property(nonatomic,strong) NSString        *distanceKm;     // 与当前定位的距离

@property(nonatomic,strong) NSString        *longitude;      // 经度
@property(nonatomic,strong) NSString        *latitude;       // 纬度
@property(nonatomic,strong) NSString        *type;           // 停车场类型
@property(nonatomic,strong) NSString        *address;        // 停车场地址

@property(nonatomic,strong) NSString        *id;             // 停车场id

@end
