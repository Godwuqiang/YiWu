//
//  NSDictionary+EPExtension.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/2.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (EPExtension)

#pragma mark - 字符串转字典
/**
 json格式字符串转字典
 
 @param jsonString JSON字符串
 @return 字典
 */
+ (NSDictionary *)ep_dictionaryWithJsonString:(NSString *)jsonString;

@end
