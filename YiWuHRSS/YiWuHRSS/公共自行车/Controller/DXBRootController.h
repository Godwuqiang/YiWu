//
//  DXBRootController.h
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/31.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXBRootController : UIViewController


/// 当前城市
@property (nonatomic, strong) NSString *currentCity;

/// 当前的经纬度
@property (nonatomic, strong) NSString *show_longitude; // 经度
@property (nonatomic, strong) NSString *show_latitude;  // 纬度

@end
