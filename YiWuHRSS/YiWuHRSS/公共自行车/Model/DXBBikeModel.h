//
//  DXBBikeModel.h
//  YiWuHRSS
//
//  Created by 大白 on 2017/8/2.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BaseDictEntity.h"

@interface DXBBikeModel : BaseDictEntity

@property (nonatomic, strong) NSString *capacity;        // 车壮总数
@property (nonatomic, strong) NSString *availBike;       // 可借数
@property (nonatomic, strong) NSString *address;         // 站点地址
@property (nonatomic, strong) NSString *id;              // 站点编号
@property (nonatomic, strong) NSString *distanceKm;      // 与当前定位的距离
@property (nonatomic, strong) NSString *lat;             // 纬度
@property (nonatomic, strong) NSString *lng;             // 经度
@property (nonatomic, strong) NSString *name;            // 站点名称


@end
