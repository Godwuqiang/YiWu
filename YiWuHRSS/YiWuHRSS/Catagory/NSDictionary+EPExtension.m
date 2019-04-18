//
//  NSDictionary+EPExtension.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/2.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "NSDictionary+EPExtension.h"

@implementation NSDictionary (EPExtension)


#pragma mark - 字符串转字典
/**
 json格式字符串转字典

 @param jsonString JSON字符串
 @return 字典
 */
+ (NSDictionary *)ep_dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
