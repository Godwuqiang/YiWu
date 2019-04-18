//
//  PublicDefine.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#ifndef PublicDefine_h
#define PublicDefine_h

#define CHANNELNO @"3307000004"
// Screen Height
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height
// Screen Width
#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
/** 状态栏高度 */
#define STATUS_BAR_HEIGHT           (20)
/** 导航栏高度 */
#define NAVGATION_BAR_HEIGHT        (44)
/** Tabbar高度 */
#define TAB_BAR_HEIGHT              (49)

// 隐藏返回键带的title
#define HIDE_BACK_TITLE             [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

// 使用DMLog打印日志（在调试模式下打印，在非调试模式下不打印）
#ifdef DEBUG
#define DMLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DMLog(...) do { } while (0)
#endif

// 使用StartBugly (在非调试模式下统计bugly,在调试模式下不统计bugly,)
#ifdef RELEASE
#define StartBugly(...) [Bugly startWithAppId:@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]];
#else
#define StartBugly(...) do { } while (0)
#endif

#define    PAGE_SIZE        (100)    // 医保消费
#define MAX_PAGE_COUNT      (20)    // 每页记录最大行数

#endif /* PublicDefine_h */
