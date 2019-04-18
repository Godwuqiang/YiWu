//
//  Util.m
//  NingBoHRSS
//
//  Created by 大白开发电脑 on 16/9/19.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "Util.h"
#import "SAMKeychain.h"
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonCrypto.h>
#import<CommonCrypto/CommonDigest.h>
#import "Base64.h"

#define PI 3.1415926

@implementation Util
const Byte iv[] = {1,2,3,4,5,6,7,8};

//判断string型的字符串是否为 nill 或者为 @“”  空字符
+(Boolean)IsStringNil:(NSString *)string{
    
    if([[string class] isKindOfClass:[NSNull class]]){
        return true;
    }
    
    @try {
        if(string == nil || [string isEqualToString:@""] || [string isEqualToString:@"null"]){
            return true;
        }else return false;
    } @catch (NSException *exception) {
        DMLog(@"判断字符串是否为空或nil异常错误:%@",exception);
        return false;
    }
}
//判断手机号是否正确
+(NSString*)IsPhone:(NSString *)phone{
    @try {
        if (phone == nil || [phone isEqualToString:@""]) {
            return @"请输入有效的手机号";
        }
        if (phone.length != 11) {
            return @"请输入有效的手机号";
        }
        NSString *phoneRegex1=@"1[34578]([0-9]){9}";
        NSPredicate *phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex1];
        if ([phoneTest1 evaluateWithObject:phone]) {
            return @"OK";
        }else{
            return @"OK";
            //return @"请输入有效的手机号";
        }
    } @catch (NSException *exception) {
        //DMLog(@"手机号校验正则表达式异常错误:%@",exception);
        return @"OK";
        //return @"请输入有效的手机号";
    }
}

//判断密码位数及数字字母组合
+(NSString *)IsPassword:(NSString *)pass{
    @try {
        if (pass == nil || [pass isEqualToString:@""]) {
            return @"密码必须为6-18位数字+字母的组合，请重新输入";
        }
        if (pass.length > 18 || pass.length < 6 ){
            return @"密码必须为6-18位数字+字母的组合，请重新输入";
        }else{
            BOOL result = false;
            // 判断长度大于8位后再接着判断是否同时包含数字和字符
            NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            result = [pred evaluateWithObject:pass];
            if (result) {
                return @"OK";
            }else{
                return @"密码必须为6-18位数字+字母的组合，请重新输入";
            }
        }
    } @catch (NSException *exception) {
        DMLog(@"判断密码位数异常错误:%@",exception);
        return @"请输入符合条件的密码";
    }
}


/**
 *对指定的字符串截取指定的长度，用  *  代替 。参数为 str 数据源、 head 前面保留的位数、 end 后面需要保留的位数
 **/
+(NSString *)StrngForStar:(NSString*)str NumForHead:(int)head NumForEnd:(int)end{
    @try {
        if (str == nil || str.length == 0) {
            return @"暂无数据";
        }
        NSString * str2 = [str substringWithRange:NSMakeRange(head,str.length-(head+end))];
        NSMutableString *star = [[NSMutableString alloc] initWithCapacity:100];
        NSInteger lent = str2.length;
        for (int i = 0; i <lent; i++) {
            [star appendString:@"*"];
        }
        NSString * string = [NSString stringWithFormat:@"%@%@%@",[str substringToIndex:head],star, [str substringFromIndex:(str.length -end)]];
        
        return string;
    } @catch (NSException *exception) {
        DMLog(@"字符串截取指定的长度错误异常:%@",exception);
        return str;
    }
}


// 按照|截取前面字段
+(NSString*)HeadStr:(NSString*)str WithNum:(int)num{
    @try {
        NSArray *listItems = [str componentsSeparatedByString:@"|"];
        NSString *data = listItems[num];
        return data;
    } @catch (NSException *exception) {
        DMLog(@"字符串截取指定的长度错误异常:%@",exception);
        return str;
    }
}


