//
//  CountDownBL.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/3.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "CountDownBL.h"

#define USER_DEFAULTS_KEY_COUNT_DOWN_START_DATE     @"USER_DEFAULTS_KEY_COUNT_DOWN_START_DATE"

@interface CountDownBL ()
/** 倒计时起始时间 */
@property(nonatomic, copy)  NSString *countDownStartTime;

@end


@implementation CountDownBL

static id sharedManager = nil;
+ (id)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// 保留倒计时开始日期
- (void)setCountDownStartTime:(NSString *)startTime{
    _countDownStartTime = startTime;
    [[NSUserDefaults standardUserDefaults] setObject:startTime forKey:USER_DEFAULTS_KEY_COUNT_DOWN_START_DATE];
}

// 获取倒计时开始日期
- (NSString *)getCountDownStartTime{
    if ( nil == _countDownStartTime ) {
        _countDownStartTime = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_KEY_COUNT_DOWN_START_DATE];
    }
    return _countDownStartTime;
}

// 清除倒计时开始时间
- (void)removeCountDownStartTime{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_KEY_COUNT_DOWN_START_DATE];
}


@end
