//
//  EPSDKConfig.h
//  ZjEsscSDK
//
//  Created by MacBook Pro on 2018/11/29.
//  Copyright © 2018年 HouXinbing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EPSDKConfig : NSObject

/**
 渠道号需要向省平台申请统一提供
 */
@property (nonatomic, strong) NSString *channelNo;

/**
 环境变量  true是测试环境，false是正式环境。不传默认为false
 */
@property (nonatomic, assign) BOOL openDebug;

/**
 设置sdk NavigationControler导航栏的的颜色值
 */
@property (nonatomic, strong) UIColor *navigationBackgroudColor;

/**
 设置sdk NavigationControler的导航栏的的title字体颜色值
 */
@property (nonatomic, strong) UIColor *navigationTextColor;



@end
