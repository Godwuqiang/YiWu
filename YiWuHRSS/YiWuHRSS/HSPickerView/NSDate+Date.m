//
//  NSDate+Date.m
//  我的-设置
//
//  Created by 胡松 on 2017/9/12.
//  Copyright © 2017年 husong. All rights reserved.
//

#import "NSDate+Date.h"

@implementation NSDate (Date)
+(NSString *)stringWithDate:(NSDate *)date{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString*strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"%@",strDate);
    
    return strDate;
}
@end
