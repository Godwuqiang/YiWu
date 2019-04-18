//
//  EPDateSelectView.h
//  PingHuHRSS
//
//  Created by shi on 2017/8/11.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPDateSelectView : UIView

@property (copy) void (^selectDateFinishBlock)(NSDate *selectedDate);

+ (instancetype)showDateSelectView;

- (void)updateBeginDate:(NSDate *)beginData andEndDate:(NSDate *)endData;

@end
