//
//  NSString+category.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "NSString+category.h"

@implementation NSString (category)

- (NSInteger)getStringLenthOfBytes
{
    NSInteger length = 0;
    for (int i = 0; i<[self length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseOrEnglish:s]) {
            
            NSLog(@" s 打印信息:%@",s);
            
            length +=2;
        }else{
            length +=1;
        }
        
        NSLog(@" 打印信息:%@  %ld",s,(long)length);
    }
    return length;
}

- (NSString *)subBytesOfstringToIndex:(NSInteger)index
{
    NSInteger length = 0;
    
    NSInteger chineseNum = 0;
    NSInteger zifuNum = 0;
    
    for (int i = 0; i<[self length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [self substringWithRange:NSMakeRange(i, 1)];
        if ([self validateChineseOrEnglish:s])
        {
            if (length + 2 > index)
            {
                return [self substringToIndex:chineseNum + zifuNum];
            }
            
            length +=2;
            
            chineseNum +=1;
        }
        else
        {
            if (length +1 >index)
            {
                return [self substringToIndex:chineseNum + zifuNum];
            }
            length+=1;
            
            zifuNum +=1;
        }
    }
    return [self substringToIndex:index];
}

//检测中文或者中文符号
- (BOOL)validateChineseChar:(NSString *)string
{
    NSString *nameRegEx = @"[\\u0391-\\uFFE5]";
    if (![string isMatchesRegularExp:nameRegEx]) {
        return NO;
    }
    return YES;
}

//检测中文
- (BOOL)validateChinese:(NSString*)string
{
    NSString *nameRegEx = @"[\u4e00-\u9fa5]";
    if (![string isMatchesRegularExp:nameRegEx]) {
        return NO;
    }
    return YES;
    
}
-(BOOL)validateChineseOrEnglish:(NSString *)string{
    
    NSString *pattern = @"[a-zA-Z\u4E00-\u9FA5\u278b-\u2792]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

- (BOOL)isMatchesRegularExp:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}



/**
 检查是否是中文或者英文

 @param string 被检查的字符串
 @return 是否允许输入
 */
+(BOOL)db_isValidateChineseOrEngnish:(NSString *)string{
    
    NSString * single = @"";
    
    for (int i = 0 ; i < string.length; i++) {
        
        
        
        single = [string substringWithRange:NSMakeRange(i, 1)];
        
        
        if(![single validateChineseOrEnglish:single]){
            
            DMLog(@"大白科技--正在检查不通过的的字符:%@",single);
            return NO;
        }
        DMLog(@"大白科技--正在检查通过的的字符:%@",single);
    }
    return YES;
}


//转码方法

/**
 URL decode

 @param str urlString
 @return decode string
 */
-(NSString*)URLDecodedString:(NSString*)str{
    
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)self,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}

#pragma mark - 字符串与JSON的转换

/**
 把格式化的JSON格式的字符串转换成字典
 
 @param jsonString JSON格式的字符串
 @return 返回字典
 */
+(NSDictionary *)db_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        NSLog(@"JSON解析失败：%@",error);
        return nil;
    }
    return dic;
}

@end

