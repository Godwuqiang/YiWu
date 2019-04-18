//
//  AppDelegate.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/11.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTabBarController.h"
#import "EAIntroView.h"
#import "HomePageVC.h"
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
//#ifdef NSFoundationVersionNumber_ios_9_x_Max
#import <UserNotifications/UserNotifications.h>
//#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)  UIWindow  *window;
@property (nonatomic, strong)   NSTimer  *Tokentimer;
@property (nonatomic, strong)   NSTimer  *Statustimer;
@property (nonatomic)            BOOL    TokentimerRunning;
@property (nonatomic)            BOOL    StatustimerRunning;

//@property (strong, nonatomic)  UIImageView *bgImgView;

@end

