//
//  DXBBikeShowView.h
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/31.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXBBikeShowView : UIView

@property (nonatomic, strong) void(^gotoOtherPlace)();

/// 站点名称
@property (nonatomic,strong) UILabel *label_name;
/// 车桩总数
@property (nonatomic,strong) UILabel *label_carPileTotal;
/// 可借数
@property (nonatomic,strong) UILabel *label_availTotal;
/// 距离
@property (nonatomic,strong) UILabel *label_distance;
/// 地址
@property (nonatomic,strong) UILabel *label_address;

@end
