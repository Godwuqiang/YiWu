//
//  XTCountDownService.h
//  XianTaoHRSS
//
//  倒计时服务：离开倒计时界面再返回时，倒计时不间断
//
//  Created by 丁飞 on 15/9/20.
//  Copyright (c) 2015年 丁飞. All rights reserved.
//

#import <Foundation/Foundation.h>

//---------------接口回调-------------------------//
@protocol CountDownServiceDelegate <NSObject>
@optional

// 倒计时回调
- (void)onTimeTick:(NSInteger)hasSeconds;
// 倒计时结束时回调
- (void)onTimeFinish;

@end
//----------------------------------------------//

@interface CountDownService : NSObject

@property(nonatomic, weak) id<CountDownServiceDelegate> delegate;

// 所剩秒数
@property(nonatomic, readonly, assign)    NSInteger   hasSeconds;

// 管理类的单例
+ (id)sharedManager;

// 计时器开始
- (void)countDownStart:(id<CountDownServiceDelegate>)delegate;
// 计时暂停（用户界面不显示时）
- (void)countDownPause;
// 计时继续（用户界面恢复时：如果时间没过期则继续计时）
- (void)countDownContinue:(id<CountDownServiceDelegate>)delegate;
// 计时终止
- (void)countDownStop;

@end
