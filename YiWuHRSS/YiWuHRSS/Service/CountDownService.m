//
//  XTCountDownService.m
//  XianTaoHRSS
//
//  倒计时服务
//
//  Created by 丁飞 on 15/9/20.
//  Copyright (c) 2015年 丁飞. All rights reserved.
//

#import "CountDownService.h"
#import "CountDownBL.h"

#define COUNT_DOWN_SECONDS  (60)    // 倒计时总秒数

@interface CountDownService ()
/** 计时器 */
@property(nonatomic, strong)    NSTimer        *countDownTimer;

- (void)NSTimerContinue;
- (void)NSTimerPause;

@end

@implementation CountDownService

static id sharedManager = nil;
+ (id)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/**
 *  计时器开始
 */
- (void)countDownStart:(id<CountDownServiceDelegate>)delegate{
    [self countDownRestart:delegate andRestart:YES];
}

- (void)countDownRestart:(id<CountDownServiceDelegate>)delegate andRestart:(BOOL)restart{
    self.delegate = delegate;
    if (restart) {
        _hasSeconds = COUNT_DOWN_SECONDS + 1;
        
        // 当前时间
        [[CountDownBL sharedManager] setCountDownStartTime:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]];
    }
    
    // 每隔1秒执行一次
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    
    [self.countDownTimer fire];

}

- (void)timerFire:(NSTimer *)timer
{
    _hasSeconds--;
    if ( 0 == self.hasSeconds ) {
        // 计时终止
        [self countDownStop];

        // 结束
        [[CountDownBL sharedManager] removeCountDownStartTime];
        
        if([self.delegate respondsToSelector:@selector(onTimeFinish)]){
            [self.delegate onTimeFinish];
        }
    }else{
        // 计时
        if([self.delegate respondsToSelector:@selector(onTimeTick:)]){
            [self.delegate onTimeTick:self.hasSeconds];
        }
    }
}
/**
 *  计时暂停（用户界面不显示时）
 */
- (void)countDownPause{
    [self NSTimerPause];
}
/**
 *  计时继续（用户界面恢复时：如果时间没过期则继续计时）
 */
- (void)countDownContinue:(id<CountDownServiceDelegate>)delegate{
    // 获取计时开始时间
    NSString *startDateStr = [[CountDownBL sharedManager] getCountDownStartTime];
    if ( nil == startDateStr) {
        return;
    }
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startDateStr.doubleValue];
    
    // 比较
    NSTimeInterval intervalTime = [[NSDate date] timeIntervalSinceDate:startDate];
    NSInteger hasSecond = COUNT_DOWN_SECONDS - (int)(intervalTime + 0.5);
    if (hasSecond > 0 ) {
        _hasSeconds = hasSecond;
        
        if ( nil == self.countDownTimer ) {
            [self countDownRestart:delegate andRestart:NO];
        }else{
            self.delegate = delegate;
            [self NSTimerContinue];
        }

    }
}
/**
 *  计时终止
 */
- (void)countDownStop{
    //销毁定时器
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
}

- (void)NSTimerContinue{
    //开启定时器
    [self.countDownTimer setFireDate:[NSDate distantPast]];
}

- (void)NSTimerPause{
    //暂停定时器
    [self.countDownTimer setFireDate:[NSDate distantFuture]];
}

@end
