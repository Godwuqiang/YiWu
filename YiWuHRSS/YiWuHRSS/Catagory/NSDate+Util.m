//
//  NSDate+Util.m
//  PingHuHRSS
//
//  Created by 丁飞 on 15/9/25.
//  Copyright (c) 2015年 丁飞. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

+ (NSString *)getCurentDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString *)parserDateTimeLong:(long)dateTime{
    // 解析时间戳
    NSDate *mydate=[NSDate dateWithTimeIntervalSince1970:dateTime / 1000.0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyy年MM月dd日"];
    return [formatter stringFromDate:mydate];
}

@end