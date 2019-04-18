//
//  NSDate+Util.h
//  PingHuHRSS
//
//  Created by 丁飞 on 15/9/25.
//  Copyright (c) 2015年 丁飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)
// 获取当前系统日期，格式为：yyyy年MM月dd日
+(NSString *)getCurentDate;
// 时间戳转为日期，格式为：yyyy年MM月dd日
+(NSString *)parserDateTimeLong:(long)dateTime;
@end