//判断身份证是否符合规范  后期如需要请添加正则表达式
+(BOOL)IsIdCard:(NSString*)idcard{
    @try {
        if(idcard.length == 18){//身份证符合规范
            idcard = [idcard stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
            NSString *leapMmdd = @"0229";
            NSString *year = @"(19|20)[0-9]{2}";
            NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
            NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
            NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
            NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
            NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
            NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
            
            NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if (![regexTest evaluateWithObject:idcard]) {
                 return NO;
            }
            int summary = ([idcard substringWithRange:NSMakeRange(0,1)].intValue + [idcard substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([idcard substringWithRange:NSMakeRange(1,1)].intValue + [idcard substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([idcard substringWithRange:NSMakeRange(2,1)].intValue + [idcard substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([idcard substringWithRange:NSMakeRange(3,1)].intValue + [idcard substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([idcard substringWithRange:NSMakeRange(4,1)].intValue + [idcard substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([idcard substringWithRange:NSMakeRange(5,1)].intValue + [idcard substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([idcard substringWithRange:NSMakeRange(6,1)].intValue + [idcard substringWithRange:NSMakeRange(16,1)].intValue) *2 + [idcard substringWithRange:NSMakeRange(7,1)].intValue *1 + [idcard substringWithRange:NSMakeRange(8,1)].intValue *6 + [idcard substringWithRange:NSMakeRange(9,1)].intValue *3;
            NSInteger remainder = summary % 11;
            NSString *checkBit = @"";
            NSString *checkString = @"10X98765432";
            checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
            return [checkBit isEqualToString:[[idcard substringWithRange:NSMakeRange(17,1)] uppercaseString]];
//            return YES;
        }else return NO;
    } @catch (NSException *exception) {
        DMLog(@"身份证正则表达式错误异常:%@",exception);
        return NO;
    }
}

// MD5加密
+(NSString*)MD5:(NSString*)input{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


//银行卡正则表达式
+(BOOL)IsBankCard:(NSString*)cardNumber{
    @try {
            if(cardNumber.length<2)
            {
                return NO;
            }
            int oddsum = 0;     //奇数求和
            int evensum = 0;    //偶数求和
            int allsum = 0;
            int cardNoLength = (int)[cardNumber length];
            int lastNum = [[cardNumber substringFromIndex:cardNoLength-1] intValue];
        
            cardNumber = [cardNumber substringToIndex:cardNoLength - 1];
            for (int i = cardNoLength -1 ; i>=1;i--) {
                NSString *tmpString = [cardNumber substringWithRange:NSMakeRange(i-1, 1)];
                int tmpVal = [tmpString intValue];
                if (cardNoLength % 2 ==1 ) {
                    if((i % 2) == 0){
                        tmpVal *= 2;
                        if(tmpVal>=10)
                            tmpVal -= 9;
                        evensum += tmpVal;
                    }else{
                        oddsum += tmpVal;
                    }
                }else{
                    if((i % 2) == 1){
                        tmpVal *= 2;
                        if(tmpVal>=10)
                            tmpVal -= 9;
                        evensum += tmpVal;
                    }else{
                        oddsum += tmpVal;
                    }
                }
            }
        
            allsum = oddsum + evensum;
            allsum += lastNum;
            if((allsum % 10) == 0)
                return YES;
            else
                return NO;
    } @catch (NSException *exception) {
        DMLog(@"银行卡正则表达式错误异常:%@",exception);
        return NO;
    }
}

// 字母数字校验
+(BOOL)IsZiMuNum:(NSString*)string{
    NSString *regex = @"^[A-Za-z0-9]+$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([predicate evaluateWithObject:string] == YES) {
        return YES;
    }else return NO;
}

// 社保号检验
+(BOOL)IsSheBaoNum:(NSString*)string{
    @try {
        if (string.length==9) {
            NSString *regex = @"^[A-Za-z0-9]+$";
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            
            if ([predicate evaluateWithObject:string] == YES) {
                return YES;
            }else return NO;
        }else{
            return NO;
        }
    } @catch (NSException *exception) {
        DMLog(@"社保卡正则表达式错误异常:%@",exception);
        return NO;
    }
}

// 家庭住址只能为中文、英文和数字
+(BOOL)IsCorrectAddress:(NSString*)string{
    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:string]) {
        return YES;
    }else{
        return NO;
    }
}

//设置圆形图片
+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}

+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
    double er = 6378137; // 6378700.0f;
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist/1000;
}

//获取设备唯一标示符 ios10更新之后一旦开启了 设置->隐私->广告->限制广告跟踪之后  获取到的idfa将会是一串00000  跟mac地址一个尿性，而且每次开启在关闭之后 相应的idfa也会重新生成，相当于还原了一次广告标识符。
+(NSString*)getuuid{
    NSString *result = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if ([result isEqualToString:@" 00000000-0000-0000-0000-000000000000"]||[result isEqualToString:@"00000000-0000-0000-0000-000000000000"])
    {
        NSString * currentDeviceUUIDStr = [SAMKeychain passwordForService:@" "account:@"uuid"];
        if (currentDeviceUUIDStr == nil || [currentDeviceUUIDStr isEqualToString:@""])
        {
            currentDeviceUUIDStr = [[NSUUID UUID] UUIDString];
            currentDeviceUUIDStr = [currentDeviceUUIDStr lowercaseString];
            [SAMKeychain setPassword: currentDeviceUUIDStr forService:@" "account:@"uuid"];
        }
        result = currentDeviceUUIDStr;
    }
    
    if (result == nil) {
        result = @"";
    }
    return result;
}

#pragma mark- 加密算法
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *ciphertext = nil;
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes], dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [Base64 encode:data];
    }
    return ciphertext;
}

#pragma mark- 解密算法
+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key
{
    NSString *plaintext = nil;
    NSData *cipherdata = [Base64 decode:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    // kCCOptionPKCS7Padding|kCCOptionECBMode 最主要在这步
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, 1024,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
    }
    return plaintext;
}


@end
