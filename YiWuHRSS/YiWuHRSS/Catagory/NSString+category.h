//
//  NSString+category.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

//.h文件
#import <Foundation/Foundation.h>

@interface NSString (category)

- (NSInteger)getStringLenthOfBytes;

- (NSString *)subBytesOfstringToIndex:(NSInteger)index;

-(BOOL)validateChineseOrEnglish:(NSString *)string;


/**
 检查是否是中文或者英文
 
 @param string 被检查的字符串
 @return 是否允许输入
 */
+(BOOL)db_isValidateChineseOrEngnish:(NSString *)string;

//转码方法

/**
 URL decode
 
 @param str urlString
 @return decode string
 */
-(NSString*)URLDecodedString:(NSString*)str;

#pragma mark - 字符串与JSON的转换

/**
 把格式化的JSON格式的字符串转换成字典
 
 @param jsonString JSON格式的字符串
 @return 返回字典
 */
+(NSDictionary *)db_dictionaryWithJsonString:(NSString *)jsonString;

@end


