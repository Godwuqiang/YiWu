//
//  Util.h
//  NingBoHRSS
//
//  Created by 大白开发电脑 on 16/9/19.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+(Boolean)IsStringNil:(NSString *) string;
+(NSString*)IsPhone:(NSString *) phone;
+(NSString*)IsPassword:(NSString *)pass;


#pragma mark - 判断身份证是否符合规范  后期如需要请添加正则表达式
+(BOOL)IsIdCard:(NSString*)idcard;

#pragma mark - MD5加密方法
+(NSString*)MD5:(NSString*)input;

#pragma mark - 对指定的字符串截取指定的长度，用  *  代替 。参数为 str 数据源、 head 前面保留的位数、 end 后面需要保留的位数
+(NSString *)StrngForStar:(NSString*)str NumForHead:(int)head NumForEnd:(int)end;

#pragma mark - 按照|截取前面字段
+(NSString*)HeadStr:(NSString*)str WithNum:(int)num;

#pragma mark - 银行卡正则表达式
+(BOOL)IsBankCard:(NSString*)cardNumber;

#pragma mark - 字母数字校验
+(BOOL)IsZiMuNum:(NSString*)string;

#pragma mark - 社保卡号检验
+(BOOL)IsSheBaoNum:(NSString*)string;

#pragma mark - 家庭住址只能为中文、英文和数字
+(BOOL)IsCorrectAddress:(NSString*)string;

#pragma mark - 设置圆形图片
+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;

#pragma mark - 计算两点经纬度的距离
+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2;

#pragma mark - 获取设备唯一标示符 ios10更新之后一旦开启了 设置->隐私->广告->限制广告跟踪之后  获取到的idfa将会是一串00000  跟mac地址一个尿性，而且每次开启在关闭之后 相应的idfa也会重新生成，相当于还原了一次广告标识符。
+(NSString*)getuuid;

#pragma mark - 服务端与客户端约定的加解密方法
//加密方法
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;
//解密方法
+(NSString *) decryptUseDES:(NSString *)cipherText key:(NSString *)key;

@end
