//
//  CountDownBL.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/3.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountDownBL : NSObject

// 管理类的单例
+(id)sharedManager;

// 保留倒计时开始时间
- (void)setCountDownStartTime:(NSString *)startTime;

// 获取倒计时开始时间
- (NSString *)getCountDownStartTime;

// 清除倒计时开始时间
- (void)removeCountDownStartTime;


@end
