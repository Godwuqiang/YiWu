//
//  SSCSkinConfig.h
//  EESBCardSDK
//
//  Created by zaiwei on 2018/7/5.
//  Copyright © 2018年 wonder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCSDKConfig : NSObject

//requid
/** 设置sdk 的appHost*/
@property (nonatomic, copy)NSString *appHost;


//optional
/*页面进度条颜色， 默认 [UIColor grayColor] */
@property (nonatomic, strong) UIColor *porgressLineColor;

/*页面加载时菊花的颜色， 默认 [UIColor grayColor] */
@property (nonatomic, strong) UIColor *activityIndicatorColor;

/** 设置sdk NavigationControler导航栏的的颜色值。 */
@property (nonatomic, strong) UIColor *navigationBackgroudColor;

/** 设置sdk NavigationControler的导航栏的的title字体颜色值。*/
@property (nonatomic, strong) UIColor *navigationTextColor;

/** 设置sdk 导航栏返回（关闭）按钮的颜色  请和导航栏颜色不同，否则会导致看不到*/
@property (nonatomic, strong) UIColor *backIconColor;
@end
